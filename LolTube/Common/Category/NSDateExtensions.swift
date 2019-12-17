import Foundation



extension NSDate {
    @objc static func date(iso8601String: String) -> Date? {
        return Date.date(iso8601String:iso8601String)
    }
}

public extension Date {

    static func date(iso8601String: String) -> Date? {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ss.SSSZ"
        dateFormatter.locale = Locale(identifier: "en_US_POSIX")
        return dateFormatter.date(from: iso8601String)
    }

    static func todayRFC3339DateTime() -> String {
        let calendar = Calendar.current
        var dateComponents = (calendar as NSCalendar).components([.year,.month,.day,.hour,.minute,.second], from: Date())
        dateComponents.hour = 0
        dateComponents.minute = 0
        dateComponents.second = 0

        let morningStartDate = calendar.date(from: dateComponents)

        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ss.SSSZ"
        dateFormatter.locale = Locale(identifier: "en_US_POSIX")
        return dateFormatter.string(from: morningStartDate!)
    }
}
