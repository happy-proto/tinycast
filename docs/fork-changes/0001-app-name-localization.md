# 0001 应用名称本地化

## 目的与行为

按系统首选语言选择应用名称，同时保留英文或原始名称供搜索。通过 Foundation 匹配 bundle
实际提供的语言、地区和脚本，读取 `InfoPlist.loctable` 与 `.lproj/InfoPlist.strings`。
不让不支持的首选语言抢先触发英文回退，不混用不同脚本，处理旧式开发语言和挪威语别名。
名称索引使用 `SystemLanguages.preferred`，不受 Tinycast 自身的界面语言覆盖影响。

## 入口与验证

- [BundleLocalization](../../Tinycast/Platform/BundleLocalization.swift)。
- [名称回归测试](../../Tests/app-name-test.swift)、[启动器文档](../features/launcher.md)。
- `./Scripts/run-tests.sh app-name-test` 覆盖资源优先级、地区及脚本差异和开发语言回退。

## 同步边界

检查上游应用索引和 Bundle 名称读取是否已覆盖这些行为；按回归用例判断，不能仅凭同名 helper。
