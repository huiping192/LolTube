//
//  NSDateTests.swift
//  LolTube
//
//  Created by 郭 輝平 on 11/8/14.
//  Copyright (c) 2014 Huiping Guo. All rights reserved.
//

import UIKit
import XCTest

class NSDateTests: XCTestCase {
    
    func testDateFromISO8601StringWhenStringIsNil() {
        let date = NSDate(fromISO8601String: nil);
        XCTAssertNil(date, "date must be nil")
    }
    
    func testDateFromISO8601StringWhenStringIsEmpty() {
        let date = NSDate(fromISO8601String: "");
        XCTAssertNil(date, "date must be nil")
    }
    
    func testDateFromISO8601StringWhenStringIsISO8601Formatter() {
        let date = NSDate(fromISO8601String: "2010-08-31T23:04:26.000Z");
        XCTAssertNotNil(date, "date must not be nil")
    }
    
    func testDateFromISO8601StringWhenStringIsNotISO8601Formatter() {
        let date = NSDate(fromISO8601String: "2010-08-31");
        XCTAssertNil(date, "date must not be nil")
    }
}
