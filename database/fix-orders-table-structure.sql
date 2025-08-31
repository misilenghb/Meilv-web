-- 修复orders表结构 - 添加缺失的requirement字段
-- 这是一个关键的数据结构修复，解决代码与数据库不匹配的问题

-- 1. 添加requirement字段（JSONB类型）
ALTER TABLE orders ADD COLUMN IF NOT EXISTS requirement JSONB;

-- 2. 为现有订单填充requirement字段
-- 从现有字段构建requirement对象
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

-- 3. 添加其他可能缺失的字段
ALTER TABLE orders ADD COLUMN IF NOT EXISTS deposit_amount DECIMAL(10,2) DEFAULT 0;
ALTER TABLE orders ADD COLUMN IF NOT EXISTS final_amount DECIMAL(10,2);
ALTER TABLE orders ADD COLUMN IF NOT EXISTS payment_method VARCHAR(20);
ALTER TABLE orders ADD COLUMN IF NOT EXISTS payment_notes TEXT;
ALTER TABLE orders ADD COLUMN IF NOT EXISTS collected_by UUID;

-- 4. 添加时间戳字段
ALTER TABLE orders ADD COLUMN IF NOT EXISTS deposit_paid_at TIMESTAMP WITH TIME ZONE;
ALTER TABLE orders ADD COLUMN IF NOT EXISTS guide_selected_at TIMESTAMP WITH TIME ZONE;
ALTER TABLE orders ADD COLUMN IF NOT EXISTS confirmed_at TIMESTAMP WITH TIME ZONE;
ALTER TABLE orders ADD COLUMN IF NOT EXISTS payment_collected_at TIMESTAMP WITH TIME ZONE;
ALTER TABLE orders ADD COLUMN IF NOT EXISTS started_at TIMESTAMP WITH TIME ZONE;
ALTER TABLE orders ADD COLUMN IF NOT EXISTS completed_at TIMESTAMP WITH TIME ZONE;

-- 5. 更新状态约束以支持新的状态系统
ALTER TABLE orders DROP CONSTRAINT IF EXISTS orders_status_check;
ALTER TABLE orders ADD CONSTRAINT orders_status_check 
CHECK (status IN (
  -- 小写状态（当前使用）
  'pending', 'confirmed', 'in_progress', 'completed', 'cancelled',
  -- 大写状态（新系统，向前兼容）
  'DRAFT', 'GUIDE_SELECTED', 'DEPOSIT_PENDING', 'DEPOSIT_PAID', 
  'PAID', 'IN_PROGRESS', 'COMPLETED', 'CANCELLED', 'REFUNDED'
));

-- 6. 更新支付状态约束
ALTER TABLE orders DROP CONSTRAINT IF EXISTS orders_payment_status_check;
ALTER TABLE orders ADD CONSTRAINT orders_payment_status_check 
CHECK (payment_status IN ('pending', 'paid', 'refunded', 'partial'));

-- 7. 添加支付方式约束
ALTER TABLE orders ADD CONSTRAINT IF NOT EXISTS orders_payment_method_check 
CHECK (payment_method IS NULL OR payment_method IN ('cash', 'wechat', 'alipay', 'bank_transfer'));

-- 8. 创建索引以提高查询性能
CREATE INDEX IF NOT EXISTS idx_orders_user_id ON orders(user_id);
CREATE INDEX IF NOT EXISTS idx_orders_guide_id ON orders(guide_id);
CREATE INDEX IF NOT EXISTS idx_orders_status ON orders(status);
CREATE INDEX IF NOT EXISTS idx_orders_created_at ON orders(created_at);
CREATE INDEX IF NOT EXISTS idx_orders_start_time ON orders(start_time);

-- 9. 创建requirement字段的GIN索引（用于JSON查询）
CREATE INDEX IF NOT EXISTS idx_orders_requirement_gin ON orders USING GIN (requirement);

-- 10. 验证修复结果
DO $$
DECLARE
    missing_requirement_count INTEGER;
    total_orders_count INTEGER;
BEGIN
    -- 检查是否还有缺失requirement的订单
    SELECT COUNT(*) INTO missing_requirement_count 
    FROM orders 
    WHERE requirement IS NULL;
    
    SELECT COUNT(*) INTO total_orders_count 
    FROM orders;
    
    RAISE NOTICE '修复完成统计:';
    RAISE NOTICE '总订单数: %', total_orders_count;
    RAISE NOTICE '缺失requirement字段的订单数: %', missing_requirement_count;
    
    IF missing_requirement_count = 0 THEN
        RAISE NOTICE '✅ 所有订单都已有requirement字段';
    ELSE
        RAISE WARNING '⚠️ 仍有 % 个订单缺失requirement字段', missing_requirement_count;
    END IF;
END $$;

-- 11. 显示修复后的表结构
SELECT 
    column_name, 
    data_type, 
    is_nullable, 
    column_default
FROM information_schema.columns 
WHERE table_name = 'orders' 
AND table_schema = 'public'
ORDER BY ordinal_position;
