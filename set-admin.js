// 设置管理员账号
require('dotenv').config({ path: '.env.local' });
const { createClient } = require('@supabase/supabase-js');
const bcrypt = require('bcryptjs');

const supabaseUrl = process.env.NEXT_PUBLIC_SUPABASE_URL;
const supabaseServiceKey = process.env.SUPABASE_SERVICE_ROLE_KEY;

const supabase = createClient(supabaseUrl, supabaseServiceKey);

async function setAdmin() {
  try {
    const adminPhone = '15988859056';
    const adminPassword = '123456'; // 默认密码，建议登录后修改
    
    console.log(`🔧 Setting up admin account for: ${adminPhone}`);
    
    // 生成密码哈希
    const passwordHash = await bcrypt.hash(adminPassword, 10);
    
    // 检查用户是否已存在
    const { data: existingUser } = await supabase
      .from('users')
      .select('id, phone, role')
      .eq('phone', adminPhone)
      .single();
    
    if (existingUser) {
      console.log('📱 User already exists, updating to admin...');
      
      // 更新现有用户为管理员
      const { data, error } = await supabase
        .from('users')
        .update({
          role: 'admin',
          intended_role: 'admin',
          password_hash: passwordHash,
          updated_at: new Date().toISOString()
        })
        .eq('phone', adminPhone)
        .select();
      
      if (error) {
        console.error('❌ Error updating user:', error);
        return;
      }
      
      console.log('✅ User updated to admin successfully!');
      console.log('Updated user:', data[0]);
      
    } else {
      console.log('👤 Creating new admin user...');
      
      // 创建新的管理员用户
      const { data, error } = await supabase
        .from('users')
        .insert([{
          phone: adminPhone,
          name: '系统管理员',
          password_hash: passwordHash,
          role: 'admin',
          intended_role: 'admin',
          created_at: new Date().toISOString(),
          updated_at: new Date().toISOString()
        }])
        .select();
      
      if (error) {
        console.error('❌ Error creating admin user:', error);
        return;
      }
      
      console.log('✅ Admin user created successfully!');
      console.log('New admin user:', data[0]);
    }
    
    console.log('\n🎉 Admin setup complete!');
    console.log('📋 Login details:');
    console.log(`   Phone: ${adminPhone}`);
    console.log(`   Password: ${adminPassword}`);
    console.log('⚠️  Please change the password after first login!');
    
    // 验证管理员账号
    console.log('\n🔍 Verifying admin account...');
    const { data: adminUser } = await supabase
      .from('users')
      .select('id, phone, name, role, intended_role')
      .eq('phone', adminPhone)
      .single();
    
    if (adminUser && adminUser.role === 'admin') {
      console.log('✅ Admin verification successful!');
      console.log('Admin details:', adminUser);
    } else {
      console.log('❌ Admin verification failed!');
    }
    
  } catch (error) {
    console.error('❌ Setup error:', error.message);
  }
}

setAdmin();
