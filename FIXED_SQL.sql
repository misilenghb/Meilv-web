-- 修复后的SQL脚本 - 去除语法错误
-- 请逐步执行以下SQL语句

-- 步骤1: 添加requirement字段
ALTER TABLE orders ADD COLUMN IF NOT EXISTS requirement JSONB;

-- 步骤2: 添加其他缺失字段
ALTER TABLE orders ADD COLUMN IF NOT EXISTS deposit_amount DECIMAL(10,2) DEFAULT 0;
ALTER TABLE orders ADD COLUMN IF NOT EXISTS payment_method VARCHAR(20);
ALTER TABLE orders ADD COLUMN IF NOT EXISTS deposit_paid_at TIMESTAMP WITH TIME ZONE;
ALTER TABLE orders ADD COLUMN IF NOT EXISTS guide_selected_at TIMESTAMP WITH TIME ZONE;
ALTER TABLE orders ADD COLUMN IF NOT EXISTS confirmed_at TIMESTAMP WITH TIME ZONE;

-- 步骤3: 更新状态约束
ALTER TABLE orders DROP CONSTRAINT IF EXISTS orders_status_check;

-- 步骤4: 添加新的状态约束
ALTER TABLE orders ADD CONSTRAINT orders_status_check 
CHECK (status IN (
  'pending', 'confirmed', 'in_progress', 'completed', 'cancelled',
  'DRAFT', 'GUIDE_SELECTED', 'DEPOSIT_PENDING', 'DEPOSIT_PAID', 
  'PAID', 'IN_PROGRESS', 'COMPLETED', 'CANCELLED', 'REFUNDED'
));

-- 步骤5: 为现有订单填充requirement字段
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
