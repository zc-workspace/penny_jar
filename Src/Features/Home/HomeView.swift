import SwiftUI
import SwiftData

/// 首页即报表 —— 复刻随手记「首页数据卡片 + 图表」概览
struct HomeView: View {
    @Environment(\.modelContext) private var context
    @Query private var transactions: [Transaction]
    @Query(sort: \Account.sortIndex) private var accounts: [Account]
    @Query private var budgets: [Budget]
    @Query private var ledgers: [Ledger]

    private var now = Date()

    private var monthRange: ClosedRange<Date> { now.startOfMonth...now.endOfMonth }
    private var monthExpense: Double { Finance.total(.expense, in: monthRange, transactions: transactions) }
    private var monthIncome: Double { Finance.total(.income, in: monthRange, transactions: transactions) }
    private var netWorth: (assets: Double, liabilities: Double, net: Double) {
        Finance.netWorth(accounts: accounts, transactions: transactions)
    }

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 16) {
                    monthCard
                    netWorthCard
                    if let b = totalBudget { budgetCard(b) }
                    topCategoriesCard
                    trendCard
                }
                .padding()
            }
            .background(Color(.systemGroupedBackground))
            .navigationTitle(ledgers.first(where: { $0.isDefault })?.name ?? "随手记")
        }
    }

    // 本月收支卡
    private var monthCard: some View {
        Card {
            VStack(alignment: .leading, spacing: 12) {
                Text("本月 · \(monthTitle)").font(.subheadline).foregroundStyle(.secondary)
                HStack {
                    stat("支出", monthExpense, .orange)
                    Divider().frame(height: 40)
                    stat("收入", monthIncome, .green)
                    Divider().frame(height: 40)
                    stat("结余", monthIncome - monthExpense, .blue)
                }
            }
        }
    }

    private func stat(_ title: String, _ value: Double, _ color: Color) -> some View {
        VStack(spacing: 4) {
            Text(title).font(.caption).foregroundStyle(.secondary)
            Text(Money.plain(value))
                .font(.system(.title3, design: .rounded).bold())
                .foregroundStyle(color)
        }
        .frame(maxWidth: .infinity)
    }

    // 净资产卡
    private var netWorthCard: some View {
        NavigationLink { AccountsView() } label: {
            Card {
                VStack(alignment: .leading, spacing: 12) {
                    HStack {
                        Text("净资产").font(.subheadline).foregroundStyle(.secondary)
                        Spacer()
                        Image(systemName: "chevron.right").font(.caption).foregroundStyle(.tertiary)
                    }
                    Text(Money.string(netWorth.net))
                        .font(.system(size: 30, weight: .bold, design: .rounded))
                    HStack {
                        Label("资产 \(Money.plain(netWorth.assets))", systemImage: "arrow.up.circle.fill")
                            .foregroundStyle(.green).font(.caption)
                        Spacer()
                        Label("负债 \(Money.plain(netWorth.liabilities))", systemImage: "arrow.down.circle.fill")
                            .foregroundStyle(.red).font(.caption)
                    }
                }
            }
        }
        .buttonStyle(.plain)
    }

    private var totalBudget: Budget? { budgets.first { $0.category == nil } }

    // 预算卡
    private func budgetCard(_ b: Budget) -> some View {
        let spent = Finance.budgetSpent(b, transactions: transactions)
        let ratio = b.amount > 0 ? spent / b.amount : 0
        return Card {
            VStack(alignment: .leading, spacing: 10) {
                HStack {
                    Text("本月预算").font(.subheadline).foregroundStyle(.secondary)
                    Spacer()
                    Text("\(Money.plain(spent)) / \(Money.plain(b.amount))")
                        .font(.caption).foregroundStyle(.secondary)
                }
                ProgressBar(value: ratio, color: ratio > 1 ? .red : Color(hex: "#FF8A00"), height: 10)
                Text(ratio > 1 ? "已超支 \(Money.plain(spent - b.amount))" : "剩余 \(Money.plain(b.amount - spent))")
                    .font(.caption)
                    .foregroundStyle(ratio > 1 ? .red : .secondary)
            }
        }
    }

    // 支出 TOP 分类
    private var topCategoriesCard: some View {
        let data = Finance.byCategory(.expense, in: monthRange, transactions: transactions).prefix(5)
        return Card {
            VStack(alignment: .leading, spacing: 12) {
                Text("支出排行").font(.subheadline).foregroundStyle(.secondary)
                if data.isEmpty {
                    Text("本月还没有支出记录").font(.footnote).foregroundStyle(.tertiary)
                } else {
                    ForEach(Array(data), id: \.category.id) { item in
                        HStack {
                            CategoryIcon(systemName: item.category.iconName, colorHex: item.category.colorHex, size: 32)
                            Text(item.category.name).font(.subheadline)
                            Spacer()
                            Text(Money.plain(item.amount)).font(.subheadline.bold())
                        }
                    }
                }
            }
        }
    }

    // 近 6 月趋势
    private var trendCard: some View {
        let trend = Finance.monthlyTrend(months: 6, transactions: transactions)
        let maxVal = max(trend.map { max($0.income, $0.expense) }.max() ?? 1, 1)
        return Card {
            VStack(alignment: .leading, spacing: 12) {
                Text("近半年收支").font(.subheadline).foregroundStyle(.secondary)
                HStack(alignment: .bottom, spacing: 12) {
                    ForEach(Array(trend.enumerated()), id: \.offset) { _, m in
                        VStack(spacing: 4) {
                            HStack(alignment: .bottom, spacing: 3) {
                                bar(m.income, maxVal, .green)
                                bar(m.expense, maxVal, .orange)
                            }
                            .frame(height: 90)
                            Text(m.label).font(.caption2).foregroundStyle(.secondary)
                        }
                        .frame(maxWidth: .infinity)
                    }
                }
                HStack(spacing: 16) {
                    Label("收入", systemImage: "square.fill").foregroundStyle(.green).font(.caption2)
                    Label("支出", systemImage: "square.fill").foregroundStyle(.orange).font(.caption2)
                }
            }
        }
    }

    private func bar(_ v: Double, _ maxVal: Double, _ color: Color) -> some View {
        RoundedRectangle(cornerRadius: 3)
            .fill(color)
            .frame(width: 10, height: max(2, CGFloat(v / maxVal) * 90))
    }

    private var monthTitle: String {
        let df = DateFormatter(); df.dateFormat = "yyyy年M月"
        return df.string(from: now)
    }
}
