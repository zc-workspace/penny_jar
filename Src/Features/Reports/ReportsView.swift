import SwiftUI
import SwiftData

/// 报表 —— 复刻随手记「近二十种图表」的核心:饼图占比 + 分类明细 + 月/年切换
struct ReportsView: View {
    @Query private var transactions: [Transaction]
    @State private var type: TransactionType = .expense
    @State private var scope: Scope = .month

    enum Scope: String, CaseIterable, Identifiable {
        case month = "本月", year = "本年", all = "全部"
        var id: String { rawValue }
    }

    private var range: ClosedRange<Date> {
        let now = Date()
        switch scope {
        case .month: return now.startOfMonth...now.endOfMonth
        case .year:  return now.startOfYear...now
        case .all:   return Date.distantPast...Date.distantFuture
        }
    }

    private var data: [(category: Category, amount: Double)] {
        Finance.byCategory(type, in: range, transactions: transactions)
    }
    private var total: Double { data.reduce(0) { $0 + $1.amount } }

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 16) {
                    Picker("范围", selection: $scope) {
                        ForEach(Scope.allCases) { Text($0.rawValue).tag($0) }
                    }.pickerStyle(.segmented)

                    Picker("类型", selection: $type) {
                        Text("支出").tag(TransactionType.expense)
                        Text("收入").tag(TransactionType.income)
                    }.pickerStyle(.segmented)

                    if data.isEmpty {
                        ContentUnavailableView("暂无数据", systemImage: "chart.pie",
                                               description: Text("换个范围或先记几笔"))
                            .frame(height: 300)
                    } else {
                        pieCard
                        listCard
                    }
                }
                .padding()
            }
            .background(Color(.systemGroupedBackground))
            .navigationTitle("报表")
        }
    }

    private var pieCard: some View {
        Card {
            VStack(spacing: 16) {
                ZStack {
                    PieChart(slices: data.prefix(8).map {
                        .init(value: $0.amount, color: Color(hex: $0.category.colorHex), label: $0.category.name)
                    })
                    .frame(height: 200)
                    VStack {
                        Text(type == .expense ? "总支出" : "总收入").font(.caption).foregroundStyle(.secondary)
                        Text(Money.plain(total)).font(.title3.bold())
                    }
                }
            }
        }
    }

    private var listCard: some View {
        Card {
            VStack(spacing: 14) {
                ForEach(data, id: \.category.id) { item in
                    let ratio = total > 0 ? item.amount / total : 0
                    VStack(spacing: 6) {
                        HStack {
                            CategoryIcon(systemName: item.category.iconName, colorHex: item.category.colorHex, size: 30)
                            Text(item.category.name).font(.subheadline)
                            Spacer()
                            Text("\(Int(ratio * 100))%").font(.caption).foregroundStyle(.secondary)
                            Text(Money.plain(item.amount)).font(.subheadline.bold())
                        }
                        ProgressBar(value: ratio, color: Color(hex: item.category.colorHex))
                    }
                }
            }
        }
    }
}
