// Cloudflare Pages Functions 中间件
// 用于处理 Next.js API 路由

export async function onRequest(context) {
  const { request, next, env } = context;
  
  // 设置环境变量
  if (env) {
    process.env.NEXT_PUBLIC_SUPABASE_URL = env.NEXT_PUBLIC_SUPABASE_URL;
    process.env.NEXT_PUBLIC_SUPABASE_ANON_KEY = env.NEXT_PUBLIC_SUPABASE_ANON_KEY;
    process.env.SUPABASE_SERVICE_ROLE_KEY = env.SUPABASE_SERVICE_ROLE_KEY;
    process.env.NEXT_PUBLIC_SUPABASE_STORAGE_URL = env.NEXT_PUBLIC_SUPABASE_STORAGE_URL;
    process.env.SUPABASE_STORAGE_KEY_ID = env.SUPABASE_STORAGE_KEY_ID;
    process.env.SUPABASE_STORAGE_ACCESS_KEY = env.SUPABASE_STORAGE_ACCESS_KEY;
  }
  
  // 继续处理请求
  return next();
}
