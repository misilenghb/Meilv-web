const { createClient } = require('@supabase/supabase-js');
require('dotenv').config({ path: '.env.local' });

const supabaseUrl = process.env.NEXT_PUBLIC_SUPABASE_URL;
const supabaseServiceKey = process.env.SUPABASE_SERVICE_ROLE_KEY;

console.log('🔍 Verifying Supabase database setup...\n');

const supabase = createClient(supabaseUrl, supabaseServiceKey);

async function verifyTables() {
  const requiredTables = ['users', 'guide_applications', 'guides'];
  const results = {};

  for (const table of requiredTables) {
    try {
      console.log(`Checking table: ${table}...`);
      
      const { data, error } = await supabase
        .from(table)
        .select('*')
        .limit(1);

      if (error) {
        if (error.message.includes('does not exist') || error.message.includes('Could not find')) {
          results[table] = { exists: false, error: 'Table does not exist' };
          console.log(`❌ ${table}: Does not exist`);
        } else {
          results[table] = { exists: false, error: error.message };
          console.log(`❌ ${table}: Error - ${error.message}`);
        }
      } else {
        results[table] = { exists: true, count: data?.length || 0 };
        console.log(`✅ ${table}: Exists (${data?.length || 0} records)`);
      }
    } catch (err) {
      results[table] = { exists: false, error: err.message };
      console.log(`❌ ${table}: Exception - ${err.message}`);
    }
  }

  return results;
}

async function testBasicOperations() {
  console.log('\n🧪 Testing basic operations...\n');

  // 测试用户表操作
  try {
    console.log('Testing users table operations...');
    
    // 尝试插入测试用户
    const testUser = {
      phone: `1380013800${Date.now() % 100}`,
      name: '测试用户',
      role: 'user',
      intended_role: 'user'
    };

    const { data: insertedUser, error: insertError } = await supabase
      .from('users')
      .insert([testUser])
      .select()
      .single();

    if (insertError) {
      console.log(`❌ Insert failed: ${insertError.message}`);
      return false;
    }

    console.log(`✅ User inserted: ${insertedUser.name} (${insertedUser.phone})`);

    // 测试查询
    const { data: users, error: selectError } = await supabase
      .from('users')
      .select('id, name, phone, role')
      .limit(5);

    if (selectError) {
      console.log(`❌ Select failed: ${selectError.message}`);
      return false;
    }

    console.log(`✅ Found ${users?.length || 0} users in database`);

    // 清理测试数据
    await supabase
      .from('users')
      .delete()
      .eq('id', insertedUser.id);

    console.log(`✅ Test user cleaned up`);

    return true;
  } catch (error) {
    console.log(`❌ Test failed: ${error.message}`);
    return false;
  }
}

async function main() {
  console.log('Configuration:');
  console.log(`URL: ${supabaseUrl}`);
  console.log(`Service Key: ${supabaseServiceKey ? 'Configured' : 'Missing'}\n`);

  if (!supabaseServiceKey) {
    console.log('❌ SUPABASE_SERVICE_ROLE_KEY is not configured');
    console.log('Please add it to your .env.local file\n');
    process.exit(1);
  }

  const tableResults = await verifyTables();
  
  const allTablesExist = Object.values(tableResults).every(result => result.exists);

  if (allTablesExist) {
    console.log('\n🎉 All required tables exist!');
    
    const operationsWork = await testBasicOperations();
    
    if (operationsWork) {
      console.log('\n✅ Database is fully functional!');
      console.log('\nYou can now:');
      console.log('1. Start the application: npm run dev');
      console.log('2. Test user registration: http://localhost:3001/register');
      console.log('3. Test guide application: http://localhost:3001/apply-guide');
      process.exit(0);
    } else {
      console.log('\n❌ Database operations failed');
      process.exit(1);
    }
  } else {
    console.log('\n❌ Some tables are missing. Manual setup required:');
    console.log('\n📋 Setup Instructions:');
    console.log('1. Open Supabase SQL Editor:');
    console.log('   https://fauzguzoamyahhcqhvoc.supabase.co/project/fauzguzoamyahhcqhvoc/sql');
    console.log('\n2. Copy and paste this SQL script:');
    console.log('   File: database/basic-tables.sql');
    console.log('\n3. Click "Run" to execute');
    console.log('\n4. Run this script again to verify: node scripts/verify-database.js');
    
    console.log('\n📄 Missing tables:');
    Object.entries(tableResults).forEach(([table, result]) => {
      if (!result.exists) {
        console.log(`   - ${table}: ${result.error}`);
      }
    });
    
    process.exit(1);
  }
}

main().catch(error => {
  console.error('❌ Verification failed:', error);
  process.exit(1);
});
