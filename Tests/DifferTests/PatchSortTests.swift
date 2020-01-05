import XCTest
@testable import Differ

class PatchTests: XCTestCase {

    func testDefaultOrder() {

        let defaultOrder = [
            ("kitten", "sitting", "D(0)I(0,s)D(4)I(4,i)I(6,g)"),
            ("🐩itt🍨ng", "kitten", "D(0)I(0,k)D(4)I(4,e)D(6)"),
            ("1234", "ABCD", "D(0)D(0)D(0)D(0)I(0,A)I(1,B)I(2,C)I(3,D)"),
            ("1234", "", "D(0)D(0)D(0)D(0)"),
            ("", "1234", "I(0,1)I(1,2)I(2,3)I(3,4)"),
            ("Hi", "Oh Hi", "I(0,O)I(1,h)I(2, )"),
            ("Hi", "Hi O", "I(2, )I(3,O)"),
            ("Hi O", "Hi", "D(2)D(2)"),
            ("Wojtek", "Wojciech", "D(3)I(3,c)I(4,i)D(6)I(6,c)I(7,h)"),
            ("1234", "1234", ""),
            ("", "", ""),
            ("Oh Hi", "Hi Oh", "D(0)D(0)D(0)I(2, )I(3,O)I(4,h)"),
            ("1362", "31526", "D(0)D(1)I(1,1)I(2,5)I(4,6)"),
            ("1234b2", "ab", "D(0)D(0)D(0)D(0)I(0,a)D(2)")
        ]

        for expectation in defaultOrder {
            XCTAssertEqual(
                _test(from: expectation.0, to: expectation.1),
                expectation.2)
        }
    }

    func testInsertionsFirst() {

        let insertionsFirst = [
            ("kitten", "sitting", "I(1,s)I(6,i)I(8,g)D(0)D(4)"),
            ("🐩itt🍨ng", "kitten", "I(1,k)I(6,e)D(0)D(4)D(6)"),
            ("1234", "ABCD", "I(4,A)I(5,B)I(6,C)I(7,D)D(0)D(0)D(0)D(0)"),
            ("1234", "", "D(0)D(0)D(0)D(0)"),
            ("", "1234", "I(0,1)I(1,2)I(2,3)I(3,4)"),
            ("Hi", "Oh Hi", "I(0,O)I(1,h)I(2, )"),
            ("Hi", "Hi O", "I(2, )I(3,O)"),
            ("Hi O", "Hi", "D(2)D(2)"),
            ("Wojtek", "Wojciech", "I(4,c)I(5,i)I(8,c)I(9,h)D(3)D(6)"),
            ("1234", "1234", ""),
            ("", "", ""),
            ("Oh Hi", "Hi Oh", "I(5, )I(6,O)I(7,h)D(0)D(0)D(0)"),
            ("1362", "31526", "I(3,1)I(4,5)I(6,6)D(0)D(1)")
        ]

        let insertionsFirstSort = { (element1: Diff.Element, element2: Diff.Element) -> Bool in
            switch (element1, element2) {
            case let (.insert(at1), .insert(at2)):
                return at1 < at2
            case (.insert(_), .delete(_)):
                return true
            case (.delete(_), .insert(_)):
                return false
            case let (.delete(at1), .delete(at2)):
                return at1 < at2
            }
        }

        for expectation in insertionsFirst {
            XCTAssertEqual(
                _test(
                    from: expectation.0,
                    to: expectation.1,
                    sortingFunction: insertionsFirstSort),
                expectation.2)
        }
    }

    func testDeletionsFirst() {

        let deletionsFirst = [
            ("kitten", "sitting", "D(0)D(3)I(0,s)I(4,i)I(6,g)"),
            ("🐩itt🍨ng", "kitten", "D(0)D(3)D(4)I(0,k)I(4,e)"),
            ("1234", "ABCD", "D(0)D(0)D(0)D(0)I(0,A)I(1,B)I(2,C)I(3,D)"),
            ("1234", "", "D(0)D(0)D(0)D(0)"),
            ("", "1234", "I(0,1)I(1,2)I(2,3)I(3,4)"),
            ("Hi", "Oh Hi", "I(0,O)I(1,h)I(2, )"),
            ("Hi", "Hi O", "I(2, )I(3,O)"),
            ("Hi O", "Hi", "D(2)D(2)"),
            ("Wojtek", "Wojciech", "D(3)D(4)I(3,c)I(4,i)I(6,c)I(7,h)"),
            ("1234", "1234", ""),
            ("", "", ""),
            ("Oh Hi", "Hi Oh", "D(0)D(0)D(0)I(2, )I(3,O)I(4,h)"),
            ("1362", "31526", "D(0)D(1)I(1,1)I(2,5)I(4,6)")
        ]

        let deletionsFirstSort = { (element1: Diff.Element, element2: Diff.Element) -> Bool in
            switch (element1, element2) {
            case let (.insert(at1), .insert(at2)):
                return at1 < at2
            case (.insert(_), .delete(_)):
                return false
            case (.delete(_), .insert(_)):
                return true
            case let (.delete(at1), .delete(at2)):
                return at1 < at2
            }
        }

        for expectation in deletionsFirst {
            XCTAssertEqual(
                _test(
                    from: expectation.0,
                    to: expectation.1,
                    sortingFunction: deletionsFirstSort),
                expectation.2)
        }
    }

    func testRandomStringPermutationRandomPatchSort() {

        let sort = { (_: Diff.Element, _: Diff.Element) -> Bool in
            arc4random_uniform(2) == 0
        }
        for _ in 0 ..< 200 {
            let randomString = randomAlphaNumericString(length: 30)
            let permutation = randomAlphaNumericString(length: 30)
            let patch = randomString.diff(permutation).patch(from: randomString, to: permutation, sort: sort)
            let result = randomString.apply(patch)
            XCTAssertEqual(result, permutation)
        }
    }

    // See https://github.com/tonyarnold/Differ/issues/63
    func testLargeCollectionOnBackgroundThread() {
        let FIRST_STRING = """
Lorem ipsum dolor sit amet, consectetur adipiscing elit, sed do eiusmod tempor incididunt ut labore et dolore magna aliqua. Vel turpis nunc eget lorem dolor sed viverra ipsum. Pharetra pharetra massa massa ultricies mi quis hendrerit. Sit amet porttitor eget dolor morbi non arcu risus quis. Cursus risus at ultrices mi tempus imperdiet nulla malesuada. Odio ut enim blandit volutpat maecenas volutpat blandit aliquam. Eu ultrices vitae auctor eu augue ut. Urna condimentum mattis pellentesque id nibh. Vestibulum lorem sed risus ultricies tristique. Tempor orci eu lobortis elementum. Purus faucibus ornare suspendisse sed nisi lacus. Fames ac turpis egestas maecenas pharetra convallis posuere morbi leo.
Neque volutpat ac tincidunt vitae semper quis lectus nulla. Eu turpis egestas pretium aenean pharetra magna ac placerat. Vestibulum morbi blandit cursus risus at ultrices mi tempus imperdiet. Mauris a diam maecenas sed enim ut sem. Pellentesque massa placerat duis ultricies lacus. Nullam non nisi est sit amet facilisis magna etiam. Eget mauris pharetra et ultrices neque ornare aenean euismod elementum. Ipsum dolor sit amet consectetur adipiscing elit duis tristique. Tellus rutrum tellus pellentesque eu tincidunt tortor. Id volutpat lacus laoreet non curabitur gravida arcu. Tellus at urna condimentum mattis pellentesque id nibh tortor id. Viverra maecenas accumsan lacus vel facilisis volutpat est velit. Ut ornare lectus sit amet est placerat in egestas. Vestibulum sed arcu non odio euismod lacinia. Pellentesque habitant morbi tristique senectus et netus et malesuada fames. Felis donec et odio pellentesque diam volutpat commodo sed.
Diam ut venenatis tellus in metus. Ultrices tincidunt arcu non sodales. Id velit ut tortor pretium viverra suspendisse potenti. Amet commodo nulla facilisi nullam vehicula. Blandit massa enim nec dui nunc mattis enim ut. Massa tempor nec feugiat nisl. Sed odio morbi quis commodo odio aenean. Dui ut ornare lectus sit amet est placerat in egestas. Varius vel pharetra vel turpis nunc eget lorem dolor sed. In cursus turpis massa tincidunt dui ut ornare lectus sit.
"""
        let SECOND_STRING = """
Proin sagittis nisl rhoncus mattis rhoncus urna neque viverra. Auctor eu augue ut lectus arcu. Condimentum lacinia quis vel eros donec. Aliquam purus sit amet luctus venenatis lectus magna fringilla urna. Tellus mauris a diam maecenas sed enim ut sem. Pharetra et ultrices neque ornare aenean. Pulvinar pellentesque habitant morbi tristique senectus et netus et malesuada. Nunc faucibus a pellentesque sit amet porttitor eget. Neque convallis a cras semper auctor. Faucibus vitae aliquet nec ullamcorper. Lectus mauris ultrices eros in cursus turpis. Elit sed vulputate mi sit amet. Dolor morbi non arcu risus quis varius quam quisque. Et malesuada fames ac turpis. Libero id faucibus nisl tincidunt eget nullam non nisi est. Eget dolor morbi non arcu risus quis. Id porta nibh venenatis cras sed felis. Quis imperdiet massa tincidunt nunc pulvinar. Tincidunt dui ut ornare lectus sit amet est placerat. Ultrices tincidunt arcu non sodales neque sodales ut.
Erat nam at lectus urna. Tellus at urna condimentum mattis. Aliquam vestibulum morbi blandit cursus risus at ultrices. Tristique senectus et netus et malesuada fames ac turpis. Arcu odio ut sem nulla pharetra diam sit amet nisl. Lorem sed risus ultricies tristique nulla aliquet. Ac turpis egestas maecenas pharetra convallis posuere morbi. Dolor sed viverra ipsum nunc. Nunc mattis enim ut tellus elementum sagittis vitae. Congue mauris rhoncus aenean vel elit scelerisque mauris. Dapibus ultrices in iaculis nunc sed augue lacus viverra vitae. Amet luctus venenatis lectus magna fringilla urna porttitor rhoncus. Suspendisse sed nisi lacus sed.
Non quam lacus suspendisse faucibus. Urna porttitor rhoncus dolor purus non enim praesent. Ultrices sagittis orci a scelerisque purus semper. Ultricies lacus sed turpis tincidunt. Pharetra vel turpis nunc eget lorem dolor sed viverra. Tortor pretium viverra suspendisse potenti nullam ac tortor vitae purus. Sit amet massa vitae tortor. Laoreet non curabitur gravida arcu ac tortor dignissim convallis aenean. Eu tincidunt tortor aliquam nulla facilisi cras fermentum. Cras ornare arcu dui vivamus arcu felis bibendum ut. Convallis tellus id interdum velit laoreet id. Ac turpis egestas sed tempus urna et. Facilisis sed odio morbi quis commodo odio aenean. Felis eget nunc lobortis mattis. Neque gravida in fermentum et sollicitudin ac orci. Id diam maecenas ultricies mi eget. Sit amet aliquam id diam maecenas. Blandit libero volutpat sed cras ornare arcu dui vivamus arcu. Mauris ultrices eros in cursus turpis massa tincidunt dui.
"""
        let source = Array(FIRST_STRING).map(String.init)
        let target = Array(SECOND_STRING).map(String.init)
        let predicate: (Diff.Element, Diff.Element) -> Bool = { _, _ in false }

        let expectation = self.expectation(description: "Patch")

        DispatchQueue.global().async(execute: {
            let patch = Differ.patch(from: source, to: target, sort: predicate)
            XCTAssertEqual(source.apply(patch), target)
            expectation.fulfill()
        })

        waitForExpectations(timeout: 30, handler: nil)
    }
}

func randomAlphaNumericString(length: Int) -> String {

    let allowedChars = "abcdefghijklmnopqrstu"
    let allowedCharsCount = UInt32(allowedChars.count)
    var randomString = ""

    for _ in 0 ..< length {
        let randomNum = Int(arc4random_uniform(allowedCharsCount))
        let randomIndex = allowedChars.index(allowedChars.startIndex, offsetBy: randomNum)
        let newCharacter = allowedChars[randomIndex]
        randomString += String(newCharacter)
    }

    return randomString
}

typealias SortingFunction = (Diff.Element, Diff.Element) -> Bool

func _test(
    from: String,
    to: String,
    sortingFunction: SortingFunction? = nil) -> String {
    if let sort = sortingFunction {
        return patch(
            from: from,
            to: to,
            sort: sort)
            .reduce("") { $0 + $1.debugDescription }
    }
    return patch(
        from: from,
        to: to)
        .reduce("") { $0 + $1.debugDescription }
}
