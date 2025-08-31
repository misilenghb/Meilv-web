require('dotenv').config({ path: '.env.local' });
const { createClient } = require('@supabase/supabase-js');

const supabaseUrl = process.env.NEXT_PUBLIC_SUPABASE_URL;
const supabaseKey = process.env.SUPABASE_SERVICE_ROLE_KEY;

if (!supabaseUrl || !supabaseKey) {
  console.error('Missing Supabase environment variables');
  process.exit(1);
}

const supabase = createClient(supabaseUrl, supabaseKey);

async function createCrossRoleMessages() {
  try {
    console.log('开始创建跨角色消息测试数据...');

    // 获取所有用户，按角色分组
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

    if (!users || users.length < 3) {
      console.log('需要至少3个不同角色的用户才能创建跨角色对话');
      return;
    }

    // 按角色分组用户
    const usersByRole = {
      user: users.filter(u => u.role === 'user'),
      guide: users.filter(u => u.role === 'guide'),
      admin: users.filter(u => u.role === 'admin')
    };

    console.log('\n用户角色分布:');
    console.log(`- 普通用户: ${usersByRole.user.length}个`);
    console.log(`- 地陪: ${usersByRole.guide.length}个`);
    console.log(`- 管理员: ${usersByRole.admin.length}个`);

    const messages = [];

    // 1. 用户与地陪的对话
    if (usersByRole.user.length > 0 && usersByRole.guide.length > 0) {
      const user = usersByRole.user[0];
      const guide = usersByRole.guide[0];
      
      console.log(`\n创建 ${user.name}(用户) 和 ${guide.name}(地陪) 之间的对话...`);
      
      messages.push(
        {
          from_user_id: user.id,
          to_user_id: guide.id,
          content: '你好，我想咨询一下你的地陪服务',
          created_at: new Date(Date.now() - 60 * 60 * 1000).toISOString() // 1小时前
        },
        {
          from_user_id: guide.id,
          to_user_id: user.id,
          content: '您好！很高兴为您服务，请问您需要什么类型的陪伴服务？',
          created_at: new Date(Date.now() - 55 * 60 * 1000).toISOString() // 55分钟前
        },
        {
          from_user_id: user.id,
          to_user_id: guide.id,
          content: '我想要一个半天的城市观光服务，大概需要多少费用？',
          created_at: new Date(Date.now() - 50 * 60 * 1000).toISOString() // 50分钟前
        },
        {
          from_user_id: guide.id,
          to_user_id: user.id,
          content: '半天城市观光服务是300元，包含景点讲解和拍照服务，您觉得怎么样？',
          created_at: new Date(Date.now() - 45 * 60 * 1000).toISOString() // 45分钟前
        }
      );
    }

    // 2. 管理员与地陪的对话
    if (usersByRole.admin.length > 0 && usersByRole.guide.length > 0) {
      const admin = usersByRole.admin[0];
      const guide = usersByRole.guide[0];
      
      console.log(`创建 ${admin.name}(管理员) 和 ${guide.name}(地陪) 之间的对话...`);
      
      messages.push(
        {
          from_user_id: admin.id,
          to_user_id: guide.id,
          content: '您好，我是平台管理员，需要和您确认一下最近的服务质量反馈',
          created_at: new Date(Date.now() - 40 * 60 * 1000).toISOString() // 40分钟前
        },
        {
          from_user_id: guide.id,
          to_user_id: admin.id,
          content: '管理员您好！我一直在努力提供优质服务，请问有什么需要改进的地方吗？',
          created_at: new Date(Date.now() - 35 * 60 * 1000).toISOString() // 35分钟前
        },
        {
          from_user_id: admin.id,
          to_user_id: guide.id,
          content: '整体反馈很好，客户对您的服务很满意。请继续保持！',
          created_at: new Date(Date.now() - 30 * 60 * 1000).toISOString() // 30分钟前
        }
      );
    }

    // 3. 管理员与用户的对话
    if (usersByRole.admin.length > 0 && usersByRole.user.length > 0) {
      const admin = usersByRole.admin[0];
      const user = usersByRole.user[0];
      
      console.log(`创建 ${admin.name}(管理员) 和 ${user.name}(用户) 之间的对话...`);
      
      messages.push(
        {
          from_user_id: user.id,
          to_user_id: admin.id,
          content: '您好，我想投诉一个地陪的服务问题',
          created_at: new Date(Date.now() - 25 * 60 * 1000).toISOString() // 25分钟前
        },
        {
          from_user_id: admin.id,
          to_user_id: user.id,
          content: '您好，我是平台管理员，很抱歉听到您的不愉快经历。请详细说明问题，我们会认真处理。',
          created_at: new Date(Date.now() - 20 * 60 * 1000).toISOString() // 20分钟前
        },
        {
          from_user_id: user.id,
          to_user_id: admin.id,
          content: '地陪迟到了30分钟，而且态度不太好。希望平台能够改进管理。',
          created_at: new Date(Date.now() - 15 * 60 * 1000).toISOString() // 15分钟前
        },
        {
          from_user_id: admin.id,
          to_user_id: user.id,
          content: '非常感谢您的反馈，我们会立即调查此事并对相关地陪进行培训。作为补偿，我们将为您提供下次服务的优惠。',
          created_at: new Date(Date.now() - 10 * 60 * 1000).toISOString() // 10分钟前
        }
      );
    }

    // 4. 如果有多个地陪，创建地陪之间的对话
    if (usersByRole.guide.length >= 2) {
      const guide1 = usersByRole.guide[0];
      const guide2 = usersByRole.guide[1];
      
      console.log(`创建 ${guide1.name}(地陪) 和 ${guide2.name}(地陪) 之间的对话...`);
      
      messages.push(
        {
          from_user_id: guide1.id,
          to_user_id: guide2.id,
          content: '你好同行，想请教一下你是怎么处理客户的特殊要求的？',
          created_at: new Date(Date.now() - 8 * 60 * 1000).toISOString() // 8分钟前
        },
        {
          from_user_id: guide2.id,
          to_user_id: guide1.id,
          content: '你好！我通常会先了解客户的具体需求，然后制定个性化的服务方案。',
          created_at: new Date(Date.now() - 5 * 60 * 1000).toISOString() // 5分钟前
        }
      );
    }

    // 批量插入消息
    if (messages.length > 0) {
      console.log(`\n开始插入 ${messages.length} 条跨角色消息...`);
      
      for (const message of messages) {
        const { error } = await supabase
          .from('messages')
          .insert([message]);
        
        if (error) {
          console.error('消息插入失败:', error);
        } else {
          console.log(`✓ 消息插入成功: ${message.content.substring(0, 30)}...`);
        }
      }
    }

    console.log('\n✅ 跨角色消息测试数据创建完成！');
    console.log('\n现在可以测试不同角色间的消息互通功能:');
    console.log('1. 访问 http://localhost:3001/test-login');
    console.log('2. 登录为不同角色的用户');
    console.log('3. 访问 http://localhost:3001/messages 查看对话');
    console.log('4. 访问 http://localhost:3001/messages/new 开始新对话');

  } catch (error) {
    console.error('创建跨角色消息失败:', error);
  }
}

createCrossRoleMessages();
