#!/usr/bin/env bash
# ---------------------------------------------------------------------------
# PreToolUse Hook: 随手记 Project — 提交/推送/建 PR 前强制跑全部 Swift 测试
#
# 触发点：Agent 调用 Bash 工具执行「提交类命令」之前
#   命中命令（正则）：git push / gh pr create / git commit
# 行为：
#   1. 命中提交类命令 → 在仓库内运行全部 Swift 测试（含覆盖率）
#   2. 测试全部通过 → exit 0，放行原命令
#   3. 测试失败 / 无法运行 → exit 2，阻断原命令，并把原因回灌给 Agent
#   4. 非提交类命令 → exit 0，直接放行（不打扰正常操作）
#
# 说明：Hook 从 stdin 读取 JSON（含 tool_input.command），由 harness 注入。
# ---------------------------------------------------------------------------
set -uo pipefail

# 读取 harness 传入的 JSON
INPUT="$(cat)"

# 提取被拦截的 Bash 命令（优先 jq，缺失则退化为 grep）
if command -v jq >/dev/null 2>&1; then
  CMD="$(printf '%s' "$INPUT" | jq -r '.tool_input.command // empty')"
  CWD="$(printf '%s' "$INPUT" | jq -r '.cwd // empty')"
else
  CMD="$(printf '%s' "$INPUT" | grep -o '"command"[[:space:]]*:[[:space:]]*"[^"]*"' | head -1 | sed 's/.*:[[:space:]]*"//; s/"$//')"
  CWD=""
fi

# 判断是否为「提交类命令」——只有这些才触发测试门禁
if ! printf '%s' "$CMD" | grep -Eq '(git[[:space:]]+push|gh[[:space:]]+pr[[:space:]]+create|git[[:space:]]+commit)'; then
  exit 0   # 非提交类命令，放行
fi

# 定位工程目录：优先命令执行目录 CWD，否则当前目录
PROJECT_DIR="${CWD:-$PWD}"
cd "$PROJECT_DIR" 2>/dev/null || true

echo "🔒 [测试门禁] 检测到提交类命令，提交前强制运行全部 Swift 测试..." >&2
echo "    命令: $CMD" >&2
echo "    目录: $PROJECT_DIR" >&2

# ---- 选择可用的 Swift 测试运行方式 ----
run_tests() {
  # 1) Xcode 工程（.xcodeproj / .xcworkspace）→ xcodebuild test + 覆盖率
  local ws proj scheme
  ws="$(ls -d *.xcworkspace 2>/dev/null | head -1)"
  proj="$(ls -d *.xcodeproj 2>/dev/null | head -1)"
  if [ -n "$ws" ] || [ -n "$proj" ]; then
    if ! command -v xcodebuild >/dev/null 2>&1; then
      echo "__NO_TOOL__ xcodebuild 不可用，无法运行 Xcode 工程测试" >&2
      return 3
    fi
    local target_flag
    if [ -n "$ws" ]; then target_flag="-workspace $ws"; else target_flag="-project $proj"; fi

    # scheme：优先环境变量 SWIFT_TEST_SCHEME；留空则用 xcodebuild -list 自动探测第一个 scheme
    scheme="${SWIFT_TEST_SCHEME:-}"
    if [ -z "$scheme" ]; then
      if command -v jq >/dev/null 2>&1; then
        scheme="$(xcodebuild -list -json $target_flag 2>/dev/null | jq -r '(.workspace // .project).schemes[0] // empty')"
      else
        scheme="$(xcodebuild -list $target_flag 2>/dev/null | awk '/Schemes:/{f=1;next} f&&NF{print $1;exit}')"
      fi
    fi
    local scheme_flag=""
    [ -n "$scheme" ] && scheme_flag="-scheme $scheme"
    echo "    运行: xcodebuild test $target_flag $scheme_flag (scheme=${scheme:-<自动>})" >&2
    xcodebuild test $target_flag $scheme_flag \
      -destination "${SWIFT_TEST_DESTINATION:-platform=iOS Simulator,name=iPhone 15}" \
      -enableCodeCoverage YES 2>&1
    return $?
  fi

  # 2) SwiftPM 包（Package.swift）→ swift test
  if [ -f "Package.swift" ]; then
    if ! command -v swift >/dev/null 2>&1; then
      echo "__NO_TOOL__ swift 不可用，无法运行 SwiftPM 测试" >&2
      return 3
    fi
    echo "    运行: swift test --enable-code-coverage" >&2
    swift test --enable-code-coverage 2>&1
    return $?
  fi

  echo "__NO_PROJECT__ 未找到 .xcworkspace / .xcodeproj / Package.swift" >&2
  return 4
}

TEST_OUTPUT="$(run_tests)"
RC=$?
echo "$TEST_OUTPUT" | tail -60 >&2

if [ "$RC" -eq 0 ]; then
  echo "✅ [测试门禁] 全部 Swift 测试通过，放行提交。" >&2
  exit 0
fi

# 失败分类处理：
#   RC=3 无工具链 / RC=4 无工程 → 处于「引导期(尚无代码或无本地工具链)」，
#      放行提交(exit 0)并告警，避免连初始配置都无法提交；
#   其它 RC → 测试真的失败，阻断提交(exit 2)。
case "$RC" in
  3)
    echo "⚠️ [测试门禁] 未检测到 Swift 工具链(xcodebuild/swift)，跳过测试并放行本次提交。" >&2
    echo "    注意：一旦本机具备工具链且工程存在，提交前将强制跑测试。" >&2
    exit 0
    ;;
  4)
    echo "⚠️ [测试门禁] 尚未检测到 Swift 工程(无 .xcworkspace/.xcodeproj/Package.swift)，判定为引导期，放行本次提交。" >&2
    echo "    注意：工程建立后，提交前将强制跑全部测试，失败则阻断。" >&2
    exit 0
    ;;
  *)
    echo "❌ [测试门禁] Swift 测试未全部通过(退出码 $RC)。按项目测试规范，禁止在测试失败时提交/推送/建 PR。请修复失败用例并保证覆盖率达标后重试。" >&2
    exit 2
    ;;
esac
