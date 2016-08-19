//
//  QueryItemWranglerTests.swift
//  QueryItemWranglerTests
//
//  Created by Johan Sørensen on 28/06/16.
//  Copyright © 2016 Johan Sørensen. All rights reserved.
//

import XCTest
@testable import QueryItemWrangler

class QueryItemWranglerTests: XCTestCase {
    let url = NSURL(string: "https://example.com?str=foo%20bar&num=42&flag=1&flag2=true")!
    var components: NSURLComponents!

    override func setUp() {
        super.setUp()
        components = NSURLComponents(URL: url, resolvingAgainstBaseURL: true)!
    }
    
    func testStringValues() {
        var wrangler = QueryItemWrangler(items: components.queryItems)
        XCTAssertEqual(wrangler["str"], Optional("foo bar"))
        wrangler["str"] = "foo"
        XCTAssertEqual(wrangler["str"], Optional("foo"))

        XCTAssertEqual(wrangler[QueryItemKey<String>("str")], Optional("foo"))
        wrangler[QueryItemKey<String>("str")] = "baz"
        XCTAssertEqual(wrangler[QueryItemKey<String>("str")], Optional("baz"))
        XCTAssertEqual(wrangler[QueryItemKey<String>("nonexistant")], nil)
    }

    func testIntValues() {
        var wrangler = QueryItemWrangler(items: components.queryItems)
        XCTAssertEqual(wrangler[QueryItemKey<Int>("num")], Optional(42))
        wrangler[QueryItemKey<Int>("num")] = 84
        XCTAssertEqual(wrangler[QueryItemKey<Int>("num")], Optional(84))
        XCTAssertEqual(wrangler[QueryItemKey<Int>("nonexistant")], nil)
    }

    func testBoolValues() {
        var wrangler = QueryItemWrangler(items: components.queryItems)
        XCTAssertTrue(wrangler[QueryItemKey<Bool>("flag")])
        wrangler[QueryItemKey<Bool>("flag")] = false
        XCTAssertFalse(wrangler[QueryItemKey<Bool>("flag")])
        XCTAssertTrue(wrangler[QueryItemKey<Bool>("flag2")])

        XCTAssertFalse(wrangler[QueryItemKey<Bool>("nonexistant")])
    }

    func testEquality() {
        let wrangler = QueryItemWrangler(items: components.queryItems)
        let other = QueryItemWrangler(items: components.queryItems)
        XCTAssertTrue(wrangler == other)
    }
}
