import { defineCollection, z } from 'astro:content';
import { glob } from 'astro/loaders';

const blogCollection = defineCollection({
    loader: glob({ pattern: '**/*.md', base: './src/content/blog' }),
    schema: z.object({
        title: z.string(),
        date: z.coerce.date(),
        tags: z.array(z.string()),
        excerpt: z.string(),
        heroImage: z.string().optional(),
        draft: z.boolean().optional(),
    }),
});

const toolsCollection = defineCollection({
    loader: glob({ pattern: '**/*.md', base: './src/content/tools' }),
    schema: z.object({
        name: z.string(),
        description: z.string(),
        github: z.string(),
        tags: z.array(z.string()).default([]),
        status: z.enum(['active', 'stable', 'experimental']).default('active'),
        order: z.number().default(0),
    }),
});

export const collections = {
    'blog': blogCollection,
    'tools': toolsCollection,
};
