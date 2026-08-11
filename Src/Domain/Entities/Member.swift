import Foundation
import SwiftData

@Model
final class Member {
    @Attribute(.unique) var id: UUID
    var name: String
    var avatarSymbol: String
    var isArchived: Bool
    var ledger: Ledger

    init(
        id: UUID = UUID(),
        name: String,
        avatarSymbol: String = "person.circle",
        isArchived: Bool = false,
        ledger: Ledger
    ) {
        self.id = id
        self.name = name
        self.avatarSymbol = avatarSymbol
        self.isArchived = isArchived
        self.ledger = ledger
    }

    func validate() throws {
        guard !name.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty else {
            throw DomainError.emptyName
        }
    }
}
