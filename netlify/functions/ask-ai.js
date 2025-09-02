import { createClient } from '@supabase/supabase-js';

export default async (request, context) => {
    try {
        const { question, authorId } = await request.json();
        if (!question || typeof question !== 'string') {
            return new Response(JSON.stringify({ error: '缺少问题' }), { status: 400 });
        }
        if (!authorId) {
            return new Response(JSON.stringify({ error: '需要登录后提问' }), { status: 401 });
        }

        const SUPABASE_URL = process.env.SUPABASE_URL;
        const SERVICE_KEY = process.env.SUPABASE_SERVICE_ROLE_KEY;
        const AI_USER_ID = process.env.AI_SYSTEM_USER_ID;
        if (!SUPABASE_URL || !SERVICE_KEY) {
            return new Response(JSON.stringify({ error: '未配置 Supabase Service Key' }), { status: 500 });
        }
        if (!AI_USER_ID) {
            return new Response(JSON.stringify({ error: '未配置 AI_SYSTEM_USER_ID' }), { status: 500 });
        }
        const supabaseAdmin = createClient(SUPABASE_URL, SERVICE_KEY);

        const apiUrl = process.env.OPENAI_COMPAT_API_URL;
        const apiKey = process.env.OPENAI_COMPAT_API_KEY;
        if (!apiUrl || !apiKey) {
            return new Response(JSON.stringify({ error: '未配置 AI 提供商' }), { status: 500 });
        }

        // 先将问题落库为一个 question 帖子
        const title = (question.split('\n')[0] || question).slice(0, 80).trim() || '用户提问';
        const { data: postData, error: postErr } = await supabaseAdmin
            .from('posts')
            .insert({ author_id: authorId, type: 'question', title, content: question, media: [] })
            .select('id')
            .single();
        if (postErr) {
            return new Response(JSON.stringify({ error: '保存问题失败', detail: postErr.message }), { status: 500 });
        }

        // 调用 AI
        const aiResp = await fetch(apiUrl + '/v1/chat/completions', {
            method: 'POST',
            headers: {
                Authorization: `Bearer ${apiKey}`,
                'Content-Type': 'application/json'
            },
            body: JSON.stringify({
                model: 'gpt-4o-mini',
                messages: [
                    { role: 'system', content: '你是一位资深 AI 编程专家，仅中文回答，给出清晰的步骤与参考。' },
                    { role: 'user', content: question }
                ]
            })
        });
        if (!aiResp.ok) {
            const txt = await aiResp.text();
            return new Response(JSON.stringify({ error: 'AI 请求失败', detail: txt, postId: postData.id }), { status: 502 });
        }
        const aiData = await aiResp.json();
        const answer = aiData?.choices?.[0]?.message?.content || '';
        if (!answer) {
            return new Response(JSON.stringify({ error: 'AI 无响应内容', postId: postData.id }), { status: 502 });
        }

        const { data: answerData, error: ansErr } = await supabaseAdmin
            .from('answers')
            .insert({ question_id: postData.id, author_id: AI_USER_ID, content: answer, media: [] })
            .select('id')
            .single();
        if (ansErr) {
            return new Response(JSON.stringify({ error: '保存回答失败', detail: ansErr.message, postId: postData.id }), { status: 500 });
        }

        return new Response(JSON.stringify({ answer, postId: postData.id, answerId: answerData.id }), {
            status: 200,
            headers: { 'Content-Type': 'application/json' }
        });
    } catch (e) {
        return new Response(JSON.stringify({ error: e.message }), { status: 500 });
    }
};
