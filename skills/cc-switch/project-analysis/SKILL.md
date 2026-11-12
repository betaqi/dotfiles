---
name: project-analysis
description: >
  Analyze a code repository and produce a Chinese, evidence-backed project report covering
  project identity, technology stack, architecture, module responsibilities, data flow,
  engineering practices, technical complexity, deployment, testing, and observable project
  facts. Use when the user explicitly asks to analyze a project/repository, identify architecture
  or tech stack, map modules and data flow, or extract project-level technical facts. Do not use
  for ordinary debugging, code review, feature implementation, or refactoring unless the user
  also asks for repository-level project analysis.
---

# project-analysis

把代码仓库解析为结构化中文项目报告。这个 Skill 专注项目事实、架构关系、数据流和技术复杂度，不把推测写成事实。

## 核心原则

1. 只记录代码、文档、配置、测试、部署文件、提交历史中可验证的信息。
2. 所有重要结论都要标注证据来源，优先使用文件路径和行号。
3. 可以指出技术复杂度和工程特征，但必须说明依据。
4. 不编造业务背景、个人贡献、量化收益、线上效果、团队规模或用户规模。
5. 无证据或证据不足的内容放入"待确认问题"，不要写入事实清单。
6. 不修改源码、配置、依赖或 README；允许在项目根目录生成或更新 `.analysis-note.md` 存放对项目文档的建议（如"README 与实际架构不一致，建议更新"）。
7. 默认不要求用户提供额外背景；缺失信息只作为待确认问题列出。
8. 输出使用中文。

## 触发边界

使用本 Skill 的典型请求：

- "帮我分析一下这个项目"
- "看看这个项目是什么架构"
- "帮我梳理技术栈和模块职责"
- "这个项目的数据流是什么"
- "这个项目有哪些技术复杂点"
- "读一下这个仓库，给我一份项目分析报告"

不要因为以下请求自动触发：

- 修 bug、跑测试、加功能、改代码
- 普通 code review
- 解释某个函数、某个报错、某个 PR
- 单纯让 Codex 阅读代码完成其他任务

## 分析范围

优先读取：

- `README.md`、`README`、`docs/`
- `package.json`、`pnpm-lock.yaml`、`yarn.lock`、`pom.xml`、`build.gradle`、`pyproject.toml`、`requirements.txt`、`go.mod`、`Cargo.toml`
- 顶层目录结构，例如 `src/`、`app/`、`server/`、`frontend/`、`backend/`、`packages/`
- `Dockerfile`、`docker-compose.yml`、`deploy/`、`k8s/`
- `.github/workflows/`、`Jenkinsfile`、`.gitlab-ci.yml`
- 路由、入口文件、模型、迁移、配置、测试目录
- `git log --oneline -30`，仅作为活跃度和演进线索

估算代码规模时排除：

- `node_modules/`、`vendor/`、`.git/`
- `dist/`、`build/`、`.next/`、`out/`、`coverage/`
- 生成文件、lockfile、压缩产物、二进制文件

## 证据规范

每条关键事实都要有证据。优先使用文件路径和行号：

```markdown
证据：`src/server/routes/auth.ts:18`，`package.json:22`
```

如果某类证据没有稳定行号，可以使用文件路径：

```markdown
证据：`docker-compose.yml`
```

提交历史只作为参考线索，不作为用户贡献或功能效果的直接证据：

```markdown
线索：`git log --oneline -30` 中多次出现 auth/payment 相关提交
```

## 产物策略

### 输出模式

| 模式 | 触发条件 | 输出内容 |
|---|---|---|
| 完整模式（默认） | 用户首次分析、明确要求完整报告 | 完整报告文件（六个章节全部输出） |
| 精简模式 | 用户说"只要交接块""给下游用""精简版" | 只输出「项目识别」+「事实交接区」，不生成完整报告文件 |
| 增量模式 | 已有旧报告且变更可控 | 更新受影响章节 |

精简模式适用于：用户明确要串联 resume-packaging 或 interview-coaching，不需要完整报告，只需要结构化事实供下游消费。

---

默认生成或更新一个 Markdown 分析报告文件：

- 默认文件名：`project-analysis-report.md`
- 默认位置：当前被分析项目根目录；如果用户指定输出目录，以用户指定为准
- 对话中只输出精简摘要和报告路径，完整报告写入文件
- 报告文件必须包含完整分析内容，不能只写摘要
- 不修改源码、配置、依赖、README 或其他项目文件
- 如果发现文档与实际代码存在明显不一致（如 README 声称的架构与代码不符），可以在 `.analysis-note.md` 中记录建议

报告开头必须包含元信息（`generated_at` 使用 ISO 8601 格式，如 `2026-05-12T14:30:00+08:00`）：

```markdown
---
report: project-analysis
generated_at:
project_path:
git_head:
update_mode: full | incremental
---
```

如果 `project-analysis-report.md` 已存在，优先做增量刷新以节省 token：

1. 读取已有报告的元信息、项目识别、事实交接区和待确认问题。
2. 如果 git 可用，读取当前 `git rev-parse HEAD`、`git status --short`，并和旧报告中的 `git_head` 比较。
3. 如果旧报告有 `git_head`，优先查看 `git diff --name-only <old_head>..HEAD` 和 `git log --oneline <old_head>..HEAD`，只重扫变更文件及其影响到的模块。
4. 如果旧报告没有 `git_head`，或当前仓库不可用 git，则把旧报告只当作目录和模块索引，重新抽样检查关键入口、依赖文件、路由、模型和部署配置。
5. 增量刷新时必须更新受影响章节，并删除或降级已经失效的事实。
6. 增量刷新时同步更新 `.analysis-note.md`：去重已有的观察笔记，删除已失效的建议。

以下情况直接全量重跑：

- 没有旧报告
- 用户明确要求重新分析
- 依赖文件、入口目录、路由结构、数据库 schema、部署方式发生明显变化
- git 变更范围过大，无法可靠判断影响面
- 旧报告缺少证据来源或元信息，不适合作为增量基线

## 执行流程

### 1. 识别项目

先建立项目画像，不要一开始就深挖所有维度。

输出字段：

| 字段 | 内容 |
|------|------|
| 项目名称 | 从 README、包名、仓库目录推断 |
| 项目类型 | Web 应用 / API 服务 / CLI 工具 / 数据管道 / ML/AI 平台 / 移动端 / 组件库 / 其他 |
| 核心功能 | 只写能从文档或代码确认的功能 |
| 技术栈 | 语言、框架、数据库、中间件、关键 SDK |
| 架构形态 | 单体 / 前后端分离 / Monorepo / 微服务 / Serverless / 其他 |
| 代码规模 | 源文件数量和代码行级估算，注明排除项 |

### 2. 聚焦扫描（新增阶段）

根据项目类型和核心功能，确定哪些维度需要深入，哪些只做表层扫描。不要平铺 17 个维度全部深入。

**聚焦判定表：**

| 项目类型 | 必深挖维度 | 可跳过或浅扫 |
|---|---|---|
| Web 应用 / API 服务 | 核心模块、数据流、前后端交互、鉴权、部署 | AI/LLM、MQ（除非依赖文件明确存在） |
| ML/AI 平台 | AI/LLM、数据流、核心模块、部署 | 状态管理、前后端交互（除非有 Web 界面） |
| CLI 工具 | 核心模块、工程化、测试 | 部署、可观测性、缓存 |
| 组件库 / SDK | 核心模块、工程化、测试 | 部署、鉴权、数据流 |
| 数据管道 | 数据流、MQ、可观测性、部署 | 前后端交互、状态管理 |
| Monorepo | 核心模块、工程化、CI/CD | 逐个 package 按以上规则再聚焦 |

**扫描规则：**
- 依赖文件（`package.json`、`go.mod` 等）中不存在的中间件/服务，不要在报告中假设项目在用。
- 目录结构中没有对应模块的维度，在小结中一句话带过，不逐条写"未发现"。
- 大项目优先覆盖主链路和核心模块，不追求穷尽所有文件。

### 3. 提取事实

根据聚焦判定表的结果，只深入标记为"必深挖"的维度。不要跳过聚焦表去全量扫描。

常见维度（按聚焦判定表筛选后使用）：

| 维度 | 关注内容 |
|------|----------|
| 技术栈 | 语言、框架、数据库、中间件、AI/LLM SDK |
| 核心模块 | 主要目录、模块职责、入口文件 |
| 数据流 | 请求、业务处理、存储、缓存、外部服务调用 |
| 前后端交互 | REST、GraphQL、WebSocket、gRPC、RPC、Server Actions |
| 权限与鉴权 | JWT、OAuth、Session、RBAC、权限中间件 |
| 状态管理 | Redux、Zustand、Pinia、Context、自研状态 |
| 性能相关设计 | 分页、懒加载、缓存、索引、批处理、并发控制 |
| 缓存 | Redis、Memcached、本地缓存、HTTP 缓存 |
| 异步任务 | 队列、定时任务、事件驱动、后台任务 |
| 消息队列 | Kafka、RabbitMQ、SQS、Pub/Sub、BullMQ |
| 数据库设计 | Schema、迁移、索引、关系建模 |
| 部署方式 | Docker、K8s、Serverless、传统服务器、云平台 |
| 工程化 | Lint、格式化、构建、Monorepo、代码生成 |
| 测试体系 | 单测、集成测试、E2E、覆盖率配置 |
| CI/CD | 构建、测试、部署、发布流程 |
| 可观测性 | 日志、监控、Trace、Health check、告警 |
| AI/LLM | RAG、Agent、Prompt、向量检索、Embedding、Fine-tuning；**同时关注成本优化（Token 压缩、Cache 策略、模型路由、Fallback 设计）和延迟控制（推理缓存、流式处理、批量化、模型蒸馏）** |

事实写法：

```markdown
- 项目使用 Next.js App Router 组织页面和服务端逻辑。证据：`app/layout.tsx:1`，`app/api/chat/route.ts:1`
- 后端通过 Prisma 访问 PostgreSQL，并使用 migration 管理表结构。证据：`prisma/schema.prisma:1`，`prisma/migrations/`
```

### 4. 梳理架构与数据流

根据代码中能确认的入口、路由、服务、模型、存储和外部依赖，描述主链路。

优先输出：

- 用户或外部请求从哪里进入
- 路由、Controller、Handler、Service、Repository、Model 如何分层
- 数据写入或读取哪些存储
- 是否经过缓存、队列、定时任务、第三方 API
- 前端状态和后端 API 如何衔接
- 错误处理、鉴权、权限校验在哪一层发生

**Mermaid 图使用条件：** 数据流满足以下任一条件时，考虑用 Mermaid 图表示：
- 主链路跨 4 个或以上模块/服务
- 不同业务角色或输入条件导致**显著不同的数据流路径**（如管理员 VS 普通用户、已认证 VS 未认证、国内 VS 海外），而非任何 if/else 条件判断
- 涉及异步/事件驱动流程（队列、消息、定时任务）
- 涉及外部服务调用链
- 数据写入路径和读取路径不一致（CQRS 或类似模式）

不满足以上条件时，用文字描述即可。避免为只有"前端→API→数据库"的简单链路画图。

### 5. 关键技术观察

这一部分不是"亮点包装"，只记录项目中值得注意的技术设计、复杂度或工程特征。每条观察都必须有依据。

观察类型：

- 架构设计：分层、模块边界、Monorepo、服务拆分
- 业务复杂度：流程编排、状态流转、权限规则、数据关系
- 工程质量：类型约束、测试、Lint、构建、代码生成
- 性能相关：缓存、分页、索引、懒加载、批处理
- 稳定性：重试、幂等、降级、限流、错误处理
- 安全性：鉴权、权限、输入校验、加密、敏感信息处理
- 可扩展性：插件化、配置化、接口抽象、策略模式
- AI/LLM：RAG、Agent、Prompt 管理、向量检索、模型调用封装、**Token/成本优化策略、延迟控制方案**

观察模板：

```markdown
### [观察标题]

| 字段 | 内容 |
|------|------|
| 类型 | 架构 / 业务 / 工程 / 性能 / 稳定性 / 安全 / 扩展性 / AI |
| 可信度 | ✅ 事实明确 / ⚠️ 需要确认 |
| 事实 | 代码或文档能直接证明什么 |
| 复杂度依据 | 为什么这个设计或模块值得注意，只写能被证据支撑的判断 |
| 证据来源 | 文件路径和行号；必要时补充 git 线索 |
| 待确认 | 仍缺少的业务背景、使用规模、线上效果等 |
```

可信度标注：

| 评级 | 说明 |
|------|------|
| ✅ 事实明确 | 代码或文档直接支持，证据充分 |
| ⚠️ 需要确认 | 有相关代码，但业务背景、使用方式或结果需要确认 |

不要输出"❌ 无法确认"的观察；这类内容放入"待确认问题"。

## 输出模板

### 零、报告元信息

写入报告文件最顶部的 frontmatter：

```markdown
---
report: project-analysis
generated_at:
project_path:
git_head:
update_mode: full | incremental
---
```

### 一、项目识别

| 字段 | 内容 |
|------|------|
| 项目名称 | |
| 项目类型 | |
| 核心功能 | |
| 技术栈 | |
| 架构形态 | |
| 代码规模 | |

### 二、项目事实清单

按实际存在证据的维度组织。每条事实都要标注证据来源。

推荐格式：

```markdown
#### 技术栈

- ...

#### 核心模块

- ...

#### 数据流

- ...
```

### 三、架构与数据流

描述主链路、模块关系、数据读写路径和外部依赖。必要时给出 Mermaid 图（判定条件见上文）。

### 四、关键技术观察

列出 3-8 条最有信息量的技术观察。小项目可以少于 3 条，大项目优先覆盖主链路和核心模块。

### 五、事实交接区

这个区块只提供结构化事实，便于其他 skill 或后续任务消费。不要在这里写主观评价、无证据结论或个人贡献推断。

```yaml
project_analysis_handoff:
  project_name:
  project_type:
  confirmed_stack:
    languages:
    frameworks:
    databases:
    middleware:
    external_services:
  architecture:
  core_modules:
    - name:
      responsibility:
      evidence:
  data_flows:
    - name:
      path:
      evidence:
  technical_observations:
    - title:
      type:
      confidence:
      evidence:
      needs_confirmation:
  unsupported_or_unclear:
    - 证据不足、不能作为事实使用的内容
  questions_for_user:
    - 需要用户补充的业务背景、使用规模、线上效果或运行环境
```

### 六、待确认问题

只列真正影响项目理解的问题。不要把所有缺失信息都列出来。

可询问：

- 代码中的某些模块是否实际用于生产？
- 文档和代码不一致时，以哪个为准？
- 是否有线上部署、使用规模、QPS、延迟、成本等数据？
- 某些第三方服务或环境变量的实际用途是什么？

## 输出要求

- 结论先行，避免流水账。
- 没有量化数据时，只描述已实现的机制，例如"实现分页查询""使用 Redis 缓存""提供健康检查"。
- 对小项目保持克制，不强行解释成复杂架构。
- 对大项目（十万行以上源码）优先覆盖主链路和高价值模块，不追求穷尽所有文件。
- 大项目 token 有限时取舍优先级：README + 依赖文件 + 核心模块入口 + 一条完整数据流链路的抽样 + 部署/CI 配置。其他维度做浅扫描，不在报告正文展开。`technical_observations` 控制在 5 条以内。