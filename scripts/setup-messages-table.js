const { createClient } = require('@supabase/supabase-js');
const fs = require('fs');
const path = require('path');
require('dotenv').config({ path: '.env.local' });

const supabaseUrl = process.env.NEXT_PUBLIC_SUPABASE_URL;
const supabaseKey = process.env.SUPABASE_SERVICE_ROLE_KEY;

if (!supabaseUrl || !supabaseKey) {
  console.error('Missing Supabase environment variables');
  process.exit(1);
}

const supabase = createClient(supabaseUrl, supabaseKey);

async function setupMessagesTable() {
  try {
    console.log('开始设置 Supabase 消息表...');

    // 读取 SQL 文件
    const sqlPath = path.join(__dirname, '../database/messages-schema.sql');
    const sqlContent = fs.readFileSync(sqlPath, 'utf8');

    // 将 SQL 分割成单独的语句
    const statements = sqlContent
      .split(';')
      .map(stmt => stmt.trim())
      .filter(stmt => stmt.length > 0 && !stmt.startsWith('--'));

    console.log(`准备执行 ${statements.length} 个 SQL 语句...`);

    // 逐个执行 SQL 语句
    for (let i = 0; i < statements.length; i++) {
      const statement = statements[i];
      if (statement.trim()) {
        try {
          console.log(`执行语句 ${i + 1}/${statements.length}...`);
          
          // 使用 rpc 调用执行 SQL
          const { data, error } = await supabase.rpc('exec_sql', { 
            sql: statement + ';' 
          });

          if (error) {
            // 如果 rpc 不可用，尝试直接使用 SQL 查询
            console.log(`RPC 执行失败，尝试其他方法: ${error.message}`);
            
            // 对于简单的 CREATE TABLE 语句，我们可以手动创建
            if (statement.includes('CREATE TABLE') && statement.includes('messages')) {
              console.log('手动创建消息表...');
              
              // 检查表是否已存在
              const { data: tables, error: tableError } = await supabase
                .from('information_schema.tables')
                .select('table_name')
                .eq('table_schema', 'public')
                .eq('table_name', 'messages');

              if (tableError) {
                console.log('无法检查表是否存在，跳过此步骤');
              } else if (tables && tables.length > 0) {
                console.log('✓ 消息表已存在');
              } else {
                console.log('需要手动在 Supabase 控制台创建消息表');
                console.log('请在 Supabase SQL 编辑器中执行以下 SQL:');
                console.log('---');
                console.log(sqlContent);
                console.log('---');
              }
            }
          } else {
            console.log(`✓ 语句 ${i + 1} 执行成功`);
          }
        } catch (err) {
          console.log(`语句 ${i + 1} 执行出错: ${err.message}`);
        }
      }
    }

    // 验证表是否创建成功
    console.log('验证消息表...');
    const { data: messages, error: selectError } = await supabase
      .from('messages')
      .select('id')
      .limit(1);

    if (selectError) {
      console.error('❌ 消息表验证失败:', selectError.message);
      console.log('\n请手动在 Supabase 控制台执行以下 SQL:');
      console.log('---');
      console.log(sqlContent);
      console.log('---');
    } else {
      console.log('✅ 消息表验证成功！');
      
      // 检查是否有测试数据
      const { data: testMessages, error: testError } = await supabase
        .from('messages')
        .select('id, content')
        .limit(5);

      if (testError) {
        console.log('无法检查测试数据:', testError.message);
      } else {
        console.log(`✓ 找到 ${testMessages?.length || 0} 条测试消息`);
        if (testMessages && testMessages.length > 0) {
          testMessages.forEach((msg, index) => {
            console.log(`  ${index + 1}. ${msg.content.substring(0, 30)}...`);
          });
        }
      }
    }

    console.log('✅ 消息表设置完成！');

  } catch (error) {
    console.error('设置消息表时发生错误:', error);
    console.log('\n如果自动设置失败，请手动在 Supabase 控制台执行 SQL 文件:');
    console.log('database/messages-schema.sql');
    process.exit(1);
  }
}

// 运行设置脚本
setupMessagesTable();
