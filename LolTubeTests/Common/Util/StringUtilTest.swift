//
//  StringUtilTest.swift
//  LolTube
//
//  Created by 郭 輝平 on 11/8/14.
//  Copyright (c) 2014 Huiping Guo. All rights reserved.
//

import UIKit
import XCTest

class StringUtilTest: XCTestCase {

    func testIsEmptyStringWhenStringIsNil() {
        let isEmpty = RSStringUtil.isEmptyString(nil)
        XCTAssertTrue(isEmpty, "empty must be true")
    }
    
    func testIsEmptyStringWhenStringIsEmpty() {
        let isEmpty = RSStringUtil.isEmptyString("")
        XCTAssertTrue(isEmpty, "empty must be true")
    }
    
    func testIsEmptyStringWhenStringIsNotEmpty() {
        let isEmpty = RSStringUtil.isEmptyString("no empty")
        XCTAssertFalse(isEmpty, "empty must be false")
    }
}
