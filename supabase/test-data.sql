-- 测试数据
-- 插入测试用户
INSERT INTO public.profiles (id, username, bio, points, level) VALUES
('11111111-1111-1111-1111-111111111111', 'testuser1', '测试用户1', 100, 2),
('22222222-2222-2222-2222-222222222222', 'testuser2', '测试用户2', 50, 1),
('33333333-3333-3333-3333-333333333333', 'testuser3', '测试用户3', 200, 3)
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
