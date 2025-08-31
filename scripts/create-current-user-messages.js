const { createClient } = require('@supabase/supabase-js');
require('dotenv').config({ path: '.env.local' });

const supabaseUrl = process.env.NEXT_PUBLIC_SUPABASE_URL;
const supabaseKey = process.env.SUPABASE_SERVICE_ROLE_KEY;

if (!supabaseUrl || !supabaseKey) {
  console.error('Missing Supabase environment variables');
  process.exit(1);
}

const supabase = createClient(supabaseUrl, supabaseKey);

async function createCurrentUserMessages() {
  try {
    console.log('开始为当前用户创建测试消息...');

    // 获取所有用户
    const { data: users, error: usersError } = await supabase
      .from('users')
      .select('id, name, phone, role')
      .order('created_at', { ascending: false });

    if (usersError) {
      console.error('获取用户列表失败:', usersError);
      return;
    }

    console.log('找到的用户:');
    users?.forEach((user, index) => {
      console.log(`  ${index + 1}. ${user.name} (${user.role}) - ${user.id}`);
    });

    if (!users || users.length < 2) {
      console.log('需要至少2个用户才能创建对话');
      return;
    }

    // 选择前两个用户创建对话
    const user1 = users[0];
    const user2 = users[1];

    console.log(`\n创建 ${user1.name} 和 ${user2.name} 之间的对话...`);

    // 创建测试消息
    const testMessages = [
      {
        from_user_id: user1.id,
        to_user_id: user2.id,
        content: `你好 ${user2.name}，我想了解一下你的服务`,
        created_at: new Date(Date.now() - 2 * 60 * 60 * 1000).toISOString() // 2小时前
      },
      {
        from_user_id: user2.id,
        to_user_id: user1.id,
        content: `你好 ${user1.name}！很高兴为您服务，请问您需要什么帮助？`,
        created_at: new Date(Date.now() - 90 * 60 * 1000).toISOString() // 1.5小时前
      },
      {
        from_user_id: user1.id,
        to_user_id: user2.id,
        content: '我想了解一下价格和服务内容',
        created_at: new Date(Date.now() - 60 * 60 * 1000).toISOString() // 1小时前
      },
      {
        from_user_id: user2.id,
        to_user_id: user1.id,
        content: '我们有多种服务套餐，价格从150-300元/小时不等，具体可以根据您的需求定制',
        created_at: new Date(Date.now() - 30 * 60 * 1000).toISOString() // 30分钟前
      },
      {
        from_user_id: user1.id,
        to_user_id: user2.id,
        content: '听起来不错，我想预约明天的服务',
        created_at: new Date(Date.now() - 15 * 60 * 1000).toISOString() // 15分钟前
      },
      {
        from_user_id: user2.id,
        to_user_id: user1.id,
        content: '好的，明天我有空。请问您希望什么时间开始？',
        created_at: new Date(Date.now() - 5 * 60 * 1000).toISOString() // 5分钟前
      }
    ];

    // 如果有第三个用户，创建另一组对话
    if (users.length >= 3) {
      const user3 = users[2];
      console.log(`同时创建 ${user1.name} 和 ${user3.name} 之间的对话...`);

      const secondConversation = [
        {
          from_user_id: user1.id,
          to_user_id: user3.id,
          content: `${user3.name}，你好！听说你的服务很专业`,
          created_at: new Date(Date.now() - 4 * 60 * 60 * 1000).toISOString() // 4小时前
        },
        {
          from_user_id: user3.id,
          to_user_id: user1.id,
          content: `谢谢您的信任！我会尽力为您提供最好的服务`,
          created_at: new Date(Date.now() - 3 * 60 * 60 * 1000).toISOString() // 3小时前
        },
        {
          from_user_id: user1.id,
          to_user_id: user3.id,
          content: '我想了解一下你们的旅游套餐',
          created_at: new Date(Date.now() - 2.5 * 60 * 60 * 1000).toISOString() // 2.5小时前
        },
        {
          from_user_id: user3.id,
          to_user_id: user1.id,
          content: '我们有杭州一日游、西湖深度游等多种套餐，价格在2000-5000元之间',
          created_at: new Date(Date.now() - 2 * 60 * 60 * 1000).toISOString() // 2小时前
        }
      ];

      testMessages.push(...secondConversation);
    }

    // 插入所有消息
    for (const message of testMessages) {
      const { data, error } = await supabase
        .from('messages')
        .insert([message]);

      if (error) {
        console.error(`插入消息失败: ${message.content.substring(0, 20)}...`, error);
      } else {
        console.log(`✓ 消息插入成功: ${message.content.substring(0, 30)}...`);
      }
    }

    // 验证插入结果
    const { data: userMessages, error: selectError } = await supabase
      .from('messages')
      .select('id, content, created_at, from_user_id, to_user_id')
      .or(`from_user_id.eq.${user1.id},to_user_id.eq.${user1.id}`)
      .order('created_at', { ascending: true });

    if (selectError) {
      console.error('验证插入结果失败:', selectError);
    } else {
      console.log(`\n✅ ${user1.name} 相关的消息 (${userMessages?.length || 0} 条):`);
      userMessages?.forEach((msg, index) => {
        const isFromUser1 = msg.from_user_id === user1.id;
        const direction = isFromUser1 ? '发送' : '接收';
        console.log(`  ${index + 1}. [${direction}] ${msg.content.substring(0, 40)}...`);
      });
    }

    console.log('\n✅ 当前用户测试消息创建完成！');
    console.log('\n现在可以测试消息功能:');
    console.log('1. 访问 http://localhost:3001/test-login');
    console.log('2. 登录为不同用户');
    console.log('3. 访问 http://localhost:3001/messages 查看对话');

  } catch (error) {
    console.error('创建当前用户消息时发生错误:', error);
    process.exit(1);
  }
}

// 运行创建脚本
createCurrentUserMessages();
