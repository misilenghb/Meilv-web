-- 修复订单表结构
-- 添加缺失的字段并修改约束

-- 1. 添加 deposit_paid_at 字段
ALTER TABLE orders ADD COLUMN IF NOT EXISTS deposit_paid_at TIMESTAMP WITH TIME ZONE;

-- 2. 修改 hourly_rate 和 total_amount 字段，允许为空或默认值
ALTER TABLE orders ALTER COLUMN hourly_rate DROP NOT NULL;
ALTER TABLE orders ALTER COLUMN hourly_rate SET DEFAULT 0;

ALTER TABLE orders ALTER COLUMN total_amount DROP NOT NULL;
ALTER TABLE orders ALTER COLUMN total_amount SET DEFAULT 0;

-- 3. 更新现有数据，将 total_amount 为 200 的记录（错误的保证金金额）重置为 0
UPDATE orders 
SET total_amount = 0, hourly_rate = 0 
WHERE total_amount = 200 AND guide_id IS NULL;

-- 4. 显示更新后的表结构
\d orders;
