import XCTest
@testable import PennyJarDomain

/// 对应 Src/Domain/Repositories/ —— 通用 CRUD 与错误分支全覆盖。
final class InMemoryRepositoryTests: XCTestCase {

    private func makeRepo(
        validate: (@Sendable (Account) -> String?)? = nil
    ) -> InMemoryRepository<Account> {
        InMemoryRepository<Account>(validate: validate)
    }

    // MARK: Create

    func test_create_thenReadReturnsEntity() throws {
        let repo = makeRepo()
        let acc = TestFactory.account(name: "现金")
        try repo.create(acc)
        XCTAssertEqual(repo.read(id: acc.id), acc)
        XCTAssertEqual(repo.count, 1)
    }

    func test_create_duplicateID_throwsDuplicate() throws {
        let repo = makeRepo()
        let acc = TestFactory.account()
        try repo.create(acc)
        XCTAssertThrowsError(try repo.create(acc)) { error in
            XCTAssertEqual(error as? RepositoryError, .duplicate(id: acc.id))
        }
    }

    func test_create_validationFails_throwsValidation() {
        let repo = makeRepo { $0.name.isEmpty ? "名称不能为空" : nil }
        let acc = TestFactory.account(name: "")
        XCTAssertThrowsError(try repo.create(acc)) { error in
            XCTAssertEqual(error as? RepositoryError, .validation(reason: "名称不能为空"))
        }
        XCTAssertEqual(repo.count, 0)
    }

    // MARK: Read

    func test_read_missingID_returnsNil() {
        let repo = makeRepo()
        XCTAssertNil(repo.read(id: UUID()))
    }

    func test_readAll_preservesInsertionOrder() throws {
        let repo = makeRepo()
        let a = TestFactory.account(name: "A")
        let b = TestFactory.account(name: "B")
        let c = TestFactory.account(name: "C")
        try repo.create(a); try repo.create(b); try repo.create(c)
        XCTAssertEqual(repo.readAll().map(\.name), ["A", "B", "C"])
    }

    func test_readAll_emptyRepo_returnsEmpty() {
        XCTAssertTrue(makeRepo().readAll().isEmpty)
    }

    func test_init_withInitialEntities_populatesStorage() {
        let a = TestFactory.account(name: "A")
        let b = TestFactory.account(name: "B")
        let repo = InMemoryRepository<Account>(initial: [a, b])
        XCTAssertEqual(repo.readAll().map(\.name), ["A", "B"])
        XCTAssertEqual(repo.count, 2)
    }

    // MARK: Update

    func test_update_existing_persistsChanges() throws {
        let repo = makeRepo()
        var acc = TestFactory.account(name: "旧名", initialBalance: 100)
        try repo.create(acc)
        acc.name = "新名"
        acc.initialBalance = 200
        try repo.update(acc)
        XCTAssertEqual(repo.read(id: acc.id)?.name, "新名")
        XCTAssertEqual(repo.read(id: acc.id)?.initialBalance, 200)
    }

    func test_update_missingID_throwsNotFound() {
        let repo = makeRepo()
        let acc = TestFactory.account()
        XCTAssertThrowsError(try repo.update(acc)) { error in
            XCTAssertEqual(error as? RepositoryError, .notFound(id: acc.id))
        }
    }

    func test_update_validationFails_throwsValidation() throws {
        let repo = makeRepo { $0.initialBalance < 0 ? "余额不能为负" : nil }
        var acc = TestFactory.account(initialBalance: 100)
        try repo.create(acc)
        acc.initialBalance = -1
        XCTAssertThrowsError(try repo.update(acc)) { error in
            XCTAssertEqual(error as? RepositoryError, .validation(reason: "余额不能为负"))
        }
    }

    // MARK: Delete

    func test_delete_existing_removesEntity() throws {
        let repo = makeRepo()
        let acc = TestFactory.account()
        try repo.create(acc)
        try repo.delete(id: acc.id)
        XCTAssertNil(repo.read(id: acc.id))
        XCTAssertEqual(repo.count, 0)
    }

    func test_delete_missingID_throwsNotFound() {
        let repo = makeRepo()
        let missing = UUID()
        XCTAssertThrowsError(try repo.delete(id: missing)) { error in
            XCTAssertEqual(error as? RepositoryError, .notFound(id: missing))
        }
    }

    func test_delete_updatesReadAllOrder() throws {
        let repo = makeRepo()
        let a = TestFactory.account(name: "A")
        let b = TestFactory.account(name: "B")
        let c = TestFactory.account(name: "C")
        try repo.create(a); try repo.create(b); try repo.create(c)
        try repo.delete(id: b.id)
        XCTAssertEqual(repo.readAll().map(\.name), ["A", "C"])
    }
}
