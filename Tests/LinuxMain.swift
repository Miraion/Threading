import XCTest

import ThreadingTests

var tests = [XCTestCaseEntry]()
tests += ThreadingTests.allTests()
XCTMain(tests)