import Foundation
import SwiftData

protocol IdentifiableEntity: AnyObject {
    var id: UUID { get }
}

extension Ledger: IdentifiableEntity {}
extension Account: IdentifiableEntity {}
extension Category: IdentifiableEntity {}
extension Member: IdentifiableEntity {}
extension Transaction: IdentifiableEntity {}
extension Budget: IdentifiableEntity {}

protocol Repository<Entity>: AnyObject where Entity: IdentifiableEntity {
    associatedtype Entity: IdentifiableEntity

    func create(_ entity: Entity) throws
    func fetch(id: UUID) throws -> Entity?
    func fetchAll() throws -> [Entity]
    func update(_ entity: Entity) throws
    func delete(id: UUID) throws
}

final class InMemoryRepository<Entity: IdentifiableEntity>: Repository {
    private var storage: [UUID: Entity] = [:]

    func create(_ entity: Entity) throws {
        storage[entity.id] = entity
    }

    func fetch(id: UUID) throws -> Entity? {
        storage[id]
    }

    func fetchAll() throws -> [Entity] {
        storage.values.sorted { $0.id.uuidString < $1.id.uuidString }
    }

    func update(_ entity: Entity) throws {
        guard storage[entity.id] != nil else {
            throw DomainError.entityNotFound
        }
        storage[entity.id] = entity
    }

    func delete(id: UUID) throws {
        guard storage.removeValue(forKey: id) != nil else {
            throw DomainError.entityNotFound
        }
    }
}

final class SwiftDataRepository<Entity: PersistentModel & IdentifiableEntity>: Repository {
    private let context: ModelContext

    init(context: ModelContext) {
        self.context = context
    }

    func create(_ entity: Entity) throws {
        context.insert(entity)
        try context.save()
    }

    func fetch(id: UUID) throws -> Entity? {
        let descriptor = FetchDescriptor<Entity>(
            predicate: #Predicate { $0.id == id }
        )
        return try context.fetch(descriptor).first
    }

    func fetchAll() throws -> [Entity] {
        try context.fetch(FetchDescriptor<Entity>())
    }

    func update(_ entity: Entity) throws {
        guard try fetch(id: entity.id) != nil else {
            throw DomainError.entityNotFound
        }
        try context.save()
    }

    func delete(id: UUID) throws {
        guard let entity = try fetch(id: id) else {
            throw DomainError.entityNotFound
        }
        context.delete(entity)
        try context.save()
    }
}

typealias LedgerRepository = any Repository<Ledger>
typealias AccountRepository = any Repository<Account>
typealias CategoryRepository = any Repository<Category>
typealias MemberRepository = any Repository<Member>
typealias TransactionRepository = any Repository<Transaction>
typealias BudgetRepository = any Repository<Budget>
