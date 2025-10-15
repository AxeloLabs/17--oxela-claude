// ============================================================
// apps/vitrine/next.config.js
// Pour le site vitrine avec SEO
// ============================================================
/** @type {import('next').NextConfig} */
const nextConfig = {
  reactStrictMode: true,
  transpilePackages: ["@mon-projet/ui", "@mon-projet/firebase"],
  output: "export", // Export statique pour Firebase Hosting
  images: {
    unoptimized: true, // Nécessaire pour export statique
  },
  trailingSlash: true, // URLs avec slash final
};

module.exports = nextConfig;
