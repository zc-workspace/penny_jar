import Foundation
import SwiftData

@Model
final class Ledger {
    @Attribute(.unique) var id: UUID
    var name: String
    var currencyCode: String
    var isDefault: Bool
    var createdAt: Date

    @Relationship(deleteRule: .cascade, inverse: \Account.ledger)
    var accounts: [Account] = []
    @Relationship(deleteRule: .cascade, inverse: \Category.ledger)
    var categories: [Category] = []
    @Relationship(deleteRule: .cascade, inverse: \Member.ledger)
    var members: [Member] = []
    @Relationship(deleteRule: .cascade, inverse: \Transaction.ledger)
    var transactions: [Transaction] = []
    @Relationship(deleteRule: .cascade, inverse: \Budget.ledger)
    var budgets: [Budget] = []

    init(
        id: UUID = UUID(),
        name: String,
        currencyCode: String = "CNY",
        isDefault: Bool = false,
        createdAt: Date = .now
    ) {
        self.id = id
        self.name = name
        self.currencyCode = currencyCode
        self.isDefault = isDefault
        self.createdAt = createdAt
    }

    func validate() throws {
        guard !name.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty else {
            throw DomainError.emptyName
        }
        guard currencyCode.count == 3, currencyCode == currencyCode.uppercased() else {
            throw DomainError.invalidCurrencyCode
        }
    }
}
