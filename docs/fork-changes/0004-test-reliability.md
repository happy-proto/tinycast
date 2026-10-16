# 0004 测试环境与异步断言

状态：维护中。

## 为什么改

测试不应依赖本机 shell 配置、系统外观或异步执行的偶然顺序。固定等待和无契约保证的调用
顺序会导致环境型失败；按浅色像素测量布局的截图断言也不能跟随本机浅色外观。

## 如何改

CI 串行运行 harness，减少编译争用影响；本地保留 runner 的默认并行度。
原生输入表单测试固定测试进程的深色外观，使浅色文字的像素测量不受系统外观影响。

上游 `8d0d6b68` 已包含按状态等待的扩展生命周期测试，并删除旧 Codex 与已安装 CLI harness
及其 stub。原 fork 的 fish 隔离和旧异步断言补丁已退役，保留上游测试结构，不恢复被删除的文件。

## 入口和验证

- [原生输入表单测试](../../Tests/form-input-test.swift)、[输入控件](../../Tinycast/DesignSystem/FormTextInput.swift)。
- [扩展菜单栏 harness](../../Tests/ext-menu-bar-test.swift)、[CI](../../.github/workflows/ci.yml)。
- 按对应 harness 名称运行 [runner](../../Scripts/run-tests.sh)；完整同步运行全套测试。

## 上游同步

关注截图外观、扩展卸载及后台执行状态、授权串行化契约和测试 runner 变化。
上游已消除环境依赖或提供等价状态等待时移除重复修改；保留行为断言，不用加长固定 sleep 掩盖缺陷。
历史讨论：[PR #6](https://github.com/happy-proto/tinycast/pull/6)。
