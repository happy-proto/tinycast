# Fork 改造记录

每项独立改造对应一个完整 commit，包含实现、测试和文档。本目录只解释当前仍需维护的净变化。

[upstream-commit](upstream-commit) 记录当前上游基线；它是 `main` 的祖先。

```sh
git diff "$(cat docs/fork-changes/upstream-commit)" HEAD
```

| 编号 | 改造点 |
| --- | --- |
| 0001 | [应用名称本地化](0001-app-name-localization.md) |
| 0002 | [跟随系统语言](0002-system-language.md) |
| 0003 | [设置搜索定位](0003-settings-search-identity.md) |
| 0004 | [表单测试外观](0004-form-test-appearance.md) |
| 0005 | [等待文件搜索 Recent 刷新](0005-recent-refresh.md) |
| 0006 | [验证 CI](0006-validation-ci.md) |
| 0007 | [Dev App 安装](0007-dev-app-installation.md) |
| 0008 | [个人 Fork 维护](0008-fork-maintenance.md) |

同步适配归入所属 commit；上游完整覆盖的改造，其实现、提交和记录一起移除。
