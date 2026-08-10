import Foundation

// MARK: - 日期区间工具

extension Date {
    var startOfMonth: Date {
        let c = Calendar.current.dateComponents([.year, .month], from: self)
        return Calendar.current.date(from: c) ?? self
    }
    var endOfMonth: Date {
        let cal = Calendar.current
        return cal.date(byAdding: DateComponents(month: 1, day: 0), to: startOfMonth) ?? self
    }
    var startOfDay: Date { Calendar.current.startOfDay(for: self) }
    var startOfYear: Date {
        let c = Calendar.current.dateComponents([.year], from: self)
        return Calendar.current.date(from: c) ?? self
    }
    func isSameDay(_ other: Date) -> Bool {
        Calendar.current.isDate(self, inSameDayAs: other)
    }
}
