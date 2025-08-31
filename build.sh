#!/bin/bash

# Cloudflare Pages 构建脚本
# 强制使用静态导出并清理大文件

echo "🚀 开始 Cloudflare Pages 构建..."

# 设置 Node.js 版本
export NODE_VERSION=20

# 安装依赖
echo "📦 安装依赖..."
npm ci

# 强制设置静态导出配置
echo "🔧 配置静态导出..."
cat > next.config.js << 'EOF'
/** @type {import('next').NextConfig} */
const nextConfig = {
  eslint: {
    ignoreDuringBuilds: true,
  },
  typescript: {
    ignoreBuildErrors: true,
  },
  images: {
    domains: ['localhost', 'fauzguzoamyahhcqhvoc.supabase.co'],
    unoptimized: true,
  },
  experimental: {
    serverComponentsExternalPackages: ['pg']
  },
  // 强制静态导出
  output: 'export',
  trailingSlash: true,
  skipTrailingSlashRedirect: true,
  distDir: 'out',
  env: {
    NEXT_PUBLIC_SUPABASE_URL: process.env.NEXT_PUBLIC_SUPABASE_URL,
    NEXT_PUBLIC_SUPABASE_ANON_KEY: process.env.NEXT_PUBLIC_SUPABASE_ANON_KEY,
    SUPABASE_SERVICE_ROLE_KEY: process.env.SUPABASE_SERVICE_ROLE_KEY,
    NEXT_PUBLIC_SUPABASE_STORAGE_URL: process.env.NEXT_PUBLIC_SUPABASE_STORAGE_URL,
    SUPABASE_STORAGE_KEY_ID: process.env.SUPABASE_STORAGE_KEY_ID,
    SUPABASE_STORAGE_ACCESS_KEY: process.env.SUPABASE_STORAGE_ACCESS_KEY,
  }
}

module.exports = nextConfig
EOF

# 构建项目
echo "🔨 构建项目..."
npm run build

# 验证输出目录
if [ -d "out" ]; then
    echo "✅ 输出目录 'out' 创建成功"
    echo "📊 输出目录大小: $(du -sh out/ | cut -f1)"
else
    echo "❌ 输出目录 'out' 不存在，检查构建配置"
    exit 1
fi

# 清理大文件
echo "🧹 清理大文件..."
rm -rf out/cache/
rm -rf out/**/*.map
find out/ -name "*.pack" -delete
find out/ -size +25M -delete

# 删除 .next 目录以避免混淆
echo "🗑️ 删除 .next 目录..."
rm -rf .next/

# 验证文件大小
echo "🔍 检查文件大小..."
large_files=$(find out/ -size +25M 2>/dev/null)
if [ -n "$large_files" ]; then
    echo "❌ 发现大文件:"
    echo "$large_files"
    exit 1
else
    echo "✅ 所有文件都小于 25MB"
fi

echo "🎉 构建完成！输出目录: out/"
echo "📁 文件列表:"
ls -la out/ | head -10
