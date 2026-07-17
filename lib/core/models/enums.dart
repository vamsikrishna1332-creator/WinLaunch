import 'package:flutter/material.dart';

// ─── Background ───────────────────────────────────────────────────────────────
enum BackgroundType { color, gradient, image, video, gif }

// ─── Particle system ──────────────────────────────────────────────────────────
class ParticleConfig {
  final int count;
  final Color color;
  final double size;
  final double speed;

  const ParticleConfig({
    this.count = 50,
    this.color = Colors.white,
    this.size = 2.0,
    this.speed = 1.0,
  });

  factory ParticleConfig.fromJson(Map<String, dynamic> json) => ParticleConfig(
        count: json['count'] ?? 50,
        color: Color(json['color'] ?? 0xFFFFFFFF),
        size: (json['size'] ?? 2.0).toDouble(),
        speed: (json['speed'] ?? 1.0).toDouble(),
      );

  Map<String, dynamic> toJson() => {
        'count': count,
        'color': color.value,
        'size': size,
        'speed': speed,
      };
}
