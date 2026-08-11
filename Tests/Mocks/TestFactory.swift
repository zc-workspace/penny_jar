import Foundation
@testable import PennyJarDomain

/// 测试工厂：快速构造 Domain 实体实例。
enum TestFactory {
    static let ledgerID = UUID(uuidString: "00000000-0000-0000-0000-0000000000AA")!

    static func ledger(name: String = "日常账本", currency: String = "CNY") -> Ledger {
        Ledger(id: ledgerID, name: name, currencyCode: currency)
    }

    static func account(
        id: UUID = UUID(),
        name: String = "测试账户",
        type: AccountType = .debitCard,
        initialBalance: Double = 0,
        includeInNetWorth: Bool = true
    ) -> Account {
        Account(id: id, ledgerID: ledgerID, name: name, type: type,
                initialBalance: initialBalance, includeInNetWorth: includeInNetWorth)
    }

    static func category(
        id: UUID = UUID(),
        name: String = "餐饮",
        type: TransactionType = .expense,
        parentID: UUID? = nil
    ) -> Category {
        Category(id: id, ledgerID: ledgerID, name: name,
                 iconName: "fork.knife", colorHex: "#FF6B6B", type: type, parentID: parentID)
    }

    static func member(id: UUID = UUID(), name: String = "我") -> Member {
        Member(id: id, ledgerID: ledgerID, name: name)
    }

    static func transaction(
        id: UUID = UUID(),
        type: TransactionType,
        amount: Double,
        date: Date = Date(),
        note: String = "",
        categoryID: UUID? = nil,
        accountID: UUID? = nil,
        toAccountID: UUID? = nil,
        memberID: UUID? = nil
    ) -> Transaction {
        Transaction(id: id, ledgerID: ledgerID, type: type, amount: amount, date: date,
                    note: note, categoryID: categoryID, accountID: accountID,
                    toAccountID: toAccountID, memberID: memberID)
    }

    static func budget(
        id: UUID = UUID(),
        amount: Double,
        period: BudgetPeriod = .monthly,
        categoryID: UUID? = nil
    ) -> Budget {
        Budget(id: id, ledgerID: ledgerID, amount: amount, period: period, categoryID: categoryID)
    }
}
