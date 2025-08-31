const { createClient } = require('@supabase/supabase-js');
require('dotenv').config({ path: '.env.local' });

const supabaseUrl = process.env.NEXT_PUBLIC_SUPABASE_URL;
const supabaseServiceKey = process.env.SUPABASE_SERVICE_ROLE_KEY;

console.log('Creating tables using service_role key...');
console.log('URL:', supabaseUrl);
console.log('Service Key:', supabaseServiceKey ? `${supabaseServiceKey.substring(0, 20)}...` : 'Not found');

const supabase = createClient(supabaseUrl, supabaseServiceKey);

async function createTables() {
  try {
    console.log('\n1. Creating users table...');
    
    // 创建用户表
    const { data: usersResult, error: usersError } = await supabase.rpc('exec_sql', {
      sql: `
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
      `
    });

    if (usersError) {
      console.error('❌ Error creating users table:', usersError);
      // 尝试直接执行SQL
      console.log('Trying alternative method...');
      
      const { error: directError } = await supabase
        .from('_supabase_admin')
        .select('*')
        .limit(1);
        
      if (directError) {
        console.log('Direct SQL execution not available, trying table creation...');
        
        // 尝试直接插入到一个测试表来验证连接
        const { data: testData, error: testError } = await supabase
          .from('users')
          .select('id')
          .limit(1);
          
        if (testError && testError.message.includes('does not exist')) {
          console.log('✅ Connection works, but tables need to be created manually');
          console.log('Please execute the SQL script manually in Supabase dashboard');
          return false;
        } else if (testError) {
          console.error('Connection error:', testError);
          return false;
        } else {
          console.log('✅ Users table already exists');
        }
      }
    } else {
      console.log('✅ Users table created successfully');
    }

    console.log('\n2. Testing table access...');
    
    // 测试表访问
    const { data: testUsers, error: selectError } = await supabase
      .from('users')
      .select('id, phone, name')
      .limit(1);

    if (selectError) {
      if (selectError.message.includes('does not exist')) {
        console.log('❌ Users table does not exist - manual creation required');
        return false;
      } else {
        console.error('❌ Error accessing users table:', selectError);
        return false;
      }
    }

    console.log('✅ Users table access successful');
    console.log('Found users:', testUsers?.length || 0);

    console.log('\n3. Testing insert operation...');
    
    // 测试插入操作
    const testUser = {
      phone: '13800138000',
      name: '测试用户',
      role: 'user',
      intended_role: 'user'
    };

    const { data: insertedUser, error: insertError } = await supabase
      .from('users')
      .upsert([testUser], { onConflict: 'phone' })
      .select()
      .single();

    if (insertError) {
      console.error('❌ Error inserting test user:', insertError);
      return false;
    }

    console.log('✅ Test user created/updated:', insertedUser);

    return true;
  } catch (error) {
    console.error('❌ Unexpected error:', error);
    return false;
  }
}

async function createAllTables() {
  console.log('🚀 Starting table creation process...\n');
  
  const success = await createTables();
  
  if (success) {
    console.log('\n🎉 Database setup completed successfully!');
    console.log('\nNext steps:');
    console.log('1. Run: npm run dev');
    console.log('2. Test registration: http://localhost:3001/register');
    console.log('3. Test guide application: http://localhost:3001/apply-guide');
  } else {
    console.log('\n❌ Database setup failed.');
    console.log('\nManual setup required:');
    console.log('1. Go to: https://fauzguzoamyahhcqhvoc.supabase.co/project/fauzguzoamyahhcqhvoc/sql');
    console.log('2. Copy and paste the contents of database/basic-tables.sql');
    console.log('3. Click "Run" to execute the script');
    console.log('4. Run this script again to verify');
  }
  
  process.exit(success ? 0 : 1);
}

createAllTables();
