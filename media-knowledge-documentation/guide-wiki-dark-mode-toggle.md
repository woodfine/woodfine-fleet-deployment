---
schema: foundry-doc-v1
title: "Wiki Dark Mode Toggle — Deployment Integration"
slug: guide-wiki-dark-mode-toggle
type: guide
status: active
bcsc_class: customer-internal
last_edited: 2026-05-07
editor: pointsav-engineering
---

## Prerequisites

- `tokens.css` linked in `base.html` per `guide-wiki-design-tokens.md`.
- The dark-mode init script installed in `<head>` per `guide-wiki-design-tokens.md` Step 2.
- Write access to the deployment's template files (`templates/`).

## Purpose

This guide wires the PointSav dark mode toggle button into a Woodfine wiki deployment.
On completion, readers can switch between light and dark colour schemes; the choice
persists across page loads and respects the OS `prefers-color-scheme` preference when
no explicit choice has been stored.

## Procedure

### Step 1 — Add the toggle button to the site header template

In `templates/partials/header.html` (or the equivalent header partial), add:

```html
<button class="ps-wiki-dark-toggle"
        type="button"
        aria-pressed="false"
        aria-label="Switch to dark mode">
  <span class="ps-wiki-dark-toggle__icon" aria-hidden="true">🌙</span>
  <span class="ps-wiki-dark-toggle__label">Dark</span>
</button>
```

The button state (`aria-pressed`, `aria-label`, icon) is set correctly by the JavaScript
in Step 3. The HTML default of `aria-pressed="false"` is corrected before any visible
render because the init script in `<head>` sets the `data-theme` attribute
synchronously.

### Step 2 — Add toggle styles

Add to `static/wiki.css`:

```css
.ps-wiki-dark-toggle {
  display: inline-flex;
  align-items: center;
  gap: var(--ps-space-2);
  padding: var(--ps-space-2) var(--ps-space-3);
  background: var(--ps-interactive-ghost);
  color: var(--ps-ink-secondary);
  border: none;
  border-radius: var(--ps-corner-2);
  cursor: pointer;
  font-family: var(--font-sans);
  font-size: 0.875rem;
  transition: background var(--ps-speed-2) var(--ps-ease-utility);
}

.ps-wiki-dark-toggle:hover {
  background: var(--ps-interactive-ghost-hover);
}

.ps-wiki-dark-toggle:focus-visible {
  outline: var(--ps-focus-ring-width) solid var(--ps-focus-ring);
  outline-offset: var(--ps-focus-ring-offset);
}
```

### Step 3 — Add the toggle JavaScript

Create `static/wiki-theme.js` (or append to an existing JS bundle):

```javascript
(function () {
  var btn = document.querySelector('.ps-wiki-dark-toggle');
  if (!btn) return;

  function isDark() {
    return document.documentElement.dataset.theme === 'dark';
  }

  function syncButton() {
    var dark = isDark();
    btn.setAttribute('aria-pressed', String(dark));
    btn.setAttribute('aria-label', dark ? 'Switch to light mode' : 'Switch to dark mode');
    btn.querySelector('.ps-wiki-dark-toggle__icon').textContent = dark ? '☀' : '🌙';
    btn.querySelector('.ps-wiki-dark-toggle__label').textContent = dark ? 'Light' : 'Dark';
  }

  syncButton();

  btn.addEventListener('click', function () {
    var dark = isDark();
    document.documentElement.dataset.theme = dark ? '' : 'dark';
    localStorage.setItem('ps-theme', dark ? 'light' : 'dark');
    syncButton();
  });
})();
```

Add to `base.html` before `</body>`:

```html
<script src="/static/wiki-theme.js" defer></script>
```

## Expected Outcome

- The toggle button appears in the site header.
- Clicking switches the colour scheme instantly without a page reload.
- The chosen theme persists across page reloads (stored in `localStorage`).
- All dark mode colour pairs pass WCAG 2.1 AAA (verified 2026-05-06).

## Verification

Open the wiki and confirm:

1. Toggle button visible in the site header.
2. Click toggles colour scheme instantly.
3. Reload the page — chosen theme is preserved.
4. Remove `ps-theme` from localStorage; with OS dark mode on, wiki follows OS preference.
5. `aria-pressed` attribute on the button matches the current theme (verify via browser
   DevTools → Accessibility panel).

## Rollback

Remove the `<button class="ps-wiki-dark-toggle">` from the header template, the
`.ps-wiki-dark-toggle` CSS block from `static/wiki.css`, and the `wiki-theme.js` script
tag from `base.html`.
