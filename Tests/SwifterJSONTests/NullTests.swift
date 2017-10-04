//
//  NullTests.swift
//  VJson
//
//  Created by Marinus van der Lugt on 03/10/17.
//
//

import XCTest
import VJson


class NullTests: XCTestCase {

    override func setUp() {
        super.setUp()
        VJson.undoManager = UndoManager()
    }
    
    override func tearDown() {
        VJson.undoManager = nil
        super.tearDown()
    }

    
    // Testing: nullValue
    
    func testNullValue() {
        
        // Creation without name
        var json = VJson.null()
        XCTAssertTrue(json.isNull)
        XCTAssertTrue(json.nullValue!)
        
        
        // Creation with name
        json = VJson.null("aName")
        XCTAssertTrue(json.isNull)
        XCTAssertTrue(json.nullValue!)
        
        
        // Convert from Number
        json = VJson(1)
        XCTAssertFalse(json.isNull)
        XCTAssertNil(json.nullValue)
        VJson.undoManager?.removeAllActions()
        json.nullValue = true
        XCTAssertTrue(json.isNull)
        XCTAssertTrue(json.nullValue!)
        VJson.undoManager?.undo()
        XCTAssertFalse(json.isNull)
        XCTAssertNil(json.nullValue)
        
        
        // Convert from String
        json = VJson("qwerty")
        XCTAssertFalse(json.isNull)
        XCTAssertNil(json.nullValue)
        VJson.undoManager?.removeAllActions()
        json.nullValue = false
        XCTAssertTrue(json.isNull)
        XCTAssertTrue(json.nullValue!)
        VJson.undoManager?.undo()
        XCTAssertFalse(json.isNull)
        XCTAssertNil(json.nullValue)

        
        // Convert from Object
        json = VJson.object("qwerty")
        XCTAssertFalse(json.isNull)
        XCTAssertNil(json.nullValue)
        VJson.undoManager?.removeAllActions()
        json.nullValue = false
        XCTAssertTrue(json.isNull)
        XCTAssertTrue(json.nullValue!)
        VJson.undoManager?.undo()
        XCTAssertFalse(json.isNull)
        XCTAssertNil(json.nullValue)
        
        // Convert from Array
        json = VJson.array("qwerty")
        XCTAssertFalse(json.isNull)
        XCTAssertNil(json.nullValue)
        VJson.undoManager?.removeAllActions()
        json.nullValue = false
        XCTAssertTrue(json.isNull)
        XCTAssertTrue(json.nullValue!)
        VJson.undoManager?.undo()
        XCTAssertFalse(json.isNull)
        XCTAssertNil(json.nullValue)
    }
    
    
    // Testing: public var isNull: Bool {...}
    
    func testIsNull() {
        
        let n = VJson.null()
        XCTAssertTrue(n.isNull)
        
        let b = VJson(true)
        XCTAssertFalse(b.isNull)
        
        let i = VJson(0)
        XCTAssertFalse(i.isNull)
        
        let s = VJson("think")
        XCTAssertFalse(s.isNull)
        
        let o = VJson.object()
        XCTAssertFalse(o.isNull)
        
        let a = VJson.array()
        XCTAssertFalse(a.isNull)
    }
}