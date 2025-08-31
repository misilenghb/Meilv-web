const { createClient } = require('@supabase/supabase-js');

const supabaseUrl = 'https://fauzguzoamyahhcqhvoc.supabase.co';
const supabaseKey = 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6ImZhdXpndXpvYW15YWhoY3Fodm9jIiwicm9sZSI6InNlcnZpY2Vfcm9sZSIsImlhdCI6MTc1NjM2MTIyOCwiZXhwIjoyMDcxOTM3MjI4fQ.EVv6O37QEeY6ZshOVVHxOVK3NlNwFb1nQBNgroPxuKU';

const supabase = createClient(supabaseUrl, supabaseKey);

async function updateOrderStatus() {
  try {
    const orderId = '8e48d536-8cf2-4797-8482-63dff3699a9a';
    
    console.log('正在更新订单状态...');
    
    // 更新订单状态为 DEPOSIT_PENDING
    const { data, error } = await supabase
      .from('orders')
      .update({ 
        status: 'DEPOSIT_PENDING',
        updated_at: new Date().toISOString()
      })
      .eq('id', orderId)
      .select();

    if (error) {
      console.error('更新错误:', error);
      return;
    }

    console.log('订单状态更新成功:', data);

    // 验证更新结果
    const { data: updatedOrder, error: fetchError } = await supabase
      .from('orders')
      .select('*')
      .eq('id', orderId)
      .single();

    if (fetchError) {
      console.error('验证查询错误:', fetchError);
    } else {
      console.log('更新后的订单状态:', updatedOrder.status);
    }

  } catch (error) {
    console.error('脚本执行错误:', error);
  }
}

updateOrderStatus();
