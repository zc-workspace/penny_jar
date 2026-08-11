import Foundation

/// 账本（聚合根）：一组账户、分类、交易、预算的归属容器，对应随手记的「多账本」。
public struct Ledger: Identifiable, Equatable, Codable, Sendable {
    public let id: UUID
    /// 账本名称。
    public var name: String
    /// 记账本位币种（ISO 4217，如 CNY）。
    public var currencyCode: String
    /// 创建时间。
    public let createdAt: Date

    public init(
        id: UUID = UUID(),
        name: String,
        currencyCode: String = "CNY",
        createdAt: Date = Date()
    ) {
        self.id = id
        self.name = name
        self.currencyCode = currencyCode
        self.createdAt = createdAt
    }
}
