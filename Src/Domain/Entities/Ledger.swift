import Foundation
import SwiftData

// MARK: - 账本（情景账本）

@Model
final class Ledger {
    @Attribute(.unique) var id: UUID
    var name: String
    var iconName: String
    var colorHex: String
    var scene: String          // 生活账 / 生意账 / 旅游账 …
    var currencyCode: String   // CNY / USD …
    var createdAt: Date
    var isDefault: Bool

    @Relationship(deleteRule: .cascade, inverse: \Transaction.ledger)
    var transactions: [Transaction] = []

    @Relationship(deleteRule: .cascade, inverse: \Budget.ledger)
    var budgets: [Budget] = []

    init(name: String,
         iconName: String = "book.closed",
         colorHex: String = "#FF8A00",
         scene: String = "生活账",
         currencyCode: String = "CNY",
         isDefault: Bool = false) {
        self.id = UUID()
        self.name = name
        self.iconName = iconName
        self.colorHex = colorHex
        self.scene = scene
        self.currencyCode = currencyCode
        self.createdAt = Date()
        self.isDefault = isDefault
    }
}
