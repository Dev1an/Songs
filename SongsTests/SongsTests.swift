//
//  SongsTests.swift
//  SongsTests
//
//  Created by Damiaan on 09/03/2021.
//

@testable import Songs
import XCTest

class SongsTests: XCTestCase {

    override func setUpWithError() throws {
        // Put setup code here. This method is called before the invocation of each test method in the class.
    }

    override func tearDownWithError() throws {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
    }

    func testLanguageLookup() throws {
		XCTAssertEqual(Set(sampleData.translations(for: 2)), Set([0,2,3]))
		XCTAssertEqual(Set(sampleData.translations(for: 3)), Set([0,2,3]))
    }

	func testSearchSong() {
		XCTAssertEqual(sampleData.searchSong("Wij begroeten"), [0])
		XCTAssertEqual(sampleData.searchSong("Queen"), [2])

		print(sampleData.groupedThemes(in: .dutch).map{ $0.map(\.title).joined(separator: ", ") }.joined(separator: "\n"))
	}

	func testSearchByTheme() {
		XCTAssertEqual(Set(sampleData.songs(in: 0).map(\.id)), ([0,4]))
	}

    func testPerformanceExample() throws {
        // This is an example of a performance test case.
        measure {
            // Put the code you want to measure the time of here.
        }
    }

}
