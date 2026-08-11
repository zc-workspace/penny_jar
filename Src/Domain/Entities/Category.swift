import Foundation

/// 收支分类，支持一级 parent 自引用形成两级分类。
public struct Category: Identifiable, Equatable, Codable, Sendable {
    public let id: UUID
    public var ledgerID: UUID
    public var name: String
    /// 图标名（SF Symbol 名称，Domain 层仅存字符串）。
    public var iconName: String
    /// 颜色值（十六进制，如 #FF6B6B）。
    public var colorHex: String
    /// 分类适用的交易类型（支出/收入）。
    public var type: TransactionType
    /// 父分类 ID；nil 表示一级分类。
    public var parentID: UUID?

    public init(
        id: UUID = UUID(),
        ledgerID: UUID,
        name: String,
        iconName: String = "tag",
        colorHex: String = "#4ECDC4",
        type: TransactionType = .expense,
        parentID: UUID? = nil
    ) {
        self.id = id
        self.ledgerID = ledgerID
        self.name = name
        self.iconName = iconName
        self.colorHex = colorHex
        self.type = type
        self.parentID = parentID
    }

    /// 是否为一级分类。
    public var isRoot: Bool { parentID == nil }
}
