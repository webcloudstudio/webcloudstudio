cd /mnt/c/Users/barlo/projects/My_Github
 1. Local Testing (Development)
  npm run build
  npm run preview
  # Test at http://localhost:4321/webcloudstudio

  2. When Ready, Push to Main
  git push origin main

  3. GitHub Actions Automatically Deploys
  - GitHub Pages watches the main branch
  - When you push, GitHub Actions runs automatically
  - Build completes in ~2 minutes
  - Site updates at: https://webcloudstudio.github.io/webcloudstudio

  4. Verify Production

  Visit https://webcloudstudio.github.io/webcloudstudio to confirm changes are live

  ---
  Current Setup

  - Repo: My_Github (main branch)
  - Deploy: GitHub Pages → webcloudstudio.github.io
  - Base Path: /webcloudstudio
  - Auto-deploy: Any push to main triggers build + deploy

  Visit http://localhost:4321/webcloudstudio — you'll see:
  - Cards rotate every 8 seconds
  - Click arrows to navigate
  - Click dots to jump to a specific card
  - Responsive: 1 card (mobile), 2 (tablet), 3 (desktop)

