# Website — Obsidian Tray Landing Page

## Overview

Single-pane landing page for Obsidian Tray, a macOS menu bar app for quick note capture to Obsidian. Design inspired by [homerow.com](https://www.homerow.com/) — centered single-column hero layout with generous whitespace and strong typography.

## Tech Stack

- **Preact** — lightweight React alternative, used via `preact/compat` aliases
- **motion/react** (motion.dev) — declarative spring animations, imported as `motion/react` and works through `preact/compat`
- **Vite** with `@preact/preset-vite` — dev server and build tool
- **Plain CSS** — no framework, uses CSS custom properties

## Commands

- `npm run dev` — start dev server (localhost:5173)
- `npm run build` — production build to `dist/`
- `npm run preview` — preview production build

## Design Decisions

- **Theme**: Dark background (`#0a0a0a`) with Obsidian purple (`#7C3AED` / `#A855F7`) accents, white/gray text
- **Typography**: System font stack (`-apple-system, BlinkMacSystemFont, "SF Pro Display", ...`), 4-level hierarchy
- **Animations**: Staggered spring entrance — elements fade in and slide up sequentially using a shared `fade(delay)` helper
- **No images** other than the app icon (`public/icon.png`, copied from `mac256.png` in the Xcode asset catalog)
- **Screencast**: WebM + MP4 (H.264) `<video>` with autoplay, loop, muted, playsinline. Subtle purple glow border.
- **Responsive**: Three breakpoints — desktop (default), tablet (<=1024px), phone (<=480px). Goal is zero scroll on tablet, minimal scroll on phone.

## File Structure

```
website/
├── index.html              # HTML shell with OG + Twitter meta tags
├── package.json
├── vite.config.js           # Preact preset + react→preact/compat aliases
├── public/
│   ├── icon.png             # App icon (256px, from Xcode assets)
│   ├── screencast.mp4       # Demo video (H.264)
│   └── screencast.webm      # Demo video (WebM)
└── src/
    ├── main.jsx             # Preact mount point
    ├── app.jsx              # Single App component with all hero content
    └── style.css            # Global styles + CSS custom properties + responsive breakpoints
```

## TODO

- Download CTA (`href="#"`) needs a real link once releases are set up (GitHub Releases `.dmg`)
- OG image URLs need to be absolute once a domain is configured
