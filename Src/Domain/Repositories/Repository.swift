import Foundation

/// 仓储层错误。
public enum RepositoryError: Error, Equatable, Sendable {
    /// 按 id 未找到实体。
    case notFound(id: UUID)
    /// 插入时 id 已存在。
    case duplicate(id: UUID)
    /// 校验失败（如金额为负、名称为空）。
    case validation(reason: String)
}

/// 通用增删改查仓储协议。Domain 层只依赖此抽象，不关心底层是内存、SwiftData 还是网络。
public protocol Repository<Entity>: AnyObject {
    associatedtype Entity: Identifiable where Entity.ID == UUID

    /// 新增；若 id 已存在抛 `.duplicate`。
    func create(_ entity: Entity) throws
    /// 按 id 读取；不存在返回 nil。
    func read(id: UUID) -> Entity?
    /// 读取全部。
    func readAll() -> [Entity]
    /// 更新；若 id 不存在抛 `.notFound`。
    func update(_ entity: Entity) throws
    /// 按 id 删除；若不存在抛 `.notFound`。
    func delete(id: UUID) throws
}
