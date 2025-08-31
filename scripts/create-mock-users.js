const { createClient } = require('@supabase/supabase-js');
require('dotenv').config({ path: '.env.local' });

const supabaseUrl = process.env.NEXT_PUBLIC_SUPABASE_URL;
const supabaseKey = process.env.SUPABASE_SERVICE_ROLE_KEY;

if (!supabaseUrl || !supabaseKey) {
  console.error('Missing Supabase environment variables');
  process.exit(1);
}

const supabase = createClient(supabaseUrl, supabaseKey);

async function createMockUsers() {
  try {
    console.log('开始创建模拟用户...');

    // 生成正确的 UUID
    function generateUUID() {
      return crypto.randomUUID();
    }

    // 创建与模拟数据库对应的用户，但使用正确的 UUID
    const user001Id = generateUUID();
    const guide001Id = generateUUID();
    const guide002Id = generateUUID();
    const guide003Id = generateUUID();
    const admin001Id = generateUUID();

    const mockUsers = [
      {
        id: user001Id,
        phone: '13800000000',
        name: '测试用户',
        role: 'user',
        created_at: new Date().toISOString(),
        updated_at: new Date().toISOString()
      },
      {
        id: guide001Id,
        phone: '13900000001',
        name: '地陪A',
        role: 'guide',
        created_at: new Date().toISOString(),
        updated_at: new Date().toISOString()
      },
      {
        id: guide002Id,
        phone: '13700000000',
        name: '地陪B',
        role: 'guide',
        created_at: new Date().toISOString(),
        updated_at: new Date().toISOString()
      },
      {
        id: guide003Id,
        phone: '13600000000',
        name: '地陪C',
        role: 'guide',
        created_at: new Date().toISOString(),
        updated_at: new Date().toISOString()
      },
      {
        id: admin001Id,
        phone: '13900000000',
        name: '管理员',
        role: 'admin',
        created_at: new Date().toISOString(),
        updated_at: new Date().toISOString()
      }
    ];

    // 插入用户数据
    for (const user of mockUsers) {
      const { data, error } = await supabase
        .from('users')
        .upsert(user, { onConflict: 'id' });
      
      if (error) {
        console.error(`创建用户 ${user.name} 失败:`, error);
      } else {
        console.log(`✓ 用户 ${user.name} (${user.id}) 创建成功`);
      }
    }

    // 创建对应的地陪档案
    const mockGuides = [
      {
        id: generateUUID(),
        user_id: guide001Id,
        display_name: '地陪A',
        bio: '经验丰富的杭州地陪，熟悉各种旅游路线',
        skills: ['杭州导游', '美食推荐'],
        hourly_rate: 200,
        city: '杭州',
        location: '西湖区',
        photos: [],
        services: [
          { code: 'daily', title: '日常陪伴', pricePerHour: 200 },
          { code: 'mild_entertainment', title: '微醺娱乐', pricePerHour: 300 },
          { code: 'local_tour', title: '同城旅游', packagePrice: 3000 }
        ],
        verification_status: 'verified',
        rating_avg: 4.8,
        rating_count: 50,
        created_at: new Date().toISOString(),
        updated_at: new Date().toISOString()
      },
      {
        id: generateUUID(),
        user_id: guide002Id,
        display_name: '地陪B',
        bio: '新手地陪，热情服务',
        skills: ['本地文化'],
        hourly_rate: 150,
        city: '杭州',
        location: '拱墅区',
        photos: [],
        services: [
          { code: 'daily', title: '日常陪伴', pricePerHour: 150 }
        ],
        verification_status: 'pending',
        rating_avg: 0,
        rating_count: 0,
        created_at: new Date().toISOString(),
        updated_at: new Date().toISOString()
      },
      {
        id: generateUUID(),
        user_id: guide003Id,
        display_name: '地陪C',
        bio: '申请被拒绝的地陪',
        skills: [],
        hourly_rate: 180,
        city: '杭州',
        location: '余杭区',
        photos: [],
        services: [],
        verification_status: 'rejected',
        rating_avg: 0,
        rating_count: 0,
        created_at: new Date().toISOString(),
        updated_at: new Date().toISOString()
      }
    ];

    // 保存用户ID映射，以便后续使用
    console.log('用户ID映射:');
    console.log(`user001 -> ${user001Id}`);
    console.log(`guide001 -> ${guide001Id}`);
    console.log(`guide002 -> ${guide002Id}`);
    console.log(`guide003 -> ${guide003Id}`);
    console.log(`admin001 -> ${admin001Id}`);

    // 插入地陪档案数据
    for (const guide of mockGuides) {
      const { data, error } = await supabase
        .from('guides')
        .upsert(guide, { onConflict: 'id' });
      
      if (error) {
        console.error(`创建地陪档案 ${guide.display_name} 失败:`, error);
      } else {
        console.log(`✓ 地陪档案 ${guide.display_name} 创建成功`);
      }
    }

    console.log('✅ 模拟用户和地陪档案创建完成！');

  } catch (error) {
    console.error('创建模拟用户时发生错误:', error);
    process.exit(1);
  }
}

// 运行创建脚本
createMockUsers();
