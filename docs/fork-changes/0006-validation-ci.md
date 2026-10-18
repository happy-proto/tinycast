# 0006 验证 CI

## 目的与行为

只保留 `ci.yml`，在 `main` push、面向 `main` 的 PR 和手动触发时运行验证。
检查 XcodeGen 生成结果、完整 harness、lint、Model import 和无签名 Debug 构建。
主验证使用 Xcode 27，串行运行 harness；真实 OCR 在 macOS 26 独立 job 中验证，
避开 macOS 27 托管虚拟机无法编译 accurate 识别模型的问题。完整 CI 不跳过 OCR 覆盖。
runner 保持崩溃结果单行，并将系统诊断附加到失败日志；回归脚本覆盖崩溃和单项排除。
工作流只需读取仓库内容，不使用发布、网站部署、镜像或通知凭据。

## 入口与验证

- [CI](../../.github/workflows/ci.yml)、[测试约定](../testing.md)、[构建与分发](../release.md)。
- 推送后核对当前精确 SHA 对应的全部检查结果。

## 同步边界

检查上游新增 workflow 和工具链变化，只保留 fork 需要的验证。
若推送没有产生运行记录，检查 Actions 页面是否禁用了 fork workflow，再核对实际运行状态。
