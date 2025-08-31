-- 美旅系统数据库设置脚本
-- 请在Supabase SQL编辑器中执行此脚本

-- 1. 创建users表（如果不存在）
CREATE TABLE IF NOT EXISTS users (
    id UUID DEFAULT gen_random_uuid() PRIMARY KEY,
    phone VARCHAR(20) UNIQUE NOT NULL,
    name VARCHAR(100) NOT NULL,
    password_hash TEXT,
    email VARCHAR(255),
    avatar_url TEXT,
    bio TEXT,
    location VARCHAR(100),
    role VARCHAR(20) DEFAULT 'user',
    intended_role VARCHAR(20) DEFAULT 'user',
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- 2. 添加password_hash列（如果不存在）
ALTER TABLE users 
ADD COLUMN IF NOT EXISTS password_hash TEXT;

-- 3. 创建索引
CREATE INDEX IF NOT EXISTS idx_users_phone ON users(phone);
CREATE INDEX IF NOT EXISTS idx_users_role ON users(role);

-- 4. 插入默认管理员用户（如果不存在）
INSERT INTO users (phone, name, password_hash, role, intended_role, email)
SELECT '13900000000', '系统管理员', '$2a$10$92IXUNpkjO0rOQ5byMi.Ye4oKoEa3Ro9llC/.og/at2.uheWG/igi', 'admin', 'admin', 'admin@meilv.com'
WHERE NOT EXISTS (
    SELECT 1 FROM users WHERE phone = '13900000000'
);

-- 注意：上面的password_hash对应密码"123456"
-- 首次登录后请立即修改密码

-- 5. 创建其他必要的表

-- 地陪申请表
CREATE TABLE IF NOT EXISTS guide_applications (
    id UUID DEFAULT gen_random_uuid() PRIMARY KEY,
    user_id UUID REFERENCES users(id),
    display_name VARCHAR(100) NOT NULL,
    real_name VARCHAR(100) NOT NULL,
    id_number VARCHAR(18) NOT NULL,
    phone VARCHAR(20) NOT NULL,
    email VARCHAR(255),
    gender VARCHAR(10),
    age INTEGER,
    city VARCHAR(100) NOT NULL,
    address TEXT NOT NULL,
    bio TEXT NOT NULL,
    skills TEXT[] NOT NULL,
    hourly_rate DECIMAL(10,2) NOT NULL,
    available_services TEXT[],
    languages TEXT[] DEFAULT ARRAY['中文'],
    id_card_front TEXT NOT NULL,
    id_card_back TEXT NOT NULL,
    health_certificate TEXT,
    background_check TEXT,
    photos TEXT[] NOT NULL,
    experience TEXT NOT NULL,
    motivation TEXT NOT NULL,
    emergency_contact JSONB NOT NULL,
    status VARCHAR(20) DEFAULT 'pending',
    submitted_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    reviewed_at TIMESTAMP WITH TIME ZONE,
    reviewer_id UUID REFERENCES users(id),
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- 订单表
CREATE TABLE IF NOT EXISTS orders (
    id UUID DEFAULT gen_random_uuid() PRIMARY KEY,
    user_id UUID REFERENCES users(id),
    guide_id UUID REFERENCES users(id),
    service_type VARCHAR(50),
    start_date DATE,
    end_date DATE,
    location VARCHAR(200),
    description TEXT,
    price DECIMAL(10,2),
    status VARCHAR(20) DEFAULT 'pending',
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- 收藏表
CREATE TABLE IF NOT EXISTS favorites (
    id UUID DEFAULT gen_random_uuid() PRIMARY KEY,
    user_id UUID REFERENCES users(id),
    guide_id UUID REFERENCES users(id),
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    UNIQUE(user_id, guide_id)
);

-- 评价表
CREATE TABLE IF NOT EXISTS reviews (
    id UUID DEFAULT gen_random_uuid() PRIMARY KEY,
    order_id UUID REFERENCES orders(id),
    user_id UUID REFERENCES users(id),
    guide_id UUID REFERENCES users(id),
    rating INTEGER CHECK (rating >= 1 AND rating <= 5),
    comment TEXT,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- 创建索引
CREATE INDEX IF NOT EXISTS idx_guide_applications_user_id ON guide_applications(user_id);
CREATE INDEX IF NOT EXISTS idx_guide_applications_status ON guide_applications(status);
CREATE INDEX IF NOT EXISTS idx_orders_user_id ON orders(user_id);
CREATE INDEX IF NOT EXISTS idx_orders_guide_id ON orders(guide_id);
CREATE INDEX IF NOT EXISTS idx_orders_status ON orders(status);
CREATE INDEX IF NOT EXISTS idx_favorites_user_id ON favorites(user_id);
CREATE INDEX IF NOT EXISTS idx_favorites_guide_id ON favorites(guide_id);
CREATE INDEX IF NOT EXISTS idx_reviews_guide_id ON reviews(guide_id);

-- 启用行级安全性（RLS）
ALTER TABLE users ENABLE ROW LEVEL SECURITY;
ALTER TABLE guide_applications ENABLE ROW LEVEL SECURITY;
ALTER TABLE orders ENABLE ROW LEVEL SECURITY;
ALTER TABLE favorites ENABLE ROW LEVEL SECURITY;
ALTER TABLE reviews ENABLE ROW LEVEL SECURITY;

-- 创建基本的RLS策略（可根据需要调整）
-- 用户可以查看和更新自己的信息
CREATE POLICY "Users can view own profile" ON users
    FOR SELECT USING (auth.uid()::text = id::text);

CREATE POLICY "Users can update own profile" ON users
    FOR UPDATE USING (auth.uid()::text = id::text);

-- 管理员可以查看所有用户
CREATE POLICY "Admins can view all users" ON users
    FOR ALL USING (
        EXISTS (
            SELECT 1 FROM users 
            WHERE id::text = auth.uid()::text 
            AND role = 'admin'
        )
    );

-- 完成提示
SELECT 'Database setup completed successfully!' as message;
