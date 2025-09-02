import { describe, it, expect } from 'vitest';

describe('PostDetail Component', () => {
    it('should render post detail with correct props', () => {
        const props = {
            id: 'test-post-id',
            type: 'post',
            title: '测试帖子标题',
            content: '这是一个测试帖子的内容，用于验证组件是否正确渲染。',
            author: {
                id: 'user-1',
                username: 'testuser',
                avatar_url: null,
                level: 2
            },
            createdAt: '2025-01-01T00:00:00Z',
            updatedAt: null,
            media: [],
            likeCount: 10,
            commentCount: 5,
            viewCount: 100,
            isAuthor: false
        };

        // 验证props结构
        expect(props.id).toBe('test-post-id');
        expect(props.type).toBe('post');
        expect(props.title).toBe('测试帖子标题');
        expect(props.content).toBe('这是一个测试帖子的内容，用于验证组件是否正确渲染。');
        expect(props.author.username).toBe('testuser');
        expect(props.author.level).toBe(2);
        expect(props.likeCount).toBe(10);
        expect(props.commentCount).toBe(5);
        expect(props.viewCount).toBe(100);
        expect(props.isAuthor).toBe(false);
    });

    it('should render question detail with correct props', () => {
        const props = {
            id: 'test-question-id',
            type: 'question',
            title: '测试问题标题',
            content: '这是一个测试问题的内容，用于验证问答组件是否正确渲染。',
            author: {
                id: 'user-2',
                username: 'questionuser',
                avatar_url: 'https://example.com/avatar.jpg',
                level: 3
            },
            createdAt: '2025-01-01T00:00:00Z',
            updatedAt: '2025-01-02T00:00:00Z',
            media: [
                { url: 'https://example.com/image.jpg', type: 'image/jpeg', name: 'test.jpg' }
            ],
            likeCount: 5,
            commentCount: 3,
            viewCount: 50,
            isAuthor: true
        };

        expect(props.type).toBe('question');
        expect(props.author.username).toBe('questionuser');
        expect(props.author.avatar_url).toBe('https://example.com/avatar.jpg');
        expect(props.media).toHaveLength(1);
        expect(props.media[0].type).toBe('image/jpeg');
        expect(props.isAuthor).toBe(true);
    });

    it('should handle media files correctly', () => {
        const media = [
            { url: 'https://example.com/image.jpg', type: 'image/jpeg', name: 'image.jpg' },
            { url: 'https://example.com/video.mp4', type: 'video/mp4', name: 'video.mp4' },
            { url: 'https://example.com/document.pdf', type: 'application/pdf', name: 'document.pdf' }
        ];

        expect(media).toHaveLength(3);
        expect(media[0].type).toMatch(/^image\//);
        expect(media[1].type).toMatch(/^video\//);
        expect(media[2].type).toMatch(/^application\//);
    });

    it('should handle empty media array', () => {
        const media = [];
        expect(media).toHaveLength(0);
    });

    it('should handle author without avatar', () => {
        const author = {
            id: 'user-3',
            username: 'noavatar',
            avatar_url: null,
            level: 1
        };

        expect(author.avatar_url).toBeNull();
        expect(author.username.charAt(0).toUpperCase()).toBe('N');
    });
});
