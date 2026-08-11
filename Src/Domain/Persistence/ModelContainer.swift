import SwiftData

enum PennyJarModelContainer {
    static let schema = Schema([
        Ledger.self,
        Account.self,
        Category.self,
        Member.self,
        Transaction.self,
        Budget.self
    ])

    static func make(inMemory: Bool = false) throws -> ModelContainer {
        let configuration = ModelConfiguration(
            schema: schema,
            isStoredInMemoryOnly: inMemory
        )
        return try ModelContainer(for: schema, configurations: configuration)
    }
}
