const { createClient } = require('@supabase/supabase-js');
require('dotenv').config({ path: '.env.local' });

const supabaseUrl = process.env.NEXT_PUBLIC_SUPABASE_URL;
const supabaseKey = process.env.SUPABASE_SERVICE_ROLE_KEY;

if (!supabaseUrl || !supabaseKey) {
  console.error('Missing Supabase environment variables');
  process.exit(1);
}

const supabase = createClient(supabaseUrl, supabaseKey);

async function insertTestMessages() {
  try {
    console.log('开始插入测试消息数据...');

    // 测试消息数据
    const testMessages = [
      {
        from_user_id: '259e7f8e-f50e-4e26-b770-f3f52530e54a', // 测试用户
        to_user_id: '709dd56f-0a15-4c7d-a8d2-9c39ce976af2',   // 地陪A
        content: '你好，我想了解一下杭州的旅游路线',
        created_at: new Date(Date.now() - 2 * 60 * 60 * 1000).toISOString() // 2小时前
      },
      {
        from_user_id: '709dd56f-0a15-4c7d-a8d2-9c39ce976af2', // 地陪A
        to_user_id: '259e7f8e-f50e-4e26-b770-f3f52530e54a',   // 测试用户
        content: '您好！我可以为您推荐西湖一日游路线，包括断桥残雪、雷峰塔等经典景点',
        created_at: new Date(Date.now() - 90 * 60 * 1000).toISOString() // 1.5小时前
      },
      {
        from_user_id: '259e7f8e-f50e-4e26-b770-f3f52530e54a', // 测试用户
        to_user_id: '709dd56f-0a15-4c7d-a8d2-9c39ce976af2',   // 地陪A
        content: '听起来不错，大概需要多长时间？',
        created_at: new Date(Date.now() - 60 * 60 * 1000).toISOString() // 1小时前
      },
      {
        from_user_id: '709dd56f-0a15-4c7d-a8d2-9c39ce976af2', // 地陪A
        to_user_id: '259e7f8e-f50e-4e26-b770-f3f52530e54a',   // 测试用户
        content: '一般是6-8小时，可以根据您的时间安排调整',
        created_at: new Date(Date.now() - 30 * 60 * 1000).toISOString() // 30分钟前
      },
      {
        from_user_id: '259e7f8e-f50e-4e26-b770-f3f52530e54a', // 测试用户
        to_user_id: '709dd56f-0a15-4c7d-a8d2-9c39ce976af2',   // 地陪A
        content: '价格怎么样？',
        created_at: new Date(Date.now() - 15 * 60 * 1000).toISOString() // 15分钟前
      },
      {
        from_user_id: '709dd56f-0a15-4c7d-a8d2-9c39ce976af2', // 地陪A
        to_user_id: '259e7f8e-f50e-4e26-b770-f3f52530e54a',   // 测试用户
        content: '西湖一日游套餐价格是2900元，包含导游服务和景点门票',
        created_at: new Date(Date.now() - 10 * 60 * 1000).toISOString() // 10分钟前
      }
    ];

    // 第二组对话
    const secondConversation = [
      {
        from_user_id: '3ba015bf-02ff-42de-9acc-a4340717e08e', // 地陪B
        to_user_id: 'dd7e6264-2992-41f8-a00e-627ebf8c6c4f',   // 地陪C
        content: '你好，我想预约明天的陪伴服务',
        created_at: new Date(Date.now() - 3 * 60 * 60 * 1000).toISOString() // 3小时前
      },
      {
        from_user_id: 'dd7e6264-2992-41f8-a00e-627ebf8c6c4f', // 地陪C
        to_user_id: '3ba015bf-02ff-42de-9acc-a4340717e08e',   // 地陪B
        content: '您好！明天我有空，请问您需要什么类型的服务？',
        created_at: new Date(Date.now() - 165 * 60 * 1000).toISOString() // 2小时45分钟前
      },
      {
        from_user_id: '3ba015bf-02ff-42de-9acc-a4340717e08e', // 地陪B
        to_user_id: 'dd7e6264-2992-41f8-a00e-627ebf8c6c4f',   // 地陪C
        content: '就是日常陪伴，逛街购物之类的',
        created_at: new Date(Date.now() - 150 * 60 * 1000).toISOString() // 2小时30分钟前
      },
      {
        from_user_id: 'dd7e6264-2992-41f8-a00e-627ebf8c6c4f', // 地陪C
        to_user_id: '3ba015bf-02ff-42de-9acc-a4340717e08e',   // 地陪B
        content: '好的，我的日常陪伴服务是150元/小时，您看可以吗？',
        created_at: new Date(Date.now() - 135 * 60 * 1000).toISOString() // 2小时15分钟前
      }
    ];

    // 合并所有消息
    const allMessages = [...testMessages, ...secondConversation];

    // 逐条插入消息
    for (const message of allMessages) {
      const { data, error } = await supabase
        .from('messages')
        .insert([message]);

      if (error) {
        console.error(`插入消息失败: ${message.content.substring(0, 20)}...`, error);
      } else {
        console.log(`✓ 消息插入成功: ${message.content.substring(0, 20)}...`);
      }
    }

    // 验证插入结果
    const { data: allInsertedMessages, error: selectError } = await supabase
      .from('messages')
      .select('id, content, created_at')
      .order('created_at', { ascending: true });

    if (selectError) {
      console.error('验证插入结果失败:', selectError);
    } else {
      console.log(`\n✅ 总共插入了 ${allInsertedMessages?.length || 0} 条消息:`);
      allInsertedMessages?.forEach((msg, index) => {
        console.log(`  ${index + 1}. ${msg.content.substring(0, 30)}... (${new Date(msg.created_at).toLocaleString()})`);
      });
    }

    console.log('\n✅ 测试消息数据插入完成！');

  } catch (error) {
    console.error('插入测试消息时发生错误:', error);
    process.exit(1);
  }
}

// 运行插入脚本
insertTestMessages();
