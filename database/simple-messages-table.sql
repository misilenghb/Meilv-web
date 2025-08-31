-- 创建消息表（简化版本）
CREATE TABLE IF NOT EXISTS public.messages (
    id UUID DEFAULT gen_random_uuid() PRIMARY KEY,
    from_user_id UUID NOT NULL,
    to_user_id UUID NOT NULL,
    content TEXT NOT NULL,
    is_read BOOLEAN DEFAULT false,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- 创建索引
CREATE INDEX IF NOT EXISTS idx_messages_from_user ON public.messages(from_user_id);
CREATE INDEX IF NOT EXISTS idx_messages_to_user ON public.messages(to_user_id);
CREATE INDEX IF NOT EXISTS idx_messages_created_at ON public.messages(created_at DESC);

-- 插入测试数据（使用已知的用户ID）
INSERT INTO public.messages (from_user_id, to_user_id, content, created_at) VALUES
('259e7f8e-f50e-4e26-b770-f3f52530e54a', '709dd56f-0a15-4c7d-a8d2-9c39ce976af2', '你好，我想了解一下杭州的旅游路线', NOW() - INTERVAL '2 hours'),
('709dd56f-0a15-4c7d-a8d2-9c39ce976af2', '259e7f8e-f50e-4e26-b770-f3f52530e54a', '您好！我可以为您推荐西湖一日游路线，包括断桥残雪、雷峰塔等经典景点', NOW() - INTERVAL '1 hour 30 minutes'),
('259e7f8e-f50e-4e26-b770-f3f52530e54a', '709dd56f-0a15-4c7d-a8d2-9c39ce976af2', '听起来不错，大概需要多长时间？', NOW() - INTERVAL '1 hour'),
('709dd56f-0a15-4c7d-a8d2-9c39ce976af2', '259e7f8e-f50e-4e26-b770-f3f52530e54a', '一般是6-8小时，可以根据您的时间安排调整', NOW() - INTERVAL '30 minutes'),
('259e7f8e-f50e-4e26-b770-f3f52530e54a', '709dd56f-0a15-4c7d-a8d2-9c39ce976af2', '价格怎么样？', NOW() - INTERVAL '15 minutes'),
('709dd56f-0a15-4c7d-a8d2-9c39ce976af2', '259e7f8e-f50e-4e26-b770-f3f52530e54a', '西湖一日游套餐价格是2900元，包含导游服务和景点门票', NOW() - INTERVAL '10 minutes');

-- 插入第二组对话
INSERT INTO public.messages (from_user_id, to_user_id, content, created_at) VALUES
('3ba015bf-02ff-42de-9acc-a4340717e08e', 'dd7e6264-2992-41f8-a00e-627ebf8c6c4f', '你好，我想预约明天的陪伴服务', NOW() - INTERVAL '3 hours'),
('dd7e6264-2992-41f8-a00e-627ebf8c6c4f', '3ba015bf-02ff-42de-9acc-a4340717e08e', '您好！明天我有空，请问您需要什么类型的服务？', NOW() - INTERVAL '2 hours 45 minutes'),
('3ba015bf-02ff-42de-9acc-a4340717e08e', 'dd7e6264-2992-41f8-a00e-627ebf8c6c4f', '就是日常陪伴，逛街购物之类的', NOW() - INTERVAL '2 hours 30 minutes'),
('dd7e6264-2992-41f8-a00e-627ebf8c6c4f', '3ba015bf-02ff-42de-9acc-a4340717e08e', '好的，我的日常陪伴服务是150元/小时，您看可以吗？', NOW() - INTERVAL '2 hours 15 minutes');
