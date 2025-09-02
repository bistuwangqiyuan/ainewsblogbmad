# AI 编程新闻与社区系统架构文档

- 文档版本：v4.0
- 创建日期：2025-08-31
- 最后更新：2025-08-31
- 作者：John (PM) → 架构师

## 1. 架构概述

### 1.1 系统架构模式

**Serverless + BaaS 架构**
- 前端：Astro 静态站点生成 + 客户端 JavaScript
- 后端：Supabase (PostgreSQL + Auth + Storage + RLS)
- 函数：Netlify Functions (新闻抓取、AI 问答)
- 部署：Netlify (静态托管 + CDN + 边缘函数)

### 1.2 核心设计原则

1. **无状态设计** - 所有状态存储在 Supabase 中
2. **最小权限原则** - RLS 策略严格控制数据访问
3. **模块化架构** - 功能模块独立，便于维护和扩展
4. **性能优先** - 静态生成 + CDN 加速
5. **安全第一** - 多层安全防护，无模拟数据回退

### 1.3 技术栈选择

| 层级 | 技术 | 版本 | 选择理由 |
|------|------|------|----------|
| 前端框架 | Astro | 最新 | 静态生成 + 组件化 + 性能优化 |
| 样式 | CSS + Tailwind | 最新 | 简洁快速，响应式设计 |
| 数据库 | PostgreSQL (Supabase) | 最新 | 关系型数据库，RLS 支持 |
| 认证 | Supabase Auth | 最新 | 开箱即用，安全可靠 |
| 存储 | Supabase Storage | 最新 | 文件存储，权限控制 |
| 函数 | Netlify Functions | 最新 | 无服务器，按需扩展 |
| 部署 | Netlify | 最新 | 静态托管 + CDN + 边缘函数 |

## 2. 系统架构图

### 2.1 高层架构

```
┌─────────────────┐    ┌─────────────────┐    ┌─────────────────┐
│   用户浏览器    │    │   Netlify CDN   │    │  Supabase Cloud │
│                 │    │                 │    │                 │
│ ┌─────────────┐ │    │ ┌─────────────┐ │    │ ┌─────────────┐ │
│ │   Astro     │ │◄──►│ │  静态文件   │ │◄──►│ │ PostgreSQL │ │
│ │  前端应用   │ │    │ │   (HTML/    │ │    │ │   数据库    │ │
│ │             │ │    │ │   CSS/JS)   │ │    │ │             │ │
│ └─────────────┘ │    │ └─────────────┘ │    │ └─────────────┘ │
└─────────────────┘    └─────────────────┘    │ ┌─────────────┐ │
                                              │ │   Auth      │ │
                                              │ │  认证服务   │ │
                                              │ └─────────────┘ │
                                              │ ┌─────────────┐ │
                                              │ │  Storage    │ │
                                              │ │  文件存储   │ │
                                              │ └─────────────┘ │
                                              └─────────────────┘
                                                       ▲
                                                       │
                                              ┌─────────────────┐
                                              │ Netlify Functions│
                                              │                 │
                                              │ ┌─────────────┐ │
                                              │ │ fetch-news  │ │
                                              │ │ 新闻抓取   │ │
                                              │ └─────────────┘ │
                                              │ ┌─────────────┐ │
                                              │ │   ask-ai    │ │
                                              │ │  AI 问答    │ │
                                              │ └─────────────┘ │
                                              └─────────────────┘
```

### 2.2 数据流架构

```
用户请求 → Netlify CDN → Astro 应用 → Supabase API → 数据库
                ↓
         Netlify Functions → 外部 API (新闻源/AI)
```

## 3. 数据库设计

### 3.1 核心表结构

#### 用户相关表

```sql
-- 用户资料表
CREATE TABLE profiles (
    id UUID REFERENCES auth.users(id) PRIMARY KEY,
    username VARCHAR(50) UNIQUE NOT NULL,
    avatar_url TEXT,
    bio TEXT,
    points INTEGER DEFAULT 0,
    level INTEGER DEFAULT 1,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- 积分记录表
CREATE TABLE points_log (
    id UUID DEFAULT gen_random_uuid() PRIMARY KEY,
    user_id UUID REFERENCES profiles(id) NOT NULL,
    action VARCHAR(50) NOT NULL,
    delta INTEGER NOT NULL,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);
```

#### 内容相关表

```sql
-- 新闻表
CREATE TABLE news_items (
    id UUID DEFAULT gen_random_uuid() PRIMARY KEY,
    title VARCHAR(500) NOT NULL,
    url TEXT UNIQUE NOT NULL,
    source VARCHAR(100) NOT NULL,
    published_at TIMESTAMP WITH TIME ZONE,
    summary TEXT,
    author VARCHAR(100),
    image_url TEXT,
    tags TEXT[],
    content_html TEXT,
    hash VARCHAR(64) UNIQUE NOT NULL,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- 帖子表 (论坛 + 问答)
CREATE TABLE posts (
    id UUID DEFAULT gen_random_uuid() PRIMARY KEY,
    author_id UUID REFERENCES profiles(id) NOT NULL,
    type VARCHAR(20) NOT NULL CHECK (type IN ('post', 'question')),
    title VARCHAR(200) NOT NULL,
    content TEXT NOT NULL,
    media TEXT[],
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- 回答表
CREATE TABLE answers (
    id UUID DEFAULT gen_random_uuid() PRIMARY KEY,
    question_id UUID REFERENCES posts(id) NOT NULL,
    author_id UUID REFERENCES profiles(id) NOT NULL,
    content TEXT NOT NULL,
    media TEXT[],
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);
```

#### 互动相关表

```sql
-- 评论表
CREATE TABLE comments (
    id UUID DEFAULT gen_random_uuid() PRIMARY KEY,
    entity_type VARCHAR(20) NOT NULL CHECK (entity_type IN ('news', 'post', 'answer')),
    entity_id UUID NOT NULL,
    author_id UUID REFERENCES profiles(id) NOT NULL,
    content TEXT NOT NULL,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- 点赞表
CREATE TABLE likes (
    id UUID DEFAULT gen_random_uuid() PRIMARY KEY,
    entity_type VARCHAR(20) NOT NULL CHECK (entity_type IN ('news', 'post', 'answer')),
    entity_id UUID NOT NULL,
    user_id UUID REFERENCES profiles(id) NOT NULL,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    UNIQUE(entity_type, entity_id, user_id)
);

-- 收藏表
CREATE TABLE favorites (
    id UUID DEFAULT gen_random_uuid() PRIMARY KEY,
    entity_type VARCHAR(20) NOT NULL CHECK (entity_type IN ('news', 'post', 'answer')),
    entity_id UUID NOT NULL,
    user_id UUID REFERENCES profiles(id) NOT NULL,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    UNIQUE(entity_type, entity_id, user_id)
);

-- 举报表
CREATE TABLE reports (
    id UUID DEFAULT gen_random_uuid() PRIMARY KEY,
    entity_type VARCHAR(20) NOT NULL CHECK (entity_type IN ('news', 'post', 'answer', 'comment')),
    entity_id UUID NOT NULL,
    user_id UUID REFERENCES profiles(id) NOT NULL,
    reason TEXT NOT NULL,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);
```

#### 统计相关表

```sql
-- 浏览量表
CREATE TABLE views (
    id UUID DEFAULT gen_random_uuid() PRIMARY KEY,
    entity_type VARCHAR(20) NOT NULL CHECK (entity_type IN ('news', 'post')),
    entity_id UUID NOT NULL,
    viewer_id UUID REFERENCES profiles(id),
    viewed_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- 消息表
CREATE TABLE messages (
    id UUID DEFAULT gen_random_uuid() PRIMARY KEY,
    sender_id UUID REFERENCES profiles(id) NOT NULL,
    receiver_id UUID REFERENCES profiles(id) NOT NULL,
    content TEXT NOT NULL,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    read BOOLEAN DEFAULT FALSE
);

-- 通知表
CREATE TABLE notifications (
    id UUID DEFAULT gen_random_uuid() PRIMARY KEY,
    user_id UUID REFERENCES profiles(id) NOT NULL,
    type VARCHAR(50) NOT NULL,
    payload JSONB,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    read BOOLEAN DEFAULT FALSE
);
```

#### 系统相关表

```sql
-- 反馈表
CREATE TABLE feedbacks (
    id UUID DEFAULT gen_random_uuid() PRIMARY KEY,
    user_id UUID REFERENCES profiles(id),
    content TEXT NOT NULL,
    files TEXT[],
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- 敏感词表
CREATE TABLE sensitive_words (
    id UUID DEFAULT gen_random_uuid() PRIMARY KEY,
    word VARCHAR(100) UNIQUE NOT NULL,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- 抓取日志表
CREATE TABLE crawler_logs (
    id UUID DEFAULT gen_random_uuid() PRIMARY KEY,
    source VARCHAR(100) NOT NULL,
    status VARCHAR(20) NOT NULL,
    message TEXT,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);
```

### 3.2 索引设计

```sql
-- 性能优化索引
CREATE INDEX idx_news_items_published_at ON news_items(published_at DESC);
CREATE INDEX idx_news_items_source ON news_items(source);
CREATE INDEX idx_news_items_hash ON news_items(hash);
CREATE INDEX idx_posts_type_created_at ON posts(type, created_at DESC);
CREATE INDEX idx_posts_author_id ON posts(author_id);
CREATE INDEX idx_comments_entity ON comments(entity_type, entity_id);
CREATE INDEX idx_likes_entity ON likes(entity_type, entity_id);
CREATE INDEX idx_favorites_entity ON favorites(entity_type, entity_id);
CREATE INDEX idx_views_entity ON views(entity_type, entity_id);
CREATE INDEX idx_points_log_user_id ON points_log(user_id);
CREATE INDEX idx_messages_users ON messages(sender_id, receiver_id);
CREATE INDEX idx_notifications_user_id ON notifications(user_id);
```

### 3.3 RLS 策略

```sql
-- 启用 RLS
ALTER TABLE profiles ENABLE ROW LEVEL SECURITY;
ALTER TABLE news_items ENABLE ROW LEVEL SECURITY;
ALTER TABLE posts ENABLE ROW LEVEL SECURITY;
ALTER TABLE answers ENABLE ROW LEVEL SECURITY;
ALTER TABLE comments ENABLE ROW LEVEL SECURITY;
ALTER TABLE likes ENABLE ROW LEVEL SECURITY;
ALTER TABLE favorites ENABLE ROW LEVEL SECURITY;
ALTER TABLE reports ENABLE ROW LEVEL SECURITY;
ALTER TABLE views ENABLE ROW LEVEL SECURITY;
ALTER TABLE points_log ENABLE ROW LEVEL SECURITY;
ALTER TABLE messages ENABLE ROW LEVEL SECURITY;
ALTER TABLE notifications ENABLE ROW LEVEL SECURITY;
ALTER TABLE feedbacks ENABLE ROW LEVEL SECURITY;

-- 公共可读策略
CREATE POLICY "Public read access" ON news_items FOR SELECT USING (true);
CREATE POLICY "Public read access" ON posts FOR SELECT USING (true);
CREATE POLICY "Public read access" ON answers FOR SELECT USING (true);
CREATE POLICY "Public read access" ON comments FOR SELECT USING (true);
CREATE POLICY "Public read access" ON likes FOR SELECT USING (true);
CREATE POLICY "Public read access" ON favorites FOR SELECT USING (true);

-- 用户可写策略
CREATE POLICY "Users can insert own posts" ON posts FOR INSERT WITH CHECK (auth.uid() = author_id);
CREATE POLICY "Users can update own posts" ON posts FOR UPDATE USING (auth.uid() = author_id);
CREATE POLICY "Users can insert own comments" ON comments FOR INSERT WITH CHECK (auth.uid() = author_id);
CREATE POLICY "Users can insert own likes" ON likes FOR INSERT WITH CHECK (auth.uid() = user_id);
CREATE POLICY "Users can delete own likes" ON likes FOR DELETE USING (auth.uid() = user_id);
CREATE POLICY "Users can insert own favorites" ON favorites FOR INSERT WITH CHECK (auth.uid() = user_id);
CREATE POLICY "Users can insert own reports" ON reports FOR INSERT WITH CHECK (auth.uid() = user_id);
CREATE POLICY "Users can insert own views" ON views FOR INSERT WITH CHECK (auth.uid() = viewer_id);

-- 私密数据策略
CREATE POLICY "Users can read own messages" ON messages FOR SELECT USING (auth.uid() = sender_id OR auth.uid() = receiver_id);
CREATE POLICY "Users can insert own messages" ON messages FOR INSERT WITH CHECK (auth.uid() = sender_id);
CREATE POLICY "Users can read own notifications" ON notifications FOR SELECT USING (auth.uid() = user_id);
CREATE POLICY "Users can read own points log" ON points_log FOR SELECT USING (auth.uid() = user_id);
```

## 4. API 设计

### 4.1 前端 API 接口

#### 新闻相关

```javascript
// 获取新闻列表
GET /api/news?page=1&limit=20&source=openai&search=ai

// 获取新闻详情
GET /api/news/:id

// 获取新闻统计
GET /api/news/stats
```

#### 社区相关

```javascript
// 获取帖子列表
GET /api/posts?type=post&page=1&limit=20

// 获取帖子详情
GET /api/posts/:id

// 创建帖子
POST /api/posts
{
  "type": "post",
  "title": "标题",
  "content": "内容",
  "media": ["url1", "url2"]
}

// 获取回答列表
GET /api/posts/:id/answers

// 创建回答
POST /api/posts/:id/answers
{
  "content": "回答内容",
  "media": ["url1"]
}
```

#### 互动相关

```javascript
// 点赞/取消点赞
POST /api/likes
{
  "entity_type": "post",
  "entity_id": "uuid"
}

// 收藏/取消收藏
POST /api/favorites
{
  "entity_type": "post",
  "entity_id": "uuid"
}

// 发表评论
POST /api/comments
{
  "entity_type": "post",
  "entity_id": "uuid",
  "content": "评论内容"
}

// 举报
POST /api/reports
{
  "entity_type": "post",
  "entity_id": "uuid",
  "reason": "举报原因"
}
```

#### 用户相关

```javascript
// 获取用户资料
GET /api/profiles/:id

// 更新用户资料
PUT /api/profiles/:id
{
  "username": "新用户名",
  "bio": "个人简介"
}

// 获取积分记录
GET /api/profiles/:id/points

// 获取个人统计
GET /api/profiles/:id/stats
```

### 4.2 Netlify Functions

#### 新闻抓取函数

```javascript
// netlify/functions/fetch-news.js
exports.handler = async (event, context) => {
  // 1. 获取配置的新闻源
  // 2. 并行抓取各源内容
  // 3. 标准化数据格式
  // 4. 去重处理
  // 5. 批量插入数据库
  // 6. 记录抓取日志
};
```

#### AI 问答函数

```javascript
// netlify/functions/ask-ai.js
exports.handler = async (event, context) => {
  // 1. 验证用户身份
  // 2. 调用 AI API
  // 3. 记录问答历史
  // 4. 返回结果
};
```

## 5. 前端架构

### 5.1 页面结构

```
src/
├── pages/
│   ├── index.astro          # 首页
│   ├── news/
│   │   ├── index.astro      # 新闻列表
│   │   └── [id].astro       # 新闻详情
│   ├── community.astro      # 社区
│   ├── compose.astro        # 发帖/提问
│   ├── post/[id].astro      # 帖子详情
│   ├── ask.astro           # AI 问答
│   ├── auth.astro          # 登录注册
│   ├── me.astro            # 个人中心
│   ├── messages.astro      # 消息中心
│   ├── feedback.astro      # 反馈
│   ├── about.astro         # 关于
│   ├── privacy.astro       # 隐私
│   └── terms.astro         # 条款
├── components/
│   ├── Header.astro         # 头部导航
│   ├── Footer.astro         # 底部
│   ├── NewsCard.astro       # 新闻卡片
│   ├── PostCard.astro       # 帖子卡片
│   ├── CommentList.astro    # 评论列表
│   └── ...
├── layouts/
│   └── Layout.astro         # 主布局
├── lib/
│   ├── supabaseClient.js    # Supabase 客户端
│   ├── ai.js               # AI 相关函数
│   └── utils.js            # 工具函数
└── styles/
    └── globals.css          # 全局样式
```

### 5.2 组件设计

#### 核心组件

```javascript
// 新闻卡片组件
<NewsCard 
  title="新闻标题"
  summary="新闻摘要"
  source="来源"
  publishedAt="发布时间"
  imageUrl="图片URL"
  tags={["AI", "编程"]}
  onLike={() => {}}
  onFavorite={() => {}}
/>

// 帖子卡片组件
<PostCard 
  type="post|question"
  title="帖子标题"
  content="帖子内容"
  author="作者"
  createdAt="创建时间"
  likeCount={10}
  commentCount={5}
  onLike={() => {}}
  onComment={() => {}}
/>

// 评论列表组件
<CommentList 
  entityType="post"
  entityId="uuid"
  comments={[]}
  onAddComment={() => {}}
/>
```

### 5.3 状态管理

```javascript
// 用户状态
const userStore = {
  user: null,
  profile: null,
  isAuthenticated: false
};

// 新闻状态
const newsStore = {
  items: [],
  loading: false,
  filters: {
    source: null,
    search: null,
    page: 1
  }
};

// 社区状态
const communityStore = {
  posts: [],
  currentPost: null,
  loading: false
};
```

## 6. 安全设计

### 6.1 认证安全

- **Supabase Auth**: 邮箱密码认证，JWT 令牌管理
- **会话管理**: 自动刷新令牌，安全存储
- **密码策略**: 强密码要求，密码哈希存储

### 6.2 数据安全

- **RLS 策略**: 行级安全控制，最小权限原则
- **输入验证**: 前端 + 后端双重验证
- **敏感词过滤**: 实时内容检查，违规内容拦截

### 6.3 API 安全

- **CORS 配置**: 严格跨域控制
- **速率限制**: API 调用频率限制
- **错误处理**: 不暴露敏感信息的错误响应

### 6.4 文件安全

- **文件类型验证**: 仅允许指定格式
- **文件大小限制**: 最大 10MB
- **存储权限**: 公开读，用户写，禁止删除

## 7. 性能优化

### 7.1 前端优化

- **静态生成**: Astro 预渲染关键页面
- **代码分割**: 按路由分割 JavaScript
- **图片优化**: 自动格式转换和压缩
- **缓存策略**: 浏览器缓存 + CDN 缓存

### 7.2 数据库优化

- **索引设计**: 关键查询字段建立索引
- **查询优化**: 避免 N+1 查询问题
- **连接池**: 数据库连接复用
- **分页优化**: 游标分页替代偏移分页

### 7.3 CDN 优化

- **全球分发**: Netlify CDN 全球节点
- **边缘缓存**: 静态资源边缘缓存
- **压缩传输**: Gzip/Brotli 压缩
- **HTTP/2**: 多路复用连接

## 8. 监控和日志

### 8.1 应用监控

- **错误追踪**: 前端错误捕获和上报
- **性能监控**: 页面加载时间监控
- **用户行为**: 关键操作埋点统计

### 8.2 系统监控

- **函数监控**: Netlify Functions 执行状态
- **数据库监控**: Supabase 性能指标
- **CDN 监控**: 缓存命中率和响应时间

### 8.3 日志管理

- **结构化日志**: JSON 格式日志输出
- **日志级别**: DEBUG, INFO, WARN, ERROR
- **日志聚合**: 集中式日志收集和分析

## 9. 部署架构

### 9.1 部署流程

```
代码提交 → GitHub → Netlify 构建 → 静态文件生成 → CDN 分发
                ↓
         Netlify Functions 部署 → 边缘函数可用
```

### 9.2 环境配置

```bash
# 生产环境变量
SUPABASE_URL=https://xxx.supabase.co
SUPABASE_ANON_KEY=xxx
SUPABASE_SERVICE_ROLE_KEY=xxx
OPENAI_COMPAT_API_URL=https://api.openai.com/v1
OPENAI_COMPAT_API_KEY=xxx
```

### 9.3 定时任务

```javascript
// netlify.toml
[functions]
  directory = "netlify/functions"

[[redirects]]
  from = "/api/*"
  to = "/.netlify/functions/:splat"
  status = 200

# 定时任务配置
[functions."fetch-news"]
  schedule = "0 2 * * *"  # 每天凌晨2点执行
```

## 10. 扩展性设计

### 10.1 水平扩展

- **无状态设计**: 支持多实例部署
- **CDN 扩展**: 自动全球分发
- **数据库扩展**: Supabase 自动扩展

### 10.2 功能扩展

- **模块化设计**: 功能模块独立
- **API 版本化**: 支持 API 版本管理
- **插件系统**: 支持功能插件扩展

### 10.3 数据扩展

- **分表策略**: 大表分片存储
- **归档策略**: 历史数据归档
- **备份策略**: 定期数据备份

## 11. 风险评估

### 11.1 技术风险

- **第三方依赖**: Supabase 和 Netlify 服务可用性
- **API 限制**: 外部 API 调用频率限制
- **数据安全**: 敏感数据泄露风险

### 11.2 业务风险

- **内容质量**: 抓取内容质量不可控
- **用户增长**: 用户增长带来的性能压力
- **合规风险**: 内容合规性风险

### 11.3 缓解措施

- **多源备份**: 关键服务多源备份
- **监控告警**: 实时监控和告警
- **内容审核**: 自动化内容审核机制

## 12. 总结

本架构设计基于 PRD 需求，采用现代化的 Serverless + BaaS 架构模式，确保系统的可扩展性、安全性和性能。通过 Supabase 提供完整的后端服务，Netlify 提供部署和函数服务，实现了简洁高效的系统架构。

关键特点：
- **无服务器架构**: 降低运维复杂度
- **安全优先**: 多层安全防护
- **性能优化**: 静态生成 + CDN 加速
- **模块化设计**: 便于维护和扩展
- **监控完善**: 全面的监控和日志系统
