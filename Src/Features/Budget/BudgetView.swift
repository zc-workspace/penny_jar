import SwiftUI
import SwiftData

/// 预算 —— 总预算 + 分类预算,超支提醒
struct BudgetView: View {
    @Environment(\.modelContext) private var context
    @Query private var budgets: [Budget]
    @Query private var transactions: [Transaction]
    @Query(sort: \Category.sortIndex) private var categories: [Category]
    @Query private var ledgers: [Ledger]

    @State private var showAdd = false

    var body: some View {
        List {
            ForEach(budgets) { b in
                let spent = Finance.budgetSpent(b, transactions: transactions)
                let ratio = b.amount > 0 ? spent / b.amount : 0
                VStack(alignment: .leading, spacing: 8) {
                    HStack {
                        Text(b.category?.name ?? "总预算").font(.headline)
                        Text(b.period.rawValue).font(.caption).foregroundStyle(.secondary)
                        Spacer()
                        Text("\(Money.plain(spent)) / \(Money.plain(b.amount))")
                            .font(.caption)
                    }
                    ProgressBar(value: ratio, color: ratio > 1 ? .red : Color(hex: "#FF8A00"), height: 10)
                    Text(ratio > 1 ? "⚠️ 已超支 \(Money.plain(spent - b.amount))"
                                   : "剩余 \(Money.plain(b.amount - spent))")
                        .font(.caption)
                        .foregroundStyle(ratio > 1 ? .red : .secondary)
                }
                .padding(.vertical, 4)
            }
            .onDelete { offsets in
                for i in offsets { context.delete(budgets[i]) }
                try? context.save()
            }
        }
        .navigationTitle("预算")
        .toolbar { Button { showAdd = true } label: { Image(systemName: "plus") } }
        .sheet(isPresented: $showAdd) {
            AddBudgetView(categories: categories.filter { $0.type == .expense },
                          ledger: ledgers.first)
        }
        .overlay {
            if budgets.isEmpty {
                ContentUnavailableView("还没有预算", systemImage: "chart.bar",
                                       description: Text("点右上角 + 设定预算"))
            }
        }
    }
}

struct AddBudgetView: View {
    @Environment(\.modelContext) private var context
    @Environment(\.dismiss) private var dismiss
    let categories: [Category]
    let ledger: Ledger?

    @State private var amount = ""
    @State private var period: BudgetPeriod = .monthly
    @State private var category: Category? = nil

    var body: some View {
        NavigationStack {
            Form {
                TextField("预算金额", text: $amount).keyboardType(.decimalPad)
                Picker("周期", selection: $period) {
                    ForEach(BudgetPeriod.allCases) { Text($0.rawValue).tag($0) }
                }
                Picker("分类", selection: $category) {
                    Text("总预算").tag(Category?.none)
                    ForEach(categories) { c in Text(c.name).tag(Category?.some(c)) }
                }
            }
            .navigationTitle("新增预算")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) { Button("取消") { dismiss() } }
                ToolbarItem(placement: .confirmationAction) {
                    Button("保存") {
                        guard let a = Double(amount), a > 0 else { return }
                        context.insert(Budget(amount: a, period: period, category: category, ledger: ledger))
                        try? context.save(); dismiss()
                    }
                }
            }
        }
    }
}
