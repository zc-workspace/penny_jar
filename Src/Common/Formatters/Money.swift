import Foundation

// MARK: - 金额格式化

enum Money {
    static func string(_ value: Double, code: String = "CNY") -> String {
        let f = NumberFormatter()
        f.numberStyle = .currency
        f.currencyCode = code
        f.maximumFractionDigits = 2
        f.locale = Locale(identifier: "zh_CN")
        return f.string(from: NSNumber(value: value)) ?? String(format: "%.2f", value)
    }

    static func plain(_ value: Double) -> String {
        String(format: "%.2f", value)
    }
}
