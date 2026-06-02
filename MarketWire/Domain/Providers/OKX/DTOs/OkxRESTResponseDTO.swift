import Foundation

nonisolated struct OkxRESTResponseDTO<DataDTO: Decodable & Sendable>: Decodable, Sendable {
    let code: String
    let msg: String?
    let data: DataDTO

    var isSuccess: Bool { code == "0" }
}
