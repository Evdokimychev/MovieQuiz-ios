
import XCTest
@testable import MovieQuiz

class ArrayTests: XCTestCase {

    func testOutOfRangeArray() {
        let testArray = [Int]()
        let value = testArray[safe: 0]
        XCTAssertNil(value)
    }

    func testByIndexArray() {
        let testArray = [1,2,3,4,5]
        let value = testArray[safe: 3]
        XCTAssertEqual(value, 4)
    }

}
