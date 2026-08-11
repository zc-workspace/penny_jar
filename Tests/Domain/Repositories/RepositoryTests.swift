import XCTest
@testable import PennyJar

final class RepositoryTests: XCTestCase {
    func testInMemoryRepositorySupportsCreateReadUpdateAndDelete() throws {
        let repository = InMemoryRepository<Ledger>()
        let ledger = TestFactory.ledger()
        try repository.create(ledger)

        XCTAssertEqual(try repository.fetch(id: ledger.id)?.name, "日常")
        XCTAssertEqual(try repository.fetchAll().count, 1)

        ledger.name = "更新后的账本"
        try repository.update(ledger)
        XCTAssertEqual(try repository.fetch(id: ledger.id)?.name, "更新后的账本")

        try repository.delete(id: ledger.id)
        XCTAssertNil(try repository.fetch(id: ledger.id))
        XCTAssertTrue(try repository.fetchAll().isEmpty)
    }

    func testInMemoryRepositoryRejectsUpdateAndDeleteOfUnknownID() {
        let repository = InMemoryRepository<Ledger>()
        let unknownID = TestFactory.ledger().id

        XCTAssertThrowsError(try repository.update(TestFactory.ledger(id: unknownID))) { error in
            XCTAssertEqual(error as? DomainError, .entityNotFound)
        }
        XCTAssertThrowsError(try repository.delete(id: unknownID)) { error in
            XCTAssertEqual(error as? DomainError, .entityNotFound)
        }
    }

    func testInMemoryRepositoryReplacesDuplicateIDAndReturnsDeterministicOrder() throws {
        let repository = InMemoryRepository<Ledger>()
        let first = TestFactory.ledger(
            id: UUID(uuidString: "00000000-0000-0000-0000-000000000099")!,
            name: "后"
        )
        let second = TestFactory.ledger(
            id: UUID(uuidString: "00000000-0000-0000-0000-000000000010")!,
            name: "前"
        )
        try repository.create(first)
        try repository.create(second)
        try repository.create(TestFactory.ledger(id: first.id, name: "替换"))

        XCTAssertEqual(try repository.fetchAll().map(\.name), ["前", "替换"])
    }
}
