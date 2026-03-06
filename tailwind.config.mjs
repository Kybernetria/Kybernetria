/** @type {import('tailwindcss').Config} */
export default {
    content: ['./src/**/*.{astro,html,js,jsx,md,mdx,svelte,ts,tsx,vue}'],
    theme: {
        extend: {
            colors: {
                carbon: '#0F0F0F',
                forge: '#1A1A1A',
                plate: '#242424',
                chalk: '#E8E4DC',
                ash: '#8A8880',
                signal: '#ff0000ff', // Signal Red
                copper: '#C47A3A',
                cyan: '#7EC8C8', // Pale Cyan
                wire: '#2E2E2E',
            },
            fontFamily: {
                headline: ['"Bebas Neue"', 'sans-serif'],
                subhead: ['"Epilogue"', 'sans-serif'],
                body: ['"Lora"', 'serif'],
                mono: ['"JetBrains Mono"', 'monospace'],
            },
        },
    },
    plugins: [],
}
