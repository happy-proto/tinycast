# 0003 设置搜索定位

## 目的与行为

设置搜索结果打开对应页面后，滚动到目标分区或选项并高亮。不同标题可能译为相同文字，
例如 Calendar 和 Calendars 都显示“日历”；定位标识不能依赖译文。
Anchor 的相等性和哈希、搜索结果 ID 及行定位使用原始资源 key，显示仍使用译文。
带图标和普通设置行均保留 `LocalizedStringResource`，直到建立定位标识。

## 入口与验证

- [Anchor](../../Tinycast/Features/Settings/SettingsAnchor.swift)、[搜索目录](../../Tinycast/Features/Settings/SettingsSearchCatalog.swift)。
- [定位视图](../../Tinycast/Features/Settings/SettingsScrollTarget.swift)、[共享设置行](../../Tinycast/DesignSystem/SettingsComponents.swift)。
- `./Scripts/run-tests.sh settings-history-test` 覆盖同译文分区，以及翻译变化后的行定位和结果 ID。

## 同步边界

检查新增或抽取的设置行是否在传递过程中丢失原始 key；静态检查和编译不能替代实际跳转验收。
