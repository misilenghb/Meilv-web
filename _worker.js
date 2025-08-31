// Cloudflare Pages Functions 配置
// 这个文件用于配置 Cloudflare Pages 的边缘函数

export default {
  async fetch(request, env, ctx) {
    // 处理静态资源
    return env.ASSETS.fetch(request);
  },
};
