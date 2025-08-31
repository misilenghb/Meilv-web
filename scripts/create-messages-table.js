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

async function createMessagesTable() {
  try {
    console.log('开始创建消息表...');

    // 创建消息表
    const createTableSQL = `
      CREATE TABLE IF NOT EXISTS messages (
        id UUID DEFAULT gen_random_uuid() PRIMARY KEY,
        from_user_id UUID REFERENCES users(id) ON DELETE CASCADE NOT NULL,
        to_user_id UUID REFERENCES users(id) ON DELETE CASCADE NOT NULL,
        content TEXT NOT NULL,
        is_read BOOLEAN DEFAULT false,
        created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
        updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
      );
    `;

    const { error: createError } = await supabase.rpc('exec_sql', { sql: createTableSQL });
    if (createError) {
      console.error('创建表失败:', createError);
      // 尝试直接执行
      console.log('尝试使用 SQL 编辑器手动创建表...');
    } else {
      console.log('✓ 消息表创建成功');
    }

    // 创建索引
    const indexSQL = [
      'CREATE INDEX IF NOT EXISTS idx_messages_from_user ON messages(from_user_id);',
      'CREATE INDEX IF NOT EXISTS idx_messages_to_user ON messages(to_user_id);',
      'CREATE INDEX IF NOT EXISTS idx_messages_conversation ON messages(from_user_id, to_user_id);',
      'CREATE INDEX IF NOT EXISTS idx_messages_created_at ON messages(created_at);'
    ];

    for (const sql of indexSQL) {
      const { error } = await supabase.rpc('exec_sql', { sql });
      if (error) {
        console.log('索引创建可能失败:', sql);
      }
    }

    // 插入测试数据
    console.log('插入测试消息数据...');

    // 获取测试用户ID
    const { data: users, error: usersError } = await supabase
      .from('users')
      .select('id, phone, name')
      .in('phone', ['13800138001', '13800138002']);

    if (usersError || !users || users.length < 2) {
      console.error('获取测试用户失败:', usersError);
      console.log('请确保已有测试用户数据');
      return;
    }

    const user1 = users.find(u => u.phone === '13800138001');
    const user2 = users.find(u => u.phone === '13800138002');

    if (!user1 || !user2) {
      console.error('未找到必要的测试用户');
      return;
    }

    console.log(`找到用户: ${user1.name} (${user1.id}), ${user2.name} (${user2.id})`);

    // 插入测试消息
    const testMessages = [
      {
        from_user_id: user1.id,
        to_user_id: user2.id,
        content: '你好，我想了解一下杭州的旅游路线',
        created_at: new Date(Date.now() - 2 * 60 * 60 * 1000).toISOString() // 2小时前
      },
      {
        from_user_id: user2.id,
        to_user_id: user1.id,
        content: '您好！我可以为您推荐西湖一日游路线，包括断桥残雪、雷峰塔等经典景点',
        created_at: new Date(Date.now() - 90 * 60 * 1000).toISOString() // 1.5小时前
      },
      {
        from_user_id: user1.id,
        to_user_id: user2.id,
        content: '听起来不错，大概需要多长时间？',
        created_at: new Date(Date.now() - 60 * 60 * 1000).toISOString() // 1小时前
      },
      {
        from_user_id: user2.id,
        to_user_id: user1.id,
        content: '一般是6-8小时，可以根据您的时间安排调整',
        created_at: new Date(Date.now() - 30 * 60 * 1000).toISOString() // 30分钟前
      }
    ];

    for (const message of testMessages) {
      const { data, error } = await supabase
        .from('messages')
        .insert([message]);

      if (error) {
        console.error('插入消息失败:', error);
      } else {
        console.log(`✓ 消息创建成功: ${message.content.substring(0, 20)}...`);
      }
    }

    console.log('✅ 消息表和测试数据创建完成！');

  } catch (error) {
    console.error('创建消息表时发生错误:', error);
    process.exit(1);
  }
}

// 运行创建脚本
createMessagesTable();
