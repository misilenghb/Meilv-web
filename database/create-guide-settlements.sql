-- 创建地陪结算记录表
-- 请在Supabase SQL编辑器中执行

CREATE TABLE IF NOT EXISTS guide_settlements (
  id UUID DEFAULT gen_random_uuid() PRIMARY KEY,
  guide_id UUID REFERENCES guides(id) ON DELETE CASCADE NOT NULL,
  amount DECIMAL(10,2) NOT NULL CHECK (amount > 0),
  settlement_date TIMESTAMP WITH TIME ZONE NOT NULL DEFAULT NOW(),
  settlement_method VARCHAR(20) DEFAULT 'bank_transfer' CHECK (settlement_method IN ('bank_transfer', 'alipay', 'wechat', 'cash')),
  status VARCHAR(20) DEFAULT 'pending' CHECK (status IN ('pending', 'processing', 'completed', 'failed', 'cancelled')),
  notes TEXT,
  bank_info JSONB, -- 银行账户信息
  transaction_id VARCHAR(100), -- 交易流水号
  created_by UUID REFERENCES users(id) ON DELETE SET NULL,
  processed_by UUID REFERENCES users(id) ON DELETE SET NULL,
  created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
  updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
  processed_at TIMESTAMP WITH TIME ZONE
);

-- 创建索引
CREATE INDEX IF NOT EXISTS idx_guide_settlements_guide_id ON guide_settlements(guide_id);
CREATE INDEX IF NOT EXISTS idx_guide_settlements_status ON guide_settlements(status);
CREATE INDEX IF NOT EXISTS idx_guide_settlements_settlement_date ON guide_settlements(settlement_date);

-- 添加RLS策略
ALTER TABLE guide_settlements ENABLE ROW LEVEL SECURITY;

-- 管理员可以查看和操作所有结算记录
CREATE POLICY "Admins can manage all settlements" ON guide_settlements
  FOR ALL USING (
    EXISTS (
      SELECT 1 FROM users 
      WHERE users.id = auth.uid() 
      AND users.role = 'admin'
    )
  );

-- 地陪只能查看自己的结算记录
CREATE POLICY "Guides can view own settlements" ON guide_settlements
  FOR SELECT USING (
    EXISTS (
      SELECT 1 FROM guides 
      WHERE guides.id = guide_settlements.guide_id 
      AND guides.user_id = auth.uid()
    )
  );

-- 创建地陪收入统计视图
CREATE OR REPLACE VIEW guide_earnings_summary AS
SELECT 
  g.id as guide_id,
  g.display_name,
  g.hourly_rate,
  g.city,
  g.rating_avg,
  g.rating_count,
  COUNT(o.id) as total_orders,
  COUNT(CASE WHEN o.status = 'completed' THEN 1 END) as completed_orders,
  COALESCE(SUM(CASE WHEN o.status = 'completed' THEN o.total_amount END), 0) as total_earnings,
  COALESCE(SUM(CASE WHEN o.status IN ('confirmed', 'in_progress') THEN o.total_amount END), 0) as pending_earnings,
  COALESCE(SUM(CASE WHEN o.status = 'completed' THEN o.total_amount * 0.3 END), 0) as platform_commission,
  COALESCE(SUM(CASE WHEN o.status = 'completed' THEN o.total_amount * 0.7 END), 0) as net_earnings,
  COALESCE(SUM(gs.amount), 0) as settled_amount,
  COALESCE(SUM(CASE WHEN o.status = 'completed' THEN o.total_amount * 0.7 END), 0) - COALESCE(SUM(gs.amount), 0) as unsettled_amount
FROM guides g
LEFT JOIN orders o ON g.id = o.guide_id
LEFT JOIN guide_settlements gs ON g.id = gs.guide_id AND gs.status = 'completed'
WHERE g.is_active = true
GROUP BY g.id, g.display_name, g.hourly_rate, g.city, g.rating_avg, g.rating_count;

-- 创建触发器函数来更新updated_at字段
CREATE OR REPLACE FUNCTION update_guide_settlements_updated_at()
RETURNS TRIGGER AS $$
BEGIN
  NEW.updated_at = NOW();
  RETURN NEW;
END;
$$ LANGUAGE plpgsql;

-- 创建触发器
DROP TRIGGER IF EXISTS trigger_update_guide_settlements_updated_at ON guide_settlements;
CREATE TRIGGER trigger_update_guide_settlements_updated_at
  BEFORE UPDATE ON guide_settlements
  FOR EACH ROW
  EXECUTE FUNCTION update_guide_settlements_updated_at();

-- 插入一些示例数据（可选）
-- INSERT INTO guide_settlements (guide_id, amount, notes, created_by) 
-- SELECT 
--   g.id,
--   100.00,
--   '测试结算记录',
--   (SELECT id FROM users WHERE role = 'admin' LIMIT 1)
-- FROM guides g 
-- WHERE g.is_active = true 
-- LIMIT 3;
