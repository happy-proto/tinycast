# 0002 跟随系统语言

## 目的与行为

界面默认跟随系统，同时保留上游提供的九种显式语言。Follow System 移除当前应用 domain 的
`AppleLanguages` 覆盖；显式选择只读写应用自己的 domain，不把全局语言列表当作应用选择。
语言设置通过 `settings.json` 和备份保存。重启提示比较解析后的目标语言和进程当前使用的语言。
界面文字使用上游原生 catalog，只为 Follow System 补齐八种翻译。

## 入口与验证

- [语言模型](../../Tinycast/Features/Settings/AppLanguage.swift)、[持久化](../../Tinycast/Features/Settings/AppSettings.swift)、[重启提示](../../Tinycast/App/AppCore.swift)。
- [语言测试](../../Tests/language-test.swift) 覆盖系统跟随、显式覆盖、资源编译和多语言复数。
- `./Scripts/run-tests.sh language-test`；新增文字运行 `./Scripts/sync-strings.sh`。

## 同步边界

检查语言默认值、domain 隔离、设置镜像、备份和重启判断。安装验收还需确认语言切换后的可见界面。
