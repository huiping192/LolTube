import Foundation

extension Int {
    private func toDecimalStyleString() -> String {
        let formatter = NSNumberFormatter()
        formatter.numberStyle = .DecimalStyle
        let formatted = formatter.stringFromNumber(NSNumber(integer:self))
        return formatted ?? ""
    }
    
    func toVideoCountFormat() -> String {
        return NSString(format: NSLocalizedString("ChannelVideoCountFormat", comment: ""), self.toDecimalStyleString()) as String
    }
    
    func toSubscriberCountFormat() -> String {
        return NSString(format: NSLocalizedString("ChannelSubscriberCountFormat", comment: ""), self.toDecimalStyleString()) as String
    }
    
    func toViewerCountFormat() -> String {
        return NSString(format: NSLocalizedString("TwitchViewerCountFormat", comment: ""), self.toDecimalStyleString()) as String
    }
}