import Foundation

final public class ChannelInfoUtil {
   
    public class func convertVideoCount(videoCount:Int) -> String {
        return NSString(format: NSLocalizedString("ChannelVideoCountFormat", comment: ""), videoCount.toDecimalStyleString()) as String
    }
    
    
    public class func convertSubscriberCount(subscriberCount:Int) -> String {
        return NSString(format: NSLocalizedString("ChannelSubscriberCountFormat", comment: ""), subscriberCount.toDecimalStyleString()) as String
    }
}

extension Int {
    func toDecimalStyleString() -> String {
        let formatter = NSNumberFormatter()
        formatter.numberStyle = .DecimalStyle
        let formatted = formatter.stringFromNumber(NSNumber(integer:self))
        return formatted ?? ""
    }
}