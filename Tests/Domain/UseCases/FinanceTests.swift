import Foundation
import XCTest
@testable import PennyJar

final class FinanceTests: XCTestCase {
    func testBalanceAppliesIncomeExpenseAndBothSidesOfTransfer() {
        let ledger = TestFactory.ledger()
        let cash = TestFactory.account(ledger: ledger)
        let bank = TestFactory.account(id: TestFactory.otherAccountID, ledger: ledger)
        let expense = TestFactory.transaction(
            amount: 20,
            type: .expense,
            ledger: ledger,
            account: cash,
            category: TestFactory.category(ledger: ledger)
        )
        let income = TestFactory.transaction(
            id: UUID(),
            amount: 50,
            type: .income,
            ledger: ledger,
            account: cash,
            category: TestFactory.category(
                id: TestFactory.incomeCategoryID,
                ledger: ledger,
                type: .income
            )
        )
        let transfer = TestFactory.transaction(
            id: UUID(),
            amount: 30,
            type: .transfer,
            ledger: ledger,
            account: cash,
            transferAccount: bank
        )

        XCTAssertEqual(Finance.balance(for: cash, transactions: [expense, income, transfer]), 100)
        XCTAssertEqual(Finance.balance(for: bank, transactions: [transfer]), 130)
    }

    func testBalancesAndNetWorthAccountForLiabilitySign() {
        let ledger = TestFactory.ledger()
        let asset = TestFactory.account(ledger: ledger, openingBalance: 100)
        let liability = TestFactory.account(
            id: TestFactory.otherAccountID,
            ledger: ledger,
            type: .creditCard,
            openingBalance: 50
        )
        let transactions: [Transaction] = []

        XCTAssertEqual(
            Finance.balances(for: [asset, liability], transactions: transactions),
            [
                AccountBalance(accountID: asset.id, balance: 100),
                AccountBalance(accountID: liability.id, balance: 50)
            ]
        )
        XCTAssertEqual(
            Finance.netWorth(accounts: [asset, liability], transactions: transactions),
            50
        )
    }

    func testExpenseTotalFiltersDateAndCategory() throws {
        let ledger = TestFactory.ledger()
        let account = TestFactory.account(ledger: ledger)
        let category = TestFactory.category(ledger: ledger)
        let otherCategory = TestFactory.category(
            id: TestFactory.incomeCategoryID,
            ledger: ledger
        )
        let included = TestFactory.transaction(
            amount: 20,
            ledger: ledger,
            account: account,
            category: category
        )
        let wrongCategory = TestFactory.transaction(
            id: UUID(),
            amount: 80,
            ledger: ledger,
            account: account,
            category: otherCategory
        )
        let outsideDate = TestFactory.transaction(
            id: UUID(),
            amount: 100,
            ledger: ledger,
            account: account,
            category: category,
            occurredAt: TestFactory.endDate.addingTimeInterval(1)
        )

        XCTAssertEqual(
            try Finance.expenseTotal(
                transactions: [included, wrongCategory, outsideDate],
                from: TestFactory.startDate,
                through: TestFactory.endDate,
                categoryID: category.id
            ),
            20
        )
        XCTAssertEqual(
            try Finance.expenseTotal(
                transactions: [included, wrongCategory],
                from: TestFactory.startDate,
                through: TestFactory.endDate
            ),
            100
        )
    }

    func testExpenseTotalAndBudgetProgressRejectReversedDatesAndCalculateRatio() throws {
        let ledger = TestFactory.ledger()
        let category = TestFactory.category(ledger: ledger)
        let account = TestFactory.account(ledger: ledger)
        let transaction = TestFactory.transaction(
            amount: 25,
            ledger: ledger,
            account: account,
            category: category
        )
        let budget = Budget(
            amount: 100,
            period: .monthly,
            startDate: TestFactory.startDate,
            endDate: TestFactory.endDate,
            ledger: ledger,
            category: category
        )

        let progress = try Finance.budgetProgress(for: budget, transactions: [transaction])
        XCTAssertEqual(progress.spent, 25)
        XCTAssertEqual(progress.limit, 100)
        XCTAssertEqual(progress.ratio, 0.25)

        XCTAssertThrowsError(
            try Finance.expenseTotal(
                transactions: [],
                from: TestFactory.endDate,
                through: TestFactory.startDate
            )
        ) { error in
            XCTAssertEqual(error as? DomainError, .invalidDateRange)
        }
    }

    func testBudgetProgressUsesOneForPositiveSpendWhenLimitIsZero() throws {
        let ledger = TestFactory.ledger()
        let account = TestFactory.account(ledger: ledger)
        let category = TestFactory.category(ledger: ledger)
        let budget = Budget(
            amount: 0,
            period: .custom,
            startDate: TestFactory.startDate,
            endDate: TestFactory.endDate,
            ledger: ledger,
            category: category
        )
        let transaction = TestFactory.transaction(
            ledger: ledger,
            account: account,
            category: category
        )

        XCTAssertEqual(
            try Finance.budgetProgress(for: budget, transactions: [transaction]).ratio,
            1
        )
    }

    func testBudgetProgressUsesZeroWhenZeroBudgetHasNoSpend() throws {
        let ledger = TestFactory.ledger()
        let category = TestFactory.category(ledger: ledger)
        let budget = Budget(
            amount: 0,
            period: .custom,
            startDate: TestFactory.startDate,
            endDate: TestFactory.endDate,
            ledger: ledger,
            category: category
        )

        XCTAssertEqual(
            try Finance.budgetProgress(for: budget, transactions: []).ratio,
            0
        )
    }
}
