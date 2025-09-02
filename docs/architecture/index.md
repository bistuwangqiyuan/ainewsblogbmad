# AI 编程新闻与社区系统架构文档

- 文档版本：v4.0
- 创建日期：2025-08-31
- 最后更新：2025-08-31
- 作者：John (PM) → 架构师

## 文档概述

本系统架构文档定义了 AI 编程新闻与社区平台的完整技术架构设计。文档采用分片结构，便于团队协作和文档维护。基于 PRD 需求，采用 Serverless + BaaS 架构模式，确保系统的可扩展性、安全性和性能。

## 章节列表

- [架构概述](./architecture-overview.md)
- [系统架构图](./system-architecture-diagrams.md)
- [数据库设计](./database-design.md)
- [API 设计](./api-design.md)
- [前端架构](./frontend-architecture.md)
- [安全设计](./security-design.md)
- [性能优化](./performance-optimization.md)
- [监控和日志](./monitoring-and-logging.md)
- [部署架构](./deployment-architecture.md)
- [扩展性设计](./scalability-design.md)
- [风险评估](./risk-assessment.md)
- [总结](./summary.md)

## 技术栈概览

- **前端**: Astro + CSS + Tailwind
- **后端**: Supabase (PostgreSQL + Auth + Storage + RLS)
- **函数**: Netlify Functions
- **部署**: Netlify (静态托管 + CDN + 边缘函数)
- **AI**: OpenAI 兼容 API

## 核心设计原则

1. **无状态设计** - 所有状态存储在 Supabase 中
2. **最小权限原则** - RLS 策略严格控制数据访问
3. **模块化架构** - 功能模块独立，便于维护和扩展
4. **性能优先** - 静态生成 + CDN 加速
5. **安全第一** - 多层安全防护，无模拟数据回退
