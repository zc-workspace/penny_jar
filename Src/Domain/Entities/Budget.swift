import Foundation
import SwiftData

// MARK: - 预算

@Model
final class Budget {
    @Attribute(.unique) var id: UUID
    var amount: Double
    var periodRaw: String
    var category: Category?      // 为空表示总预算
    var ledger: Ledger?
    var createdAt: Date

    var period: BudgetPeriod {
        get { BudgetPeriod(rawValue: periodRaw) ?? .monthly }
        set { periodRaw = newValue.rawValue }
    }

    init(amount: Double,
         period: BudgetPeriod = .monthly,
         category: Category? = nil,
         ledger: Ledger? = nil) {
        self.id = UUID()
        self.amount = amount
        self.periodRaw = period.rawValue
        self.category = category
        self.ledger = ledger
        self.createdAt = Date()
    }
}
