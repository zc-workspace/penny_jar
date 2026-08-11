import Foundation

/// 分类聚合结果。
public struct CategoryTotal: Equatable, Sendable {
    public let categoryID: UUID
    public let amount: Double
    public init(categoryID: UUID, amount: Double) {
        self.categoryID = categoryID
        self.amount = amount
    }
}

/// 净资产结果。
public struct NetWorth: Equatable, Sendable {
    public let assets: Double
    public let liabilities: Double
    public var net: Double { assets - liabilities }
    public init(assets: Double, liabilities: Double) {
        self.assets = assets
        self.liabilities = liabilities
    }
}

/// 纯函数财务计算引擎，不依赖 UI 与持久化。
public enum Finance {

    /// 计算某账户的当前余额 = 期初 + 收入 - 支出 + 转入 - 转出。
    public static func balance(of account: Account, transactions: [Transaction]) -> Double {
        var balance = account.initialBalance
        for tx in transactions {
            switch tx.type {
            case .income where tx.accountID == account.id:
                balance += tx.amount
            case .expense where tx.accountID == account.id:
                balance -= tx.amount
            case .transfer:
                if tx.accountID == account.id { balance -= tx.amount }
                if tx.toAccountID == account.id { balance += tx.amount }
            default:
                break
            }
        }
        return balance
    }

    /// 计算净资产：资产账户余额之和 - 负债账户余额之绝对值；仅统计 includeInNetWorth 账户。
    public static func netWorth(accounts: [Account], transactions: [Transaction]) -> NetWorth {
        var assets = 0.0
        var liabilities = 0.0
        for account in accounts where account.includeInNetWorth {
            let bal = balance(of: account, transactions: transactions)
            if account.type.isLiability {
                // 信用卡：余额为负代表欠款，负债取其绝对值。
                liabilities += max(0, -bal)
                assets += max(0, bal)
            } else {
                assets += bal
            }
        }
        return NetWorth(assets: assets, liabilities: liabilities)
    }

    /// 指定类型在时间区间内的合计金额。
    public static func total(
        _ type: TransactionType,
        in range: ClosedRange<Date>,
        transactions: [Transaction]
    ) -> Double {
        transactions
            .filter { $0.type == type && range.contains($0.date) }
            .reduce(0) { $0 + $1.amount }
    }

    /// 按分类聚合指定类型在区间内的金额，按金额降序返回。
    public static func byCategory(
        _ type: TransactionType,
        in range: ClosedRange<Date>,
        transactions: [Transaction]
    ) -> [CategoryTotal] {
        var sums: [UUID: Double] = [:]
        for tx in transactions
        where tx.type == type && range.contains(tx.date) {
            guard let cid = tx.categoryID else { continue }
            sums[cid, default: 0] += tx.amount
        }
        return sums
            .map { CategoryTotal(categoryID: $0.key, amount: $0.value) }
            .sorted { lhs, rhs in
                if lhs.amount == rhs.amount {
                    return lhs.categoryID.uuidString < rhs.categoryID.uuidString
                }
                return lhs.amount > rhs.amount
            }
    }

    /// 某预算已花费金额：匹配分类（总预算则统计全部支出）在其周期区间内的支出合计。
    public static func budgetSpent(
        _ budget: Budget,
        in range: ClosedRange<Date>,
        transactions: [Transaction]
    ) -> Double {
        transactions
            .filter { tx in
                tx.type == .expense
                    && range.contains(tx.date)
                    && (budget.categoryID == nil || tx.categoryID == budget.categoryID)
            }
            .reduce(0) { $0 + $1.amount }
    }

    /// 预算使用进度（0...1，可超过 1 表示超支）；预算金额 <= 0 返回 0 避免除零。
    public static func budgetProgress(
        _ budget: Budget,
        in range: ClosedRange<Date>,
        transactions: [Transaction]
    ) -> Double {
        guard budget.amount > 0 else { return 0 }
        return budgetSpent(budget, in: range, transactions: transactions) / budget.amount
    }
}
