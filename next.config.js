/** @type {import('next').NextConfig} */
const nextConfig = {
  eslint: {
    // 在构建时忽略 ESLint 错误
    ignoreDuringBuilds: true,
  },
  typescript: {
    // 在构建时忽略 TypeScript 错误
    ignoreBuildErrors: true,
  },
  images: {
    // 允许外部图片域名
    domains: ['localhost', 'fauzguzoamyahhcqhvoc.supabase.co'],
    // 允许未优化的图片
    unoptimized: true,
  },
  experimental: {
    serverComponentsExternalPackages: ['pg']
  },
  // Cloudflare Pages 静态导出配置
  output: 'export',
  trailingSlash: true,
  skipTrailingSlashRedirect: true,
  distDir: 'out',
  // 环境变量配置
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
