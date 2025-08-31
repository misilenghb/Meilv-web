# 🚀 Vercel 环境变量快速修复指南

## 🚨 **问题**
```
Environment Variable "NEXT_PUBLIC_SUPABASE_URL" references Secret "next_public_supabase_url", which does not exist.
```

## ✅ **已修复**
- ✅ 移除了 `vercel.json` 中的 Secret 引用
- ✅ 简化了 Vercel 配置
- ✅ 代码已推送到 GitHub

## 🔧 **现在需要您做的**

### 步骤1: 访问 Vercel Dashboard
1. 打开 https://vercel.com/dashboard
2. 选择您的项目
3. 点击 **Settings** → **Environment Variables**

### 步骤2: 添加以下6个环境变量

#### 变量1: NEXT_PUBLIC_SUPABASE_URL
```
名称: NEXT_PUBLIC_SUPABASE_URL
值: https://fauzguzoamyahhcqhvoc.supabase.co
环境: Production, Preview, Development
```

#### 变量2: NEXT_PUBLIC_SUPABASE_ANON_KEY
```
名称: NEXT_PUBLIC_SUPABASE_ANON_KEY
值: eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6ImZhdXpndXpvYW15YWhoY3Fodm9jIiwicm9sZSI6ImFub24iLCJpYXQiOjE3NTYzNjEyMjgsImV4cCI6MjA3MTkzNzIyOH0.HJ4By-4wXr8l_6G3sCpTaDTX63KLxm0DXkCOaO3vXv4
环境: Production, Preview, Development
```

#### 变量3: SUPABASE_SERVICE_ROLE_KEY
```
名称: SUPABASE_SERVICE_ROLE_KEY
值: eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6ImZhdXpndXpvYW15YWhoY3Fodm9jIiwicm9sZSI6InNlcnZpY2Vfcm9sZSIsImlhdCI6MTc1NjM2MTIyOCwiZXhwIjoyMDcxOTM3MjI4fQ.EVv6O37QEeY6ZshOVVHxOVK3NlNwFb1nQBNgroPxuKU
环境: Production, Preview, Development
```

#### 变量4: NEXT_PUBLIC_SUPABASE_STORAGE_URL
```
名称: NEXT_PUBLIC_SUPABASE_STORAGE_URL
值: https://fauzguzoamyahhcqhvoc.storage.supabase.co/storage/v1/s3
环境: Production, Preview, Development
```

#### 变量5: SUPABASE_STORAGE_KEY_ID
```
名称: SUPABASE_STORAGE_KEY_ID
值: 544474680de66be82cc3e308e0d95542
环境: Production, Preview, Development
```

#### 变量6: SUPABASE_STORAGE_ACCESS_KEY
```
名称: SUPABASE_STORAGE_ACCESS_KEY
值: e307cb9f13b0df250f56838bc872b99c8b4a6773c2ccee94ad4d06c8471bc47a
环境: Production, Preview, Development
```

### 步骤3: 重新部署
1. 保存所有环境变量
2. 在 **Deployments** 标签中点击 **Redeploy**
3. 等待部署完成

## 📋 **配置截图指南**

### 在 Vercel Dashboard 中：
1. **Project Settings** → **Environment Variables**
2. 点击 **Add New**
3. 输入变量名和值
4. 选择环境：**Production**, **Preview**, **Development**
5. 点击 **Save**
6. 重复6次，添加所有变量

## 🎯 **验证部署**

### 部署成功后检查：
- ✅ 应用可以正常访问
- ✅ 用户可以注册/登录
- ✅ 数据库连接正常
- ✅ 文件上传功能正常

## 📞 **如果还有问题**

### 常见解决方案：
1. **检查变量名拼写**：确保完全一致
2. **检查值的完整性**：确保没有遗漏字符
3. **重新部署**：保存变量后必须重新部署
4. **清除缓存**：在浏览器中清除缓存

### 联系支持：
- 查看详细指南：`VERCEL_ENV_SETUP.md`
- GitHub 仓库：https://github.com/misilenghb/dipei.git

---

**🎉 按照以上步骤操作后，您的项目将成功部署到 Vercel！**
