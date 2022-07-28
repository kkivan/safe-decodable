import XCTest
@testable import safe_decodable

final class safe_decodableTests: XCTestCase {

    let d: JSONDecoder = JSONDecoder()

    func decode<T: Decodable>(_ json: String) -> T {
        try! d.decode(T.self, from: json.data(using: .utf8)!)
    }

    func testSingleValues() throws {
        let int: Safe<Int> = decode("1")
        XCTAssertEqual(int.wrappedValue, 1)
        let str: Safe<String> = decode("\"str\"")
        XCTAssertEqual(str.wrappedValue, "str")
        let double: Safe<Double> = decode("1.1")
        XCTAssertEqual(double.wrappedValue, 1.1)
    }

    func testStructMappingDoesntThrow() {
        let json =
        """
        {
            "int": "1",
            "str": "str"
        }
        """


        let simple: Simple = decode(json)
        XCTAssertNotNil(simple.$int.error)
        XCTAssertEqual(simple.str, "str")
    }

    func testThatMissingKeyDecodesToNil() {
        let json =
        """
        {
            "str": "str"
        }
        """
        let simple: Safe<Simple> = decode(json)
        XCTAssertNotNil(simple.wrappedValue?.str)
    }

    func estCollectErrors() {
        let json =
        """
        {
            "int": "1",
            "str": "str",
            "nested": {
                "str": "1"
            }
        }
        """
        let nested: Nested = decode(json)
        dump(nested)
        XCTAssertEqual(nested.nested?.str, "str")
    }
}

struct Nested: Decodable {
    @Safe var int: Int?
    @Safe var str: String?
    @Safe var nested: Simple?
}

struct Simple: Decodable {
    @Safe var int: Int?
    @Safe var str: String?
}
