import { describe, it, expect } from 'vitest';
import fs from 'fs';
import path from 'path';

describe('Database Schema Validation', () => {
  describe('Schema File Structure', () => {
    it('should have schema.sql file with all required tables', () => {
      const schemaPath = path.join(process.cwd(), 'supabase', 'schema.sql');
      const schemaContent = fs.readFileSync(schemaPath, 'utf8');
      
      // 检查必需的表
      const requiredTables = [
        'profiles',
        'news_items', 
        'posts',
        'answers',
        'comments',
        'likes',
        'favorites',
        'reports',
        'views',
        'points_log',
        'messages',
        'notifications',
        'feedbacks',
        'sensitive_words',
        'crawler_logs'
      ];
      
      requiredTables.forEach(table => {
        expect(schemaContent).toContain(`create table if not exists public.${table}`);
      });
    });

    it('should have proper indexes for performance', () => {
      const schemaPath = path.join(process.cwd(), 'supabase', 'schema.sql');
      const schemaContent = fs.readFileSync(schemaPath, 'utf8');
      
      // 检查必需的索引
      const requiredIndexes = [
        'idx_news_items_published_at',
        'idx_news_items_source_date',
        'idx_posts_author',
        'idx_posts_created',
        'idx_posts_type_created',
        'idx_comments_entity',
        'idx_likes_user',
        'idx_favorites_user',
        'idx_views_entity',
        'idx_points_log_user',
        'idx_messages_users',
        'idx_notifications_user',
        'idx_feedbacks_user'
      ];
      
      requiredIndexes.forEach(index => {
        expect(schemaContent).toContain(`create index if not exists ${index}`);
      });
    });

    it('should have proper constraints and checks', () => {
      const schemaPath = path.join(process.cwd(), 'supabase', 'schema.sql');
      const schemaContent = fs.readFileSync(schemaPath, 'utf8');
      
      // 检查约束
      expect(schemaContent).toContain('check (type in (\'post\',\'question\'))');
      expect(schemaContent).toContain('check (entity_type in (\'news\',\'post\',\'answer\'))');
      expect(schemaContent).toContain('unique (entity_type, entity_id, user_id)');
      expect(schemaContent).toContain('hash text not null unique');
    });
  });

  describe('Policies File Structure', () => {
    it('should have policies.sql file with RLS enabled', () => {
      const policiesPath = path.join(process.cwd(), 'supabase', 'policies.sql');
      const policiesContent = fs.readFileSync(policiesPath, 'utf8');
      
      // 检查RLS启用
      expect(policiesContent).toContain('enable row level security');
      
      // 检查策略类型
      expect(policiesContent).toContain('create policy');
      expect(policiesContent).toContain('select using');
      expect(policiesContent).toContain('insert with check');
    });

    it('should have proper public read policies', () => {
      const policiesPath = path.join(process.cwd(), 'supabase', 'policies.sql');
      const policiesContent = fs.readFileSync(policiesPath, 'utf8');
      
      // 检查公共可读策略
      expect(policiesContent).toContain('profiles_read');
      expect(policiesContent).toContain('news_read');
      expect(policiesContent).toContain('posts_read');
      expect(policiesContent).toContain('comments_read');
      expect(policiesContent).toContain('likes_read');
      expect(policiesContent).toContain('favorites_read');
    });

    it('should have proper authenticated user policies', () => {
      const policiesPath = path.join(process.cwd(), 'supabase', 'policies.sql');
      const policiesContent = fs.readFileSync(policiesPath, 'utf8');
      
      // 检查认证用户策略
      expect(policiesContent).toContain('auth.role() = \'authenticated\'');
      expect(policiesContent).toContain('auth.uid() = author_id');
      expect(policiesContent).toContain('auth.uid() = user_id');
    });
  });

  describe('Functions File Structure', () => {
    it('should have functions.sql file with required functions', () => {
      const functionsPath = path.join(process.cwd(), 'supabase', 'functions.sql');
      const functionsContent = fs.readFileSync(functionsPath, 'utf8');
      
      // 检查必需函数
      expect(functionsContent).toContain('fn_check_sensitive');
      expect(functionsContent).toContain('fn_award_points');
      expect(functionsContent).toContain('fn_recalc_level');
      expect(functionsContent).toContain('fn_daily_login');
      expect(functionsContent).toContain('fn_increment_view');
    });

    it('should have proper triggers', () => {
      const functionsPath = path.join(process.cwd(), 'supabase', 'functions.sql');
      const functionsContent = fs.readFileSync(functionsPath, 'utf8');
      
      // 检查触发器
      expect(functionsContent).toContain('create trigger');
      expect(functionsContent).toContain('before_posts_sensitive');
      expect(functionsContent).toContain('after_posts_points');
      expect(functionsContent).toContain('after_comments_points');
      expect(functionsContent).toContain('after_likes_points');
      expect(functionsContent).toContain('after_favorites_points');
    });

    it('should have sensitive content filtering', () => {
      const functionsPath = path.join(process.cwd(), 'supabase', 'functions.sql');
      const functionsContent = fs.readFileSync(functionsPath, 'utf8');
      
      // 检查敏感词过滤
      expect(functionsContent).toContain('trg_block_sensitive');
      expect(functionsContent).toContain('内容包含敏感词，已被拒绝');
      expect(functionsContent).toContain('sensitive_words');
    });

    it('should have points and level management', () => {
      const functionsPath = path.join(process.cwd(), 'supabase', 'functions.sql');
      const functionsContent = fs.readFileSync(functionsPath, 'utf8');
      
      // 检查积分和等级管理
      expect(functionsContent).toContain('points_log');
      expect(functionsContent).toContain('level');
      expect(functionsContent).toContain('create_post');
      expect(functionsContent).toContain('create_comment');
      expect(functionsContent).toContain('got_liked');
      expect(functionsContent).toContain('favorite');
    });
  });

  describe('Test Data File Structure', () => {
    it('should have test-data.sql file with sample data', () => {
      const testDataPath = path.join(process.cwd(), 'supabase', 'test-data.sql');
      const testDataContent = fs.readFileSync(testDataPath, 'utf8');
      
      // 检查测试数据
      expect(testDataContent).toContain('INSERT INTO public.profiles');
      expect(testDataContent).toContain('INSERT INTO public.posts');
      expect(testDataContent).toContain('ON CONFLICT (id) DO NOTHING');
    });

    it('should have proper test user data', () => {
      const testDataPath = path.join(process.cwd(), 'supabase', 'test-data.sql');
      const testDataContent = fs.readFileSync(testDataPath, 'utf8');
      
      // 检查测试用户
      expect(testDataContent).toContain('testuser1');
      expect(testDataContent).toContain('testuser2');
      expect(testDataContent).toContain('testuser3');
    });

    it('should have proper test post data', () => {
      const testDataPath = path.join(process.cwd(), 'supabase', 'test-data.sql');
      const testDataContent = fs.readFileSync(testDataPath, 'utf8');
      
      // 检查测试帖子
      expect(testDataContent).toContain('post');
      expect(testDataContent).toContain('question');
      expect(testDataContent).toContain('Astro框架入门指南');
      expect(testDataContent).toContain('如何解决TypeScript类型错误？');
    });
  });

  describe('Database Design Compliance', () => {
    it('should follow naming conventions', () => {
      const schemaPath = path.join(process.cwd(), 'supabase', 'schema.sql');
      const schemaContent = fs.readFileSync(schemaPath, 'utf8');
      
      // 检查命名规范
      expect(schemaContent).toContain('created_at'); // 必需字段
      expect(schemaContent).toContain('updated_at'); // 更新字段
      expect(schemaContent).toContain('timestamptz'); // 时间字段
      expect(schemaContent).toContain('uuid'); // 主键类型
    });

    it('should have proper data types', () => {
      const schemaPath = path.join(process.cwd(), 'supabase', 'schema.sql');
      const schemaContent = fs.readFileSync(schemaPath, 'utf8');
      
      // 检查数据类型
      expect(schemaContent).toContain('text'); // 文本字段
      expect(schemaContent).toContain('integer'); // 数字字段
      expect(schemaContent).toContain('boolean'); // 布尔字段
      expect(schemaContent).toContain('jsonb'); // JSON字段
      expect(schemaContent).toContain('text[]'); // 数组字段
    });

    it('should have proper foreign key relationships', () => {
      const schemaPath = path.join(process.cwd(), 'supabase', 'schema.sql');
      const schemaContent = fs.readFileSync(schemaPath, 'utf8');
      
      // 检查外键关系
      expect(schemaContent).toContain('references public.posts(id)');
      expect(schemaContent).toContain('author_id uuid not null');
      expect(schemaContent).toContain('user_id uuid not null');
      expect(schemaContent).toContain('question_id uuid not null');
    });
  });
});
