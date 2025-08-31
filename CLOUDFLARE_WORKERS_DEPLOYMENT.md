# 🚀 Cloudflare Workers 部署指南

## 📋 概览

本指南将帮助您将美旅地陪服务平台部署到 Cloudflare Workers。Workers 提供了更灵活的部署选项和更好的性能。

## 🔧 已创建的配置文件

### 1. `wrangler.toml` - Workers 配置
```toml
name = "meilv-web"
compatibility_date = "2025-08-31"

[assets]
directory = ".next"

[vars]
NODE_ENV = "production"
```

### 2. `worker.js` - Worker 入口文件
- 处理静态资源请求
- 处理 API 路由
- 支持 SPA 路由
- 错误处理

### 3. 更新的 `next.config.js`
- 启用静态导出
- 优化 Workers 部署
- 环境变量配置

## 🚀 部署方式

### 方式 1: 本地部署（推荐）

#### 步骤 1: 安装 Wrangler CLI
```bash
npm install -g wrangler
```

#### 步骤 2: 登录 Cloudflare
```bash
wrangler login
```

#### 步骤 3: 设置环境变量
```bash
# 设置生产环境变量
wrangler secret put NEXT_PUBLIC_SUPABASE_URL
wrangler secret put NEXT_PUBLIC_SUPABASE_ANON_KEY
wrangler secret put SUPABASE_SERVICE_ROLE_KEY
wrangler secret put NEXT_PUBLIC_SUPABASE_STORAGE_URL
wrangler secret put SUPABASE_STORAGE_KEY_ID
wrangler secret put SUPABASE_STORAGE_ACCESS_KEY
```

#### 步骤 4: 构建和部署
```bash
cd meilv-web
npm run deploy:workers
```

### 方式 2: 通过 GitHub Actions

#### 创建 `.github/workflows/deploy-workers.yml`
```yaml
name: Deploy to Cloudflare Workers

on:
  push:
    branches: [ main ]

jobs:
  deploy:
    runs-on: ubuntu-latest
    steps:
    - uses: actions/checkout@v3
    
    - name: Setup Node.js
      uses: actions/setup-node@v3
      with:
        node-version: '20'
        
    - name: Install dependencies
      run: |
        cd meilv-web
        npm ci
        
    - name: Build project
      run: |
        cd meilv-web
        npm run build
        
    - name: Deploy to Cloudflare Workers
      uses: cloudflare/wrangler-action@v3
      with:
        apiToken: ${{ secrets.CLOUDFLARE_API_TOKEN }}
        workingDirectory: meilv-web
```

## 🔧 环境变量配置

### 必需的环境变量
```
NEXT_PUBLIC_SUPABASE_URL=https://fauzguzoamyahhcqhvoc.supabase.co
NEXT_PUBLIC_SUPABASE_ANON_KEY=eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6ImZhdXpndXpvYW15YWhoY3Fodm9jIiwicm9sZSI6ImFub24iLCJpYXQiOjE3NTYzNjEyMjgsImV4cCI6MjA3MTkzNzIyOH0.HJ4By-4wXr8l_6G3sCpTaDTX63KLxm0DXkCOaO3vXv4
SUPABASE_SERVICE_ROLE_KEY=eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6ImZhdXpndXpvYW15YWhoY3Fodm9jIiwicm9sZSI6InNlcnZpY2Vfcm9sZSIsImlhdCI6MTc1NjM2MTIyOCwiZXhwIjoyMDcxOTM3MjI4fQ.EVv6O37QEeY6ZshOVVHxOVK3NlNwFb1nQBNgroPxuKU
NEXT_PUBLIC_SUPABASE_STORAGE_URL=https://fauzguzoamyahhcqhvoc.storage.supabase.co/storage/v1/s3
SUPABASE_STORAGE_KEY_ID=544474680de66be82cc3e308e0d95542
SUPABASE_STORAGE_ACCESS_KEY=e307cb9f13b0df250f56838bc872b99c8b4a6773c2ccee94ad4d06c8471bc47a
```

## 🔍 本地开发

### 启动开发服务器
```bash
cd meilv-web
npm run dev:workers
```

这将启动 Wrangler 开发服务器，模拟 Cloudflare Workers 环境。

## 📊 Workers vs Pages 对比

| 特性 | Workers | Pages |
|------|---------|-------|
| 部署复杂度 | 中等 | 简单 |
| 性能 | 更高 | 高 |
| 功能灵活性 | 更高 | 中等 |
| 文件大小限制 | 更宽松 | 25MB 限制 |
| API 支持 | 完整 | 有限 |
| 自定义逻辑 | 完全支持 | 有限 |

## 🚀 部署优势

### Cloudflare Workers 优势
1. **更高性能** - 边缘计算
2. **更灵活** - 自定义请求处理
3. **更好的 API 支持** - 完整的服务器端功能
4. **无文件大小限制** - 不受 25MB 限制
5. **更好的缓存控制** - 自定义缓存策略

## 🔧 故障排除

### 常见问题

#### 1. 部署失败
```
错误: Authentication error
解决: 运行 wrangler login 重新登录
```

#### 2. 环境变量未生效
```
错误: Environment variables not found
解决: 使用 wrangler secret put 设置变量
```

#### 3. 静态资源 404
```
错误: Static files not found
解决: 检查 wrangler.toml 中的 assets.directory 配置
```

### 调试步骤

1. **检查构建输出**
   ```bash
   npm run build
   ls -la .next/
   ```

2. **本地测试**
   ```bash
   npm run dev:workers
   ```

3. **查看 Worker 日志**
   ```bash
   wrangler tail
   ```

## 📋 部署检查清单

### 部署前确认
- [ ] Wrangler CLI 已安装
- [ ] 已登录 Cloudflare 账户
- [ ] 环境变量已设置
- [ ] 项目已构建成功
- [ ] wrangler.toml 配置正确

### 部署后验证
- [ ] Worker 部署成功
- [ ] 网站正常访问
- [ ] API 接口响应正常
- [ ] 静态资源加载正常
- [ ] 环境变量生效

## 🎯 立即部署

### 快速部署命令
```bash
# 进入项目目录
cd meilv-web

# 安装 Wrangler（如果未安装）
npm install -g wrangler

# 登录 Cloudflare
wrangler login

# 部署到 Workers
npm run deploy:workers
```

## 📞 获取帮助

- **Cloudflare Workers 文档**: https://developers.cloudflare.com/workers/
- **Wrangler CLI 文档**: https://developers.cloudflare.com/workers/wrangler/
- **Next.js on Workers**: https://developers.cloudflare.com/workers/frameworks/nextjs/

---

**🎉 按照本指南，您的美旅地陪服务平台将成功部署到 Cloudflare Workers！**
