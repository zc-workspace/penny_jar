import SwiftData
import XCTest
@testable import PennyJar

final class PersistenceTests: XCTestCase {
    func testModelContainerUsesAllDomainEntities() throws {
        let container = try PennyJarModelContainer.make(inMemory: true)
        let context = ModelContext(container)

        let ledger = try SeedData.makeDefaultLedger(in: context)
        XCTAssertEqual(ledger.accounts.count, 2)
        XCTAssertEqual(ledger.categories.count, 2)
        XCTAssertEqual(ledger.members.count, 1)
        XCTAssertTrue(ledger.isDefault)
    }
}
