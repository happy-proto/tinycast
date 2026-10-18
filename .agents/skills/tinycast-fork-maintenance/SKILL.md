---
name: tinycast-fork-maintenance
description: 维护 happy-proto/tinycast 个人 fork；在开发或修复 fork 功能、同步上游、验证 main 或安装 Tinycast Dev App 时使用。不用于只涉及上游仓库的贡献。
---

# Tinycast Fork Maintenance

维护单一 `main` 上的 fork 自有提交，并确保本地运行的是对应的最新 Dev App。

## 固定约定

- `origin` 指向个人 fork `happy-proto/tinycast`，`upstream` 指向上游 `abue-ammar/tinycast`。
- `main` 是唯一维护分支和默认分支，直接承载所有 fork 修改。
- 一个独立改造对应一个完整 commit，包含实现、测试和文档；同步适配归入所属改造。
- [改造记录](../../../docs/fork-changes/README.md) 只说明当前仍需维护的改造。上游完整覆盖后删除对应实现、提交和记录，不保留退役说明或迁移流水。
- 同步时将 fork 自有 commits rebase 到最新 `upstream/main`，解决冲突并检查语义及覆盖面。
- fork 只保留测试和 Debug 构建 CI，不发布 Release、不部署网站，也不运行上游的 PR 自动处理工作流；同步后检查新增或恢复的 workflow。
- 同步上游默认包含必要的 rebase、提交整理，以及验证后通过精确 SHA 的 `--force-with-lease` 覆盖推送 `origin/main`，不额外确认；用户明确要求仅本地或不推送时除外。普通开发的提交、推送及 App 安装仍遵循当前任务授权。

## 按需读取

- 实现、验证、提交并交付修改：读取 [development-delivery.md](references/development-delivery.md)。
- 构建、安装或验证 Dev App：读取 [dev-app.md](references/dev-app.md)。
- 同步上游：读取 [upstream-sync.md](references/upstream-sync.md)。
