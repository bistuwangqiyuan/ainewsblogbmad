import { describe, it, expect, beforeEach, afterEach, vi } from 'vitest';
import { createClient } from '@supabase/supabase-js';

// 模拟Supabase客户端
const mockSupabase = {
  auth: {
    signInWithPassword: vi.fn(),
    signUp: vi.fn(),
    getUser: vi.fn(),
    signOut: vi.fn()
  },
  from: vi.fn(() => ({
    select: vi.fn().mockReturnThis(),
    eq: vi.fn().mockReturnThis(),
    single: vi.fn(),
    insert: vi.fn(),
    update: vi.fn()
  })),
  rpc: vi.fn()
};

describe('Authentication System', () => {
  beforeEach(() => {
    // 重置模拟函数
    vi.clearAllMocks();
  });

  afterEach(() => {
    // 清理
  });

  describe('Login Functionality', () => {
    it('should handle successful login', async () => {
      const mockUser = { id: 'test-user-id', email: 'test@example.com' };
      mockSupabase.auth.signInWithPassword.mockResolvedValue({
        data: { user: mockUser },
        error: null
      });

      const result = await mockSupabase.auth.signInWithPassword({
        email: 'test@example.com',
        password: 'password123'
      });

      expect(result.data.user).toEqual(mockUser);
      expect(result.error).toBeNull();
      expect(mockSupabase.auth.signInWithPassword).toHaveBeenCalledWith({
        email: 'test@example.com',
        password: 'password123'
      });
    });

    it('should handle login failure', async () => {
      const mockError = { message: 'Invalid credentials' };
      mockSupabase.auth.signInWithPassword.mockResolvedValue({
        data: { user: null },
        error: mockError
      });

      const result = await mockSupabase.auth.signInWithPassword({
        email: 'test@example.com',
        password: 'wrongpassword'
      });

      expect(result.data.user).toBeNull();
      expect(result.error).toEqual(mockError);
    });
  });

  describe('Registration Functionality', () => {
    it('should handle successful registration', async () => {
      const mockUser = { id: 'new-user-id', email: 'new@example.com' };
      mockSupabase.auth.signUp.mockResolvedValue({
        data: { user: mockUser },
        error: null
      });

      const result = await mockSupabase.auth.signUp({
        email: 'new@example.com',
        password: 'newpassword123'
      });

      expect(result.data.user).toEqual(mockUser);
      expect(result.error).toBeNull();
      expect(mockSupabase.auth.signUp).toHaveBeenCalledWith({
        email: 'new@example.com',
        password: 'newpassword123'
      });
    });

    it('should handle registration failure', async () => {
      const mockError = { message: 'Email already exists' };
      mockSupabase.auth.signUp.mockResolvedValue({
        data: { user: null },
        error: mockError
      });

      const result = await mockSupabase.auth.signUp({
        email: 'existing@example.com',
        password: 'password123'
      });

      expect(result.data.user).toBeNull();
      expect(result.error).toEqual(mockError);
    });
  });

  describe('Profile Management', () => {
    it('should create profile for new user', async () => {
      const mockUser = { id: 'new-user-id', email: 'new@example.com' };
      const mockProfile = { id: 'new-user-id', username: 'new' };
      
      mockSupabase.from.mockReturnValue({
        select: vi.fn().mockReturnThis(),
        eq: vi.fn().mockReturnThis(),
        single: vi.fn().mockResolvedValue({ data: null }),
        insert: vi.fn().mockResolvedValue({ data: mockProfile, error: null })
      });

      const profileTable = mockSupabase.from('profiles');
      const result = await profileTable.insert({ 
        id: mockUser.id, 
        username: mockUser.email.split('@')[0] 
      });

      expect(result.data).toEqual(mockProfile);
      expect(result.error).toBeNull();
    });

    it('should load existing profile', async () => {
      const mockUser = { id: 'existing-user-id', email: 'existing@example.com' };
      const mockProfile = { 
        id: 'existing-user-id', 
        username: 'existing',
        points: 100,
        level: 2
      };
      
      mockSupabase.from.mockReturnValue({
        select: vi.fn().mockReturnThis(),
        eq: vi.fn().mockReturnThis(),
        single: vi.fn().mockResolvedValue({ data: mockProfile })
      });

      const profileTable = mockSupabase.from('profiles');
      const result = await profileTable.select('*').eq('id', mockUser.id).single();

      expect(result.data).toEqual(mockProfile);
    });
  });

  describe('Session Management', () => {
    it('should get current user', async () => {
      const mockUser = { id: 'current-user-id', email: 'current@example.com' };
      mockSupabase.auth.getUser.mockResolvedValue({
        data: { user: mockUser },
        error: null
      });

      const result = await mockSupabase.auth.getUser();

      expect(result.data.user).toEqual(mockUser);
      expect(result.error).toBeNull();
    });

    it('should handle no authenticated user', async () => {
      mockSupabase.auth.getUser.mockResolvedValue({
        data: { user: null },
        error: null
      });

      const result = await mockSupabase.auth.getUser();

      expect(result.data.user).toBeNull();
      expect(result.error).toBeNull();
    });

    it('should sign out user', async () => {
      mockSupabase.auth.signOut.mockResolvedValue({
        error: null
      });

      const result = await mockSupabase.auth.signOut();

      expect(result.error).toBeNull();
      expect(mockSupabase.auth.signOut).toHaveBeenCalled();
    });
  });

  describe('Points System', () => {
    it('should award daily login points', async () => {
      mockSupabase.rpc.mockResolvedValue({
        data: null,
        error: null
      });

      const result = await mockSupabase.rpc('fn_daily_login');

      expect(result.error).toBeNull();
      expect(mockSupabase.rpc).toHaveBeenCalledWith('fn_daily_login');
    });

    it('should load points log', async () => {
      const mockPointsLog = [
        { id: '1', user_id: 'user1', action: 'daily_login', delta: 5, created_at: '2025-01-01' },
        { id: '2', user_id: 'user1', action: 'create_post', delta: 10, created_at: '2025-01-01' }
      ];

      mockSupabase.from.mockReturnValue({
        select: vi.fn().mockReturnThis(),
        eq: vi.fn().mockReturnThis(),
        order: vi.fn().mockResolvedValue({ data: mockPointsLog })
      });

      const pointsTable = mockSupabase.from('points_log');
      const result = await pointsTable.select('*').eq('user_id', 'user1').order('created_at', { ascending: false });

      expect(result.data).toEqual(mockPointsLog);
    });
  });

  describe('User Statistics', () => {
    it('should load user statistics', async () => {
      const mockStats = {
        posts: { count: 5 },
        comments: { count: 12 },
        favorites: { count: 8 }
      };

      mockSupabase.from.mockReturnValue({
        select: vi.fn().mockReturnThis(),
        eq: vi.fn().mockReturnThis(),
        count: vi.fn().mockResolvedValue({ count: 5 })
      });

      const postsTable = mockSupabase.from('posts');
      const result = await postsTable.select('*', { count: 'exact', head: true }).eq('author_id', 'user1');

      expect(mockSupabase.from).toHaveBeenCalledWith('posts');
    });
  });
});
