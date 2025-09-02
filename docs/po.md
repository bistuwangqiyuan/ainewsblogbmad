# 产品纲要（PO）— Epics 汇总

- 版本：v1.0（2025-08-31）
- 规范来源：`docs/PRD.md`、`docs/architecture.md`
- 原则：不使用模拟/不做回退；所有写入与访问严格遵守 Supabase RLS 与最小权限；失败以清晰错误提示呈现。

## Epic 1：新闻聚合与浏览（News）

- 目标：聚合 20+ RSS 源，标准化入库并支持按来源/时间/关键词的高效筛选与分页浏览。
- 范围：
  - Netlify Function `netlify/functions/fetch-news.js`（CRON 调度）
  - 表 `news_items`、`crawler_logs`；sha1(title|url|date) 去重，`upsert(onConflict=hash)`
  - 列表分页（20/页，最大 50 页），按发布时间倒序
  - 前端筛选：来源/时间区间/关键词
- 验收要点（参考 `docs/PRD.md` 第 3 章）：
  - 抓取任务按计划执行并记录日志；重复数据不会重复写入
  - 筛选组合与分页边界正确；无数据时清晰提示
  - 不展示伪数据；失败不回退

关联文档：`docs/epic-1-news-community.md`

## Epic 2：论坛与问答（Community & Q&A）

- 目标：提供帖子与问答基础能力；支持登录后发帖/提问与内容详情浏览。
- 范围：
  - 表：`posts(type=post|question)`、`answers`
  - 登录与会话（Supabase Auth）
  - 上传（<=10MB，最多 5 个；前端校验类型/大小；存储至 `media` bucket）
  - 详情页（帖子/问题与回答）
- 验收要点（参考 `docs/PRD.md` 第 3 章）：
  - 敏感词预检 `rpc('fn_check_sensitive')` 与 DB 触发器强制拒写
  - 发帖/提问可用；上传限制生效
  - 问题-回答正确展示与新增

关联文档：`docs/epic-2-forum-qa.md`

## Epic 3：互动与积分（Interactions & Points）

- 目标：提供点赞/收藏/评论/举报能力，记录浏览量与积分，并基于触发器维护等级。
- 范围：
  - 表：`comments`、`likes`、`favorites`、`reports`、`views`、`points_log`、`profiles`
  - 触发器：敏感词拦截、浏览量计数、积分累积与等级计算
  - 规则：每日首次登录+5；发帖+10；评论+2；点赞他人+1；被赞+1；收藏+1
- 验收要点（参考 `docs/PRD.md` 第 3 章）：
  - 点赞可取消、收藏幂等、评论仅一级且不可编辑/删除
  - 举报原因写入成功；RLS 正确限制
  - `points_log` 写入与 `profiles.points/level` 自动更新；个人中心可展示

关联文档：`docs/epic-3-interactions-and-points.md`

## Epic 4：AI 问答与消息（AI & Messages）

- 目标：支持向 AI 专家提问并将问答写入社区，同时实现站内私信与通知。
- 范围：
  - Netlify Function `netlify/functions/ask-ai.js`（POST）：
    - Body `{ question, authorId }`
    - 新建 `posts(type='question')`，AI 回答写入 `answers`，作者为 `AI_SYSTEM_USER_ID`
    - 失败直接报错（无回退/无模拟）
  - 消息/通知：`messages`、`notifications`（点赞/回答/评论触发写入）
- 验收要点（参考 `docs/PRD.md` 第 3 章）：
  - 提问成功返回 `{ answer, postId, answerId }`
  - RLS：未登录不可读取私信；发送/置已读受限于参与方
  - 失败场景提示明确；无降级数据

关联文档：`docs/epic-4-ai-and-messages.md`

## 统一配置与安全（Deployment & Security）

- 环境变量（Netlify）：
  - `SUPABASE_URL`、`SUPABASE_ANON_KEY`（前端 `public/config.js`）
  - `SUPABASE_SERVICE_ROLE_KEY`（仅函数用）
  - `OPENAI_COMPAT_API_URL`、`OPENAI_COMPAT_API_KEY`
  - `AI_SYSTEM_USER_ID`
- 存储：Bucket `media`（公开读、本人写、禁删）；前端限制文件类型与大小
- RLS：最小权限；服务密钥仅在函数中使用

## 实施顺序建议（按依赖）

1. 数据库初始化：`supabase/schema.sql` → `policies.sql` → `functions.sql`；创建 `media` bucket 与策略
2. News 抓取与浏览（Epic 1）：验证 CRON、去重与筛选
3. 社区与问答（Epic 2）：发帖/提问/上传/详情
4. 互动与积分（Epic 3）：点赞/收藏/评论/举报，积分/等级触发
5. AI 与消息（Epic 4）：`ask-ai`、私信与通知

## 验收清单（摘自 PRD）

- 定时抓取成功且去重有效（upsert）
- 页面功能齐备，筛选/搜索/分页/互动正常
- 敏感词与积分触发正确
- AI 问答无回退/无模拟
- 测试通过，README 勾选
