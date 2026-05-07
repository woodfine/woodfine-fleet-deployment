---
schema: foundry-doc-v1
title: "Wiki Design Tokens — Deployment Integration"
slug: guide-wiki-design-tokens
type: guide
status: active
bcsc_class: customer-internal
last_edited: 2026-05-07
editor: pointsav-engineering
---

## Prerequisites

- Write access to the deployment's `static/` directory and Zola template files
  (`templates/`).
- The latest `tokens.css` from `vendor/pointsav-design-system/dist/tokens.css`.
- IBM Plex font files or access to Google Fonts (see Step 3).

## Purpose

This guide integrates the PointSav design token stylesheet into a Woodfine wiki
deployment. Follow when provisioning a new wiki instance or updating tokens after a
design-system release.

## Procedure

### Step 1 — Copy tokens.css to the deployment

```bash
cp vendor/pointsav-design-system/dist/tokens.css static/tokens.css
```

`tokens.css` is a generated file. Do not edit it directly. All token changes go through
the design-system source (`dtcg-vault/exports/tokens.full.json`) and must be promoted
through the design-system release process.

### Step 2 — Link tokens.css in the base template

In `templates/base.html`, add to `<head>` in this exact order:

```html
<head>
  <!-- Design tokens — must load before any component CSS -->
  <link rel="stylesheet" href="/static/tokens.css">

  <!-- Dark mode init script — must run before tokens.css renders -->
  <script>
    (function() {
      var stored = localStorage.getItem('ps-theme');
      var prefersDark = window.matchMedia('(prefers-color-scheme: dark)').matches;
      if (stored === 'dark' || (!stored && prefersDark)) {
        document.documentElement.dataset.theme = 'dark';
      }
    })();
  </script>

  <!-- Other stylesheets reference token vars — load after tokens.css -->
  <link rel="stylesheet" href="/static/wiki.css">
</head>
```

Order is load-order critical: `tokens.css` must appear before any stylesheet that
references `var(--ps-*)` custom properties. The dark-mode init script must appear before
`tokens.css` to prevent a flash of the light theme on dark-mode page loads.

### Step 3 — Add IBM Plex fonts

#### Option A — Self-hosted (recommended)

Download WOFF2 files from npm `@ibm/plex` or the IBM Plex GitHub repository. Place in
`static/fonts/`:

```
static/
  fonts/
    IBMPlexSans-Regular.woff2
    IBMPlexSans-SemiBold.woff2
    IBMPlexSans-Bold.woff2
    IBMPlexMono-Regular.woff2
    IBMPlexMono-Medium.woff2
```

Create `static/fonts.css`:

```css
@font-face {
  font-family: 'IBM Plex Sans';
  font-style: normal;
  font-weight: 400;
  font-display: swap;
  src: url('/static/fonts/IBMPlexSans-Regular.woff2') format('woff2');
}
@font-face {
  font-family: 'IBM Plex Sans';
  font-style: normal;
  font-weight: 600;
  font-display: swap;
  src: url('/static/fonts/IBMPlexSans-SemiBold.woff2') format('woff2');
}
@font-face {
  font-family: 'IBM Plex Sans';
  font-style: normal;
  font-weight: 700;
  font-display: swap;
  src: url('/static/fonts/IBMPlexSans-Bold.woff2') format('woff2');
}
@font-face {
  font-family: 'IBM Plex Mono';
  font-style: normal;
  font-weight: 400;
  font-display: swap;
  src: url('/static/fonts/IBMPlexMono-Regular.woff2') format('woff2');
}
@font-face {
  font-family: 'IBM Plex Mono';
  font-style: normal;
  font-weight: 500;
  font-display: swap;
  src: url('/static/fonts/IBMPlexMono-Medium.woff2') format('woff2');
}
```

Add to `base.html` before `tokens.css`:

```html
<link rel="stylesheet" href="/static/fonts.css">
```

#### Option B — Google Fonts CDN

For deployments where self-hosting is not available:

```html
<link rel="preconnect" href="https://fonts.googleapis.com">
<link rel="preconnect" href="https://fonts.gstatic.com" crossorigin>
<link href="https://fonts.googleapis.com/css2?family=IBM+Plex+Mono:wght@400;500&family=IBM+Plex+Sans:wght@400;500;600;700&display=swap" rel="stylesheet">
```

Note: Google Fonts requests are visible to Google's servers. Use Option A for
deployments with strict privacy requirements.

### Step 4 — Apply token variables in wiki CSS

In `static/wiki.css`, reference token aliases:

```css
body {
  font-family: var(--font-sans);
  font-size:   var(--ps-wiki-font-size-base);
  line-height: var(--leading-body);
  color:       var(--color-text-primary);
  background:  var(--color-surface-page);
}

.wiki-article {
  max-width: var(--measure);
}

h1 { font-size: var(--text-h1); }
h2 { font-size: var(--text-h2); }
h3 { font-size: var(--text-h3); }
h4 { font-size: var(--text-h4); }

code, pre {
  font-family: var(--font-mono);
  background:  var(--color-surface-code);
}

a { color: var(--color-text-link); }
a.redlink { color: var(--color-text-redlink); }
```

## Expected Outcome

- `tokens.css` is present at `static/tokens.css`.
- The wiki renders IBM Plex Sans for body text and IBM Plex Mono for code.
- Dark mode activates without a flash of the light theme.
- All `var(--ps-*)` references in `wiki.css` resolve correctly.

## Verification

```bash
# 1. Confirm tokens.css is present
ls static/tokens.css

# 2. Confirm font files are present (Option A)
ls static/fonts/IBMPlexSans-Regular.woff2
```

Open the wiki in a browser and:

1. Inspect `<head>` — confirm load order: `fonts.css` → `tokens.css` → init script →
   `wiki.css`.
2. Open DevTools → Computed → font-family on `body` — should show `IBM Plex Sans`.
3. Run `localStorage.setItem('ps-theme', 'dark')` in the console and reload — dark
   theme should load without a light-theme flash.

## Rollback

Remove `static/tokens.css`, `static/fonts.css`, and `static/fonts/`, and revert the
`<head>` block in `base.html` to its previous state.

## Updating Tokens

When a new `tokens.css` is released by the design system:

1. Copy the updated file: `cp vendor/pointsav-design-system/dist/tokens.css static/tokens.css`
2. Check `vendor/pointsav-design-system/CHANGELOG.md` for token renames or removals.
3. Search `static/wiki.css` for any removed token names and update them.
4. Commit: `git add static/tokens.css && commit-as-next.sh "tokens: update to design-system vX.X.X"`
