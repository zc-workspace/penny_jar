import Foundation

/// 交易类型：支出 / 收入 / 转账。
public enum TransactionType: String, Codable, CaseIterable, Sendable {
    case expense
    case income
    case transfer

    /// 对账户余额的方向系数：支出 -1，收入 +1，转账 0（转账在账户维度单独处理）。
    public var sign: Double {
        switch self {
        case .expense: return -1
        case .income: return 1
        case .transfer: return 0
        }
    }

    /// 展示用中文名。
    public var displayName: String {
        switch self {
        case .expense: return "支出"
        case .income: return "收入"
        case .transfer: return "转账"
        }
    }
}

/// 账户类型。
public enum AccountType: String, Codable, CaseIterable, Sendable {
    case cash
    case debitCard
    case creditCard
    case investment

    /// 是否为负债类账户（仅信用卡计入负债）。
    public var isLiability: Bool {
        self == .creditCard
    }

    public var displayName: String {
        switch self {
        case .cash: return "现金"
        case .debitCard: return "储蓄卡"
        case .creditCard: return "信用卡"
        case .investment: return "投资"
        }
    }
}

/// 预算周期。
public enum BudgetPeriod: String, Codable, CaseIterable, Sendable {
    case weekly
    case monthly
    case yearly

    public var displayName: String {
        switch self {
        case .weekly: return "每周"
        case .monthly: return "每月"
        case .yearly: return "每年"
        }
    }
}
