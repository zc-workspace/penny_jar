import Foundation

/// 交易流水：一笔支出 / 收入 / 转账。
public struct Transaction: Identifiable, Equatable, Codable, Sendable {
    public let id: UUID
    public var ledgerID: UUID
    public var type: TransactionType
    /// 金额，始终为非负数；方向由 `type` 决定。
    public var amount: Double
    public var date: Date
    public var note: String
    /// 分类 ID（转账通常为 nil）。
    public var categoryID: UUID?
    /// 来源账户 ID（支出/转账的出账账户；收入的入账账户）。
    public var accountID: UUID?
    /// 转入账户 ID（仅转账使用）。
    public var toAccountID: UUID?
    /// 成员 ID。
    public var memberID: UUID?

    public init(
        id: UUID = UUID(),
        ledgerID: UUID,
        type: TransactionType,
        amount: Double,
        date: Date = Date(),
        note: String = "",
        categoryID: UUID? = nil,
        accountID: UUID? = nil,
        toAccountID: UUID? = nil,
        memberID: UUID? = nil
    ) {
        self.id = id
        self.ledgerID = ledgerID
        self.type = type
        self.amount = amount
        self.date = date
        self.note = note
        self.categoryID = categoryID
        self.accountID = accountID
        self.toAccountID = toAccountID
        self.memberID = memberID
    }

    /// 带方向的金额：支出为负、收入为正、转账为 0。
    public var signedAmount: Double {
        amount * type.sign
    }
}
