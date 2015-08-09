import Foundation


public extension NSDate {

    public class func date(iso8601String iso8601String: String) -> NSDate? {
        let dateFormatter = NSDateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ss.SSSZ"
        dateFormatter.locale = NSLocale(localeIdentifier: "en_US_POSIX")
        return dateFormatter.dateFromString(iso8601String)
    }

    public class func todayRFC3339DateTime() -> String {
        let calendar = NSCalendar.currentCalendar()
        let dateComponents = calendar.components([.Year,.Month,.Day,.Hour,.Minute,.Second], fromDate: NSDate())
        dateComponents.hour = 0
        dateComponents.minute = 0
        dateComponents.second = 0

        let morningStartDate = calendar.dateFromComponents(dateComponents)

        let dateFormatter = NSDateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ss.SSSZ"
        dateFormatter.locale = NSLocale(localeIdentifier: "en_US_POSIX")
        return dateFormatter.stringFromDate(morningStartDate!)
    }
}
