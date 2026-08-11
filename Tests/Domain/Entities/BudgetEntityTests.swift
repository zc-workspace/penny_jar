import XCTest
@testable import PennyJar

final class BudgetEntityTests: XCTestCase {
    func testBudgetValidationAcceptsValidBudget() {
        let ledger = TestFactory.ledger()
        let budget = Budget(
            amount: 100,
            period: .monthly,
            startDate: TestFactory.startDate,
            endDate: TestFactory.endDate,
            ledger: ledger,
            category: TestFactory.category(ledger: ledger)
        )

        XCTAssertNoThrow(try budget.validate())
    }

    func testBudgetValidationRejectsReversedDatesAndNegativeAmount() {
        let ledger = TestFactory.ledger()
        let reversedDates = Budget(
            amount: 100,
            period: .monthly,
            startDate: TestFactory.endDate,
            endDate: TestFactory.startDate,
            ledger: ledger
        )
        let negative = Budget(
            amount: -1,
            period: .monthly,
            startDate: TestFactory.startDate,
            endDate: TestFactory.endDate,
            ledger: ledger
        )

        XCTAssertThrowsError(try reversedDates.validate()) { error in
            XCTAssertEqual(error as? DomainError, .invalidDateRange)
        }
        XCTAssertThrowsError(try negative.validate()) { error in
            XCTAssertEqual(error as? DomainError, .invalidAmount)
        }
    }

    func testBudgetValidationRejectsCrossLedgerCategory() {
        let ledger = TestFactory.ledger()
        let budget = Budget(
            amount: 100,
            period: .monthly,
            startDate: TestFactory.startDate,
            endDate: TestFactory.endDate,
            ledger: ledger,
            category: TestFactory.category(
                ledger: TestFactory.ledger(id: TestFactory.otherLedgerID)
            )
        )

        XCTAssertThrowsError(try budget.validate()) { error in
            XCTAssertEqual(error as? DomainError, .crossLedgerReference)
        }
    }
}
