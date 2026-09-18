# Stacked PR

使用 GitHub 官方 `github/gh-stack` 扩展。由于 `origin` 是上游，远端操作必须明确指向 fork：

```sh
GH_REPO=happy-proto/tinycast gh stack view --json
```

支持 `--remote` 的写命令一律指定 `--remote fork`。若裸 PR 编号被解析到上游，使用
`GH_REPO=happy-proto/tinycast` 和完整的 fork PR URL。

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

## 完成检查

推送后回读每个 PR 的 base/head、状态、检查和 mergeability，并确认：

- 历史仍然线性，没有层需要 rebase。
- `integration/current` 是 stack 顶部和仓库默认分支。
- 本地目标分支与 fork 远端一致。

CI 可以检查关系和运行测试，但不自动 rebase 或强推 stack。GitHub 自动调整剩余层后，先读取
远端状态再同步本地，不用陈旧历史覆盖远端。
