# penny_jar 目录索引与源码映射（index.md）

> 本文件定义 `Src/` 与 `Tests/` 各目录的用途，以及每个 path 应放置的源码 / 文件类型。
> **凡是向本仓库生成或提交代码，必须遵循此映射关系放置文件；新增目录须同步更新本文件。**
>
> 架构：SwiftUI + SwiftData（iOS 17+），MVVM + 分层（App / Domain / Features / Common）。
> Domain 已合并「数据层 + 领域层」；Tests 逐层镜像 Src。

---

## 一、Src/ 源码目录映射

| Path | 用途 | 应放置的源码 / 文件 |
|------|------|--------------------|
| `Src/App/` | 应用入口与根导航 | `@main` App 入口（`PennyJarApp.swift`）、`ModelContainer` 装配、`RootTabView` 根 TabView、AppDelegate/场景配置 |
| `Src/Domain/Entities/` | 领域实体（SwiftData 模型） | `@Model` 实体：`Ledger` / `Account` / `Category` / `Member` / `Transaction` / `Budget`；以及枚举 `TransactionType` / `AccountType` / `BudgetPeriod`（`Enums.swift`） |
| `Src/Domain/UseCases/` | 业务用例 / 计算引擎 | 纯函数业务逻辑：余额、净资产、区间合计、分类聚合、月度趋势、预算进度（`Finance.swift`）等，不依赖 UI |
| `Src/Domain/Repositories/` | 仓储抽象与实现 | 数据访问协议（`TransactionRepositoryProtocol` 等）+ SwiftData 实现（`SwiftDataTransactionRepository` 等） |
| `Src/Domain/Persistence/` | 持久化与初始化数据 | `ModelContainer`/`ModelContext` 相关封装、种子数据 `SeedData`、数据迁移 |
| `Src/Domain/Export/` | 数据导出 | CSV/文件导出等纯逻辑（`CSVExporter.swift`） |
| `Src/Features/Home/` | 首页/概览 | 首页 View + ViewModel（月度收支、快捷入口、卡片） |
| `Src/Features/Record/` | 记一笔 | 记账录入 View + 键盘组件（`RecordView`、`Keypad`）+ ViewModel |
| `Src/Features/Transactions/` | 流水/账单列表 | 交易列表、筛选、详情 View + ViewModel |
| `Src/Features/Reports/` | 报表统计 | 收支报表、图表页 View + ViewModel（调用 UseCases 聚合结果） |
| `Src/Features/Accounts/` | 账户管理 | 账户列表、净资产、账户增删改 View + ViewModel |
| `Src/Features/Budget/` | 预算管理 | 预算设置、预算进度 View + ViewModel |
| `Src/Features/Books/` | 多账本 | 账本切换、账本管理 View + ViewModel |
| `Src/Features/Mine/` | 我的/设置 | 个人中心、成员管理、分类管理、导出入口、关于 View + ViewModel |
| `Src/Common/Extensions/` | 通用扩展 | 标准库/系统类型扩展：`Color+Hex`、`Date+Range` 等 |
| `Src/Common/Formatters/` | 格式化工具 | 金额/日期格式化：`Money`（货币字符串）等 |
| `Src/Common/Components/` | 通用 UI 组件 | 可复用 SwiftUI 组件：`CategoryIcon`、`Card`、`ProgressBar`、`PieChart` 等 |
| `Src/Common/Utils/` | 通用工具 | 与业务无关的辅助工具：`ShareSheet`（UIActivityViewController 桥接）等 |
| `Src/Resources/` | 资源文件 | `Info.plist`、`Assets.xcassets`（AppIcon/AccentColor）、本地化、字体等静态资源 |

---

## 二、Tests/ 测试目录映射（逐层镜像 Src/）

| Path | 用途 | 应放置的源码 / 文件 |
|------|------|--------------------|
| `Tests/App/` | App 层测试 | 入口装配、依赖注入、`ModelContainer` 构建的测试 |
| `Tests/Domain/Entities/` | 实体测试 | 实体派生属性/枚举语义单测（`EntityTests.swift`：`signedAmount`、`sign`、`isLiability` 等） |
| `Tests/Domain/UseCases/` | 用例测试 | 计算引擎单测（`FinanceTests.swift`：余额/净资产/聚合/预算） |
| `Tests/Domain/Repositories/` | 仓储测试 | Repository 协议实现的读写/持久化行为测试 |
| `Tests/Domain/Persistence/` | 持久化测试 | 种子数据、迁移、`ModelContext` 相关测试 |
| `Tests/Domain/Export/` | 导出测试 | 导出逻辑单测（`CSVExporterTests.swift`：表头/行数/逗号转义） |
| `Tests/Features/Home/` | 首页测试 | 首页 ViewModel/交互逻辑测试 |
| `Tests/Features/Record/` | 记一笔测试 | 记账录入 ViewModel/校验逻辑测试 |
| `Tests/Features/Transactions/` | 流水测试 | 列表筛选/排序逻辑测试 |
| `Tests/Features/Reports/` | 报表测试 | 报表聚合展示逻辑测试 |
| `Tests/Features/Accounts/` | 账户测试 | 账户管理/净资产逻辑测试 |
| `Tests/Features/Budget/` | 预算测试 | 预算进度/校验逻辑测试 |
| `Tests/Features/Books/` | 多账本测试 | 账本切换/管理逻辑测试 |
| `Tests/Features/Mine/` | 我的测试 | 成员/分类管理、导出入口逻辑测试 |
| `Tests/Common/Extensions/` | 扩展测试 | `Color+Hex`、`Date+Range` 等扩展单测 |
| `Tests/Common/Formatters/` | 格式化测试 | `Money` 等格式化单测 |
| `Tests/Common/Components/` | 组件测试 | 可复用组件的快照/逻辑测试 |
| `Tests/Common/Utils/` | 工具测试 | 通用工具单测 |
| `Tests/Resources/` | 测试资源 | 测试用固定数据、fixture、mock 资源文件 |
| `Tests/Mocks/` | 测试替身 | 测试工厂与假实现（`TestFactory.swift`、各 Repository 的 Mock） |

---

## 三、放置规则（生成代码时必须遵守）

1. **实体（`@Model`）只放** `Src/Domain/Entities/`；纯业务计算只放 `Src/Domain/UseCases/`，不得写进 View。
2. **页面代码按功能域** 放入对应 `Src/Features/<域>/`；跨功能复用的 UI/工具下沉到 `Src/Common/`。
3. **数据访问** 一律经 `Src/Domain/Repositories/` 的协议抽象，SwiftData 实现同目录并置。
4. **每个被测源码文件** 的测试放到 `Tests/` 中与 `Src/` **相同的相对路径**下（如 `Src/Domain/UseCases/Finance.swift` → `Tests/Domain/UseCases/FinanceTests.swift`）。
5. **测试替身与工厂** 统一放 `Tests/Mocks/`。
6. **新增目录** 必须同步在本 `index.md` 补充映射条目。

---

## 四、工程约定目录（非 Src/Tests）

| Path | 用途 | 说明 |
|------|------|------|
| `docs/testing_requirements.md` | 测试规范（强制 Instructions） | 单元测试全覆盖、语句+分支覆盖率 100%、异常/边界/等价类用例、回归零破坏、Definition of Done。生成/修改代码必须遵守 |
| `.claude/settings.json` | Agent 门禁配置 | 注册 PreToolUse Hook，提交前强制跑测试 |
| `.claude/hooks/pre-commit-swift-tests.sh` | 提交前测试门禁脚本 | 拦截 `git push`/`gh pr create`/`git commit`，先跑全部 Swift 测试，失败则阻断 |
