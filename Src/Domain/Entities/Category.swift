import Foundation
import SwiftData

// MARK: - 分类

@Model
final class Category {
    @Attribute(.unique) var id: UUID
    var name: String
    var iconName: String
    var colorHex: String
    var typeRaw: String          // 属于支出还是收入
    var sortIndex: Int
    var parentID: UUID?          // 支持二级分类

    var type: TransactionType {
        get { TransactionType(rawValue: typeRaw) ?? .expense }
        set { typeRaw = newValue.rawValue }
    }

    init(name: String,
         iconName: String,
         colorHex: String,
         type: TransactionType,
         sortIndex: Int = 0,
         parentID: UUID? = nil) {
        self.id = UUID()
        self.name = name
        self.iconName = iconName
        self.colorHex = colorHex
        self.typeRaw = type.rawValue
        self.sortIndex = sortIndex
        self.parentID = parentID
    }
}
