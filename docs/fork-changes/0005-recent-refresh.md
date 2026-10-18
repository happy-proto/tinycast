# 0005 等待文件搜索 Recent 刷新

## 目的与行为

文件搜索 Recent 刷新返回可等待的任务。测试在预取完成后检查缓存即时显示，避免依赖固定等待。
200ms 的模拟延迟覆盖预取超过固定等待时间的情况；前台搜索和缓存更新行为保持一致。

## 入口与验证

- [会话服务](../../Tinycast/Features/FileSearch/Service/FileSearchSession.swift)。
- [会话测试](../../Tests/file-search-session-test.swift)。
- `./Scripts/run-tests.sh file-search-session-test` 验证刷新完成、前台结果及取消行为。

## 同步边界

检查 Recent 刷新任务的生命周期和完成条件；上游提供等价的可等待边界后移除此改造。
