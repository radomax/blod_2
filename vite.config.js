import { sveltekit } from '@sveltejs/kit/vite';
import { defineConfig } from 'vite';

export default defineConfig({
    plugins: [sveltekit()],
    server: {
        port: 3023,
        host: true
    },
    build: {
        target: 'es2015'
    }
});