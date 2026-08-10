import XCTest
@testable import PennyJar

/// 对应 Src/Domain/Export/CSVExporter.swift
final class CSVExporterTests: XCTestCase {

    func testHeaderAlwaysPresent() {
        let csv = CSVExporter.makeCSV(from: [])
        XCTAssertTrue(csv.hasPrefix("日期,类型,分类,金额,账户,备注,项目"))
    }

    func testRowCountMatchesTransactions() {
        let txs = [
            TestFactory.transaction(type: .expense, amount: 12.5),
            TestFactory.transaction(type: .income, amount: 100)
        ]
        let csv = CSVExporter.makeCSV(from: txs)
        // 1 表头 + 2 数据行 + 末尾换行 → 拆分后过滤空行为 3 行
        let lines = csv.split(separator: "\n", omittingEmptySubsequences: true)
        XCTAssertEqual(lines.count, 3)
    }

    func testNoteCommasAreSanitized() {
        let t = Transaction(type: .expense, amount: 9, note: "买了,苹果,香蕉")
        let csv = CSVExporter.makeCSV(from: [t])
        // 备注里的逗号应被替换为空格，避免破坏 CSV 列结构
        XCTAssertFalse(csv.contains("买了,苹果,香蕉"))
        XCTAssertTrue(csv.contains("买了 苹果 香蕉"))
    }
}
