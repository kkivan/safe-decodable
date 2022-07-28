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

    func testCollectErrors() {
        let json =
        """
        {
            "int": "1",
            "str": "str",
            "nested": {
                "str": 1
            }
        }
        """
        let nested: Safe<Nested> = decode(json)
        // assert 3 errors but MissingValue shoud be discarded
        XCTAssertEqual(nested.wrappedValue?.nested?.str, "str")
    }

    func testArray() {
        let json =
        """
        {
            "arr": [1,2,"3"]
        }
        """
        let array: WithArray = decode(json)
        XCTAssertEqual(array.arr?.count, 2)
    }

    func testArrayOfStructs() {
        let json =
        """
        {
            "arr": [{ "int": 1, "str": 1 }, { "int": 1, "str": 1 }]
        }
        """
        let array: WithSimpleArray = decode(json)

        XCTAssertEqual(array.arr?[0].int, 1)
        XCTAssertEqual(array.arr?[1].int, 1)
    }

    func testGeneric() {

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

struct WithArray: Decodable {
    @SafeArray var arr: [Int]?
}

struct WithSimpleArray: Decodable {
    @SafeArray var arr: [Simple]?
}
