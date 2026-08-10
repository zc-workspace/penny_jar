import XCTest
@testable import PennyJar

/// 对应 Src/Domain/UseCases/Finance.swift —— 验证余额、净资产、报表聚合、预算进度
final class FinanceTests: XCTestCase {

    // MARK: 余额计算

    func testBalanceWithIncomeExpenseAndTransfer() {
        let cash = TestFactory.account(name: "现金", type: .cash, initialBalance: 1000)
        let bank = TestFactory.account(name: "银行卡", type: .debitCard, initialBalance: 5000)

        let txs = [
            TestFactory.transaction(type: .income, amount: 2000, account: cash),   // 现金 +2000
            TestFactory.transaction(type: .expense, amount: 300, account: cash),   // 现金 -300
            TestFactory.transaction(type: .transfer, amount: 500, account: cash, toAccount: bank) // 现金 -500，银行 +500
        ]

        XCTAssertEqual(Finance.balance(of: cash, transactions: txs), 1000 + 2000 - 300 - 500, accuracy: 0.001)
        XCTAssertEqual(Finance.balance(of: bank, transactions: txs), 5000 + 500, accuracy: 0.001)
    }

    // MARK: 净资产

    func testNetWorthSubtractsLiabilities() {
        let bank = TestFactory.account(name: "银行卡", type: .debitCard, initialBalance: 10000)
        let credit = TestFactory.account(name: "信用卡", type: .creditCard, initialBalance: 0)

        // 信用卡消费 2000 → 信用卡余额 -2000 → 负债 2000
        let txs = [
            TestFactory.transaction(type: .expense, amount: 2000, account: credit)
        ]

        let result = Finance.netWorth(accounts: [bank, credit], transactions: txs)
        XCTAssertEqual(result.assets, 10000, accuracy: 0.001)
        XCTAssertEqual(result.liabilities, 2000, accuracy: 0.001)
        XCTAssertEqual(result.net, 8000, accuracy: 0.001)
    }

    func testNetWorthExcludesAccountsNotCounted() {
        let counted = TestFactory.account(initialBalance: 1000, includeInNetWorth: true)
        let excluded = TestFactory.account(initialBalance: 9999, includeInNetWorth: false)

        let result = Finance.netWorth(accounts: [counted, excluded], transactions: [])
        XCTAssertEqual(result.net, 1000, accuracy: 0.001)
    }

    // MARK: 区间合计与分类聚合

    func testTotalFiltersByTypeAndRange() {
        let now = Date()
        let inRange = now
        let outOfRange = now.addingTimeInterval(-60 * 60 * 24 * 365)

        let txs = [
            TestFactory.transaction(type: .expense, amount: 100, date: inRange),
            TestFactory.transaction(type: .expense, amount: 50, date: outOfRange),
            TestFactory.transaction(type: .income, amount: 999, date: inRange)
        ]
        let range = now.addingTimeInterval(-3600)...now.addingTimeInterval(3600)
        XCTAssertEqual(Finance.total(.expense, in: range, transactions: txs), 100, accuracy: 0.001)
    }

    func testByCategorySortsDescending() {
        let food = TestFactory.category(name: "餐饮")
        let shopping = TestFactory.category(name: "购物")
        let now = Date()
        let range = now.addingTimeInterval(-3600)...now.addingTimeInterval(3600)

        let txs = [
            TestFactory.transaction(type: .expense, amount: 100, date: now, category: food),
            TestFactory.transaction(type: .expense, amount: 300, date: now, category: shopping),
            TestFactory.transaction(type: .expense, amount: 50, date: now, category: food)
        ]

        let result = Finance.byCategory(.expense, in: range, transactions: txs)
        XCTAssertEqual(result.count, 2)
        XCTAssertEqual(result.first?.category.name, "购物")   // 300 排最前
        XCTAssertEqual(result.first?.amount, 300, accuracy: 0.001)
        XCTAssertEqual(result.last?.amount, 150, accuracy: 0.001) // 餐饮 100+50
    }

    // MARK: 预算进度

    func testBudgetSpentOnlyCountsMatchingCategory() {
        let food = TestFactory.category(name: "餐饮")
        let other = TestFactory.category(name: "购物")
        let budget = Budget(amount: 1000, period: .monthly, category: food)

        let now = Date()
        let txs = [
            TestFactory.transaction(type: .expense, amount: 200, date: now, category: food),
            TestFactory.transaction(type: .expense, amount: 500, date: now, category: other)
        ]
        XCTAssertEqual(Finance.budgetSpent(budget, transactions: txs), 200, accuracy: 0.001)
    }
}
