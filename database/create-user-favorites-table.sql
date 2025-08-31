-- 创建用户收藏表
-- 请在Supabase SQL编辑器中执行此脚本

-- 创建 user_favorites 表
CREATE TABLE IF NOT EXISTS user_favorites (
    id UUID DEFAULT gen_random_uuid() PRIMARY KEY,
    user_id UUID NOT NULL REFERENCES users(id) ON DELETE CASCADE,
    guide_id UUID NOT NULL REFERENCES guides(id) ON DELETE CASCADE,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    UNIQUE(user_id, guide_id)
);

-- 创建索引
CREATE INDEX IF NOT EXISTS idx_user_favorites_user_id ON user_favorites(user_id);
CREATE INDEX IF NOT EXISTS idx_user_favorites_guide_id ON user_favorites(guide_id);
CREATE INDEX IF NOT EXISTS idx_user_favorites_created_at ON user_favorites(created_at DESC);

-- 启用行级安全性（RLS）
ALTER TABLE user_favorites ENABLE ROW LEVEL SECURITY;

-- 创建RLS策略
-- 用户可以查看自己的收藏
CREATE POLICY "Users can view own favorites" ON user_favorites
    FOR SELECT USING (
        auth.uid()::text = user_id::text
    );

-- 用户可以添加收藏
CREATE POLICY "Users can add favorites" ON user_favorites
    FOR INSERT WITH CHECK (
        auth.uid()::text = user_id::text
    );

-- 用户可以删除自己的收藏
CREATE POLICY "Users can delete own favorites" ON user_favorites
    FOR DELETE USING (
        auth.uid()::text = user_id::text
    );

-- 如果存在旧的 favorites 表，迁移数据
DO $$
BEGIN
    IF EXISTS (SELECT FROM information_schema.tables WHERE table_name = 'favorites') THEN
        -- 迁移数据从 favorites 到 user_favorites
        INSERT INTO user_favorites (user_id, guide_id, created_at)
        SELECT user_id, guide_id, created_at
        FROM favorites
        ON CONFLICT (user_id, guide_id) DO NOTHING;
        
        RAISE NOTICE '已从 favorites 表迁移数据到 user_favorites 表';
    END IF;
END $$;

-- 完成提示
SELECT 'User favorites table created successfully!' as message;
