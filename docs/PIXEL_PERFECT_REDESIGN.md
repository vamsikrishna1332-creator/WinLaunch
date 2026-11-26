# LaunchDesk screenshot-matching redesign

Reference: the user's three uploaded screenshots (nine-screen collage and dashboard close-up). This document records the intended UI, not a claim that it has all been implemented.

## Layout
- Windows desktop, dark navy (#081321 / #0D1928), purple accent (#5B4AD8), green running-task status (#31C66A).
- Permanent ~190 px left sidebar: Dashboard, Schedule, Tasks, Notes, Apps, Focus Timer, Habits, Journal, Settings; profile footer.
- Narrow scrolling notice strip above dashboard content.
- Main dashboard: greeting + compact clock; running task and today's schedule side-by-side; focus timer, task overview and quick notes below; quick-launch row and battery/focus stats at bottom.
- Rounded dark cards, subtle borders, Segoe UI, compact 12–14 px text; no glitter or particle effects in the reference theme.
- Other eight pages match the corresponding screenshot collage panels. Do not substitute the old four-tab navigation.

## Authentication
- LaunchDesk profile login is a separate feature to implement. Existing UserProfile model is a local profile record, not secure authentication.
- ChatGPT entry opens https://chatgpt.com/ in the external browser. Users sign in on OpenAI's own site; never collect their passwords or session cookies.
- A ChatGPT subscription is not an API credential. Do not promise embedded ChatGPT account authentication without a supported OpenAI authorization flow.

## Non-regression requirements
- Preserve launcher shortcuts, settings and SQLite data across restarts.
- Verify widgets and navigation at 1280×720 and 1920×1080.
- Check pixel alignment against original reference assets, not phone screenshots with black margins.
- Run flutter analyze, flutter test and Windows build before claiming completion.
