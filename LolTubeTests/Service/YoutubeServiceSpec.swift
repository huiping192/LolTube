//
//  YoutubeServiceSpec.swift
//  LolTube
//
//  Created by 郭 輝平 on 4/9/15.
//  Copyright (c) 2015 Huiping Guo. All rights reserved.
//

import Quick
import Nimble
import OCMock
import OHHTTPStubs
import LolTube

func setMockData(fileName: String) {
    OHHTTPStubs.stubRequestsPassingTest({
        (request: NSURLRequest!) -> Bool in
        return true
    }, withStubResponse: {
        (request: NSURLRequest!) -> OHHTTPStubsResponse! in
        let filePath = NSBundle(forClass: YoutubeServiceSpec().classForCoder).pathForResource(fileName, ofType: "json")
        return OHHTTPStubsResponse(fileAtPath: filePath, statusCode: 200, headers: ["Content-Type": "application/json"])
    })
}


func mockHttpError() {
    OHHTTPStubs.stubRequestsPassingTest({
        (request: NSURLRequest!) -> Bool in
        return true
    }, withStubResponse: {
        (request: NSURLRequest!) -> OHHTTPStubsResponse! in
        return OHHTTPStubsResponse(error: NSError(domain: NSURLErrorDomain, code: -1009, userInfo: nil))
    })
}


class YoutubeServiceSpec: QuickSpec {

    override func spec() {
        var service: YoutubeService!
        beforeEach {
            service = YoutubeService()
        }
        afterEach {
            OHHTTPStubs.removeAllStubs()
        }

        describe("videoList:searchText:nextPageToken:success:failure:") {
            context("when success") {
                var successBlockCalled: Bool!
                var failureBlockCalled: Bool!
                var searchModel: RSSearchModel!

                let successBlock: ((RSSearchModel) -> Void) = {
                    (successSearchModel) in
                    successBlockCalled = true
                    searchModel = successSearchModel
                }
                let failureBlock: ((NSError) -> Void) = {
                    (failureError) in
                    failureBlockCalled = true
                }

                beforeEach {
                    successBlockCalled = false
                    failureBlockCalled = false
                    setMockData("LoLProChannelVideoList")
                    service.videoList("channelId", searchText: "searchText", nextPageToken: "nextPageToken", success: successBlock, failure: failureBlock)
                }
                it("should call success block") {
                    expect(successBlockCalled).toEventually(beTruthy())
                }
                it("should return expect data") {
                    expect(searchModel.nextPageToken).toEventually(equal("CAoQAA"))
                    expect(searchModel.items.count).toEventually(equal(10))
                }
                it("should not call failure block") {
                    expect(failureBlockCalled).toEventually(beFalsy())
                }
            }

            context("when failure") {
                var successBlockCalled: Bool!
                var failureBlockCalled: Bool!
                var error: NSError!

                let successBlock: ((RSSearchModel) -> Void) = {
                    (successSearchModel) in
                    successBlockCalled = true
                }
                let failureBlock: ((NSError) -> Void) = {
                    (failureError) in
                    failureBlockCalled = true
                    error = failureError
                }

                beforeEach {
                    successBlockCalled = false
                    failureBlockCalled = false
                    mockHttpError()
                    service.videoList("channelId", searchText: "searchText", nextPageToken: "nextPageToken", success: successBlock, failure: failureBlock)
                }

                it("should not call success block") {
                    expect(successBlockCalled).toEventually(beFalsy())
                }

                it("should call failure block") {
                    expect(failureBlockCalled).toEventually(beTruthy())
                }

                it("should return expect error") {
                    expect(error.code).toEventually(equal(-1009))
                }
            }
        }

        describe("videoList:searchText:nextPageToken:success:failure:") {
            context("when success") {
                var successBlockCalled: Bool!
                var failureBlockCalled: Bool!
                var searchModelList: [RSSearchModel]!

                let successBlock: (([RSSearchModel]) -> Void) = {
                    (successSearchModelList) in
                    successBlockCalled = true
                    searchModelList = successSearchModelList
                }
                let failureBlock: ((NSError) -> Void) = {
                    (failureError) in
                    failureBlockCalled = true
                }

                beforeEach {
                    successBlockCalled = false
                    failureBlockCalled = false
                    setMockData("LoLProChannelVideoList")
                    service.videoList(["channelId1", "channelId2"], searchText: nil, nextPageTokenList: nil, success: successBlock, failure: failureBlock)
                }
                it("should call success block") {
                    expect(successBlockCalled).toEventually(beTruthy())
                }
                it("should return expect data") {
                    expect(searchModelList.count).toEventually(equal(2))

                    let searchModel = searchModelList[0]
                    expect(searchModel.nextPageToken).toEventually(equal("CAoQAA"))
                    expect(searchModel.items.count).toEventually(equal(10))
                }
                it("should not call failure block") {
                    expect(failureBlockCalled).toEventually(beFalsy())
                }
            }

            context("when failure") {
                var successBlockCalled: Bool!
                var failureBlockCalled: Bool!
                var error: NSError!

                let successBlock: (([RSSearchModel]) -> Void) = {
                    (successSearchModelList) in
                    successBlockCalled = true
                }
                let failureBlock: ((NSError) -> Void) = {
                    (failureError) in
                    failureBlockCalled = true
                    error = failureError
                }

                beforeEach {
                    successBlockCalled = false
                    failureBlockCalled = false
                    mockHttpError()
                    service.videoList(["channelId1", "channelId2"], searchText: nil, nextPageTokenList: nil, success: successBlock, failure: failureBlock)
                }

                it("should not call success block") {
                    expect(successBlockCalled).toEventually(beFalsy())
                }

                it("should call failure block") {
                    expect(failureBlockCalled).toEventually(beTruthy())
                }

                it("should return expect error") {
                    expect(error.code).toEventually(equal(-1009))
                }
            }
        }

//        describe("video:success:failure:") {
//            context("when success") {
//                var successBlockCalled: Bool!
//                var failureBlockCalled: Bool!
//                var videoModel: RSVideoModel!
//
//                let successBlock: ((RSVideoModel) -> Void) = {
//                    (successVideoModel) in
//                    successBlockCalled = true
//                    videoModel = successVideoModel
//                }
//                let failureBlock: ((NSError) -> Void) = {
//                    (failureError) in
//                    failureBlockCalled = true
//                }
//
//                beforeEach {
//                    successBlockCalled = false
//                    failureBlockCalled = false
//                    setMockData("CLG_vs_DIG_Video")
//                    service.video(["videoId"], success: successBlock, failure: failureBlock)
//                }
//                it("should call success block") {
//                    expect(successBlockCalled).toEventually(beTruthy())
//                }
//                it("should return expect data") {
//                    expect(videoModel.items.count).toEventually(equal(1))
//
//                    let video = videoModel.items[0]
//                    expect(video.snippet.publishedAt).toEventually(equal("2014-08-30T00:09:00.000Z"))
//                    expect(video.snippet.channelId).toEventually(equal("UCvqRdlKsE5Q8mf8YXbdIJLw"))
//                    expect(video.snippet.title).toEventually(equal("CLG vs DIG - 2014 NA LCS Playoffs 5th Place G3"))
//                    expect(video.snippet.videoDescription).toEventually(equal("For game stats, go to the CLG vs DIG match page:\nhttp://www.lolesports.com/na-lcs/2014/na-regional-2014/matches/round-3/counter-logic-gaming-vs-team-dignitas\n\nCounter Logic Gaming – CLG | http://bit.ly/lolesportsCLG\nShin \"Seraph\" Woo-Yeong -- Top Lane\nMarcel “dexter” Feldkamp – Jungler\nAustin “Link” Shin – Mid Lane\nYiliang “Doublelift” Peng – AD Carry\nZaqueri “Aphromoo” Black -- Support\n\nTeam Dignitas – DIG | http://bit.ly/lolesportsDIG\nDarshan \"Zion Spartan\" Upadhyaya – Top Lane\nAlberto “Crumbzz” Rengifo -- Jungler\nDanny \"Shiphtur\" Le – Mid Lane\nMichael “Imaqtpie” Santana – AD Carry\nAlan “KiWiKiD” Nguyen – Support\n\nFor more LCS coverage including the latest schedule, results, stats, and analysis, GO TO:\nhttp://lolesports.com\n\nJoin the conversation on Twitter, TWEET #LCS:\nhttp://www.twitter.com/lolesports\n\nLike us on FACEBOOK for important updates and more #LCSBIGPLAYS:\nhttp://www.facebook.com/lolesports\n\nFind us on INSTAGRAM:\nhttp://www.instagram.com/lolesports\n\nCheck out our photos on FLICKR:\nhttp://bit.ly/lolesportsFlickr"))
//
//                    let thumbnails = video.snippet.thumbnails
//                    expect(thumbnails.medium.url).toEventually(equal("https://i.ytimg.com/vi/b-BBlJm8bHI/mqdefault.jpg"))
//                }
//                it("should not call failure block") {
//                    expect(failureBlockCalled).toEventually(beFalsy())
//                }
//            }
//
//            context("when failure") {
//                var successBlockCalled: Bool!
//                var failureBlockCalled: Bool!
//                var error: NSError!
//
//                let successBlock: ((RSVideoModel) -> Void) = {
//                    (successVideoModel) in
//                    successBlockCalled = true
//                }
//                let failureBlock: ((NSError) -> Void) = {
//                    (failureError) in
//                    failureBlockCalled = true
//                    error = failureError
//                }
//
//                beforeEach {
//                    successBlockCalled = false
//                    failureBlockCalled = false
//                    mockHttpError()
//                    service.video(["videoId"], success: successBlock, failure: failureBlock)
//                }
//
//                it("should not call success block") {
//                    expect(successBlockCalled).toEventually(beFalsy())
//                }
//
//                it("should call failure block") {
//                    expect(failureBlockCalled).toEventually(beTruthy())
//                }
//
//                it("should return expect error") {
//                    expect(error.code).toEventually(equal(-1009))
//                }
//            }
//        }

        describe("channel:success:failure:") {
            context("when success") {

                context("and receive only two channles") {
                    var successBlockCalled: Bool!
                    var failureBlockCalled: Bool!
                    var channelModel: RSChannelModel!

                    let successBlock: ((RSChannelModel) -> Void) = {
                        (successChannelModel) in
                        successBlockCalled = true
                        channelModel = successChannelModel
                    }
                    let failureBlock: ((NSError) -> Void) = {
                        (failureError) in
                        failureBlockCalled = true
                    }

                    beforeEach {
                        successBlockCalled = false
                        failureBlockCalled = false
                        setMockData("TwoChannel")
                        service.channel(["channel1", "channel2"], success: successBlock, failure: failureBlock)
                    }
                    it("should call success block") {
                        expect(successBlockCalled).toEventually(beTruthy())
                    }
                    it("should return expect data") {
                        expect(channelModel.items.count).toEventually(equal(2))

                        let channelItem = channelModel.items[0]
                        expect(channelItem.channelId).toEventually(equal("UCGd9kLfXGJS1VG1nBumsUMA"))
                        expect(channelItem.snippet.publishedAt).toEventually(equal("2014-08-11T11:32:40.000Z"))
                        expect(channelItem.snippet.title).toEventually(equal("LoL Pro"))

                        let thumbnails = channelItem.snippet.thumbnails
                        expect(thumbnails.medium.url).toEventually(equal("https://yt3.ggpht.com/-Vue5WIq8Qzs/AAAAAAAAAAI/AAAAAAAAAAA/Kv02yYSSOiY/s240-c-k-no/photo.jpg"))
                    }
                    it("should not call failure block") {
                        expect(failureBlockCalled).toEventually(beFalsy())
                    }
                }

                context("and receive 100 channels") {
                    var successBlockCalled: Bool!
                    var failureBlockCalled: Bool!
                    var channelModel: RSChannelModel!
                    var error: NSError!

                    let successBlock: ((RSChannelModel) -> Void) = {
                        (successChannelModel) in
                        successBlockCalled = true
                        channelModel = successChannelModel
                    }
                    let failureBlock: ((NSError) -> Void) = {
                        (failureError) in
                        failureBlockCalled = true
                        error = failureError
                    }

                    beforeEach {
                        successBlockCalled = false
                        failureBlockCalled = false
                        setMockData("FiftyChannel")

                        var channelIds = [String]()
                        for index in 0 ..< 100 {
                            channelIds.append("channel\(index)")
                        }
                        service.channel(channelIds, success: successBlock, failure: failureBlock)
                    }
                    it("should call success block") {
                        expect(successBlockCalled).toEventually(beTruthy())
                    }
                    it("should return expect data") {
                        expect(channelModel.items.count).toEventually(equal(100))

                        let channelItem = channelModel.items[0]
                        expect(channelItem.channelId).toEventually(equal("UCGd9kLfXGJS1VG1nBumsUMA"))
                        expect(channelItem.snippet.publishedAt).toEventually(equal("2014-08-11T11:32:40.000Z"))
                        expect(channelItem.snippet.title).toEventually(equal("LoL Pro"))

                        let thumbnails = channelItem.snippet.thumbnails
                        expect(thumbnails.medium.url).toEventually(equal("https://yt3.ggpht.com/-Vue5WIq8Qzs/AAAAAAAAAAI/AAAAAAAAAAA/Kv02yYSSOiY/s240-c-k-no/photo.jpg"))
                    }
                    it("should not call failure block") {
                        expect(failureBlockCalled).toEventually(beFalsy())
                    }
                }
            }

            context("when failure") {
                var successBlockCalled: Bool!
                var failureBlockCalled: Bool!
                var channelModel: RSChannelModel!
                var error: NSError!

                let successBlock: ((RSChannelModel) -> Void) = {
                    (successChannelModel) in
                    successBlockCalled = true
                    channelModel = successChannelModel
                }
                let failureBlock: ((NSError) -> Void) = {
                    (failureError) in
                    failureBlockCalled = true
                    error = failureError
                }

                beforeEach {
                    successBlockCalled = false
                    failureBlockCalled = false
                    mockHttpError()
                    service.channel(["channel1", "channel2"], success: successBlock, failure: failureBlock)
                }

                it("should not call success block") {
                    expect(successBlockCalled).toEventually(beFalsy())
                }

                it("should call failure block") {
                    expect(failureBlockCalled).toEventually(beTruthy())
                }

                it("should return expect error") {
                    expect(error.code).toEventually(equal(-1009))
                }
            }
        }

        describe("channelList:nextPageToken:success:failure:") {
            context("when success") {
                var successBlockCalled: Bool!
                var failureBlockCalled: Bool!
                var searchModel: RSSearchModel!
                var error: NSError!

                let successBlock: ((RSSearchModel) -> Void) = {
                    (successSearchModel) in
                    successBlockCalled = true
                    searchModel = successSearchModel
                }
                let failureBlock: ((NSError) -> Void) = {
                    (failureError) in
                    failureBlockCalled = true
                    error = failureError
                }

                beforeEach {
                    successBlockCalled = false
                    failureBlockCalled = false
                    setMockData("LolChannelSearchChannelList")
                    service.channelList("lol", nextPageToken: "nextPageToken", success: successBlock, failure: failureBlock)
                }
                it("should call success block") {
                    expect(successBlockCalled).toEventually(beTruthy())
                }
                it("should return expect data") {
                    expect(searchModel.nextPageToken).toEventually(equal("CAoQAA"))
                    expect(searchModel.items.count).toEventually(equal(10))
                }
                it("should not call failure block") {
                    expect(failureBlockCalled).toEventually(beFalsy())
                }
            }

            context("when failure") {
                var successBlockCalled: Bool!
                var failureBlockCalled: Bool!
                var searchModel: RSSearchModel!
                var error: NSError!

                let successBlock: ((RSSearchModel) -> Void) = {
                    (successSearchModel) in
                    successBlockCalled = true
                    searchModel = successSearchModel
                }
                let failureBlock: ((NSError) -> Void) = {
                    (failureError) in
                    failureBlockCalled = true
                    error = failureError
                }

                beforeEach {
                    successBlockCalled = false
                    failureBlockCalled = false
                    mockHttpError()
                    service.channelList("lol", nextPageToken: "nextPageToken", success: successBlock, failure: failureBlock)
                }

                it("should not call success block") {
                    expect(successBlockCalled).toEventually(beFalsy())
                }

                it("should call failure block") {
                    expect(failureBlockCalled).toEventually(beTruthy())
                }

                it("should return expect error") {
                    expect(error.code).toEventually(equal(-1009))
                }
            }
        }

        describe("todayVideoList:success:failure:") {
            context("when success") {
                var successBlockCalled: Bool!
                var failureBlockCalled: Bool!
                var searchModelList: [RSSearchModel]!
                var error: NSError!

                let successBlock: (([RSSearchModel]) -> Void) = {
                    (successSearchModelList) in
                    successBlockCalled = true
                    searchModelList = successSearchModelList
                }
                let failureBlock: ((NSError) -> Void) = {
                    (failureError) in
                    failureBlockCalled = true
                    error = failureError
                }

                beforeEach {
                    successBlockCalled = false
                    failureBlockCalled = false
                    setMockData("LoLProChannelVideoList")
                    service.todayVideoList(["channelId1", "channelId2"], success: successBlock, failure: failureBlock)
                }
                it("should call success block") {
                    expect(successBlockCalled).toEventually(beTruthy())
                }
                it("should return expect data") {
                    expect(searchModelList.count).toEventually(equal(2))

                    let searchModel = searchModelList[0]
                    expect(searchModel.nextPageToken).toEventually(equal("CAoQAA"))
                    expect(searchModel.items.count).toEventually(equal(10))
                }
                it("should not call failure block") {
                    expect(failureBlockCalled).toEventually(beFalsy())
                }
            }

            context("when failure") {
                var successBlockCalled: Bool!
                var failureBlockCalled: Bool!
                var searchModelList: [RSSearchModel]!
                var error: NSError!

                let successBlock: (([RSSearchModel]) -> Void) = {
                    (successSearchModelList) in
                    successBlockCalled = true
                    searchModelList = successSearchModelList
                }
                let failureBlock: ((NSError) -> Void) = {
                    (failureError) in
                    failureBlockCalled = true
                    error = failureError
                }

                beforeEach {
                    successBlockCalled = false
                    failureBlockCalled = false
                    mockHttpError()
                    service.todayVideoList(["channelId1", "channelId2"], success: successBlock, failure: failureBlock)
                }

                it("should not call success block") {
                    expect(successBlockCalled).toEventually(beFalsy())
                }

                it("should call failure block") {
                    expect(failureBlockCalled).toEventually(beTruthy())
                }

                it("should return expect error") {
                    expect(error.code).toEventually(equal(-1009))
                }
            }
        }

        describe("relatedVideoList:success:failure:") {
            context("when success") {
                var successBlockCalled: Bool!
                var failureBlockCalled: Bool!
                var searchModel: RSSearchModel!
                var error: NSError!

                let successBlock: ((RSSearchModel) -> Void) = {
                    (successSearchModel) in
                    successBlockCalled = true
                    searchModel = successSearchModel
                }
                let failureBlock: ((NSError) -> Void) = {
                    (failureError) in
                    failureBlockCalled = true
                    error = failureError
                }

                beforeEach {
                    successBlockCalled = false
                    failureBlockCalled = false
                    setMockData("LoLProChannelVideoList")
                    service.relatedVideoList("videoId", success: successBlock, failure: failureBlock)
                }
                it("should call success block") {
                    expect(successBlockCalled).toEventually(beTruthy())
                }
                it("should return expect data") {
                    expect(searchModel.nextPageToken).toEventually(equal("CAoQAA"))
                    expect(searchModel.items.count).toEventually(equal(10))
                }
                it("should not call failure block") {
                    expect(failureBlockCalled).toEventually(beFalsy())
                }
            }

            context("when failure") {
                var successBlockCalled: Bool!
                var failureBlockCalled: Bool!
                var searchModel: RSSearchModel!
                var error: NSError!

                let successBlock: ((RSSearchModel) -> Void) = {
                    (successSearchModel) in
                    successBlockCalled = true
                    searchModel = successSearchModel
                }
                let failureBlock: ((NSError) -> Void) = {
                    (failureError) in
                    failureBlockCalled = true
                    error = failureError
                }

                beforeEach {
                    successBlockCalled = false
                    failureBlockCalled = false
                    mockHttpError()
                    service.relatedVideoList("videoId", success: successBlock, failure: failureBlock)
                }

                it("should not call success block") {
                    expect(successBlockCalled).toEventually(beFalsy())
                }

                it("should call failure block") {
                    expect(failureBlockCalled).toEventually(beTruthy())
                }

                it("should return expect error") {
                    expect(error.code).toEventually(equal(-1009))
                }
            }
        }

        describe("videoDetailList:success:failure:") {
            context("when success") {

                context("and receive only two channles") {
                    var successBlockCalled: Bool!
                    var failureBlockCalled: Bool!
                    var videoDetailModel: RSVideoDetailModel!

                    let successBlock: ((RSVideoDetailModel) -> Void) = {
                        (successVideoDetailModel) in
                        successBlockCalled = true
                        videoDetailModel = successVideoDetailModel
                    }
                    let failureBlock: ((NSError) -> Void) = {
                        (failureError) in
                        failureBlockCalled = true
                    }

                    beforeEach {
                        successBlockCalled = false
                        failureBlockCalled = false
                        setMockData("TwoVideosDetail")
                        service.videoDetailList(["videoId1", "videoId2"], success: successBlock, failure: failureBlock)
                    }
                    it("should call success block") {
                        expect(successBlockCalled).toEventually(beTruthy())
                    }
                    it("should return expect data") {
                        expect(videoDetailModel.items.count).toEventually(equal(2))
                    }
                    it("should not call failure block") {
                        expect(failureBlockCalled).toEventually(beFalsy())
                    }
                }

                context("and receive 100 channles") {
                    var successBlockCalled: Bool!
                    var failureBlockCalled: Bool!
                    var videoDetailModel: RSVideoDetailModel!

                    let successBlock: ((RSVideoDetailModel) -> Void) = {
                        (successVideoDetailModel) in
                        successBlockCalled = true
                        videoDetailModel = successVideoDetailModel
                    }
                    let failureBlock: ((NSError) -> Void) = {
                        (failureError) in
                        failureBlockCalled = true
                    }

                    beforeEach {
                        successBlockCalled = false
                        failureBlockCalled = false
                        setMockData("FiftyVideosDetail")

                        var videoIds = [String]()
                        for index in 0 ..< 100 {
                            videoIds.append("video\(index)")
                        }
                        service.videoDetailList(videoIds, success: successBlock, failure: failureBlock)
                    }
                    it("should call success block") {
                        expect(successBlockCalled).toEventually(beTruthy())
                    }
                    it("should return expect data") {
                        expect(videoDetailModel.items.count).toEventually(equal(100))
                    }
                    it("should not call failure block") {
                        expect(failureBlockCalled).toEventually(beFalsy())
                    }
                }
            }

            context("when failure") {
                var successBlockCalled: Bool!
                var failureBlockCalled: Bool!
                var error: NSError!

                let successBlock: ((RSVideoDetailModel) -> Void) = {
                    (successVideoDetailModel) in
                    successBlockCalled = true
                }
                let failureBlock: ((NSError) -> Void) = {
                    (failureError) in
                    failureBlockCalled = true
                    error = failureError
                }

                beforeEach {
                    successBlockCalled = false
                    failureBlockCalled = false
                    mockHttpError()
                    service.videoDetailList(["videoId1", "videoId2"], success: successBlock, failure: failureBlock)
                }

                it("should not call success block") {
                    expect(successBlockCalled).toEventually(beFalsy())
                }

                it("should call failure block") {
                    expect(failureBlockCalled).toEventually(beTruthy())
                }

                it("should return expect error") {
                    expect(error.code).toEventually(equal(-1009))
                }
            }
        }
    }
}
