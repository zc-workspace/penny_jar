import XCTest
@testable import PennyJarDomain

/// 对应 Src/Domain/Entities/ —— 实体派生属性与枚举语义全分支覆盖。
final class EntityTests: XCTestCase {

    // MARK: TransactionType

    func test_transactionTypeSign_coversAllCases() {
        XCTAssertEqual(TransactionType.expense.sign, -1)
        XCTAssertEqual(TransactionType.income.sign, 1)
        XCTAssertEqual(TransactionType.transfer.sign, 0)
    }

    func test_transactionTypeDisplayName_coversAllCases() {
        XCTAssertEqual(TransactionType.expense.displayName, "支出")
        XCTAssertEqual(TransactionType.income.displayName, "收入")
        XCTAssertEqual(TransactionType.transfer.displayName, "转账")
    }

    // MARK: AccountType

    func test_onlyCreditCardIsLiability() {
        XCTAssertTrue(AccountType.creditCard.isLiability)
        XCTAssertFalse(AccountType.cash.isLiability)
        XCTAssertFalse(AccountType.debitCard.isLiability)
        XCTAssertFalse(AccountType.investment.isLiability)
    }

    func test_accountTypeDisplayName_coversAllCases() {
        XCTAssertEqual(AccountType.cash.displayName, "现金")
        XCTAssertEqual(AccountType.debitCard.displayName, "储蓄卡")
        XCTAssertEqual(AccountType.creditCard.displayName, "信用卡")
        XCTAssertEqual(AccountType.investment.displayName, "投资")
    }

    // MARK: BudgetPeriod

    func test_budgetPeriodDisplayName_coversAllCases() {
        XCTAssertEqual(BudgetPeriod.weekly.displayName, "每周")
        XCTAssertEqual(BudgetPeriod.monthly.displayName, "每月")
        XCTAssertEqual(BudgetPeriod.yearly.displayName, "每年")
    }

    // MARK: Transaction.signedAmount（等价类：支出/收入/转账）

    func test_signedAmount_expenseIsNegative() {
        let tx = TestFactory.transaction(type: .expense, amount: 100)
        XCTAssertEqual(tx.signedAmount, -100, accuracy: 0.0001)
    }

    func test_signedAmount_incomeIsPositive() {
        let tx = TestFactory.transaction(type: .income, amount: 100)
        XCTAssertEqual(tx.signedAmount, 100, accuracy: 0.0001)
    }

    func test_signedAmount_transferIsZero() {
        let tx = TestFactory.transaction(type: .transfer, amount: 100)
        XCTAssertEqual(tx.signedAmount, 0, accuracy: 0.0001)
    }

    // MARK: Category.isRoot（分支：nil / 非 nil）

    func test_category_isRoot_whenParentIsNil() {
        let c = TestFactory.category(parentID: nil)
        XCTAssertTrue(c.isRoot)
    }

    func test_category_isNotRoot_whenParentPresent() {
        let c = TestFactory.category(parentID: UUID())
        XCTAssertFalse(c.isRoot)
    }

    // MARK: Budget.isOverall（分支：nil / 非 nil）

    func test_budget_isOverall_whenCategoryIsNil() {
        let b = TestFactory.budget(amount: 1000, categoryID: nil)
        XCTAssertTrue(b.isOverall)
    }

    func test_budget_isNotOverall_whenCategoryPresent() {
        let b = TestFactory.budget(amount: 1000, categoryID: UUID())
        XCTAssertFalse(b.isOverall)
    }

    // MARK: Ledger 默认值 & Codable 往返

    func test_ledger_defaultCurrencyIsCNY() {
        let l = Ledger(name: "x")
        XCTAssertEqual(l.currencyCode, "CNY")
    }

    func test_transaction_codableRoundTrip() throws {
        let tx = TestFactory.transaction(type: .expense, amount: 12.5, note: "咖啡",
                                         categoryID: UUID(), accountID: UUID())
        let data = try JSONEncoder().encode(tx)
        let decoded = try JSONDecoder().decode(Transaction.self, from: data)
        XCTAssertEqual(tx, decoded)
    }

    // MARK: Member（默认头像色 & Codable 往返）

    func test_member_defaultAvatarColorAndInit() throws {
        let m = TestFactory.member(name: "配偶")
        XCTAssertEqual(m.name, "配偶")
        XCTAssertEqual(m.avatarColorHex, "#5B8FF9")
        XCTAssertEqual(m.ledgerID, TestFactory.ledgerID)
        let decoded = try JSONDecoder().decode(Member.self, from: JSONEncoder().encode(m))
        XCTAssertEqual(m, decoded)
    }

    func test_enums_allCasesCount() {
        XCTAssertEqual(TransactionType.allCases.count, 3)
        XCTAssertEqual(AccountType.allCases.count, 4)
        XCTAssertEqual(BudgetPeriod.allCases.count, 3)
    }
}
