# 0007 Dev App 安装

## 目的与行为

从干净的 `main` 构建完整 `Tinycast Dev.app`，使用固定 DerivedData 和本地签名，安装到
`/Applications/Tinycast Dev.app`。替换后只启动一个该路径下的实例；安装失败恢复原 App。
Dev 与正式版保持独立 bundle ID、设置和权限，固定路径及签名维持已有辅助功能授权。

## 入口与验证

- [安装脚本](../../Scripts/install-dev-app.sh)、[Dev App 工作流](../../.agents/skills/tinycast-fork-maintenance/references/dev-app.md)。
- [开发文档](../development.md)、[签名说明](../signing.md)。
- 安装验收核对签名、bundle ID、进程路径、实例数量及目标可见行为。

## 同步边界

检查项目生成、Debug bundle、构建路径和签名变化；构建成功不等于已安装或正在运行新实例。
