import SwiftData

enum SeedData {
    static func makeDefaultLedger(in context: ModelContext) throws -> Ledger {
        let ledger = Ledger(name: "日常生活", isDefault: true)
        let cash = Account(name: "现金", type: .cash, ledger: ledger)
        let bank = Account(name: "储蓄卡", type: .bankCard, ledger: ledger)
        let food = Category(name: "餐饮", type: .expense, iconName: "fork.knife", ledger: ledger)
        let salary = Category(name: "工资", type: .income, iconName: "banknote", ledger: ledger)
        let member = Member(name: "我", ledger: ledger)
        ledger.accounts = [cash, bank]
        ledger.categories = [food, salary]
        ledger.members = [member]
        context.insert(ledger)
        try context.save()
        return ledger
    }
}
