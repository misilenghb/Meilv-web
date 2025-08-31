const { Client } = require('pg');
const fs = require('fs');
const path = require('path');
require('dotenv').config({ path: '.env.local' });

// 从Supabase URL构建PostgreSQL连接字符串
const supabaseUrl = process.env.NEXT_PUBLIC_SUPABASE_URL;
const serviceKey = process.env.SUPABASE_SERVICE_ROLE_KEY;

if (!supabaseUrl || !serviceKey) {
  console.error('❌ Missing Supabase configuration');
  process.exit(1);
}

// 解析Supabase URL获取项目ID
const projectId = supabaseUrl.replace('https://', '').replace('.supabase.co', '');

// 构建PostgreSQL连接配置
const connectionConfig = {
  host: `db.${projectId}.supabase.co`,
  port: 5432,
  database: 'postgres',
  user: 'postgres',
  password: serviceKey, // 使用service key作为密码
  ssl: {
    rejectUnauthorized: false
  }
};

console.log('🔗 Connecting to Supabase PostgreSQL...');
console.log(`Host: ${connectionConfig.host}`);
console.log(`Database: ${connectionConfig.database}`);

async function createTables() {
  const client = new Client(connectionConfig);
  
  try {
    await client.connect();
    console.log('✅ Connected to PostgreSQL');

    // 读取SQL脚本
    const sqlPath = path.join(__dirname, '..', 'database', 'basic-tables.sql');
    const sqlScript = fs.readFileSync(sqlPath, 'utf8');

    console.log('📄 Executing SQL script...');
    
    // 分割SQL语句（按分号分割，但忽略注释）
    const statements = sqlScript
      .split(';')
      .map(stmt => stmt.trim())
      .filter(stmt => stmt.length > 0 && !stmt.startsWith('--'));

    for (let i = 0; i < statements.length; i++) {
      const statement = statements[i];
      if (statement.trim()) {
        try {
          console.log(`Executing statement ${i + 1}/${statements.length}...`);
          await client.query(statement);
          console.log(`✅ Statement ${i + 1} executed successfully`);
        } catch (error) {
          console.error(`❌ Error in statement ${i + 1}:`, error.message);
          console.log('Statement:', statement.substring(0, 100) + '...');
          
          // 如果是"already exists"错误，继续执行
          if (error.message.includes('already exists')) {
            console.log('⚠️  Object already exists, continuing...');
            continue;
          }
          
          throw error;
        }
      }
    }

    console.log('\n🎉 All tables created successfully!');

    // 验证表创建
    console.log('\n🔍 Verifying table creation...');
    
    const tables = ['users', 'guide_applications', 'guides'];
    for (const table of tables) {
      try {
        const result = await client.query(`SELECT COUNT(*) FROM ${table}`);
        console.log(`✅ ${table}: ${result.rows[0].count} records`);
      } catch (error) {
        console.error(`❌ ${table}: ${error.message}`);
      }
    }

    // 测试插入操作
    console.log('\n🧪 Testing insert operation...');
    
    const testUser = {
      phone: `1380013800${Date.now() % 100}`,
      name: '测试用户',
      role: 'user',
      intended_role: 'user'
    };

    const insertResult = await client.query(
      'INSERT INTO users (phone, name, role, intended_role) VALUES ($1, $2, $3, $4) RETURNING id, name',
      [testUser.phone, testUser.name, testUser.role, testUser.intended_role]
    );

    console.log(`✅ Test user created: ${insertResult.rows[0].name} (ID: ${insertResult.rows[0].id})`);

    // 清理测试数据
    await client.query('DELETE FROM users WHERE id = $1', [insertResult.rows[0].id]);
    console.log('✅ Test data cleaned up');

    return true;
  } catch (error) {
    console.error('❌ Database operation failed:', error.message);
    
    if (error.message.includes('password authentication failed')) {
      console.log('\n💡 Troubleshooting:');
      console.log('1. Make sure SUPABASE_SERVICE_ROLE_KEY is correct');
      console.log('2. Check if the service key has database access permissions');
      console.log('3. Verify the project ID in the URL is correct');
    } else if (error.message.includes('ENOTFOUND')) {
      console.log('\n💡 Troubleshooting:');
      console.log('1. Check your internet connection');
      console.log('2. Verify the Supabase project URL is correct');
      console.log('3. Make sure the project is active');
    }
    
    return false;
  } finally {
    await client.end();
    console.log('🔌 Database connection closed');
  }
}

async function main() {
  console.log('🚀 Starting automatic table creation...\n');
  
  const success = await createTables();
  
  if (success) {
    console.log('\n🎉 Database setup completed successfully!');
    console.log('\nNext steps:');
    console.log('1. Run: npm run dev');
    console.log('2. Test registration: http://localhost:3001/register');
    console.log('3. Test guide application: http://localhost:3001/apply-guide');
    console.log('4. Verify with: node scripts/verify-database.js');
  } else {
    console.log('\n❌ Automatic setup failed.');
    console.log('\nFallback options:');
    console.log('1. Manual setup in Supabase dashboard');
    console.log('2. Check connection settings');
    console.log('3. Verify service key permissions');
  }
  
  process.exit(success ? 0 : 1);
}

main().catch(error => {
  console.error('❌ Script failed:', error);
  process.exit(1);
});
