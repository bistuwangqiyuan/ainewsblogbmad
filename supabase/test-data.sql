-- 测试数据
-- 插入测试用户
INSERT INTO public.profiles (id, username, bio, points, level) VALUES
('11111111-1111-1111-1111-111111111111', 'testuser1', '测试用户1', 100, 2),
('22222222-2222-2222-2222-222222222222', 'testuser2', '测试用户2', 50, 1),
('33333333-3333-3333-3333-333333333333', 'testuser3', '测试用户3', 200, 3)
ON CONFLICT (id) DO NOTHING;

-- 插入测试新闻数据
INSERT INTO public.news_items (id, title, url, source, published_at, summary, author, image_url, tags, content_html, hash) VALUES
('aaaaaaaa-aaaa-aaaa-aaaa-aaaaaaaaaaaa', 'OpenAI发布GPT-5预览版，多模态能力大幅提升', 'https://openai.com/blog/gpt-5-preview', 'OpenAI Blog', '2024-01-15T10:00:00Z', 'OpenAI今日发布了GPT-5的预览版本，新版本在多模态理解、推理能力和创造性方面都有显著提升。', 'OpenAI Team', 'https://openai.com/blog/gpt-5-preview.jpg', ARRAY['AI', 'GPT-5', '多模态'], '<p>OpenAI今日发布了GPT-5的预览版本...</p>', 'hash1'),
('bbbbbbbb-bbbb-bbbb-bbbb-bbbbbbbbbbbb', 'Google推出Gemini 2.0，性能提升40%', 'https://ai.googleblog.com/2024/01/gemini-2.0.html', 'Google AI', '2024-01-14T15:30:00Z', 'Google发布了Gemini 2.0版本，在推理能力和多模态理解方面都有显著提升。', 'Google AI Team', 'https://ai.googleblog.com/gemini-2.0.jpg', ARRAY['AI', 'Gemini', 'Google'], '<p>Google今日发布了Gemini 2.0...</p>', 'hash2'),
('cccccccc-cccc-cccc-cccc-cccccccccccc', 'Meta开源Llama 3，700B参数模型', 'https://ai.facebook.com/blog/llama-3', 'Meta AI', '2024-01-13T09:15:00Z', 'Meta开源了Llama 3大语言模型，拥有700B参数，在多个基准测试中表现优异。', 'Meta Research', 'https://ai.facebook.com/llama-3.jpg', ARRAY['AI', 'Llama', '开源'], '<p>Meta今日开源了Llama 3...</p>', 'hash3'),
('dddddddd-dddd-dddd-dddd-dddddddddddd', 'Microsoft发布Azure AI新功能', 'https://techcommunity.microsoft.com/azure-ai', 'Azure AI Blog', '2024-01-12T14:20:00Z', 'Microsoft在Azure AI平台中新增了多项功能，包括更好的模型管理和部署工具。', 'Azure Team', 'https://techcommunity.microsoft.com/azure-ai.jpg', ARRAY['AI', 'Azure', 'Microsoft'], '<p>Microsoft今日发布了Azure AI新功能...</p>', 'hash4'),
('eeeeeeee-eeee-eeee-eeee-eeeeeeeeeeee', 'Anthropic发布Claude 3.5 Sonnet', 'https://www.anthropic.com/news/claude-3.5', 'Anthropic', '2024-01-11T11:45:00Z', 'Anthropic发布了Claude 3.5 Sonnet，在代码生成和数学推理方面有显著提升。', 'Anthropic Team', 'https://www.anthropic.com/claude-3.5.jpg', ARRAY['AI', 'Claude', 'Anthropic'], '<p>Anthropic今日发布了Claude 3.5 Sonnet...</p>', 'hash5'),
('ffffffff-ffff-ffff-ffff-ffffffffffff', 'Hugging Face推出新的模型库', 'https://huggingface.co/blog/new-models', 'Hugging Face Blog', '2024-01-10T16:30:00Z', 'Hugging Face在其模型库中新增了数千个预训练模型，涵盖多个AI领域。', 'Hugging Face Team', 'https://huggingface.co/new-models.jpg', ARRAY['AI', 'Hugging Face', '模型库'], '<p>Hugging Face今日推出了新的模型库...</p>', 'hash6'),
('gggggggg-gggg-gggg-gggg-gggggggggggg', 'NVIDIA发布新一代AI芯片', 'https://developer.nvidia.com/blog/new-ai-chips', 'NVIDIA Technical Blog AI', '2024-01-09T13:15:00Z', 'NVIDIA发布了新一代AI芯片，在性能和能效方面都有显著提升。', 'NVIDIA Team', 'https://developer.nvidia.com/new-chips.jpg', ARRAY['AI', 'NVIDIA', '芯片'], '<p>NVIDIA今日发布了新一代AI芯片...</p>', 'hash7'),
('hhhhhhhh-hhhh-hhhh-hhhh-hhhhhhhhhhhh', 'DeepMind在蛋白质结构预测方面取得突破', 'https://deepmind.com/blog/protein-structure', 'DeepMind', '2024-01-08T10:00:00Z', 'DeepMind在蛋白质结构预测方面取得了重大突破，准确率提升至95%以上。', 'DeepMind Team', 'https://deepmind.com/protein.jpg', ARRAY['AI', 'DeepMind', '蛋白质'], '<p>DeepMind今日在蛋白质结构预测方面取得突破...</p>', 'hash8'),
('iiiiiiii-iiii-iiii-iiii-iiiiiiiiiiii', 'Stability AI发布新的图像生成模型', 'https://stability.ai/blog/new-image-model', 'Stability AI', '2024-01-07T15:45:00Z', 'Stability AI发布了新的图像生成模型，在图像质量和生成速度方面都有显著提升。', 'Stability AI Team', 'https://stability.ai/new-model.jpg', ARRAY['AI', 'Stability AI', '图像生成'], '<p>Stability AI今日发布了新的图像生成模型...</p>', 'hash9'),
('jjjjjjjj-jjjj-jjjj-jjjj-jjjjjjjjjjjj', 'Papers with Code新增AI论文数据集', 'https://paperswithcode.com/news/new-dataset', 'Papers with Code', '2024-01-06T12:30:00Z', 'Papers with Code新增了大规模的AI论文数据集，包含超过10万篇论文。', 'Papers with Code Team', 'https://paperswithcode.com/dataset.jpg', ARRAY['AI', 'Papers with Code', '数据集'], '<p>Papers with Code今日新增了AI论文数据集...</p>', 'hash10')
ON CONFLICT (id) DO NOTHING;

-- 插入测试帖子
INSERT INTO public.posts (id, author_id, type, title, content, category, like_count, comment_count, view_count) VALUES
-- 论坛帖子
('aaaaaaaa-aaaa-aaaa-aaaa-aaaaaaaaaaaa', '11111111-1111-1111-1111-111111111111', 'post', 'Astro框架入门指南', 'Astro是一个现代化的静态站点生成器，它允许你使用你喜欢的JavaScript框架来构建网站。本文将介绍Astro的基本概念和使用方法。', 'tech', 15, 8, 120),
('bbbbbbbb-bbbb-bbbb-bbbb-bbbbbbbbbbbb', '22222222-2222-2222-2222-222222222222', 'post', '前端开发最佳实践', '在前端开发中，代码质量和性能优化是非常重要的。本文将分享一些实用的最佳实践。', 'tech', 23, 12, 89),
('cccccccc-cccc-cccc-cccc-cccccccccccc', '33333333-3333-3333-3333-333333333333', 'post', '如何提高编程效率', '编程效率的提升需要多方面的努力，包括工具使用、代码组织和学习方法的改进。', 'tech', 8, 5, 67),
('dddddddd-dddd-dddd-dddd-dddddddddddd', '11111111-1111-1111-1111-111111111111', 'post', '周末生活分享', '分享一下我的周末生活，包括阅读、运动和放松的时间安排。', 'life', 12, 6, 45),
('eeeeeeee-eeee-eeee-eeee-eeeeeeeeeeee', '22222222-2222-2222-2222-222222222222', 'post', '最新技术趋势分析', '分析当前最新的技术趋势，包括AI、Web3、云计算等领域的发展。', 'news', 31, 18, 156),

-- 问答帖子
('ffffffff-ffff-ffff-ffff-ffffffffffff', '11111111-1111-1111-1111-111111111111', 'question', '如何解决TypeScript类型错误？', '我在使用TypeScript时遇到了类型错误，错误信息显示"类型Element上不存在属性dataset"。请问如何解决这个问题？', 'tech', 5, 3, 34),
('gggggggg-gggg-gggg-gggg-gggggggggggg', '22222222-2222-2222-2222-222222222222', 'question', 'Astro和Next.js的区别是什么？', '我想了解Astro和Next.js这两个框架的主要区别，以及它们各自的适用场景。', 'tech', 18, 9, 78),
('hhhhhhhh-hhhh-hhhh-hhhh-hhhhhhhhhhhh', '33333333-3333-3333-3333-333333333333', 'question', '如何优化网站性能？', '我的网站加载速度比较慢，想了解一些性能优化的方法和技巧。', 'tech', 25, 14, 92),
('iiiiiiii-iiii-iiii-iiii-iiiiiiiiiiii', '11111111-1111-1111-1111-111111111111', 'question', '推荐一些学习资源', '我是前端新手，想找一些好的学习资源，包括书籍、视频和在线课程。', 'life', 7, 4, 56),
('jjjjjjjj-jjjj-jjjj-jjjj-jjjjjjjjjjjj', '22222222-2222-2222-2222-222222222222', 'question', '如何处理用户反馈？', '在产品开发中，如何有效地收集和处理用户反馈，并将其转化为产品改进？', 'other', 14, 7, 43)
ON CONFLICT (id) DO NOTHING;
