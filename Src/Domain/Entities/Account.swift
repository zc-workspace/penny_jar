import Foundation

/// 账户：现金、储蓄卡、信用卡、投资等。
public struct Account: Identifiable, Equatable, Codable, Sendable {
    public let id: UUID
    /// 所属账本。
    public var ledgerID: UUID
    public var name: String
    public var type: AccountType
    /// 初始余额（建账时的期初金额）。
    public var initialBalance: Double
    /// 是否计入净资产统计。
    public var includeInNetWorth: Bool

    public init(
        id: UUID = UUID(),
        ledgerID: UUID,
        name: String,
        type: AccountType = .debitCard,
        initialBalance: Double = 0,
        includeInNetWorth: Bool = true
    ) {
        self.id = id
        self.ledgerID = ledgerID
        self.name = name
        self.type = type
        self.initialBalance = initialBalance
        self.includeInNetWorth = includeInNetWorth
    }
}
