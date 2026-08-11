import Foundation

/// 成员：多人记账场景下的账本成员。
public struct Member: Identifiable, Equatable, Codable, Sendable {
    public let id: UUID
    public var ledgerID: UUID
    public var name: String
    /// 头像颜色（十六进制）。
    public var avatarColorHex: String

    public init(
        id: UUID = UUID(),
        ledgerID: UUID,
        name: String,
        avatarColorHex: String = "#5B8FF9"
    ) {
        self.id = id
        self.ledgerID = ledgerID
        self.name = name
        self.avatarColorHex = avatarColorHex
    }
}
