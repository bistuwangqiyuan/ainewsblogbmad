# 项目简报（Project Brief）—— AI 编程新闻与社区

- 文档版本：v1.0
- 日期：2025-08-31
- 适用范围：本简报用于指导后续的产品设计、技术实现与测试；与 PRD、详细设计配套使用。

## 1. 背景与愿景

- 背景/痛点：AI 与编程领域信息爆炸，个人用户难以及时获取高质量、与编程相关的 AI 新闻、论文与实用讨论；缺少简洁聚合与低门槛互动平台。
- 愿景（一句话）：打造“中文、聚焦 AI 编程、轻交互”的高质量资讯与社区枢纽。
- 不做范围：第三方登录、广告/变现模块、后台管理系统、APP 客户端、多角色复杂权限、内容人工审核与付费功能。

## 2. 目标用户

- 用户群体：个人开发者、在职工程师、研究者/学生；中文用户为主。
- 语言与地区：中文（简体）优先；面向中文读者即可。
- 使用频率：每日/每周浏览与互动。

## 3. 关键使用场景

1. 快速获取最新 AI 编程相关新闻/论文，按来源/时间/关键词筛选。
2. 在社区发帖或公开提问、上传图片/视频、进行基础互动（点赞/收藏/评论/举报）。
3. 查看个人积分/等级与简单数据统计，接收站内消息与系统通知。

## 4. 内容来源与抓取策略

- 来源清单：采用 PRD/设计文档中列出的 20 个可行 RSS/API 站点（OpenAI、DeepMind、Google AI、Microsoft Research、Meta AI、Hugging Face、Papers with Code、The Gradient、GitHub Blog AI、MLOps Community、Anthropic、Amazon Science、Apple ML、NVIDIA Tech Blog、Google Research 等）。
- 频率与配额：每日定时抓取（默认 02:00 UTC），每源 10–100 条。
- 去重策略：以 sha1(title|url|date) 作为归一化哈希键，重复丢弃；仅服务端写入。
- 失败处理：逐源记录 `crawler_logs` 状态；失败仅提示，不用任何模拟/回退数据。

## 5. 信息架构与页面

- 顶部导航：首页、新闻、社区、发帖/提问、AI 问答、消息、个人中心、反馈、关于、隐私、协议。
- 主要页面：
  - 首页（门户）：网站介绍与关键入口。
  - 新闻流 `/news`：筛选/搜索/分页（20/页，最大 50 页），时间优先排序。
  - 新闻详情 `/news/[id]`：来源链接、点赞/收藏/评论/举报、浏览量统计。
  - 社区 `/community`：同一结构、两标签（论坛/问答），筛选与搜索。
  - 发帖/提问 `/compose`：支持图片/视频上传（<=10MB，最多 5 个）。
  - 帖子详情 `/post/[id]`：评论、点赞、收藏、举报；问题支持回答列表与新增回答。
  - AI 问答 `/ask`：向 AI 提问（公开），失败明确报错。
  - 登录注册 `/auth`：Supabase 邮箱+密码。
  - 个人中心 `/me`：资料、积分与等级、个人统计（发帖/评论/收藏计数等）。
  - 消息 `/messages`：私信与系统通知。
  - 反馈 `/feedback`：文本+附件（<=10MB；常见类型）。
  - 关于/隐私/协议/网站介绍：常见法务与说明页面。

## 6. 功能与业务规则

- 鉴权：Supabase Auth 邮箱+密码，会话持久化；未登录可浏览，登录后可发帖/互动/私信/反馈。
- 社区与问答：同一表 `posts`（`type`=post|question），问题的回答存 `answers`。
- 媒体上传：图片 jpg/png/webp、视频 mp4；单文件 <=10MB；最多 5 个；存储至 Supabase Storage `media` bucket，公开读、本人写、禁删策略。
- 互动：
  - 点赞：可取消（删除 `likes`）。
  - 收藏：不可删除（保留历史；`favorites` 无删除策略）。
  - 评论：仅一级、不可编辑/删除。
  - 举报：文本原因，记录即可。
- 敏感词与合规：前端 RPC 预检 + 数据库触发器强校验，命中直接拒写并提示；词库初始维护在 `sensitive_words`。
- 数据统计：浏览量写入 `views`；个人中心展示发帖/评论/收藏等计数；积分变更记录 `points_log`。
- 积分/等级（默认）：
  - 等级阈值：Lv1 0 / Lv2 50 / Lv3 150 / Lv4 400 / Lv5 1000。
  - 行为积分：每日首次登录 +5；发帖/提问 +10；评论 +2；点赞他人 +1；被点赞 +1；收藏 +1。
  - 用途：展示与荣誉，不做权限门槛。
- 搜索/筛选/分页/排序：分页 20/页、最大 50 页；来源/时间/关键词筛选；时间优先排序（可扩展热度排序）。

## 7. 技术方案与架构

- 前端：Astro + 原生 HTML/CSS/JS；统一头部/尾部与响应式布局；移动优先理念简化为 PC 优先适配。
- 数据与权限：Supabase（Postgres + Auth + Storage + RLS + RPC/触发器）。
- 部署与运行：Netlify（静态/SSR 托管、Functions、调度任务）。
- AI 问答：Netlify Function `ask-ai` 调用单一 OpenAI 兼容接口（由环境变量配置）；失败直接报错，不做回退或模拟。
- 抓取：Netlify 定时函数 `fetch-news`，RSS 聚合 → 标准化 → 去重 → 入库；错误记录 `crawler_logs`。

## 8. 数据模型摘要（详见 supabase/\*.sql）

- `profiles(id, username, avatar_url, bio, points, level, created_at, updated_at)`
- `news_items(id, title, url, source, published_at, summary, author, image_url, tags, content_html, hash)`
- `posts(id, author_id, type, title, content, media, created_at)`
- `answers(id, question_id, author_id, content, media, created_at)`
- `comments(id, entity_type, entity_id, author_id, content, created_at)`
- `likes(id, entity_type, entity_id, user_id, created_at)`（unique: entity_type, entity_id, user_id）
- `favorites(id, entity_type, entity_id, user_id, created_at)`（unique 同上）
- `reports(id, entity_type, entity_id, user_id, reason, created_at)`
- `views(id, entity_type, entity_id, viewer_id, viewed_at)`
- `points_log(id, user_id, action, delta, created_at)`
- `messages(id, sender_id, receiver_id, content, created_at, read)`
- `notifications(id, user_id, type, payload, created_at, read)`
- `feedbacks(id, user_id, content, files, created_at)`
- `sensitive_words(id, word, created_at)`
- `crawler_logs(id, source, status, message, created_at)`

RLS 原则（摘要）：

- 公共可读：`news_items`、大部分列表数据。
- 自身可写：发帖/评论/点赞/收藏/举报/消息等仅登录用户；收藏无删除；点赞可删除（取消）。
- 管控：`news_items` 与敏感词等由服务角色写入/维护；触发器负责敏感词与积分。

## 9. 非功能性（NFR）

- 性能：新闻列表 20 条/页；关键列表查询建立索引（时间/来源/作者/实体关联）。
- 安全：RLS 最小权限；Storage 写入路径隔离；禁止使用模拟/回退数据；错误清晰提示。
- 可运维：定时任务日志化；失败源可定位；配置环境变量管理敏感信息。

## 10. KPI（上线后三个月）

- 北极星指标：
  - 每日有效新闻入库数（目标：≥100/日，去重后）。
  - 日活阅读数（目标：≥500）。
- 次级指标：注册 → 发帖/评论/点赞转化率、7 日留存、互动率（点赞/评论/收藏）。

## 11. 品牌与风格

- 视觉风格：简洁明快；对比度良好；可读性优先。
- 主题色：沿用当前样式（可后续细化）。
- Logo：暂用占位图，后续替换。

## 12. 依赖与配置

- 依赖：Astro、@supabase/supabase-js、rss-parser、@netlify/functions。
- 环境变量（Netlify）：
  - `SUPABASE_URL`、`SUPABASE_SERVICE_ROLE_KEY`
  - `OPENAI_COMPAT_API_URL`、`OPENAI_COMPAT_API_KEY`
- 前端运行时：`public/config.js` 暴露 `SUPABASE_URL` 与 `SUPABASE_ANON_KEY`。

## 13. 交付物与对接

- 本仓库已包含：PRD（`docs/PRD.md`）、详细设计（`docs/design.md`）、数据库 SQL（`supabase/*.sql`）、前端页面、Netlify 函数与调度配置、README 任务记录。
- 本简报为上层概述，供沟通与对齐使用；具体字段/表/策略以设计与 SQL 为准。
