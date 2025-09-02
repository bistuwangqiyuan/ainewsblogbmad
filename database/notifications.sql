-- 通知表
CREATE TABLE IF NOT EXISTS notifications (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    user_id UUID REFERENCES profiles(id) ON DELETE CASCADE NOT NULL,
    type VARCHAR(50) NOT NULL CHECK (
        type IN ('system', 'comment', 'like', 'follow', 'mention')
    ),
    title TEXT NOT NULL,
    content TEXT,
    read BOOLEAN DEFAULT FALSE,
    data JSONB,
    -- 存储额外的通知数据，如帖子ID、用户ID等
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);
-- 通知设置表
CREATE TABLE IF NOT EXISTS notification_settings (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    user_id UUID REFERENCES profiles(id) ON DELETE CASCADE UNIQUE NOT NULL,
    email_enabled BOOLEAN DEFAULT TRUE,
    push_enabled BOOLEAN DEFAULT TRUE,
    system_enabled BOOLEAN DEFAULT TRUE,
    comment_enabled BOOLEAN DEFAULT TRUE,
    like_enabled BOOLEAN DEFAULT TRUE,
    follow_enabled BOOLEAN DEFAULT TRUE,
    mention_enabled BOOLEAN DEFAULT TRUE,
    frequency VARCHAR(20) DEFAULT 'immediate' CHECK (frequency IN ('immediate', 'hourly', 'daily')),
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);
-- 创建索引
CREATE INDEX IF NOT EXISTS idx_notifications_user_id ON notifications(user_id);
CREATE INDEX IF NOT EXISTS idx_notifications_type ON notifications(type);
CREATE INDEX IF NOT EXISTS idx_notifications_read ON notifications(read);
CREATE INDEX IF NOT EXISTS idx_notifications_created_at ON notifications(created_at DESC);
CREATE INDEX IF NOT EXISTS idx_notifications_user_read ON notifications(user_id, read);
-- 创建更新时间触发器
CREATE OR REPLACE FUNCTION update_updated_at_column() RETURNS TRIGGER AS $$ BEGIN NEW.updated_at = NOW();
RETURN NEW;
END;
$$ language 'plpgsql';
CREATE TRIGGER update_notifications_updated_at BEFORE
UPDATE ON notifications FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();
CREATE TRIGGER update_notification_settings_updated_at BEFORE
UPDATE ON notification_settings FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();
-- 创建通知函数
CREATE OR REPLACE FUNCTION create_notification(
        p_user_id UUID,
        p_type VARCHAR(50),
        p_title TEXT,
        p_content TEXT DEFAULT NULL,
        p_data JSONB DEFAULT NULL
    ) RETURNS UUID AS $$
DECLARE notification_id UUID;
BEGIN
INSERT INTO notifications (user_id, type, title, content, data)
VALUES (p_user_id, p_type, p_title, p_content, p_data)
RETURNING id INTO notification_id;
RETURN notification_id;
END;
$$ LANGUAGE plpgsql;
-- 创建批量标记已读函数
CREATE OR REPLACE FUNCTION mark_notifications_read(
        p_user_id UUID,
        p_notification_ids UUID [] DEFAULT NULL
    ) RETURNS INTEGER AS $$
DECLARE updated_count INTEGER;
BEGIN IF p_notification_ids IS NULL THEN -- 标记用户所有未读通知为已读
UPDATE notifications
SET read = TRUE,
    updated_at = NOW()
WHERE user_id = p_user_id
    AND read = FALSE;
GET DIAGNOSTICS updated_count = ROW_COUNT;
ELSE -- 标记指定通知为已读
UPDATE notifications
SET read = TRUE,
    updated_at = NOW()
WHERE user_id = p_user_id
    AND id = ANY(p_notification_ids);
GET DIAGNOSTICS updated_count = ROW_COUNT;
END IF;
RETURN updated_count;
END;
$$ LANGUAGE plpgsql;
-- 创建删除已读通知函数
CREATE OR REPLACE FUNCTION delete_read_notifications(
        p_user_id UUID,
        p_older_than_days INTEGER DEFAULT 30
    ) RETURNS INTEGER AS $$
DECLARE deleted_count INTEGER;
BEGIN
DELETE FROM notifications
WHERE user_id = p_user_id
    AND read = TRUE
    AND created_at < NOW() - INTERVAL '1 day' * p_older_than_days;
GET DIAGNOSTICS deleted_count = ROW_COUNT;
RETURN deleted_count;
END;
$$ LANGUAGE plpgsql;
-- 创建获取通知统计函数
CREATE OR REPLACE FUNCTION get_notification_stats(p_user_id UUID) RETURNS TABLE(
        total_count BIGINT,
        unread_count BIGINT,
        today_count BIGINT,
        system_count BIGINT,
        comment_count BIGINT,
        like_count BIGINT,
        follow_count BIGINT,
        mention_count BIGINT
    ) AS $$ BEGIN RETURN QUERY
SELECT COUNT(*)::BIGINT as total_count,
    COUNT(*) FILTER (
        WHERE read = FALSE
    )::BIGINT as unread_count,
    COUNT(*) FILTER (
        WHERE DATE(created_at) = CURRENT_DATE
    )::BIGINT as today_count,
    COUNT(*) FILTER (
        WHERE type = 'system'
    )::BIGINT as system_count,
    COUNT(*) FILTER (
        WHERE type = 'comment'
    )::BIGINT as comment_count,
    COUNT(*) FILTER (
        WHERE type = 'like'
    )::BIGINT as like_count,
    COUNT(*) FILTER (
        WHERE type = 'follow'
    )::BIGINT as follow_count,
    COUNT(*) FILTER (
        WHERE type = 'mention'
    )::BIGINT as mention_count
FROM notifications
WHERE user_id = p_user_id;
END;
$$ LANGUAGE plpgsql;
-- 插入示例数据
INSERT INTO notification_settings (
        user_id,
        email_enabled,
        push_enabled,
        system_enabled,
        comment_enabled,
        like_enabled,
        follow_enabled,
        mention_enabled,
        frequency
    )
SELECT id,
    TRUE,
    TRUE,
    TRUE,
    TRUE,
    TRUE,
    TRUE,
    TRUE,
    'immediate'
FROM profiles ON CONFLICT (user_id) DO NOTHING;
-- 插入示例通知（可选）
-- INSERT INTO notifications (user_id, type, title, content, data)
-- VALUES 
--     ('user-uuid-here', 'system', '欢迎使用通知系统', '您的通知系统已激活', '{"welcome": true}'),
--     ('user-uuid-here', 'comment', '新评论', '有人评论了您的帖子', '{"post_id": "post-uuid-here"}'),
--     ('user-uuid-here', 'like', '新点赞', '有人点赞了您的帖子', '{"post_id": "post-uuid-here"}');
-- 创建视图用于通知列表查询
CREATE OR REPLACE VIEW notification_list_view AS
SELECT n.id,
    n.user_id,
    n.type,
    n.title,
    n.content,
    n.read,
    n.data,
    n.created_at,
    n.updated_at,
    p.username as user_username,
    p.avatar_url as user_avatar_url
FROM notifications n
    LEFT JOIN profiles p ON n.user_id = p.id
ORDER BY n.created_at DESC;
-- 创建RLS策略
ALTER TABLE notifications ENABLE ROW LEVEL SECURITY;
ALTER TABLE notification_settings ENABLE ROW LEVEL SECURITY;
-- 通知表RLS策略
CREATE POLICY "Users can view their own notifications" ON notifications FOR
SELECT USING (auth.uid() = user_id);
CREATE POLICY "Users can update their own notifications" ON notifications FOR
UPDATE USING (auth.uid() = user_id);
CREATE POLICY "Users can delete their own notifications" ON notifications FOR DELETE USING (auth.uid() = user_id);
CREATE POLICY "System can insert notifications" ON notifications FOR
INSERT WITH CHECK (true);
-- 通知设置表RLS策略
CREATE POLICY "Users can view their own notification settings" ON notification_settings FOR
SELECT USING (auth.uid() = user_id);
CREATE POLICY "Users can update their own notification settings" ON notification_settings FOR
UPDATE USING (auth.uid() = user_id);
CREATE POLICY "Users can insert their own notification settings" ON notification_settings FOR
INSERT WITH CHECK (auth.uid() = user_id);
-- 创建通知触发器（当有新的点赞、评论等时自动创建通知）
CREATE OR REPLACE FUNCTION trigger_notification() RETURNS TRIGGER AS $$ BEGIN -- 根据不同的表触发不同类型的通知
    IF TG_TABLE_NAME = 'likes' THEN -- 点赞通知
    IF NEW.user_id != (
        SELECT author_id
        FROM posts
        WHERE id = NEW.post_id
    ) THEN PERFORM create_notification(
        (
            SELECT author_id
            FROM posts
            WHERE id = NEW.post_id
        ),
        'like',
        '新点赞',
        '有人点赞了您的帖子',
        jsonb_build_object('post_id', NEW.post_id, 'user_id', NEW.user_id)
    );
END IF;
ELSIF TG_TABLE_NAME = 'comments' THEN -- 评论通知
IF NEW.user_id != (
    SELECT author_id
    FROM posts
    WHERE id = NEW.post_id
) THEN PERFORM create_notification(
    (
        SELECT author_id
        FROM posts
        WHERE id = NEW.post_id
    ),
    'comment',
    '新评论',
    '有人评论了您的帖子',
    jsonb_build_object(
        'post_id',
        NEW.post_id,
        'user_id',
        NEW.user_id,
        'comment_id',
        NEW.id
    )
);
END IF;
ELSIF TG_TABLE_NAME = 'follows' THEN -- 关注通知
PERFORM create_notification(
    NEW.followed_id,
    'follow',
    '新关注',
    '有人关注了您',
    jsonb_build_object('user_id', NEW.follower_id)
);
END IF;
RETURN NEW;
END;
$$ LANGUAGE plpgsql;
-- 创建触发器（需要确保likes、comments、follows表存在）
-- CREATE TRIGGER trigger_like_notification
--     AFTER INSERT ON likes
--     FOR EACH ROW EXECUTE FUNCTION trigger_notification();
-- CREATE TRIGGER trigger_comment_notification
--     AFTER INSERT ON comments
--     FOR EACH ROW EXECUTE FUNCTION trigger_notification();
-- CREATE TRIGGER trigger_follow_notification
--     AFTER INSERT ON follows
--     FOR EACH ROW EXECUTE FUNCTION trigger_notification();