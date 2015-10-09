import Foundation

@objc
class EventTracker: NSObject {
    static func  trackViewContentView<T>(viewName viewName:String,viewType:T.Type,viewId:String? = nil){
        Answers.logContentViewWithName(viewName,
            contentType: String(viewType),
            contentId: viewId,
            customAttributes: nil)
        
       EventTracker.trackGoogleAnalyticsScreen(screenName: viewName)
    }
    
    static func trackViewDetailShare(activityType activityType:String,videoId:String) {
        let contentType = "Video"
        Answers.logShareWithMethod(activityType,
            contentName: videoId,
            contentType: contentType,
            contentId: videoId,
            customAttributes: nil)
        
        EventTracker.trackGoogleAnalyticsEvent(category: contentType, action: "Share", label: videoId)
    }
    
    static func trackVideoDetailPlay(videoId:String) {
        let category = "Video"
        let action = "Play"
        Answers.logCustomEventWithName("Play Video",
            customAttributes: ["videoId":videoId])
        
        EventTracker.trackGoogleAnalyticsEvent(category: category, action: action, label: videoId)
    }
    
    static func trackSearch(searchText:String){
        let category = "Search"
        let action = "Search"

        Answers.logSearchWithQuery(searchText,
            customAttributes: nil)
        
        EventTracker.trackGoogleAnalyticsEvent(category: category, action: action, label: searchText)
    }
    
    static func trackAddChannel(channelTitle channelTitle:String,channelId:String){
        Answers.logCustomEventWithName("Add Channel",
            customAttributes: ["channelTitle":channelTitle,"channelId":channelId])
        
        EventTracker.trackGoogleAnalyticsEvent(category: "Channel", action: "Add", label: channelTitle)
    }
    
    static func trackDeleteChannel(channelTitle channelTitle:String,channelId:String){
        Answers.logCustomEventWithName("Delete Channel",
            customAttributes: ["channelTitle":channelTitle,"channelId":channelId])
        
        EventTracker.trackGoogleAnalyticsEvent(category: "Channel", action: "Delete", label: channelTitle)
    }
    
    private static func trackGoogleAnalyticsScreen(screenName screenName:String){
        guard let tracker = GAI.sharedInstance().defaultTracker else {
            return
        }
        tracker.set(kGAIScreenName, value: screenName)
        let parameters = GAIDictionaryBuilder.createScreenView().build() as [NSObject : AnyObject]
        tracker.send(parameters)
    }
    
    private static func trackGoogleAnalyticsEvent(category category:String,action:String,label:String? = nil) {
        guard let tracker = GAI.sharedInstance().defaultTracker else {
            return
        }
        let parameters =  GAIDictionaryBuilder.createEventWithCategory(category, action: action, label: label, value: nil).build() as [NSObject : AnyObject]
        tracker.send(parameters)
    }

    
}
