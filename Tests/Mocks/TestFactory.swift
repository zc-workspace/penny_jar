import Foundation
@testable import PennyJar

/// 测试用工厂：快速构造脱离数据库的实体实例，供 UseCase 单元测试使用。
/// 注：SwiftData @Model 可脱离 ModelContext 直接实例化用于纯逻辑计算测试。
enum TestFactory {

    static func account(name: String = "测试账户",
                        type: AccountType = .debitCard,
                        initialBalance: Double = 0,
                        includeInNetWorth: Bool = true) -> Account {
        Account(name: name, type: type, initialBalance: initialBalance,
                includeInNetWorth: includeInNetWorth)
    }

    static func category(name: String = "餐饮",
                         type: TransactionType = .expense) -> Category {
        Category(name: name, iconName: "fork.knife", colorHex: "#FF6B6B", type: type)
    }

    static func transaction(type: TransactionType,
                            amount: Double,
                            date: Date = Date(),
                            category: Category? = nil,
                            account: Account? = nil,
                            toAccount: Account? = nil) -> Transaction {
        Transaction(type: type, amount: amount, date: date,
                    category: category, account: account, toAccount: toAccount)
    }
}
