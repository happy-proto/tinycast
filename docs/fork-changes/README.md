# Fork 改造记录

`main` 是唯一维护分支，包含全部自有修改。[upstream-commit](upstream-commit) 记录最近一次
完成同步的上游 commit；实际差异以该基线到 `HEAD` 的 diff 为准，本目录解释目的、入口和维护边界。

```sh
git diff "$(cat docs/fork-changes/upstream-commit)" HEAD
```

| 编号 | 改造点 |
| --- | --- |
| 0001 | [单分支维护、CI 与 Dev App 安装](0001-maintenance-and-dev-app.md) |
| 0002 | [应用名称本地化](0002-app-name-localization.md) |
| 0003 | [简体中文界面与应用语言](0003-interface-localization.md) |
| 0004 | [测试环境与异步断言](0004-test-reliability.md) |

“维护中”表示代码仍有此改造，不替代最新测试、CI 或安装验收。
修改已有改造时更新原记录；新改造使用下一个编号，编号不重用，也不对应 PR 或固定 commit SHA。
每项可以包含多个目的相同的实现、修复和上游适配 commit，不强求压成一个提交。
上游吸收或移除改造时保留原文件，记录状态、吸收基线及残留差异；历史 PR 仅供追溯讨论。
同步后逐项复核记录与净 diff，验证完成后更新基线。操作方法见[维护 skill](../../.agents/skills/tinycast-fork-maintenance/SKILL.md)。
