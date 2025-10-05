import { createClient } from '@supabase/supabase-js';
import Parser from 'rss-parser';
import { createHash } from 'crypto';

const SOURCES = [
    { type: 'rss', name: 'OpenAI Blog', url: 'https://openai.com/blog/rss.xml' },
    { type: 'rss', name: 'DeepMind', url: 'https://deepmind.com/blog/rss.xml' },
    { type: 'rss', name: 'Google AI', url: 'https://ai.googleblog.com/feeds/posts/default?alt=rss' },
    { type: 'rss', name: 'Microsoft Research', url: 'https://www.microsoft.com/en-us/research/feed/' },
    { type: 'rss', name: 'Meta AI', url: 'https://ai.facebook.com/blog/rss/' },
    { type: 'rss', name: 'Stability AI', url: 'https://stability.ai/feed' },
    { type: 'rss', name: 'Amazon Science', url: 'https://www.amazon.science/index.rss' },
    { type: 'rss', name: 'Apple ML', url: 'https://machinelearning.apple.com/rss.xml' },
    { type: 'rss', name: 'Hugging Face Blog', url: 'https://huggingface.co/blog/rss.xml' },
    { type: 'rss', name: 'The Gradient', url: 'https://thegradient.pub/rss/' },
    { type: 'rss', name: 'GitHub Blog AI', url: 'https://github.blog/tag/ai/feed/' },
    { type: 'rss', name: 'MLOps Community', url: 'https://mlops.community/feed/' },
    { type: 'rss', name: 'Anthropic', url: 'https://www.anthropic.com/news.xml' },
    { type: 'rss', name: 'Papers with Code', url: 'https://paperswithcode.com/feeds/latest' },
    { type: 'rss', name: 'Amazon Science Blog', url: 'https://www.amazon.science/index.rss' },
    { type: 'rss', name: 'Meta Research', url: 'https://research.facebook.com/blog/rss/' },
    { type: 'rss', name: 'Google Research', url: 'https://research.google/blog/rss/' },
    { type: 'rss', name: 'Azure AI Blog', url: 'https://techcommunity.microsoft.com/t5/azure-ai-blog/bg-p/AzureAIBlog/label-name/AI/rss-board' },
    { type: 'rss', name: 'NVIDIA Technical Blog AI', url: 'https://developer.nvidia.com/blog/tag/ai/feed/' },
    { type: 'rss', name: 'Open Source AI', url: 'https://opensource.googleblog.com/feeds/posts/default?alt=rss' }
];

function sha1(str) {
    return createHash('sha1').update(str).digest('hex');
}

export default async (request, context) => {
    // 使用Anon Key而不是Service Role Key
    const SUPABASE_URL = process.env.SUPABASE_URL || "https://zzyueuweeoakopuuwfau.supabase.co";
    const SUPABASE_ANON_KEY = process.env.SUPABASE_ANON_KEY || "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6Inp6eXVldXdlZW9ha29wdXV3ZmF1Iiwicm9sZSI6ImFub24iLCJpYXQiOjE3NDQzODEzMDEsImV4cCI6MjA1OTk1NzMwMX0.y8V3EXK9QVd3txSWdE3gZrSs96Ao0nvpnd0ntZw_dQ4";
    
    if (!SUPABASE_URL || !SUPABASE_ANON_KEY) {
        return new Response(JSON.stringify({ error: '未配置 Supabase 配置' }), { status: 500 });
    }
    
    const supabase = createClient(SUPABASE_URL, SUPABASE_ANON_KEY);
    const parser = new Parser();
    let inserted = 0,
        seen = new Set();

    for (const src of SOURCES) {
        try {
            if (src.type === 'rss') {
                const feed = await parser.parseURL(src.url);
                const items = (feed.items || []).slice(0, 100);
                for (const it of items) {
                    const title = it.title || '';
                    const url = it.link || '';
                    if (!title || !url) continue;
                    const pub = it.isoDate || it.pubDate ? new Date(it.isoDate || it.pubDate).toISOString() : null;
                    const hash = sha1(title.trim().toLowerCase() + '|' + url.trim().toLowerCase() + '|' + (pub || ''));
                    if (seen.has(hash)) continue;
                    seen.add(hash);
                    const row = {
                        title,
                        url,
                        source: src.name,
                        published_at: pub,
                        summary: it.contentSnippet || it.content || '',
                        image_url: it.enclosure?.url || null,
                        tags: [],
                        content_html: it['content:encoded'] || it.content || null,
                        hash
                    };
                    const { data, error } = await supabase.from('news_items').upsert(row, { onConflict: 'hash', ignoreDuplicates: true }).select('id');
                    if (!error && data && data.length > 0) inserted += data.length;
                }
            }
            await supabase.from('crawler_logs').insert({ source: src.name, status: 'ok', message: null });
        } catch (e) {
            await supabase.from('crawler_logs').insert({ source: src.name, status: 'error', message: String(e?.message || e) });
        }
    }

    return new Response(JSON.stringify({ inserted }), { status: 200 });
};
