// Cloudflare Worker 入口文件
// 用于处理 Next.js 应用的请求

export default {
  async fetch(request, env, ctx) {
    const url = new URL(request.url);
    
    // 处理静态资源
    if (url.pathname.startsWith('/_next/static/')) {
      // 直接返回静态文件
      return env.ASSETS.fetch(request);
    }
    
    // 处理 API 路由
    if (url.pathname.startsWith('/api/')) {
      // 这里可以添加 API 路由处理逻辑
      return new Response(JSON.stringify({ 
        message: 'API endpoint',
        path: url.pathname 
      }), {
        headers: { 'Content-Type': 'application/json' }
      });
    }
    
    // 处理页面请求
    try {
      // 尝试从 assets 获取文件
      const response = await env.ASSETS.fetch(request);
      
      if (response.status === 404) {
        // 如果找不到文件，返回 index.html (SPA 路由支持)
        const indexRequest = new Request(
          new URL('/index.html', request.url),
          request
        );
        return env.ASSETS.fetch(indexRequest);
      }
      
      return response;
    } catch (error) {
      return new Response('Internal Server Error', { status: 500 });
    }
  },
};
