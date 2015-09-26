import Foundation
import Async

class TopViewModel {
    
    private let youtubeService = YoutubeService()
    private let channelService = ChannelService()
    private let twitchService = TwitchService()

    var topVideoList: [Video]?
    var channelList: [Channel]?
    var videoDictionary: [Channel:[Video]]?
    
    var twtichStreamList: [TwitchStream]?
    
    init() {
        
    }
    
    func update(success: () -> Void, failure: (NSError) -> Void) {
        let defaultChannelIdList = channelService.channelIds()
        
        let successBlock:((RSChannelModel) -> Void) = {
            [weak self]channelModel in
            
            let channelList = (channelModel.items as! [RSChannelItem]).map{Channel($0)}
            
            self?.loadVideos(channelList, success: success, failure: failure)
        }
        
        youtubeService.channel(defaultChannelIdList, success: successBlock, failure: failure)
    }
    
    private func loadVideos(channelList: [Channel], success: () -> Void, failure: (NSError) -> Void) {
        let successBlock:(([RSSearchModel]) -> Void) = {
            [weak self]searchModelList in
            Async.userInitiated{
                [weak self]  in
                guard let weakSelf = self else {
                    return
                }
                var videoDictionary = [Channel: [Video]]()
                var allVideoList = [Video]()
                
                for (index, searchModel) in searchModelList.enumerate() {
                    var videoList = [Video]()
                    
                    if searchModel.items != nil {
                        (searchModel.items as! [RSItem]).forEach{
                            let video = Video($0)
                       videoList.append(video)
                            allVideoList.append(video)
                        }
                    }
                    
                    videoDictionary[channelList[index]] = videoList;
                }
                
                weakSelf.topVideoList = weakSelf.highRankVideoList(allVideoList)
                weakSelf.channelList = weakSelf.topChannelList(channelList, videoDictionary: videoDictionary)
                weakSelf.videoDictionary = videoDictionary
                
                weakSelf.loadTwitchStream({
                    Async.main{success()}
                    }, failure: failure)
                
            }
        }
        
        let channelIdList = channelList.map { $0.channelId! }
        self.youtubeService.videoList(channelIdList, searchText: nil, nextPageTokenList: nil, success: successBlock, failure: failure)
    }
    
    func loadTwitchStream(success: () -> Void, failure: ((NSError) -> Void)?) {
        let successBlock:(RSStreamListModel -> Void) = {
            [weak self]streamListModel in
            self?.twtichStreamList = streamListModel.streams.map{ TwitchStream($0) }
            success()
        }
        
        twitchService.steamList(pageCount:4, pageNumber: 0, success: successBlock, failure: failure)
    }
    
    func updateVideoDetail(video: Video, success: () -> Void, failure: ((NSError) -> Void)? = nil) {
        guard video.duration == nil || video.viewCount == nil else {
            Async.main{success()}
            return
        }
        
        let successBlock:((RSVideoDetailModel) -> Void) = {
            videoDetailModel in
            Async.userInitiated{
                if let videoDetail = (videoDetailModel.items as! [RSVideoDetailItem]).first {
                    video.update(videoDetail)
                }
                Async.main{success()}
            }
        }
        
        youtubeService.videoDetail(video.videoId, success: successBlock, failure: failure)
    }
    
    private func highRankVideoList(videoList: [Video]) -> [Video] {
        var sortedVideoList = videoList.sort {
            if let video1PublishedAt = $0.publishedAt, video2PublishedAt = $1.publishedAt {
                if let video1PublishedDate = NSDate.date(iso8601String: video1PublishedAt), video2PublishedDate = NSDate.date(iso8601String: video2PublishedAt) {
                    return $0.viewCount > $1.viewCount || video1PublishedDate.compare(video2PublishedDate) == .OrderedDescending
                }
            }
            
            return false
        }
        
        let highRankVideoCount = 4
        return  sortedVideoList.count >= highRankVideoCount ? Array(sortedVideoList[0 ..< highRankVideoCount]) : sortedVideoList
    }
    
    private func sortChannelList(channelList: [Channel], videoDictionary: [Channel:[Video]]) -> [Channel] {
        return channelList.sort {
            let videoList1 = videoDictionary[$0]
            let videoList2 = videoDictionary[$1]
            
            if videoList1?.isEmpty == true {
                return false
            } else if videoList2?.isEmpty == true {
                return true
            }
            
            let video1 = videoList1![0]
            let video2 = videoList2![0]
            
            if let video1PublishedAt = video1.publishedAt, video2PublishedAt = video2.publishedAt {
                if let video1PublishedDate = NSDate.date(iso8601String: video1PublishedAt), video2PublishedDate = NSDate.date(iso8601String: video2PublishedAt) {
                    return video1PublishedDate.compare(video2PublishedDate) == .OrderedDescending
                }
            }
            return false
        }
    }
    
    private func topChannelList(channelList: [Channel], videoDictionary: [Channel:[Video]]) -> [Channel]{
        return sortChannelList(channelList, videoDictionary: videoDictionary).filter{ videoDictionary[$0]?.count != 0}
    }
}
