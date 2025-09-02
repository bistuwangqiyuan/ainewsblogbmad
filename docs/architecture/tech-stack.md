# 技术栈说明

## 前端

- Astro + 原生 HTML/CSS/JS：低复杂度、构建快、易托管。
- Tailwind（已接入）：快速样式迭代。

## 数据

- Supabase：Postgres + Auth + Storage + RLS + RPC/触发器。
- 方案理由：一体化 PaaS，前端直连简化后端；RLS 满足权限；Storage 支持对象存储。

## 函数

- Netlify Functions：`ask-ai`、`fetch-news`；边缘可扩。
- 方案理由：无服务器、与托管一体化；支持调度任务。

## 第三方

- AI：OpenAI 兼容接口（由环境变量注入）。
- RSS：`rss-parser`，Node `crypto` 计算哈希。
