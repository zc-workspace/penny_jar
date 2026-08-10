import SwiftUI
import SwiftData
import PhotosUI
import UIKit

/// 记一笔 —— 复刻随手记核心录入:支出/收入/转账切换 + 分类九宫格 + 数字键盘 + 拍照/成员/项目
struct RecordView: View {
    @Environment(\.modelContext) private var context
    @Environment(\.dismiss) private var dismiss

    @Query(sort: \Category.sortIndex) private var categories: [Category]
    @Query(sort: \Account.sortIndex) private var accounts: [Account]
    @Query private var members: [Member]
    @Query private var ledgers: [Ledger]

    // 可选:编辑已有交易
    var editing: Transaction?

    @State private var type: TransactionType = .expense
    @State private var amountString = "0"
    @State private var selectedCategory: Category?
    @State private var selectedAccount: Account?
    @State private var toAccount: Account?
    @State private var selectedMember: Member?
    @State private var date = Date()
    @State private var note = ""
    @State private var projectTag = ""
    @State private var photoItem: PhotosPickerItem?
    @State private var photoData: Data?

    private var currentCategories: [Category] {
        categories.filter { $0.type == type }
    }

    var body: some View {
        NavigationStack {
            VStack(spacing: 0) {
                typePicker
                ScrollView {
                    VStack(spacing: 20) {
                        if type == .transfer {
                            transferSection
                        } else {
                            categoryGrid
                        }
                        detailSection
                    }
                    .padding()
                }
                Divider()
                amountDisplay
                Keypad(amount: $amountString, onDone: save)
            }
            .navigationTitle(editing == nil ? "记一笔" : "编辑")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("取消") { dismiss() }
                }
            }
            .onAppear(perform: setup)
        }
    }

    // MARK: 类型切换
    private var typePicker: some View {
        Picker("类型", selection: $type) {
            ForEach(TransactionType.allCases) { Text($0.rawValue).tag($0) }
        }
        .pickerStyle(.segmented)
        .padding()
        .onChange(of: type) { _, _ in selectedCategory = currentCategories.first }
    }

    // MARK: 分类九宫格
    private var categoryGrid: some View {
        LazyVGrid(columns: Array(repeating: GridItem(.flexible()), count: 5), spacing: 16) {
            ForEach(currentCategories) { cat in
                VStack(spacing: 6) {
                    CategoryIcon(systemName: cat.iconName, colorHex: cat.colorHex, size: 46)
                        .overlay(
                            Circle().stroke(Color(hex: cat.colorHex),
                                            lineWidth: selectedCategory?.id == cat.id ? 2 : 0)
                        )
                    Text(cat.name).font(.caption2).foregroundStyle(.secondary)
                }
                .onTapGesture { selectedCategory = cat }
            }
        }
    }

    // MARK: 转账区
    private var transferSection: some View {
        Card {
            VStack(spacing: 14) {
                accountPicker(title: "转出账户", selection: $selectedAccount)
                Divider()
                accountPicker(title: "转入账户", selection: $toAccount)
            }
        }
    }

    private func accountPicker(title: String, selection: Binding<Account?>) -> some View {
        HStack {
            Text(title).foregroundStyle(.secondary)
            Spacer()
            Menu {
                ForEach(accounts) { a in
                    Button(a.name) { selection.wrappedValue = a }
                }
            } label: {
                Text(selection.wrappedValue?.name ?? "请选择")
                    .foregroundStyle(Color(hex: "#FF8A00"))
            }
        }
    }

    // MARK: 明细(账户/日期/备注/成员/项目/照片)
    private var detailSection: some View {
        Card {
            VStack(spacing: 14) {
                if type != .transfer {
                    accountPicker(title: "账户", selection: $selectedAccount)
                    Divider()
                }
                HStack {
                    Text("日期").foregroundStyle(.secondary)
                    Spacer()
                    DatePicker("", selection: $date, displayedComponents: [.date, .hourAndMinute])
                        .labelsHidden()
                }
                Divider()
                HStack {
                    Text("备注").foregroundStyle(.secondary)
                    TextField("点此输入", text: $note).multilineTextAlignment(.trailing)
                }
                Divider()
                HStack {
                    Text("项目").foregroundStyle(.secondary)
                    TextField("如:三亚旅行", text: $projectTag).multilineTextAlignment(.trailing)
                }
                if !members.isEmpty {
                    Divider()
                    HStack {
                        Text("成员").foregroundStyle(.secondary)
                        Spacer()
                        Menu {
                            ForEach(members) { m in Button(m.name) { selectedMember = m } }
                        } label: {
                            Text(selectedMember?.name ?? "我")
                                .foregroundStyle(Color(hex: "#FF8A00"))
                        }
                    }
                }
                Divider()
                HStack {
                    Text("照片").foregroundStyle(.secondary)
                    Spacer()
                    PhotosPicker(selection: $photoItem, matching: .images) {
                        if let data = photoData, let ui = UIImage(data: data) {
                            Image(uiImage: ui).resizable().scaledToFill()
                                .frame(width: 40, height: 40).clipShape(RoundedRectangle(cornerRadius: 8))
                        } else {
                            Image(systemName: "camera.fill").foregroundStyle(Color(hex: "#FF8A00"))
                        }
                    }
                }
            }
        }
        .onChange(of: photoItem) { _, item in
            Task {
                if let data = try? await item?.loadTransferable(type: Data.self) {
                    photoData = data
                }
            }
        }
    }

    // MARK: 金额显示
    private var amountDisplay: some View {
        HStack {
            Text("¥").font(.title2).foregroundStyle(.secondary)
            Text(amountString)
                .font(.system(size: 34, weight: .semibold, design: .rounded))
                .foregroundStyle(type.tint)
            Spacer()
            if let c = selectedCategory, type != .transfer {
                Label(c.name, systemImage: c.iconName).foregroundStyle(.secondary).font(.subheadline)
            }
        }
        .padding(.horizontal)
        .padding(.vertical, 10)
    }

    // MARK: 生命周期 / 保存
    private func setup() {
        if let t = editing {
            type = t.type
            amountString = Money.plain(t.amount)
            selectedCategory = t.category
            selectedAccount = t.account
            toAccount = t.toAccount
            selectedMember = t.member
            date = t.date
            note = t.note
            projectTag = t.projectTag ?? ""
            photoData = t.photoData
        } else {
            selectedCategory = currentCategories.first
            selectedAccount = accounts.first
            selectedMember = members.first
        }
    }

    private func save() {
        let amount = Double(amountString) ?? 0
        guard amount > 0 else { dismiss(); return }
        let ledger = ledgers.first { $0.isDefault } ?? ledgers.first

        if let t = editing {
            t.type = type
            t.amount = amount
            t.category = type == .transfer ? nil : selectedCategory
            t.account = selectedAccount
            t.toAccount = type == .transfer ? toAccount : nil
            t.member = selectedMember
            t.date = date
            t.note = note
            t.projectTag = projectTag.isEmpty ? nil : projectTag
            t.photoData = photoData
        } else {
            let t = Transaction(type: type,
                                amount: amount,
                                date: date,
                                note: note,
                                category: type == .transfer ? nil : selectedCategory,
                                account: selectedAccount,
                                toAccount: type == .transfer ? toAccount : nil,
                                member: selectedMember,
                                ledger: ledger,
                                projectTag: projectTag.isEmpty ? nil : projectTag,
                                photoData: photoData)
            context.insert(t)
        }
        try? context.save()
        dismiss()
    }
}

// MARK: - 自定义数字键盘(随手记特色:自带记账键盘)
struct Keypad: View {
    @Binding var amount: String
    var onDone: () -> Void

    private let keys = [["7","8","9"],["4","5","6"],["1","2","3"],[".","0","⌫"]]

    var body: some View {
        HStack(spacing: 0) {
            VStack(spacing: 1) {
                ForEach(keys, id: \.self) { row in
                    HStack(spacing: 1) {
                        ForEach(row, id: \.self) { key in
                            Button { tap(key) } label: {
                                Text(key)
                                    .font(.title2)
                                    .frame(maxWidth: .infinity, maxHeight: .infinity)
                                    .background(Color(.systemBackground))
                            }
                            .foregroundStyle(.primary)
                        }
                    }
                }
            }
            Button(action: onDone) {
                Text("完成")
                    .font(.title3.bold())
                    .foregroundStyle(.white)
                    .frame(width: 90)
                    .frame(maxHeight: .infinity)
                    .background(Color(hex: "#FF8A00"))
            }
        }
        .frame(height: 240)
        .background(Color(.systemGroupedBackground))
    }

    private func tap(_ key: String) {
        switch key {
        case "⌫":
            amount = amount.count > 1 ? String(amount.dropLast()) : "0"
        case ".":
            if !amount.contains(".") { amount += "." }
        default:
            if amount == "0" { amount = key } else { amount += key }
            // 限制两位小数
            if let dot = amount.firstIndex(of: "."),
               amount.distance(from: dot, to: amount.endIndex) > 3 {
                amount = String(amount.dropLast())
            }
        }
    }
}
