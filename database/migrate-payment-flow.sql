-- 更新订单表以支持新的支付流程
-- 添加新的字段来支持保证金和尾款分离收取

-- 1. 添加新的支付相关字段
ALTER TABLE orders 
ADD COLUMN IF NOT EXISTS deposit_payment_method VARCHAR(20),
ADD COLUMN IF NOT EXISTS deposit_payment_notes TEXT,
ADD COLUMN IF NOT EXISTS final_payment_method VARCHAR(20),
ADD COLUMN IF NOT EXISTS final_payment_notes TEXT,
ADD COLUMN IF NOT EXISTS deposit_paid_at TIMESTAMP WITH TIME ZONE,
ADD COLUMN IF NOT EXISTS final_payment_paid_at TIMESTAMP WITH TIME ZONE,
ADD COLUMN IF NOT EXISTS confirmed_at TIMESTAMP WITH TIME ZONE;

-- 2. 更新状态约束以支持新的状态
ALTER TABLE orders 
DROP CONSTRAINT IF EXISTS orders_status_check;

ALTER TABLE orders 
ADD CONSTRAINT orders_status_check 
CHECK (status IN (
  'pending', 'confirmed', 'guide_selected', 'in_progress', 'completed', 'cancelled',
  'DRAFT', 'GUIDE_SELECTED', 'DEPOSIT_PENDING', 'DEPOSIT_PAID', 
  'CONFIRMED', 'FINAL_PAYMENT_PENDING', 'PAID', 'IN_PROGRESS', 
  'COMPLETED', 'CANCELLED', 'REFUNDED'
));

-- 3. 添加支付方式约束
ALTER TABLE orders 
ADD CONSTRAINT orders_deposit_payment_method_check 
CHECK (deposit_payment_method IS NULL OR deposit_payment_method IN ('cash', 'wechat', 'alipay', 'bank_transfer'));

ALTER TABLE orders 
ADD CONSTRAINT orders_final_payment_method_check 
CHECK (final_payment_method IS NULL OR final_payment_method IN ('cash', 'wechat', 'alipay', 'bank_transfer'));

-- 4. 更新现有订单数据以适配新流程
-- 将现有的 payment_status = 'paid' 的订单状态更新为新的状态
UPDATE orders 
SET status = 'PAID'
WHERE payment_status = 'paid' AND status IN ('pending', 'confirmed', 'guide_selected');

-- 将现有的等待收款订单状态更新为等待收取保证金
UPDATE orders 
SET status = 'DEPOSIT_PENDING'
WHERE payment_status = 'pending' AND status IN ('pending', 'confirmed', 'guide_selected');

-- 5. 为现有订单设置 final_amount（尾款金额）
UPDATE orders 
SET final_amount = GREATEST(total_amount - 200, 0)
WHERE final_amount IS NULL AND total_amount IS NOT NULL;

-- 6. 创建索引以提高查询性能
CREATE INDEX IF NOT EXISTS idx_orders_status_payment ON orders(status, payment_status);
CREATE INDEX IF NOT EXISTS idx_orders_deposit_paid_at ON orders(deposit_paid_at);
CREATE INDEX IF NOT EXISTS idx_orders_final_payment_paid_at ON orders(final_payment_paid_at);
CREATE INDEX IF NOT EXISTS idx_orders_confirmed_at ON orders(confirmed_at);

-- 7. 添加注释
COMMENT ON COLUMN orders.deposit_payment_method IS '保证金收款方式';
COMMENT ON COLUMN orders.deposit_payment_notes IS '保证金收款备注';
COMMENT ON COLUMN orders.final_payment_method IS '尾款收款方式';
COMMENT ON COLUMN orders.final_payment_notes IS '尾款收款备注';
COMMENT ON COLUMN orders.deposit_paid_at IS '保证金收款时间';
COMMENT ON COLUMN orders.final_payment_paid_at IS '尾款收款时间';
COMMENT ON COLUMN orders.confirmed_at IS '见面确认时间';
COMMENT ON COLUMN orders.final_amount IS '尾款金额（总金额 - 保证金）';

-- 8. 创建视图以便于查询不同状态的订单
CREATE OR REPLACE VIEW pending_deposit_orders AS
SELECT * FROM orders 
WHERE status = 'DEPOSIT_PENDING'
ORDER BY created_at DESC;

CREATE OR REPLACE VIEW pending_meeting_confirmation_orders AS
SELECT * FROM orders 
WHERE status = 'DEPOSIT_PAID'
ORDER BY created_at DESC;

CREATE OR REPLACE VIEW pending_final_payment_orders AS
SELECT * FROM orders 
WHERE status = 'FINAL_PAYMENT_PENDING'
ORDER BY created_at DESC;

-- 9. 创建函数来计算今日收款统计
CREATE OR REPLACE FUNCTION get_today_payment_stats()
RETURNS TABLE(
  deposit_count BIGINT,
  deposit_amount NUMERIC,
  final_payment_count BIGINT,
  final_payment_amount NUMERIC,
  total_revenue NUMERIC
) AS $$
BEGIN
  RETURN QUERY
  SELECT 
    COUNT(*) FILTER (WHERE deposit_paid_at::date = CURRENT_DATE) as deposit_count,
    COALESCE(SUM(200) FILTER (WHERE deposit_paid_at::date = CURRENT_DATE), 0) as deposit_amount,
    COUNT(*) FILTER (WHERE final_payment_paid_at::date = CURRENT_DATE) as final_payment_count,
    COALESCE(SUM(final_amount) FILTER (WHERE final_payment_paid_at::date = CURRENT_DATE), 0) as final_payment_amount,
    COALESCE(SUM(200) FILTER (WHERE deposit_paid_at::date = CURRENT_DATE), 0) + 
    COALESCE(SUM(final_amount) FILTER (WHERE final_payment_paid_at::date = CURRENT_DATE), 0) as total_revenue
  FROM orders;
END;
$$ LANGUAGE plpgsql;
