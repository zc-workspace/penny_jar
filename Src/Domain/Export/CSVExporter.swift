import Foundation

/// 将流水序列化为 CSV 的纯逻辑 UseCase（无副作用，便于单元测试）。
/// UI 层（MineView）只负责把生成的字符串写入临时文件并调用系统分享面板。
enum CSVExporter {

    /// 生成 CSV 文本：日期,类型,分类,金额,账户,备注,项目
    static func makeCSV(from transactions: [Transaction]) -> String {
        var csv = "日期,类型,分类,金额,账户,备注,项目\n"
        let df = DateFormatter(); df.dateFormat = "yyyy-MM-dd HH:mm"
        for t in transactions.sorted(by: { $0.date > $1.date }) {
            let fields = [
                df.string(from: t.date),
                t.type.rawValue,
                t.category?.name ?? "",
                Money.plain(t.amount),
                t.account?.name ?? "",
                t.note.replacingOccurrences(of: ",", with: " "),
                t.projectTag ?? ""
            ]
            csv += fields.joined(separator: ",") + "\n"
        }
        return csv
    }

    /// 将 CSV 写入临时目录并返回文件 URL（供系统分享面板使用）
    static func writeTempFile(_ csv: String, fileName: String = "penny_jar导出.csv") -> URL? {
        let url = FileManager.default.temporaryDirectory.appendingPathComponent(fileName)
        do {
            try csv.data(using: .utf8)?.write(to: url)
            return url
        } catch {
            return nil
        }
    }
}
