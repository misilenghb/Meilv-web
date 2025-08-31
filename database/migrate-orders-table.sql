-- 订单表迁移脚本 - 支持人工收款流程
-- 请在Supabase SQL编辑器中执行

-- 1. 备份现有orders表（如果存在）
DO $$
BEGIN
    IF EXISTS (SELECT FROM information_schema.tables WHERE table_name = 'orders') THEN
        DROP TABLE IF EXISTS orders_backup;
        CREATE TABLE orders_backup AS SELECT * FROM orders;
        RAISE NOTICE '已备份现有orders表到orders_backup';
    END IF;
END $$;

-- 2. 删除现有orders表
DROP TABLE IF EXISTS orders CASCADE;

-- 3. 创建新的orders表结构
CREATE TABLE orders (
  id UUID DEFAULT gen_random_uuid() PRIMARY KEY,
  user_id UUID REFERENCES users(id) ON DELETE CASCADE NOT NULL,
  guide_id UUID REFERENCES guides(id) ON DELETE CASCADE,
  
  -- 需求信息 (JSON格式存储)
  requirement JSONB NOT NULL,
  
  -- 金额相关
  deposit_amount DECIMAL(10,2) DEFAULT 0, -- 定金金额
  total_amount DECIMAL(10,2), -- 总金额
  final_amount DECIMAL(10,2), -- 最终金额
  
  -- 状态管理
  status VARCHAR(20) DEFAULT 'DRAFT' CHECK (status IN (
    'DRAFT', 'DEPOSIT_PAID', 'GUIDE_SELECTED', 'CONFIRMED', 
    'PAYMENT_PENDING', 'PAID', 'IN_PROGRESS', 'COMPLETED', 
    'CANCELLED', 'REFUNDED'
  )),
  
  -- 人工收款相关
  payment_method VARCHAR(20) CHECK (payment_method IN ('cash', 'wechat', 'alipay', 'bank_transfer')),
  payment_notes TEXT,
  collected_by UUID REFERENCES users(id),
  
  -- 备注
  notes TEXT,
  
  -- 时间戳
  created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
  updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
  
  -- 流程时间戳
  deposit_paid_at TIMESTAMP WITH TIME ZONE,
  guide_selected_at TIMESTAMP WITH TIME ZONE,
  confirmed_at TIMESTAMP WITH TIME ZONE,
  payment_collected_at TIMESTAMP WITH TIME ZONE,
  started_at TIMESTAMP WITH TIME ZONE,
  completed_at TIMESTAMP WITH TIME ZONE
);

-- 4. 创建索引
CREATE INDEX idx_orders_user_id ON orders(user_id);
CREATE INDEX idx_orders_guide_id ON orders(guide_id);
CREATE INDEX idx_orders_status ON orders(status);
CREATE INDEX idx_orders_created_at ON orders(created_at);
CREATE INDEX idx_orders_requirement_gin ON orders USING gin(requirement);

-- 5. 创建更新时间触发器
CREATE OR REPLACE FUNCTION update_updated_at_column()
RETURNS TRIGGER AS $$
BEGIN
    NEW.updated_at = NOW();
    RETURN NEW;
END;
$$ language 'plpgsql';

CREATE TRIGGER update_orders_updated_at 
    BEFORE UPDATE ON orders 
    FOR EACH ROW 
    EXECUTE FUNCTION update_updated_at_column();

-- 6. 启用行级安全策略
ALTER TABLE orders ENABLE ROW LEVEL SECURITY;

-- 7. 创建RLS策略
-- 用户只能查看自己的订单
CREATE POLICY "Users can view own orders" ON orders
    FOR SELECT USING (auth.uid()::text = user_id::text);

-- 用户可以创建自己的订单
CREATE POLICY "Users can create own orders" ON orders
    FOR INSERT WITH CHECK (auth.uid()::text = user_id::text);

-- 用户可以更新自己的订单
CREATE POLICY "Users can update own orders" ON orders
    FOR UPDATE USING (auth.uid()::text = user_id::text);

-- 地陪可以查看分配给自己的订单
CREATE POLICY "Guides can view assigned orders" ON orders
    FOR SELECT USING (auth.uid()::text = guide_id::text);

-- 地陪可以更新分配给自己的订单
CREATE POLICY "Guides can update assigned orders" ON orders
    FOR UPDATE USING (auth.uid()::text = guide_id::text);

-- 管理员可以查看所有订单
CREATE POLICY "Admins can view all orders" ON orders
    FOR ALL USING (
        EXISTS (
            SELECT 1 FROM users 
            WHERE id::text = auth.uid()::text 
            AND role = 'admin'
        )
    );

-- 8. 插入测试数据
INSERT INTO orders (
    id,
    user_id,
    guide_id,
    requirement,
    deposit_amount,
    total_amount,
    final_amount,
    status,
    created_at,
    updated_at,
    guide_selected_at,
    confirmed_at,
    payment_collected_at,
    started_at,
    completed_at
) VALUES (
    'order001'::uuid,
    (SELECT id FROM users WHERE phone = '13800000000' LIMIT 1),
    (SELECT id FROM guides WHERE display_name = '杭州地陪小美' LIMIT 1),
    '{"startTime": "2024-01-15T10:00:00.000Z", "duration": 4, "serviceType": "daily", "area": "朝阳区", "address": "三里屯", "specialRequests": "希望地陪熟悉当地美食"}'::jsonb,
    50.00,
    792.00,
    742.00,
    'COMPLETED',
    NOW() - INTERVAL '2 days',
    NOW() - INTERVAL '1 day',
    NOW() - INTERVAL '2 days',
    NOW() - INTERVAL '1 day',
    NOW() - INTERVAL '1 day',
    NOW() - INTERVAL '1 day',
    NOW() - INTERVAL '1 hour'
);

RAISE NOTICE '订单表迁移完成！';
RAISE NOTICE '新表结构支持：';
RAISE NOTICE '- 人工收款流程';
RAISE NOTICE '- JSON格式需求信息';
RAISE NOTICE '- 完整的状态管理';
RAISE NOTICE '- 流程时间戳跟踪';
