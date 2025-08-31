-- 创建消息表
CREATE TABLE IF NOT EXISTS public.messages (
    id UUID DEFAULT gen_random_uuid() PRIMARY KEY,
    from_user_id UUID NOT NULL REFERENCES public.users(id) ON DELETE CASCADE,
    to_user_id UUID NOT NULL REFERENCES public.users(id) ON DELETE CASCADE,
    content TEXT NOT NULL,
    is_read BOOLEAN DEFAULT false,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- 创建索引以提高查询性能
CREATE INDEX IF NOT EXISTS idx_messages_from_user ON public.messages(from_user_id);
CREATE INDEX IF NOT EXISTS idx_messages_to_user ON public.messages(to_user_id);
CREATE INDEX IF NOT EXISTS idx_messages_conversation ON public.messages(from_user_id, to_user_id);
CREATE INDEX IF NOT EXISTS idx_messages_created_at ON public.messages(created_at DESC);
CREATE INDEX IF NOT EXISTS idx_messages_unread ON public.messages(to_user_id, is_read) WHERE is_read = false;

-- 创建触发器自动更新 updated_at
CREATE OR REPLACE FUNCTION update_messages_updated_at()
RETURNS TRIGGER AS $$
BEGIN
    NEW.updated_at = NOW();
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

DROP TRIGGER IF EXISTS trigger_update_messages_updated_at ON public.messages;
CREATE TRIGGER trigger_update_messages_updated_at
    BEFORE UPDATE ON public.messages
    FOR EACH ROW
    EXECUTE FUNCTION update_messages_updated_at();

-- 启用行级安全策略 (RLS)
ALTER TABLE public.messages ENABLE ROW LEVEL SECURITY;

-- 创建安全策略：用户只能查看自己相关的消息
CREATE POLICY "Users can view their own messages" ON public.messages
    FOR SELECT USING (
        auth.uid()::text IN (from_user_id::text, to_user_id::text)
    );

-- 创建安全策略：用户只能插入自己发送的消息
CREATE POLICY "Users can insert their own messages" ON public.messages
    FOR INSERT WITH CHECK (
        auth.uid()::text = from_user_id::text
    );

-- 创建安全策略：用户只能更新自己接收的消息（如标记为已读）
CREATE POLICY "Users can update messages sent to them" ON public.messages
    FOR UPDATE USING (
        auth.uid()::text = to_user_id::text
    );

-- 插入测试消息数据
DO $$
DECLARE
    user1_id UUID;
    user2_id UUID;
    guide1_id UUID;
    guide2_id UUID;
BEGIN
    -- 获取测试用户ID
    SELECT id INTO user1_id FROM public.users WHERE phone = '13800138001' LIMIT 1;
    SELECT id INTO user2_id FROM public.users WHERE phone = '13800138002' LIMIT 1;
    SELECT id INTO guide1_id FROM public.users WHERE phone = '13900000001' LIMIT 1;
    SELECT id INTO guide2_id FROM public.users WHERE phone = '13700000000' LIMIT 1;

    -- 如果找到用户，插入测试消息
    IF user1_id IS NOT NULL AND guide1_id IS NOT NULL THEN
        INSERT INTO public.messages (from_user_id, to_user_id, content, created_at) VALUES
        (user1_id, guide1_id, '你好，我想了解一下杭州的旅游路线', NOW() - INTERVAL '2 hours'),
        (guide1_id, user1_id, '您好！我可以为您推荐西湖一日游路线，包括断桥残雪、雷峰塔等经典景点', NOW() - INTERVAL '1 hour 30 minutes'),
        (user1_id, guide1_id, '听起来不错，大概需要多长时间？', NOW() - INTERVAL '1 hour'),
        (guide1_id, user1_id, '一般是6-8小时，可以根据您的时间安排调整', NOW() - INTERVAL '30 minutes'),
        (user1_id, guide1_id, '价格怎么样？', NOW() - INTERVAL '15 minutes'),
        (guide1_id, user1_id, '西湖一日游套餐价格是2900元，包含导游服务和景点门票', NOW() - INTERVAL '10 minutes');
    END IF;

    IF user2_id IS NOT NULL AND guide2_id IS NOT NULL THEN
        INSERT INTO public.messages (from_user_id, to_user_id, content, created_at) VALUES
        (user2_id, guide2_id, '你好，我想预约明天的陪伴服务', NOW() - INTERVAL '3 hours'),
        (guide2_id, user2_id, '您好！明天我有空，请问您需要什么类型的服务？', NOW() - INTERVAL '2 hours 45 minutes'),
        (user2_id, guide2_id, '就是日常陪伴，逛街购物之类的', NOW() - INTERVAL '2 hours 30 minutes'),
        (guide2_id, user2_id, '好的，我的日常陪伴服务是150元/小时，您看可以吗？', NOW() - INTERVAL '2 hours 15 minutes');
    END IF;

    -- 输出结果
    RAISE NOTICE '测试消息数据插入完成';
END $$;

-- 创建视图方便查询对话列表
CREATE OR REPLACE VIEW public.conversation_list AS
SELECT DISTINCT
    CASE 
        WHEN m.from_user_id < m.to_user_id THEN m.from_user_id
        ELSE m.to_user_id
    END as user1_id,
    CASE 
        WHEN m.from_user_id < m.to_user_id THEN m.to_user_id
        ELSE m.from_user_id
    END as user2_id,
    (SELECT content FROM public.messages m2 
     WHERE (m2.from_user_id = m.from_user_id AND m2.to_user_id = m.to_user_id)
        OR (m2.from_user_id = m.to_user_id AND m2.to_user_id = m.from_user_id)
     ORDER BY m2.created_at DESC LIMIT 1) as last_message,
    (SELECT created_at FROM public.messages m2 
     WHERE (m2.from_user_id = m.from_user_id AND m2.to_user_id = m.to_user_id)
        OR (m2.from_user_id = m.to_user_id AND m2.to_user_id = m.from_user_id)
     ORDER BY m2.created_at DESC LIMIT 1) as last_message_time,
    (SELECT COUNT(*) FROM public.messages m2 
     WHERE m2.to_user_id = CASE 
         WHEN m.from_user_id < m.to_user_id THEN m.from_user_id
         ELSE m.to_user_id
     END
     AND (m2.from_user_id = CASE 
         WHEN m.from_user_id < m.to_user_id THEN m.to_user_id
         ELSE m.from_user_id
     END)
     AND m2.is_read = false) as unread_count_user1,
    (SELECT COUNT(*) FROM public.messages m2 
     WHERE m2.to_user_id = CASE 
         WHEN m.from_user_id < m.to_user_id THEN m.to_user_id
         ELSE m.from_user_id
     END
     AND (m2.from_user_id = CASE 
         WHEN m.from_user_id < m.to_user_id THEN m.from_user_id
         ELSE m.to_user_id
     END)
     AND m2.is_read = false) as unread_count_user2
FROM public.messages m;
