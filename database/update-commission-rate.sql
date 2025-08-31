-- 更新平台抽成比例为30%，地陪净收入为70%
-- 请在Supabase SQL编辑器中执行

-- 更新地陪收入统计视图
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
  COALESCE(SUM(CASE WHEN o.status = 'completed' THEN o.total_amount * 0.3 END), 0) as platform_commission, -- 30%平台抽成
  COALESCE(SUM(CASE WHEN o.status = 'completed' THEN o.total_amount * 0.7 END), 0) as net_earnings, -- 70%地陪收入
  COALESCE(SUM(gs.amount), 0) as settled_amount,
  COALESCE(SUM(CASE WHEN o.status = 'completed' THEN o.total_amount * 0.7 END), 0) - COALESCE(SUM(gs.amount), 0) as unsettled_amount -- 基于70%计算未结算金额
FROM guides g
LEFT JOIN orders o ON g.id = o.guide_id
LEFT JOIN guide_settlements gs ON g.id = gs.guide_id AND gs.status = 'completed'
WHERE g.is_active = true
GROUP BY g.id, g.display_name, g.hourly_rate, g.city, g.rating_avg, g.rating_count;

-- 验证视图更新
SELECT 
  guide_id,
  display_name,
  total_earnings,
  platform_commission,
  net_earnings,
  ROUND((platform_commission / NULLIF(total_earnings, 0)) * 100, 1) as commission_percentage,
  ROUND((net_earnings / NULLIF(total_earnings, 0)) * 100, 1) as guide_percentage
FROM guide_earnings_summary 
WHERE total_earnings > 0
LIMIT 5;
