import SwiftUI
import SwiftData

/// 账户 —— 资产/负债分组展示,含净资产;支持新增账户
struct AccountsView: View {
    @Environment(\.modelContext) private var context
    @Query(sort: \Account.sortIndex) private var accounts: [Account]
    @Query private var transactions: [Transaction]
    @State private var showAdd = false

    private var assetAccounts: [Account] { accounts.filter { !$0.type.isLiability } }
    private var liabilityAccounts: [Account] { accounts.filter { $0.type.isLiability } }
    private var net: (assets: Double, liabilities: Double, net: Double) {
        Finance.netWorth(accounts: accounts, transactions: transactions)
    }

    var body: some View {
        NavigationStack {
            List {
                Section {
                    VStack(spacing: 8) {
                        Text("净资产").font(.caption).foregroundStyle(.secondary)
                        Text(Money.string(net.net))
                            .font(.system(size: 30, weight: .bold, design: .rounded))
                        HStack {
                            Text("资产 \(Money.plain(net.assets))").foregroundStyle(.green)
                            Spacer()
                            Text("负债 \(Money.plain(net.liabilities))").foregroundStyle(.red)
                        }.font(.caption)
                    }
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 8)
                }

                accountSection("资产账户", assetAccounts)
                if !liabilityAccounts.isEmpty { accountSection("负债账户", liabilityAccounts) }
            }
            .navigationTitle("账户")
            .toolbar {
                Button { showAdd = true } label: { Image(systemName: "plus") }
            }
            .sheet(isPresented: $showAdd) { AddAccountView() }
        }
    }

    private func accountSection(_ title: String, _ list: [Account]) -> some View {
        Section(title) {
            ForEach(list) { a in
                HStack {
                    CategoryIcon(systemName: a.type.icon, colorHex: "#4A90D9", size: 38)
                    VStack(alignment: .leading) {
                        Text(a.name)
                        Text(a.type.rawValue).font(.caption).foregroundStyle(.secondary)
                    }
                    Spacer()
                    Text(Money.plain(Finance.balance(of: a, transactions: transactions)))
                        .font(.system(.body, design: .rounded).bold())
                        .foregroundStyle(a.type.isLiability ? .red : .primary)
                }
            }
            .onDelete { offsets in
                for i in offsets { context.delete(list[i]) }
                try? context.save()
            }
        }
    }
}

struct AddAccountView: View {
    @Environment(\.modelContext) private var context
    @Environment(\.dismiss) private var dismiss
    @State private var name = ""
    @State private var type: AccountType = .debitCard
    @State private var balance = ""

    var body: some View {
        NavigationStack {
            Form {
                TextField("账户名称", text: $name)
                Picker("类型", selection: $type) {
                    ForEach(AccountType.allCases) { Label($0.rawValue, systemImage: $0.icon).tag($0) }
                }
                TextField("初始余额", text: $balance).keyboardType(.decimalPad)
            }
            .navigationTitle("新增账户")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) { Button("取消") { dismiss() } }
                ToolbarItem(placement: .confirmationAction) {
                    Button("保存") {
                        guard !name.isEmpty else { return }
                        let a = Account(name: name, type: type,
                                        initialBalance: Double(balance) ?? 0)
                        context.insert(a); try? context.save(); dismiss()
                    }
                }
            }
        }
    }
}
