import { describe, it, expect } from 'vitest';
import { parseSources, toQueryParams } from '../src/lib/filters.js';

describe('filters utils', () => {
    it('parseSources handles empty', () => {
        expect(parseSources('')).toEqual([]);
        expect(parseSources(null)).toEqual([]);
    });
    it('parseSources trims and dedupes', () => {
        expect(parseSources('a, b ,a')).toEqual(['a', 'b']);
    });
    it('toQueryParams serializes non-empty fields', () => {
        // 创建模拟的FormData对象
        const formData = new FormData();
        formData.append('q', 'abc');
        formData.append('source', '');
        
        const qs = toQueryParams(formData);
        expect(qs).toContain('q=abc');
        expect(qs).not.toContain('source=');
    });
});
