/** @type {import('next').NextConfig} */
const nextConfig = {
  reactStrictMode: true,
  transpilePackages: ['@mon-projet/ui', '@mon-projet/firebase'],
}

module.exports = nextConfig
