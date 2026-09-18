---
name: tinycast-fork-maintenance
description: 维护 happy-proto/tinycast 个人 fork；在判断需求所属 PR、开发或修复 fork 功能、维护 stacked PR、同步上游、验证完整集成分支，或安装 Tinycast Dev App 时使用。不用于只涉及上游仓库的贡献。
---

# Tinycast Fork Maintenance

维护 fork 的线性功能历史，并确保本地运行的是完整 stack 的最新 Dev App。

## 固定约定

- `origin` 指向上游 `abue-ammar/tinycast`，`fork` 指向 `happy-proto/tinycast`。
- `main` 只跟随上游 `main`，不承载 fork 专属修改。
- 功能 PR 可以完全依赖前一层；分层记录修改为什么存在，不要求功能彼此独立。
- `integration/current` 始终是完整 stack 顶部和 fork 默认分支。
- 不硬编码当前 PR 编号或层级。涉及分支或平台状态时，先读取实时 stack。
- 提交、推送、历史改写、创建或更新 PR，以及安装 App，仍分别受用户授权范围约束。

## 按需读取

- 判断修改现有 PR 还是创建新层：读取 [change-routing.md](references/change-routing.md)。
- 实现、验证、提交并交付修改：读取 [development-delivery.md](references/development-delivery.md)。
- 查看或改变 stack、分支、PR base/head：读取 [stacked-pr.md](references/stacked-pr.md)。
- 构建、安装或验证 Dev App：读取 [dev-app.md](references/dev-app.md)。
- 同步上游：读取 [upstream-sync.md](references/upstream-sync.md)，并按其中路由继续读取其它 reference。

一个任务跨越多个阶段时，读取每个相关 reference；不要加载与当前任务无关的文档。
