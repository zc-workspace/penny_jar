import Foundation
import SwiftData

// MARK: - 账户

@Model
final class Account {
    @Attribute(.unique) var id: UUID
    var name: String
    var typeRaw: String
    var initialBalance: Double   // 初始余额
    var currencyCode: String
    var includeInNetWorth: Bool  // 是否计入净资产
    var sortIndex: Int
    var createdAt: Date

    var type: AccountType {
        get { AccountType(rawValue: typeRaw) ?? .cash }
        set { typeRaw = newValue.rawValue }
    }

    init(name: String,
         type: AccountType,
         initialBalance: Double = 0,
         currencyCode: String = "CNY",
         includeInNetWorth: Bool = true,
         sortIndex: Int = 0) {
        self.id = UUID()
        self.name = name
        self.typeRaw = type.rawValue
        self.initialBalance = initialBalance
        self.currencyCode = currencyCode
        self.includeInNetWorth = includeInNetWorth
        self.sortIndex = sortIndex
        self.createdAt = Date()
    }
}
