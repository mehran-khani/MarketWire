import Foundation

private final class FixtureBundleAnchor {}

enum Fixture {
    enum Provider: String {
        case coinbase = "Coinbase"
        case okx = "OKX"
    }

    enum FixtureError: Error {
        case notFound(String)
    }

    static func data(_ name: String, provider: Provider) throws -> Data {
        let bundle = Bundle(for: FixtureBundleAnchor.self)
        let subdirectory = "Fixtures/\(provider.rawValue)"
        guard let url = bundle.url(forResource: name, withExtension: "json", subdirectory: subdirectory) else {
            throw FixtureError.notFound("\(subdirectory)/\(name).json")
        }
        return try Data(contentsOf: url)
    }
}
