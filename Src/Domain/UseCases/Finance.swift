import Foundation

// MARK: - 财务计算引擎（纯函数 UseCase，便于注入 Mock 做单元测试）

/// 集中所有账户余额、净资产、报表聚合、预算进度的核心计算逻辑。
/// 全部为无副作用的纯函数，不依赖 SwiftData / SwiftUI，可脱库测试。
enum Finance {

    /// 账户当前余额 = 初始余额 + 收入 - 支出 + 转入 - 转出
    static func balance(of account: Account, transactions: [Transaction]) -> Double {
        var bal = account.initialBalance
        for t in transactions {
            switch t.type {
            case .income:  if t.account?.id == account.id { bal += t.amount }
            case .expense: if t.account?.id == account.id { bal -= t.amount }
            case .transfer:
                if t.account?.id == account.id { bal -= t.amount }
                if t.toAccount?.id == account.id { bal += t.amount }
            }
        }
        return bal
    }

    /// 净资产 = Σ 资产账户余额 - Σ 负债账户余额(计入净资产的部分)
    static func netWorth(accounts: [Account], transactions: [Transaction]) -> (assets: Double, liabilities: Double, net: Double) {
        var assets = 0.0, liabilities = 0.0
        for a in accounts where a.includeInNetWorth {
            let b = balance(of: a, transactions: transactions)
            if a.type.isLiability { liabilities += -b } else { assets += b }
        }
        return (assets, liabilities, assets - liabilities)
    }

    /// 区间收支合计
    static func total(_ type: TransactionType, in range: ClosedRange<Date>, transactions: [Transaction]) -> Double {
        transactions
            .filter { $0.type == type && range.contains($0.date) }
            .reduce(0) { $0 + $1.amount }
    }

    /// 按分类汇总(用于饼图/报表)
    static func byCategory(_ type: TransactionType, in range: ClosedRange<Date>, transactions: [Transaction]) -> [(category: Category, amount: Double)] {
        var dict: [UUID: (Category, Double)] = [:]
        for t in transactions where t.type == type && range.contains(t.date) {
            guard let c = t.category else { continue }
            let cur = dict[c.id]?.1 ?? 0
            dict[c.id] = (c, cur + t.amount)
        }
        return dict.values.map { ($0.0, $0.1) }.sorted { $0.1 > $1.1 }
    }

    /// 按月趋势(近 n 个月的收入/支出)
    static func monthlyTrend(months: Int, transactions: [Transaction]) -> [(label: String, income: Double, expense: Double)] {
        let cal = Calendar.current
        var result: [(String, Double, Double)] = []
        let now = Date()
        for i in stride(from: months - 1, through: 0, by: -1) {
            guard let monthDate = cal.date(byAdding: .month, value: -i, to: now) else { continue }
            let start = monthDate.startOfMonth
            let end = start.endOfMonth
            let range = start...end
            let inc = total(.income, in: range, transactions: transactions)
            let exp = total(.expense, in: range, transactions: transactions)
            let df = DateFormatter(); df.dateFormat = "M月"
            result.append((df.string(from: monthDate), inc, exp))
        }
        return result
    }

    /// 预算已用金额(按当前月)
    static func budgetSpent(_ budget: Budget, transactions: [Transaction]) -> Double {
        let now = Date()
        let range: ClosedRange<Date> = budget.period == .monthly
            ? now.startOfMonth...now.endOfMonth
            : now.startOfYear...now
        return transactions
            .filter { $0.type == .expense && range.contains($0.date) &&
                (budget.category == nil || $0.category?.id == budget.category?.id) }
            .reduce(0) { $0 + $1.amount }
    }
}
