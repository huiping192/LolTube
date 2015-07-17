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

        let successBlock:((RSChannelModel) -> Void) = {
            [unowned self]channelModel in
            var channelList = [Channel]()
            var channelIdList = [String]()
            
            for item: RSChannelItem in channelModel.items as! [RSChannelItem] {
                channelIdList.append(item.channelId)
                channelList.append(Channel(channelItem:item))
            }
            
            self.loadVideos(channelList, success: success, failure: failure)
            
        }
        
        youtubeService.channel(defaultChannelIdList, success: successBlock, failure: failure)
    }

    private func loadVideos(channelList: [Channel], success: () -> Void, failure: (NSError) -> Void) {
        let channelIdList = channelList.map {
            (channel: Channel) -> String in
            return channel.channelId
        }

        let successBlock:(([RSSearchModel]) -> Void) = {
            [unowned self]searchModelList in
            
            var videoDictionary = [Channel: [Video]]()
            var allVideoList = [Video]()
            
            for (index, searchModel) in searchModelList.enumerate() {
                var videoList = [Video]()
                for item in searchModel.items as! [RSItem] {
                    let video = Video(item:item)
                    videoList.append(video)
                    allVideoList.append(video)
                }
                videoDictionary[channelList[index]] = videoList;
            }
            
            
            let successBlock:(() -> Void) = {
                dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0)) {
                    [unowned self]  in
                    self.topVideoList = self.todayFourHighRankVideoList(allVideoList)
                    self.channelList = self.topChannelList(channelList, videoDictionary: videoDictionary)
                    self.videoDictionary = videoDictionary
                    dispatch_async(dispatch_get_main_queue()) {
                        success()
                    }
                }
            }
            self.updateVideoDetail(allVideoList, success: successBlock, failure: failure)
        }
        
        self.youtubeService.videoList(channelIdList, searchText: nil, nextPageTokenList: nil, success: successBlock, failure: failure)
    }

    private func updateVideoDetail(videoList: [Video], success: () -> Void, failure: (NSError) -> Void) {
        let videoIdList = videoList.map {
            (video: Video) -> String in
            return video.videoId
        }

        let successBlock:((RSVideoDetailModel) -> Void) = {
            videoDetailModel in
            dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0)) {
                for (index, detailItem) in (videoDetailModel.items as! [RSVideoDetailItem]).enumerate() {
                    let video = videoList[index]
                    video.update(detailItem)
                }
                dispatch_async(dispatch_get_main_queue()) {
                    success()
                }
            }
        }
        
        youtubeService.videoDetailList(videoIdList, success: successBlock, failure: failure)
    }

    private func todayFourHighRankVideoList(videoList: [Video]) -> [Video] {
        var sortedVideoList = videoList.sort {
            (video1, video2) in
            let video1PublishedDate = NSDate(fromISO8601String: video1.publishedAt)
            let video2PublishedDate = NSDate(fromISO8601String: video2.publishedAt)

            return video1.viewCount > video2.viewCount || video1PublishedDate.compare(video2PublishedDate) == .OrderedDescending
        }

        return  sortedVideoList.count >= 4 ? Array(sortedVideoList[0 ..< 4]) : sortedVideoList
    }

    private func sortChannelList(channelList: [Channel], videoDictionary: [Channel:[Video]]) -> [Channel] {
        return channelList.sort {
            (channel1, channel2) in

            let videoList1 = videoDictionary[channel1]
            let videoList2 = videoDictionary[channel2]

            //TODO: change to more beautiful code
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
