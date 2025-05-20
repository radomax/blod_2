import adapter from '@sveltejs/adapter-auto';

/** @type {import('@sveltejs/kit').Config} */
const config = {
    kit: {
        adapter: adapter(),
        files: {
            hooks: {
                client: 'src/hooks.client.js',
                server: 'src/hooks.server.js'
            }
        }
    }
};

export default config;