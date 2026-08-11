import Foundation

/// 预算：针对某分类或整体的周期性支出限额。
public struct Budget: Identifiable, Equatable, Codable, Sendable {
    public let id: UUID
    public var ledgerID: UUID
    /// 预算金额（正数）。
    public var amount: Double
    public var period: BudgetPeriod
    /// 关联分类 ID；nil 表示总预算（不限分类）。
    public var categoryID: UUID?

    public init(
        id: UUID = UUID(),
        ledgerID: UUID,
        amount: Double,
        period: BudgetPeriod = .monthly,
        categoryID: UUID? = nil
    ) {
        self.id = id
        self.ledgerID = ledgerID
        self.amount = amount
        self.period = period
        self.categoryID = categoryID
    }

    /// 是否为总预算（不限定分类）。
    public var isOverall: Bool { categoryID == nil }
}
