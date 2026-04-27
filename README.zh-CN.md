# harness-project-template

[English](README.md) | **中文**

一个用于快速搭建 **Python + FastAPI 服务**的 GitHub 模板，从第一天起就为多智能体协作（Claude Code、Codex、Cursor、人类）做好准备。

## 这个模板要解决什么

大多数所谓"对智能体友好"的项目脚手架都和某个工具强绑定：要么是一个 `.cursor/` 目录，要么是一份 `.claude/` 配置，要么是一个 `.codex/` 规则文件。换工具，就得把项目从头解释一遍。

这个模板把**工作流**而不是**工具**当成事实源。规则——怎么写需求、怎么拆任务、怎么 review——都写在 `.agents/skills/` 下的 Markdown 里，工具无关。Claude Code 和 Codex 原生自动发现这个路径，其他工具也能直接读这些文件。所以不管下一个贡献者用 Claude、Codex、Cursor 还是裸 VS Code，都遵循同一套门控流程：

```
SPEC  →  PLAN  →  BUILD  →  REVIEW  →  SHIP
```

CI 对所有人（也对所有工具）执行同样的检查，没人能绕。

## 开箱即得

- **可跑的 FastAPI 骨架** —— `src/di2vibe/` 含一个 `/health` 端点和异步测试。`di2vibe` 是占位包名，30 秒就能换成你的（见 [Bootstrap](#1-bootstrap-一条命令)）。
- **工具无关的工作流 skill** —— `.agents/skills/` 下六个精简过的 playbook，覆盖写需求、拆任务、增量实现、TDD、code review、git 流程。
- **预接好的质量门** —— `ruff`（lint + format）+ `mypy --strict`（仅作用于 `src/`）+ `pytest`（asyncio 模式），本地 pre-commit hook 和 GitHub Actions 双重把关。
- **Claude Code 的 slash 命令** —— `/spec`、`/plan`、`/build`、`/review` 各自包装对应的 skill。
- **其他工具的等价 prompt** —— 同样的流程在 `.agent/prompts/` 下以纯文本 prompt 形式提供。
- **一键 bootstrap 脚本** —— `scripts/init-template.sh` 自动装 `uv`、改包名、装依赖、装 hook、跑 gate。幂等。

`src/` 下的 `di2vibe` 只是示例占位，bootstrap 时会被改成你的服务名。

## 如何使用本模板

### 方式 A —— GitHub 网页

1. 打开 <https://github.com/luoli523/harness-project-template>。
2. 点 **Use this template → Create a new repository**。
3. 起名字、选 owner/可见性，点 **Create repository from template**。
4. `git clone` 你的新仓库，然后跳到下面的 [Bootstrap](#post-clone-初始化) 部分。

### 方式 B —— GitHub CLI

```bash
gh repo create <你的-org>/<你的-服务> \
  --template luoli523/harness-project-template \
  --private --clone
cd <你的-服务>
```

接下来按下文操作。

## Post-clone 初始化

### 1. Bootstrap（一条命令）

```bash
./scripts/init-template.sh <你的_包名>
# 例如 ./scripts/init-template.sh orders_api
```

这一条脚本干完了过去所有手动步骤：

1. 没装 `uv` 就装上。
2. 把示例包 `di2vibe` 重命名成 `<你的_包名>`，覆盖源码、测试、`pyproject.toml`、`uv.lock`、文档（脚本自身排除）。
3. 跑 `uv sync --all-extras`。
4. 跑 `uv run pre-commit install`。
5. 跑完整的 gate 链（`ruff` + `mypy` + `pytest`），让你在写第一行代码之前就确认骨架是绿的。

脚本是幂等的——重命名后再跑一次只会重新 sync 依赖、重跑 gate，不会破坏已有状态。全部绿了之后启动 dev server：

```bash
uv run uvicorn <你的_包名>.main:app --reload   # → http://localhost:8000/health
```

### 2. 把它变成你的项目

- 改 `AGENTS.md` —— 如果换掉了 FastAPI/uv 等技术栈，更新 **Tech Stack** 那一行；删掉不适用的部分。这份文件是所有 agent 读的事实源。
- 改这份 `README.md` —— 把"模板介绍"换成你的服务介绍。仓库实例化之后，"Use this template" 和 "Post-clone 初始化" 两节就不再适用了。
- 删 `scripts/init-template.sh` —— 一次性的 bootstrap 工具，不该长期保留。
- 删示例的 `src/<你的_包>/api/health.py` 及其测试（除非你想留作 liveness 探针）。
- 在 `spec/<feature>.md` 下写第一份真正的 spec（用 Claude Code 的话直接 `/spec <feature>`）。

### 3. 配上分支保护

CI 在 push 到 `main` 和每个 PR 时跑——见 `.github/workflows/ci.yml`。仓库到 GitHub 上之后，给 `main` 分支加一条保护规则，要求 `lint-type-test` 这个 check 必须通过才允许合入。

## 工作流是怎么运作的

任何变更——新功能、bug 修复、重构——都走同一条门控流程：

```
SPEC  →  PLAN  →  BUILD  →  REVIEW  →  SHIP
```

| 阶段 | 产出 | Skill | Claude 命令 |
|---|---|---|---|
| **SPEC** | `spec/<feature>.md`，描述这次要做什么 | `spec-driven-development` | `/spec <feature>` |
| **PLAN** | 任务列表，每个任务 ≤ 100 行，附验收标准 | `planning-and-task-breakdown` | `/plan spec/<feature>.md` |
| **BUILD** | 一次一个任务，TDD 优先（红 → 绿 → 重构） | `incremental-implementation`、`test-driven-development` | `/build spec/<feature>.md T<n>` |
| **REVIEW** | 按 5 轴清单自查 | `code-review-and-quality` | `/review` |
| **SHIP** | PR 链回 spec、CI 绿、至少一人 review | `git-workflow-and-versioning` | — |

skill playbook 都在 `.agents/skills/<name>/SKILL.md`。Claude Code 和 Codex 都会自动发现这个路径。完整规则见 [AGENTS.md](AGENTS.md)。

## 质量门

同一套 gate 在三个地方跑（纵深防御，不是冗余）：

| 在哪 | 什么时候 | 工具 |
|---|---|---|
| **pre-commit hook** | 每次 `git commit` 之前 | 行尾空格 / 文末换行 / yaml / toml / 大文件 / merge 冲突标记；`ruff --fix`；`ruff-format`；针对 `src/` 的 `mypy` |
| **`scripts/init-template.sh`** | bootstrap 之后 | `ruff` + `ruff format --check` + `mypy` + `pytest` |
| **GitHub Actions CI** | 每次推 `main`、每个 PR | `ruff` + `ruff format --check` + `mypy` + `pytest` |

Hook 提供亚秒级反馈；CI 是不可绕的底线。AGENTS.md 明确禁止 `--no-verify`。

## 仓库结构

```
AGENTS.md                所有 agent 的事实源
CLAUDE.md                指向 AGENTS.md（Claude Code 启动会话时自动读）

src/<你的_包>/           应用代码（从 di2vibe 改名而来）
tests/                   与 src/ 镜像
spec/                    每个 feature 一份 .md

.agents/skills/          工作流 playbook（工具无关，会被自动发现）
.agent/prompts/          同样的流程，给不支持 skill 的工具的纯文本 prompt
.claude/                 Claude Code 的命令和权限

docs/
  references/            testing-patterns.md、security-checklist.md
  workflows/             pr-flow.md、commit-conventions.md

scripts/init-template.sh 一次性 bootstrap（用完即删）
.github/workflows/ci.yml CI：ruff → ruff format --check → mypy → pytest
.pre-commit-config.yaml  本地 commit 前跑同一组 gate
pyproject.toml           依赖、ruff/mypy/pytest 配置
```

## 各类 agent 的入口

| 工具 | 怎么用 |
|---|---|
| **Claude Code** | `/spec`、`/plan`、`/build`、`/review`（定义在 `.claude/commands/`） |
| **Codex CLI** | 输入 `$<skill-name>` 显式提及，或 `/skills` 选 —— `.agents/skills/` 是原生支持 |
| **Cursor / Aider / 其他** | 打开 `.agents/skills/<name>/SKILL.md`，或粘贴 `.agent/prompts/*.md` 里对应的 prompt |
| **人类** | 先读 [AGENTS.md](AGENTS.md)，再读相关的 `.agents/skills/<name>/SKILL.md` |

所有工具产出的代码都必须过同一套 CI gate，没有任何工具有特权绕过规则。

## 想魔改这个模板本身

如果你想 fork 这个模板做自己的变体（换技术栈、换 skill 集）：

- 把 `src/` 下的 FastAPI 骨架替换成你想要的栈。
- 更新 `AGENTS.md` 里的 **Tech Stack** 和 **Commands** 两节。
- 修改 `.github/workflows/ci.yml` 和 `.pre-commit-config.yaml` 让 gate 链匹配新栈。
- 如果改了占位包名，同步改 `scripts/init-template.sh` 里的 `OLD_NAME`。
- 裁掉或替换 `.agents/skills/` 下的 skill —— 这里附带的 6 份是从 [addyosmani/agent-skills](https://github.com/addyosmani/agent-skills) 精简而来；记得在每份 `SKILL.md` 底部留上游链接，便于读者查完整版。

## 上游参考

`.agents/skills/` 下的 playbook 是 [addyosmani/agent-skills](https://github.com/addyosmani/agent-skills) 的项目化精简版。如果项目内的 skill 嫌简略，每份 `SKILL.md` 底部都链了上游全版。
