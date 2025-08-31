-- 修复订单流程中发现的问题
-- 请在Supabase SQL编辑器中执行

-- 1. 修复状态约束，添加缺失的REFUND_REJECTED状态
ALTER TABLE orders DROP CONSTRAINT IF EXISTS orders_status_check;
ALTER TABLE orders ADD CONSTRAINT orders_status_check 
CHECK (status IN (
  -- 小写状态（当前使用）
  'pending', 'confirmed', 'in_progress', 'completed', 'cancelled',
  -- 大写状态（新系统，向前兼容）
  'DRAFT', 'GUIDE_SELECTED', 'DEPOSIT_PENDING', 'DEPOSIT_PAID', 
  'PAID', 'IN_PROGRESS', 'COMPLETED', 'CANCELLED', 'REFUNDED', 'REFUND_REJECTED'
));

-- 2. 检查并修复数据不一致的订单
-- 查找有金额但无地陪的订单
SELECT id, total_amount, guide_id, status 
FROM orders 
WHERE total_amount > 0 AND guide_id IS NULL;

-- 如果确认是错误数据，可以执行以下修复（请先确认）
-- UPDATE orders 
-- SET total_amount = 0, hourly_rate = 0
-- WHERE total_amount > 0 AND guide_id IS NULL AND status = 'pending';

-- 3. 添加数据一致性检查函数
CREATE OR REPLACE FUNCTION check_order_consistency()
RETURNS TABLE(
  order_id UUID,
  issue_type TEXT,
  description TEXT
) AS $$
BEGIN
  -- 检查有金额但无地陪的订单
  RETURN QUERY
  SELECT 
    o.id,
    'amount_without_guide'::TEXT,
    'Order has amount but no guide assigned'::TEXT
  FROM orders o
  WHERE o.total_amount > 0 AND o.guide_id IS NULL;
  
  -- 检查已完成但无金额的订单
  RETURN QUERY
  SELECT 
    o.id,
    'completed_without_amount'::TEXT,
    'Order is completed but has no amount'::TEXT
  FROM orders o
  WHERE (o.status = 'completed' OR o.status = 'COMPLETED') 
    AND (o.total_amount IS NULL OR o.total_amount <= 0);
    
  -- 检查有地陪但状态为pending的订单
  RETURN QUERY
  SELECT 
    o.id,
    'guide_with_pending_status'::TEXT,
    'Order has guide but status is still pending'::TEXT
  FROM orders o
  WHERE o.guide_id IS NOT NULL AND o.status = 'pending';
END;
$$ LANGUAGE plpgsql;

-- 4. 运行一致性检查
SELECT * FROM check_order_consistency();

-- 5. 创建订单状态历史表（用于审计）
CREATE TABLE IF NOT EXISTS order_status_history (
  id UUID DEFAULT gen_random_uuid() PRIMARY KEY,
  order_id UUID REFERENCES orders(id) ON DELETE CASCADE NOT NULL,
  old_status VARCHAR(20),
  new_status VARCHAR(20) NOT NULL,
  changed_by UUID REFERENCES users(id) ON DELETE SET NULL,
  reason TEXT,
  created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- 6. 创建状态变更触发器
CREATE OR REPLACE FUNCTION log_order_status_change()
RETURNS TRIGGER AS $$
BEGIN
  -- 只在状态真正改变时记录
  IF OLD.status IS DISTINCT FROM NEW.status THEN
    INSERT INTO order_status_history (order_id, old_status, new_status)
    VALUES (NEW.id, OLD.status, NEW.status);
  END IF;
  RETURN NEW;
END;
$$ LANGUAGE plpgsql;

-- 创建触发器
DROP TRIGGER IF EXISTS order_status_change_trigger ON orders;
CREATE TRIGGER order_status_change_trigger
  AFTER UPDATE ON orders
  FOR EACH ROW
  EXECUTE FUNCTION log_order_status_change();

-- 7. 验证修复结果
SELECT 
  'Status constraint check' as check_type,
  COUNT(*) as total_orders,
  COUNT(CASE WHEN status NOT IN (
    'pending', 'confirmed', 'in_progress', 'completed', 'cancelled',
    'DRAFT', 'GUIDE_SELECTED', 'DEPOSIT_PENDING', 'DEPOSIT_PAID', 
    'PAID', 'IN_PROGRESS', 'COMPLETED', 'CANCELLED', 'REFUNDED', 'REFUND_REJECTED'
  ) THEN 1 END) as invalid_status_count
FROM orders;
