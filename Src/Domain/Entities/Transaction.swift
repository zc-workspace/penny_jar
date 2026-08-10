import Foundation
import SwiftData

// MARK: - 交易（流水 / 记一笔）

@Model
final class Transaction {
    @Attribute(.unique) var id: UUID
    var typeRaw: String
    var amount: Double
    var date: Date
    var note: String
    var photoData: Data?         // 记一笔拍照
    var projectTag: String?      // 项目标签

    var category: Category?
    var account: Account?        // 支出/收入的账户；转账的转出账户
    var toAccount: Account?      // 转账的转入账户
    var member: Member?
    var ledger: Ledger?

    var type: TransactionType {
        get { TransactionType(rawValue: typeRaw) ?? .expense }
        set { typeRaw = newValue.rawValue }
    }

    /// 带符号金额，用于余额与统计
    var signedAmount: Double { amount * type.sign }

    init(type: TransactionType,
         amount: Double,
         date: Date = Date(),
         note: String = "",
         category: Category? = nil,
         account: Account? = nil,
         toAccount: Account? = nil,
         member: Member? = nil,
         ledger: Ledger? = nil,
         projectTag: String? = nil,
         photoData: Data? = nil) {
        self.id = UUID()
        self.typeRaw = type.rawValue
        self.amount = amount
        self.date = date
        self.note = note
        self.category = category
        self.account = account
        self.toAccount = toAccount
        self.member = member
        self.ledger = ledger
        self.projectTag = projectTag
        self.photoData = photoData
    }
}
