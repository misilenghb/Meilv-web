-- 🚨 紧急修复SQL脚本 - 直接复制到Supabase SQL编辑器执行
-- 修复orders表结构不匹配问题

-- 1. 添加requirement字段（核心修复）
ALTER TABLE orders ADD COLUMN IF NOT EXISTS requirement JSONB;

-- 2. 为现有订单填充requirement字段
UPDATE orders 
SET requirement = jsonb_build_object(
  'serviceType', service_type,
  'startTime', start_time,
  'duration', duration_hours,
  'area', COALESCE(SPLIT_PART(location, ' ', 1), '未知区域'),
  'address', COALESCE(SPLIT_PART(location, ' ', 2), location),
  'specialRequests', COALESCE(service_description, '')
)
WHERE requirement IS NULL;

-- 3. 添加缺失的金额字段
ALTER TABLE orders ADD COLUMN IF NOT EXISTS deposit_amount DECIMAL(10,2) DEFAULT 0;
ALTER TABLE orders ADD COLUMN IF NOT EXISTS final_amount DECIMAL(10,2);

-- 4. 添加支付相关字段
ALTER TABLE orders ADD COLUMN IF NOT EXISTS payment_method VARCHAR(20);
ALTER TABLE orders ADD COLUMN IF NOT EXISTS payment_notes TEXT;
ALTER TABLE orders ADD COLUMN IF NOT EXISTS collected_by UUID;

-- 5. 添加时间戳字段
ALTER TABLE orders ADD COLUMN IF NOT EXISTS deposit_paid_at TIMESTAMP WITH TIME ZONE;
ALTER TABLE orders ADD COLUMN IF NOT EXISTS guide_selected_at TIMESTAMP WITH TIME ZONE;
ALTER TABLE orders ADD COLUMN IF NOT EXISTS confirmed_at TIMESTAMP WITH TIME ZONE;
ALTER TABLE orders ADD COLUMN IF NOT EXISTS payment_collected_at TIMESTAMP WITH TIME ZONE;
ALTER TABLE orders ADD COLUMN IF NOT EXISTS started_at TIMESTAMP WITH TIME ZONE;
ALTER TABLE orders ADD COLUMN IF NOT EXISTS completed_at TIMESTAMP WITH TIME ZONE;

-- 6. 更新状态约束（支持大小写状态）
ALTER TABLE orders DROP CONSTRAINT IF EXISTS orders_status_check;
ALTER TABLE orders ADD CONSTRAINT orders_status_check 
CHECK (status IN (
  -- 小写状态（当前使用）
  'pending', 'confirmed', 'in_progress', 'completed', 'cancelled',
  -- 大写状态（新系统，向前兼容）
  'DRAFT', 'GUIDE_SELECTED', 'DEPOSIT_PENDING', 'DEPOSIT_PAID', 
  'PAID', 'IN_PROGRESS', 'COMPLETED', 'CANCELLED', 'REFUNDED'
));

-- 7. 添加支付方式约束
ALTER TABLE orders ADD CONSTRAINT IF NOT EXISTS orders_payment_method_check 
CHECK (payment_method IS NULL OR payment_method IN ('cash', 'wechat', 'alipay', 'bank_transfer'));

-- 8. 创建性能索引
CREATE INDEX IF NOT EXISTS idx_orders_user_id ON orders(user_id);
CREATE INDEX IF NOT EXISTS idx_orders_guide_id ON orders(guide_id);
CREATE INDEX IF NOT EXISTS idx_orders_status ON orders(status);
CREATE INDEX IF NOT EXISTS idx_orders_created_at ON orders(created_at);
CREATE INDEX IF NOT EXISTS idx_orders_requirement_gin ON orders USING GIN (requirement);

-- 9. 验证修复结果
SELECT 
    '✅ 修复验证' as status,
    COUNT(*) as total_orders,
    COUNT(requirement) as orders_with_requirement,
    COUNT(deposit_amount) as orders_with_deposit_amount
FROM orders;

-- 10. 显示新增字段
SELECT 
    '📋 新增字段检查' as check_type,
    column_name, 
    data_type, 
    is_nullable
FROM information_schema.columns 
WHERE table_name = 'orders' 
AND table_schema = 'public'
AND column_name IN ('requirement', 'deposit_amount', 'payment_method', 'deposit_paid_at')
ORDER BY column_name;
