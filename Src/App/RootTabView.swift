import SwiftUI
import SwiftData

/// 底部 5 Tab:首页 / 流水 / [记一笔] / 报表 / 我的 —— 复刻随手记主导航
struct RootTabView: View {
    @State private var selection = 0
    @State private var showRecord = false

    var body: some View {
        ZStack(alignment: .bottom) {
            TabView(selection: $selection) {
                HomeView()
                    .tabItem { Label("首页", systemImage: "house.fill") }
                    .tag(0)

                TransactionsView()
                    .tabItem { Label("流水", systemImage: "list.bullet.rectangle") }
                    .tag(1)

                Color.clear
                    .tabItem { Text("") }
                    .tag(2)

                ReportsView()
                    .tabItem { Label("报表", systemImage: "chart.pie.fill") }
                    .tag(3)

                MineView()
                    .tabItem { Label("我的", systemImage: "person.fill") }
                    .tag(4)
            }
            .tint(Color(hex: "#FF8A00"))

            // 中间凸起的「记一笔」按钮
            Button {
                showRecord = true
            } label: {
                ZStack {
                    Circle()
                        .fill(Color(hex: "#FF8A00"))
                        .frame(width: 58, height: 58)
                        .shadow(color: Color(hex: "#FF8A00").opacity(0.4), radius: 8, y: 4)
                    Image(systemName: "plus")
                        .font(.system(size: 26, weight: .bold))
                        .foregroundStyle(.white)
                }
            }
            .offset(y: -6)
            .accessibilityLabel("记一笔")
        }
        .sheet(isPresented: $showRecord) {
            RecordView()
        }
    }
}
