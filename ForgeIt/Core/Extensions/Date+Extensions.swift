import Foundation

extension Date {
    var isToday: Bool {
        Calendar.current.isDateInToday(self)
    }

    var isYesterday: Bool {
        Calendar.current.isDateInYesterday(self)
    }

    var relativeDisplay: String {
        let now = Date()
        let diff = now.timeIntervalSince(self)

        if diff < 60 {
            return "just now"
        } else if diff < 3600 {
            let mins = Int(diff / 60)
            return "\(mins)m ago"
        } else if diff < 86400 {
            let hrs = Int(diff / 3600)
            return "\(hrs)h ago"
        } else if isYesterday {
            return "yesterday"
        } else {
            let formatter = DateFormatter()
            formatter.dateFormat = "MMM d"
            return formatter.string(from: self)
        }
    }

    var todayLabel: String {
        if isToday { return "today" }
        if isYesterday { return "yesterday" }
        return relativeDisplay
    }

    var dateOnly: Date {
        Calendar.current.startOfDay(for: self)
    }

    static var todayDate: Date {
        Calendar.current.startOfDay(for: Date())
    }

    static var isoDateFormatter: DateFormatter = {
        let f = DateFormatter()
        f.dateFormat = "yyyy-MM-dd"
        return f
    }()

    var isoDateString: String {
        Date.isoDateFormatter.string(from: self)
    }
}
