import 'dart:math' as math;
import 'package:flutter/material.dart';
import '../constants/colors.dart';

class ParticleBackground extends StatefulWidget {
  final Widget child;
  final int particleCount;
  final double connectionDistance;
  final bool showCursorHalo;

  const ParticleBackground({
    super.key,
    required this.child,
    this.particleCount = 50,
    this.connectionDistance = 120,
    this.showCursorHalo = false,
  });

  @override
  State<ParticleBackground> createState() => _ParticleBackgroundState();
}

class _ParticleBackgroundState extends State<ParticleBackground>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  List<Particle> _particles = [];
  Offset? _mousePosition;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 20),
    )..repeat();

    _controller.addListener(_updateParticles);
  }

  void _updateParticles() {
    if (mounted) {
      setState(() {});
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _initializeParticles(Size size) {
    final random = math.Random();
    _particles = List.generate(
      widget.particleCount,
      (_) => Particle.random(size),
    );

    // Recolor a small subset to green accent
    final greenCount = math.min(6, math.max(2, widget.particleCount ~/ 8));
    final selectedIndices = <int>{};
    while (selectedIndices.length < greenCount) {
      selectedIndices.add(random.nextInt(_particles.length));
    }
    for (final index in selectedIndices) {
      _particles[index] = _particles[index].copyWith(
        color: AppColors.accent.withValues(alpha: 0.6),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        if (_particles.isEmpty || _particles.length != widget.particleCount) {
          WidgetsBinding.instance.addPostFrameCallback((_) {
            if (mounted) {
              _initializeParticles(constraints.biggest);
            }
          });
        }

        return GestureDetector(
          onPanUpdate: (details) {
            setState(() {
              _mousePosition = details.localPosition;
            });
          },
          onPanEnd: (_) {
            setState(() {
              _mousePosition = null;
            });
          },
          child: MouseRegion(
            onHover: (event) {
              setState(() {
                _mousePosition = event.localPosition;
              });
            },
            onExit: (_) {
              setState(() {
                _mousePosition = null;
              });
            },
            child: Stack(
              children: [
                CustomPaint(
                  painter: ParticlePainter(
                    particles: _particles,
                    mousePosition: _mousePosition,
                    connectionDistance: widget.connectionDistance,
                    showCursorHalo: widget.showCursorHalo,
                    time: _controller.value * 2 * math.pi,
                  ),
                  size: constraints.biggest,
                ),
                widget.child,
              ],
            ),
          ),
        );
      },
    );
  }
}

class Particle {
  double x;
  double y;
  double vx;
  double vy;
  double radius;
  Color color;

  Particle({
    required this.x,
    required this.y,
    required this.vx,
    required this.vy,
    required this.radius,
    required this.color,
  });

  factory Particle.random(Size size) {
    final random = math.Random();
    return Particle(
      x: random.nextDouble() * size.width,
      y: random.nextDouble() * size.height,
      vx: (random.nextDouble() - 0.5) * 0.25,
      vy: (random.nextDouble() - 0.5) * 0.25,
      radius: random.nextDouble() * 2 + 1,
      color: AppColors.primaryLight.withValues(alpha:
        random.nextDouble() * 0.5 + 0.2,
      ),
    );
  }

  Particle copyWith({Color? color}) {
    return Particle(
      x: x,
      y: y,
      vx: vx,
      vy: vy,
      radius: radius,
      color: color ?? this.color,
    );
  }

  void update(Size size, Offset? mousePosition, double time) {
    // Update position
    x += vx;
    y += vy;

    // Add some wave motion
    x += math.sin(time + y * 0.01) * 0.2;
    y += math.cos(time + x * 0.01) * 0.2;

    // Mouse interaction - particles are repelled by mouse
    if (mousePosition != null) {
      final dx = x - mousePosition.dx;
      final dy = y - mousePosition.dy;
      final distance = math.sqrt(dx * dx + dy * dy);
      final maxDistance = 150.0;

      if (distance < maxDistance && distance > 0) {
        final force = (maxDistance - distance) / maxDistance;
        final angle = math.atan2(dy, dx);
        x += math.cos(angle) * force * 1.2;
        y += math.sin(angle) * force * 1.2;
      }
    }

    // Bounce off edges
    if (x < 0 || x > size.width) {
      vx = -vx;
      x = x.clamp(0.0, size.width);
    }
    if (y < 0 || y > size.height) {
      vy = -vy;
      y = y.clamp(0.0, size.height);
    }

    // Keep particles within bounds
    x = x.clamp(0.0, size.width);
    y = y.clamp(0.0, size.height);
  }
}

class ParticlePainter extends CustomPainter {
  final List<Particle> particles;
  final Offset? mousePosition;
  final double connectionDistance;
  final double time;
  final bool showCursorHalo;

  ParticlePainter({
    required this.particles,
    this.mousePosition,
    required this.connectionDistance,
    required this.time,
    required this.showCursorHalo,
  });

  @override
  void paint(Canvas canvas, Size size) {
    // Update particles
    for (var particle in particles) {
      particle.update(size, mousePosition, time);
    }

    // Small cursor halo (for enabled contexts)
    if (showCursorHalo && mousePosition != null) {
      final haloPaint = Paint()
        ..color = AppColors.primaryLight.withValues(alpha: 0.18)
        ..style = PaintingStyle.fill
        ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 12);

      canvas.drawCircle(mousePosition!, 24, haloPaint);

      final strokePaint = Paint()
        ..color = AppColors.primaryLight.withValues(alpha: 0.5)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 1.2;

      canvas.drawCircle(mousePosition!, 24, strokePaint);
    }

    // Draw connections
    final paint = Paint()
      ..strokeWidth = 1
      ..style = PaintingStyle.stroke;

    for (int i = 0; i < particles.length; i++) {
      for (int j = i + 1; j < particles.length; j++) {
        final p1 = particles[i];
        final p2 = particles[j];
        final dx = p1.x - p2.x;
        final dy = p1.y - p2.y;
        final distance = math.sqrt(dx * dx + dy * dy);

        if (distance < connectionDistance) {
          final opacity = (1 - distance / connectionDistance) * 0.3;
          paint.color = AppColors.primaryLight.withValues(alpha: opacity);
          canvas.drawLine(
            Offset(p1.x, p1.y),
            Offset(p2.x, p2.y),
            paint,
          );
        }
      }
    }

    // Draw particles
    for (var particle in particles) {
      final particlePaint = Paint()
        ..color = particle.color
        ..style = PaintingStyle.fill;

      canvas.drawCircle(
        Offset(particle.x, particle.y),
        particle.radius,
        particlePaint,
      );

      // Add glow effect
      final glowPaint = Paint()
        ..color = particle.color.withValues(alpha: 0.3)
        ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 3);

      canvas.drawCircle(
        Offset(particle.x, particle.y),
        particle.radius * 2,
        glowPaint,
      );
    }
  }

  @override
  bool shouldRepaint(ParticlePainter oldDelegate) {
    return true;
  }
}
