# 0003 简体中文界面与应用语言

状态：维护中。

## 为什么改

上游界面以英文为主，个人日常使用需要简体中文，并能在跟随系统、英文和简体中文之间选择。

## 如何改

使用 String Catalog 和显式本地化调用覆盖固定及动态界面文字，在设置中提供应用语言选项。
`AppleLanguages` 覆盖只读写当前 bundle 的 persistent domain，跟随系统时移除应用覆盖。
搜索目标和设置 anchor 保留未翻译的稳定身份；扩展相关本地化 helper 留在 Extensions 内部。
翻译之外保留品牌、技术示例和用户内容的原文语义。

## 入口和验证

- [String Catalog](../../Tinycast/Localizable.xcstrings)、[语言设置与 helper](../../Tinycast/Features/Settings/SettingsLocalization.swift)。
- [扩展 helper](../../Tinycast/Features/Extensions/Settings/ExtensionLocalization.swift)、[设置身份与语言测试](../../Tests/settings-history-test.swift)。
- [本地化检查](../../Scripts/check-localized-text.js) 由 [lint](../../Scripts/lint.sh) 调用；设置测试使用 `./Scripts/run-tests.sh settings-history-test`。
- 静态检查不能证明全部文字已翻译；安装后回读语言资源并验收代表性的动态、条件和间接呈现文本。

## 上游同步

此项每次同步都需专项审阅。检查新增设置、菜单、对话框、HUD、辅助说明、无障碍文字，以及
经模型属性、自定义组件或 presenter 传递的字符串；检查 SwiftUI 重载是否从可本地化 key 变成
普通 `String`，插值及数量格式是否与 catalog 一致。同步方法见 [i18n 专项检查](../../.agents/skills/tinycast-fork-maintenance/references/upstream-sync.md#i18n-专项检查)。

按修改目的维护多个 commit，新增适配明确说明覆盖的上游变化；不要把产品行为改造混进翻译提交。
关注语言切换、anchor 身份、资源构建配置和扩展隔离，不能以 rebase 无冲突替代覆盖审计。
历史讨论：[PR #2](https://github.com/happy-proto/tinycast/pull/2)。
