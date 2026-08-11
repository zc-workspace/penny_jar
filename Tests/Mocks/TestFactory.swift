import Foundation
@testable import PennyJar

enum TestFactory {
    static let ledgerID = UUID(uuidString: "00000000-0000-0000-0000-000000000001")!
    static let otherLedgerID = UUID(uuidString: "00000000-0000-0000-0000-000000000002")!
    static let accountID = UUID(uuidString: "00000000-0000-0000-0000-000000000011")!
    static let otherAccountID = UUID(uuidString: "00000000-0000-0000-0000-000000000012")!
    static let categoryID = UUID(uuidString: "00000000-0000-0000-0000-000000000021")!
    static let incomeCategoryID = UUID(uuidString: "00000000-0000-0000-0000-000000000022")!
    static let memberID = UUID(uuidString: "00000000-0000-0000-0000-000000000031")!
    static let transactionID = UUID(uuidString: "00000000-0000-0000-0000-000000000041")!
    static let budgetID = UUID(uuidString: "00000000-0000-0000-0000-000000000051")!
    static let startDate = Date(timeIntervalSince1970: 1_700_000_000)
    static let endDate = Date(timeIntervalSince1970: 1_700_086_400)

    static func ledger(id: UUID = ledgerID, name: String = "日常") -> Ledger {
        Ledger(id: id, name: name)
    }

    static func account(
        id: UUID = accountID,
        ledger: Ledger,
        type: AccountType = .cash,
        openingBalance: Decimal = 100
    ) -> Account {
        Account(
            id: id,
            name: "账户",
            type: type,
            openingBalance: openingBalance,
            ledger: ledger
        )
    }

    static func category(
        id: UUID = categoryID,
        ledger: Ledger,
        type: CategoryType = .expense
    ) -> PennyJar.Category {
        PennyJar.Category(id: id, name: "分类", type: type, ledger: ledger)
    }

    static func member(ledger: Ledger) -> Member {
        Member(id: memberID, name: "我", ledger: ledger)
    }

    static func transaction(
        id: UUID = transactionID,
        amount: Decimal = 20,
        type: TransactionType = .expense,
        ledger: Ledger,
        account: Account,
        category: PennyJar.Category? = nil,
        transferAccount: Account? = nil,
        occurredAt: Date = startDate
    ) -> Transaction {
        Transaction(
            id: id,
            amount: amount,
            type: type,
            occurredAt: occurredAt,
            ledger: ledger,
            account: account,
            transferAccount: transferAccount,
            category: category,
            member: member(ledger: ledger)
        )
    }
}
