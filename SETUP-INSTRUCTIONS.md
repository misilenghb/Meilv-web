# 🚀 Supabase数据库设置指南

## ❓ 为什么需要手动创建表？

### **技术原因**
- **API限制**: Supabase Management API不支持DDL操作（CREATE TABLE）
- **安全考虑**: 防止通过API意外修改数据库架构
- **权限分离**: Service Role Key用于数据操作，不是数据库管理

### **MCP工具局限**
- Supabase MCP主要用于项目管理
- 不包含数据库架构操作功能
- DDL操作需要通过Web界面或CLI

## 📋 设置步骤

### **步骤1: 打开Supabase SQL编辑器**

点击链接打开：https://fauzguzoamyahhcqhvoc.supabase.co/project/fauzguzoamyahhcqhvoc/sql

### **步骤2: 执行SQL脚本**

复制以下完整的SQL脚本并粘贴到编辑器中：

```sql
-- 美旅地陪平台 - 数据库初始化脚本
-- 请在Supabase SQL编辑器中一次性执行

-- 1. 创建用户表
CREATE TABLE IF NOT EXISTS users (
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

-- 2. 创建地陪申请表
CREATE TABLE IF NOT EXISTS guide_applications (
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

-- 3. 创建地陪表
CREATE TABLE IF NOT EXISTS guides (
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

-- 4. 创建索引
CREATE INDEX IF NOT EXISTS idx_users_phone ON users(phone);
CREATE INDEX IF NOT EXISTS idx_users_role ON users(role);
CREATE INDEX IF NOT EXISTS idx_guide_applications_phone ON guide_applications(phone);
CREATE INDEX IF NOT EXISTS idx_guide_applications_status ON guide_applications(status);
CREATE INDEX IF NOT EXISTS idx_guides_user_id ON guides(user_id);
CREATE INDEX IF NOT EXISTS idx_guides_city ON guides(city);

-- 5. 启用行级安全策略
ALTER TABLE users ENABLE ROW LEVEL SECURITY;
ALTER TABLE guide_applications ENABLE ROW LEVEL SECURITY;
ALTER TABLE guides ENABLE ROW LEVEL SECURITY;

-- 6. 创建RLS策略（开发阶段使用宽松策略）
CREATE POLICY "Enable all operations for users" ON users FOR ALL USING (true) WITH CHECK (true);
CREATE POLICY "Enable all operations for guide_applications" ON guide_applications FOR ALL USING (true) WITH CHECK (true);
CREATE POLICY "Enable all operations for guides" ON guides FOR ALL USING (true) WITH CHECK (true);

-- 7. 插入测试数据（可选）
INSERT INTO users (phone, name, role, intended_role) VALUES 
('13800138000', '测试用户', 'user', 'user'),
('13800138001', '测试地陪', 'user', 'guide')
ON CONFLICT (phone) DO NOTHING;
```

### **步骤3: 点击"Run"按钮**

在SQL编辑器中点击"Run"按钮执行脚本。

### **步骤4: 验证创建结果**

执行完成后，运行验证脚本：

```bash
node scripts/verify-database.js
```

如果看到以下输出说明成功：
```
✅ All required tables exist!
✅ Database is fully functional!
```

### **步骤5: 启动应用**

```bash
npm run dev
```

应用将在 http://localhost:3001 启动。

## 🔧 故障排除

### **问题1: SQL执行失败**
- **解决**: 确保一次性复制完整的SQL脚本
- **检查**: 是否有语法错误或权限问题

### **问题2: 表已存在错误**
- **解决**: 使用 `CREATE TABLE IF NOT EXISTS` 语句
- **说明**: 这是正常的，表示表已经创建

### **问题3: 权限错误**
- **解决**: 确保在正确的Supabase项目中执行
- **检查**: 项目URL是否正确

## 🎯 功能测试清单

创建表后，测试以下功能：

- [ ] 用户注册: http://localhost:3001/register
- [ ] 地陪申请: http://localhost:3001/apply-guide  
- [ ] 地陪工作台: http://localhost:3001/guide-dashboard
- [ ] 管理员审核: http://localhost:3001/admin/applications

## 📞 技术支持

如果遇到问题：

1. **检查环境变量**: 确保 `.env.local` 配置正确
2. **验证连接**: 运行 `node scripts/test-supabase.js`
3. **查看日志**: 检查浏览器控制台和服务器日志
4. **重新执行**: 可以安全地重复执行SQL脚本

## 🔮 未来改进

### **可能的自动化方案**
1. **Supabase CLI**: 官方CLI工具支持迁移
2. **GitHub Actions**: 自动化部署流程
3. **Docker**: 容器化数据库初始化

### **当前限制**
- Management API不支持DDL操作
- 需要Web界面或CLI进行架构管理
- 安全限制防止API直接修改架构

---

**总结**: 虽然无法通过MCP直接创建表，但通过Web界面执行SQL脚本是最安全可靠的方法。这种设计保护了数据库架构的安全性。
