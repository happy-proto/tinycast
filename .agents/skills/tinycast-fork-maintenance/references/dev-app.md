# Dev App

最终本地验收使用 `/Applications/Tinycast Dev.app`。`build/DerivedData` 是稳定构建来源，不是
最终安装位置；不要同时运行两个路径下的同 Bundle ID 实例。

## 安装前提

- 当前分支必须是 `integration/current`。
- 工作区必须干净，确保 App 对应一个可识别的完整 stack commit。
- 本地 `integration/current` 必须已经包含本次目标层及所有上层修改。
- 本机存在 `Tinycast Self-Signed` 签名身份。

## 构建与安装

运行仓库脚本：

```sh
./Scripts/install-dev-app.sh
```

脚本负责从固定 DerivedData 构建、校验 bundle 和签名、停止所有 Dev 副本、替换
`/Applications/Tinycast Dev.app`、启动新实例并验证唯一进程。不要在脚本之后再用
`open -n build/DerivedData/...` 启动第二份 App。

## 验收

除了脚本的结构性校验，还要按需求验证可见行为。涉及本地化时，从最终安装包回读目标语言
资源，并确认界面来自 `/Applications` 进程；仅检查源码或 String Catalog 不足以证明安装生效。
