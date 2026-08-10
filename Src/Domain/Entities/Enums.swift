import Foundation
import SwiftUI

// MARK: - 交易类型

/// 交易类型：支出 / 收入 / 转账 —— 对应随手记「记一笔」的三个维度
enum TransactionType: String, Codable, CaseIterable, Identifiable, Sendable {
    case expense = "支出"
    case income = "收入"
    case transfer = "转账"

    var id: String { rawValue }

    var tint: Color {
        switch self {
        case .expense: return .orange
        case .income: return .green
        case .transfer: return .blue
        }
    }

    /// 对余额的影响方向（转账在 Transaction 内单独处理）
    var sign: Double {
        switch self {
        case .expense: return -1
        case .income: return 1
        case .transfer: return 0
        }
    }
}

// MARK: - 账户类型

/// 账户类型：现金 / 银行卡 / 信用卡 / 储蓄 / 投资 / 应收应付
enum AccountType: String, Codable, CaseIterable, Identifiable, Sendable {
    case cash = "现金"
    case debitCard = "储蓄卡"
    case creditCard = "信用卡"
    case eWallet = "电子钱包"
    case investment = "投资"
    case receivable = "应收/应付"

    var id: String { rawValue }

    var icon: String {
        switch self {
        case .cash: return "banknote"
        case .debitCard: return "creditcard"
        case .creditCard: return "creditcard.fill"
        case .eWallet: return "wallet.pass"
        case .investment: return "chart.line.uptrend.xyaxis"
        case .receivable: return "arrow.left.arrow.right"
        }
    }

    /// 信用卡属于负债类账户
    var isLiability: Bool { self == .creditCard }
}

// MARK: - 预算周期

enum BudgetPeriod: String, Codable, CaseIterable, Identifiable, Sendable {
    case monthly = "每月"
    case yearly = "每年"
    var id: String { rawValue }
}
