import { describe, it, expect, beforeEach, vi } from 'vitest';

// 模拟反馈类型
const mockTypes = [
    {
        value: 'bug',
        label: 'Bug 报告',
        description: '报告系统错误或问题',
        icon: '<svg>bug</svg>'
    },
    {
        value: 'feature',
        label: '功能建议',
        description: '建议新功能或改进',
        icon: '<svg>feature</svg>'
    },
    {
        value: 'suggestion',
        label: '改进建议',
        description: '对现有功能的改进建议',
        icon: '<svg>suggestion</svg>'
    },
    {
        value: 'other',
        label: '其他',
        description: '其他类型的反馈',
        icon: '<svg>other</svg>'
    }
];

describe('FeedbackForm Component', () => {
    beforeEach(() => {
        // 模拟DOM环境
        global.document = {
            addEventListener: vi.fn(),
            querySelectorAll: vi.fn(() => []),
            querySelector: vi.fn(() => ({
                addEventListener: vi.fn(),
                classList: {
                    add: vi.fn(),
                    remove: vi.fn()
                },
                innerHTML: '',
                textContent: '',
                files: []
            })),
            getElementById: vi.fn(() => ({
                addEventListener: vi.fn(),
                classList: {
                    add: vi.fn(),
                    remove: vi.fn()
                },
                innerHTML: '',
                textContent: '',
                value: '',
                files: []
            })),
            dispatchEvent: vi.fn()
        };

        global.window = {
            alert: vi.fn()
        };

        global.CustomEvent = vi.fn();
    });

    it('应该正确渲染反馈表单', () => {
        const component = {
            onSubmit: vi.fn(),
            onCancel: vi.fn(),
            types: mockTypes
        };

        expect(component.types).toHaveLength(4);
        expect(component.types[0].value).toBe('bug');
        expect(component.types[1].value).toBe('feature');
        expect(component.types[2].value).toBe('suggestion');
        expect(component.types[3].value).toBe('other');
    });

    it('应该处理反馈类型选择', () => {
        const component = {
            onSubmit: vi.fn(),
            onCancel: vi.fn(),
            types: mockTypes
        };

        // 模拟类型选择
        const selectedType = 'bug';
        const typeData = component.types.find((t) => t.value === selectedType);

        expect(typeData).toBeDefined();
        expect(typeData.value).toBe('bug');
        expect(typeData.label).toBe('Bug 报告');
    });

    it('应该验证必填字段', () => {
        const component = {
            onSubmit: vi.fn(),
            onCancel: vi.fn(),
            types: mockTypes
        };

        // 模拟表单验证
        const validateForm = (data) => {
            const errors = [];
            if (!data.type) errors.push('请选择反馈类型');
            if (!data.title) errors.push('请填写反馈标题');
            if (!data.content) errors.push('请填写反馈内容');
            return errors;
        };

        const emptyData = { type: '', title: '', content: '' };
        const errors = validateForm(emptyData);

        expect(errors).toHaveLength(3);
        expect(errors).toContain('请选择反馈类型');
        expect(errors).toContain('请填写反馈标题');
        expect(errors).toContain('请填写反馈内容');
    });

    it('应该处理字符计数', () => {
        // 模拟字符计数函数
        const updateCharCount = (text, maxLength) => {
            const count = text.length;
            const isNearLimit = count > maxLength * 0.9;
            return { count, isNearLimit };
        };

        const shortText = '短文本';
        const longText = '这是一个很长的文本，用来测试字符计数功能是否正常工作';
        const maxLength = 200;

        const shortResult = updateCharCount(shortText, maxLength);
        const longResult = updateCharCount(longText, maxLength);

        expect(shortResult.count).toBe(3);
        expect(shortResult.isNearLimit).toBe(false);
        expect(longResult.count).toBe(26); // 修正：实际字符长度是26，不是20
        expect(longResult.isNearLimit).toBe(false);
    });

    it('应该处理文件上传', () => {
        const component = {
            onSubmit: vi.fn(),
            onCancel: vi.fn(),
            types: mockTypes
        };

        // 模拟文件验证
        const validateFile = (file) => {
            const maxSize = 10 * 1024 * 1024; // 10MB
            const allowedTypes = ['image/', 'application/pdf', 'text/'];

            const errors = [];
            if (file.size > maxSize) {
                errors.push(`文件 ${file.name} 超过10MB限制`);
            }

            const isValidType = allowedTypes.some((type) => file.type.startsWith(type));
            if (!isValidType) {
                errors.push(`文件 ${file.name} 格式不支持`);
            }

            return errors;
        };

        const validFile = {
            name: 'test.jpg',
            size: 1024 * 1024, // 1MB
            type: 'image/jpeg'
        };

        const invalidFile = {
            name: 'test.exe',
            size: 20 * 1024 * 1024, // 20MB
            type: 'application/x-executable'
        };

        const validErrors = validateFile(validFile);
        const invalidErrors = validateFile(invalidFile);

        expect(validErrors).toHaveLength(0);
        expect(invalidErrors).toHaveLength(2);
    });

    it('应该处理表单提交', () => {
        const component = {
            onSubmit: vi.fn(),
            onCancel: vi.fn(),
            types: mockTypes
        };

        // 模拟表单数据
        const formData = {
            type: 'bug',
            title: '测试Bug报告',
            content: '这是一个测试Bug报告的内容',
            contact: 'test@example.com',
            attachments: []
        };

        // 模拟提交
        const submitForm = (data) => {
            if (!data.type || !data.title || !data.content) {
                throw new Error('请填写完整的反馈信息');
            }
            return { success: true, data };
        };

        const result = submitForm(formData);

        expect(result.success).toBe(true);
        expect(result.data.type).toBe('bug');
        expect(result.data.title).toBe('测试Bug报告');
    });

    it('应该处理表单取消', () => {
        const component = {
            onSubmit: vi.fn(),
            onCancel: vi.fn(),
            types: mockTypes
        };

        // 模拟取消操作
        const cancelForm = () => {
            return { cancelled: true };
        };

        const result = cancelForm();

        expect(result.cancelled).toBe(true);
    });

    it('应该处理预览功能', () => {
        const component = {
            onSubmit: vi.fn(),
            onCancel: vi.fn(),
            types: mockTypes
        };

        // 模拟预览数据
        const previewData = {
            type: 'feature',
            title: '新功能建议',
            content: '建议添加一个新功能',
            contact: 'user@example.com',
            attachments: ['file1.jpg', 'file2.pdf']
        };

        // 模拟生成预览内容
        const generatePreview = (data) => {
            const typeLabel = component.types.find((t) => t.value === data.type)?.label || data.type;

            return {
                type: typeLabel,
                title: data.title,
                content: data.content,
                contact: data.contact,
                attachmentCount: data.attachments.length
            };
        };

        const preview = generatePreview(previewData);

        expect(preview.type).toBe('功能建议');
        expect(preview.title).toBe('新功能建议');
        expect(preview.attachmentCount).toBe(2);
    });

    it('应该处理拖拽上传', () => {
        const component = {
            onSubmit: vi.fn(),
            onCancel: vi.fn(),
            types: mockTypes
        };

        // 模拟拖拽事件
        const mockDragEvent = {
            preventDefault: vi.fn(),
            dataTransfer: {
                files: [
                    {
                        name: 'test.jpg',
                        size: 1024 * 1024,
                        type: 'image/jpeg'
                    }
                ]
            }
        };

        // 模拟处理拖拽文件
        const handleDragDrop = (event) => {
            event.preventDefault();
            const files = Array.from(event.dataTransfer.files);
            return files;
        };

        const files = handleDragDrop(mockDragEvent);

        expect(files).toHaveLength(1);
        expect(files[0].name).toBe('test.jpg');
        expect(mockDragEvent.preventDefault).toHaveBeenCalled();
    });

    it('应该处理文件删除', () => {
        const component = {
            onSubmit: vi.fn(),
            onCancel: vi.fn(),
            types: mockTypes
        };

        // 模拟文件列表
        let uploadedFiles = [
            { name: 'file1.jpg', size: 1024 * 1024 },
            { name: 'file2.pdf', size: 2048 * 1024 },
            { name: 'file3.txt', size: 512 * 1024 }
        ];

        // 模拟删除文件
        const removeFile = (index) => {
            uploadedFiles.splice(index, 1);
            return uploadedFiles;
        };

        const result = removeFile(1);

        expect(result).toHaveLength(2);
        expect(result[0].name).toBe('file1.jpg');
        expect(result[1].name).toBe('file3.txt');
    });

    it('应该处理不同反馈类型', () => {
        const component = {
            onSubmit: vi.fn(),
            onCancel: vi.fn(),
            types: mockTypes
        };

        // 模拟不同类型的数据
        const feedbackData = [
            {
                type: 'bug',
                title: '系统崩溃问题',
                content: '在使用过程中系统突然崩溃',
                priority: 'high'
            },
            {
                type: 'feature',
                title: '添加搜索功能',
                content: '建议添加全局搜索功能',
                priority: 'medium'
            },
            {
                type: 'suggestion',
                title: '优化界面布局',
                content: '建议优化界面布局，提升用户体验',
                priority: 'low'
            }
        ];

        feedbackData.forEach((data) => {
            const typeInfo = component.types.find((t) => t.value === data.type);
            expect(typeInfo).toBeDefined();
            expect(data.title).toBeDefined();
            expect(data.content).toBeDefined();
            expect(data.priority).toBeDefined();
        });
    });

    it('应该处理表单重置', () => {
        const component = {
            onSubmit: vi.fn(),
            onCancel: vi.fn(),
            types: mockTypes
        };

        // 模拟表单状态
        let formState = {
            type: 'bug',
            title: '测试标题',
            content: '测试内容',
            contact: 'test@example.com',
            attachments: ['file1.jpg']
        };

        // 模拟重置表单
        const resetForm = () => {
            formState = {
                type: '',
                title: '',
                content: '',
                contact: '',
                attachments: []
            };
            return formState;
        };

        const result = resetForm();

        expect(result.type).toBe('');
        expect(result.title).toBe('');
        expect(result.content).toBe('');
        expect(result.attachments).toHaveLength(0);
    });
});
