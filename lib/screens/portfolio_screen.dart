import 'package:flutter/gestures.dart';
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
  
  // Auto-scroll snap variables
  bool _isAutoScrolling = false;

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
    if (!_scrollController.hasClients) return;

    try {
      final screenSize = MediaQuery.of(context).size;
      final screenHeight = screenSize.height;
      final isMobile = screenSize.width < 768;
      
      // Use scroll offset to determine home section visibility
      // Home section is visible when scroll offset is near 0
      final scrollOffset = _scrollController.offset;
      
      // Calculate how much of the screen is showing the home section
      // When scrollOffset = 0, home is 100% visible
      // When scrollOffset >= screenHeight, home is 0% visible
      final homeVisibilityPercentage = 1.0 - (scrollOffset / screenHeight).clamp(0.0, 1.0);
      
      // Use lower threshold for mobile (85%) to account for nav bar, etc.
      final visibilityThreshold = isMobile ? 0.85 : 0.95;
      final isVisible = homeVisibilityPercentage >= visibilityThreshold;

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
  
  /// Called when user stops scrolling - triggers snap if needed
  void _onScrollEnd() {
    if (_isAutoScrolling || !_scrollController.hasClients) return;
    
    final scrollOffset = _scrollController.offset;
    final screenHeight = MediaQuery.of(context).size.height;
    
    // Only apply snap between Home and About sections
    if (scrollOffset > 0 && scrollOffset < screenHeight) {
      final snapThreshold = 0.3; // 30% visibility triggers snap
      
      // If scrolled more than 70% (Home only 30% visible), snap to About
      if (scrollOffset >= screenHeight * (1 - snapThreshold)) {
        _snapToOffset(screenHeight);
      }
      // If scrolled less than 30% (About only 30% visible), snap to Home
      else if (scrollOffset <= screenHeight * snapThreshold) {
        _snapToOffset(0);
      }
      // In between (30% to 70%), snap to the closer section
      else if (scrollOffset >= screenHeight * 0.5) {
        _snapToOffset(screenHeight);
      } else {
        _snapToOffset(0);
      }
    }
  }
  
  void _snapToOffset(double targetOffset) {
    if (_isAutoScrolling) return;
    
    _isAutoScrolling = true;
    _scrollController.animateTo(
      targetOffset,
      duration: const Duration(milliseconds: 400),
      curve: Curves.easeOutCubic,
    ).then((_) {
      if (mounted) {
        _isAutoScrolling = false;
      }
    });
  }

  int _calculateCurrentSection() {
    final screenHeight = MediaQuery.of(context).size.height;
    final scrollOffset = _scrollController.hasClients ? _scrollController.offset : 0.0;
    
    // Home section is fixed, so check scroll offset first
    // If we haven't scrolled past the home section height, we're on home
    if (scrollOffset < screenHeight * 0.5) {
      return 0; // Home section
    }
    
    // For other sections, calculate based on their position in the scroll view
    final sectionKeys = [
      _aboutSectionKey,
      _projectsSectionKey,
      _experienceSectionKey,
      _contactSectionKey,
    ];

    final viewportCenter = screenHeight / 2;
    
    int closestSection = 1; // Default to About section
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
          closestSection = i + 1; // +1 because index 0 is Home
        }
      } catch (e) {
        // Silently handle errors
      }
    }

    return closestSection;
  }

  void _scrollToSection(int sectionIndex) {
    if (sectionIndex < 0 || sectionIndex > 4) return;
    
    // Special case for Home section - scroll to top
    if (sectionIndex == 0) {
      _scrollController.animateTo(
        0,
        duration: const Duration(milliseconds: 800),
        curve: Curves.easeInOut,
      );
      return;
    }
    
    final sectionKeys = [
      _aboutSectionKey,
      _projectsSectionKey,
      _experienceSectionKey,
      _contactSectionKey,
    ];

    final keyIndex = sectionIndex - 1; // Adjust for Home being index 0
    if (keyIndex < 0 || keyIndex >= sectionKeys.length) return;

    final key = sectionKeys[keyIndex];
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
    final screenHeight = MediaQuery.of(context).size.height;
    
    // Define the two categories
    final homeSection = SizedBox(
      key: _homeSectionKey,
      height: screenHeight,
      child: const HomeSection(),
    );
    
    final stackingSections = [
      SizedBox(
        key: _aboutSectionKey,
        child: AboutSection(
          onRegisterReset: (resetCallback) {
            _resetAboutAnimations = resetCallback;
          },
          isFirstStackingSection: true,
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
    ];
    
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
            // ===== CATEGORY 1: Home Section (Fixed at back) =====
            // Wrapped with scroll gesture handling so scrolling works from Home
            Positioned(
              top: 0,
              left: 0,
              right: 0,
              height: screenHeight,
              child: _ScrollableHomeSection(
                scrollController: _scrollController,
                onScrollEnd: _onScrollEnd,
                child: homeSection,
              ),
            ),
            
            // ===== CATEGORY 2: Stacking Sections (Scroll over home) =====
            _StackingSectionsScrollView(
              scrollController: _scrollController,
              spacerHeight: screenHeight,
              sections: stackingSections,
              onScrollEnd: _onScrollEnd,
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

/// Wraps the Home section to handle scroll gestures (mouse wheel & touch)
/// while allowing all other interactions to pass through to child widgets.
/// Uses raw pointer events which don't compete in the gesture arena.
class _ScrollableHomeSection extends StatefulWidget {
  final ScrollController scrollController;
  final VoidCallback? onScrollEnd;
  final Widget child;

  const _ScrollableHomeSection({
    required this.scrollController,
    this.onScrollEnd,
    required this.child,
  });

  @override
  State<_ScrollableHomeSection> createState() => _ScrollableHomeSectionState();
}

class _ScrollableHomeSectionState extends State<_ScrollableHomeSection> {
  // Track active pointers for touch scrolling
  final Map<int, Offset> _pointerPositions = {};
  bool _hasScrolled = false;
  
  void _handleScroll(double delta) {
    if (!widget.scrollController.hasClients) return;
    _hasScrolled = true;
    
    final maxExtent = widget.scrollController.position.maxScrollExtent;
    final newOffset = widget.scrollController.offset + delta;
    widget.scrollController.jumpTo(newOffset.clamp(0.0, maxExtent));
  }

  @override
  Widget build(BuildContext context) {
    return Listener(
      behavior: HitTestBehavior.translucent,
      // Mouse wheel scrolling
      onPointerSignal: (event) {
        if (event is PointerScrollEvent) {
          _handleScroll(event.scrollDelta.dy);
          // Trigger scroll end after a short delay for mouse wheel
          Future.delayed(const Duration(milliseconds: 200), () {
            if (_hasScrolled) {
              _hasScrolled = false;
              widget.onScrollEnd?.call();
            }
          });
        }
      },
      // Track touch pointer positions for scrolling
      onPointerDown: (event) {
        _pointerPositions[event.pointer] = event.position;
      },
      onPointerMove: (event) {
        final lastPosition = _pointerPositions[event.pointer];
        if (lastPosition != null) {
          final delta = event.position - lastPosition;
          // Only scroll if primarily vertical movement
          if (delta.dy.abs() > delta.dx.abs() && delta.dy.abs() > 2) {
            _handleScroll(-delta.dy);
          }
          _pointerPositions[event.pointer] = event.position;
        }
      },
      onPointerUp: (event) {
        _pointerPositions.remove(event.pointer);
        // Trigger scroll end when user lifts finger
        if (_hasScrolled && _pointerPositions.isEmpty) {
          _hasScrolled = false;
          widget.onScrollEnd?.call();
        }
      },
      onPointerCancel: (event) {
        _pointerPositions.remove(event.pointer);
        if (_hasScrolled && _pointerPositions.isEmpty) {
          _hasScrolled = false;
          widget.onScrollEnd?.call();
        }
      },
      // Child receives all events - Listener doesn't block anything
      child: widget.child,
    );
  }
}

/// Scroll view for stacking sections with a transparent spacer area.
/// Uses AbsorbPointer to block events in the spacer area so Home section
/// can receive them, while allowing events through to sections.
class _StackingSectionsScrollView extends StatefulWidget {
  final ScrollController scrollController;
  final double spacerHeight;
  final List<Widget> sections;
  final VoidCallback? onScrollEnd;

  const _StackingSectionsScrollView({
    required this.scrollController,
    required this.spacerHeight,
    required this.sections,
    this.onScrollEnd,
  });

  @override
  State<_StackingSectionsScrollView> createState() => _StackingSectionsScrollViewState();
}

class _StackingSectionsScrollViewState extends State<_StackingSectionsScrollView> {
  double _scrollOffset = 0;

  @override
  void initState() {
    super.initState();
    widget.scrollController.addListener(_onScroll);
  }

  void _onScroll() {
    if (mounted) {
      setState(() {
        _scrollOffset = widget.scrollController.offset;
      });
    }
  }

  @override
  void dispose() {
    widget.scrollController.removeListener(_onScroll);
    super.dispose();
  }
  
  bool _onScrollNotification(ScrollNotification notification) {
    if (notification is ScrollEndNotification) {
      widget.onScrollEnd?.call();
    }
    return false;
  }

  @override
  Widget build(BuildContext context) {
    // When we're in the spacer area (showing Home section),
    // ignore ALL pointer events so they pass through to Home section.
    // Only become interactive when sections are visible.
    final isInSpacerArea = _scrollOffset < widget.spacerHeight;

    return IgnorePointer(
      // Ignore events when in spacer area - lets Home section receive them
      ignoring: isInSpacerArea,
      child: NotificationListener<ScrollNotification>(
        onNotification: _onScrollNotification,
        child: SingleChildScrollView(
          controller: widget.scrollController,
          physics: const ClampingScrollPhysics(),
          child: Column(
            children: [
              // Spacer for home section
              SizedBox(height: widget.spacerHeight),
              // Stacking sections
              ...widget.sections,
            ],
          ),
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

