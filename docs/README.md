# LaunchDesk browser demo

This is a **static, standalone, browser-safe simulation** of the LaunchDesk Flutter Windows dashboard, using the screenshot layout as visual reference.

## Features

- Demo User identity for all visitors (no login or password collection)
- Dashboard, schedule, tasks, notes, journal, habits, activity, focus timer, website shortcuts and widgets
- Theme, accent, compact layout, timers and dashboard widget settings
- Automatic `localStorage` persistence; JSON backup/export/import; reset
- Responsive light/dark interface
- Official ChatGPT website link (not a third-party ChatGPT login)
- No backend or analytics

**What differs from the Windows app:** browsers cannot launch Windows executables or read the same live CPU/RAM counters. Demo Apps open only `http(s)` URLs in a new tab. Browser battery availability varies.

## Preview locally

Serve the `docs` directory instead of opening `index.html` directly, e.g.:

```cmd
python -m http.server 8765 --directory docs
```

Open http://localhost:8765/ in a browser. `localStorage` is scoped to the browser and site origin: it doesn't sync between visitors or devices.

## Publishing with GitHub Pages

The demo lives in `docs/` and includes a GitHub Actions Pages workflow. **The repository is currently private**; whether it can publish GitHub Pages depends on repository plan/settings. If the owner has Pages access:

1. Merge the web-demo PR into `main`.
2. Open **GitHub repository → Settings → Pages**.
3. Under **Build and deployment**, select **GitHub Actions**.
4. Run the **LaunchDesk Web Demo** workflow (or push to `main`) and confirm its Deploy job succeeds.
5. The expected Pages URL is `https://vamsikrishna1332-creator.github.io/WinLaunch/` if GitHub Pages is enabled and the domain/path hasn't been changed.

No publishing claim is made until the deploy workflow reports success. GitHub Pages content is publicly accessible even when its source repository is private, depending on the account and enterprise settings.

## Tests

```cmd
npm install --no-save @playwright/test
npx playwright install chromium
npx playwright test --config web-demo-tests/playwright.config.cjs
```

All demo state lives in `localStorage['launchdesk-web-demo-v1']`. Clearing site data clears the workspace.
