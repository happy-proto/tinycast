---
name: tinycast-fork-maintenance
description: 维护 happy-proto/tinycast 个人 fork；在开发或修复 fork 功能、同步上游、验证 main 或安装 Tinycast Dev App 时使用。不用于只涉及上游仓库的贡献。
---

# Tinycast Fork Maintenance

维护单一 `main` 上的 fork 自有提交，并确保本地运行的是对应的最新 Dev App。

## 固定约定

- `origin` 指向个人 fork `happy-proto/tinycast`，`upstream` 指向上游 `abue-ammar/tinycast`。
- `main` 是唯一维护分支和默认分支，直接承载所有 fork 修改，不再维护功能分支或 stacked PR。
- 以 commit 作为修改单元，按目的区分应用名称本地化、i18n、工具等修改；适配提交也保持目的明确。
- [改造记录](../../../docs/fork-changes/README.md) 是长期维护索引；修改时更新对应记录，新增改造使用下一个编号，退役时保留记录并更新状态。
- 同步时将 fork 自有 commits rebase 到最新 `upstream/main`，解决冲突并检查语义及覆盖面。
- 同步授权包含上述必要 rebase；提交、推送和安装 App 仍分别受用户当前任务授权范围约束。

## 按需读取

- 实现、验证、提交并交付修改：读取 [development-delivery.md](references/development-delivery.md)。
- 构建、安装或验证 Dev App：读取 [dev-app.md](references/dev-app.md)。
- 同步上游：读取 [upstream-sync.md](references/upstream-sync.md)。
