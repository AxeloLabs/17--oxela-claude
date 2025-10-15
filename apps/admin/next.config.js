// ============================================================
// apps/admin/next.config.js
// Pour l'admin (pas de SEO nécessaire)
// ============================================================
/** @type {import('next').NextConfig} */
const nextConfig = {
  reactStrictMode: true,
  transpilePackages: ["@mon-projet/ui", "@mon-projet/firebase"],
  output: "export",
  images: {
    unoptimized: true,
  },
};

module.exports = nextConfig;
