import SwiftUI

struct RootTabView: View {
    var body: some View {
        TabView {
            Text("账本")
                .tabItem {
                    Label("账本", systemImage: "book.closed")
                }
            Text("流水")
                .tabItem {
                    Label("流水", systemImage: "list.bullet")
                }
            Text("报表")
                .tabItem {
                    Label("报表", systemImage: "chart.pie")
                }
            Text("我的")
                .tabItem {
                    Label("我的", systemImage: "person")
                }
        }
    }
}
