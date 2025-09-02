# 源码结构说明

```
public/
  config.js                 # 运行时公开配置（Supabase 公钥）
src/
  assets/                   # 资源
  components/               # 组件（Header/Footer 等）
  layouts/                  # 布局（全站统一）
  lib/
    supabaseClient.js       # Supabase 客户端单例
  pages/
    index.astro             # 首页
    news/                   # 新闻列表与详情
    community.astro         # 社区列表（论坛/问答）
    compose.astro           # 发帖/提问
    post/[id].astro         # 帖子/问题详情
    ask.astro               # AI 问答
    auth.astro              # 登录/注册
    me.astro                # 个人中心
    messages.astro          # 站内消息
    feedback.astro          # 用户反馈
    about/privacy/terms/intro.astro
netlify/
  functions/
    ask-ai.js               # AI 问答函数（保存问题与回答）
    fetch-news.js           # 定时抓取 RSS
supabase/
  schema.sql                # 表/索引
  policies.sql              # RLS 策略
  functions.sql             # 触发器/函数
```
