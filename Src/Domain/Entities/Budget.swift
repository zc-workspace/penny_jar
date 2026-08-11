import Foundation
import SwiftData

@Model
final class Budget {
    @Attribute(.unique) var id: UUID
    var amount: Decimal
    var periodRawValue: String
    var startDate: Date
    var endDate: Date
    var ledger: Ledger
    var category: Category?

    var period: BudgetPeriod {
        get { BudgetPeriod(rawValue: periodRawValue) ?? .custom }
        set { periodRawValue = newValue.rawValue }
    }

    init(
        id: UUID = UUID(),
        amount: Decimal,
        period: BudgetPeriod,
        startDate: Date,
        endDate: Date,
        ledger: Ledger,
        category: Category? = nil
    ) {
        self.id = id
        self.amount = amount
        self.periodRawValue = period.rawValue
        self.startDate = startDate
        self.endDate = endDate
        self.ledger = ledger
        self.category = category
    }

    func validate() throws {
        guard amount >= .zero, amount.isFinite else {
            throw DomainError.invalidAmount
        }
        guard startDate <= endDate else {
            throw DomainError.invalidDateRange
        }
        if let category, category.ledger.id != ledger.id {
            throw DomainError.crossLedgerReference
        }
        guard BudgetPeriod(rawValue: periodRawValue) != nil else {
            throw DomainError.invalidBudgetPeriod
        }
    }
}
