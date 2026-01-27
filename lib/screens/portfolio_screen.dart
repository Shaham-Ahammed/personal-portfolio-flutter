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
  bool _homeSectionVisible = false;
  
  // Callbacks to reset animations
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

    final double scrollPosition = _scrollController.offset;
    final double screenHeight = MediaQuery.of(context).size.height;

    // Determine current section based on scroll position
    int newSection = (scrollPosition / screenHeight).round();
    newSection = newSection.clamp(0, 4);

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

  void _scrollToSection(int sectionIndex) {
    final double screenHeight = MediaQuery.of(context).size.height;
    final double targetOffset = sectionIndex * screenHeight;

    _scrollController.animateTo(
      targetOffset,
      duration: const Duration(milliseconds: 800),
      curve: Curves.easeInOut,
    );
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
    return Scaffold(
      backgroundColor: AppColors.background,
      body: Stack(
        children: [
          // Main Scrollable Content
          SingleChildScrollView(
            controller: _scrollController,
            physics: const BouncingScrollPhysics(),
            child: Column(
              children: [
                SizedBox(
                  height: MediaQuery.of(context).size.height,
                  child: HomeSection(key: _homeSectionKey),
                ),
                SizedBox(
                  // height: MediaQuery.of(context).size.height,
                  child: const AboutSection(),
                ),
                SizedBox(
                  // height: MediaQuery.of(context).size.height,
                  child: ProjectsSection(
                    onRegisterReset: (resetCallback) {
                      _resetProjectsAnimations = resetCallback;
                    },
                  ),
                ),
                SizedBox(
                  // height: MediaQuery.of(context).size.height,
                  child: ExperienceSection(
                    onRegisterReset: (resetCallback) {
                      _resetExperienceAnimations = resetCallback;
                    },
                  ),
                ),
                SizedBox(
                  // height: MediaQuery.of(context).size.height,
                  child: ContactSection(
                    onRegisterReset: (resetCallback) {
                      _resetContactAnimations = resetCallback;
                    },
                  ),
                ),
              ],
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
    );
  }
}

