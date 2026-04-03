import { defineConfig } from 'astro/config';
import tailwind from '@astrojs/tailwind';
import wikiLinks from './src/plugins/wiki-links.mjs';

export default defineConfig({
  output: 'static',
  site: 'https://kybernetria.com',
  integrations: [tailwind()],
  markdown: {
    remarkPlugins: [wikiLinks],
  },
});