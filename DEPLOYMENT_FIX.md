# 🔧 部署问题修复指南

## 🚨 问题分析

您遇到的错误是 Cloudflare Wrangler 试图部署 Next.js 项目，但配置不正确。这通常发生在：
1. 部署平台错误识别项目类型
2. 存在冲突的配置文件
3. 环境变量配置不正确

## ✅ 解决方案

### 方案 1: Vercel 部署 (推荐)

#### 步骤 1: 清理并重新部署
1. **删除任何 Cloudflare 相关文件**
   ```bash
   rm -f wrangler.toml wrangler.jsonc
   ```

2. **使用 Vercel CLI 部署**
   ```bash
   npm install -g vercel
   vercel login
   vercel --prod
   ```

3. **或者通过 Vercel 网站部署**
   - 访问 https://vercel.com
   - 连接 GitHub 仓库：https://github.com/misilenghb/dipei
   - 选择 `meilv-web` 目录作为根目录
   - 配置环境变量

#### 步骤 2: 配置环境变量
在 Vercel 项目设置中添加：
```
NEXT_PUBLIC_SUPABASE_URL=https://fauzguzoamyahhcqhvoc.supabase.co
NEXT_PUBLIC_SUPABASE_ANON_KEY=eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6ImZhdXpndXpvYW15YWhoY3Fodm9jIiwicm9sZSI6ImFub24iLCJpYXQiOjE3NTYzNjEyMjgsImV4cCI6MjA3MTkzNzIyOH0.HJ4By-4wXr8l_6G3sCpTaDTX63KLxm0DXkCOaO3vXv4
SUPABASE_SERVICE_ROLE_KEY=eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6ImZhdXpndXpvYW15YWhoY3Fodm9jIiwicm9sZSI6InNlcnZpY2Vfcm9sZSIsImlhdCI6MTc1NjM2MTIyOCwiZXhwIjoyMDcxOTM3MjI4fQ.EVv6O37QEeY6ZshOVVHxOVK3NlNwFb1nQBNgroPxuKU
NEXT_PUBLIC_SUPABASE_STORAGE_URL=https://fauzguzoamyahhcqhvoc.storage.supabase.co/storage/v1/s3
SUPABASE_STORAGE_KEY_ID=544474680de66be82cc3e308e0d95542
SUPABASE_STORAGE_ACCESS_KEY=e307cb9f13b0df250f56838bc872b99c8b4a6773c2ccee94ad4d06c8471bc47a
```

### 方案 2: Netlify 部署

#### 步骤 1: 使用 Netlify CLI
```bash
npm install -g netlify-cli
netlify login
netlify deploy --prod --dir=.next
```

#### 步骤 2: 或通过 Netlify 网站
1. 访问 https://netlify.com
2. 连接 GitHub 仓库
3. 设置构建配置：
   - Build command: `npm run build`
   - Publish directory: `.next`
   - Node version: `18`

### 方案 3: 手动本地部署测试

#### 步骤 1: 本地构建测试
```bash
cd meilv-web
npm install
npm run build
npm start
```

#### 步骤 2: 验证功能
访问 http://localhost:3000 确认应用正常运行

## 🔧 配置文件说明

### 已更新的文件

#### 1. `vercel.json` (已优化)
```json
{
  "version": 2,
  "name": "meilv-web",
  "framework": "nextjs",
  "buildCommand": "npm run build",
  "outputDirectory": ".next",
  "installCommand": "npm install",
  "devCommand": "npm run dev",
  "functions": {
    "src/app/api/**/*.ts": {
      "runtime": "nodejs18.x"
    }
  },
  "rewrites": [
    {
      "source": "/api/(.*)",
      "destination": "/api/$1"
    }
  ]
}
```

#### 2. `netlify.toml` (新增)
```toml
[build]
  command = "npm run build"
  publish = ".next"

[build.environment]
  NODE_VERSION = "18"
  NPM_VERSION = "9"

[[redirects]]
  from = "/api/*"
  to = "/.netlify/functions/:splat"
  status = 200

[[redirects]]
  from = "/*"
  to = "/index.html"
  status = 200
```

## 🚀 推荐部署流程

### 最佳实践：Vercel 部署

1. **准备工作**
   ```bash
   # 确保代码是最新的
   git add .
   git commit -m "Fix deployment configuration"
   git push origin main
   ```

2. **Vercel 部署**
   - 访问 https://vercel.com/new
   - 选择 GitHub 仓库：`misilenghb/dipei`
   - 设置根目录为 `meilv-web`
   - 添加环境变量
   - 点击 Deploy

3. **验证部署**
   - 检查构建日志
   - 测试应用功能
   - 验证 API 接口

## 🔍 故障排除

### 常见问题

#### 1. 构建失败
```bash
# 检查依赖
npm install

# 本地构建测试
npm run build
```

#### 2. 环境变量问题
- 确保所有环境变量都已正确设置
- 检查变量名称是否正确
- 验证 Supabase 连接

#### 3. API 路由问题
- 确认 API 路由路径正确
- 检查函数运行时配置
- 验证权限设置

### 调试命令

```bash
# 检查项目结构
ls -la

# 验证 package.json
cat package.json

# 测试本地构建
npm run build

# 检查环境变量
echo $NEXT_PUBLIC_SUPABASE_URL
```

## 📞 获取帮助

如果问题仍然存在：

1. **检查部署日志**
   - Vercel: 在项目仪表板查看构建日志
   - Netlify: 在部署页面查看详细日志

2. **验证配置**
   - 确认项目根目录设置正确
   - 检查环境变量配置
   - 验证构建命令

3. **联系支持**
   - Vercel: https://vercel.com/support
   - Netlify: https://netlify.com/support

## ✅ 成功部署检查清单

- [ ] 删除 Cloudflare 相关配置
- [ ] 更新 vercel.json 配置
- [ ] 添加 netlify.toml 配置
- [ ] 设置正确的环境变量
- [ ] 本地构建测试成功
- [ ] 选择合适的部署平台
- [ ] 配置项目根目录
- [ ] 验证部署结果

---

**🎯 推荐：使用 Vercel 部署，它对 Next.js 项目有最好的支持！**
