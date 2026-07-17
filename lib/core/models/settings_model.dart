
class AppSettings {
  final String appName;
  final String welcomeText;
  final String username;
  final String language;
  final String timeFormat;
  final String dateFormat;
  final String fontFamily;
  final double fontSize;
  final int fontColor;
  final bool startFullscreen;
  final bool startMaximized;
  final bool customTitleBar;
  final bool showTopBar;
  final bool showClock;
  final bool showDate;
  final bool showBattery;
  final bool showCpu;
  final bool showRam;
  final bool showWifi;
  final bool showBluetooth;
  final bool showWeather;
  final int windowWidth;
  final int windowHeight;
  final String activeThemeId;
  final String activeProfileId;
  final bool enableAnimations;
  final bool enableSounds;
  final bool enableNotifications;
  final bool enableHotkeys;
  final bool developerMode;
  final bool enableTouchscreen;
  final double uiScale;
  final bool highContrast;
  final bool reduceMotion;
  final String launcherLayout; // 'grid' | 'list'
  final int launcherColumns;
  final double launcherIconSize;
  final bool showLauncherLabels;
  final bool enableSearch;
  final String sortOrder; // 'name' | 'custom' | 'recent'
  final bool autoSave;
  final String backupPath;
  final bool enableAutoBackup;
  final int backupIntervalDays;
  // Notice bar — up to 5 items
  final bool showNoticeBar;
  final List<String> notices;

  const AppSettings({
    this.appName = 'LaunchDesk',
    this.welcomeText = 'Welcome',
    this.username = 'User',
    this.language = 'en',
    this.timeFormat = 'HH:mm',
    this.dateFormat = 'EEEE, MMMM d',
    this.fontFamily = 'Segoe UI',
    this.fontSize = 14.0,
    this.fontColor = 0xFFFFFFFF,
    this.startFullscreen = false,
    this.startMaximized = true,
    this.customTitleBar = true,
    this.showTopBar = true,
    this.showClock = true,
    this.showDate = true,
    this.showBattery = true,
    this.showCpu = true,
    this.showRam = true,
    this.showWifi = true,
    this.showBluetooth = false,
    this.showWeather = false,
    this.windowWidth = 1280,
    this.windowHeight = 800,
    this.activeThemeId = 'default_dark',
    this.activeProfileId = 'default',
    this.enableAnimations = true,
    this.enableSounds = true,
    this.enableNotifications = true,
    this.enableHotkeys = true,
    this.developerMode = false,
    this.enableTouchscreen = false,
    this.uiScale = 1.0,
    this.highContrast = false,
    this.reduceMotion = false,
    this.launcherLayout = 'grid',
    this.launcherColumns = 6,
    this.launcherIconSize = 64.0,
    this.showLauncherLabels = true,
    this.enableSearch = true,
    this.sortOrder = 'custom',
    this.autoSave = true,
    this.backupPath = '',
    this.enableAutoBackup = false,
    this.backupIntervalDays = 7,
    this.showNoticeBar = false,
    this.notices = const [],
  });

  AppSettings copyWith({
    String? appName,
    String? welcomeText,
    String? username,
    String? language,
    String? timeFormat,
    String? dateFormat,
    String? fontFamily,
    double? fontSize,
    int? fontColor,
    bool? startFullscreen,
    bool? startMaximized,
    bool? customTitleBar,
    bool? showTopBar,
    bool? showClock,
    bool? showDate,
    bool? showBattery,
    bool? showCpu,
    bool? showRam,
    bool? showWifi,
    bool? showBluetooth,
    bool? showWeather,
    int? windowWidth,
    int? windowHeight,
    String? activeThemeId,
    String? activeProfileId,
    bool? enableAnimations,
    bool? enableSounds,
    bool? enableNotifications,
    bool? enableHotkeys,
    bool? developerMode,
    bool? enableTouchscreen,
    double? uiScale,
    bool? highContrast,
    bool? reduceMotion,
    String? launcherLayout,
    int? launcherColumns,
    double? launcherIconSize,
    bool? showLauncherLabels,
    bool? enableSearch,
    String? sortOrder,
    bool? autoSave,
    String? backupPath,
    bool? enableAutoBackup,
    int? backupIntervalDays,
    bool? showNoticeBar,
    List<String>? notices,
  }) {
    return AppSettings(
      appName: appName ?? this.appName,
      welcomeText: welcomeText ?? this.welcomeText,
      username: username ?? this.username,
      language: language ?? this.language,
      timeFormat: timeFormat ?? this.timeFormat,
      dateFormat: dateFormat ?? this.dateFormat,
      fontFamily: fontFamily ?? this.fontFamily,
      fontSize: fontSize ?? this.fontSize,
      fontColor: fontColor ?? this.fontColor,
      startFullscreen: startFullscreen ?? this.startFullscreen,
      startMaximized: startMaximized ?? this.startMaximized,
      customTitleBar: customTitleBar ?? this.customTitleBar,
      showTopBar: showTopBar ?? this.showTopBar,
      showClock: showClock ?? this.showClock,
      showDate: showDate ?? this.showDate,
      showBattery: showBattery ?? this.showBattery,
      showCpu: showCpu ?? this.showCpu,
      showRam: showRam ?? this.showRam,
      showWifi: showWifi ?? this.showWifi,
      showBluetooth: showBluetooth ?? this.showBluetooth,
      showWeather: showWeather ?? this.showWeather,
      windowWidth: windowWidth ?? this.windowWidth,
      windowHeight: windowHeight ?? this.windowHeight,
      activeThemeId: activeThemeId ?? this.activeThemeId,
      activeProfileId: activeProfileId ?? this.activeProfileId,
      enableAnimations: enableAnimations ?? this.enableAnimations,
      enableSounds: enableSounds ?? this.enableSounds,
      enableNotifications: enableNotifications ?? this.enableNotifications,
      enableHotkeys: enableHotkeys ?? this.enableHotkeys,
      developerMode: developerMode ?? this.developerMode,
      enableTouchscreen: enableTouchscreen ?? this.enableTouchscreen,
      uiScale: uiScale ?? this.uiScale,
      highContrast: highContrast ?? this.highContrast,
      reduceMotion: reduceMotion ?? this.reduceMotion,
      launcherLayout: launcherLayout ?? this.launcherLayout,
      launcherColumns: launcherColumns ?? this.launcherColumns,
      launcherIconSize: launcherIconSize ?? this.launcherIconSize,
      showLauncherLabels: showLauncherLabels ?? this.showLauncherLabels,
      enableSearch: enableSearch ?? this.enableSearch,
      sortOrder: sortOrder ?? this.sortOrder,
      autoSave: autoSave ?? this.autoSave,
      backupPath: backupPath ?? this.backupPath,
      enableAutoBackup: enableAutoBackup ?? this.enableAutoBackup,
      backupIntervalDays: backupIntervalDays ?? this.backupIntervalDays,
      showNoticeBar: showNoticeBar ?? this.showNoticeBar,
      notices: notices ?? this.notices,
    );
  }

  factory AppSettings.fromJson(Map<String, dynamic> json) => AppSettings(
        appName: json['appName'] ?? 'LaunchDesk',
        welcomeText: json['welcomeText'] ?? 'Welcome',
        username: json['username'] ?? 'User',
        language: json['language'] ?? 'en',
        timeFormat: json['timeFormat'] ?? 'HH:mm',
        dateFormat: json['dateFormat'] ?? 'EEEE, MMMM d',
        fontFamily: json['fontFamily'] ?? 'Segoe UI',
        fontSize: (json['fontSize'] ?? 14.0).toDouble(),
        fontColor: json['fontColor'] ?? 0xFFFFFFFF,
        startFullscreen: json['startFullscreen'] ?? false,
        startMaximized: json['startMaximized'] ?? true,
        customTitleBar: json['customTitleBar'] ?? true,
        showTopBar: json['showTopBar'] ?? true,
        showClock: json['showClock'] ?? true,
        showDate: json['showDate'] ?? true,
        showBattery: json['showBattery'] ?? true,
        showCpu: json['showCpu'] ?? true,
        showRam: json['showRam'] ?? true,
        showWifi: json['showWifi'] ?? true,
        showBluetooth: json['showBluetooth'] ?? false,
        showWeather: json['showWeather'] ?? false,
        windowWidth: json['windowWidth'] ?? 1280,
        windowHeight: json['windowHeight'] ?? 800,
        activeThemeId: json['activeThemeId'] ?? 'default_dark',
        activeProfileId: json['activeProfileId'] ?? 'default',
        enableAnimations: json['enableAnimations'] ?? true,
        enableSounds: json['enableSounds'] ?? true,
        enableNotifications: json['enableNotifications'] ?? true,
        enableHotkeys: json['enableHotkeys'] ?? true,
        developerMode: json['developerMode'] ?? false,
        enableTouchscreen: json['enableTouchscreen'] ?? false,
        uiScale: (json['uiScale'] ?? 1.0).toDouble(),
        highContrast: json['highContrast'] ?? false,
        reduceMotion: json['reduceMotion'] ?? false,
        launcherLayout: json['launcherLayout'] ?? 'grid',
        launcherColumns: json['launcherColumns'] ?? 6,
        launcherIconSize: (json['launcherIconSize'] ?? 64.0).toDouble(),
        showLauncherLabels: json['showLauncherLabels'] ?? true,
        enableSearch: json['enableSearch'] ?? true,
        sortOrder: json['sortOrder'] ?? 'custom',
        autoSave: json['autoSave'] ?? true,
        backupPath: json['backupPath'] ?? '',
        enableAutoBackup: json['enableAutoBackup'] ?? false,
        backupIntervalDays: json['backupIntervalDays'] ?? 7,
        showNoticeBar: json['showNoticeBar'] ?? false,
        notices: (json['notices'] as List<dynamic>?)
                ?.map((e) => e.toString())
                .take(5)
                .toList() ??
            const [],
      );

  Map<String, dynamic> toJson() => {
        'appName': appName,
        'welcomeText': welcomeText,
        'username': username,
        'language': language,
        'timeFormat': timeFormat,
        'dateFormat': dateFormat,
        'fontFamily': fontFamily,
        'fontSize': fontSize,
        'fontColor': fontColor,
        'startFullscreen': startFullscreen,
        'startMaximized': startMaximized,
        'customTitleBar': customTitleBar,
        'showTopBar': showTopBar,
        'showClock': showClock,
        'showDate': showDate,
        'showBattery': showBattery,
        'showCpu': showCpu,
        'showRam': showRam,
        'showWifi': showWifi,
        'showBluetooth': showBluetooth,
        'showWeather': showWeather,
        'windowWidth': windowWidth,
        'windowHeight': windowHeight,
        'activeThemeId': activeThemeId,
        'activeProfileId': activeProfileId,
        'enableAnimations': enableAnimations,
        'enableSounds': enableSounds,
        'enableNotifications': enableNotifications,
        'enableHotkeys': enableHotkeys,
        'developerMode': developerMode,
        'enableTouchscreen': enableTouchscreen,
        'uiScale': uiScale,
        'highContrast': highContrast,
        'reduceMotion': reduceMotion,
        'launcherLayout': launcherLayout,
        'launcherColumns': launcherColumns,
        'launcherIconSize': launcherIconSize,
        'showLauncherLabels': showLauncherLabels,
        'enableSearch': enableSearch,
        'sortOrder': sortOrder,
        'autoSave': autoSave,
        'backupPath': backupPath,
        'enableAutoBackup': enableAutoBackup,
        'backupIntervalDays': backupIntervalDays,
        'showNoticeBar': showNoticeBar,
        'notices': notices,
      };
}
