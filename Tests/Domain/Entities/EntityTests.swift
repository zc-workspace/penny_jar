import Foundation
import XCTest
@testable import PennyJar

final class EntityTests: XCTestCase {
    func testAccountTypeMarksOnlyCreditCardAndLoanAsLiabilities() {
        XCTAssertTrue(AccountType.creditCard.isLiability)
        XCTAssertTrue(AccountType.loan.isLiability)
        XCTAssertFalse(AccountType.cash.isLiability)
        XCTAssertFalse(AccountType.bankCard.isLiability)
        XCTAssertFalse(AccountType.digitalWallet.isLiability)
        XCTAssertFalse(AccountType.investment.isLiability)
        XCTAssertFalse(AccountType.receivable.isLiability)
    }

    func testLedgerValidationAcceptsTrimmedNameAndUppercaseCurrency() throws {
        let ledger = Ledger(name: " 日常 ", currencyCode: "USD")

        XCTAssertNoThrow(try ledger.validate())
    }

    func testLedgerValidationRejectsEmptyNameAndInvalidCurrency() {
        let emptyName = Ledger(name: " \n")
        XCTAssertThrowsError(try emptyName.validate()) { error in
            XCTAssertEqual(error as? DomainError, .emptyName)
        }

        let invalidCurrency = Ledger(name: "日常", currencyCode: "cny")
        XCTAssertThrowsError(try invalidCurrency.validate()) { error in
            XCTAssertEqual(error as? DomainError, .invalidCurrencyCode)
        }
    }

    func testAccountValidationRejectsEmptyName() {
        let account = Account(name: "", type: .cash, ledger: TestFactory.ledger())

        XCTAssertThrowsError(try account.validate()) { error in
            XCTAssertEqual(error as? DomainError, .emptyName)
        }
    }

    func testCategoryValidationChecksNameAndHexColor() {
        let emptyName = Category(name: "", type: .expense, ledger: TestFactory.ledger())
        XCTAssertThrowsError(try emptyName.validate()) { error in
            XCTAssertEqual(error as? DomainError, .emptyName)
        }

        let invalidColor = Category(
            name: "餐饮",
            type: .expense,
            colorHex: "red",
            ledger: TestFactory.ledger()
        )
        XCTAssertThrowsError(try invalidColor.validate()) { error in
            XCTAssertEqual(error as? DomainError, .invalidCurrencyCode)
        }
    }

    func testMemberValidationRejectsWhitespaceName() {
        let member = Member(name: " \t", ledger: TestFactory.ledger())

        XCTAssertThrowsError(try member.validate()) { error in
            XCTAssertEqual(error as? DomainError, .emptyName)
        }
    }

    func testTransactionSignedAmountUsesTransactionType() {
        let ledger = TestFactory.ledger()
        let account = TestFactory.account(ledger: ledger)
        let category = TestFactory.category(ledger: ledger)

        let expense = TestFactory.transaction(
            type: .expense,
            ledger: ledger,
            account: account,
            category: category
        )
        let income = TestFactory.transaction(
            id: UUID(),
            type: .income,
            ledger: ledger,
            account: account,
            category: TestFactory.category(
                id: TestFactory.incomeCategoryID,
                ledger: ledger,
                type: .income
            )
        )
        let transfer = TestFactory.transaction(
            id: UUID(),
            type: .transfer,
            ledger: ledger,
            account: account,
            transferAccount: TestFactory.account(
                id: TestFactory.otherAccountID,
                ledger: ledger
            )
        )

        XCTAssertEqual(expense.signedAmount, -20)
        XCTAssertEqual(income.signedAmount, 20)
        XCTAssertEqual(transfer.signedAmount, .zero)
    }

    func testTransactionValidationAcceptsMatchingExpenseIncomeAndTransfer() throws {
        let ledger = TestFactory.ledger()
        let account = TestFactory.account(ledger: ledger)
        let otherAccount = TestFactory.account(
            id: TestFactory.otherAccountID,
            ledger: ledger
        )
        let expense = TestFactory.transaction(
            type: .expense,
            ledger: ledger,
            account: account,
            category: TestFactory.category(ledger: ledger)
        )
        let income = TestFactory.transaction(
            id: UUID(),
            type: .income,
            ledger: ledger,
            account: account,
            category: TestFactory.category(
                id: TestFactory.incomeCategoryID,
                ledger: ledger,
                type: .income
            )
        )
        let transfer = TestFactory.transaction(
            id: UUID(),
            type: .transfer,
            ledger: ledger,
            account: account,
            transferAccount: otherAccount
        )

        XCTAssertNoThrow(try expense.validate())
        XCTAssertNoThrow(try income.validate())
        XCTAssertNoThrow(try transfer.validate())
    }

    func testTransactionValidationRejectsInvalidAmountAndCrossLedgerReferences() {
        let ledger = TestFactory.ledger()
        let otherLedger = TestFactory.ledger(id: TestFactory.otherLedgerID)
        let account = TestFactory.account(ledger: ledger)
        let expenseCategory = TestFactory.category(ledger: ledger)

        let zero = TestFactory.transaction(
            amount: 0,
            ledger: ledger,
            account: account,
            category: expenseCategory
        )
        XCTAssertThrowsError(try zero.validate()) { error in
            XCTAssertEqual(error as? DomainError, .invalidAmount)
        }

        let crossLedgerAccount = TestFactory.transaction(
            ledger: ledger,
            account: TestFactory.account(ledger: otherLedger),
            category: expenseCategory
        )
        XCTAssertThrowsError(try crossLedgerAccount.validate()) { error in
            XCTAssertEqual(error as? DomainError, .crossLedgerReference)
        }

        let crossLedgerCategory = TestFactory.transaction(
            ledger: ledger,
            account: account,
            category: TestFactory.category(ledger: otherLedger)
        )
        XCTAssertThrowsError(try crossLedgerCategory.validate()) { error in
            XCTAssertEqual(error as? DomainError, .crossLedgerReference)
        }
    }

    func testTransactionValidationRejectsInvalidTransferShape() {
        let ledger = TestFactory.ledger()
        let account = TestFactory.account(ledger: ledger)
        let otherAccount = TestFactory.account(id: TestFactory.otherAccountID, ledger: ledger)
        let expenseCategory = TestFactory.category(ledger: ledger)
        let transferMissingTarget = TestFactory.transaction(
            type: .transfer,
            ledger: ledger,
            account: account
        )
        XCTAssertThrowsError(try transferMissingTarget.validate()) { error in
            XCTAssertEqual(error as? DomainError, .missingTransferAccount)
        }

        let transferSameTarget = TestFactory.transaction(
            type: .transfer,
            ledger: ledger,
            account: account,
            transferAccount: account
        )
        XCTAssertThrowsError(try transferSameTarget.validate()) { error in
            XCTAssertEqual(error as? DomainError, .sameTransferAccount)
        }

        let transferWithCategory = TestFactory.transaction(
            type: .transfer,
            ledger: ledger,
            account: account,
            category: expenseCategory,
            transferAccount: otherAccount
        )
        XCTAssertThrowsError(try transferWithCategory.validate()) { error in
            XCTAssertEqual(error as? DomainError, .invalidTransactionCategory)
        }
    }

    func testTransactionValidationRejectsCategoryAndMemberMismatches() {
        let ledger = TestFactory.ledger()
        let otherLedger = TestFactory.ledger(id: TestFactory.otherLedgerID)
        let account = TestFactory.account(ledger: ledger)
        let incomeWithExpenseCategory = TestFactory.transaction(
            type: .income,
            ledger: ledger,
            account: account,
            category: TestFactory.category(ledger: ledger)
        )
        XCTAssertThrowsError(try incomeWithExpenseCategory.validate()) { error in
            XCTAssertEqual(error as? DomainError, .invalidTransactionCategory)
        }

        let crossLedgerMember = TestFactory.transaction(
            ledger: ledger,
            account: account,
            category: TestFactory.category(ledger: ledger)
        )
        crossLedgerMember.member = TestFactory.member(ledger: otherLedger)
        XCTAssertThrowsError(try crossLedgerMember.validate()) { error in
            XCTAssertEqual(error as? DomainError, .crossLedgerReference)
        }

        let crossLedgerTransfer = TestFactory.transaction(
            type: .transfer,
            ledger: ledger,
            account: account,
            transferAccount: TestFactory.account(ledger: otherLedger)
        )
        XCTAssertThrowsError(try crossLedgerTransfer.validate()) { error in
            XCTAssertEqual(error as? DomainError, .crossLedgerReference)
        }
    }

}
