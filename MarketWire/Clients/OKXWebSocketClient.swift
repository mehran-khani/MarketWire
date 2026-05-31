import Foundation

enum OKXWebSocketError: Error, Sendable, LocalizedError {
    case notConnected
    case connectTimeout
    case encodingFailed

    var errorDescription: String? {
        switch self {
        case .notConnected:
            "WebSocket is not connected."
        case .connectTimeout:
            "Timed out while connecting to the market stream."
        case .encodingFailed:
            "Failed to encode the subscription request."
        }
    }
}

actor OKXWebSocketClient {
    private let url: URL
    private let session: URLSession
    private var webSocketTask: URLSessionWebSocketTask?
    private var pingTask: Task<Void, Never>?
    private var isDisconnected = false

    init(url: URL = OKXConfiguration.publicWebSocketURL) {
        self.url = url
        session = URLSession(configuration: .default)
    }

    func connect() async throws {
        disconnect()
        isDisconnected = false

        let task = session.webSocketTask(with: url)
        webSocketTask = task
        task.resume()

        try await withThrowingTaskGroup(of: Void.self) { group in
            group.addTask {
                try await withCheckedThrowingContinuation { (continuation: CheckedContinuation<Void, Error>) in
                    task.sendPing { error in
                        if let error {
                            continuation.resume(throwing: error)
                        } else {
                            continuation.resume()
                        }
                    }
                }
            }
            group.addTask {
                try await Task.sleep(nanoseconds: OKXConfiguration.connectTimeoutNanoseconds)
                throw OKXWebSocketError.connectTimeout
            }
            _ = try await group.next()
            group.cancelAll()
        }
    }

    func subscribe(args: [OkxSubscribeArg]) async throws {
        guard let webSocketTask else {
            throw OKXWebSocketError.notConnected
        }
        let message = try OkxMessageCodec.encodeSubscribe(to: args)
        try await webSocketTask.send(.string(message))
    }

    func marketEvents() -> AsyncStream<MarketEvent> {
        AsyncStream { continuation in
            let receiveTask = Task {
                await self.receiveLoop(continuation: continuation)
            }

            continuation.onTermination = { @Sendable _ in
                receiveTask.cancel()
                Task { await self.disconnect() }
            }
        }
    }

    func disconnect() {
        isDisconnected = true
        pingTask?.cancel()
        pingTask = nil
        webSocketTask?.cancel(with: .goingAway, reason: nil)
        webSocketTask = nil
    }

    private func startPing() {
        pingTask?.cancel()
        pingTask = Task { [webSocketTask] in
            while !Task.isCancelled {
                try? await Task.sleep(nanoseconds: OKXConfiguration.pingIntervalNanoseconds)
                guard !Task.isCancelled, let webSocketTask else { return }
                try? await webSocketTask.send(.string("ping"))
            }
        }
    }

    private func receiveLoop(continuation: AsyncStream<MarketEvent>.Continuation) async {
        guard let webSocketTask, !isDisconnected else {
            continuation.finish()
            return
        }

        startPing()

        while !isDisconnected {
            do {
                let message = try await webSocketTask.receive()
                guard let data = data(from: message) else {
                    continue
                }

                let events = try OkxMessageCodec.marketEvents(from: data)
                for event in events {
                    continuation.yield(event)
                }
            } catch {
                if !isDisconnected {
                    continuation.finish()
                }
                return
            }
        }

        continuation.finish()
    }

    private func data(from message: URLSessionWebSocketTask.Message) -> Data? {
        switch message {
        case let .string(text):
            if text == "pong" {
                return nil
            }
            return Data(text.utf8)

        case let .data(data):
            return data

        @unknown default:
            return nil
        }
    }
}
