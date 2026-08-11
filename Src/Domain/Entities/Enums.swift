import Foundation

enum TransactionType: String, Codable, CaseIterable, Sendable {
    case expense
    case income
    case transfer
}

enum AccountType: String, Codable, CaseIterable, Sendable {
    case cash
    case bankCard
    case creditCard
    case digitalWallet
    case investment
    case receivable
    case loan

    var isLiability: Bool {
        switch self {
        case .creditCard, .loan:
            return true
        case .cash, .bankCard, .digitalWallet, .investment, .receivable:
            return false
        }
    }
}

enum CategoryType: String, Codable, CaseIterable, Sendable {
    case expense
    case income
}

enum BudgetPeriod: String, Codable, CaseIterable, Sendable {
    case monthly
    case yearly
    case custom
}

enum DomainError: Error, Equatable, Sendable {
    case emptyName
    case invalidCurrencyCode
    case invalidAmount
    case invalidDateRange
    case invalidBudgetPeriod
    case missingTransferAccount
    case sameTransferAccount
    case invalidTransactionCategory
    case crossLedgerReference
    case entityNotFound
}
