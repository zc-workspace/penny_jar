import Foundation

/// 交易流水的仓储抽象。Domain 层只依赖此协议，具体实现由 Data/持久化层提供
/// （当前实现基于 SwiftData `ModelContext`；后续可替换为 CloudKit / Mock 而不影响业务逻辑）。
///
/// 保留此协议是分层架构可测性的来源：UseCase 注入 Mock 实现即可脱离数据库做单元测试。
protocol TransactionRepositoryProtocol {
    func fetchAll() -> [Transaction]
    func insert(_ transaction: Transaction)
    func delete(_ transaction: Transaction)
    func save()
}
