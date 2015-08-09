//
//  NSDate+FormatterSpec.swift
//  LolTube
//
//  Created by 郭 輝平 on 11/8/14.
//  Copyright (c) 2014 Huiping Guo. All rights reserved.
//

import Quick
import Nimble
import LolTube

class NSDateSpec: QuickSpec {
    override func spec() {

        describe("date:iso8601String") {
            context("when string is iSO8601 formatter") {
                it("return expect date") {
                    let date = NSDate.date(iso8601String: "2010-08-31T23:04:26.000Z")
                    expect(date).notTo(beNil())
                }
            }
            context("when string is not iSO8601 formatter"){
                it("return nil") {
                    let date = NSDate.date(iso8601String: "2010-08-31")
                    expect(date).to(beNil());
                }
            }
        }

        describe("date:iSO8601TimeString") {
            context("when string is iSO8601 formatter") {
                it("return expect date") {
                    let date = NSDate.date(iso8601String: "2010-08-31T23:04:26.000Z")
                    expect(date).notTo(beNil())
                }
            }
            context("when string is not iSO8601 formatter"){
                it("return nil") {
                    let date = NSDate.date(iso8601String: "2010-08-31")
                    expect(date).to(beNil());
                }
            }
        }
    }
}
