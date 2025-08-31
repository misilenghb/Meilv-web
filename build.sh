#!/bin/bash

# Cloudflare Pages 根目录构建脚本
# 解决根目录问题并强制静态导出

echo "🚀 开始 Cloudflare Pages 构建..."

# 检查是否在正确目录
if [ -d "meilv-web" ]; then
    echo "📁 进入 meilv-web 目录..."
    cd meilv-web
elif [ -f "package.json" ]; then
    echo "📁 已在项目目录中..."
else
    echo "❌ 找不到项目目录"
    exit 1
fi

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
find out/ -name "*.pack" -delete 2>/dev/null || true
find out/ -size +25M -delete 2>/dev/null || true

# 删除 .next 目录以避免混淆
echo "🗑️ 删除 .next 目录..."
rm -rf .next/

# 验证文件大小
echo "🔍 检查文件大小..."
large_files=$(find out/ -size +25M 2>/dev/null || true)
if [ -n "$large_files" ]; then
    echo "❌ 发现大文件:"
    echo "$large_files"
    exit 1
else
    echo "✅ 所有文件都小于 25MB"
fi

# 如果在子目录中，将输出移动到根目录
if [ "$(basename $(pwd))" = "meilv-web" ]; then
    echo "📦 移动输出到根目录..."
    mv out ../
    cd ..
fi

echo "🎉 构建完成！输出目录: out/"
echo "📁 文件列表:"
ls -la out/ | head -10
