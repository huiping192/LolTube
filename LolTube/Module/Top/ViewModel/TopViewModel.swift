//
// Created by 郭 輝平 on 3/11/15.
// Copyright (c) 2015 Huiping Guo. All rights reserved.
//

import Foundation

class TopViewModel {

    private let youtubeService = YoutubeService()
    private let channelService = RSChannelService()

    var topVideoList: [Video]?

    var channelList: [Channel]?
    var videoDictionary: [Channel:[Video]]?

    init() {

    }

    func update(success: () -> Void, failure: (NSError) -> Void) {
        let defaultChannelIdList = channelService.channelIds()

        youtubeService.channel(defaultChannelIdList as! [String], success: {
            [unowned self](channelModel: RSChannelModel) in

            var channelList = [Channel]()
            var channelIdList = [String]()

            for item: RSChannelItem in channelModel.items as! [RSChannelItem] {
                channelList.append(self.convertChannel(item))
                channelIdList.append(item.channelId)
            }

            self.loadVideos(channelList, success: {
                success()
            }, failure: failure)

        }, failure: {
            (error: NSError!) in
            failure(error)
        })
    }

    private func loadVideos(channelList: [Channel], success: () -> Void, failure: (NSError) -> Void) {
        let channelIdList = channelList.map {
            (channel: Channel) -> String in
            return channel.channelId
        }

        self.youtubeService.videoList(channelIdList, searchText: nil, nextPageTokenList: nil, success: {
            [unowned self](searchModelList: [RSSearchModel]) in

            var videoDictionary = [Channel: [Video]]()
            var allVideoList = [Video]()

            for (index, searchModel) in enumerate(searchModelList) {
                var videoList = [Video]()

                for item in searchModel.items as! [RSItem] {
                    let video = self.convertVideo(item)
                    videoList.append(video)
                    allVideoList.append(video)
                }

                videoDictionary[channelList[index]] = videoList;
            }

            self.updateVideoDetail(allVideoList, success: {
                self.topVideoList = self.todayFourHighRankVideoList(allVideoList)
                self.channelList = self.sortChannelList(channelList, videoDictionary: videoDictionary)
                self.videoDictionary = videoDictionary
                success()
            }, failure: {
                (error: NSError!) in
                failure(error)
            })

        }, failure: {
            (error: NSError!) in
            failure(error)
        })
    }

    private func updateVideoDetail(videoList: [Video], success: () -> Void, failure: (NSError) -> Void) {
        var videoIdList = videoList.map {
            (video: Video) -> String in
            return video.videoId
        }

        youtubeService.videoDetailList(videoIdList, success: {
            (videoDetailModel: RSVideoDetailModel!) in

            for (index, detailItem) in enumerate(videoDetailModel.items as! [RSVideoDetailItem]) {
                var video = videoList[index]
                video.duration = RSVideoInfoUtil.convertVideoDuration(detailItem.contentDetails.duration)
                video.viewCountString = RSVideoInfoUtil.convertVideoViewCount(detailItem.statistics.viewCount.toInt() ?? 0)
                video.viewCount = detailItem.statistics.viewCount.toInt() ?? 0
            }

            success()
        }, failure: {
            (error: NSError!) in
            failure(error)
        })
    }

    private func convertChannel(item: RSChannelItem) -> Channel {
        var channel = Channel()
        channel.channelId = item.channelId
        channel.title = item.snippet.title
        channel.thumbnailUrl = item.snippet.thumbnails.medium.url

        return channel
    }

    private func convertVideo(item: RSItem) -> Video {
        var video = Video()
        video.videoId = item.id.videoId
        video.channelId = item.snippet.channelId
        video.channelTitle = item.snippet.channelTitle
        video.title = item.snippet.title
        video.thumbnailUrl = item.snippet.thumbnails.medium.url
        video.highThumbnailUrl = "http://i.ytimg.com/vi/\(video.videoId)/maxresdefault.jpg"
        video.publishedAt = item.snippet.publishedAt
        return video
    }

    private func todayFourHighRankVideoList(videoList: [Video]) -> [Video] {
        var sortedVideoList = videoList.sorted {
            (video1, video2) in
            let video1PublishedDate = NSDate(fromISO8601String: video1.publishedAt)
            let video2PublishedDate = NSDate(fromISO8601String: video2.publishedAt)

            return video1.viewCount > video2.viewCount || video1PublishedDate.compare(video2PublishedDate) == .OrderedDescending
        }

        return Array(sortedVideoList[0 ... 4])
    }

    private func sortChannelList(channelList: [Channel], videoDictionary: [Channel:[Video]]) -> [Channel] {
        return channelList.sorted {
            (channel1, channel2) in

            let videoList1 = videoDictionary[channel1]
            let videoList2 = videoDictionary[channel2]

            if videoList1?.isEmpty == true {
                return false
            } else if videoList2?.isEmpty == true {
                return true
            }

            let video1 = videoList1![0]
            let video2 = videoList2![0]

            let video1PublishedDate = NSDate(fromISO8601String: video1.publishedAt)
            let video2PublishedDate = NSDate(fromISO8601String: video2.publishedAt)

            return video1PublishedDate.compare(video2PublishedDate) == .OrderedDescending
        }
    }
}
