#if !os(macOS) && !os(watchOS)
    @testable import Differ
    import XCTest

    private func IP(_ row: Int, _ section: Int) -> IndexPath {
        return IndexPath(row: row, section: section)
    }

    class BatchUpdateTests: XCTestCase {
        private struct Expectation {
            let orderBefore: [Int]
            let orderAfter: [Int]
            let insertions: [IndexPath]
            let deletions: [IndexPath]
            let moves: [(from: IndexPath, to: IndexPath)]
        }

        private let cellExpectations: [Expectation] = [
            Expectation(orderBefore: [1, 2, 3, 4], orderAfter: [1, 2, 3, 4], insertions: [], deletions: [], moves: []),
            Expectation(orderBefore: [1, 2, 3, 4], orderAfter: [4, 2, 3, 1], insertions: [], deletions: [], moves: [(IP(0, 0), IP(3, 0)), (IP(3, 0), IP(0, 0))]),
            Expectation(orderBefore: [1, 2, 3, 4], orderAfter: [2, 3, 1], insertions: [IP(3, 0)], deletions: [], moves: [(IP(0, 0), IP(2, 0))]),
            Expectation(orderBefore: [1, 2, 3, 4], orderAfter: [5, 2, 3, 4], insertions: [IP(0, 0)], deletions: [IP(0, 0)], moves: []),
            Expectation(orderBefore: [1, 2, 3, 4], orderAfter: [4, 1, 3, 5], insertions: [IP(1, 0)], deletions: [IP(3, 0)], moves: [(IP(2, 0), IP(0, 0))]),
            Expectation(orderBefore: [1, 2, 3, 4], orderAfter: [4, 2, 3, 4], insertions: [IP(0, 0)], deletions: [IP(0, 0)], moves: []),
            Expectation(orderBefore: [1, 2, 3, 4], orderAfter: [1, 2, 4, 4], insertions: [IP(2, 0)], deletions: [IP(3, 0)], moves: []),
            Expectation(orderBefore: [1, 2, 3, 4], orderAfter: [5, 6, 7, 8], insertions: [IP(0, 0), IP(1, 0), IP(2, 0), IP(3, 0)], deletions: [IP(0, 0), IP(1, 0), IP(2, 0), IP(3, 0)], moves: []),
            Expectation(orderBefore: [1, 2, 3, 4], orderAfter: [5, 6, 7, 1], insertions: [IP(1, 0), IP(2, 0), IP(3, 0)], deletions: [IP(0, 0), IP(1, 0), IP(2, 0)], moves: [])
        ]

        func testCells() {
            self._testCells()
        }

        func testCellsWithTransform() {
            self._testCellsWithTransform()
        }

        func _testCells() {
            for expectation in self.cellExpectations {
                let batch = BatchUpdate(diff: expectation.orderBefore.extendedDiff(expectation.orderAfter))
                XCTAssertEqual(batch.deletions, expectation.deletions)
                XCTAssertEqual(batch.insertions, expectation.insertions)
                XCTAssertEqual(batch.moves, expectation.moves)
            }
        }

        func _testCellsWithTransform() {
            let transform: (IndexPath) -> IndexPath = { IP($0.row + 1, $0.section + 2) }

            for expectation in self.cellExpectations {
                let batch = BatchUpdate(diff: expectation.orderBefore.extendedDiff(expectation.orderAfter), indexPathTransform: transform)
                XCTAssertEqual(batch.deletions, expectation.deletions.map(transform))
                XCTAssertEqual(batch.insertions, expectation.insertions.map(transform))
                XCTAssertEqual(batch.moves, expectation.moves.map { (transform($0.0), transform($0.1)) })
            }
        }
    }

#endif
