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
  }
}

module.exports = nextConfig
