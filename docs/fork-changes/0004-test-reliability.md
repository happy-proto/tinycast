# 0004 测试环境与异步断言

状态：维护中。

## 为什么改

AI CLI harness 会受本机 fish 启动配置和 PATH 影响；扩展生命周期及授权队列测试依赖异步结果，
固定等待和无契约保证的调用顺序会导致环境型失败。

## 如何改

AI CLI 测试使用隔离的 fish 配置和 stub 路径。扩展菜单栏测试在关键操作后等待可观测状态，
授权测试检查各调用恰好一次且询问不重叠，不要求并发调用按固定顺序执行。CI 串行运行 harness，
减少编译争用影响；本地仍保留 runner 的默认并行度。

## 入口和验证

- [Codex harness](../../Tests/codex-turn-test.swift)、[已安装 CLI harness](../../Tests/installed-ai-test.swift)。
- [扩展菜单栏 harness](../../Tests/ext-menu-bar-test.swift)、[CI](../../.github/workflows/ci.yml)。
- 按对应 harness 名称运行 [runner](../../Scripts/run-tests.sh)；完整同步运行全套测试。

## 上游同步

关注 shell 环境准备、扩展卸载及后台执行状态、授权串行化契约和测试 runner 变化。
上游已消除环境依赖或提供等价状态等待时移除重复修改；保留行为断言，不用加长固定 sleep 掩盖缺陷。
历史讨论：[PR #6](https://github.com/happy-proto/tinycast/pull/6)。
