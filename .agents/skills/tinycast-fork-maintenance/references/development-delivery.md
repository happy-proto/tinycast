# 开发与交付

修改前读取项目 `AGENTS.md` 以及任务涉及的开发、架构、功能和测试文档。

## 开发顺序

1. 读取 [change-routing.md](change-routing.md)，定位目标功能层并切换到该分支。
2. 保留用户已有改动，在目标层实现需求。
3. 完成项目 Definition of Done 和与风险匹配的专项验证。
4. 用户授权提交后，在目标层创建范围明确的 commit。
5. 读取 [stacked-pr.md](stacked-pr.md)，在本地级联 rebase 所有上层分支。
6. 需要最终本地验收时，切换到 `integration/current`，读取 [dev-app.md](dev-app.md) 并安装
   完整集成版本。不要用目标功能层或 DerivedData 中的临时实例代替最终集成验收。
7. 本地集成验证通过且用户已授权推送后，统一推送 stack。
8. 回读 PR 和默认分支状态，最后保持 checkout 在干净的 `integration/current`。

如果用户没有授权提交或历史改写，只在目标层完成工作区验证；不要声称未进入
`integration/current` 的修改已经完成集成安装。

## 验证边界

- 区分源码检查、测试、构建、安装、进程启动和可见行为验收。
- 构建成功不代表 `/Applications` 中的 App 已更新。
- 安装成功不代表当前窗口来自新实例；必须验证进程路径和实例数量。
- 首轮完整测试中的环境型失败可以单独复跑定位，但应如实报告两次结果。
