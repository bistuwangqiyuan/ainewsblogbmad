# API 设计

## 前端 API 接口

### 新闻相关

```javascript
// 获取新闻列表
GET /api/news?page=1&limit=20&source=openai&search=ai

// 获取新闻详情
GET /api/news/:id

// 获取新闻统计
GET /api/news/stats
```

### 社区相关

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

### 互动相关

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

### 用户相关

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

## Netlify Functions

### 新闻抓取函数

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

### AI 问答函数

```javascript
// netlify/functions/ask-ai.js
exports.handler = async (event, context) => {
  // 1. 验证用户身份
  // 2. 调用 AI API
  // 3. 记录问答历史
  // 4. 返回结果
};
```
