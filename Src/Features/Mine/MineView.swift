import SwiftUI
import SwiftData
import UniformTypeIdentifiers
import UIKit

/// 我的 —— 入口聚合:账本/账户/预算/成员/分类,数据导出 CSV、生成演示数据
struct MineView: View {
    @Environment(\.modelContext) private var context
    @Query private var transactions: [Transaction]
    @Query private var members: [Member]
    @State private var showExport = false
    @State private var exportURL: URL?

    var body: some View {
        NavigationStack {
            List {
                Section {
                    NavigationLink { BooksView() } label: { row("我的账本", "book.closed.fill", "#FF8A00") }
                    NavigationLink { AccountsView() } label: { row("账户管理", "creditcard.fill", "#4A90D9") }
                    NavigationLink { BudgetView() } label: { row("预算", "chart.bar.fill", "#34C759") }
                    NavigationLink { MembersView() } label: { row("成员", "person.2.fill", "#AF52DE") }
                    NavigationLink { CategoriesView() } label: { row("分类管理", "square.grid.2x2.fill", "#FF8AC7") }
                }

                Section("数据") {
                    Button { exportCSV() } label: { row("导出 CSV", "square.and.arrow.up", "#5AC8FA") }
                    Button { SeedData.generateDemo(context) } label: { row("生成演示数据", "wand.and.stars", "#FFB300") }
                }

                Section {
                    HStack {
                        Text("流水总数"); Spacer()
                        Text("\(transactions.count) 笔").foregroundStyle(.secondary)
                    }
                }

                Section {
                    Text("penny_jar · SwiftUI + SwiftData\n本地存储,数据不出设备")
                        .font(.caption).foregroundStyle(.secondary)
                }
            }
            .navigationTitle("我的")
            .sheet(isPresented: $showExport) {
                if let url = exportURL { ShareSheet(items: [url]) }
            }
        }
    }

    private func row(_ title: String, _ icon: String, _ color: String) -> some View {
        HStack {
            CategoryIcon(systemName: icon, colorHex: color, size: 32)
            Text(title)
        }
    }

    private func exportCSV() {
        let csv = CSVExporter.makeCSV(from: transactions)
        guard let url = CSVExporter.writeTempFile(csv) else { return }
        exportURL = url
        showExport = true
    }
}

// 成员管理
struct MembersView: View {
    @Environment(\.modelContext) private var context
    @Query private var members: [Member]
    @State private var newName = ""

    var body: some View {
        List {
            Section("添加成员") {
                HStack {
                    TextField("成员姓名", text: $newName)
                    Button("添加") {
                        guard !newName.isEmpty else { return }
                        context.insert(Member(name: newName)); try? context.save(); newName = ""
                    }
                }
            }
            Section("成员列表") {
                ForEach(members) { m in
                    HStack {
                        Circle().fill(Color(hex: m.avatarColorHex)).frame(width: 28, height: 28)
                            .overlay(Text(String(m.name.prefix(1))).font(.caption).foregroundStyle(.white))
                        Text(m.name)
                    }
                }
                .onDelete { offsets in
                    for i in offsets { context.delete(members[i]) }; try? context.save()
                }
            }
        }
        .navigationTitle("成员")
    }
}

// 分类管理
struct CategoriesView: View {
    @Environment(\.modelContext) private var context
    @Query(sort: \Category.sortIndex) private var categories: [Category]
    @State private var type: TransactionType = .expense
    @State private var newName = ""

    var body: some View {
        List {
            Picker("类型", selection: $type) {
                Text("支出").tag(TransactionType.expense)
                Text("收入").tag(TransactionType.income)
            }.pickerStyle(.segmented)

            Section("新增分类") {
                HStack {
                    TextField("分类名称", text: $newName)
                    Button("添加") {
                        guard !newName.isEmpty else { return }
                        let idx = categories.filter { $0.type == type }.count
                        context.insert(Category(name: newName, iconName: "tag.fill",
                                                colorHex: "#8E8E93", type: type, sortIndex: idx))
                        try? context.save(); newName = ""
                    }
                }
            }

            ForEach(categories.filter { $0.type == type }) { c in
                HStack {
                    CategoryIcon(systemName: c.iconName, colorHex: c.colorHex, size: 32)
                    Text(c.name)
                }
            }
            .onDelete { offsets in
                let list = categories.filter { $0.type == type }
                for i in offsets { context.delete(list[i]) }; try? context.save()
            }
        }
        .navigationTitle("分类管理")
    }
}
