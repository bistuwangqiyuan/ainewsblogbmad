# 技术假设

## 仓库结构

**Monorepo** - 单一仓库包含前端、函数、配置等所有代码

## 服务架构

**Serverless** - 基于 Netlify Functions 和 Supabase 的无服务器架构

## 测试要求

**单元 + 集成** - 前端单元测试 + 后端集成测试，包含 API 测试

## 额外技术假设和请求

- **前端框架**: Astro + 原生 HTML/CSS/JS，不使用 TypeScript
- **后端服务**: Supabase（Postgres + Auth + Storage + RLS）
- **部署平台**: Netlify（静态托管 + Functions + 调度任务）
- **AI 集成**: OpenAI 兼容 API 调用
- **数据抓取**: RSS 聚合 + 定时函数
- **文件存储**: Supabase Storage，公开读、本人写、禁删策略
- **权限管理**: Supabase RLS 策略
- **敏感词过滤**: 前端预检 + 数据库触发器
- **积分系统**: 数据库触发器自动计算
- **消息系统**: 实时通知（可选 WebSocket）
