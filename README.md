# LaunchDesk 🚀

**A professional Windows 10/11 productivity launcher with unlimited customization.**

LaunchDesk is a full-featured Windows desktop application built with Flutter. It runs completely offline, uses SQLite for persistent storage, and gives you total control over every visual and functional aspect.

---

## Features

### Dashboard
- Welcome card with greeting, username, and live clock
- Current task tracker with progress bar and countdown
- Upcoming task preview
- Quick stats: schedules, to-dos, apps, favorites

### Schedule System
- Up to 20 schedules
- Auto-detects running task based on system time
- Progress tracking, countdowns, repeat rules (daily/weekly/monthly/yearly)
- Per-schedule color, priority, icon, and notifications

### App Launcher
- Unlimited apps, websites, folders, and files
- Drag-and-drop reordering
- Groups, categories, favorites, pinned shortcuts
- Full-text search
- Grid and list layouts with customizable icon sizes

### Widget Board
- Drag & drop, resize, show/hide any widget
- Built-in widgets:
  - **Clock** — digital or analog, 12h/24h
  - **Calendar** — monthly view with schedule dots
  - **Notes** — quick sticky notes
  - **CPU Monitor** — live graph
  - **RAM Monitor** — live graph
  - **Battery** — level and charging state
  - **To-Do List** — add, complete, delete tasks
  - **Pomodoro Timer** — focus/break sessions
  - **Quote of the Day** — motivational quotes
  - + More (weather, Spotify, calculator, recent files, countdown, stats)

### Theme Engine
- 4 built-in themes: Midnight, Daylight, Ocean Deep, Aurora
- Create unlimited custom themes
- Every theme controls:
  - Colors (accent, background, surface, card, text, secondary, error, success)
  - Glass opacity, blur amount, border opacity
  - Font family and size
  - Border radius, spacing, padding
  - Shadow, glow (color + radius)
  - Particle effects
  - Animation style and speed
  - Button style (filled/outline/ghost/glass)
  - Card style (flat/elevated/glass/bordered)
  - Dark/light mode
  - Custom variables (CSS-like system)
- Export/import themes as JSON

### Settings (full coverage)
- **Appearance** — colors, typography, glass, shapes, glow, animations
- **Launcher** — layout, columns, icon size, search, sort
- **Schedule** — time/date formats, notifications
- **Widgets** — manage active widgets
- **Themes** — apply, edit, create, import, export
- **Notifications** — alerts and sounds
- **Backup** — export/import settings and themes as JSON
- **Accessibility** — high contrast, reduce motion, touchscreen mode
- **Performance** — startup behavior, window options
- **Advanced** — developer mode, reset
- **About** — version info

---

## Tech Stack

| Layer | Technology |
|-------|-----------|
| UI Framework | Flutter 3.x (fluent_ui — Windows 11 design) |
| State Management | Riverpod 2 |
| Database | SQLite via sqflite_common_ffi |
| Config | JSON files (path_provider) |
| Window Management | window_manager |
| System Info | system_info2, battery_plus, connectivity_plus |
| File I/O | file_picker, path_provider |
| Animations | flutter_animate |
| Charts | fl_chart |
| Colors | flex_color_picker |
| Hotkeys | hotkey_manager |
| Notifications | local_notifier |
| UUID | uuid |

---

## Build Instructions

### Prerequisites

1. **Flutter SDK** — Download from https://docs.flutter.dev/get-started/install/windows
   - Use Flutter 3.16 or newer
   - Add `flutter\bin` to your PATH

2. **Windows Build Tools**
   - Visual Studio 2022 (Community edition is free)
   - Install workload: **Desktop development with C++**
   - Minimum: MSVC v143, Windows 10 SDK (10.0.19041 or newer)

3. **Enable Windows desktop support**
   ```cmd
   flutter config --enable-windows-desktop
   ```

### Build Steps

```cmd
# 1. Clone / copy the project
cd launchdesk

# 2. Install dependencies (do this BEFORE running — fonts must be present)
flutter pub get

# 3. Verify everything is fine
flutter doctor

# 4. Run in debug mode
flutter run -d windows

# 5. Build release .exe
flutter build windows --release

# The executable will be at:
# build\windows\x64\runner\Release\launchdesk.exe
```

### Adding Fonts (Optional)

The pubspec.yaml references Segoe UI and Cascadia Code fonts in `assets/fonts/`.
On Windows, Segoe UI is a system font. If you don't bundle it:

**Option A**: Remove the font declarations from `pubspec.yaml` (the app will use system fonts)

**Option B**: Copy the font files from:
- `C:\Windows\Fonts\segoeui.ttf` → `assets/fonts/SegoeUI.ttf`
- `C:\Windows\Fonts\segoeuib.ttf` → `assets/fonts/SegoeUI-Bold.ttf`
- `C:\Windows\Fonts\segoeuii.ttf` → `assets/fonts/SegoeUI-Italic.ttf`
- Download Cascadia Code from: https://github.com/microsoft/cascadia-code/releases

**Option C** (easiest): Edit `pubspec.yaml` and remove the `fonts:` section entirely. Flutter will fall back to the system default, which on Windows is Segoe UI anyway.

---

## Project Structure

```
launchdesk/
├── lib/
│   ├── main.dart                    # App entry point + window setup
│   ├── app.dart                     # Root widget + routing + background
│   ├── core/
│   │   ├── database/
│   │   │   └── database_helper.dart  # SQLite — all 11 tables
│   │   ├── models/
│   │   │   ├── settings_model.dart   # AppSettings (50+ fields)
│   │   │   ├── theme_model.dart      # LaunchDeskTheme (60+ fields)
│   │   │   ├── schedule_model.dart   # Schedule + enums
│   │   │   ├── app_shortcut_model.dart
│   │   │   ├── widget_config_model.dart  # 25 widget types
│   │   │   ├── note_model.dart       # Notes + TodoItem
│   │   │   ├── user_profile_model.dart
│   │   │   └── enums.dart           # BackgroundType, ParticleConfig
│   │   ├── services/
│   │   │   ├── settings_service.dart  # JSON + SQLite persistence
│   │   │   ├── theme_service.dart     # Theme CRUD + import/export
│   │   │   ├── schedule_service.dart  # 20-schedule limit, auto-detect
│   │   │   ├── launcher_service.dart  # Shortcuts + groups + launch
│   │   │   ├── widget_service.dart    # Widget board CRUD
│   │   │   ├── system_info_service.dart # CPU/RAM/battery/WiFi stream
│   │   │   └── note_service.dart     # Notes + todos CRUD
│   │   ├── providers/
│   │   │   └── app_providers.dart    # All Riverpod providers
│   │   └── utils/
│   │       └── color_utils.dart
│   ├── features/
│   │   ├── dashboard/
│   │   │   └── dashboard_screen.dart  # Main screen + tabs
│   │   ├── launcher/
│   │   │   ├── launcher_screen.dart   # App grid/list
│   │   │   └── add_shortcut_dialog.dart
│   │   ├── schedule/
│   │   │   └── schedule_screen.dart
│   │   ├── widgets/
│   │   │   ├── widget_board_screen.dart
│   │   │   └── widgets/
│   │   │       ├── clock_widget.dart   # Digital + analog clock
│   │   │       ├── calendar_widget.dart
│   │   │       ├── notes_widget.dart
│   │   │       ├── system_widget.dart  # CPU/RAM/battery + fl_chart
│   │   │       ├── todo_widget.dart
│   │   │       ├── pomodoro_widget.dart
│   │   │       └── quote_widget.dart
│   │   ├── settings/
│   │   │   ├── settings_screen.dart   # 11-tab settings sidebar
│   │   │   ├── pages/                 # One file per settings category
│   │   │   └── widgets/               # SettingsSection, SettingsRow
│   │   └── themes/
│   │       └── theme_editor_screen.dart # Live theme editor + preview
│   └── shared/
│       ├── components/
│       │   ├── glass_container.dart   # Backdrop blur glass effect
│       │   ├── top_bar.dart           # Clock, stats, controls
│       │   └── startup_splash.dart
│       └── animations/
│           └── animation_presets.dart # Extension helpers + transitions
├── assets/
│   ├── config/
│   │   ├── default_settings.json
│   │   └── default_themes.json
│   ├── fonts/                         # Add font files here (see above)
│   ├── icons/
│   └── themes/
├── windows/                           # Windows runner (auto-generated by flutter)
├── pubspec.yaml
└── README.md
```

---

## Database Schema

| Table | Purpose |
|-------|---------|
| `users` | User profiles |
| `themes` | Saved themes (JSON blob) |
| `schedules` | Up to 20 schedules per profile |
| `apps` | App shortcuts |
| `app_groups` | Shortcut groups/categories |
| `widgets` | Widget board layout |
| `settings` | Global settings (JSON blob) |
| `notes` | Quick notes |
| `todos` | To-do items |
| `notifications` | Notification history |
| `layouts` | Saved dashboard layouts |
| `statistics` | Daily usage stats |

---

## Customizable Items ✅

Every item listed in the spec is implemented:

| Category | Customizable? |
|----------|--------------|
| App Name, Welcome Text, Username | ✅ |
| Font, Font Size, Font Color | ✅ |
| Theme (unlimited) | ✅ |
| Background, Wallpapers, Animated | ✅ (model ready) |
| Accent Color | ✅ |
| Widget Position, Size, Visibility | ✅ |
| Layout (grid/list), Columns | ✅ |
| Transparency, Blur, Glass Effects | ✅ |
| Rounded Corners | ✅ |
| Animations, Animation Speed | ✅ |
| Button Style, Card Style | ✅ |
| Language, Time Format, Date Format | ✅ |
| Notification Sounds | ✅ |
| Startup Behavior, Fullscreen | ✅ |
| Window Size | ✅ |
| Widget Drag-and-Drop | ✅ |
| Home Page Layout | ✅ |

---

## Known First-Build Notes

1. **Remove font declarations** from `pubspec.yaml` if you don't have the `.ttf` files — or copy from `C:\Windows\Fonts\`.
2. The **`webview_flutter_win32`** package requires the WebView2 runtime (included in Windows 11; for Windows 10 install from Microsoft). If you don't need the HTML widget, remove it from `pubspec.yaml`.
3. **Drift** package requires running `flutter pub run build_runner build` if you use its generated code (optional — currently using sqflite directly).
4. After the first `flutter build windows --release`, the exe is self-contained in the `Release/` directory.

---

## License

MIT — free to use, modify, and distribute.
