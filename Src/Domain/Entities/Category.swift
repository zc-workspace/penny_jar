import Foundation
import SwiftData

@Model
final class Category {
    @Attribute(.unique) var id: UUID
    var name: String
    var typeRawValue: String
    var iconName: String
    var colorHex: String
    var parentID: UUID?
    var isArchived: Bool
    var ledger: Ledger

    var type: CategoryType {
        get { CategoryType(rawValue: typeRawValue) ?? .expense }
        set { typeRawValue = newValue.rawValue }
    }

    init(
        id: UUID = UUID(),
        name: String,
        type: CategoryType,
        iconName: String = "tag",
        colorHex: String = "#808080",
        parentID: UUID? = nil,
        isArchived: Bool = false,
        ledger: Ledger
    ) {
        self.id = id
        self.name = name
        self.typeRawValue = type.rawValue
        self.iconName = iconName
        self.colorHex = colorHex
        self.parentID = parentID
        self.isArchived = isArchived
        self.ledger = ledger
    }

    func validate() throws {
        guard !name.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty else {
            throw DomainError.emptyName
        }
        guard colorHex.hasPrefix("#"), colorHex.count == 7 else {
            throw DomainError.invalidCurrencyCode
        }
    }
}
