import XCTest
@testable import LibToken

final class LibTokenTests: XCTestCase {
    func testExample() {
        // This is an example of a functional test case.
        // Use XCTAssert and related functions to verify your tests produce the correct
        // results.
        XCTAssertEqual(LibToken().text, "Hello, World!")
    }

    static var allTests = [
        ("testExample", testExample),
    ]
}
