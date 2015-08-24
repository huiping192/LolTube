import Foundation

@objc
class EventTracker: NSObject {
    static func  trackViewContentView<T>(viewName viewName:String,viewType:T.Type,viewId:String? = nil){
        Answers.logContentViewWithName(viewName,
            contentType: String(viewType),
            contentId: viewId,
            customAttributes: nil)
    }
    
    static func trackViewDetailShare(activityType activityType:String,videoId:String) {
        Answers.logShareWithMethod(activityType,
            contentName: videoId,
            contentType: "Video",
            contentId: videoId,
            customAttributes: nil)
    }
    
    static func trackVideoDetailPlay(videoId:String) {
        Answers.logCustomEventWithName("Play Video",
            customAttributes: ["videoId":videoId])
    }
    
    static func trackSearch(searchText:String){
        Answers.logSearchWithQuery(searchText,
            customAttributes: nil)
    }
    
    static func trackAddChannel(channelTitle channelTitle:String,channelId:String){
        Answers.logCustomEventWithName("Add Channel",
            customAttributes: ["channelTitle":channelTitle,"channelId":channelId])
    }
    
    static func trackDeleteChannel(channelTitle channelTitle:String,channelId:String){
        Answers.logCustomEventWithName("Delete Channel",
            customAttributes: ["channelTitle":channelTitle,"channelId":channelId])
    }
    
}
