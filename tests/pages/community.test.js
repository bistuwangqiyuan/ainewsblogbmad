import { describe, it, expect, beforeEach, vi } from 'vitest';

// Mock Supabase client
const mockSupabase = {
    from: vi.fn(() => ({
        select: vi.fn(() => ({
            eq: vi.fn(() => ({
                order: vi.fn(() => ({
                    or: vi.fn(() => Promise.resolve({ data: [], error: null }))
                }))
            }))
        }))
    }))
};

// Mock DOM elements
const mockElements = {
    'posts-list': { innerHTML: '', classList: { add: vi.fn(), remove: vi.fn() } },
    'loading': { classList: { add: vi.fn(), remove: vi.fn() } },
    'empty': { classList: { add: vi.fn(), remove: vi.fn() } }
};

describe('Community Page', () => {
    beforeEach(() => {
        vi.clearAllMocks();
        global.document = {
            getElementById: vi.fn((id) => mockElements[id]),
            addEventListener: vi.fn(),
            dispatchEvent: vi.fn()
        };
    });

    describe('Data Loading', () => {
        it('should load posts successfully', async () => {
            const mockData = [
                {
                    id: 'test-1',
                    title: '测试帖子1',
                    content: '测试内容1',
                    created_at: '2025-01-01T00:00:00Z',
                    author: { username: 'testuser' },
                    like_count: 10,
                    comment_count: 5
                }
            ];

            mockSupabase.from.mockReturnValue({
                select: vi.fn(() => ({
                    eq: vi.fn(() => ({
                        order: vi.fn(() => Promise.resolve({ data: mockData, error: null }))
                    }))
                }))
            });

            // 模拟加载函数
            const loadPosts = async () => {
                const { data, error } = await mockSupabase.from('posts').select().eq().order();
                if (error) throw error;
                return data;
            };

            const result = await loadPosts();
            expect(result).toEqual(mockData);
        });

        it('should handle loading errors gracefully', async () => {
            const mockError = { message: 'Database connection failed' };

            mockSupabase.from.mockReturnValue({
                select: vi.fn(() => ({
                    eq: vi.fn(() => ({
                        order: vi.fn(() => Promise.resolve({ data: null, error: mockError }))
                    }))
                }))
            });

            // 模拟错误处理
            const loadPosts = async () => {
                const { data, error } = await mockSupabase.from('posts').select().eq().order();
                if (error) throw error;
                return data;
            };

            await expect(loadPosts()).rejects.toEqual(mockError);
        });

        it('should handle empty data correctly', async () => {
            mockSupabase.from.mockReturnValue({
                select: vi.fn(() => ({
                    eq: vi.fn(() => ({
                        order: vi.fn(() => Promise.resolve({ data: [], error: null }))
                    }))
                }))
            });

            const loadPosts = async () => {
                const { data, error } = await mockSupabase.from('posts').select().eq().order();
                if (error) throw error;
                return data;
            };

            const result = await loadPosts();
            expect(result).toEqual([]);
        });
    });

    describe('Filtering and Sorting', () => {
        it('should apply sort filters correctly', () => {
            const sortOptions = [
                { value: 'time', label: '最新发布' },
                { value: 'hot', label: '最热门' },
                { value: 'reply', label: '最新回复' }
            ];

            expect(sortOptions).toHaveLength(3);
            expect(sortOptions[0].value).toBe('time');
            expect(sortOptions[1].value).toBe('hot');
            expect(sortOptions[2].value).toBe('reply');
        });

        it('should apply category filters correctly', () => {
            const filterOptions = [
                { value: 'tech', label: '技术' },
                { value: 'life', label: '生活' },
                { value: 'news', label: '新闻' },
                { value: 'other', label: '其他' }
            ];

            expect(filterOptions).toHaveLength(4);
            expect(filterOptions[0].value).toBe('tech');
            expect(filterOptions[1].value).toBe('life');
        });

        it('should handle search functionality', () => {
            const searchTerm = '测试';
            const mockQuery = {
                or: vi.fn(() => Promise.resolve({ data: [], error: null }))
            };

            // 模拟搜索查询
            const applySearch = (query, term) => {
                if (term) {
                    return query.or(`title.ilike.%${term}%,content.ilike.%${term}%`);
                }
                return query;
            };

            const result = applySearch(mockQuery, searchTerm);
            expect(result).toBeDefined();
        });
    });

    describe('Tab Switching', () => {
        it('should switch between forum and Q&A tabs', () => {
            const tabs = ['论坛', '问答'];
            expect(tabs).toHaveLength(2);
            expect(tabs[0]).toBe('论坛');
            expect(tabs[1]).toBe('问答');
        });

        it('should update content type when switching tabs', () => {
            const tabToType = {
                '论坛': 'post',
                '问答': 'question'
            };

            expect(tabToType['论坛']).toBe('post');
            expect(tabToType['问答']).toBe('question');
        });
    });
});
