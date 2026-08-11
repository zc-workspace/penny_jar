import Foundation
import SwiftData

@Model
final class Transaction {
    @Attribute(.unique) var id: UUID
    var amount: Decimal
    var typeRawValue: String
    var occurredAt: Date
    var note: String
    var tags: [String]
    var receiptPath: String?
    var ledger: Ledger
    var account: Account
    var transferAccount: Account?
    var category: Category?
    var member: Member?

    var type: TransactionType {
        get { TransactionType(rawValue: typeRawValue) ?? .expense }
        set { typeRawValue = newValue.rawValue }
    }

    var signedAmount: Decimal {
        switch type {
        case .income:
            return amount
        case .expense:
            return -amount
        case .transfer:
            return .zero
        }
    }

    init(
        id: UUID = UUID(),
        amount: Decimal,
        type: TransactionType,
        occurredAt: Date = .now,
        note: String = "",
        tags: [String] = [],
        receiptPath: String? = nil,
        ledger: Ledger,
        account: Account,
        transferAccount: Account? = nil,
        category: Category? = nil,
        member: Member? = nil
    ) {
        self.id = id
        self.amount = amount
        self.typeRawValue = type.rawValue
        self.occurredAt = occurredAt
        self.note = note
        self.tags = tags
        self.receiptPath = receiptPath
        self.ledger = ledger
        self.account = account
        self.transferAccount = transferAccount
        self.category = category
        self.member = member
    }

    func validate() throws {
        guard amount > .zero, amount.isFinite else {
            throw DomainError.invalidAmount
        }
        try validateReferences()
        try validateTypeRules()
    }

    private func validateReferences() throws {
        guard account.ledger.id == ledger.id else {
            throw DomainError.crossLedgerReference
        }
        if let transferAccount, transferAccount.ledger.id != ledger.id {
            throw DomainError.crossLedgerReference
        }
        if let category, category.ledger.id != ledger.id {
            throw DomainError.crossLedgerReference
        }
        if let member, member.ledger.id != ledger.id {
            throw DomainError.crossLedgerReference
        }
    }

    private func validateTypeRules() throws {
        switch type {
        case .transfer:
            guard transferAccount != nil else {
                throw DomainError.missingTransferAccount
            }
            guard transferAccount?.id != account.id else {
                throw DomainError.sameTransferAccount
            }
            guard category == nil else {
                throw DomainError.invalidTransactionCategory
            }
        case .expense:
            guard category?.type == .expense else {
                throw DomainError.invalidTransactionCategory
            }
        case .income:
            guard category?.type == .income else {
                throw DomainError.invalidTransactionCategory
            }
        }
    }
}
