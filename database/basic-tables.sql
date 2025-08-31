-- 基础表创建脚本 - 请在Supabase SQL编辑器中执行

-- 创建用户表
CREATE TABLE users (
  id UUID DEFAULT gen_random_uuid() PRIMARY KEY,
  phone VARCHAR(20) UNIQUE NOT NULL,
  name VARCHAR(100) NOT NULL,
  email VARCHAR(255),
  role VARCHAR(20) DEFAULT 'user' CHECK (role IN ('user', 'guide', 'admin')),
  intended_role VARCHAR(20) DEFAULT 'user' CHECK (intended_role IN ('user', 'guide', 'admin')),
  avatar_url TEXT,
  created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
  updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- 创建地陪申请表
CREATE TABLE guide_applications (
  id UUID DEFAULT gen_random_uuid() PRIMARY KEY,
  phone VARCHAR(20) NOT NULL,
  display_name VARCHAR(100) NOT NULL,
  real_name VARCHAR(100) NOT NULL,
  id_number VARCHAR(50) NOT NULL,
  email VARCHAR(255),
  gender VARCHAR(10) CHECK (gender IN ('male', 'female', 'other')),
  age INTEGER,
  city VARCHAR(100) NOT NULL,
  address TEXT NOT NULL,
  bio TEXT NOT NULL,
  skills TEXT[] NOT NULL,
  hourly_rate DECIMAL(10,2) NOT NULL,
  available_services TEXT[],
  languages TEXT[],
  id_card_front TEXT NOT NULL,
  id_card_back TEXT NOT NULL,
  health_certificate TEXT,
  background_check TEXT,
  photos TEXT[],
  experience TEXT,
  motivation TEXT,
  emergency_contact JSONB NOT NULL,
  status VARCHAR(20) DEFAULT 'pending' CHECK (status IN ('pending', 'under_review', 'approved', 'rejected', 'need_more_info')),
  review_notes TEXT,
  reviewed_by UUID,
  reviewed_at TIMESTAMP WITH TIME ZONE,
  review_history JSONB DEFAULT '[]'::jsonb,
  submitted_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
  updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- 创建地陪表
CREATE TABLE guides (
  id UUID DEFAULT gen_random_uuid() PRIMARY KEY,
  user_id UUID REFERENCES users(id) ON DELETE CASCADE,
  application_id UUID REFERENCES guide_applications(id),
  display_name VARCHAR(100) NOT NULL,
  bio TEXT,
  skills TEXT[],
  hourly_rate DECIMAL(10,2),
  services JSONB,
  photos TEXT[],
  city VARCHAR(100),
  location TEXT,
  rating_avg DECIMAL(3,2) DEFAULT 0,
  rating_count INTEGER DEFAULT 0,
  verification_status VARCHAR(20) DEFAULT 'unverified' CHECK (verification_status IN ('unverified', 'pending', 'verified', 'rejected', 'suspended')),
  verification_notes TEXT,
  verified_by UUID,
  verified_at TIMESTAMP WITH TIME ZONE,
  is_active BOOLEAN DEFAULT true,
  created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
  updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- 创建订单表
CREATE TABLE orders (
  id UUID DEFAULT gen_random_uuid() PRIMARY KEY,
  user_id UUID REFERENCES users(id) ON DELETE CASCADE,
  guide_id UUID REFERENCES guides(id) ON DELETE CASCADE,
  service_type VARCHAR(50) NOT NULL,
  service_title VARCHAR(200) NOT NULL,
  service_description TEXT,
  start_time TIMESTAMP WITH TIME ZONE NOT NULL,
  end_time TIMESTAMP WITH TIME ZONE NOT NULL,
  duration_hours INTEGER NOT NULL,
  hourly_rate DECIMAL(10,2) NOT NULL,
  total_amount DECIMAL(10,2) NOT NULL,
  status VARCHAR(20) DEFAULT 'pending' CHECK (status IN ('pending', 'confirmed', 'in_progress', 'completed', 'cancelled')),
  payment_status VARCHAR(20) DEFAULT 'pending' CHECK (payment_status IN ('pending', 'paid', 'refunded')),
  location TEXT,
  notes TEXT,
  created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
  updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- 创建基本索引
CREATE INDEX idx_users_phone ON users(phone);
CREATE INDEX idx_users_role ON users(role);
CREATE INDEX idx_guide_applications_phone ON guide_applications(phone);
CREATE INDEX idx_guide_applications_status ON guide_applications(status);
CREATE INDEX idx_guides_user_id ON guides(user_id);
CREATE INDEX idx_guides_city ON guides(city);
CREATE INDEX idx_orders_user_id ON orders(user_id);
CREATE INDEX idx_orders_guide_id ON orders(guide_id);
CREATE INDEX idx_orders_status ON orders(status);

-- 启用行级安全策略
ALTER TABLE users ENABLE ROW LEVEL SECURITY;
ALTER TABLE guide_applications ENABLE ROW LEVEL SECURITY;
ALTER TABLE guides ENABLE ROW LEVEL SECURITY;
ALTER TABLE orders ENABLE ROW LEVEL SECURITY;

-- 创建宽松的RLS策略（开发阶段）
CREATE POLICY "Enable all operations for users" ON users FOR ALL USING (true) WITH CHECK (true);
CREATE POLICY "Enable all operations for guide_applications" ON guide_applications FOR ALL USING (true) WITH CHECK (true);
CREATE POLICY "Enable all operations for guides" ON guides FOR ALL USING (true) WITH CHECK (true);
CREATE POLICY "Enable all operations for orders" ON orders FOR ALL USING (true) WITH CHECK (true);
