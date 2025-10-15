// ============================================================
// apps/dashboard/next.config.js
// Pour le dashboard utilisateur (pas de SEO nécessaire)
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
