import { describe, it, expect } from 'vitest';
import { formatAiError } from '../src/lib/ai.js';

describe('formatAiError', () => {
    it('returns plain string', () => {
        expect(formatAiError('错误A')).toBe('错误A');
    });
    it('returns detail when provided', () => {
        expect(formatAiError({}, '详细错误')).toBe('详细错误');
    });
    it('handles object with message', () => {
        expect(formatAiError({ message: '失败' })).toBe('失败');
    });
    it('fallback default', () => {
        expect(formatAiError(null)).toBe('请求失败，请稍后重试');
    });
});
