-- 创建投诉系统表
-- 请在Supabase SQL编辑器中执行此脚本

-- 1. 创建投诉表
CREATE TABLE IF NOT EXISTS complaints (
    id UUID DEFAULT gen_random_uuid() PRIMARY KEY,
    
    -- 投诉相关方
    complainant_id UUID NOT NULL REFERENCES users(id) ON DELETE CASCADE, -- 投诉人
    respondent_id UUID NOT NULL REFERENCES users(id) ON DELETE CASCADE,  -- 被投诉人
    order_id UUID NOT NULL REFERENCES orders(id) ON DELETE CASCADE,      -- 关联订单
    
    -- 投诉内容
    category VARCHAR(50) NOT NULL CHECK (category IN (
        'service_quality',      -- 服务质量问题
        'attitude_problem',     -- 态度问题
        'safety_concern',       -- 安全问题
        'pricing_dispute',      -- 价格争议
        'no_show',             -- 爽约/未出现
        'inappropriate_behavior', -- 不当行为
        'other'                -- 其他
    )),
    title VARCHAR(200) NOT NULL,                    -- 投诉标题
    description TEXT NOT NULL,                      -- 投诉详情
    evidence_urls TEXT[],                           -- 证据文件URLs
    
    -- 状态管理
    status VARCHAR(20) DEFAULT 'pending' CHECK (status IN (
        'pending',      -- 待处理
        'investigating', -- 调查中
        'resolved',     -- 已解决
        'rejected',     -- 已驳回
        'closed'        -- 已关闭
    )),
    
    -- 优先级
    priority VARCHAR(20) DEFAULT 'normal' CHECK (priority IN (
        'low',          -- 低优先级
        'normal',       -- 普通
        'high',         -- 高优先级
        'urgent'        -- 紧急
    )),
    
    -- 管理员处理
    admin_id UUID REFERENCES users(id) ON DELETE SET NULL,  -- 处理管理员
    admin_notes TEXT,                                        -- 管理员备注
    resolution TEXT,                                         -- 处理结果
    
    -- 时间戳
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    resolved_at TIMESTAMP WITH TIME ZONE,
    
    -- 约束：同一订单的同一投诉人只能投诉一次
    UNIQUE(complainant_id, order_id)
);

-- 2. 创建投诉处理记录表（用于记录处理过程）
CREATE TABLE IF NOT EXISTS complaint_actions (
    id UUID DEFAULT gen_random_uuid() PRIMARY KEY,
    complaint_id UUID NOT NULL REFERENCES complaints(id) ON DELETE CASCADE,
    actor_id UUID NOT NULL REFERENCES users(id) ON DELETE CASCADE,  -- 操作人
    action_type VARCHAR(50) NOT NULL CHECK (action_type IN (
        'created',          -- 创建投诉
        'assigned',         -- 分配处理人
        'status_changed',   -- 状态变更
        'note_added',       -- 添加备注
        'evidence_added',   -- 添加证据
        'resolved',         -- 解决投诉
        'rejected',         -- 驳回投诉
        'closed'           -- 关闭投诉
    )),
    description TEXT,                                        -- 操作描述
    old_value TEXT,                                         -- 旧值
    new_value TEXT,                                         -- 新值
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- 3. 创建索引
CREATE INDEX IF NOT EXISTS idx_complaints_complainant ON complaints(complainant_id);
CREATE INDEX IF NOT EXISTS idx_complaints_respondent ON complaints(respondent_id);
CREATE INDEX IF NOT EXISTS idx_complaints_order ON complaints(order_id);
CREATE INDEX IF NOT EXISTS idx_complaints_status ON complaints(status);
CREATE INDEX IF NOT EXISTS idx_complaints_priority ON complaints(priority);
CREATE INDEX IF NOT EXISTS idx_complaints_admin ON complaints(admin_id);
CREATE INDEX IF NOT EXISTS idx_complaints_created_at ON complaints(created_at DESC);

CREATE INDEX IF NOT EXISTS idx_complaint_actions_complaint ON complaint_actions(complaint_id);
CREATE INDEX IF NOT EXISTS idx_complaint_actions_actor ON complaint_actions(actor_id);
CREATE INDEX IF NOT EXISTS idx_complaint_actions_created_at ON complaint_actions(created_at DESC);

-- 4. 启用行级安全性（RLS）
ALTER TABLE complaints ENABLE ROW LEVEL SECURITY;
ALTER TABLE complaint_actions ENABLE ROW LEVEL SECURITY;

-- 5. 创建RLS策略
-- 投诉人可以查看自己的投诉
CREATE POLICY "Users can view own complaints" ON complaints
    FOR SELECT USING (
        auth.uid()::text = complainant_id::text
    );

-- 被投诉人可以查看针对自己的投诉
CREATE POLICY "Users can view complaints against them" ON complaints
    FOR SELECT USING (
        auth.uid()::text = respondent_id::text
    );

-- 管理员可以查看所有投诉
CREATE POLICY "Admins can view all complaints" ON complaints
    FOR ALL USING (
        EXISTS (
            SELECT 1 FROM users 
            WHERE id::text = auth.uid()::text 
            AND role = 'admin'
        )
    );

-- 用户可以创建投诉
CREATE POLICY "Users can create complaints" ON complaints
    FOR INSERT WITH CHECK (
        auth.uid()::text = complainant_id::text
    );

-- 管理员可以更新投诉
CREATE POLICY "Admins can update complaints" ON complaints
    FOR UPDATE USING (
        EXISTS (
            SELECT 1 FROM users 
            WHERE id::text = auth.uid()::text 
            AND role = 'admin'
        )
    );

-- 投诉操作记录的RLS策略
CREATE POLICY "Users can view related complaint actions" ON complaint_actions
    FOR SELECT USING (
        EXISTS (
            SELECT 1 FROM complaints 
            WHERE id = complaint_actions.complaint_id 
            AND (complainant_id::text = auth.uid()::text 
                 OR respondent_id::text = auth.uid()::text)
        )
        OR EXISTS (
            SELECT 1 FROM users 
            WHERE id::text = auth.uid()::text 
            AND role = 'admin'
        )
    );

CREATE POLICY "Users can create complaint actions" ON complaint_actions
    FOR INSERT WITH CHECK (
        auth.uid()::text = actor_id::text
    );

-- 6. 创建触发器函数：自动更新 updated_at
CREATE OR REPLACE FUNCTION update_complaints_updated_at()
RETURNS TRIGGER AS $$
BEGIN
    NEW.updated_at = NOW();
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

-- 7. 创建触发器
CREATE TRIGGER trigger_update_complaints_updated_at
    BEFORE UPDATE ON complaints
    FOR EACH ROW
    EXECUTE FUNCTION update_complaints_updated_at();

-- 8. 创建自动记录操作的触发器函数
CREATE OR REPLACE FUNCTION log_complaint_action()
RETURNS TRIGGER AS $$
BEGIN
    IF TG_OP = 'INSERT' THEN
        INSERT INTO complaint_actions (complaint_id, actor_id, action_type, description)
        VALUES (NEW.id, NEW.complainant_id, 'created', '创建投诉');
        RETURN NEW;
    ELSIF TG_OP = 'UPDATE' THEN
        -- 记录状态变更
        IF OLD.status != NEW.status THEN
            INSERT INTO complaint_actions (complaint_id, actor_id, action_type, description, old_value, new_value)
            VALUES (NEW.id, COALESCE(NEW.admin_id, NEW.complainant_id), 'status_changed', 
                   '状态变更', OLD.status, NEW.status);
        END IF;
        
        -- 记录分配处理人
        IF OLD.admin_id IS DISTINCT FROM NEW.admin_id THEN
            INSERT INTO complaint_actions (complaint_id, actor_id, action_type, description, new_value)
            VALUES (NEW.id, COALESCE(NEW.admin_id, NEW.complainant_id), 'assigned', 
                   '分配处理人', NEW.admin_id::text);
        END IF;
        
        RETURN NEW;
    END IF;
    RETURN NULL;
END;
$$ LANGUAGE plpgsql;

-- 9. 创建操作记录触发器
CREATE TRIGGER trigger_log_complaint_action
    AFTER INSERT OR UPDATE ON complaints
    FOR EACH ROW
    EXECUTE FUNCTION log_complaint_action();

-- 完成提示
SELECT 'Complaints system tables created successfully!' as message;
