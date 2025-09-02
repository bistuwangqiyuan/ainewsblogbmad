# AI 编程新闻与社区网站 详细设计

- 文档版本：v1.1
- 更新日期：2025-08-31

## 变更摘要

- AI 问答：服务端函数 `ask-ai` 现在会先以登录用户创建 `posts(type='question')` 再调用 AI，将回答以 `answers` 形式写入，作者为 `AI_SYSTEM_USER_ID`（环境变量配置）。失败时返回错误且不做任何回退或伪造。
- 抓取：`fetch-news` 使用 `upsert(onConflict=hash, ignoreDuplicates=true)` 提升去重与统计准确性。
- 统计：个人中心计数基于实时 `count: 'exact'` 查询；后续可扩展视图优化。

## 1. 系统架构

- 前端：Astro + 原生 HTML/CSS/JS。统一 `src/layouts/Layout.astro`。
- 数据：Supabase（Postgres + Auth + Storage + RLS + RPC）。
- 托管：Netlify（Functions + 调度）。
- AI：`ask-ai` 使用 `OPENAI_COMPAT_API_URL`/`OPENAI_COMPAT_API_KEY` 与 `AI_SYSTEM_USER_ID`。
- 聚合：`fetch-news` 定时抓取 + upsert 去重。

## 2. 环境变量

- `SUPABASE_URL`、`SUPABASE_SERVICE_ROLE_KEY`
- `OPENAI_COMPAT_API_URL`、`OPENAI_COMPAT_API_KEY`
- `AI_SYSTEM_USER_ID`（用于写入 AI 回答的系统用户 ID）

## 3. 安全与合规

- 无回退/模拟；失败明确提示。
- RLS：问题与回答写入通过服务角色；前端仅读取与登录后可写入自身记录。

## 4. 页面与导航

- 顶部导航：`首页`、`论坛/问答`、`发帖/提问`、`AI 专家问答`、`消息`、`个人中心`、`反馈`、`关于`。
- 页表：
  - `/`：新闻流（筛选/搜索/分页）。
  - `/news/[id]`：新闻详情（评论/点赞/收藏/举报/浏览量）。
  - `/community`：列表 + 标签（论坛/问答），共用结构，筛选/搜索/分页。
  - `/compose`：发布帖子或问题（图片/视频上传，<=10MB；前置敏感词 RPC 校验）。
  - `/post/[id]`：帖子或问题详情；问题支持回答（answers）。
  - `/auth`：登录/注册（邮箱+密码）。
  - `/me`：个人中心（资料、积分与等级、统计）。
  - `/messages`：站内私信与系统通知。
  - `/feedback`：用户反馈与附件上传（<=10MB）。
  - `/about` `/privacy` `/terms` `/intro`：静态法务/介绍页。

## 5. 数据模型（Supabase）

注意：均启用 RLS。`id` 默认 `gen_random_uuid()`。

- 表：`profiles`

  - `id uuid pk`（=auth.uid）
  - `username text unique`，`avatar_url text`，`bio text`
  - `points int default 0`，`level int default 1`
  - `created_at timestamptz default now()`，`updated_at timestamptz`

- 表：`news_items`

  - `id uuid pk`，`title text not null`，`url text not null`，`source text not null`
  - `published_at timestamptz`，`summary text`，`author text`，`image_url text`
  - `tags text[]`，`content_html text`
  - `hash text unique not null`（title+url+date 归一化哈希，防重复）
  - `created_at timestamptz default now()`

- 表：`posts`（论坛/问题二合一）

  - `id uuid pk`，`author_id uuid not null`（=auth.uid）
  - `type text check (type in ('post','question')) not null`
  - `title text not null`，`content text not null`
  - `media jsonb default '[]'::jsonb`（存储路径数组）
  - `created_at timestamptz default now()`

- 表：`answers`

  - `id uuid pk`，`question_id uuid references posts(id) on delete restrict`
  - `author_id uuid not null`，`content text not null`
  - `media jsonb default '[]'::jsonb`，`created_at timestamptz default now()`

- 表：`comments`

  - `id uuid pk`，`entity_type text check (entity_type in ('news','post','answer')) not null`
  - `entity_id uuid not null`，`author_id uuid not null`
  - `content text not null`，`created_at timestamptz default now()`

- 表：`likes`

  - `id uuid pk`，`entity_type text check (entity_type in ('news','post','answer')) not null`
  - `entity_id uuid not null`，`user_id uuid not null`
  - `created_at timestamptz default now()`
  - 唯一：`unique (entity_type, entity_id, user_id)`（避免重复点赞）

- 表：`favorites`

  - `id uuid pk`，`entity_type text check (entity_type in ('news','post','answer')) not null`
  - `entity_id uuid not null`，`user_id uuid not null`
  - `created_at timestamptz default now()`
  - 唯一：`unique (entity_type, entity_id, user_id)`（重复收藏按一次计）

- 表：`reports`

  - `id uuid pk`，`entity_type text check (entity_type in ('news','post','answer','comment')) not null`
  - `entity_id uuid not null`，`user_id uuid not null`，`reason text not null`
  - `created_at timestamptz default now()`

- 表：`views`

  - `id bigint generated always as identity pk`
  - `entity_type text check (entity_type in ('news','post','answer')) not null`
  - `entity_id uuid not null`，`viewer_id uuid`（可空）
  - `viewed_at timestamptz default now()`

- 表：`points_log`

  - `id uuid pk`，`user_id uuid not null`，`action text not null`，`delta int not null`
  - `created_at timestamptz default now()`

- 表：`messages`

  - `id uuid pk`，`sender_id uuid not null`，`receiver_id uuid not null`
  - `content text not null`，`created_at timestamptz default now()`，`read boolean default false`

- 表：`notifications`

  - `id uuid pk`，`user_id uuid not null`，`type text not null`
  - `payload jsonb not null`，`created_at timestamptz default now()`，`read boolean default false`

- 表：`feedbacks`

  - `id uuid pk`，`user_id uuid`（匿名允许为空）
  - `content text not null`，`files jsonb default '[]'::jsonb`（存储 URL 列表）
  - `created_at timestamptz default now()`

- 表：`sensitive_words`

  - `id uuid pk`，`word text unique not null`，`created_at timestamptz default now()`

- 表：`crawler_logs`
  - `id uuid pk`，`source text not null`，`status text not null`，`message text`，`created_at timestamptz default now()`

## 6. RLS 策略（要点）

- `profiles`: read all；insert/update 仅本人（auth.uid() = id）。
- `news_items`: read all；禁止普通用户写入（仅服务端函数使用 service key）。
- `posts/answers`: read all；insert 仅已登录；update/delete 禁止。
- `comments`: read all；insert 仅已登录；update/delete 禁止。
- `likes`: read all；insert 仅已登录；delete 仅本人（允许取消点赞）。
- `favorites`: read 自己+聚合可通过视图；insert 仅已登录；delete 禁止。
- `reports`: insert 仅已登录；read 自己。
- `views`: insert 所有人（匿名 viewer_id null）；read 聚合视图提供计数。
- `points_log`: read 自己；insert 通过触发器；禁止手工写入。
- `messages`: read 仅参与双方；insert 仅发送者；update 仅接收者可置 `read=true`；delete 禁止。
- `notifications`: read 仅本人；insert 触发器。
- `feedbacks`: read 仅本人；insert 所有登录/匿名；delete 禁止。
- `sensitive_words`: read all；insert/update 限制（可临时手工维护）。

## 7. 触发器/函数

- `fn_check_sensitive(text) returns boolean`：遍历 `sensitive_words`，命中返回 false。
- `BEFORE INSERT/UPDATE ON posts, answers, comments`：若 `fn_check_sensitive` 返回 false 则 `raise exception` 阻止写入。
- `fn_award_points(user_id, action text)`：按规则写 `points_log` 并累加 `profiles.points`；`fn_recalc_level()` 基于积分区间更新 `profiles.level`。
- 触发积分：
  - `AFTER INSERT ON posts` → `+10`
  - `AFTER INSERT ON comments` → `+2`
  - `AFTER INSERT ON likes WHERE user_id <> target_author` → `+1` 给被点赞作者
  - `RPC fn_daily_login()`：每日仅一次 `+5`
- `fn_increment_view(entity_type, entity_id)`：写入一条 `views`。
- `AFTER INSERT ON likes/comments/answers`：写入 `notifications` 给目标作者。

## 8. 存储（Supabase Storage）

- Bucket：`media`（公开读取）。路径：`user/{uid}/{yyyy}/{mm}/{filename}`。
- 策略：读取 `true`；写入仅本人；删除禁止。
- 前端限制：图片 jpg/png/webp；视频 mp4；单文件<=10MB；最多 5 个。

## 9. 定时抓取 `fetch-news`（Netlify Function）

- 周期：每日 02:00（UTC 偏移可调整）。
- 流程：
  1. 逐源抓取 RSS/JSON；
  2. 标准化字段：title/url/source/published_at/summary/image/tags；
  3. 计算哈希（sha1(title|url|date)）；
  4. 批量 upsert 至 `news_items`（冲突 on hash do nothing）；
  5. 记录 `crawler_logs`。
- 依赖：`@supabase/supabase-js`、`fast-xml-parser`。

## 10. AI 专家问答 `ask-ai`（Netlify Function）

- 输入：`question` 文本。
- 逻辑：读取 `OPENAI_COMPAT_API_URL` 与 `OPENAI_COMPAT_API_KEY` 调用 `/v1/chat/completions`；失败直接返回错误信息；绝不切换其他提供商。
- 持久化：在成功时，由函数使用 service key 将问题写入 `posts(type='question')`，答案写入 `answers`（`author_id` 为空或固定系统 UID）。

## 11. 前端实现要点

- 公共：`public/config.js` 暴露 `SUPABASE_URL` 与 `SUPABASE_ANON_KEY`（由环境注入或静态配置）。
- 客户端：`src/lib/supabaseClient.js` 单例。
- 组件：卡片 `NewsCard`、列表 `List`、分页器、筛选条、上传组件。
- 交互：
  - 登录/注册使用 Supabase Auth。
  - 发布前先调用 `rpc('fn_check_sensitive')` 预检。
  - 上传使用 `storage.from('media').upload()`；前端校验类型/大小。
  - 点赞：插入/删除 `likes`；收藏：仅插入 `favorites`（无删除）。
  - 评论：插入 `comments`；无编辑/删除。
  - 统计：浏览时调用 `rpc('fn_increment_view')`。

## 12. 测试策略（真实数据）

- 用例覆盖：
  - 期望：注册/登录、发布、评论、点赞/取消、收藏、举报、AI 提问、反馈上传、筛选与分页。
  - 边界：文件 10MB 限制、非法类型、敏感词阻止、重复点赞/收藏幂等、匿名浏览统计。
  - 失败：AI 提供商未配置/超时、抓取源失败、RLS 拒绝写入。
- 目录：`/tests`，使用 `vitest` + 实际 Supabase 项目与密钥。

## 13. 配置与环境变量

- 前端：`
