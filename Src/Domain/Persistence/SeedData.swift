import Foundation
import SwiftData

/// 首次启动时植入默认账本、账户、分类,复刻随手记开箱即用的体验
enum SeedData {

    static func bootstrapIfNeeded(_ context: ModelContext) {
        let ledgerCount = (try? context.fetchCount(FetchDescriptor<Ledger>())) ?? 0
        guard ledgerCount == 0 else { return }

        // 默认账本
        let life = Ledger(name: "日常生活", iconName: "house.fill", colorHex: "#FF8A00", scene: "生活账", isDefault: true)
        context.insert(life)

        // 账户
        let accounts: [Account] = [
            Account(name: "现金", type: .cash, initialBalance: 500, sortIndex: 0),
            Account(name: "招商银行卡", type: .debitCard, initialBalance: 20000, sortIndex: 1),
            Account(name: "微信钱包", type: .eWallet, initialBalance: 1200, sortIndex: 2),
            Account(name: "支付宝", type: .eWallet, initialBalance: 800, sortIndex: 3),
            Account(name: "花呗", type: .creditCard, initialBalance: 0, sortIndex: 4)
        ]
        accounts.forEach { context.insert($0) }

        // 支出分类
        let expense: [(String, String, String)] = [
            ("餐饮", "fork.knife", "#FF6B6B"),
            ("交通", "car.fill", "#4ECDC4"),
            ("购物", "bag.fill", "#FFB300"),
            ("居家", "house.fill", "#A28CFF"),
            ("娱乐", "gamecontroller.fill", "#FF8AC7"),
            ("医疗", "cross.case.fill", "#5AC8FA"),
            ("教育", "book.fill", "#34C759"),
            ("通讯", "phone.fill", "#FF9500"),
            ("旅行", "airplane", "#00C7BE"),
            ("人情", "gift.fill", "#FF375F")
        ]
        for (i, c) in expense.enumerated() {
            context.insert(Category(name: c.0, iconName: c.1, colorHex: c.2, type: .expense, sortIndex: i))
        }

        // 收入分类
        let income: [(String, String, String)] = [
            ("工资", "banknote.fill", "#34C759"),
            ("奖金", "star.fill", "#FFD60A"),
            ("兼职", "briefcase.fill", "#5AC8FA"),
            ("理财", "chart.line.uptrend.xyaxis", "#AF52DE"),
            ("红包", "gift.fill", "#FF375F"),
            ("其他", "ellipsis.circle.fill", "#8E8E93")
        ]
        for (i, c) in income.enumerated() {
            context.insert(Category(name: c.0, iconName: c.1, colorHex: c.2, type: .income, sortIndex: i))
        }

        // 成员
        context.insert(Member(name: "我", avatarColorHex: "#FF8A00"))

        // 一条月度总预算
        context.insert(Budget(amount: 6000, period: .monthly, category: nil, ledger: life))

        try? context.save()
    }

    /// 演示数据(可在「我的」里一键生成,方便预览报表)
    static func generateDemo(_ context: ModelContext) {
        let ledger = (try? context.fetch(FetchDescriptor<Ledger>()))?.first
        let expenseCats = (try? context.fetch(FetchDescriptor<Category>()))?.filter { $0.type == .expense } ?? []
        let incomeCats = (try? context.fetch(FetchDescriptor<Category>()))?.filter { $0.type == .income } ?? []
        let accounts = (try? context.fetch(FetchDescriptor<Account>())) ?? []
        guard !expenseCats.isEmpty, !accounts.isEmpty else { return }

        let cal = Calendar.current
        for dayOffset in 0..<90 {
            guard let day = cal.date(byAdding: .day, value: -dayOffset, to: Date()) else { continue }
            let count = Int.random(in: 0...3)
            for _ in 0..<count {
                let cat = expenseCats.randomElement()!
                let amount = Double(Int.random(in: 8...480))
                let t = Transaction(type: .expense,
                                    amount: amount,
                                    date: day,
                                    note: cat.name,
                                    category: cat,
                                    account: accounts.randomElement(),
                                    ledger: ledger)
                context.insert(t)
            }
            // 每月 10 号发工资
            if cal.component(.day, from: day) == 10, let salary = incomeCats.first {
                let t = Transaction(type: .income,
                                    amount: 15000,
                                    date: day,
                                    note: "工资",
                                    category: salary,
                                    account: accounts.first,
                                    ledger: ledger)
                context.insert(t)
            }
        }
        try? context.save()
    }
}
