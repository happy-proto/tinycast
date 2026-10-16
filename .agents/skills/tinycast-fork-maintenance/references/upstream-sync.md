# 同步上游

同步将 `main` 上的 fork 自有 commits 重放到最新 `upstream/main`。以提交的修改目的为单位维护，
既解决冲突，也检查上游新增表面是否需要适配；没有文本冲突不代表行为和翻译覆盖仍然完整。

## 建立基线

1. 确认当前为 `main`，工作区干净；不要 stash 或覆盖无关用户改动。
2. Fetch `origin` 和 `upstream`，记录当前 head、`origin/main` 的 SHA。读取
   [upstream-commit](../../../../docs/fork-changes/upstream-commit) 作为旧上游基线并确认它是当前 head 的祖先。
   核对本地与远端关系，先纳入远端新增提交，不用本地旧历史覆盖它们。
3. 在仓库外创建并验证 Git bundle，保留旧 main 和上游引用；记录用于推送 lease 的远端 SHA。
4. 用旧上游基线到新 `upstream/main` 的增量审阅功能、重构、删除、生成物、测试和治理变化。
   结合 [改造记录](../../../../docs/fork-changes/README.md) 和
   `git log --reverse <旧基线>..main` 阅读 fork 提交及其目的，不从旧 PR 或固定编号推断职责。

若上游改写过公开历史，先比较旧、新基线，确认语义等价的分界点。使用
`git rebase --onto upstream/main <确认的旧上游边界> main` 只移植 fork 提交，避免重放旧上游历史。
若普通 rebase 在无关旧路径产生大量冲突，先 abort 并重查边界。

## 重放与适配

通常执行 `git rebase upstream/main`。对每个受影响提交先理解上游意图，再按原目的适配新结构，
不要机械选择 ours/theirs 或恢复已经淘汰的 API。保留清晰的提交边界，不把整套 fork squash。

- 无语义交集：重放后检查净变化是否漂移。
- 上游重构或新增入口：移植到新结构并补齐覆盖，相关测试及文档随之更新。
- 上游已吸收同一目的：核对行为后移除重复提交或缩小修改，不只凭提交标题判断。
- 同步中发现的额外适配按目的单独提交；不把无关行为修改混入 i18n。

使用旧、新提交序列的 `git range-diff` 和相对新上游的净 diff 检查遗漏、重复和意外回退。

## i18n 专项检查

每次同步均检查上游新增或改名的设置、按钮、菜单、对话框、HUD、占位符、帮助与无障碍文本，
以及运行时拼接的可见字符串。确认沿用已有 key 和默认值约定，String Catalog 翻译完整，相关
本地化 lint 和 harness 覆盖新入口。

不要只搜索 `Text("…")`：直接阅读上游新建或重写的 UI，以及模型到 UI 的文字路径，尤其检查：

- 先存入 `String`、模型或枚举属性，再交给 view 的文字。
- 通过自定义 view、菜单数据、搜索占位符或 presenter 间接呈现的文字。
- 条件标题、字符串拼接、插值、数量、格式化参数和运行时 catalog key 的签名。
- view 抽取、移动或改名后，从 `LocalizedStringKey` 变成普通 `String` 的重载。
- helper 的 feature 归属，避免为本地化破坏模块隔离。

静态 lint 只证明已覆盖的模式。需要安装验收时，从最终安装包回读语言资源，并验证有代表性的
动态和间接呈现文本。

## 验证与推送

逐项复核改造记录，更新适配、吸收或退役状态。完成 rebase 和适配后运行项目验证，通过后将
`upstream-commit` 更新为本次采用的精确上游 SHA，并提交记录变更。安装验收按 [dev-app.md](dev-app.md) 执行。
用户授权推送后，用基线阶段记录的精确 SHA 保护远端：

```sh
git push --force-with-lease=refs/heads/main:<同步前记录的远端SHA> origin main:main
```

lease 被拒绝时停止强推，读取并整合远端变化后重新验证。不要刷新 lease 后盲目覆盖。
推送后独立读取 `origin/main` 和 CI，核对本地、远端及默认分支，最后保持 checkout 在 `main`。

## 同步报告

按产品行为和重要维护变化概述相对旧上游基线新增的内容，再说明 fork 修改中哪些仅重放、哪些
适配或已被上游吸收，以及 i18n 覆盖检查和验证结果。区分 CI、安装和可见行为的实际状态。
