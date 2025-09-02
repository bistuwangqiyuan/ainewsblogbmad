# 部署架构

## 部署流程

```
代码提交 → GitHub → Netlify 构建 → 静态文件生成 → CDN 分发
                ↓
         Netlify Functions 部署 → 边缘函数可用
```

## 环境配置

```bash
# 生产环境变量
SUPABASE_URL=https://xxx.supabase.co
SUPABASE_ANON_KEY=xxx
SUPABASE_SERVICE_ROLE_KEY=xxx
OPENAI_COMPAT_API_URL=https://api.openai.com/v1
OPENAI_COMPAT_API_KEY=xxx
```

## 定时任务

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
