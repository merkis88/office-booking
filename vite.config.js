import { defineConfig } from 'vite';
import vue from '@vitejs/plugin-vue';
import { fileURLToPath, URL } from 'node:url';

export default defineConfig({
    plugins: [vue()],
    resolve: {
        alias: {
            '@': fileURLToPath(new URL('./src', import.meta.url)),
        },
    },
    publicDir: false,
    server: {
        proxy: {
            '/api': {
                target: 'http://localhost',
                changeOrigin: true,
            },
        },
        watch: {
            usePolling: true,
        },
    },
    build: {
        watch: {
            chokidar: {
                usePolling: true,
            },
        },
        outDir: 'public',
        assetsDir: 'dist',
        emptyOutDir: false,
    },
});
