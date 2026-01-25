import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import '../constants/colors.dart';
import '../constants/text_styles.dart';
import '../constants/portfolio_data.dart';
import '../models/experience_model.dart';

class ExperienceSection extends StatefulWidget {
  const ExperienceSection({super.key});

  @override
  State<ExperienceSection> createState() => _ExperienceSectionState();
}

class _ExperienceSectionState extends State<ExperienceSection>
    with WidgetsBindingObserver {
  final GlobalKey _sectionKey = GlobalKey();
  bool _sectionAnimated = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    // Check visibility after multiple frames to ensure layout is complete
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Future.delayed(const Duration(milliseconds: 300), () {
        if (mounted) {
          _checkSectionVisibility();
          _startPeriodicVisibilityCheck();
          // Fallback: if section is already mostly visible, trigger animation
          Future.delayed(const Duration(milliseconds: 500), () {
            if (mounted && !_sectionAnimated) {
              _checkSectionVisibility();
            }
          });
        }
      });
    });
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  void _startPeriodicVisibilityCheck() {
    Future.delayed(const Duration(milliseconds: 200), () {
      if (mounted) {
        _checkSectionVisibility();
        _startPeriodicVisibilityCheck();
      }
    });
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed && mounted) {
      _checkSectionVisibility();
    }
  }

  double _getVisibilityThreshold() {
    final experienceCount = PortfolioData.experiences.length;
    if (experienceCount >= 5) {
      return 0.45; // 45% for 5 or more elements
    } else if (experienceCount == 4) {
      return 0.60; // 60% for exactly 4 elements
    } else if (experienceCount >= 3) {
      return 0.70; // 70% for 3 or more elements
    } else {
      return 0.70; // Default to 70% for less than 3 elements
    }
  }

  void _checkSectionVisibility() {
    if (!mounted) return;

    final context = _sectionKey.currentContext;
    if (context == null || !context.mounted) return;

    final RenderBox? renderBox = context.findRenderObject() as RenderBox?;
    if (renderBox == null || !renderBox.hasSize) return;

    try {
      final position = renderBox.localToGlobal(Offset.zero);
      final widgetSize = renderBox.size;
      final screenSize = MediaQuery.of(context).size;
      final screenHeight = screenSize.height;

      final viewportTop = 0.0;
      final viewportBottom = screenHeight;

      final widgetTop = position.dy;
      final widgetBottom = widgetTop + widgetSize.height;

      final visibleTop = widgetTop.clamp(viewportTop, viewportBottom);
      final visibleBottom = widgetBottom.clamp(viewportTop, viewportBottom);
      final visibleHeight = (visibleBottom - visibleTop).clamp(0.0, widgetSize.height);

      if (widgetSize.height > 0) {
        final visibilityPercentage = visibleHeight / widgetSize.height;
        final isInViewport = widgetBottom > viewportTop && widgetTop < viewportBottom;
        final threshold = _getVisibilityThreshold();
        final shouldBeAnimated = isInViewport && visibilityPercentage >= threshold;

        final isCompletelyOutOfView = widgetBottom <= viewportTop || widgetTop >= viewportBottom;

        if (shouldBeAnimated && !_sectionAnimated && mounted) {
          setState(() {
            _sectionAnimated = true;
          });
        } else if (isCompletelyOutOfView && _sectionAnimated && mounted) {
          setState(() {
            _sectionAnimated = false;
          });
        }
      }
    } catch (e) {
      // Silently handle errors
    }
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final isMobile = size.width < 768;

    // Check visibility after build completes
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        Future.delayed(const Duration(milliseconds: 50), () {
          if (mounted) {
            _checkSectionVisibility();
          }
        });
      }
    });

    return NotificationListener<ScrollNotification>(
      onNotification: (notification) {
        if (notification is ScrollUpdateNotification ||
            notification is ScrollEndNotification ||
            notification is ScrollStartNotification) {
          WidgetsBinding.instance.addPostFrameCallback((_) {
            if (mounted) {
              _checkSectionVisibility();
            }
          });
        }
        return false;
      },
      child: Container(
        key: _sectionKey,
        width: double.infinity,
        constraints: BoxConstraints(
          minHeight: size.height,
        ),
        color: AppColors.backgroundLight,
        padding: EdgeInsets.symmetric(
          horizontal: isMobile ? 20 : 60,
          vertical: isMobile ? 60 : 100,
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'EXPERIENCE',
              style: AppTextStyles.sectionTitle(context),
            ),
            const SizedBox(height: 16),
            Text(
              'My Career Journey',
              style: AppTextStyles.heading2(context),
            ),
            const SizedBox(height: 60),
            _buildExperiencesList(context, isMobile),
          ],
        ),
      ),
    );
  }

  Widget _buildExperiencesList(BuildContext context, bool isMobile) {
    final experiences = PortfolioData.experiences
        .map((exp) => Experience.fromMap(exp))
        .toList();

    return isMobile
        ? Column(
            children: experiences
                .asMap()
                .entries
                .map((entry) => Padding(
                      padding: const EdgeInsets.only(bottom: 18),
                      child: _ExperienceCard(
                        experience: entry.value,
                        isLast: entry.key == experiences.length - 1,
                        isMobile: true,
                        index: entry.key,
                        shouldAnimate: _sectionAnimated,
                      ),
                    ))
                .toList(),
          )
        : Column(
            children: experiences
                .asMap()
                .entries
                .map((entry) => Padding(
                      padding: const EdgeInsets.only(bottom: 24),
                      child: _ExperienceCard(
                        experience: entry.value,
                        isLast: entry.key == experiences.length - 1,
                        isMobile: false,
                        index: entry.key,
                        shouldAnimate: _sectionAnimated,
                      ),
                    ))
                .toList(),
          );
  }
}

class _ExperienceCard extends StatefulWidget {
  final Experience experience;
  final bool isLast;
  final bool isMobile;
  final int index;
  final bool shouldAnimate;

  const _ExperienceCard({
    required this.experience,
    required this.isLast,
    required this.isMobile,
    required this.index,
    required this.shouldAnimate,
  });

  @override
  State<_ExperienceCard> createState() => _ExperienceCardState();
}

class _ExperienceCardState extends State<_ExperienceCard>
    with TickerProviderStateMixin {
  late AnimationController _animationController;
  late AnimationController _stackingController;
  late AnimationController _typewriterController;
  late Animation<double> _rotationAnimation;
  late Animation<double> _stackingAnimation;
  late Animation<int> _typewriterAnimation;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1200), // Slow animation
    );

    // Stacking animation controller - starts after initial animation
    _stackingController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 600), // Stacking animation duration
    );

    // Typewriter animation controller - starts after initial animation completes
    final companyName = widget.experience.company;
    final typewriterDuration = Duration(milliseconds: companyName.length * 50); // 50ms per character
    _typewriterController = AnimationController(
      vsync: this,
      duration: typewriterDuration,
    );

    // Typewriter animation: reveals characters one by one
    _typewriterAnimation = IntTween(
      begin: 0,
      end: companyName.length,
    ).animate(CurvedAnimation(
      parent: _typewriterController,
      curve: Curves.linear,
    ));

    // Animation sequence: fall from 90° to 0°, then bounce
    _rotationAnimation = TweenSequence<double>([
      // Main fall: from 90° to 0° (80% of animation time)
      TweenSequenceItem(
        tween: Tween<double>(begin: 90.0, end: 0.0)
            .chain(CurveTween(curve: Curves.easeOut)),
        weight: 80.0,
      ),
      // Bounce up: slight overshoot to -8° (10% of animation time)
      TweenSequenceItem(
        tween: Tween<double>(begin: 0.0, end: -8.0)
            .chain(CurveTween(curve: Curves.easeOut)),
        weight: 10.0,
      ),
      // Bounce back: settle to 0° (10% of animation time)
      TweenSequenceItem(
        tween: Tween<double>(begin: -8.0, end: 0.0)
            .chain(CurveTween(curve: Curves.easeInOut)),
        weight: 10.0,
      ),
    ]).animate(_animationController);

    // Stacking animation: slight rotation to create stacking effect
    // Rotates 3-5 degrees based on index (all cards including last)
    final stackingAngle = 3.0 + (widget.index * 0.5); // Slight increase per card
    _stackingAnimation = Tween<double>(
      begin: 0.0,
      end: stackingAngle,
    ).animate(CurvedAnimation(
      parent: _stackingController,
      curve: Curves.easeOut,
    ));

    // Start with cards invisible (at 0.0 = 90 degrees rotated)
    // They will only animate when shouldAnimate becomes true
    _animationController.value = 0.0;
    
    // Listen to initial animation completion to start stacking and typewriter
    _animationController.addStatusListener((status) {
      if (status == AnimationStatus.completed) {
        // Start typewriter animation after initial animation completes
        Future.delayed(const Duration(milliseconds: 300), () {
          if (mounted) {
            _typewriterController.forward();
          }
        });
        
        // Start stacking animation after initial animation completes (all cards)
        Future.delayed(const Duration(milliseconds: 200), () {
          if (mounted) {
            _stackingController.forward();
          }
        });
      }
    });

    // Only start animation if shouldAnimate is already true
    if (widget.shouldAnimate) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) {
          // Start animation with staggered delay based on index
          Future.delayed(Duration(milliseconds: widget.index * 150), () {
            if (mounted) {
              _animationController.forward();
            }
          });
        }
      });
    }
  }

  @override
  void didUpdateWidget(_ExperienceCard oldWidget) {
    super.didUpdateWidget(oldWidget);
    
    if (widget.shouldAnimate && !oldWidget.shouldAnimate) {
      // Section became 60% visible - start animation from invisible state
      // Ensure we're at start position (invisible)
      if (_animationController.value != 0.0) {
        _animationController.value = 0.0;
      }
      _stackingController.reset();
      _typewriterController.reset();
      // Start animation with staggered delay based on index
      Future.delayed(Duration(milliseconds: widget.index * 150), () {
        if (mounted && widget.shouldAnimate) {
          _animationController.forward();
        }
      });
    } else if (!widget.shouldAnimate && oldWidget.shouldAnimate) {
      // Section went out of view - reset to invisible state
      _animationController.reset();
      _stackingController.reset();
      _typewriterController.reset();
    }
  }

  @override
  void dispose() {
    _animationController.dispose();
    _stackingController.dispose();
    _typewriterController.dispose();
    super.dispose();
  }

  Future<void> _launchCompanyWebsite() async {
    final website = widget.experience.website;
    if (website != null && website.isNotEmpty) {
      final uri = Uri.parse(website);
      if (await canLaunchUrl(uri)) {
        await launchUrl(uri, mode: LaunchMode.externalApplication);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return widget.isMobile
        ? _buildMobileCard(context)
        : _buildDesktopCard(context);
  }

  Widget _buildDesktopCard(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final cardWidth = screenWidth * 0.58;
    final isLeftAligned = widget.index % 2 == 0; // Even index = left, odd index = right
    
    // Bullet widget with horizontal line (hinge effect)
    // For left: bullet → line, For right: line → bullet
    final bulletWidget = AnimatedBuilder(
      animation: _rotationAnimation,
      builder: (context, child) {
        final rotationX = _rotationAnimation.value * (3.14159 / 180);
        
        return Transform(
          alignment: Alignment.center,
          transform: Matrix4.identity()
            ..setEntry(3, 2, 0.001) // Perspective
            ..rotateX(rotationX),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: isLeftAligned
                ? [
                    // Left aligned: bullet first, then line
                    Container(
                      width: 16,
                      height: 16,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: AppColors.primary,
                        border: Border.all(
                          color: AppColors.backgroundLight,
                          width: 4,
                        ),
                      ),
                    ),
                    // Horizontal line connecting to card (hinge effect)
                    Container(
                      width: 24, // Distance to card
                      height: 2,
                      color: AppColors.primary.withValues(alpha: 0.3),
                    ),
                  ]
                : [
                    // Right aligned: line first, then bullet
                    Container(
                      width: 24, // Distance to card
                      height: 2,
                      color: AppColors.primary.withValues(alpha: 0.3),
                    ),
                    Container(
                      width: 16,
                      height: 16,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: AppColors.primary,
                        border: Border.all(
                          color: AppColors.backgroundLight,
                          width: 4,
                        ),
                      ),
                    ),
                  ],
          ),
        );
      },
    );
    
    final cardWidget = Container(
      width: cardWidth,
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [
            AppColors.surface.withValues(alpha: 0.95),
            AppColors.surface,
            AppColors.surfaceLight.withValues(alpha: 0.8),
          ],
          stops: const [0.0, 0.5, 1.0],
        ),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: AppColors.primary.withValues(alpha: 0.5),
          width: 2,
        ),
        boxShadow: [
          BoxShadow(
            color: AppColors.primary.withValues(alpha: 0.1),
            blurRadius: 20,
            spreadRadius: 0,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      widget.experience.title,
                      style: AppTextStyles.heading4(context),
                    ),
                    const SizedBox(height: 4),
                    AnimatedBuilder(
                      animation: _typewriterAnimation,
                      builder: (context, child) {
                        final companyName = widget.experience.company;
                        final visibleLength = _typewriterAnimation.value;
                        final visibleText = companyName.substring(
                          0,
                          visibleLength.clamp(0, companyName.length),
                        );
                        final hasWebsite = widget.experience.website != null && 
                                         widget.experience.website!.isNotEmpty;
                        return GestureDetector(
                          onTap: hasWebsite ? _launchCompanyWebsite : null,
                          child: MouseRegion(
                            cursor: hasWebsite 
                                ? SystemMouseCursors.click 
                                : SystemMouseCursors.basic,
                            child: Text(
                              visibleText,
                              style: AppTextStyles.bodyLarge(context).copyWith(
                                color: AppColors.primaryLight,
                                fontWeight: FontWeight.w600,
                                decoration: hasWebsite 
                                    ? TextDecoration.underline 
                                    : TextDecoration.none,
                                decorationColor: AppColors.primaryLight,
                              ),
                            ),
                          ),
                        );
                      },
                    ),
                  ],
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 8,
                ),
                decoration: BoxDecoration(
                  color: AppColors.primary.withValues(alpha: 0.2),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  widget.experience.period,
                  style: AppTextStyles.bodySmall(context).copyWith(
                    color: AppColors.primaryLight,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              Icon(
                Icons.location_on,
                size: 16,
                color: AppColors.textTertiary,
              ),
              const SizedBox(width: 4),
              Text(
                widget.experience.location,
                style: AppTextStyles.bodySmall(context),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Text(
            widget.experience.description,
            style: AppTextStyles.bodyMedium(context),
          ),
          const SizedBox(height: 16),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: widget.experience.technologies
                .map((tech) => Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 6,
                      ),
                      decoration: BoxDecoration(
                        color: AppColors.surfaceLight,
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Text(
                        tech,
                        style: AppTextStyles.bodySmall(context),
                      ),
                    ))
                .toList(),
          ),
        ],
      ),
    );
    
    return AnimatedBuilder(
      animation: Listenable.merge([_rotationAnimation, _stackingAnimation]),
      builder: (context, child) {
        // Convert degrees to radians for rotation
        final rotationX = _rotationAnimation.value * (3.14159 / 180);
        final stackingZ = _stackingAnimation.value * (3.14159 / 180);
        
        // Pivot point: left edge (hinge) for left cards, right edge (hinge) for right cards
        // This keeps the hinge fixed while the opposite end moves down
        final pivotAlignment = isLeftAligned ? Alignment.centerLeft : Alignment.centerRight;
        
        return Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          mainAxisAlignment: isLeftAligned ? MainAxisAlignment.start : MainAxisAlignment.end,
          children: isLeftAligned
              ? [
                  bulletWidget,
                  // First apply initial rotation around center
                  Transform(
                    alignment: Alignment.center,
                    transform: Matrix4.identity()
                      ..setEntry(3, 2, 0.001)
                      ..rotateX(rotationX),
                    child: Transform(
                      alignment: pivotAlignment, // Pivot at left edge (hinge) - this stays fixed
                      transform: Matrix4.identity()
                        ..setEntry(3, 2, 0.001)
                        ..rotateZ(stackingZ * 1.0), // Increased: more downward tilt
                      child: cardWidget,
                    ),
                  ),
                  const Spacer(), // Push to left side
                ]
              : [
                  const Spacer(), // Push to right side
                  // First apply initial rotation around center
                  Transform(
                    alignment: Alignment.center,
                    transform: Matrix4.identity()
                      ..setEntry(3, 2, 0.001)
                      ..rotateX(rotationX),
                    child: Transform(
                      alignment: pivotAlignment, // Pivot at right edge (hinge) - this stays fixed
                      transform: Matrix4.identity()
                        ..setEntry(3, 2, 0.001)
                        ..rotateZ(-stackingZ * 1.0), // Increased: more downward tilt
                      child: cardWidget,
                    ),
                  ),
                  bulletWidget,
                ],
        );
      },
    );
  }

  Widget _buildMobileCard(BuildContext context) {
    return AnimatedBuilder(
      animation: _rotationAnimation,
      builder: (context, child) {
        // Convert degrees to radians for rotation
        final rotationX = _rotationAnimation.value * (3.14159 / 180);
        
        return Transform(
          alignment: Alignment.center,
          transform: Matrix4.identity()
            ..setEntry(3, 2, 0.001) // Perspective
            ..rotateX(rotationX),
          child: Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [
                  AppColors.surface.withValues(alpha: 0.95),
                  AppColors.surface,
                  AppColors.surfaceLight.withValues(alpha: 0.8),
                ],
                stops: const [0.0, 0.5, 1.0],
              ),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(
                color: AppColors.primary.withValues(alpha: 0.5),
                width: 2,
              ),
              boxShadow: [
                BoxShadow(
                  color: AppColors.primary.withValues(alpha: 0.1),
                  blurRadius: 20,
                  spreadRadius: 0,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            widget.experience.title,
            style: AppTextStyles.heading4(context),
          ),
          const SizedBox(height: 4),
          AnimatedBuilder(
            animation: _typewriterAnimation,
            builder: (context, child) {
              final companyName = widget.experience.company;
              final visibleLength = _typewriterAnimation.value;
              final visibleText = companyName.substring(
                0,
                visibleLength.clamp(0, companyName.length),
              );
              final hasWebsite = widget.experience.website != null && 
                               widget.experience.website!.isNotEmpty;
              return GestureDetector(
                onTap: hasWebsite ? _launchCompanyWebsite : null,
                child: MouseRegion(
                  cursor: hasWebsite 
                      ? SystemMouseCursors.click 
                      : SystemMouseCursors.basic,
                  child: Text(
                    visibleText,
                    style: AppTextStyles.bodyMedium(context).copyWith(
                      color: AppColors.primaryLight,
                      fontWeight: FontWeight.w600,
                      decoration: hasWebsite 
                          ? TextDecoration.underline 
                          : TextDecoration.none,
                      decorationColor: AppColors.primaryLight,
                    ),
                  ),
                ),
              );
            },
          ),
          const SizedBox(height: 8),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  Icon(
                    Icons.location_on,
                    size: 14,
                    color: AppColors.textTertiary,
                  ),
                  const SizedBox(width: 4),
                  Text(
                    widget.experience.location,
                    style: AppTextStyles.bodySmall(context),
                  ),
                ],
              ),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 6,
                ),
                decoration: BoxDecoration(
                  color: AppColors.primary.withValues(alpha: 0.2),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  widget.experience.period,
                  style: AppTextStyles.bodySmall(context).copyWith(
                    color: AppColors.primaryLight,
                    fontWeight: FontWeight.w600,
                    fontSize: 12,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Text(
            widget.experience.description,
            style: AppTextStyles.bodyMedium(context),
          ),
          const SizedBox(height: 16),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: widget.experience.technologies
                .map((tech) => Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 10,
                        vertical: 6,
                      ),
                      decoration: BoxDecoration(
                        color: AppColors.surfaceLight,
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Text(
                        tech,
                        style: AppTextStyles.bodySmall(context).copyWith(
                          fontSize: 12,
                        ),
                      ),
                    ))
                .toList(),
          ),
        ],
            ),
          ),
        );
      },
    );
  }
}

