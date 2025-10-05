import { defineConfig } from 'astro/config';
import netlify from '@astrojs/netlify';
import react from '@astrojs/react';
import tailwindcss from '@tailwindcss/vite';
import sitemap from '@astrojs/sitemap';

// https://astro.build/config
export default defineConfig({
    site: 'https://ainewsblogbmad.netlify.app',
    trailingSlash: 'never',
    build: {
        inlineStylesheets: 'auto',
        assets: '_astro'
    },
    compressHTML: true,
    vite: {
        plugins: [tailwindcss()],
        build: {
            cssMinify: true,
            minify: 'esbuild',
            rollupOptions: {
                output: {
                    manualChunks: {
                        'react-vendor': ['react', 'react-dom']
                    }
                }
            }
        }
    },
    integrations: [
        react(),
        sitemap({
            changefreq: 'daily',
            priority: 0.7,
            lastmod: new Date(),
            filter: (page) => !page.includes('/api/'),
            serialize(item) {
                if (item.url.endsWith('/')) {
                    item.url = item.url.slice(0, -1);
                }
                // 优先级设置
                if (item.url === 'https://ainewsblogbmad.netlify.app') {
                    item.priority = 1.0;
                } else if (item.url.includes('/news') || item.url.includes('/community')) {
                    item.priority = 0.9;
                } else if (item.url.includes('/ask') || item.url.includes('/compose')) {
                    item.priority = 0.8;
                }
                return item;
            }
        })
    ],
    adapter: netlify({
        edgeMiddleware: true
    })
});
