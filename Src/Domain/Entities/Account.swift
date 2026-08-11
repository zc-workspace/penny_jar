import Foundation
import SwiftData

@Model
final class Account {
    @Attribute(.unique) var id: UUID
    var name: String
    var typeRawValue: String
    var openingBalance: Decimal
    var isArchived: Bool
    var createdAt: Date
    var ledger: Ledger

    var type: AccountType {
        get { AccountType(rawValue: typeRawValue) ?? .cash }
        set { typeRawValue = newValue.rawValue }
    }

    init(
        id: UUID = UUID(),
        name: String,
        type: AccountType,
        openingBalance: Decimal = .zero,
        isArchived: Bool = false,
        createdAt: Date = .now,
        ledger: Ledger
    ) {
        self.id = id
        self.name = name
        self.typeRawValue = type.rawValue
        self.openingBalance = openingBalance
        self.isArchived = isArchived
        self.createdAt = createdAt
        self.ledger = ledger
    }

    func validate() throws {
        guard !name.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty else {
            throw DomainError.emptyName
        }
        guard openingBalance.isFinite else {
            throw DomainError.invalidAmount
        }
    }
}
