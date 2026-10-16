# Tinycast · 个人 Fork

> 一个面向个人日常使用的 [Tinycast](https://github.com/abue-ammar/tinycast) 定制版本。

Tinycast 是原生 macOS 启动器。功能介绍、安装方式、构建方法和项目文档均以上游仓库为准；
这里仅记录这个 fork 为什么存在，以及它如何维护。

[查看上游](https://github.com/abue-ammar/tinycast) ·
[查看自维护修改](https://github.com/abue-ammar/tinycast/compare/main...happy-proto:tinycast:main) ·
[AGPL-3.0](LICENSE)

## 当前关注

| 功能 | 目的 |
| --- | --- |
| 应用名称本地化 | 按用户首选语言识别和搜索应用名称 |
| 简体中文界面 | 翻译 Tinycast 界面并提供应用语言选项 |

这个 fork 只处理我实际遇到的问题，并加入少量符合个人习惯的定制。它不是面向所有用户的
通用发行版；如果你的需求不同，建议从上游创建自己的 fork。

## 安装与更新

这个 fork 不发布预编译版本，通过 Xcode 构建独立的 `Tinycast Dev.app`。需要 macOS 26 和
Xcode 26；第一次构建前，按照[签名说明](docs/signing.md#1-create-the-tinycast-self-signed-identity-once)
创建一次本地签名证书。

```sh
git clone https://github.com/happy-proto/tinycast.git
cd tinycast
open Tinycast.xcodeproj
```

在 `main` 分支上运行安装脚本：

```sh
./Scripts/install-dev-app.sh
```

脚本会使用固定的 DerivedData 路径构建并签名 App，然后覆盖安装到
`/Applications/Tinycast Dev.app`。Dev App 使用独立的应用名称、设置和系统权限，可以与正式版
同时存在；不要再从 DerivedData 启动第二份同 Bundle ID 的 Dev App。

更新时，将本地 `main` 同步到远端最新状态，再次运行安装脚本。稳定的安装路径和
本地签名会让 macOS 保留已经授予的辅助功能权限。更多细节见[开发文档](docs/development.md)。

## 使用风险

> [!WARNING]
> 我不了解 macOS 开发。这个 fork 的专属代码全部由 AI 编写，我不会对具体实现进行代码审查。
> 这些修改未经专业维护或安全审计，请自行判断使用风险。

## 维护方式

这个 fork 只维护一个 `main` 分支，所有修改直接在这里完成，以 commit 记录各项修改的目的。
应用名称本地化、i18n 和维护工具保持清晰的提交边界，便于逐项适配或撤销。

```text
upstream/main → fork 自有 commits → main
```

同步上游时，获取最新 `upstream/main`，把 fork 自有提交 rebase 到它之上，解决冲突并适配
上游变化，验证后使用带明确旧 SHA 的 `--force-with-lease` 更新 `origin/main`。

i18n 等修改需要每次重新检查上游新增或重构的界面、动态文字和翻译资源；没有文本冲突也可能
遗漏翻译。同步时按提交目的检查净变化，保留仍然需要的定制，移除已被上游完整吸收的修改。
具体流程见[同步约定](.agents/skills/tinycast-fork-maintenance/references/upstream-sync.md)。
