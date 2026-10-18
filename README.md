# Tinycast · 个人 Fork

> 一个面向个人日常使用的 [Tinycast](https://github.com/abue-ammar/tinycast) 定制版本。

Tinycast 是原生 macOS 启动器。功能介绍、安装方式、构建方法和项目文档均以上游仓库为准；
这里仅记录这个 fork 为什么存在，以及它如何维护。

[查看上游](https://github.com/abue-ammar/tinycast) ·
[改造记录](docs/fork-changes/README.md) ·
[AGPL-3.0](LICENSE)

## 当前关注

| 功能 | 目的 |
| --- | --- |
| 应用名称本地化 | 按用户首选语言识别和搜索应用名称 |
| 跟随系统语言 | 让界面默认使用系统语言，同时保留显式语言选择 |
| 设置搜索定位 | 使用稳定标识区分同译文分区，准确跳转和高亮搜索结果 |

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

这个 fork 只维护一个 `main` 分支。每项独立改造对应一个完整 commit，包含实现、测试和文档，
便于逐项适配或撤销。

```text
upstream/main → fork 自有 commits → main
```

同步上游时，获取最新 `upstream/main`，把 fork 自有提交 rebase 到它之上，解决冲突并适配
上游变化，验证后默认使用带明确旧 SHA 的 `--force-with-lease` 更新 `origin/main`，无需额外确认；
明确要求仅本地同步或不推送时除外。

同步适配归入对应改造的 commit；上游已完整覆盖的改造，其实现、提交和记录一起移除。
文档只解释当前需要维护的行为，不记录废弃方案和迁移过程。界面翻译使用上游原生资源。
具体流程见[同步约定](.agents/skills/tinycast-fork-maintenance/references/upstream-sync.md)。
各项改造的目的、代码入口和长期维护边界见[改造记录](docs/fork-changes/README.md)，已验证的上游
基线单独记录，便于检查实际剩余差异。
