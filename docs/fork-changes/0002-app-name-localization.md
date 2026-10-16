# 0002 应用名称本地化

状态：维护中。

## 为什么改

应用的资源语言、地区和脚本标识不总与用户首选语言完全一致。启动器需要按系统语言选择正确
应用名称，同时保留可搜索的英文或原始名称。

## 如何改

通过 Foundation 解析候选本地化，结合 `InfoPlist.loctable`、`.lproj/InfoPlist.strings` 和开发语言
收集名称，按首选语言排序并去重。保留英文搜索，处理旧式开发语言名称和挪威语别名；
不让不支持的首选语言误触 Foundation 的英文回退，也不混用不同脚本的名称。

## 入口和验证

- [BundleLocalization](../../Tinycast/Platform/BundleLocalization.swift)。
- [名称回归测试](../../Tests/app-name-test.swift)、[启动器文档](../features/launcher.md)。
- 使用 `./Scripts/run-tests.sh app-name-test` 验证语言优先级、地区及脚本差异和资源回退。

## 上游同步

关注应用索引、Bundle 名称读取及 Foundation 语言匹配变化；按行为比较上游实现是否已覆盖这些
边界，不能仅因同名 helper 或“本地化”提交就删除改造。此项与应用界面 i18n 是独立目的。
历史讨论：[PR #3](https://github.com/happy-proto/tinycast/pull/3)。
