-- 创建消息表
CREATE TABLE IF NOT EXISTS messages (
  id UUID DEFAULT gen_random_uuid() PRIMARY KEY,
  from_user_id UUID REFERENCES users(id) ON DELETE CASCADE NOT NULL,
  to_user_id UUID REFERENCES users(id) ON DELETE CASCADE NOT NULL,
  content TEXT NOT NULL,
  is_read BOOLEAN DEFAULT false,
  created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
  updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- 创建索引以提高查询性能
CREATE INDEX IF NOT EXISTS idx_messages_from_user ON messages(from_user_id);
CREATE INDEX IF NOT EXISTS idx_messages_to_user ON messages(to_user_id);
CREATE INDEX IF NOT EXISTS idx_messages_conversation ON messages(from_user_id, to_user_id);
CREATE INDEX IF NOT EXISTS idx_messages_created_at ON messages(created_at);

-- 创建触发器自动更新 updated_at
CREATE OR REPLACE FUNCTION update_messages_updated_at()
RETURNS TRIGGER AS $$
BEGIN
  NEW.updated_at = NOW();
  RETURN NEW;
END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER trigger_update_messages_updated_at
  BEFORE UPDATE ON messages
  FOR EACH ROW
  EXECUTE FUNCTION update_messages_updated_at();

-- 插入一些测试消息数据
INSERT INTO messages (from_user_id, to_user_id, content, created_at) VALUES
(
  (SELECT id FROM users WHERE phone = '13800138001' LIMIT 1),
  (SELECT id FROM users WHERE phone = '13800138002' LIMIT 1),
  '你好，我想了解一下杭州的旅游路线',
  NOW() - INTERVAL '2 hours'
),
(
  (SELECT id FROM users WHERE phone = '13800138002' LIMIT 1),
  (SELECT id FROM users WHERE phone = '13800138001' LIMIT 1),
  '您好！我可以为您推荐西湖一日游路线，包括断桥残雪、雷峰塔等经典景点',
  NOW() - INTERVAL '1 hour 30 minutes'
),
(
  (SELECT id FROM users WHERE phone = '13800138001' LIMIT 1),
  (SELECT id FROM users WHERE phone = '13800138002' LIMIT 1),
  '听起来不错，大概需要多长时间？',
  NOW() - INTERVAL '1 hour'
),
(
  (SELECT id FROM users WHERE phone = '13800138002' LIMIT 1),
  (SELECT id FROM users WHERE phone = '13800138001' LIMIT 1),
  '一般是6-8小时，可以根据您的时间安排调整',
  NOW() - INTERVAL '30 minutes'
);
