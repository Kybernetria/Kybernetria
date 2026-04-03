/** @type {import('tailwindcss').Config} */
export default {
  content: ["./src/**/*.{astro,html,js,jsx,md,mdx,svelte,ts,tsx,vue}"],
  theme: {
    extend: {
      colors: {
        carbon: "rgb(15 15 15 / <alpha-value>)",
        forge: "rgb(26 26 26 / <alpha-value>)",
        plate: "rgb(36 36 36 / <alpha-value>)",
        chalk: "rgb(232 228 220 / <alpha-value>)",
        ash: "rgb(138 136 128 / <alpha-value>)",
        signal: "rgb(217 63 46 / <alpha-value>)",
        copper: "rgb(196 122 58 / <alpha-value>)",
        cyan: "rgb(126 200 200 / <alpha-value>)",
        wire: "rgb(46 46 46 / <alpha-value>)",
      },
      fontFamily: {
        headline: ['"Bebas Neue"', "sans-serif"],
        subhead: ['"Epilogue"', "sans-serif"],
        body: ['"Lora"', "serif"],
        mono: ['"JetBrains Mono"', "monospace"],
      },
    },
  },
  plugins: [],
};
