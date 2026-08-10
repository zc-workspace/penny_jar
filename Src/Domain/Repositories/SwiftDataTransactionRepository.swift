import Foundation
import SwiftData

/// `TransactionRepositoryProtocol` 的 SwiftData 实现。
/// 依赖倒置：Domain 定义协议，此处提供具体存储实现，可随时替换为 CloudKit / Mock。
struct SwiftDataTransactionRepository: TransactionRepositoryProtocol {
    let context: ModelContext

    init(context: ModelContext) {
        self.context = context
    }

    func fetchAll() -> [Transaction] {
        let descriptor = FetchDescriptor<Transaction>(
            sortBy: [SortDescriptor(\.date, order: .reverse)]
        )
        return (try? context.fetch(descriptor)) ?? []
    }

    func insert(_ transaction: Transaction) {
        context.insert(transaction)
    }

    func delete(_ transaction: Transaction) {
        context.delete(transaction)
    }

    func save() {
        try? context.save()
    }
}
