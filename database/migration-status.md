# 订单系统Supabase迁移状态

## 🎯 迁移目标
将订单系统从内存数据库（Map）迁移到Supabase，支持人工收款流程。

## ✅ 已完成的迁移

### 1. 数据库表结构
- ✅ 创建了新的orders表结构 (`migrate-orders-table.sql`)
- ✅ 支持JSON格式的requirement字段
- ✅ 支持人工收款相关字段
- ✅ 完整的状态管理（11种状态）
- ✅ 流程时间戳跟踪
- ✅ 行级安全策略（RLS）

### 2. Supabase辅助函数
- ✅ 扩展了SupabaseHelper类
- ✅ 添加了订单CRUD操作方法
- ✅ 支持用户和地陪的订单查询

### 3. API迁移
- ✅ `/api/orders/create-draft/route.ts` - 创建草稿订单
- ✅ `/api/orders/[id]/route.ts` - 获取和更新订单
- ✅ `/api/orders/[id]/select-guide/route.ts` - 选择地陪
- ✅ `/api/orders/[id]/start/route.ts` - 开始服务
- ✅ `/api/orders/[id]/notes/route.ts` - 订单备注
- ✅ `/api/orders/route.ts` - 订单列表

## 🔄 需要继续的工作

### 1. 前端页面适配
需要更新前端页面以适配新的Supabase数据结构：

#### 字段映射
| 内存数据库字段 | Supabase字段 | 状态 |
|---------------|-------------|------|
| `userId` | `user_id` | ❌ 需要更新 |
| `guideId` | `guide_id` | ❌ 需要更新 |
| `createdAt` | `created_at` | ❌ 需要更新 |
| `updatedAt` | `updated_at` | ❌ 需要更新 |
| `depositAmount` | `deposit_amount` | ❌ 需要更新 |
| `totalAmount` | `total_amount` | ❌ 需要更新 |
| `finalAmount` | `final_amount` | ❌ 需要更新 |

#### 需要更新的页面
- `/booking/select-guide/[orderId]` - 选择地陪页面
- `/booking/payment-pending/[orderId]` - 等待收款页面
- `/booking/start/[orderId]` - 服务开始页面
- `/my-bookings` - 我的预约页面

### 2. 数据库执行
- ❌ 需要在Supabase中执行 `migrate-orders-table.sql`
- ❌ 需要验证表结构创建成功
- ❌ 需要测试RLS策略

### 3. 测试验证
- ❌ 测试订单创建流程
- ❌ 测试选择地陪流程
- ❌ 测试人工收款流程
- ❌ 测试订单状态更新

## 🚨 重要注意事项

### 数据结构变化
1. **requirement字段**：现在是JSONB类型，需要适配前端解析
2. **时间戳字段**：使用下划线命名（snake_case）
3. **ID关联**：guide_id现在关联guides表而不是users表

### 状态流程
人工收款模式下的状态流程：
```
DRAFT → GUIDE_SELECTED → PAYMENT_PENDING → PAID → IN_PROGRESS → COMPLETED
```

### API变化
- 所有API现在返回Supabase格式的数据
- 错误处理更加完善
- 支持更多的查询参数

## 📋 下一步行动计划

### 立即执行
1. **执行数据库迁移脚本**
   ```sql
   -- 在Supabase SQL编辑器中执行
   \i migrate-orders-table.sql
   ```

2. **更新前端字段映射**
   - 创建数据转换函数
   - 更新所有订单相关页面

3. **测试API功能**
   - 测试订单创建
   - 测试状态更新
   - 测试权限控制

### 后续优化
1. **性能优化**
   - 添加必要的数据库索引
   - 优化查询语句

2. **监控和日志**
   - 添加错误监控
   - 完善日志记录

3. **数据迁移**
   - 如果有现有数据，制定迁移计划
   - 备份和恢复策略

## 🔧 故障排除

### 常见问题
1. **字段不匹配**：检查snake_case vs camelCase
2. **权限错误**：验证RLS策略配置
3. **关联错误**：确认guide_id关联正确的表

### 调试工具
- Supabase Dashboard
- 浏览器开发者工具
- API测试工具（如Postman）

---

**迁移进度：60% 完成**
- ✅ 后端API迁移完成
- ❌ 前端适配待完成
- ❌ 数据库执行待完成
- ❌ 测试验证待完成
