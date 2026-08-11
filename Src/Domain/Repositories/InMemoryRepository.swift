import Foundation

/// 平台无关的内存仓储实现，用于单元测试与预览。
/// 生产环境的 SwiftData 实现放在后续 Data/App 层（见 index.md），实现同一 `Repository` 协议。
public final class InMemoryRepository<Entity: Identifiable & Sendable>: Repository
where Entity.ID == UUID {

    /// 保持插入顺序的存储。
    private var storage: [UUID: Entity] = [:]
    private var order: [UUID] = []
    /// 可选的写入校验闭包，返回错误原因则拒绝写入。
    private let validate: (@Sendable (Entity) -> String?)?

    public init(
        initial: [Entity] = [],
        validate: (@Sendable (Entity) -> String?)? = nil
    ) {
        self.validate = validate
        for e in initial {
            storage[e.id] = e
            order.append(e.id)
        }
    }

    public func create(_ entity: Entity) throws {
        if let reason = validate?(entity) {
            throw RepositoryError.validation(reason: reason)
        }
        guard storage[entity.id] == nil else {
            throw RepositoryError.duplicate(id: entity.id)
        }
        storage[entity.id] = entity
        order.append(entity.id)
    }

    public func read(id: UUID) -> Entity? {
        storage[id]
    }

    public func readAll() -> [Entity] {
        order.compactMap { storage[$0] }
    }

    public func update(_ entity: Entity) throws {
        guard storage[entity.id] != nil else {
            throw RepositoryError.notFound(id: entity.id)
        }
        if let reason = validate?(entity) {
            throw RepositoryError.validation(reason: reason)
        }
        storage[entity.id] = entity
    }

    public func delete(id: UUID) throws {
        guard storage[id] != nil else {
            throw RepositoryError.notFound(id: id)
        }
        storage[id] = nil
        order.removeAll { $0 == id }
    }

    /// 当前实体数量。
    public var count: Int { storage.count }
}
