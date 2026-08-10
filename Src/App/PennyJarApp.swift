import SwiftUI
import SwiftData

@main
struct PennyJarApp: App {
    let container: ModelContainer

    init() {
        do {
            container = try ModelContainer(
                for: Ledger.self, Account.self, Category.self,
                Member.self, Transaction.self, Budget.self
            )
            SeedData.bootstrapIfNeeded(container.mainContext)
        } catch {
            fatalError("无法初始化数据库: \(error)")
        }
    }

    var body: some Scene {
        WindowGroup {
            RootTabView()
        }
        .modelContainer(container)
    }
}
