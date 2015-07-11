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
        let defaultChannelIdList = channelService.channelIds() as! [String]

        youtubeService.channel(defaultChannelIdList, success: {
            [unowned self]channelModel in
            var channelList = [Channel]()
            var channelIdList = [String]()

            for item: RSChannelItem in channelModel.items as! [RSChannelItem] {
                channelList.append(self.convertChannel(item))
                channelIdList.append(item.channelId)
            }

            self.loadVideos(channelList, success: {
                success()
            }, failure: failure)

        }, failure: failure)
    }

    private func loadVideos(channelList: [Channel], success: () -> Void, failure: (NSError) -> Void) {
        let channelIdList = channelList.map {
            (channel: Channel) -> String in
            return channel.channelId
        }

        self.youtubeService.videoList(channelIdList, searchText: nil, nextPageTokenList: nil, success: {
            [unowned self]searchModelList in

            var videoDictionary = [Channel: [Video]]()
            var allVideoList = [Video]()

            for (index, searchModel) in searchModelList.enumerate() {
                var videoList = [Video]()

                for item in searchModel.items as! [RSItem] {
                    let video = self.convertVideo(item)
                    videoList.append(video)
                    allVideoList.append(video)
                }

                videoDictionary[channelList[index]] = videoList;
            }

            self.updateVideoDetail(allVideoList, success: {
                dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0)) {
                    [unowned self] in
                    self.topVideoList = self.todayFourHighRankVideoList(allVideoList)
                    self.channelList = self.topChannelList(channelList, videoDictionary: videoDictionary)
                    self.videoDictionary = videoDictionary
                    dispatch_async(dispatch_get_main_queue()) {
                        success()
                    }
                }
                
            }, failure: failure)

        }, failure: failure)
    }

    private func updateVideoDetail(videoList: [Video], success: () -> Void, failure: (NSError) -> Void) {
        let videoIdList = videoList.map {
            (video: Video) -> String in
            return video.videoId
        }

        youtubeService.videoDetailList(videoIdList, success: {
            videoDetailModel in

            dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0)) {
                for (index, detailItem) in (videoDetailModel.items as! [RSVideoDetailItem]).enumerate() {
                    let video = videoList[index]
                    video.duration = RSVideoInfoUtil.convertVideoDuration(detailItem.contentDetails.duration)
                    video.viewCountString = RSVideoInfoUtil.convertVideoViewCount(Int(detailItem.statistics.viewCount) ?? 0)
                    video.viewCount = Int(detailItem.statistics.viewCount) ?? 0
                    
                    if let viewCount = video.viewCountString , publishedAtString = video.publishedAtString{
                        video.viewCountPublishedAt = "\(viewCount) ・ \(publishedAtString)"
                    }
                }
                dispatch_async(dispatch_get_main_queue()) {
                    success()
                }
            }
            
        }, failure: failure)
    }

    private func convertChannel(item: RSChannelItem) -> Channel {
        let channel = Channel()
        channel.channelId = item.channelId
        channel.title = item.snippet.title
        channel.thumbnailUrl = item.snippet.thumbnails.medium.url

        return channel
    }

    private func convertVideo(item: RSItem) -> Video {
        let video = Video()
        video.videoId = item.id.videoId
        video.channelId = item.snippet.channelId
        video.channelTitle = item.snippet.channelTitle
        video.title = item.snippet.title
        video.thumbnailUrl = item.snippet.thumbnails.medium.url
        video.highThumbnailUrl = "https://i.ytimg.com/vi/\(video.videoId)/maxresdefault.jpg"
        video.publishedAt = item.snippet.publishedAt
        video.publishedAtString = RSVideoInfoUtil.convertToShortPostedTime(item.snippet.publishedAt)

        return video
    }

    private func todayFourHighRankVideoList(videoList: [Video]) -> [Video] {
        var sortedVideoList = videoList.sort {
            (video1, video2) in
            let video1PublishedDate = NSDate(fromISO8601String: video1.publishedAt)
            let video2PublishedDate = NSDate(fromISO8601String: video2.publishedAt)

            return video1.viewCount > video2.viewCount || video1PublishedDate.compare(video2PublishedDate) == .OrderedDescending
        }

        //FIXME: do not have 4 videos crash
        return Array(sortedVideoList[0 ..< 4])
    }

    private func sortChannelList(channelList: [Channel], videoDictionary: [Channel:[Video]]) -> [Channel] {
        return channelList.sort {
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
    
    private func topChannelList(channelList: [Channel], videoDictionary: [Channel:[Video]]) -> [Channel]{
        let sortedChannelList = sortChannelList(channelList, videoDictionary: videoDictionary)
       
        let maxChannelCount = 8
        if sortedChannelList.count > maxChannelCount {
            return Array(sortedChannelList[0 ..< maxChannelCount])
        }
        
        return sortedChannelList
    }
}
