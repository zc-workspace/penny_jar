# 随手记 Project · 长期约定（Context）

> 本文件记录 Shuishouji Project 的长期协作约定。后续每次会话、每次代码提交都应先读取并遵守本文件。用户可随时更新此文件，更新后以最新内容为准。

最后更新：2026-08-10（补充：改代码/提交前必须 rebase 远程 main 并解决冲突）

---

## 一、代码仓库

- **GitHub 仓库地址**：`https://github.com/zc-workspace/penny_jar.git`
- **平台**：GitHub（外部）
- **默认分支**：`main`

## 一之二、编译环境（生成代码时必须匹配）

生成 / 修改代码时，必须适配用户本机的以下工具链版本，避免用超出该版本能力或已弃用的写法：

| 工具 | 版本 |
|---|---|
| Xcode | 26.6（Build 17F113） |
| Swift | Apple Swift 6.3.3（swiftlang-6.3.3.1.3 clang-2100.1.1.101） |
| swift-driver | 1.148.6 |
| XcodeGen | 2.46.0 |
| SwiftLint | 0.65.0 |

- 语言标准：按 Swift 6.x 语法与并发模型（Sendable / actor 隔离等）编写，确保能在上述 Xcode / Swift 上编译通过。
- 代码风格须满足 SwiftLint 0.65.0 规则。
- 工程用 XcodeGen 2.46.0 兼容的 `project.yml` 描述。

## 二、提交方式（强制）

1. **每次提交代码必须走 PR（Pull Request），禁止直接覆盖 / 直接推送到 `main`**。
2. **同步远程（强制）**：每次动手改代码之前、以及提交 PR/MR 之前，都必须先 `git fetch` 并 rebase 远程 `main` 分支的最新变更（`git rebase origin/main`）；**先消除所有代码冲突、确认工作区干净后，再生成 / 修改代码**。
3. 标准流程：`git fetch origin` → 从最新 `main` 拉特性分支（或对已有分支 `git rebase origin/main`）→ 解决冲突 → 在分支上改动 → commit → push 分支 → 创建 PR 指向 `main`。
4. 分支命名建议：`feature/xxx`、`fix/xxx`、`docs/xxx`。
5. 合并权限保留给用户，助手只负责把 PR 建好，不自行合并。

## 三、鉴权

- 推送与建 PR 需要用户提供的 GitHub Personal Access Token（fine-grained）。
- token 属敏感信息，不写入本文件，由用户在需要时临时提供；用完提醒用户吊销。
- token 至少需要权限：**Contents: Read and write** + **Pull requests: Read and write**。

## 四、其他

- 合入代码时优先与仓库现有结构合并，不覆盖已有内容。
- 用户可随时更新本文件中的仓库地址、分支策略、提交要求等约定。

## 五、测试要求（强制）

- 生成 / 修改任何生产代码时，必须遵守 `testing_requirements.md` 中的全部测试规范：单元测试全覆盖、语句 + 分支覆盖率 100%、异常/边界/等价类用例、回归测试零破坏、Definition of Done 逐项自检。
- **MR / PR 提交前必须运行全部测试并全部通过**，否则不得创建 PR（已由本地 Hook 强制拦截，见项目 `.claude/settings.json` 的 PreToolUse 配置）。
