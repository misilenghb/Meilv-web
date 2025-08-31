-- 强制刷新Supabase PostgREST schema缓存
-- 请在Supabase SQL编辑器中执行

-- 方法1：发送NOTIFY信号强制刷新
NOTIFY pgrst, 'reload schema';

-- 方法2：更新pg_stat_statements来触发刷新
SELECT pg_stat_statements_reset();

-- 方法3：检查当前orders表的实际结构
SELECT column_name, data_type, is_nullable, column_default
FROM information_schema.columns 
WHERE table_name = 'orders' 
AND table_schema = 'public'
ORDER BY ordinal_position;

-- 方法4：强制重新加载表定义
DROP VIEW IF EXISTS orders_view;
CREATE VIEW orders_view AS SELECT * FROM orders LIMIT 0;
DROP VIEW orders_view;

-- 方法5：更新表注释来触发schema更新
COMMENT ON TABLE orders IS 'Orders table - updated at ' || NOW();

-- 验证表结构
\d orders;
