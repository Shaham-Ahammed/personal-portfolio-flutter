import 'package:flutter/material.dart';
import '../widgets/navigation_bar.dart';
import '../widgets/home_section.dart';
import '../widgets/about_section.dart';
import '../widgets/projects_section.dart';
import '../widgets/experience_section.dart';
import '../widgets/contact_section.dart';
import '../constants/colors.dart';

class PortfolioScreen extends StatefulWidget {
  const PortfolioScreen({super.key});

  @override
  State<PortfolioScreen> createState() => _PortfolioScreenState();
}

class _PortfolioScreenState extends State<PortfolioScreen>
    with WidgetsBindingObserver {
  final ScrollController _scrollController = ScrollController();
  int _currentSection = 0;
  final GlobalKey _homeSectionKey = GlobalKey();
  final GlobalKey _aboutSectionKey = GlobalKey();
  final GlobalKey _projectsSectionKey = GlobalKey();
  final GlobalKey _experienceSectionKey = GlobalKey();
  final GlobalKey _contactSectionKey = GlobalKey();
  bool _homeSectionVisible = false;
  
  // Cursor glow position
  Offset _cursorPosition = Offset.zero;
  bool _isCursorInside = false;
  
  // Callbacks to reset animations
  VoidCallback? _resetAboutAnimations;
  VoidCallback? _resetProjectsAnimations;
  VoidCallback? _resetExperienceAnimations;
  VoidCallback? _resetContactAnimations;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _scrollController.addListener(_onScroll);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _checkHomeSectionVisibility();
      _startPeriodicHomeVisibilityCheck();
    });
  }

  void _startPeriodicHomeVisibilityCheck() {
    Future.delayed(const Duration(milliseconds: 200), () {
      if (mounted) {
        _checkHomeSectionVisibility();
        _startPeriodicHomeVisibilityCheck();
      }
    });
  }

  void _checkHomeSectionVisibility() {
    if (!mounted) return;

    final context = _homeSectionKey.currentContext;
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
        final isVisible = isInViewport && visibilityPercentage >=1; // 100% visible

        if (isVisible && !_homeSectionVisible && mounted) {
          setState(() {
            _homeSectionVisible = true;
          });
          // Reset animations when home section becomes visible
          _resetAboutAnimations?.call();
          _resetProjectsAnimations?.call();
          _resetExperienceAnimations?.call();
          _resetContactAnimations?.call();
        } else if (!isVisible && _homeSectionVisible && mounted) {
          setState(() {
            _homeSectionVisible = false;
          });
        }
      }
    } catch (e) {
      // Silently handle errors
    }
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed && mounted) {
      _checkHomeSectionVisibility();
    }
  }

  void _onScroll() {
    if (!_scrollController.hasClients) return;

    // Determine current section based on which section is most visible
    final int newSection = _calculateCurrentSection();

    if (newSection != _currentSection) {
      setState(() {
        _currentSection = newSection;
      });
    }
    
    // Check home section visibility on scroll
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        _checkHomeSectionVisibility();
      }
    });
  }

  int _calculateCurrentSection() {
    final sectionKeys = [
      _homeSectionKey,
      _aboutSectionKey,
      _projectsSectionKey,
      _experienceSectionKey,
      _contactSectionKey,
    ];

    final screenHeight = MediaQuery.of(context).size.height;
    final viewportCenter = screenHeight / 2;
    
    int closestSection = 0;
    double closestDistance = double.infinity;

    for (int i = 0; i < sectionKeys.length; i++) {
      final key = sectionKeys[i];
      final context = key.currentContext;
      if (context == null) continue;

      final RenderBox? renderBox = context.findRenderObject() as RenderBox?;
      if (renderBox == null || !renderBox.hasSize) continue;

      try {
        final position = renderBox.localToGlobal(Offset.zero);
        final sectionTop = position.dy;
        final sectionHeight = renderBox.size.height;
        final sectionCenter = sectionTop + (sectionHeight / 2);
        
        // Calculate distance from section center to viewport center
        final distance = (sectionCenter - viewportCenter).abs();
        
        if (distance < closestDistance) {
          closestDistance = distance;
          closestSection = i;
        }
      } catch (e) {
        // Silently handle errors
      }
    }

    return closestSection;
  }

  void _scrollToSection(int sectionIndex) {
    final sectionKeys = [
      _homeSectionKey,
      _aboutSectionKey,
      _projectsSectionKey,
      _experienceSectionKey,
      _contactSectionKey,
    ];

    if (sectionIndex < 0 || sectionIndex >= sectionKeys.length) return;

    final key = sectionKeys[sectionIndex];
    final context = key.currentContext;
    if (context == null) return;

    final RenderBox? renderBox = context.findRenderObject() as RenderBox?;
    if (renderBox == null) return;

    try {
      final position = renderBox.localToGlobal(Offset.zero);
      final scrollOffset = _scrollController.offset;
      final targetOffset = scrollOffset + position.dy;

      _scrollController.animateTo(
        targetOffset,
        duration: const Duration(milliseconds: 800),
        curve: Curves.easeInOut,
      );
    } catch (e) {
      // Fallback to old method
      final double screenHeight = MediaQuery.of(this.context).size.height;
      final double targetOffset = sectionIndex * screenHeight;
      _scrollController.animateTo(
        targetOffset,
        duration: const Duration(milliseconds: 800),
        curve: Curves.easeInOut,
      );
    }
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _scrollController.removeListener(_onScroll);
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // Show cursor glow only when not on the first page
    final showCursorGlow = _currentSection != 0 && _isCursorInside;
    
    return Scaffold(
      backgroundColor: AppColors.background,
      body: MouseRegion(
        onEnter: (_) => setState(() => _isCursorInside = true),
        onExit: (_) => setState(() => _isCursorInside = false),
        onHover: (event) {
          setState(() {
            _cursorPosition = event.position;
          });
        },
        child: Stack(
          children: [
            // Main Scrollable Content
            SingleChildScrollView(
              controller: _scrollController,
              physics: const BouncingScrollPhysics(),
              child: Column(
                children: [
                  SizedBox(
                    key: _homeSectionKey,
                    height: MediaQuery.of(context).size.height,
                    child: const HomeSection(),
                  ),
                  SizedBox(
                    key: _aboutSectionKey,
                    child: AboutSection(
                      onRegisterReset: (resetCallback) {
                        _resetAboutAnimations = resetCallback;
                      },
                    ),
                  ),
                  SizedBox(
                    key: _projectsSectionKey,
                    child: ProjectsSection(
                      onRegisterReset: (resetCallback) {
                        _resetProjectsAnimations = resetCallback;
                      },
                    ),
                  ),
                  SizedBox(
                    key: _experienceSectionKey,
                    child: ExperienceSection(
                      onRegisterReset: (resetCallback) {
                        _resetExperienceAnimations = resetCallback;
                      },
                    ),
                  ),
                  SizedBox(
                    key: _contactSectionKey,
                    child: ContactSection(
                      onRegisterReset: (resetCallback) {
                        _resetContactAnimations = resetCallback;
                      },
                    ),
                  ),
                ],
              ),
            ),
            // Cursor Glow Effect (only visible when not on first page)
            if (showCursorGlow)
              Positioned.fill(
                child: IgnorePointer(
                  child: CustomPaint(
                    painter: _CursorGlowPainter(cursorPosition: _cursorPosition),
                  ),
                ),
              ),
            // Navigation Bar (Fixed at top)
            Positioned(
              top: 0,
              left: 0,
              right: 0,
              child: PortfolioNavigationBar(
                currentSection: _currentSection,
                onSectionTap: _scrollToSection,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _CursorGlowPainter extends CustomPainter {
  final Offset cursorPosition;

  _CursorGlowPainter({required this.cursorPosition});

  @override
  void paint(Canvas canvas, Size size) {
    const double radius = 120; // Radius of the glow
    
    final paint = Paint()
      ..shader = RadialGradient(
        colors: [
          const Color(0xFF818CF8).withValues(alpha: 0.18), // Primary Light
          const Color(0xFF6366F1).withValues(alpha: 0.10), // Primary (Indigo)
          const Color(0xFF4F46E5).withValues(alpha: 0.04), // Primary Dark
          Colors.transparent,
        ],
        stops: const [0.0, 0.35, 0.7, 1.0],
      ).createShader(
        Rect.fromCircle(center: cursorPosition, radius: radius),
      );

    canvas.drawCircle(cursorPosition, radius, paint);
  }

  @override
  bool shouldRepaint(_CursorGlowPainter oldDelegate) {
    return oldDelegate.cursorPosition != cursorPosition;
  }
}

