import 'dart:async';
import 'dart:math';

import 'package:flutter/material.dart';
import '../constants/colors.dart';
import '../constants/images.dart';
import '../constants/text_styles.dart';
import '../constants/portfolio_data.dart';
import 'particle_background.dart';

class HomeSection extends StatefulWidget {
  const HomeSection({super.key});

  @override
  State<HomeSection> createState() => _HomeSectionState();
}

class _HomeSectionState extends State<HomeSection>
    with SingleTickerProviderStateMixin {
  bool _isNameAnimationComplete = false;
  late final AnimationController _titleController;
  late final Animation<Offset> _titleSlide;
  late final Animation<double> _titleOpacity;

  @override
  void initState() {
    super.initState();
    _titleController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1400),
    );
    _titleSlide = Tween<Offset>(
      begin: const Offset(0.4, 0),
      end: Offset.zero,
    ).animate(
      CurvedAnimation(
        parent: _titleController,
        curve: Curves.elasticOut,
      ),
    );
    _titleOpacity = CurvedAnimation(
      parent: _titleController,
      curve: Curves.easeOut,
    );
  }

  @override
  void dispose() {
    _titleController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final isMobile = size.width < 768;

    return Container(
      width: double.infinity,
      constraints: BoxConstraints(minHeight: size.height),
      decoration: const BoxDecoration(gradient: AppColors.backgroundGradient),
      child: ParticleBackground(
        particleCount: isMobile ? 30 : 50,
        connectionDistance: isMobile ? 100 : 120,
        showCursorHalo: true,
        child: SafeArea(
          child: Padding(
            padding: EdgeInsets.symmetric(
              horizontal: isMobile ? 20 : 60,
              vertical: isMobile ? 40 : 80,
            ),
            child: isMobile
                ? _buildMobileLayout(context)
                : _buildDesktopLayout(context),
          ),
        ),
      ),
    );
  }

  Widget _buildDesktopLayout(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Expanded(
          flex: 1,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                'Hello, I\'m',
                style: AppTextStyles.bodyLarge(
                  context,
                ).copyWith(color: AppColors.primaryLight, fontSize: 20),
              ),
              const SizedBox(height: 16),
              _AnimatedNameText(
                text: PortfolioData.name,
                style: AppTextStyles.heading1(context),
                onCompleted: () {
                  setState(() => _isNameAnimationComplete = true);
                  _titleController.forward();
                },
              ),
              const SizedBox(height: 16),
              Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  FadeTransition(
                    opacity: _titleOpacity,
                    child: SlideTransition(
                      position: _titleSlide,
                      child: Text(
                        PortfolioData.title,
                        style: AppTextStyles.heading3(
                          context,
                        ).copyWith(color: AppColors.textSecondary),
                      ),
                    ),
                  ),
                  const SizedBox(width: 32),
                  AnimatedOpacity(
                    opacity: _isNameAnimationComplete ? 1 : 0,
                    duration: const Duration(milliseconds: 400),
                    curve: Curves.easeOut,
                    child: _FlutterBird(),
                  ),
                ],
              ),
              const SizedBox(height: 18),
              Container(
                padding: const EdgeInsets.all(24),
                decoration: BoxDecoration(
                  color: AppColors.surface,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(
                    color: AppColors.primary.withOpacity(0.3),
                    width: 1,
                  ),
                ),
                child: Row(
                  children: [
                    Icon(
                      Icons.format_quote,
                      color: AppColors.primaryLight,
                      size: 32,
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Text(
                        PortfolioData.quote,
                        style: AppTextStyles.quote(context),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
        const SizedBox(width: 60),
        Expanded(
          flex: 1,
          child: Center(
            child: Container(
              width: 350,
              height: 350,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: AppColors.primaryGradient,
                boxShadow: [
                  BoxShadow(
                    color: AppColors.primary.withOpacity(0.5),
                    blurRadius: 40,
                    spreadRadius: 10,
                  ),
                ],
              ),
              padding: const EdgeInsets.all(6),
              child: Container(
                decoration: const BoxDecoration(
                  shape: BoxShape.circle,
                  color: AppColors.background,
                ),
                child: ClipOval(
                  child: Image.network(
                    PortfolioData.profileImageUrl,
                    fit: BoxFit.cover,
                    errorBuilder: (context, error, stackTrace) {
                      return Container(
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          gradient: AppColors.primaryGradient,
                        ),
                        child: const Icon(
                          Icons.person,
                          size: 150,
                          color: Colors.white,
                        ),
                      );
                    },
                  ),
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildMobileLayout(BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Container(
          width: 250,
          height: 250,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            gradient: AppColors.primaryGradient,
            boxShadow: [
              BoxShadow(
                color: AppColors.primary.withOpacity(0.5),
                blurRadius: 30,
                spreadRadius: 5,
              ),
            ],
          ),
          padding: const EdgeInsets.all(5),
          child: Container(
            decoration: const BoxDecoration(
              shape: BoxShape.circle,
              color: AppColors.background,
            ),
            child: ClipOval(
              child: Image.network(
                PortfolioData.profileImageUrl,
                fit: BoxFit.cover,
                errorBuilder: (context, error, stackTrace) {
                  return Container(
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      gradient: AppColors.primaryGradient,
                    ),
                    child: const Icon(
                      Icons.person,
                      size: 100,
                      color: Colors.white,
                    ),
                  );
                },
              ),
            ),
          ),
        ),
        const SizedBox(height: 40),
        Text(
          'Hello, I\'m',
          style: AppTextStyles.bodyLarge(
            context,
          ).copyWith(color: AppColors.primaryLight),
        ),
        const SizedBox(height: 12),
        _AnimatedNameText(
          text: PortfolioData.name,
          style: AppTextStyles.heading1(context),
          textAlign: TextAlign.center,
          onCompleted: () {
            setState(() => _isNameAnimationComplete = true);
            _titleController.forward();
          },
        ),
        const SizedBox(height: 12),
        Row(
          mainAxisSize: MainAxisSize.min,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            FadeTransition(
              opacity: _titleOpacity,
              child: SlideTransition(
                position: _titleSlide,
                child: Text(
                  PortfolioData.title,
                  style: AppTextStyles.heading3(
                    context,
                  ).copyWith(color: AppColors.textSecondary),
                  textAlign: TextAlign.center,
                ),
              ),
            ),
            const SizedBox(width: 10),
            AnimatedOpacity(
              opacity: _isNameAnimationComplete ? 1 : 0,
              duration: const Duration(milliseconds: 400),
              curve: Curves.easeOut,
              child: _FlutterBird(),
            ),
          ],
        ),
        const SizedBox(height: 32),
        Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: AppColors.surface,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: AppColors.primary.withOpacity(0.3),
              width: 1,
            ),
          ),
          child: Column(
            children: [
              Icon(Icons.format_quote, color: AppColors.primaryLight, size: 28),
              const SizedBox(height: 12),
              Text(
                PortfolioData.quote,
                style: AppTextStyles.quote(context),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _AnimatedNameText extends StatefulWidget {
  const _AnimatedNameText({
    required this.text,
    required this.style,
    this.textAlign = TextAlign.start,
    this.onCompleted,
  });

  final String text;
  final TextStyle style;
  final TextAlign textAlign;
  final VoidCallback? onCompleted;

  @override
  State<_AnimatedNameText> createState() => _AnimatedNameTextState();
}

class _AnimatedNameTextState extends State<_AnimatedNameText> {
  late int _visibleChars;
  late bool _cursorOn;
  Timer? _charTimer;
  Timer? _cursorTimer;
  final _rand = Random();
  bool _hasCompleted = false;

  @override
  void initState() {
    super.initState();
    _visibleChars = 0;
    _cursorOn = true;
    _startAnimation();
  }

  void _startAnimation() {
    const startDelay = Duration(milliseconds: 300);
    Future.delayed(startDelay, () {
      if (!mounted) return;
      _startCursorBlink();
      _scheduleNextChar();
    });
  }

  void _startCursorBlink() {
    _cursorTimer?.cancel();
    _cursorTimer = Timer.periodic(const Duration(milliseconds: 500), (timer) {
      if (!mounted) return;
      setState(() {
        _cursorOn = !_cursorOn;
      });
    });
  }

  void _scheduleNextChar() {
    if (_visibleChars >= widget.text.length) {
      _cursorTimer?.cancel();
      if (!_hasCompleted) {
        _hasCompleted = true;
        widget.onCompleted?.call();
      }
      return;
    }

    final minDelay = 130;
    final maxDelay = 280;
    final delayMs = minDelay + _rand.nextInt(maxDelay - minDelay + 1);

    _charTimer?.cancel();
    _charTimer = Timer(Duration(milliseconds: delayMs), () {
      if (!mounted) return;
      setState(() {
        _visibleChars = (_visibleChars + 1)
            .clamp(0, widget.text.length)
            .toInt();
      });
      _scheduleNextChar();
    });
  }

  @override
  void dispose() {
    _charTimer?.cancel();
    _cursorTimer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final displayText = widget.text.substring(0, _visibleChars);
    final showCursor = _cursorOn && _visibleChars < widget.text.length;

    return Text.rich(
      TextSpan(
        children: [
          TextSpan(text: displayText),
          if (showCursor) const TextSpan(text: '_'),
        ],
      ),
      style: widget.style,
      textAlign: widget.textAlign,
    );
  }
}

class _FlutterBird extends StatefulWidget {
  @override
  State<_FlutterBird> createState() => _FlutterBirdState();
}

class _FlutterBirdState extends State<_FlutterBird>
    with TickerProviderStateMixin {
  late final AnimationController _controller;
  late final AnimationController _spinController;
  Animation<double>? _returnDx;
  late final Animation<double> _rotation;
  double _dx = 0;

  static const double _maxDx = 400;
  VoidCallback? _controllerListener;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 900),
    );
    _spinController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 500),
    );
    _rotation = Tween<double>(begin: 0, end: pi).animate(
      CurvedAnimation(parent: _spinController, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    final listener = _controllerListener;
    if (listener != null) {
      _controller.removeListener(listener);
    }
    _controller.dispose();
    _spinController.dispose();
    super.dispose();
  }

  void _onDragUpdate(DragUpdateDetails details) {
    if (_controller.isAnimating) {
      _controller.stop();
    }
    setState(() {
      _dx = (_dx + details.delta.dx).clamp(0.0, _maxDx);
    });
  }

  void _onDragEnd(DragEndDetails details) {
    if (_dx == 0) return;

    _returnDx = Tween<double>(begin: _dx, end: 0).animate(
      CurvedAnimation(parent: _controller, curve: Curves.elasticOut),
    );

    final prevListener = _controllerListener;
    if (prevListener != null) {
      _controller.removeListener(prevListener);
    }

    _controllerListener = () {
      final value = _returnDx?.value;
      if (!mounted || value == null) return;
      setState(() => _dx = value);
    };

    _controller
      ..reset()
      ..addListener(_controllerListener!)
      ..forward().whenComplete(() {
        if (!mounted) return;
        setState(() => _dx = 0);
      });
  }

  Future<void> _handleTap() async {
    if (_spinController.isAnimating) return;
    await _spinController.forward(from: 0);
    if (mounted) {
      await _spinController.reverse();
    }
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onHorizontalDragUpdate: _onDragUpdate,
      onHorizontalDragEnd: _onDragEnd,
      onTap: _handleTap,
      child: Transform.translate(
        offset: Offset(_dx, 0),
        child: AnimatedBuilder(
          animation: _rotation,
          builder: (context, child) {
            final angle = _rotation.value;
            final transform = Matrix4.identity()
              ..setEntry(3, 2, 0.0015)
              ..rotateY(angle);
            return Transform(
              alignment: Alignment.center,
              transform: transform,
              child: child,
            );
          },
          child: Transform.scale(
            scale: 4,
            child: Image.asset(AppImages.flutterBird, width: 48, height: 48),
          ),
        ),
      ),
    );
  }
}
