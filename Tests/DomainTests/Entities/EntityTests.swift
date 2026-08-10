import XCTest
@testable import PennyJar

/// 对应 Src/Domain/Entities/ —— 验证实体上的派生属性与枚举语义
final class EntityTests: XCTestCase {

    func testTransactionTypeSign() {
        XCTAssertEqual(TransactionType.expense.sign, -1)
        XCTAssertEqual(TransactionType.income.sign, 1)
        XCTAssertEqual(TransactionType.transfer.sign, 0)
    }

    func testSignedAmount() {
        let expense = Transaction(type: .expense, amount: 100)
        let income = Transaction(type: .income, amount: 100)
        XCTAssertEqual(expense.signedAmount, -100, accuracy: 0.001)
        XCTAssertEqual(income.signedAmount, 100, accuracy: 0.001)
    }

    func testOnlyCreditCardIsLiability() {
        XCTAssertTrue(AccountType.creditCard.isLiability)
        XCTAssertFalse(AccountType.cash.isLiability)
        XCTAssertFalse(AccountType.debitCard.isLiability)
        XCTAssertFalse(AccountType.investment.isLiability)
    }

    func testCategoryTypeRoundTrip() {
        let c = TestFactory.category(name: "工资", type: .income)
        XCTAssertEqual(c.type, .income)
        c.type = .expense
        XCTAssertEqual(c.typeRaw, TransactionType.expense.rawValue)
    }
}
