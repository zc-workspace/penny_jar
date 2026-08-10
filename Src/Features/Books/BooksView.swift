import SwiftUI
import SwiftData

/// 账本 —— 复刻随手记「情景账本」:生活/生意/旅游/结婚/宝宝/装修/汽车/多人
struct BooksView: View {
    @Environment(\.modelContext) private var context
    @Query(sort: \Ledger.createdAt) private var ledgers: [Ledger]
    @State private var showAdd = false

    var body: some View {
        List {
            ForEach(ledgers) { l in
                HStack {
                    CategoryIcon(systemName: l.iconName, colorHex: l.colorHex, size: 40)
                    VStack(alignment: .leading) {
                        HStack {
                            Text(l.name)
                            if l.isDefault {
                                Text("默认").font(.caption2).padding(.horizontal, 6).padding(.vertical, 2)
                                    .background(Color(hex: "#FF8A00").opacity(0.15))
                                    .foregroundStyle(Color(hex: "#FF8A00")).clipShape(Capsule())
                            }
                        }
                        Text("\(l.scene) · \(l.transactions.count) 笔").font(.caption).foregroundStyle(.secondary)
                    }
                    Spacer()
                    if !l.isDefault {
                        Button("设为默认") { setDefault(l) }.font(.caption).buttonStyle(.borderless)
                    }
                }
            }
            .onDelete { offsets in
                for i in offsets where !ledgers[i].isDefault { context.delete(ledgers[i]) }
                try? context.save()
            }
        }
        .navigationTitle("我的账本")
        .toolbar { Button { showAdd = true } label: { Image(systemName: "plus") } }
        .sheet(isPresented: $showAdd) { AddBookView() }
    }

    private func setDefault(_ l: Ledger) {
        ledgers.forEach { $0.isDefault = false }
        l.isDefault = true
        try? context.save()
    }
}

struct AddBookView: View {
    @Environment(\.modelContext) private var context
    @Environment(\.dismiss) private var dismiss
    @State private var selected = 0

    // 情景账本模板
    private let templates: [(name: String, icon: String, color: String, scene: String)] = [
        ("生活账", "house.fill", "#FF8A00", "生活账"),
        ("生意账", "storefront.fill", "#34C759", "生意账"),
        ("旅游账", "airplane", "#00C7BE", "旅游账"),
        ("结婚账", "heart.fill", "#FF375F", "结婚账"),
        ("宝宝账", "figure.child", "#FF8AC7", "宝宝账"),
        ("装修账", "hammer.fill", "#FFB300", "装修账"),
        ("汽车账", "car.fill", "#4A90D9", "汽车账"),
        ("多人账", "person.3.fill", "#AF52DE", "多人账")
    ]
    @State private var name = ""

    var body: some View {
        NavigationStack {
            Form {
                Section("选择情景模板") {
                    LazyVGrid(columns: Array(repeating: GridItem(.flexible()), count: 4), spacing: 16) {
                        ForEach(templates.indices, id: \.self) { i in
                            VStack(spacing: 6) {
                                CategoryIcon(systemName: templates[i].icon, colorHex: templates[i].color, size: 46)
                                    .overlay(Circle().stroke(Color(hex: templates[i].color),
                                                             lineWidth: selected == i ? 2 : 0))
                                Text(templates[i].name).font(.caption2)
                            }
                            .onTapGesture { selected = i; name = templates[i].name }
                        }
                    }
                    .padding(.vertical, 8)
                }
                Section("账本名称") {
                    TextField(templates[selected].name, text: $name)
                }
            }
            .navigationTitle("新建账本")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) { Button("取消") { dismiss() } }
                ToolbarItem(placement: .confirmationAction) {
                    Button("创建") {
                        let t = templates[selected]
                        let finalName = name.isEmpty ? t.name : name
                        context.insert(Ledger(name: finalName, iconName: t.icon,
                                              colorHex: t.color, scene: t.scene))
                        try? context.save(); dismiss()
                    }
                }
            }
            .onAppear { name = templates[selected].name }
        }
    }
}
