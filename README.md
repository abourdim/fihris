# بِسْمِ ٱللَّهِ ٱلرَّحْمَٰنِ ٱلرَّحِيمِ

# فهرس · Fihris v2.0

**The Workshop-DIY App Catalog**

> 179 apps · 13 categories · 179 GitHub repos · 5 views · 1 file

---

## What is Fihris?

Fihris (فهرس) is an interactive catalog of every app built by [Workshop-DIY](https://workshop-diy.org) — 179 educational web apps for kids covering robotics, IoT, Arabic language, Islamic education, cybersecurity, networking, AI, and more.

The name comes from **كتاب الفهرست** (Kitab al-Fihrist) by Ibn al-Nadim (987 CE) — the first comprehensive catalog of books in the Islamic world.

---

## What's New in v2.0

**Auto-Sync** — `sync-fihris.sh` scans the repos directory, reads each README for descriptions, auto-detects categories, and regenerates the APPS array. No more manual updates.

**Islamic Books** — New 📚 category with 54 entries for al-Ghazali works and Islamic texts.

**Dynamic Stats** — App count, category count, and repo count are computed from data, not hardcoded.

**179 Apps** — Up from 102 in v1.0.

---

## 5 Views

| View | Icon | Description |
|------|------|-------------|
| **List** | 📋 | Clean categorized list with search and filters |
| **Cards** | 🃏 | Trading cards with flip animation (Alhambra borders) |
| **Periodic** | ⚗️ | Periodic table layout, color-coded by category |
| **Terminal** | 💻 | Hacker terminal — type `ls`, `cat`, `find`, `grep`, `stats` |
| **Galaxy** | 🌌 | Animated constellation map — apps are stars, categories are nebulae |

---

## Features

- **Live search** — filters instantly across all views
- **13 category filters** — click to toggle
- **Sound FX** — toggleable click/flip/beep sounds
- **Intro animation** — counter from 0 to 179
- **Export** — copy as Markdown, download CSV, print-friendly
- **Terminal** — full CLI with autocomplete (Tab), history (↑↓), 8 commands
- **Galaxy** — animated canvas with hover tooltips and click-to-open
- **Responsive** — works on mobile and desktop
- **Remembers** your preferred view (localStorage)
- **بِسْمِ ٱللَّهِ** — always present (intro, header, footer)

---

## Sync Script

Run this whenever repos are added, removed, or renamed:

```bash
cd ~/Desktop/00_work/apps/repos/fihris
bash sync-fihris.sh
```

The script:
1. Scans every folder in `../` (the repos directory)
2. Reads each repo's README.md for emoji, description, and status
3. Falls back to `<title>` from index.html if no README
4. Auto-detects category from repo name patterns
5. Checks `.git/config` for GitHub remote
6. Regenerates the `APPS` array in `index.html`

---

## Terminal Commands

```
ls [category]     List apps (all or by category)
cat <name>        Show app details
find <keyword>    Search by name
grep <keyword>    Search in descriptions
stats             Show statistics
open <name>       Open app on GitHub
categories        List all categories
clear             Clear terminal
help              Show commands
```

---

## Categories

| # | Category | Apps |
|---|----------|------|
| 🤖 | AI | 3 |
| 🕌 | Arabic & Islamic | 22 |
| 📚 | Islamic Books | 54 |
| 📸 | Camera | 2 |
| 🏫 | Classroom | 2 |
| 📚 | Education — Tech | 15 |
| 🎮 | Fun & Creative | 4 |
| 🔧 | Infra & Backend | 8 |
| 📦 | Meta & Project | 12 |
| 🤖 | micro:bit | 10 |
| 🌐 | Networking Labs | 13 |
| 💼 | Standalone Tools | 5 |
| 🛠️ | Tools | 29 |

---

## Quick Start

1. Open `index.html` in any browser
2. That's it — no server, no dependencies, no build step

---

## Tech Stack

- **HTML + CSS + JS** — single file, zero dependencies
- **Canvas API** — Galaxy view animation
- **Google Fonts** — Outfit, JetBrains Mono, Amiri
- **localStorage** — remembers view preference + intro skip
- **sync-fihris.sh** — Bash + Python for repo scanning and patching

---

## Links

- 🌐 [workshop-diy.org](https://workshop-diy.org)
- 🐙 [github.com/abourdim](https://github.com/abourdim)
- 📘 [Facebook — Workshop-DIY](https://www.facebook.com/WorkshopDIY)

---

## License

MIT — Built with ❤️ and Claude · March 2026

---

> *"Whoever takes a path seeking knowledge, Allah makes easy for him a path to Paradise."*
> — Prophet Muhammad ﷺ (Sahih Muslim)
