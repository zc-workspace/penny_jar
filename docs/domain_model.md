# Domain 与数据实体设计

## 产品能力映射

“随手记专业版”的核心数据链路可以归纳为：多账本隔离基础资料，账户记录资产和负债，交易记录每一笔收支/转账，预算约束消费，报表从交易聚合。公开产品信息还提到多币种、多人协同、借贷、备份和导出；本阶段只落地 README 已确定的本地核心链路，预留了 `Member`、`receiptPath`、`tags` 和账本币种字段。

## 实体

| 实体 | 作用 | 关键字段 |
| --- | --- | --- |
| `Ledger` | 多账本边界和币种上下文 | `id`、`name`、`currencyCode`、`isDefault`、`createdAt` |
| `Account` | 现金、银行卡、信用卡等资金载体 | `name`、`type`、`openingBalance`、`isArchived`、`ledger` |
| `Category` | 收入或支出分类，支持父分类 | `name`、`type`、`iconName`、`colorHex`、`parentID` |
| `Member` | 账本参与人/归属人 | `name`、`avatarSymbol`、`isArchived` |
| `Transaction` | 收支、转账流水 | `amount`、`type`、`occurredAt`、`note`、`tags`、`receiptPath`、账户/分类/成员 |
| `Budget` | 总预算或分类预算 | `amount`、`period`、`startDate`、`endDate`、`category` |

所有实体以 `UUID` 作为稳定主键。除 `Category.parentID` 外，跨账本关系在实体校验时拒绝，避免一个账本的流水引用到另一个账本的账户或分类。删除账本采用 SwiftData cascade 删除其从属数据；业务上如需保留历史记录，应优先使用 `isArchived`。

## 余额语义

- 支出：从交易的 `account` 扣减 `amount`。
- 收入：向交易的 `account` 增加 `amount`。
- 转账：从 `account` 扣减、向 `transferAccount` 增加，交易本身不影响净资产。
- 负债账户的当前余额在净资产计算中取反。

## CRUD

`Repository` 定义了 `create`、`fetch`、`fetchAll`、`update`、`delete` 五个操作。`InMemoryRepository` 用于快速、隔离的单元测试；`SwiftDataRepository` 是生产持久化实现，使用 `ModelContext` 保存每次写入并在更新/删除不存在的 ID 时抛出 `DomainError.entityNotFound`。
