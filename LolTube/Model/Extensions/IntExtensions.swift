import Foundation

extension Int {
    fileprivate func toDecimalStyleString() -> String {
        let formatter = NumberFormatter()
        formatter.numberStyle = .decimal
        let formatted = formatter.string(from: NSNumber(value: self as Int))
        return formatted ?? ""
    }
    
    func toVideoCountFormat() -> String {
        return NSString(format: NSLocalizedString("ChannelVideoCountFormat", comment: "") as NSString, self.toDecimalStyleString()) as String
    }
    
    func toSubscriberCountFormat() -> String {
        return NSString(format: NSLocalizedString("ChannelSubscriberCountFormat", comment: "") as NSString, self.toDecimalStyleString()) as String
    }
    
    func toViewerCountFormat() -> String {
        return NSString(format: NSLocalizedString("TwitchViewerCountFormat", comment: "") as NSString, self.toDecimalStyleString()) as String
    }
}
