# Tinycast · 个人 Fork

> 一个面向个人日常使用的 [Tinycast](https://github.com/abue-ammar/tinycast) 定制版本。

Tinycast 是原生 macOS 启动器。功能介绍、安装方式、构建方法和项目文档均以上游仓库为准；
这里仅记录这个 fork 为什么存在，以及它如何维护。

[查看上游](https://github.com/abue-ammar/tinycast) ·
[查看维护 Stack](https://github.com/happy-proto/tinycast/pull/1) ·
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
git clone --branch integration/current https://github.com/happy-proto/tinycast.git
cd tinycast
open Tinycast.xcodeproj
```

在完整的 `integration/current` 分支上运行安装脚本：

```sh
./Scripts/install-dev-app.sh
```

脚本会使用固定的 DerivedData 路径构建并签名 App，然后覆盖安装到
`/Applications/Tinycast Dev.app`。Dev App 使用独立的应用名称、设置和系统权限，可以与正式版
同时存在；不要再从 DerivedData 启动第二份同 Bundle ID 的 Dev App。

更新时，将本地 `integration/current` 同步到远端最新状态，再次运行安装脚本。稳定的安装路径和
本地签名会让 macOS 保留已经授予的辅助功能权限。更多细节见[开发文档](docs/development.md)。

## 使用风险

> [!WARNING]
> 我不了解 macOS 开发。这个 fork 的专属代码全部由 AI 编写，我不会对具体实现进行代码审查。
> 这些修改未经专业维护或安全审计，请自行判断使用风险。

## 维护方式

这个 fork 会尽量跟进上游。所有自维护功能通过 GitHub 原生 stacked PR 组织成线性历史：

```text
上游 main → fork main → 功能 PR stack → integration/current
```

- `main` 只跟随上游，不包含 fork 专属修改。
- 每个 PR 记录一个功能对应的历史分段，可以完全依赖前一层。
- 功能层可以插入、删除或调整；其上层分支随后统一 rebase。
- `integration/current` 始终指向完整 stack 顶部，也是仓库默认展示的分支。
- [PR #1](https://github.com/happy-proto/tinycast/pull/1) 是当前 stack 顶层，可通过 GitHub 的
  stack map 查看所有功能层及其状态。
