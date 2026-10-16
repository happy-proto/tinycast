# 0001 单分支维护、CI 与 Dev App 安装

状态：维护中。

## 为什么改

个人 fork 需要持续保留定制，并从统一来源验证和安装完整 Dev App。stacked PR 的分支和级联
维护成本过高，改为直接在 `main` 按 commit 维护。

## 如何改

`origin` 指向 `happy-proto/tinycast`，`upstream` 指向 `abue-ammar/tinycast`。
同步时将 fork 自有提交 rebase 到 `upstream/main`；改造记录与精确上游基线共同说明剩余差异。
CI 在 `main` push、面向 `main` 的 PR 和手动触发时运行测试、lint、模型 import 和 Debug 构建检查。
仅保留 `ci.yml`；上游发版、网站部署、PR 自动分流和 co-author 评论工作流已移除。CI 不需要
发布签名、Cloudflare、Homebrew tap 或通知凭据，工作流 token 仅需读取仓库内容。
安装脚本要求干净的 `main`，使用固定 DerivedData、本地签名和独立 Dev bundle，替换安装后验证
唯一进程路径；失败时恢复上一份 App。fork 不发布预编译版本。

## 入口和验证

- [维护 skill](../../.agents/skills/tinycast-fork-maintenance/SKILL.md)、[CI](../../.github/workflows/ci.yml)。
- [安装脚本](../../Scripts/install-dev-app.sh)、[开发文档](../development.md)、[签名说明](../signing.md)。
- 安装验收必须核对 `/Applications/Tinycast Dev.app` 的签名、bundle ID、进程路径和实例数量。

## 上游同步

关注项目生成、Debug bundle、构建路径、签名和 CI 工具链变化。保留 Dev 与正式版的设置及权限隔离。
同步后审阅 workflow 增量，避免恢复上游的发布、部署或 PR 自动处理流程。
GitHub 对 fork 的工作流禁用状态可能不反映在 permissions API 中；若没有运行记录，检查 Actions
页面的禁用提示并在已授权范围内启用，再核对当前提交对应的实际运行结果。
分支迁移是维护方式的 breaking change：旧 `fork` 和功能分支已退役，开发和安装须使用 `main`。
历史讨论：[PR #6](https://github.com/happy-proto/tinycast/pull/6)、[PR #11](https://github.com/happy-proto/tinycast/pull/11)。
