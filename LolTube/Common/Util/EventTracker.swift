import Foundation

@objc
class EventTracker: NSObject {
    static func  trackViewContentView<T>(viewName:String,viewType:T.Type,viewId:String? = nil){
        Answers.logContentView(withName: viewName,
            contentType: String(describing: viewType),
            contentId: viewId,
            customAttributes: nil)
        
       EventTracker.trackGoogleAnalyticsScreen(screenName: viewName)
    }
    
    static func trackViewDetailShare(activityType:String,videoId:String) {
        let contentType = "Video"
        Answers.logShare(withMethod: activityType,
            contentName: videoId,
            contentType: contentType,
            contentId: videoId,
            customAttributes: nil)
        
        EventTracker.trackGoogleAnalyticsEvent(category: contentType, action: "Share", label: videoId)
    }
    
    static func trackVideoDetailPlay(_ videoId:String) {
        let category = "Video"
        let action = "Play"
        Answers.logCustomEvent(withName: "Play Video",
            customAttributes: ["videoId":videoId])
        
        EventTracker.trackGoogleAnalyticsEvent(category: category, action: action, label: videoId)
    }
    
    static func trackSearch(_ searchText:String){
        let category = "Search"
        let action = "Search"

        Answers.logSearch(withQuery: searchText,
            customAttributes: nil)
        
        EventTracker.trackGoogleAnalyticsEvent(category: category, action: action, label: searchText)
    }
    
    static func trackAddChannel(channelTitle:String,channelId:String){
        Answers.logCustomEvent(withName: "Add Channel",
            customAttributes: ["channelTitle":channelTitle,"channelId":channelId])
        
        EventTracker.trackGoogleAnalyticsEvent(category: "Channel", action: "Add", label: channelTitle)
    }
    
    static func trackDeleteChannel(channelTitle:String,channelId:String){
        Answers.logCustomEvent(withName: "Delete Channel",
            customAttributes: ["channelTitle":channelTitle,"channelId":channelId])
        
        EventTracker.trackGoogleAnalyticsEvent(category: "Channel", action: "Delete", label: channelTitle)
    }
    
    static func trackBackgroundFetch() {
        Answers.logCustomEvent(withName: "Background Fetch",
            customAttributes: nil)
        
        EventTracker.trackGoogleAnalyticsEvent(category: "App", action: "BackgroundFetch", label: nil)
    }
    
    fileprivate static func trackGoogleAnalyticsScreen(screenName:String){
        guard let tracker = GAI.sharedInstance().defaultTracker else {
            return
        }
        tracker.set(kGAIScreenName, value: screenName)
        let parameters = GAIDictionaryBuilder.createScreenView().build() as! [AnyHashable: Any]
        tracker.send(parameters)
    }
    
    fileprivate static func trackGoogleAnalyticsEvent(category:String,action:String,label:String? = nil) {
        guard let tracker = GAI.sharedInstance().defaultTracker else {
            return
        }
        let parameters =  GAIDictionaryBuilder.createEvent(withCategory: category, action: action, label: label, value: nil).build() as! [AnyHashable: Any]
        tracker.send(parameters)
    }

    
}
