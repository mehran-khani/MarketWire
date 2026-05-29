import Foundation

private final class FixtureBundleAnchor {}

enum Fixture {
    enum FixtureError: Error {
        case notFound(String)
    }

    static func data(_ name: String) throws -> Data {
        let bundle = Bundle(for: FixtureBundleAnchor.self)
        let url = bundle.url(forResource: name, withExtension: "json", subdirectory: "Fixtures")
            ?? bundle.url(forResource: name, withExtension: "json")
        guard let url else {
            throw FixtureError.notFound(name)
        }
        return try Data(contentsOf: url)
    }
}
