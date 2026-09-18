# Stacked PR

使用 GitHub 官方 `github/gh-stack` 扩展。由于 `origin` 是上游，远端操作必须明确指向 fork：

```sh
GH_REPO=happy-proto/tinycast gh stack view --json
```

支持 `--remote` 的写命令一律指定 `--remote fork`。若裸 PR 编号被解析到上游，使用
`GH_REPO=happy-proto/tinycast` 和完整的 fork PR URL。

`gh-stack` 的部分命令仍会从名为 `origin` 的 remote 写入本地 stack 仓库身份，忽略 `GH_REPO`；本仓库
的 `origin` 恰好是上游。导入或写入后检查 `.git/gh-stack` 的 `repository`、目标 stack 的 REST URL
和 PR URL，不能只信命令成功输出。若目标被解析成上游，停止继续写入，不要通过重命名 remotes 破坏
本仓库约定。

## 修改已有功能层

在目标功能层提交并完成验证后，先级联更新所有上层分支，再统一推送：

```sh
GH_REPO=happy-proto/tinycast gh stack rebase --upstack --remote fork
GH_REPO=happy-proto/tinycast gh stack push --remote fork
```

不要先单独推送被修改的底层分支。级联 rebase 会改变该层及其上层 commit SHA，可能重新触发
CI 或使 review 失效，但应保留 PR 编号和讨论。

## 调整结构

- 插入、删除、折叠、重命名或重排功能层时使用 `gh stack modify`，不要手工改 PR base 模拟。
- 创建或更新 PR 并重新关联 stack 时使用 `gh stack submit --remote fork`。
- 不擅自改变 draft 状态。
- 新 PR 使用中文标题和描述，说明功能目的和依赖层；普通验证命令留在交付回复，不堆进正文。

删除已被上游吸收的层时，先让其上层分支直接基于下一层并统一推送，再解除 GitHub 上旧 stack 的
关联，更新上层 PR base，最后关闭 PR 和删除远端分支。GitHub 会拒绝修改仍属于 stack 的 PR base；
遇到这个错误时不要反复 `pr edit`。先读取 `GET repos/<fork>/stacks/<number>` 确认 stack 内容，再用
官方 unstack 操作；若扩展因 `origin` 指向上游而路由错误，可对已确认的 fork URL 调用同一个官方
`POST repos/<fork>/stacks/<number>/unstack` 端点。收到瞬时网络错误后必须重新 GET：请求可能已经成功，
不要盲目重试写操作。

结构写入后重新读取 PR base/head 和远端 refs。Git 历史与 PR base 已线性但 GitHub 暂时拒绝重新创建
可视 stack map 时，明确报告平台层状态，不要把它误报成 Git 结构失败，也不要为恢复 UI 关联改坏分支。

## 完成检查

推送后回读每个 PR 的 base/head、状态、检查和 mergeability，并确认：

- 历史仍然线性，没有层需要 rebase。
- `integration/current` 是 stack 顶部和仓库默认分支。
- 本地目标分支与 fork 远端一致。

CI 可以检查关系和运行测试，但不自动 rebase 或强推 stack。GitHub 自动调整剩余层后，先读取
远端状态再同步本地，不用陈旧历史覆盖远端。
