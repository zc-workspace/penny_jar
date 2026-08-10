import SwiftUI
import SwiftData

/// 流水 —— 按日分组、可搜索、可筛选类型,支持滑动删除与点击编辑
struct TransactionsView: View {
    @Environment(\.modelContext) private var context
    @Query(sort: \Transaction.date, order: .reverse) private var transactions: [Transaction]

    @State private var searchText = ""
    @State private var filterType: TransactionType? = nil
    @State private var editing: Transaction?

    private var filtered: [Transaction] {
        transactions.filter { t in
            (filterType == nil || t.type == filterType) &&
            (searchText.isEmpty ||
             t.note.localizedCaseInsensitiveContains(searchText) ||
             (t.category?.name.localizedCaseInsensitiveContains(searchText) ?? false) ||
             (t.projectTag?.localizedCaseInsensitiveContains(searchText) ?? false))
        }
    }

    private var grouped: [(day: Date, items: [Transaction])] {
        let dict = Dictionary(grouping: filtered) { $0.date.startOfDay }
        return dict.map { ($0.key, $0.value) }.sorted { $0.day > $1.day }
    }

    var body: some View {
        NavigationStack {
            List {
                filterBar
                ForEach(grouped, id: \.day) { group in
                    Section {
                        ForEach(group.items) { t in
                            TransactionRow(t: t)
                                .contentShape(Rectangle())
                                .onTapGesture { editing = t }
                        }
                        .onDelete { offsets in delete(offsets, in: group.items) }
                    } header: {
                        dayHeader(group.day, items: group.items)
                    }
                }
            }
            .listStyle(.insetGrouped)
            .navigationTitle("流水")
            .searchable(text: $searchText, prompt: "搜索备注 / 分类 / 项目")
            .sheet(item: $editing) { RecordView(editing: $0) }
            .overlay {
                if filtered.isEmpty {
                    ContentUnavailableView("暂无流水", systemImage: "tray",
                                           description: Text("点击底部 + 记一笔"))
                }
            }
        }
    }

    private var filterBar: some View {
        Picker("筛选", selection: $filterType) {
            Text("全部").tag(TransactionType?.none)
            ForEach(TransactionType.allCases) { Text($0.rawValue).tag(TransactionType?.some($0)) }
        }
        .pickerStyle(.segmented)
        .listRowInsets(EdgeInsets())
        .listRowBackground(Color.clear)
        .padding(.vertical, 4)
    }

    private func dayHeader(_ day: Date, items: [Transaction]) -> some View {
        let inc = items.filter { $0.type == .income }.reduce(0) { $0 + $1.amount }
        let exp = items.filter { $0.type == .expense }.reduce(0) { $0 + $1.amount }
        let df = DateFormatter(); df.dateFormat = "M月d日 EEEE"; df.locale = Locale(identifier: "zh_CN")
        return HStack {
            Text(df.string(from: day))
            Spacer()
            if inc > 0 { Text("收 \(Money.plain(inc))").foregroundStyle(.green) }
            if exp > 0 { Text("支 \(Money.plain(exp))").foregroundStyle(.orange) }
        }
        .font(.caption)
    }

    private func delete(_ offsets: IndexSet, in items: [Transaction]) {
        for i in offsets { context.delete(items[i]) }
        try? context.save()
    }
}

struct TransactionRow: View {
    let t: Transaction

    var body: some View {
        HStack(spacing: 12) {
            if t.type == .transfer {
                CategoryIcon(systemName: "arrow.left.arrow.right", colorHex: "#4A90D9", size: 40)
            } else if let c = t.category {
                CategoryIcon(systemName: c.iconName, colorHex: c.colorHex, size: 40)
            } else {
                CategoryIcon(systemName: "questionmark", colorHex: "#8E8E93", size: 40)
            }
            VStack(alignment: .leading, spacing: 3) {
                Text(title).font(.body)
                HStack(spacing: 6) {
                    if let a = t.account { Text(a.name) }
                    if t.type == .transfer, let to = t.toAccount { Text("→ \(to.name)") }
                    if let p = t.projectTag { Text("· \(p)") }
                }
                .font(.caption).foregroundStyle(.secondary)
            }
            Spacer()
            Text(amountText)
                .font(.system(.body, design: .rounded).bold())
                .foregroundStyle(t.type.tint)
        }
        .padding(.vertical, 2)
    }

    private var title: String {
        if t.type == .transfer { return "转账" }
        if !t.note.isEmpty { return t.note }
        return t.category?.name ?? "未分类"
    }

    private var amountText: String {
        let prefix = t.type == .expense ? "-" : (t.type == .income ? "+" : "")
        return prefix + Money.plain(t.amount)
    }
}
