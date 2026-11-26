import 'package:fluent_ui/fluent_ui.dart';
import 'enums.dart';

class LaunchDeskTheme {
  final String id;
  final String name;
  final String description;
  final String author;
  final String version;
  final DateTime createdAt;
  final DateTime updatedAt;

  // Colors
  final int backgroundColor;
  final int surfaceColor;
  final int cardColor;
  final int accentColor;
  final int textColor;
  final int secondaryTextColor;
  final int borderColor;
  final int errorColor;
  final int successColor;
  final int warningColor;
  final List<int> gradientColors;

  // Background
  final BackgroundType backgroundType;
  final String? backgroundImagePath;
  final String? backgroundVideoPath;
  final String? backgroundGifPath;
  final double backgroundOpacity;
  final bool backgroundBlur;
  final double blurAmount;

  // Glass effect
  final bool enableGlass;
  final double glassOpacity;
  final double glassBorderOpacity;
  final int glassTint;

  // Typography
  final String fontFamily;
  final double baseFontSize;
  final String fontWeight;

  // Shapes
  final double borderRadius;
  final double cardBorderRadius;
  final double buttonBorderRadius;

  // Spacing
  final double spacing;
  final double margin;
  final double padding;
  final double cardPadding;

  // Shadows & Glow
  final bool enableShadow;
  final double shadowBlur;
  final int shadowColor;
  final bool enableGlow;
  final double glowRadius;
  final int glowColor;

  // Animations
  final String animationStyle; // 'material' | 'windows' | 'custom' | 'none'
  final double animationSpeed;
  final bool enableParticles;
  final Map<String, dynamic> particleConfig;

  // Scrollbar
  final String scrollbarStyle; // 'fluent' | 'thin' | 'none'
  final int scrollbarColor;

  // Button style
  final String buttonStyle; // 'filled' | 'outline' | 'ghost' | 'glass'

  // Card style
  final String cardStyle; // 'flat' | 'elevated' | 'glass' | 'bordered'

  // Icon pack
  final String iconPack;

  // Window
  final double windowOpacity;
  final bool enableWindowBlur;

  // Dark/light
  final bool isDark;

  // Custom variables for CSS-like system
  final Map<String, String> customVariables;

  // Thumbnail (base64 or path)
  final String? thumbnail;

  const LaunchDeskTheme({
    required this.id,
    required this.name,
    this.description = '',
    this.author = 'User',
    this.version = '1.0.0',
    required this.createdAt,
    required this.updatedAt,
    this.backgroundColor = 0xFF1A1A2E,
    this.surfaceColor = 0xFF16213E,
    this.cardColor = 0xFF0F3460,
    this.accentColor = 0xFF0078D4,
    this.textColor = 0xFFFFFFFF,
    this.secondaryTextColor = 0xFFAAAAAA,
    this.borderColor = 0xFF444444,
    this.errorColor = 0xFFCF6679,
    this.successColor = 0xFF6BCB77,
    this.warningColor = 0xFFFFD166,
    this.gradientColors = const [0xFF1A1A2E, 0xFF16213E],
    this.backgroundType = BackgroundType.gradient,
    this.backgroundImagePath,
    this.backgroundVideoPath,
    this.backgroundGifPath,
    this.backgroundOpacity = 1.0,
    this.backgroundBlur = false,
    this.blurAmount = 10.0,
    this.enableGlass = true,
    this.glassOpacity = 0.15,
    this.glassBorderOpacity = 0.3,
    this.glassTint = 0xFFFFFFFF,
    this.fontFamily = 'Segoe UI',
    this.baseFontSize = 14.0,
    this.fontWeight = 'normal',
    this.borderRadius = 12.0,
    this.cardBorderRadius = 12.0,
    this.buttonBorderRadius = 8.0,
    this.spacing = 8.0,
    this.margin = 16.0,
    this.padding = 16.0,
    this.cardPadding = 16.0,
    this.enableShadow = true,
    this.shadowBlur = 20.0,
    this.shadowColor = 0x44000000,
    this.enableGlow = false,
    this.glowRadius = 10.0,
    this.glowColor = 0xFF0078D4,
    this.animationStyle = 'windows',
    this.animationSpeed = 1.0,
    this.enableParticles = false,
    this.particleConfig = const {},
    this.scrollbarStyle = 'fluent',
    this.scrollbarColor = 0xFF888888,
    this.buttonStyle = 'filled',
    this.cardStyle = 'glass',
    this.iconPack = 'fluent',
    this.windowOpacity = 1.0,
    this.enableWindowBlur = true,
    this.isDark = true,
    this.customVariables = const {},
    this.thumbnail,
  });

  Color get backgroundColorObj => Color(backgroundColor);
  Color get surfaceColorObj => Color(surfaceColor);
  Color get cardColorObj => Color(cardColor);
  Color get accentColorObj => Color(accentColor);
  Color get textColorObj => Color(textColor);
  Color get secondaryTextColorObj => Color(secondaryTextColor);

  AccentColor get fluentAccent {
    final base = Color(accentColor);
    return AccentColor.swatch({
      'darkest': base.withOpacity(0.4),
      'darker': base.withOpacity(0.6),
      'dark': base.withOpacity(0.8),
      'normal': base,
      'light': base.withOpacity(0.85),
      'lighter': base.withOpacity(0.7),
      'lightest': base.withOpacity(0.5),
    });
  }

  ThemeMode get themeMode => isDark ? ThemeMode.dark : ThemeMode.light;

  FluentThemeData toFluentTheme() {
    final accent = fluentAccent;
    return FluentThemeData(
      brightness: isDark ? Brightness.dark : Brightness.light,
      accentColor: accent,
      scaffoldBackgroundColor: Colors.transparent,
      cardColor: Color(cardColor).withOpacity(glassOpacity + 0.05),
      fontFamily: fontFamily,
      micaBackgroundColor: Color(backgroundColor),
    );
  }

  LaunchDeskTheme copyWith({
    String? id,
    String? name,
    String? description,
    String? author,
    int? backgroundColor,
    int? surfaceColor,
    int? cardColor,
    int? accentColor,
    int? textColor,
    int? secondaryTextColor,
    BackgroundType? backgroundType,
    String? backgroundImagePath,
    double? backgroundOpacity,
    bool? backgroundBlur,
    double? blurAmount,
    bool? enableGlass,
    double? glassOpacity,
    double? glassBorderOpacity,
    String? fontFamily,
    double? baseFontSize,
    double? borderRadius,
    double? cardBorderRadius,
    double? spacing,
    double? margin,
    double? padding,
    bool? enableShadow,
    bool? enableGlow,
    int? glowColor,
    double? glowRadius,
    String? animationStyle,
    double? animationSpeed,
    bool? enableParticles,
    Map<String, dynamic>? particleConfig,
    String? buttonStyle,
    String? cardStyle,
    String? iconPack,
    double? windowOpacity,
    bool? isDark,
    Map<String, String>? customVariables,
    String? thumbnail,
    List<int>? gradientColors,
  }) {
    return LaunchDeskTheme(
      id: id ?? this.id,
      name: name ?? this.name,
      description: description ?? this.description,
      author: author ?? this.author,
      version: version,
      createdAt: createdAt,
      updatedAt: DateTime.now(),
      backgroundColor: backgroundColor ?? this.backgroundColor,
      surfaceColor: surfaceColor ?? this.surfaceColor,
      cardColor: cardColor ?? this.cardColor,
      accentColor: accentColor ?? this.accentColor,
      textColor: textColor ?? this.textColor,
      secondaryTextColor: secondaryTextColor ?? this.secondaryTextColor,
      borderColor: borderColor,
      errorColor: errorColor,
      successColor: successColor,
      warningColor: warningColor,
      gradientColors: gradientColors ?? this.gradientColors,
      backgroundType: backgroundType ?? this.backgroundType,
      backgroundImagePath: backgroundImagePath ?? this.backgroundImagePath,
      backgroundVideoPath: backgroundVideoPath,
      backgroundGifPath: backgroundGifPath,
      backgroundOpacity: backgroundOpacity ?? this.backgroundOpacity,
      backgroundBlur: backgroundBlur ?? this.backgroundBlur,
      blurAmount: blurAmount ?? this.blurAmount,
      enableGlass: enableGlass ?? this.enableGlass,
      glassOpacity: glassOpacity ?? this.glassOpacity,
      glassBorderOpacity: glassBorderOpacity ?? this.glassBorderOpacity,
      glassTint: glassTint,
      fontFamily: fontFamily ?? this.fontFamily,
      baseFontSize: baseFontSize ?? this.baseFontSize,
      fontWeight: fontWeight,
      borderRadius: borderRadius ?? this.borderRadius,
      cardBorderRadius: cardBorderRadius ?? this.cardBorderRadius,
      buttonBorderRadius: buttonBorderRadius,
      spacing: spacing ?? this.spacing,
      margin: margin ?? this.margin,
      padding: padding ?? this.padding,
      cardPadding: cardPadding,
      enableShadow: enableShadow ?? this.enableShadow,
      shadowBlur: shadowBlur,
      shadowColor: shadowColor,
      enableGlow: enableGlow ?? this.enableGlow,
      glowRadius: glowRadius ?? this.glowRadius,
      glowColor: glowColor ?? this.glowColor,
      animationStyle: animationStyle ?? this.animationStyle,
      animationSpeed: animationSpeed ?? this.animationSpeed,
      enableParticles: enableParticles ?? this.enableParticles,
      particleConfig: particleConfig ?? this.particleConfig,
      scrollbarStyle: scrollbarStyle,
      scrollbarColor: scrollbarColor,
      buttonStyle: buttonStyle ?? this.buttonStyle,
      cardStyle: cardStyle ?? this.cardStyle,
      iconPack: iconPack ?? this.iconPack,
      windowOpacity: windowOpacity ?? this.windowOpacity,
      enableWindowBlur: enableWindowBlur,
      isDark: isDark ?? this.isDark,
      customVariables: customVariables ?? this.customVariables,
      thumbnail: thumbnail ?? this.thumbnail,
    );
  }

  factory LaunchDeskTheme.fromJson(Map<String, dynamic> json) {
    return LaunchDeskTheme(
      id: json['id'],
      name: json['name'],
      description: json['description'] ?? '',
      author: json['author'] ?? 'User',
      version: json['version'] ?? '1.0.0',
      createdAt: DateTime.tryParse(json['createdAt'] ?? '') ?? DateTime.now(),
      updatedAt: DateTime.tryParse(json['updatedAt'] ?? '') ?? DateTime.now(),
      backgroundColor: json['backgroundColor'] ?? 0xFF1A1A2E,
      surfaceColor: json['surfaceColor'] ?? 0xFF16213E,
      cardColor: json['cardColor'] ?? 0xFF0F3460,
      accentColor: json['accentColor'] ?? 0xFF0078D4,
      textColor: json['textColor'] ?? 0xFFFFFFFF,
      secondaryTextColor: json['secondaryTextColor'] ?? 0xFFAAAAAA,
      borderColor: json['borderColor'] ?? 0xFF444444,
      errorColor: json['errorColor'] ?? 0xFFCF6679,
      successColor: json['successColor'] ?? 0xFF6BCB77,
      warningColor: json['warningColor'] ?? 0xFFFFD166,
      gradientColors: (json['gradientColors'] as List<dynamic>?)
              ?.map((e) => e as int)
              .toList() ??
          [0xFF1A1A2E, 0xFF16213E],
      backgroundType: BackgroundType.values.firstWhere(
        (e) => e.name == json['backgroundType'],
        orElse: () => BackgroundType.gradient,
      ),
      backgroundImagePath: json['backgroundImagePath'],
      backgroundVideoPath: json['backgroundVideoPath'],
      backgroundGifPath: json['backgroundGifPath'],
      backgroundOpacity: (json['backgroundOpacity'] ?? 1.0).toDouble(),
      backgroundBlur: json['backgroundBlur'] ?? false,
      blurAmount: (json['blurAmount'] ?? 10.0).toDouble(),
      enableGlass: json['enableGlass'] ?? true,
      glassOpacity: (json['glassOpacity'] ?? 0.15).toDouble(),
      glassBorderOpacity: (json['glassBorderOpacity'] ?? 0.3).toDouble(),
      glassTint: json['glassTint'] ?? 0xFFFFFFFF,
      fontFamily: json['fontFamily'] ?? 'Segoe UI',
      baseFontSize: (json['baseFontSize'] ?? 14.0).toDouble(),
      fontWeight: json['fontWeight'] ?? 'normal',
      borderRadius: (json['borderRadius'] ?? 12.0).toDouble(),
      cardBorderRadius: (json['cardBorderRadius'] ?? 12.0).toDouble(),
      buttonBorderRadius: (json['buttonBorderRadius'] ?? 8.0).toDouble(),
      spacing: (json['spacing'] ?? 8.0).toDouble(),
      margin: (json['margin'] ?? 16.0).toDouble(),
      padding: (json['padding'] ?? 16.0).toDouble(),
      cardPadding: (json['cardPadding'] ?? 16.0).toDouble(),
      enableShadow: json['enableShadow'] ?? true,
      shadowBlur: (json['shadowBlur'] ?? 20.0).toDouble(),
      shadowColor: json['shadowColor'] ?? 0x44000000,
      enableGlow: json['enableGlow'] ?? false,
      glowRadius: (json['glowRadius'] ?? 10.0).toDouble(),
      glowColor: json['glowColor'] ?? 0xFF0078D4,
      animationStyle: json['animationStyle'] ?? 'windows',
      animationSpeed: (json['animationSpeed'] ?? 1.0).toDouble(),
      enableParticles: json['enableParticles'] ?? false,
      particleConfig:
          Map<String, dynamic>.from(json['particleConfig'] ?? {}),
      scrollbarStyle: json['scrollbarStyle'] ?? 'fluent',
      scrollbarColor: json['scrollbarColor'] ?? 0xFF888888,
      buttonStyle: json['buttonStyle'] ?? 'filled',
      cardStyle: json['cardStyle'] ?? 'glass',
      iconPack: json['iconPack'] ?? 'fluent',
      windowOpacity: (json['windowOpacity'] ?? 1.0).toDouble(),
      enableWindowBlur: json['enableWindowBlur'] ?? true,
      isDark: json['isDark'] ?? true,
      customVariables:
          Map<String, String>.from(json['customVariables'] ?? {}),
      thumbnail: json['thumbnail'],
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'name': name,
        'description': description,
        'author': author,
        'version': version,
        'createdAt': createdAt.toIso8601String(),
        'updatedAt': updatedAt.toIso8601String(),
        'backgroundColor': backgroundColor,
        'surfaceColor': surfaceColor,
        'cardColor': cardColor,
        'accentColor': accentColor,
        'textColor': textColor,
        'secondaryTextColor': secondaryTextColor,
        'borderColor': borderColor,
        'errorColor': errorColor,
        'successColor': successColor,
        'warningColor': warningColor,
        'gradientColors': gradientColors,
        'backgroundType': backgroundType.name,
        'backgroundImagePath': backgroundImagePath,
        'backgroundVideoPath': backgroundVideoPath,
        'backgroundGifPath': backgroundGifPath,
        'backgroundOpacity': backgroundOpacity,
        'backgroundBlur': backgroundBlur,
        'blurAmount': blurAmount,
        'enableGlass': enableGlass,
        'glassOpacity': glassOpacity,
        'glassBorderOpacity': glassBorderOpacity,
        'glassTint': glassTint,
        'fontFamily': fontFamily,
        'baseFontSize': baseFontSize,
        'fontWeight': fontWeight,
        'borderRadius': borderRadius,
        'cardBorderRadius': cardBorderRadius,
        'buttonBorderRadius': buttonBorderRadius,
        'spacing': spacing,
        'margin': margin,
        'padding': padding,
        'cardPadding': cardPadding,
        'enableShadow': enableShadow,
        'shadowBlur': shadowBlur,
        'shadowColor': shadowColor,
        'enableGlow': enableGlow,
        'glowRadius': glowRadius,
        'glowColor': glowColor,
        'animationStyle': animationStyle,
        'animationSpeed': animationSpeed,
        'enableParticles': enableParticles,
        'particleConfig': particleConfig,
        'scrollbarStyle': scrollbarStyle,
        'scrollbarColor': scrollbarColor,
        'buttonStyle': buttonStyle,
        'cardStyle': cardStyle,
        'iconPack': iconPack,
        'windowOpacity': windowOpacity,
        'enableWindowBlur': enableWindowBlur,
        'isDark': isDark,
        'customVariables': customVariables,
        'thumbnail': thumbnail,
      };

  // Built-in default themes
  static LaunchDeskTheme get defaultDark => LaunchDeskTheme(
        id: 'default_dark',
        name: 'Midnight',
        description: 'Default dark theme with Windows 11 glass effects',
        author: 'LaunchDesk',
        createdAt: DateTime(2024),
        updatedAt: DateTime(2024),
        backgroundColor: 0xFF0D1117,
        surfaceColor: 0xFF161B22,
        cardColor: 0xFF21262D,
        accentColor: 0xFF0078D4,
        textColor: 0xFFE6EDF3,
        secondaryTextColor: 0xFF8B949E,
        gradientColors: [0xFF0D1117, 0xFF161B22],
        backgroundType: BackgroundType.gradient,
        enableGlass: true,
        glassOpacity: 0.12,
        isDark: true,
      );

  static LaunchDeskTheme get defaultLight => LaunchDeskTheme(
        id: 'default_light',
        name: 'Daylight',
        description: 'Clean light theme',
        author: 'LaunchDesk',
        createdAt: DateTime(2024),
        updatedAt: DateTime(2024),
        backgroundColor: 0xFFF3F3F3,
        surfaceColor: 0xFFFFFFFF,
        cardColor: 0xFFF0F0F0,
        accentColor: 0xFF0078D4,
        textColor: 0xFF000000,
        secondaryTextColor: 0xFF444444,
        gradientColors: [0xFFF3F3F3, 0xFFE8E8E8],
        backgroundType: BackgroundType.gradient,
        enableGlass: true,
        glassOpacity: 0.5,
        isDark: false,
      );

  static LaunchDeskTheme get ocean => LaunchDeskTheme(
        id: 'ocean',
        name: 'Ocean Deep',
        description: 'Deep ocean blues with teal accents',
        author: 'LaunchDesk',
        createdAt: DateTime(2024),
        updatedAt: DateTime(2024),
        backgroundColor: 0xFF001F3F,
        surfaceColor: 0xFF002D5F,
        cardColor: 0xFF003B7A,
        accentColor: 0xFF00B4D8,
        textColor: 0xFFCAF0F8,
        secondaryTextColor: 0xFF90E0EF,
        gradientColors: [0xFF001F3F, 0xFF003B7A],
        backgroundType: BackgroundType.gradient,
        enableGlass: true,
        glassOpacity: 0.15,
        enableGlow: true,
        glowColor: 0xFF00B4D8,
        glowRadius: 8.0,
        isDark: true,
      );

  static LaunchDeskTheme get aurora => LaunchDeskTheme(
        id: 'aurora',
        name: 'Aurora',
        description: 'Purple-green aurora with particle effects',
        author: 'LaunchDesk',
        createdAt: DateTime(2024),
        updatedAt: DateTime(2024),
        backgroundColor: 0xFF0A0A1A,
        surfaceColor: 0xFF12122A,
        cardColor: 0xFF1A1A3A,
        accentColor: 0xFF8B5CF6,
        textColor: 0xFFE2E8F0,
        secondaryTextColor: 0xFF94A3B8,
        gradientColors: [0xFF0A0A1A, 0xFF1A0A3A],
        backgroundType: BackgroundType.gradient,
        enableGlass: true,
        glassOpacity: 0.12,
        enableGlow: true,
        glowColor: 0xFF8B5CF6,
        enableParticles: true,
        isDark: true,
      );

  static List<LaunchDeskTheme> get builtinThemes =>
      [defaultDark, defaultLight, ocean, aurora];
}
