import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:personal_portfoliio/constants/images.dart';

import '../constants/colors.dart';
import '../constants/text_styles.dart';
import '../constants/portfolio_data.dart';

class AboutSection extends StatefulWidget {
  const AboutSection({super.key});

  @override
  State<AboutSection> createState() => _AboutSectionState();
}

class _AboutSectionState extends State<AboutSection>
    with SingleTickerProviderStateMixin {
  late final AnimationController _flareController;
  late final List<_FlareParticle> _particles;
  double _lastT = 0;

  @override
  void initState() {
    super.initState();
    _flareController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 12),
    )..addListener(_tick);
    _resetParticles();
    _flareController.repeat();
  }

  @override
  void dispose() {
    _flareController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final isMobile = size.width < 768;

    return Container(
      width: double.infinity,
      constraints: BoxConstraints(minHeight: size.height),
      color: AppColors.backgroundLight,
      padding: EdgeInsets.symmetric(
        horizontal: isMobile ? 20 : 60,
        vertical: isMobile ? 60 : 100,
      ),
      child: AnimatedBuilder(
        animation: _flareController,
        builder: (context, _) {
          final flareValue = _flareController.value;
          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('ABOUT', style: AppTextStyles.sectionTitle(context)),
              const SizedBox(height: 16),
              Text('Who I Am', style: AppTextStyles.heading2(context)),
              const SizedBox(height: 40),
              isMobile
                  ? _buildContentBox(context, flareProgress: flareValue)
                  : Row(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        Expanded(
                          flex: 2,
                          child: _buildContentBox(
                            context,
                            flareProgress: flareValue,
                          ),
                        ),
                        const SizedBox(width: 60),
                        Expanded(flex: 1, child: _buildGifContainer(context)),
                      ],
                    ),
            ],
          );
        },
      ),
    );
  }

  void _tick() {
    final t =
        _flareController.lastElapsedDuration?.inMilliseconds.toDouble() ?? 0.0;
    final dtMs = (t - _lastT).clamp(0, 32); // clamp to avoid big jumps
    _lastT = t;
    final dt = dtMs / 1000.0;

    // Simple physics in normalized space (0..1)
    for (int i = 0; i < _particles.length; i++) {
      final p = _particles[i];
      p.position += p.velocity * dt;

      // Bounce on bounds
      if (p.position.dx < 0 || p.position.dx > 1) {
        p.velocity = Offset(-p.velocity.dx, p.velocity.dy);
        p.position = Offset(p.position.dx.clamp(0, 1), p.position.dy);
      }
      if (p.position.dy < 0 || p.position.dy > 1) {
        p.velocity = Offset(p.velocity.dx, -p.velocity.dy);
        p.position = Offset(p.position.dx, p.position.dy.clamp(0, 1));
      }

      // Collisions with other particles (basic elastic swap)
      for (int j = i + 1; j < _particles.length; j++) {
        final q = _particles[j];
        final dist2 = (p.position - q.position).distanceSquared;
        const minDist = 0.08;
        if (dist2 < minDist * minDist) {
          final tmp = p.velocity;
          p.velocity = q.velocity;
          q.velocity = tmp;
          // push apart a bit
          final diff = p.position - q.position;
          final len = diff.distance;
          final dir = len == 0 ? const Offset(1, 0) : diff / len;
          p.position += dir * 0.01;
          q.position -= dir * 0.01;
        }
      }
    }
    if (mounted) setState(() {});
  }

  void _resetParticles() {
    final rng = math.Random();
    _particles = List.generate(3, (_) {
      final speed = 0.12 + rng.nextDouble() * 0.12; // normalized units per sec
      final angle = rng.nextDouble() * 2 * math.pi;
      return _FlareParticle(
        position: Offset(rng.nextDouble(), rng.nextDouble()),
        velocity: Offset(math.cos(angle), math.sin(angle)) * speed,
      );
    });
  }

  Widget _buildContentBox(
    BuildContext context, {
    required double flareProgress,
  }) {
    return CustomPaint(
      foregroundPainter: _FlarePainter(
        progress: flareProgress,
        particles: _particles,
      ),
      child: Container(
        padding: const EdgeInsets.all(32),
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: AppColors.primary.withOpacity(0.2),
            width: 1,
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.1),
              blurRadius: 20,
              offset: const Offset(0, 8),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              PortfolioData.bio,
              style: AppTextStyles.bodyLarge(
                context,
              ).copyWith(color: AppColors.textSecondary, height: 1.7),
            ),
            const SizedBox(height: 10),
            Text(
              'Skills & Tools',
              style: AppTextStyles.heading4(
                context,
              ).copyWith(color: AppColors.primaryLight),
            ),
            const SizedBox(height: 20),
            Wrap(
              spacing: 12,
              runSpacing: 12,
              children: [
                for (final skillMap in PortfolioData.skills)
                  _SkillBullet(name: skillMap['name'] as String),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildGifContainer(BuildContext context) {
    return Center(
      child: SizedBox(
        width: 300,

        child: Stack(
          clipBehavior: Clip.none,
          children: [
            // Decorative outlined container behind/offset from the GIF
            Positioned(
              top: 26,
              left: 46,
              child: Container(
                width: 230,
                height: 300,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(
                    color: AppColors.primary.withOpacity(0.4),
                    width: 3,
                  ),
                  color: Colors.transparent,
                ),
              ),
            ),
            // Main GIF card
            Container(
              height: 300,
              width: 250,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(20),
                color: Colors.black,
                border: Border.all(
                  color: AppColors.primary.withOpacity(0.2),
                  width: 1,
                ),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.18),
                    blurRadius: 20,
                    offset: const Offset(0, 8),
                  ),
                ],
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(20),
                child: Image.asset(
                  AppImages.aboutAnimation,
                  fit: BoxFit.cover,
                  errorBuilder: (context, error, stackTrace) {
                    return Container(
                      height: 220,
                      decoration: BoxDecoration(
                        color: AppColors.surface,
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(
                          color: AppColors.primary.withOpacity(0.2),
                          width: 1,
                        ),
                      ),
                      child: const Center(
                        child: Icon(
                          Icons.image,
                          size: 80,
                          color: AppColors.textSecondary,
                        ),
                      ),
                    );
                  },
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _SkillBullet extends StatefulWidget {
  const _SkillBullet({required this.name});

  final String name;

  @override
  State<_SkillBullet> createState() => _SkillBulletState();
}

class _SkillBulletState extends State<_SkillBullet>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  late final Animation<double> _shake;
  final math.Random _rng = math.Random();

  // Track the pill's resting angle so a new shake starts from its last pose.
  double _restingAngle = 0;
  // Angle offset applied at the beginning of a shake; set from _restingAngle.
  double _initialAngle = 0;
  // Randomized swing direction so first move can go left or right.
  double _direction = 1;
  // Live angle updated during the animation.
  double _currentAngle = 0;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 2000),
    );
    _shake = CurvedAnimation(parent: _controller, curve: Curves.easeOut);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _triggerShake() {
    if (_controller.isAnimating) return;

    _direction = _rng.nextBool() ? 1 : -1;
    _initialAngle = _restingAngle;
    _controller.forward(from: 0);
  }

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      cursor: SystemMouseCursors.click,
      child: GestureDetector(
        onTap: _triggerShake,
        behavior: HitTestBehavior.opaque,
        child: AnimatedBuilder(
          animation: _shake,
          builder: (context, child) {
            final double progress = _shake.value;
            // Kids swing effect: pendulum motion with rotation
            // Exponential decay for natural damping
            final double decay = math.exp(-progress * 1.2);
            // Smooth sine wave for pendulum motion (fewer oscillations)
            final double swing =
                _direction * math.sin(progress * 2.5 * math.pi) * decay;
            final double angle = _initialAngle + swing;
            _currentAngle = angle;
            if (!_controller.isAnimating) {
              _restingAngle = angle;
            }
            // Horizontal displacement creates the arc
            final double offsetX = angle * 12;
            // Rotation angle matches the swing arc (in degrees)
            final double rotationAngle = angle * 0.15;
            return Transform.translate(
              offset: Offset(offsetX, 0),
              child: Transform.rotate(angle: rotationAngle, child: child),
            );
          },
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
            decoration: BoxDecoration(
              color: AppColors.surface,
              borderRadius: BorderRadius.circular(20),
              border: Border.all(
                color: AppColors.primary.withOpacity(0.35),
                width: 1,
              ),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  width: 6,
                  height: 6,
                  decoration: const BoxDecoration(
                    shape: BoxShape.circle,
                    color: AppColors.primaryLight,
                  ),
                ),
                const SizedBox(width: 8),
                Text(
                  widget.name,
                  style: AppTextStyles.bodyMedium(context).copyWith(
                    color: AppColors.textSecondary,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _FlarePainter extends CustomPainter {
  _FlarePainter({required this.progress, required this.particles});

  final double progress;
  final List<_FlareParticle> particles;

  @override
  void paint(Canvas canvas, Size size) {
    final p = progress * 2 * math.pi;

    for (int i = 0; i < particles.length; i++) {
      final part = particles[i];
      final pos = Offset(
        size.width * part.position.dx,
        size.height * part.position.dy,
      );

      final baseSize = 110.0 + 40.0 * math.sin(p + i);
      final opacity = 0.2 + 0.08 * math.cos(p + i * 1.3);

      final paint = Paint()
        ..shader = RadialGradient(
          colors: [
            AppColors.primaryLight.withOpacity(opacity),
            AppColors.primaryLight.withOpacity(0),
          ],
        ).createShader(Rect.fromCircle(center: pos, radius: baseSize * 1.2))
        ..maskFilter = MaskFilter.blur(BlurStyle.normal, baseSize * 0.5)
        ..blendMode = BlendMode.screen;

      canvas.drawCircle(pos, baseSize, paint);
    }
  }

  @override
  bool shouldRepaint(covariant _FlarePainter oldDelegate) {
    return oldDelegate.progress != progress ||
        oldDelegate.particles != particles;
  }
}

class _FlareParticle {
  _FlareParticle({required this.position, required this.velocity});

  Offset position;
  Offset velocity;
}
