# 0008 个人 Fork 维护

## 目的与行为

`main` 包含选定的上游基线与全部自有改造，直接在该分支开发。
`origin` 指向 `happy-proto/tinycast`，`upstream` 指向 `abue-ammar/tinycast`。
每项独立改造对应一个完整 commit，包含实现、测试和文档；同步适配归入所属 commit。
上游完整覆盖的改造连同提交和记录一起移除，文档只解释当前净变化。

## 入口与验证

- [维护 skill](../../.agents/skills/tinycast-fork-maintenance/SKILL.md)、[项目约定](../../AGENTS.md)。
- [改造索引](README.md)、[上游基线](upstream-commit)。
- 核对基线是 `main` 的祖先，按基线到 `HEAD` 的净 diff 检查每个提交和记录的范围。

## 同步边界

重放前备份完整 Git 历史，确认远端没有遗漏提交；推送使用操作前精确 SHA 作为 lease。
同步上游默认包含必要的历史整理及验证后的覆盖推送，不额外确认；明确要求仅本地或不推送时除外。
不重放旧上游历史，不把所有改造合并为一笔；普通开发的提交、推送及 App 安装遵循当前任务授权。
