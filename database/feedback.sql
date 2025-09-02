-- 反馈表
CREATE TABLE IF NOT EXISTS feedback (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    user_id UUID REFERENCES profiles(id) ON DELETE CASCADE NOT NULL,
    type VARCHAR(50) NOT NULL CHECK (
        type IN ('bug', 'feature', 'suggestion', 'other')
    ),
    title VARCHAR(200) NOT NULL,
    content TEXT NOT NULL,
    contact TEXT,
    -- 用户联系方式
    attachments TEXT [],
    -- 附件文件URL数组
    status VARCHAR(20) DEFAULT 'pending' CHECK (
        status IN ('pending', 'processing', 'resolved', 'rejected')
    ),
    admin_reply TEXT,
    -- 管理员回复
    admin_id UUID REFERENCES profiles(id),
    -- 处理反馈的管理员
    priority VARCHAR(20) DEFAULT 'medium' CHECK (priority IN ('low', 'medium', 'high', 'urgent')),
    tags TEXT [],
    -- 标签数组
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);
-- 创建索引
CREATE INDEX IF NOT EXISTS idx_feedback_user_id ON feedback(user_id);
CREATE INDEX IF NOT EXISTS idx_feedback_type ON feedback(type);
CREATE INDEX IF NOT EXISTS idx_feedback_status ON feedback(status);
CREATE INDEX IF NOT EXISTS idx_feedback_priority ON feedback(priority);
CREATE INDEX IF NOT EXISTS idx_feedback_created_at ON feedback(created_at DESC);
CREATE INDEX IF NOT EXISTS idx_feedback_user_status ON feedback(user_id, status);
-- 创建更新时间触发器
CREATE OR REPLACE FUNCTION update_updated_at_column() RETURNS TRIGGER AS $$ BEGIN NEW.updated_at = NOW();
RETURN NEW;
END;
$$ language 'plpgsql';
CREATE TRIGGER update_feedback_updated_at BEFORE
UPDATE ON feedback FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();
-- 创建反馈函数
CREATE OR REPLACE FUNCTION create_feedback(
        p_user_id UUID,
        p_type VARCHAR(50),
        p_title VARCHAR(200),
        p_content TEXT,
        p_contact TEXT DEFAULT NULL,
        p_attachments TEXT [] DEFAULT NULL
    ) RETURNS UUID AS $$
DECLARE feedback_id UUID;
BEGIN
INSERT INTO feedback (
        user_id,
        type,
        title,
        content,
        contact,
        attachments
    )
VALUES (
        p_user_id,
        p_type,
        p_title,
        p_content,
        p_contact,
        p_attachments
    )
RETURNING id INTO feedback_id;
RETURN feedback_id;
END;
$$ LANGUAGE plpgsql;
-- 创建更新反馈状态函数
CREATE OR REPLACE FUNCTION update_feedback_status(
        p_feedback_id UUID,
        p_status VARCHAR(20),
        p_admin_id UUID DEFAULT NULL,
        p_reply TEXT DEFAULT NULL
    ) RETURNS BOOLEAN AS $$ BEGIN
UPDATE feedback
SET status = p_status,
    admin_id = p_admin_id,
    admin_reply = p_reply,
    updated_at = NOW()
WHERE id = p_feedback_id;
RETURN FOUND;
END;
$$ LANGUAGE plpgsql;
-- 创建获取反馈统计函数
CREATE OR REPLACE FUNCTION get_feedback_stats(p_user_id UUID DEFAULT NULL) RETURNS TABLE(
        total_count BIGINT,
        pending_count BIGINT,
        processing_count BIGINT,
        resolved_count BIGINT,
        rejected_count BIGINT,
        bug_count BIGINT,
        feature_count BIGINT,
        suggestion_count BIGINT,
        other_count BIGINT
    ) AS $$ BEGIN RETURN QUERY
SELECT COUNT(*)::BIGINT as total_count,
    COUNT(*) FILTER (
        WHERE status = 'pending'
    )::BIGINT as pending_count,
    COUNT(*) FILTER (
        WHERE status = 'processing'
    )::BIGINT as processing_count,
    COUNT(*) FILTER (
        WHERE status = 'resolved'
    )::BIGINT as resolved_count,
    COUNT(*) FILTER (
        WHERE status = 'rejected'
    )::BIGINT as rejected_count,
    COUNT(*) FILTER (
        WHERE type = 'bug'
    )::BIGINT as bug_count,
    COUNT(*) FILTER (
        WHERE type = 'feature'
    )::BIGINT as feature_count,
    COUNT(*) FILTER (
        WHERE type = 'suggestion'
    )::BIGINT as suggestion_count,
    COUNT(*) FILTER (
        WHERE type = 'other'
    )::BIGINT as other_count
FROM feedback
WHERE (
        p_user_id IS NULL
        OR user_id = p_user_id
    );
END;
$$ LANGUAGE plpgsql;
-- 创建搜索反馈函数
CREATE OR REPLACE FUNCTION search_feedback(
        p_user_id UUID DEFAULT NULL,
        p_search_query TEXT DEFAULT NULL,
        p_type_filter VARCHAR(50) DEFAULT NULL,
        p_status_filter VARCHAR(20) DEFAULT NULL,
        p_limit INTEGER DEFAULT 20,
        p_offset INTEGER DEFAULT 0
    ) RETURNS TABLE(
        id UUID,
        user_id UUID,
        type VARCHAR(50),
        title VARCHAR(200),
        content TEXT,
        status VARCHAR(20),
        priority VARCHAR(20),
        created_at TIMESTAMP WITH TIME ZONE,
        updated_at TIMESTAMP WITH TIME ZONE,
        username TEXT,
        avatar_url TEXT
    ) AS $$ BEGIN RETURN QUERY
SELECT f.id,
    f.user_id,
    f.type,
    f.title,
    f.content,
    f.status,
    f.priority,
    f.created_at,
    f.updated_at,
    p.username,
    p.avatar_url
FROM feedback f
    LEFT JOIN profiles p ON f.user_id = p.id
WHERE (
        p_user_id IS NULL
        OR f.user_id = p_user_id
    )
    AND (
        p_search_query IS NULL
        OR f.title ILIKE '%' || p_search_query || '%'
        OR f.content ILIKE '%' || p_search_query || '%'
    )
    AND (
        p_type_filter IS NULL
        OR f.type = p_type_filter
    )
    AND (
        p_status_filter IS NULL
        OR f.status = p_status_filter
    )
ORDER BY f.created_at DESC
LIMIT p_limit OFFSET p_offset;
END;
$$ LANGUAGE plpgsql;
-- 创建反馈标签表
CREATE TABLE IF NOT EXISTS feedback_tags (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    name VARCHAR(50) UNIQUE NOT NULL,
    color VARCHAR(7) DEFAULT '#3B82F6',
    -- 十六进制颜色值
    description TEXT,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);
-- 创建反馈标签关联表
CREATE TABLE IF NOT EXISTS feedback_tag_relations (
    feedback_id UUID REFERENCES feedback(id) ON DELETE CASCADE,
    tag_id UUID REFERENCES feedback_tags(id) ON DELETE CASCADE,
    PRIMARY KEY (feedback_id, tag_id)
);
-- 插入默认标签
INSERT INTO feedback_tags (name, color, description)
VALUES ('UI/UX', '#EF4444', '用户界面和用户体验相关'),
    ('性能', '#F59E0B', '性能优化相关'),
    ('安全', '#10B981', '安全性相关'),
    ('功能', '#3B82F6', '新功能建议'),
    ('Bug', '#8B5CF6', 'Bug修复'),
    ('文档', '#6B7280', '文档相关'),
    ('移动端', '#EC4899', '移动端相关'),
    ('桌面端', '#84CC16', '桌面端相关') ON CONFLICT (name) DO NOTHING;
-- 创建反馈优先级自动设置函数
CREATE OR REPLACE FUNCTION set_feedback_priority() RETURNS TRIGGER AS $$ BEGIN -- 根据反馈类型自动设置优先级
    IF NEW.type = 'bug' THEN NEW.priority = 'high';
ELSIF NEW.type = 'feature' THEN NEW.priority = 'medium';
ELSIF NEW.type = 'suggestion' THEN NEW.priority = 'low';
ELSE NEW.priority = 'medium';
END IF;
RETURN NEW;
END;
$$ LANGUAGE plpgsql;
CREATE TRIGGER trigger_set_feedback_priority BEFORE
INSERT ON feedback FOR EACH ROW EXECUTE FUNCTION set_feedback_priority();
-- 创建反馈通知函数
CREATE OR REPLACE FUNCTION notify_feedback_submission() RETURNS TRIGGER AS $$ BEGIN -- 当有新反馈提交时，可以发送通知给管理员
    -- 这里可以集成通知系统
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;
CREATE TRIGGER trigger_notify_feedback_submission
AFTER
INSERT ON feedback FOR EACH ROW EXECUTE FUNCTION notify_feedback_submission();
-- 创建视图用于反馈列表查询
CREATE OR REPLACE VIEW feedback_list_view AS
SELECT f.id,
    f.user_id,
    f.type,
    f.title,
    f.content,
    f.contact,
    f.attachments,
    f.status,
    f.priority,
    f.admin_reply,
    f.admin_id,
    f.tags,
    f.created_at,
    f.updated_at,
    p.username as user_username,
    p.avatar_url as user_avatar_url,
    admin.username as admin_username,
    admin.avatar_url as admin_avatar_url
FROM feedback f
    LEFT JOIN profiles p ON f.user_id = p.id
    LEFT JOIN profiles admin ON f.admin_id = admin.id
ORDER BY f.created_at DESC;
-- 创建RLS策略
ALTER TABLE feedback ENABLE ROW LEVEL SECURITY;
ALTER TABLE feedback_tags ENABLE ROW LEVEL SECURITY;
ALTER TABLE feedback_tag_relations ENABLE ROW LEVEL SECURITY;
-- 反馈表RLS策略
CREATE POLICY "Users can view their own feedback" ON feedback FOR
SELECT USING (auth.uid() = user_id);
CREATE POLICY "Users can insert their own feedback" ON feedback FOR
INSERT WITH CHECK (auth.uid() = user_id);
CREATE POLICY "Users can update their own feedback" ON feedback FOR
UPDATE USING (auth.uid() = user_id);
CREATE POLICY "Admins can view all feedback" ON feedback FOR
SELECT USING (
        EXISTS (
            SELECT 1
            FROM profiles
            WHERE id = auth.uid()
                AND role = 'admin'
        )
    );
CREATE POLICY "Admins can update all feedback" ON feedback FOR
UPDATE USING (
        EXISTS (
            SELECT 1
            FROM profiles
            WHERE id = auth.uid()
                AND role = 'admin'
        )
    );
-- 标签表RLS策略
CREATE POLICY "Everyone can view feedback tags" ON feedback_tags FOR
SELECT USING (true);
CREATE POLICY "Admins can manage feedback tags" ON feedback_tags FOR ALL USING (
    EXISTS (
        SELECT 1
        FROM profiles
        WHERE id = auth.uid()
            AND role = 'admin'
    )
);
-- 标签关联表RLS策略
CREATE POLICY "Users can view feedback tag relations" ON feedback_tag_relations FOR
SELECT USING (true);
CREATE POLICY "Admins can manage feedback tag relations" ON feedback_tag_relations FOR ALL USING (
    EXISTS (
        SELECT 1
        FROM profiles
        WHERE id = auth.uid()
            AND role = 'admin'
    )
);
-- 插入示例数据（可选）
-- INSERT INTO feedback (user_id, type, title, content, contact, status, priority)
-- VALUES 
--     ('user-uuid-here', 'bug', '登录页面无法访问', '点击登录按钮后页面无响应', 'user@example.com', 'pending', 'high'),
--     ('user-uuid-here', 'feature', '添加深色模式', '建议添加深色模式选项', 'user@example.com', 'processing', 'medium'),
--     ('user-uuid-here', 'suggestion', '优化搜索功能', '建议在搜索结果中添加高亮显示', 'user@example.com', 'resolved', 'low');
-- 创建反馈统计视图
CREATE OR REPLACE VIEW feedback_stats_view AS
SELECT DATE(created_at) as date,
    type,
    status,
    priority,
    COUNT(*) as count
FROM feedback
GROUP BY DATE(created_at),
    type,
    status,
    priority
ORDER BY date DESC;
-- 创建反馈趋势视图
CREATE OR REPLACE VIEW feedback_trend_view AS
SELECT DATE_TRUNC('week', created_at) as week,
    type,
    COUNT(*) as count
FROM feedback
GROUP BY DATE_TRUNC('week', created_at),
    type
ORDER BY week DESC;