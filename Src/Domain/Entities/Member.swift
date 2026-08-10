import Foundation
import SwiftData

// MARK: - 成员（多人账本）

@Model
final class Member {
    @Attribute(.unique) var id: UUID
    var name: String
    var avatarColorHex: String

    init(name: String, avatarColorHex: String = "#4A90D9") {
        self.id = UUID()
        self.name = name
        self.avatarColorHex = avatarColorHex
    }
}
