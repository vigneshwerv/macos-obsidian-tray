import { motion } from "motion/react";

const fade = (delay) => ({
  initial: { opacity: 0, y: 20 },
  animate: { opacity: 1, y: 0 },
  transition: {
    type: "spring",
    stiffness: 80,
    damping: 20,
    delay,
  },
});

export function App() {
  return (
    <>
      <motion.a
        href="https://github.com/vigneshwerv/macos-obsidian-tray"
        target="_blank"
        rel="noopener noreferrer"
        class="github-link"
        initial={{ opacity: 0 }}
        animate={{ opacity: 1 }}
        transition={{ delay: 0.5, duration: 0.4 }}
        aria-label="GitHub"
      >
        <svg viewBox="0 0 24 24" fill="currentColor">
          <path d="M12 0C5.37 0 0 5.37 0 12c0 5.31 3.435 9.795 8.205 11.385.6.105.825-.255.825-.57 0-.285-.015-1.23-.015-2.235-3.015.555-3.795-.735-4.035-1.41-.135-.345-.72-1.41-1.23-1.695-.42-.225-1.02-.78-.015-.795.945-.015 1.62.87 1.845 1.23 1.08 1.815 2.805 1.305 3.495.99.105-.78.42-1.305.765-1.605-2.67-.3-5.46-1.335-5.46-5.925 0-1.305.465-2.385 1.23-3.225-.12-.3-.54-1.53.12-3.18 0 0 1.005-.315 3.3 1.23.96-.27 1.98-.405 3-.405s2.04.135 3 .405c2.295-1.56 3.3-1.23 3.3-1.23.66 1.65.24 2.88.12 3.18.765.84 1.23 1.905 1.23 3.225 0 4.605-2.805 5.625-5.475 5.925.435.375.81 1.095.81 2.22 0 1.605-.015 2.895-.015 3.3 0 .315.225.69.825.57A12.02 12.02 0 0 0 24 12c0-6.63-5.37-12-12-12z" />
        </svg>
      </motion.a>
      <main>
      <motion.img
        src="/icon.png"
        alt="Obsidian Tray icon"
        class="icon"
        {...fade(0)}
      />

      <motion.p class="app-name" {...fade(0.08)}>
        Obsidian Tray
      </motion.p>

      <motion.h1 {...fade(0.16)}>
        Capture thoughts <em>instantly</em> from anywhere on your Mac
      </motion.h1>

      <motion.div class="demo" {...fade(0.24)}>
        <video autoplay loop muted playsinline>
          <source src="/screencast.webm" type="video/webm" />
          <source src="/screencast.mp4" type="video/mp4" />
        </video>
      </motion.div>

      <motion.a href="#" class="cta" {...fade(0.32)}>
        <svg
          xmlns="http://www.w3.org/2000/svg"
          viewBox="0 0 24 24"
          fill="none"
          stroke="currentColor"
          stroke-width="2"
          stroke-linecap="round"
          stroke-linejoin="round"
        >
          <path d="M21 15v4a2 2 0 0 1-2 2H5a2 2 0 0 1-2-2v-4" />
          <polyline points="7 10 12 15 17 10" />
          <line x1="12" y1="15" x2="12" y2="3" />
        </svg>
        Download for Mac
      </motion.a>

      <motion.p class="note" {...fade(0.4)}>
        Requires macOS 13 or later
      </motion.p>

      <motion.div class="hotkey" {...fade(0.48)}>
        Press <kbd>&#8984;</kbd> <kbd>&#8679;</kbd> <kbd>N</kbd> to capture from
        anywhere
      </motion.div>
    </main>
    </>
  );
}
