# 架构概述

## 系统架构模式

**Serverless + BaaS 架构**
- 前端：Astro 静态站点生成 + 客户端 JavaScript
- 后端：Supabase (PostgreSQL + Auth + Storage + RLS)
- 函数：Netlify Functions (新闻抓取、AI 问答)
- 部署：Netlify (静态托管 + CDN + 边缘函数)

## 核心设计原则

1. **无状态设计** - 所有状态存储在 Supabase 中
2. **最小权限原则** - RLS 策略严格控制数据访问
3. **模块化架构** - 功能模块独立，便于维护和扩展
4. **性能优先** - 静态生成 + CDN 加速
5. **安全第一** - 多层安全防护，无模拟数据回退

## 技术栈选择

| 层级 | 技术 | 版本 | 选择理由 |
|------|------|------|----------|
| 前端框架 | Astro | 最新 | 静态生成 + 组件化 + 性能优化 |
| 样式 | CSS + Tailwind | 最新 | 简洁快速，响应式设计 |
| 数据库 | PostgreSQL (Supabase) | 最新 | 关系型数据库，RLS 支持 |
| 认证 | Supabase Auth | 最新 | 开箱即用，安全可靠 |
| 存储 | Supabase Storage | 最新 | 文件存储，权限控制 |
| 函数 | Netlify Functions | 最新 | 无服务器，按需扩展 |
| 部署 | Netlify | 最新 | 静态托管 + CDN + 边缘函数 |
