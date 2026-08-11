# CLAUDE.md

本文件是 Claude Code 在本仓库工作的长期上下文摘要。详细规则以 `docs/` 下对应文档为准；当摘要与详细文档不一致时，优先遵守最新详细文档。

## 必读长期文档

- `docs/project_context.md` — 仓库、工具链、分支/PR 流程、鉴权与测试强制约定。
- `docs/clone_target.md` — 复刻目标与目录映射约定。
- `docs/testing_requirements.md` — 强制测试规范与本地 Hook 门禁说明。

## 项目目标

- 本项目复刻目标是 Apple App Store 上的「随手记专业版」。后续提到“复刻”“复刻目标”“参考 App”“对标产品”“原版”等，均默认指该 App，无需再次确认。
- 复刻重点是核心主链路：记账、报表、账户、预算、多账本。云同步等服务端能力按需另议。

## 技术栈与工具链

生成或修改代码时必须适配用户本机工具链：

- Xcode 26.6（Build 17F113）
- Apple Swift 6.3.3
- swift-driver 1.148.6
- XcodeGen 2.46.0
- SwiftLint 0.65.0

要求：

- 使用 Swift 6.x 语法与并发模型，注意 Sendable、actor 隔离和 async 测试覆盖。
- 工程描述使用 XcodeGen 2.46.0 兼容的 `project.yml`。
- 代码风格需满足 SwiftLint 0.65.0。

## 目录与文件放置

- 根目录 `index.md` 定义了 `Src/` 与 `Tests/` 的目录映射，新增或移动任何源码/测试文件前必须先遵守该映射。
- 新增目录或调整结构时，必须同步更新 `index.md`。
- 测试文件必须放在 `Tests/` 下与 `Src/` 相同的相对路径中，例如：
  - `Src/Domain/UseCases/Finance.swift`
  - `Tests/Domain/UseCases/FinanceTests.swift`

## Git 与 PR 流程

- 默认分支是 `main`，GitHub 仓库为 `https://github.com/zc-workspace/penny_jar.git`。
- 禁止直接推送或覆盖 `main`；每次提交代码必须走 PR。
- 每次动手改代码前、提交 PR 前，都必须先同步远程：`git fetch origin` 并基于最新 `origin/main` rebase，解决冲突并确认工作区状态后再继续。
- 标准流程：从最新 `main` 创建/更新特性分支 → 修改 → 测试全绿 → commit → push 分支 → 创建 PR 指向 `main`。
- 分支命名建议：`feature/xxx`、`fix/xxx`、`docs/xxx`。
- 合并权限保留给用户，助手只负责创建 PR，不自行合并。
- GitHub PAT 属敏感信息，不得写入文件；如用户临时提供，使用后提醒吊销。

## 测试强制要求

核心原则：**No test, no merge**。任何生产代码变更未附带通过的测试，视为未完成。

- 每次新增/修改生产代码，必须同时新增/修改对应测试。
- 每个新增或修改的 public 函数、方法、类型必须有对应测试。
- 测试遵循 FIRST 原则，结构采用 AAA 或 Given-When-Then。
- 用例必须覆盖：正常路径、边界值、等价类、异常/错误路径、状态与副作用。
- 单元测试必须隔离外部依赖；禁止真实网络、真实持久化、真实时钟和随机数。
- 优先使用 Swift Testing（`@Test`、`#expect`、`#require`）或 XCTest。
- 语句覆盖率要求 100%，分支覆盖率要求 100%；豁免必须显式、可审计并说明理由。
- 修复 bug 时，先写能复现问题的失败测试，再修复使其通过。
- 修改后必须运行受影响范围的既有测试；关键变更跑全量测试。
- 不得声称“已测试”或“已 100% 覆盖”除非实际运行测试/覆盖率工具并能给出结果。

## 本地测试门禁

- `.claude/settings.json` 配置了 PreToolUse Hook：`.claude/hooks/pre-commit-swift-tests.sh`。
- 执行 `git commit`、`git push`、`gh pr create` 前会自动运行全部 Swift 测试。
- Xcode 工程默认运行 `xcodebuild test -enableCodeCoverage YES`；SwiftPM 默认运行 `swift test --enable-code-coverage`。
- 默认模拟器 destination：`platform=iOS Simulator,name=iPhone 15`，可用 `SWIFT_TEST_DESTINATION` 覆盖。
- 默认 test scheme 由 `xcodebuild -list` 自动探测第一个 scheme，可用 `SWIFT_TEST_SCHEME` 指定。
- 尚无工程或本机无 Swift 工具链时，引导期允许提交但会告警；工程建立后门禁自动生效。

## 交付前自检

完成任何生产代码任务前，至少确认：

- 新/改 public 单元有测试覆盖。
- 正常、边界、异常、等价类用例齐全。
- 语句/分支覆盖率达到 100%，或有明确豁免。
- 全部相关测试实际执行通过，并报告命令与结果。
- 既有回归测试无破坏。
- 外部依赖已 mock/stub/fake，测试可重复且不 flaky。
- 若涉及缺陷修复，已添加复现用测试。
