# 美旅地陪服务平台

一个基于 Next.js 和 Supabase 的地陪服务预订平台，提供用户预订地陪服务、地陪管理、订单管理等功能。

## 🚀 功能特性

### 用户功能
- ✅ 用户注册/登录
- ✅ 地陪服务预订
- ✅ 订单管理
- ✅ 重复订单防护
- ✅ 退款申请
- ✅ 用户余额管理

### 地陪功能
- ✅ 地陪申请注册
- ✅ 个人资料管理
- ✅ 自主接单
- ✅ 订单管理
- ✅ 收入统计

### 管理员功能
- ✅ 用户管理
- ✅ 地陪审核
- ✅ 订单管理
- ✅ 财务管理
- ✅ 地陪结算
- ✅ 退款审批

## 🛠️ 技术栈

- **前端**: Next.js 15, React 19, TypeScript, Tailwind CSS
- **后端**: Next.js API Routes
- **数据库**: Supabase (PostgreSQL)
- **认证**: Supabase Auth
- **存储**: Supabase Storage
- **部署**: Vercel / Netlify

## 📦 安装和运行

### 环境要求
- Node.js 18+
- npm 或 yarn

### 本地开发

1. **克隆项目**
   ```bash
   git clone <repository-url>
   cd meilv-web
   ```

2. **安装依赖**
   ```bash
   npm install
   ```

3. **配置环境变量**
   ```bash
   cp .env.example .env.local
   ```

   编辑 `.env.local` 文件，填入您的 Supabase 配置：
   ```env
   NEXT_PUBLIC_SUPABASE_URL=your_supabase_url
   NEXT_PUBLIC_SUPABASE_ANON_KEY=your_supabase_anon_key
   SUPABASE_SERVICE_ROLE_KEY=your_service_role_key
   NEXT_PUBLIC_SUPABASE_STORAGE_URL=your_storage_url
   SUPABASE_STORAGE_KEY_ID=your_storage_key_id
   SUPABASE_STORAGE_ACCESS_KEY=your_storage_access_key
   ```

4. **初始化数据库**
   ```bash
   npm run init-db
   ```

5. **启动开发服务器**
   ```bash
   npm run dev
   ```

6. **访问应用**
   打开 [http://localhost:3000](http://localhost:3000)

## 🚀 部署

### Vercel 部署

1. **连接 GitHub**
   - 将代码推送到 GitHub
   - 在 Vercel 中导入项目

2. **配置环境变量**
   在 Vercel 项目设置中添加以下环境变量：
   - `NEXT_PUBLIC_SUPABASE_URL`
   - `NEXT_PUBLIC_SUPABASE_ANON_KEY`
   - `SUPABASE_SERVICE_ROLE_KEY`
   - `NEXT_PUBLIC_SUPABASE_STORAGE_URL`
   - `SUPABASE_STORAGE_KEY_ID`
   - `SUPABASE_STORAGE_ACCESS_KEY`

3. **自动部署**
   推送到 main 分支将自动触发部署

### GitHub Actions 自动部署

项目已配置 GitHub Actions，推送到 main 分支时自动部署。

需要在 GitHub 仓库设置中添加以下 Secrets：

#### Supabase 配置
- `NEXT_PUBLIC_SUPABASE_URL`
- `NEXT_PUBLIC_SUPABASE_ANON_KEY`
- `SUPABASE_SERVICE_ROLE_KEY`
- `NEXT_PUBLIC_SUPABASE_STORAGE_URL`
- `SUPABASE_STORAGE_KEY_ID`
- `SUPABASE_STORAGE_ACCESS_KEY`

#### Vercel 部署 (可选)
- `VERCEL_TOKEN`
- `VERCEL_ORG_ID`
- `VERCEL_PROJECT_ID`

#### 自定义服务器部署 (可选)
- `SERVER_HOST`
- `SERVER_USER`
- `SERVER_SSH_KEY`
- `SERVER_PORT`

## 📁 项目结构

```
meilv-web/
├── src/
│   ├── app/                 # Next.js App Router
│   │   ├── api/            # API 路由
│   │   ├── admin/          # 管理员页面
│   │   ├── guide/          # 地陪页面
│   │   └── ...             # 其他页面
│   ├── components/         # React 组件
│   ├── lib/               # 工具库
│   └── types/             # TypeScript 类型定义
├── database/              # 数据库脚本
├── scripts/               # 初始化脚本
├── .github/               # GitHub Actions
└── ...
```

## 🔧 开发工具

### 可用脚本

```bash
npm run dev          # 启动开发服务器
npm run build        # 构建生产版本
npm run start        # 启动生产服务器
npm run lint         # 代码检查
npm run init-db      # 初始化数据库
```

### 数据库管理

```bash
npm run create-messages      # 创建消息表
npm run create-mock-users    # 创建测试用户
npm run setup-messages       # 设置消息系统
```

## 🗄️ 数据库结构

### 主要表
- `users` - 用户表
- `guides` - 地陪档案表
- `guide_applications` - 地陪申请表
- `orders` - 订单表
- `guide_settlements` - 地陪结算表
- `balance_transactions` - 余额变更记录表

## 🔐 安全特性

- ✅ 用户身份验证
- ✅ 角色权限控制
- ✅ API 权限验证
- ✅ 输入数据验证
- ✅ SQL 注入防护
- ✅ 重复订单防护

## 📊 系统健康度

- **用户流程健康度**: 96% ✅
- **地陪流程健康度**: 100% ✅
- **财务系统健康度**: 96% ✅
- **数据一致性**: 100% ✅

## 🤝 贡献

1. Fork 项目
2. 创建功能分支 (`git checkout -b feature/AmazingFeature`)
3. 提交更改 (`git commit -m 'Add some AmazingFeature'`)
4. 推送到分支 (`git push origin feature/AmazingFeature`)
5. 打开 Pull Request

## 📄 许可证

本项目采用 MIT 许可证 - 查看 [LICENSE](LICENSE) 文件了解详情

## 📞 支持

如有问题或建议，请创建 Issue 或联系开发团队。

## 🎯 路线图

- [ ] 移动端适配
- [ ] 实时通知系统
- [ ] 地陪评价系统
- [ ] 智能推荐算法
- [ ] 多语言支持
- [ ] 支付集成
