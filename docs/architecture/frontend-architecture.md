# 前端架构

## 页面结构

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

## 组件设计

### 核心组件

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

## 状态管理

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
