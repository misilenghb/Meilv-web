# 🌐 Cloudflare Pages 部署指南

## 📋 概览

本指南将帮助您将美旅地陪服务平台部署到 Cloudflare Pages。Cloudflare Pages 是部署 Next.js 应用的正确选择，而不是 Cloudflare Workers。

## 🚀 部署方式

### 方式 1: 通过 Cloudflare Dashboard 部署 (推荐)

#### 步骤 1: 访问 Cloudflare Pages
1. 登录 [Cloudflare Dashboard](https://dash.cloudflare.com)
2. 选择 "Pages" 服务
3. 点击 "Create a project"

#### 步骤 2: 连接 GitHub 仓库
1. 选择 "Connect to Git"
2. 授权 Cloudflare 访问您的 GitHub
3. 选择仓库：`misilenghb/dipei`

#### 步骤 3: 配置构建设置
```
Project name: meilv-web
Production branch: main
Root directory: meilv-web
Build command: npm run build
Build output directory: .next
```

#### 步骤 4: 配置环境变量
在 "Environment variables" 部分添加：

```
NEXT_PUBLIC_SUPABASE_URL=https://fauzguzoamyahhcqhvoc.supabase.co
NEXT_PUBLIC_SUPABASE_ANON_KEY=eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6ImZhdXpndXpvYW15YWhoY3Fodm9jIiwicm9sZSI6ImFub24iLCJpYXQiOjE3NTYzNjEyMjgsImV4cCI6MjA3MTkzNzIyOH0.HJ4By-4wXr8l_6G3sCpTaDTX63KLxm0DXkCOaO3vXv4
SUPABASE_SERVICE_ROLE_KEY=eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6ImZhdXpndXpvYW15YWhoY3Fodm9jIiwicm9sZSI6InNlcnZpY2Vfcm9sZSIsImlhdCI6MTc1NjM2MTIyOCwiZXhwIjoyMDcxOTM3MjI4fQ.EVv6O37QEeY6ZshOVVHxOVK3NlNwFb1nQBNgroPxuKU
NEXT_PUBLIC_SUPABASE_STORAGE_URL=https://fauzguzoamyahhcqhvoc.storage.supabase.co/storage/v1/s3
SUPABASE_STORAGE_KEY_ID=544474680de66be82cc3e308e0d95542
SUPABASE_STORAGE_ACCESS_KEY=e307cb9f13b0df250f56838bc872b99c8b4a6773c2ccee94ad4d06c8471bc47a
NODE_VERSION=18
```

#### 步骤 5: 部署
1. 点击 "Save and Deploy"
2. 等待构建完成（约 3-5 分钟）
3. 获取 Cloudflare Pages URL

### 方式 2: 使用 Wrangler CLI 部署

#### 步骤 1: 安装 Wrangler
```bash
npm install -g wrangler
```

#### 步骤 2: 登录 Cloudflare
```bash
wrangler login
```

#### 步骤 3: 构建和部署
```bash
cd meilv-web
npm run deploy:cloudflare
```

## 🔧 配置文件说明

### 已创建的 Cloudflare 专用文件

#### 1. `next.config.cloudflare.js`
Cloudflare Pages 优化的 Next.js 配置：
```javascript
{
  output: 'standalone',
  images: { unoptimized: true },
  env: { /* 环境变量配置 */ }
}
```

#### 2. `functions/_middleware.js`
Cloudflare Pages Functions 中间件，用于处理环境变量

#### 3. `_headers`
HTTP 头配置，包含安全头和缓存策略

#### 4. `_redirects`
路由重定向配置，支持 SPA 路由

#### 5. `wrangler.toml`
Cloudflare 项目配置文件

### 新增的 package.json 脚本

```json
{
  "build:cloudflare": "cp next.config.cloudflare.js next.config.js && npm run build",
  "deploy:cloudflare": "npm run build:cloudflare && wrangler pages deploy .next --project-name=meilv-web"
}
```

## 🛠️ 构建配置详解

### Cloudflare Pages 构建设置

```yaml
Build command: npm run build
Build output directory: .next
Root directory: meilv-web
Node.js version: 18
```

### 环境变量配置

所有环境变量都必须在 Cloudflare Pages 设置中配置：

1. **Supabase 配置**（必需）
   - `NEXT_PUBLIC_SUPABASE_URL`
   - `NEXT_PUBLIC_SUPABASE_ANON_KEY`
   - `SUPABASE_SERVICE_ROLE_KEY`
   - `NEXT_PUBLIC_SUPABASE_STORAGE_URL`
   - `SUPABASE_STORAGE_KEY_ID`
   - `SUPABASE_STORAGE_ACCESS_KEY`

2. **构建配置**（推荐）
   - `NODE_VERSION=18`

## 🔍 故障排除

### 常见问题

#### 1. 构建失败
```
错误: Build failed
解决: 检查 Node.js 版本是否为 18，确认所有依赖已安装
```

#### 2. API 路由不工作
```
错误: API routes returning 404
解决: 确认 _redirects 文件配置正确，检查 functions/_middleware.js
```

#### 3. 环境变量未生效
```
错误: Environment variables not found
解决: 在 Cloudflare Pages 设置中重新添加所有环境变量
```

#### 4. 图片加载失败
```
错误: Image optimization error
解决: 已配置 unoptimized: true，应该正常工作
```

### 调试步骤

1. **检查构建日志**
   - 在 Cloudflare Pages Dashboard 查看详细构建日志
   - 确认所有依赖安装成功

2. **验证环境变量**
   - 在 Pages 设置中确认所有环境变量已添加
   - 检查变量名称和值是否正确

3. **测试本地构建**
   ```bash
   cd meilv-web
   npm run build:cloudflare
   npm start
   ```

## 📊 性能优化

### Cloudflare Pages 优势

1. **全球 CDN**
   - 自动分发到全球边缘节点
   - 减少延迟，提高访问速度

2. **自动 HTTPS**
   - 免费 SSL 证书
   - 自动续期

3. **无限带宽**
   - 不限制流量
   - 高可用性

### 性能配置

1. **缓存策略**
   - 静态资源长期缓存
   - API 响应适当缓存

2. **压缩优化**
   - 自动 Gzip/Brotli 压缩
   - 图片优化

## 🔒 安全配置

### HTTP 安全头

已在 `_headers` 文件中配置：
- `X-Frame-Options: DENY`
- `X-XSS-Protection: 1; mode=block`
- `X-Content-Type-Options: nosniff`
- `Referrer-Policy: strict-origin-when-cross-origin`

### CORS 配置

API 路由已配置适当的 CORS 头：
- `Access-Control-Allow-Origin: *`
- `Access-Control-Allow-Methods: GET, POST, PUT, DELETE, OPTIONS`

## 📋 部署检查清单

部署前确认：
- [ ] GitHub 仓库已更新最新代码
- [ ] 环境变量已在 Cloudflare Pages 中配置
- [ ] 构建命令设置为 `npm run build`
- [ ] 输出目录设置为 `.next`
- [ ] 根目录设置为 `meilv-web`
- [ ] Node.js 版本设置为 18

部署后验证：
- [ ] 网站正常访问
- [ ] 用户注册/登录功能正常
- [ ] API 接口响应正常
- [ ] 数据库连接正常
- [ ] 图片资源加载正常

## 🎯 推荐操作流程

### 立即部署步骤：

1. **访问 Cloudflare Pages**
   ```
   https://dash.cloudflare.com/pages
   ```

2. **创建新项目**
   - 选择 "Connect to Git"
   - 选择仓库：`misilenghb/dipei`

3. **配置构建设置**
   - 根目录：`meilv-web`
   - 构建命令：`npm run build`
   - 输出目录：`.next`

4. **添加环境变量**
   - 复制您的 `.env.local` 文件内容
   - 在 Pages 设置中逐一添加

5. **部署**
   - 点击 "Save and Deploy"
   - 等待构建完成

## 🔗 有用链接

- **Cloudflare Pages 文档**: https://developers.cloudflare.com/pages/
- **Next.js on Cloudflare**: https://developers.cloudflare.com/pages/framework-guides/deploy-a-nextjs-site/
- **Wrangler CLI 文档**: https://developers.cloudflare.com/workers/wrangler/

---

**🎉 按照本指南，您的美旅地陪服务平台将成功部署到 Cloudflare Pages！**
