import XCTest
@testable import PennyJarDomain

/// 对应 Src/Domain/UseCases/Finance.swift —— 余额、净资产、聚合、预算全分支覆盖。
final class FinanceTests: XCTestCase {

    private let now = Date(timeIntervalSince1970: 1_700_000_000)
    private var range: ClosedRange<Date> {
        now.addingTimeInterval(-3600)...now.addingTimeInterval(3600)
    }

    // MARK: balance —— 覆盖 income/expense/transfer(双向)/default 分支

    func test_balance_incomeExpenseAndTransfer() {
        let cash = TestFactory.account(initialBalance: 1000)
        let bank = TestFactory.account(initialBalance: 5000)
        let txs = [
            TestFactory.transaction(type: .income, amount: 2000, accountID: cash.id),
            TestFactory.transaction(type: .expense, amount: 300, accountID: cash.id),
            TestFactory.transaction(type: .transfer, amount: 500, accountID: cash.id, toAccountID: bank.id)
        ]
        XCTAssertEqual(Finance.balance(of: cash, transactions: txs), 1000 + 2000 - 300 - 500, accuracy: 0.001)
        XCTAssertEqual(Finance.balance(of: bank, transactions: txs), 5000 + 500, accuracy: 0.001)
    }

    func test_balance_ignoresUnrelatedAccountAndDefaultBranch() {
        let target = TestFactory.account(initialBalance: 100)
        let other = TestFactory.account()
        let txs = [
            // income 记到别的账户 → 命中 income 但 where 不满足 → default
            TestFactory.transaction(type: .income, amount: 999, accountID: other.id),
            // expense 记到别的账户 → 命中 expense 但 where 不满足 → default
            TestFactory.transaction(type: .expense, amount: 999, accountID: other.id)
        ]
        XCTAssertEqual(Finance.balance(of: target, transactions: txs), 100, accuracy: 0.001)
    }

    func test_balance_emptyTransactions_returnsInitial() {
        let acc = TestFactory.account(initialBalance: 42)
        XCTAssertEqual(Finance.balance(of: acc, transactions: []), 42, accuracy: 0.001)
    }

    // MARK: netWorth

    func test_netWorth_subtractsCreditCardLiability() {
        let bank = TestFactory.account(type: .debitCard, initialBalance: 10000)
        let credit = TestFactory.account(type: .creditCard, initialBalance: 0)
        let txs = [TestFactory.transaction(type: .expense, amount: 2000, accountID: credit.id)]
        let result = Finance.netWorth(accounts: [bank, credit], transactions: txs)
        XCTAssertEqual(result.assets, 10000, accuracy: 0.001)
        XCTAssertEqual(result.liabilities, 2000, accuracy: 0.001)
        XCTAssertEqual(result.net, 8000, accuracy: 0.001)
    }

    func test_netWorth_creditCardPositiveBalanceCountsAsAsset() {
        // 信用卡溢缴款：余额为正 → 计入资产而非负债
        let credit = TestFactory.account(type: .creditCard, initialBalance: 500)
        let result = Finance.netWorth(accounts: [credit], transactions: [])
        XCTAssertEqual(result.assets, 500, accuracy: 0.001)
        XCTAssertEqual(result.liabilities, 0, accuracy: 0.001)
    }

    func test_netWorth_excludesAccountsNotCounted() {
        let counted = TestFactory.account(initialBalance: 1000, includeInNetWorth: true)
        let excluded = TestFactory.account(initialBalance: 9999, includeInNetWorth: false)
        let result = Finance.netWorth(accounts: [counted, excluded], transactions: [])
        XCTAssertEqual(result.net, 1000, accuracy: 0.001)
    }

    // MARK: total

    func test_total_filtersByTypeAndRange() {
        let outOfRange = now.addingTimeInterval(-60 * 60 * 24 * 365)
        let txs = [
            TestFactory.transaction(type: .expense, amount: 100, date: now),
            TestFactory.transaction(type: .expense, amount: 50, date: outOfRange),
            TestFactory.transaction(type: .income, amount: 999, date: now)
        ]
        XCTAssertEqual(Finance.total(.expense, in: range, transactions: txs), 100, accuracy: 0.001)
    }

    func test_total_noMatches_returnsZero() {
        XCTAssertEqual(Finance.total(.income, in: range, transactions: []), 0, accuracy: 0.001)
    }

    // MARK: byCategory

    func test_byCategory_sortsDescendingAndAggregates() throws {
        let food = TestFactory.category(name: "餐饮")
        let shopping = TestFactory.category(name: "购物")
        let txs = [
            TestFactory.transaction(type: .expense, amount: 100, date: now, categoryID: food.id),
            TestFactory.transaction(type: .expense, amount: 300, date: now, categoryID: shopping.id),
            TestFactory.transaction(type: .expense, amount: 50, date: now, categoryID: food.id)
        ]
        let result = Finance.byCategory(.expense, in: range, transactions: txs)
        XCTAssertEqual(result.count, 2)
        XCTAssertEqual(result.first?.categoryID, shopping.id)   // 300 最前
        XCTAssertEqual(try XCTUnwrap(result.first).amount, 300, accuracy: 0.001)
        XCTAssertEqual(try XCTUnwrap(result.last).amount, 150, accuracy: 0.001) // 餐饮 100+50
    }

    func test_byCategory_skipsTransactionsWithoutCategory() {
        let txs = [TestFactory.transaction(type: .expense, amount: 100, date: now, categoryID: nil)]
        XCTAssertTrue(Finance.byCategory(.expense, in: range, transactions: txs).isEmpty)
    }

    func test_byCategory_equalAmounts_tieBreaksByCategoryID() {
        // 构造两个金额相同的分类，验证稳定的 id 次序分支
        let low = UUID(uuidString: "00000000-0000-0000-0000-000000000001")!
        let high = UUID(uuidString: "00000000-0000-0000-0000-0000000000FF")!
        let txs = [
            TestFactory.transaction(type: .expense, amount: 100, date: now, categoryID: high),
            TestFactory.transaction(type: .expense, amount: 100, date: now, categoryID: low)
        ]
        let result = Finance.byCategory(.expense, in: range, transactions: txs)
        XCTAssertEqual(result.map(\.categoryID), [low, high])
    }

    // MARK: budgetSpent

    func test_budgetSpent_categoryBudget_onlyMatchingCategory() {
        let food = TestFactory.category(name: "餐饮")
        let other = TestFactory.category(name: "购物")
        let budget = TestFactory.budget(amount: 1000, categoryID: food.id)
        let txs = [
            TestFactory.transaction(type: .expense, amount: 200, date: now, categoryID: food.id),
            TestFactory.transaction(type: .expense, amount: 500, date: now, categoryID: other.id)
        ]
        XCTAssertEqual(Finance.budgetSpent(budget, in: range, transactions: txs), 200, accuracy: 0.001)
    }

    func test_budgetSpent_overallBudget_countsAllExpenses() {
        let food = TestFactory.category(name: "餐饮")
        let budget = TestFactory.budget(amount: 1000, categoryID: nil)
        let txs = [
            TestFactory.transaction(type: .expense, amount: 200, date: now, categoryID: food.id),
            TestFactory.transaction(type: .expense, amount: 500, date: now, categoryID: nil),
            TestFactory.transaction(type: .income, amount: 999, date: now) // 收入不计
        ]
        XCTAssertEqual(Finance.budgetSpent(budget, in: range, transactions: txs), 700, accuracy: 0.001)
    }

    // MARK: budgetProgress —— 覆盖 amount<=0 守卫 与 正常分支

    func test_budgetProgress_zeroAmount_returnsZero() {
        let budget = TestFactory.budget(amount: 0)
        let txs = [TestFactory.transaction(type: .expense, amount: 100, date: now)]
        XCTAssertEqual(Finance.budgetProgress(budget, in: range, transactions: txs), 0, accuracy: 0.001)
    }

    func test_budgetProgress_normal_computesRatio() {
        let budget = TestFactory.budget(amount: 1000, categoryID: nil)
        let txs = [TestFactory.transaction(type: .expense, amount: 250, date: now)]
        XCTAssertEqual(Finance.budgetProgress(budget, in: range, transactions: txs), 0.25, accuracy: 0.001)
    }

    func test_budgetProgress_overspend_exceedsOne() {
        let budget = TestFactory.budget(amount: 100, categoryID: nil)
        let txs = [TestFactory.transaction(type: .expense, amount: 150, date: now)]
        XCTAssertEqual(Finance.budgetProgress(budget, in: range, transactions: txs), 1.5, accuracy: 0.001)
    }

    // MARK: 结果结构体

    func test_netWorth_struct_netComputed() {
        let nw = NetWorth(assets: 300, liabilities: 120)
        XCTAssertEqual(nw.net, 180, accuracy: 0.001)
    }

    func test_categoryTotal_equatable() {
        let id = UUID()
        XCTAssertEqual(CategoryTotal(categoryID: id, amount: 10),
                       CategoryTotal(categoryID: id, amount: 10))
    }
}
