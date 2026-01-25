import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:vector_math/vector_math_64.dart' show Vector3;
import 'package:flutter_staggered_grid_view/flutter_staggered_grid_view.dart';
import '../constants/colors.dart';
import '../constants/text_styles.dart';
import '../constants/portfolio_data.dart';
import '../models/project_model.dart';

class ProjectsSection extends StatefulWidget {
  const ProjectsSection({super.key});

  @override
  State<ProjectsSection> createState() => _ProjectsSectionState();
}

class _ProjectsSectionState extends State<ProjectsSection>
    with WidgetsBindingObserver {
  // Viewport fraction keeps three cards visible (prev/active/next)
  late final PageController _mainProjectsController;
  int _currentMainProjectIndex = 0;
  final GlobalKey _miniProjectsKey = GlobalKey();
  bool _miniProjectsAnimated = false;

  @override
  void initState() {
    super.initState();
    // Calculate initial page to show first item (index 0)
    final allProjects = PortfolioData.projects
        .map((project) => Project.fromMap(project))
        .toList();
    final mainProjects = allProjects
        .where((p) => p.type == ProjectType.main)
        .toList();
    final projectsCount = mainProjects.length;
    // Set initial page to a multiple of projectsCount to ensure it shows index 0
    final initialPage = projectsCount > 0
        ? (1000 ~/ projectsCount) * projectsCount
        : 1000;

    _mainProjectsController = PageController(
      viewportFraction: 0.62,
      initialPage: initialPage,
    );

    // Ensure indicator shows first item on initial load
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted && projectsCount > 0) {
        setState(() {
          _currentMainProjectIndex = initialPage % projectsCount;
        });
      }
      // Check mini projects visibility on initial load and periodically
      _checkMiniProjectsVisibility();
      _startPeriodicVisibilityCheck();
    });
    
    // Add observer to check visibility when app resumes
    WidgetsBinding.instance.addObserver(this);
  }
  
  void _startPeriodicVisibilityCheck() {
    // Check visibility periodically (every 100ms) continuously
    Future.delayed(const Duration(milliseconds: 100), () {
      if (mounted) {
        _checkMiniProjectsVisibility();
        _startPeriodicVisibilityCheck();
      }
    });
  }
  
  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed && mounted) {
      _checkMiniProjectsVisibility();
    }
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _mainProjectsController.dispose();
    super.dispose();
  }

  void _checkMiniProjectsVisibility() {
    if (!mounted) {
      return;
    }

    final context = _miniProjectsKey.currentContext;
    if (context == null || !context.mounted) return;

    final RenderBox? renderBox = context.findRenderObject() as RenderBox?;
    if (renderBox == null || !renderBox.hasSize) return;

    try {
      final position = renderBox.localToGlobal(Offset.zero);
      final widgetSize = renderBox.size;
      
      // Get screen size and viewport info
      final screenSize = MediaQuery.of(context).size;
      final screenHeight = screenSize.height;
      
      // Account for any app bars or padding at the top
      final viewportTop = 0.0; // Top of visible screen
      final viewportBottom = screenHeight; // Bottom of visible screen

      // Widget position relative to screen
      final widgetTop = position.dy;
      final widgetBottom = widgetTop + widgetSize.height;

      // Calculate how much of the widget is visible in the viewport
      final visibleTop = widgetTop.clamp(viewportTop, viewportBottom);
      final visibleBottom = widgetBottom.clamp(viewportTop, viewportBottom);
      final visibleHeight = (visibleBottom - visibleTop).clamp(0.0, widgetSize.height);

      // Check if 70% of the widget is visible
      if (widgetSize.height > 0) {
        final visibilityPercentage = visibleHeight / widgetSize.height;
        
        // Also check if widget is at least partially in viewport
        final isInViewport = widgetBottom > viewportTop && widgetTop < viewportBottom;
        final shouldBeAnimated = isInViewport && visibilityPercentage >= 0.7;
        
        // Check if widget is completely out of view (100% not visible)
        final isCompletelyOutOfView = widgetBottom <= viewportTop || widgetTop >= viewportBottom;
        
        // Update animation state based on visibility
        if (shouldBeAnimated && !_miniProjectsAnimated && mounted) {
          // Section became 70% visible - trigger animation
          setState(() {
            _miniProjectsAnimated = true;
          });
        } else if (isCompletelyOutOfView && _miniProjectsAnimated && mounted) {
          // Section is 100% out of view - reset to invisible for next time
          setState(() {
            _miniProjectsAnimated = false;
          });
        }
      }
    } catch (e) {
      // Silently handle any errors in visibility calculation
      // This can happen during layout or if widget is not yet rendered
    }
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final isMobile = size.width < 768;

    final allProjects = PortfolioData.projects
        .map((project) => Project.fromMap(project))
        .toList();

    final mainProjects = allProjects
        .where((p) => p.type == ProjectType.main)
        .toList();
    final miniProjects = allProjects
        .where((p) => p.type == ProjectType.mini)
        .toList();

    return NotificationListener<ScrollNotification>(
      onNotification: (notification) {
        // Listen to scroll notifications from parent scroll view
        if (notification is ScrollUpdateNotification ||
            notification is ScrollEndNotification ||
            notification is ScrollStartNotification) {
          WidgetsBinding.instance.addPostFrameCallback((_) {
            if (mounted) {
              _checkMiniProjectsVisibility();
            }
          });
        }
        return false; // Allow notification to bubble up
      },
      child: Container(
        width: double.infinity,
        constraints: BoxConstraints(minHeight: size.height),
        color: AppColors.background,
        padding: EdgeInsets.symmetric(
          horizontal: isMobile ? 20 : 60,
          vertical: isMobile ? 60 : 100,
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('PROJECTS', style: AppTextStyles.sectionTitle(context)),
            const SizedBox(height: 12),
            Text(
              'Some Things I\'ve Build',
              style: AppTextStyles.heading4(context),
            ),
            const SizedBox(height: 50),

            // Main Projects Section
            if (mainProjects.isNotEmpty) ...[
              _VisibilityDetectedMainProjects(
                child: _buildMainProjectsCarousel(context, mainProjects, isMobile),
              ),
              const SizedBox(height: 80),
            ],

            // Mini Projects Section
            if (miniProjects.isNotEmpty) ...[
              Text('Mini Projects', style: AppTextStyles.heading3(context)),
              const SizedBox(height: 24),
              _buildMiniProjectsList(context, miniProjects, isMobile),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildMainProjectsCarousel(
    BuildContext context,
    List<Project> projects,
    bool isMobile,
  ) {
    // For circular effect, we map page index to project index with modulo.
    return Column(
      children: [
        SizedBox(
          height: isMobile ? 520 : 460,
          child: Stack(
            children: [
              PageView.builder(
                controller: _mainProjectsController,
                onPageChanged: (index) {
                  final realIndex = index % projects.length;
                  setState(() {
                    _currentMainProjectIndex = realIndex;
                  });
                },
                // Large itemCount to allow long scrolling; modulo picks actual project
                itemCount: projects.length * 2000,
                itemBuilder: (context, index) {
                  final realIndex = index % projects.length;
                  return AnimatedBuilder(
                    animation: _mainProjectsController,
                    builder: (context, child) {
                      double delta = 0.0;
                      if (_mainProjectsController.position.haveDimensions) {
                        delta = (_mainProjectsController.page ?? 0) - index;
                      }

                      // Clamp to keep animation stable
                      final clamped = delta.clamp(-1.0, 1.0);

                      // Roller-like curved stack: neighbors curve away, center pops
                      final rotationY = clamped * 0.9; // stronger curve
                      // Scale animates with page drag; side cards drop to 0.6, center to 1
                      final scale = (1 - (clamped.abs() * 0.4)).clamp(0.6, 1.0);
                      final translateZ =
                          -80 * clamped.abs(); // curve back slightly
                      // push side cards outward to avoid overlap
                      final translateX = clamped * (isMobile ? 30 : 70);
                      final opacity = 1 - (clamped.abs() * 0.35);

                      // Hide far items to keep only 3 visible
                      if (clamped.abs() > 1.2) {
                        return const SizedBox.shrink();
                      }

                      return Transform(
                        alignment: Alignment.center,
                        transform: Matrix4.identity()
                          ..setEntry(3, 2, 0.001)
                          ..translateByVector3(
                            Vector3(translateX, 0.0, translateZ),
                          )
                          ..rotateY(rotationY)
                          ..scaleByVector3(Vector3(scale, scale, scale)),
                        child: Opacity(
                          opacity: opacity,
                          child: Padding(
                            padding: EdgeInsets.symmetric(
                              horizontal: isMobile ? 12 : 20,
                              vertical: 12,
                            ),
                            child: _MainProjectCard(
                              project: projects[realIndex],
                              isMobile: isMobile,
                              index: realIndex,
                              currentIndex: _currentMainProjectIndex,
                            ),
                          ),
                        ),
                      );
                    },
                  );
                },
              ),
              // Navigation Buttons
              if (!isMobile && projects.length > 1)
                Positioned(
                  left: 0,
                  top: 0,
                  bottom: 0,
                  child: Center(
                    child: _NavigationButton(
                      icon: Icons.arrow_back_ios,
                      onTap: () {
                        _mainProjectsController.previousPage(
                          duration: const Duration(milliseconds: 400),
                          curve: Curves.easeInOut,
                        );
                      },
                      isEnabled: true,
                    ),
                  ),
                ),
              if (!isMobile && projects.length > 1)
                Positioned(
                  right: 0,
                  top: 0,
                  bottom: 0,
                  child: Center(
                    child: _NavigationButton(
                      icon: Icons.arrow_forward_ios,
                      onTap: () {
                        _mainProjectsController.nextPage(
                          duration: const Duration(milliseconds: 400),
                          curve: Curves.easeInOut,
                        );
                      },
                      isEnabled: true,
                    ),
                  ),
                ),
            ],
          ),
        ),
        const SizedBox(height: 32),
        _buildInteractiveIndicator(projects.length),
      ],
    );
  }

  Widget _buildInteractiveIndicator(int count) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: List.generate(
        count,
        (index) => AnimatedContainer(
          duration: const Duration(milliseconds: 300),
          margin: const EdgeInsets.symmetric(horizontal: 6),
          width: _currentMainProjectIndex == index ? 32 : 10,
          height: 10,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(5),
            gradient: _currentMainProjectIndex == index
                ? AppColors.primaryGradient
                : null,
            color: _currentMainProjectIndex == index
                ? null
                : AppColors.primaryLight.withValues(alpha: 0.3),
            boxShadow: _currentMainProjectIndex == index
                ? [
                    BoxShadow(
                      color: AppColors.primary.withValues(alpha: 0.5),
                      blurRadius: 8,
                      spreadRadius: 1,
                    ),
                  ]
                : null,
          ),
        ),
      ),
    );
  }

  Widget _buildMiniProjectsList(
    BuildContext context,
    List<Project> projects,
    bool isMobile,
  ) {
    return SizedBox(
      key: _miniProjectsKey,
      height: isMobile ? 360 : 400,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        itemCount: projects.length,
        itemBuilder: (context, index) {
          return Container(
            width: isMobile ? 300 : 340,
            margin: EdgeInsets.only(
              right: index < projects.length - 1 ? 24 : 0,
            ),
            child: _AnimatedMiniProjectCard(
              project: projects[index],
              isMobile: isMobile,
              index: index,
              shouldAnimate: _miniProjectsAnimated,
            ),
          );
        },
      ),
    );
  }
}

class _VisibilityDetectedMainProjects extends StatefulWidget {
  final Widget child;

  const _VisibilityDetectedMainProjects({
    required this.child,
  });

  @override
  State<_VisibilityDetectedMainProjects> createState() =>
      _VisibilityDetectedMainProjectsState();
}

class _VisibilityDetectedMainProjectsState
    extends State<_VisibilityDetectedMainProjects>
    with TickerProviderStateMixin, WidgetsBindingObserver {
  final GlobalKey _widgetKey = GlobalKey();
  late AnimationController _fadeController;
  late Animation<double> _fadeAnimation;
  bool _hasAnimated = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    
    // Initialize fade animation controller
    _fadeController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 800),
    );
    
    // Fade animation from 0 to 1
    _fadeAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _fadeController,
      curve: Curves.easeIn,
    ));
    
    // Start with opacity at 0 (invisible)
    _fadeController.value = 0.0;
    
    // Check visibility after first frame
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Future.delayed(const Duration(milliseconds: 300), () {
        if (mounted) {
          _checkVisibility();
          _startPeriodicVisibilityCheck();
        }
      });
    });
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _fadeController.dispose();
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed && mounted) {
      _checkVisibility();
    }
  }

  void _startPeriodicVisibilityCheck() {
    Future.delayed(const Duration(milliseconds: 200), () {
      if (mounted && !_hasAnimated) {
        _checkVisibility();
        _startPeriodicVisibilityCheck();
      }
    });
  }

  void _checkVisibility() {
    if (!mounted || _hasAnimated) return;

    final context = _widgetKey.currentContext;
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
        final shouldFadeIn = isInViewport && visibilityPercentage >= 0.70; // 70% threshold

        if (shouldFadeIn && !_hasAnimated && mounted) {
          setState(() {
            _hasAnimated = true;
          });
          _fadeController.forward();
        }
      }
    } catch (e) {
      // Silently handle errors
    }
  }

  @override
  Widget build(BuildContext context) {
    return NotificationListener<ScrollNotification>(
      onNotification: (notification) {
        if (notification is ScrollUpdateNotification ||
            notification is ScrollEndNotification ||
            notification is ScrollStartNotification) {
          WidgetsBinding.instance.addPostFrameCallback((_) {
            if (mounted && !_hasAnimated) {
              _checkVisibility();
            }
          });
        }
        return false;
      },
      child: FadeTransition(
        opacity: _fadeAnimation,
        child: Container(
          key: _widgetKey,
          child: widget.child,
        ),
      ),
    );
  }
}

class _MainProjectCard extends StatefulWidget {
  final Project project;
  final bool isMobile;
  final int index;
  final int currentIndex;

  const _MainProjectCard({
    required this.project,
    required this.isMobile,
    required this.index,
    required this.currentIndex,
  });

  @override
  State<_MainProjectCard> createState() => _MainProjectCardState();
}

class _MainProjectCardState extends State<_MainProjectCard>
    with SingleTickerProviderStateMixin {
  bool _isHovered = false;
  late AnimationController _animationController;
  late Animation<double> _scaleAnimation;
  late Animation<double> _glowAnimation;
  late ScrollController _techScrollController;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 300),
    );
    _scaleAnimation = Tween<double>(begin: 1.0, end: 1.02).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeInOut),
    );
    _glowAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeInOut),
    );
    _techScrollController = ScrollController();
  }

  @override
  void dispose() {
    _animationController.dispose();
    _techScrollController.dispose();
    super.dispose();
  }

  void _onHover(bool hover) {
    setState(() {
      _isHovered = hover;
    });
    if (hover) {
      _animationController.forward();
    } else {
      _animationController.reverse();
    }
  }

  Future<void> _launchUrl(String? url) async {
    if (url != null && url.isNotEmpty) {
      final Uri uri = Uri.parse(url);
      if (await canLaunchUrl(uri)) {
        await launchUrl(uri, mode: LaunchMode.externalApplication);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final isActive = widget.index == widget.currentIndex;

    return MouseRegion(
      onEnter: (_) => _onHover(true),
      onExit: (_) => _onHover(false),
      child: AnimatedBuilder(
        animation: _animationController,
        builder: (context, child) {
          return Transform.scale(
            scale: _scaleAnimation.value,
            child: Container(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(28),
                gradient: _isHovered && isActive
                    ? LinearGradient(
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                        colors: [
                          AppColors.primary.withValues(alpha: 0.3),
                          AppColors.primary.withValues(alpha: 0.1),
                        ],
                      )
                    : null,
                boxShadow: [
                  BoxShadow(
                    color: AppColors.primary.withValues(
                      alpha: 0.3 * _glowAnimation.value * (isActive ? 1 : 0.5),
                    ),
                    blurRadius: 30 * _glowAnimation.value,
                    spreadRadius: 5 * _glowAnimation.value,
                  ),
                ],
              ),
              child: Container(
                decoration: BoxDecoration(
                  color: AppColors.surface,
                  borderRadius: BorderRadius.circular(28),
                  border: Border.all(
                    color: isActive
                        ? AppColors.primary.withValues(alpha: 0.5)
                        : AppColors.primary.withValues(alpha: 0.2),
                    width: isActive ? 2 : 1,
                  ),
                ),
                child: widget.isMobile
                    ? _buildMobileLayout()
                    : _buildDesktopLayout(),
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildMobileLayout() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildImageSection(),
        Expanded(
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: _buildContentSection(),
          ),
        ),
      ],
    );
  }

  Widget _buildDesktopLayout() {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Expanded(flex: 5, child: _buildImageSection()),
        Expanded(
          flex: 4,
          child: Padding(
            padding: const EdgeInsets.all(32),
            child: _buildContentSection(),
          ),
        ),
      ],
    );
  }

  Widget _buildImageSection() {
    return GestureDetector(
      onTap: () {
        if (widget.project.galleryImages != null &&
            widget.project.galleryImages!.isNotEmpty) {
          _showGalleryPopup(context);
        }
      },
      child: MouseRegion(
        cursor: SystemMouseCursors.click,
        child: ClipRRect(
          borderRadius: widget.isMobile
              ? const BorderRadius.vertical(top: Radius.circular(28))
              : const BorderRadius.horizontal(left: Radius.circular(28)),
          child: Container(
            height: widget.isMobile ? 200 : double.infinity,
            width: double.infinity,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  AppColors.primary.withValues(alpha: 0.2),
                  AppColors.surfaceLight,
                ],
              ),
            ),
            child: Stack(
              fit: StackFit.expand,
              children: [
                Image.network(
                  widget.project.imageUrl,
                  fit: BoxFit.cover,
                  errorBuilder: (context, error, stackTrace) {
                    return Container(
                      color: AppColors.surfaceLight,
                      child: const Icon(
                        Icons.image,
                        size: 60,
                        color: AppColors.textTertiary,
                      ),
                    );
                  },
                ),
                Container(
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                      colors: [
                        Colors.transparent,
                        AppColors.background.withValues(alpha: 0.6),
                      ],
                    ),
                  ),
                ),
                if (_isHovered && widget.index == widget.currentIndex)
                  Container(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.centerLeft,
                        end: Alignment.centerRight,
                        colors: [
                          AppColors.primary.withValues(alpha: 0.1),
                          Colors.transparent,
                        ],
                      ),
                    ),
                  ),
                if (widget.project.galleryImages != null &&
                    widget.project.galleryImages!.isNotEmpty)
                  Positioned(
                    top: 12,
                    right: 12,
                    child: Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: AppColors.background.withValues(alpha: 0.8),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: const Icon(
                        Icons.collections,
                        color: AppColors.primaryLight,
                        size: 20,
                      ),
                    ),
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  void _showGalleryPopup(BuildContext context) {
    final random = DateTime.now().millisecondsSinceEpoch % 2;
    final isFromTopLeft = random == 0;

    showDialog(
      context: context,
      barrierColor: Colors.black.withValues(alpha: 0.8),
      builder: (context) => _ProjectGalleryPopup(
        project: widget.project,
        isFromTopLeft: isFromTopLeft,
      ),
    );
  }

  Widget _buildContentSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  width: 4,
                  height: 24,
                  decoration: BoxDecoration(
                    gradient: AppColors.primaryGradient,
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    widget.project.title,
                    style: AppTextStyles.heading3(context),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Text(
              widget.project.description,
              style: AppTextStyles.bodyMedium(context),
              maxLines: widget.isMobile ? 4 : 6,
              overflow: TextOverflow.ellipsis,
            ),
          ],
        ),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            MouseRegion(
              cursor: SystemMouseCursors.grab,
              child: SizedBox(
                height: 40,
                child: InteractiveViewer(
                  constrained: false,
                  panEnabled: true,
                  scaleEnabled: false,
                  minScale: 1.0,
                  maxScale: 1.0,
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: widget.project.technologies.asMap().entries.map((
                      entry,
                    ) {
                      final index = entry.key;
                      final tech = entry.value;
                      return Container(
                        margin: EdgeInsets.only(
                          right: index < widget.project.technologies.length - 1
                              ? 8
                              : 0,
                        ),
                        padding: const EdgeInsets.symmetric(
                          horizontal: 14,
                          vertical: 8,
                        ),
                        decoration: BoxDecoration(
                          gradient: AppColors.primaryGradient,
                          borderRadius: BorderRadius.circular(20),
                          boxShadow: [
                            BoxShadow(
                              color: AppColors.primary.withValues(alpha: 0.3),
                              blurRadius: 8,
                              spreadRadius: 0,
                            ),
                          ],
                        ),
                        child: Text(
                          tech,
                          style: AppTextStyles.bodySmall(context).copyWith(
                            fontSize: 12,
                            color: Colors.white,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      );
                    }).toList(),
                  ),
                ),
              ),
            ),
            const SizedBox(height: 24),
            SizedBox(
              height: 48,
              child: InteractiveViewer(
                constrained: false,
                panEnabled: true,
                scaleEnabled: false,
                minScale: 1.0,
                maxScale: 1.0,
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    if (widget.project.githubUrl != null) ...[
                      _ActionButton(
                        icon: Icons.code,
                        label: 'Code',
                        onTap: () => _launchUrl(widget.project.githubUrl),
                      ),
                      const SizedBox(width: 12),
                    ],
                    if (widget.project.iosUrl != null) ...[
                      _ActionButton(
                        icon: Icons.phone_iphone,
                        label: 'iOS',
                        onTap: () => _launchUrl(widget.project.iosUrl),
                      ),
                      const SizedBox(width: 12),
                    ],
                    if (widget.project.androidUrl != null) ...[
                      _ActionButton(
                        icon: Icons.android,
                        label: 'Android',
                        onTap: () => _launchUrl(widget.project.androidUrl),
                      ),
                      const SizedBox(width: 12),
                    ],
                    if (widget.project.userAndroidUrl != null) ...[
                      _ActionButton(
                        icon: Icons.android,
                        label: 'User App',
                        onTap: () => _launchUrl(widget.project.userAndroidUrl),
                      ),
                      const SizedBox(width: 12),
                    ],
                    if (widget.project.adminAndroidUrl != null) ...[
                      _ActionButton(
                        icon: Icons.android,
                        label: 'Admin App',
                        onTap: () => _launchUrl(widget.project.adminAndroidUrl),
                      ),
                      const SizedBox(width: 12),
                    ],
                    if (widget.project.webUrl != null)
                      _ActionButton(
                        icon: Icons.language,
                        label: 'Web',
                        onTap: () => _launchUrl(widget.project.webUrl),
                      ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }
}

class _NavigationButton extends StatefulWidget {
  final IconData icon;
  final VoidCallback onTap;
  final bool isEnabled;

  const _NavigationButton({
    required this.icon,
    required this.onTap,
    required this.isEnabled,
  });

  @override
  State<_NavigationButton> createState() => _NavigationButtonState();
}

class _NavigationButtonState extends State<_NavigationButton>
    with SingleTickerProviderStateMixin {
  bool _isHovered = false;
  late AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 200),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      onEnter: (_) {
        if (widget.isEnabled) {
          setState(() => _isHovered = true);
          _controller.forward();
        }
      },
      onExit: (_) {
        setState(() => _isHovered = false);
        _controller.reverse();
      },
      child: GestureDetector(
        onTap: widget.isEnabled ? widget.onTap : null,
        child: AnimatedBuilder(
          animation: _controller,
          builder: (context, child) {
            return Transform.scale(
              scale: 1.0 + (_controller.value * 0.1),
              child: Container(
                width: 50,
                height: 50,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: widget.isEnabled && _isHovered
                      ? AppColors.primaryGradient
                      : null,
                  color: widget.isEnabled
                      ? AppColors.surface.withValues(alpha: 0.8)
                      : AppColors.surface.withValues(alpha: 0.3),
                  border: Border.all(
                    color: widget.isEnabled
                        ? AppColors.primary.withValues(alpha: 0.5)
                        : AppColors.primary.withValues(alpha: 0.2),
                    width: 1.5,
                  ),
                  boxShadow: widget.isEnabled && _isHovered
                      ? [
                          BoxShadow(
                            color: AppColors.primary.withValues(alpha: 0.5),
                            blurRadius: 15,
                            spreadRadius: 2,
                          ),
                        ]
                      : null,
                ),
                child: Icon(
                  widget.icon,
                  color: widget.isEnabled
                      ? AppColors.primaryLight
                      : AppColors.textTertiary,
                  size: 20,
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}

class _AnimatedMiniProjectCard extends StatefulWidget {
  final Project project;
  final bool isMobile;
  final int index;
  final bool shouldAnimate;

  const _AnimatedMiniProjectCard({
    required this.project,
    required this.isMobile,
    required this.index,
    required this.shouldAnimate,
  });

  @override
  State<_AnimatedMiniProjectCard> createState() =>
      _AnimatedMiniProjectCardState();
}

class _AnimatedMiniProjectCardState extends State<_AnimatedMiniProjectCard>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _slideAnimation;
  late Animation<double> _opacityAnimation;
  late Animation<double> _forwardAnimation;
  bool _hasAnimated = false;

  @override
  void initState() {
    super.initState();
    // Total duration should accommodate all staggered animations
    // Assuming max 10 cards: 10 * 0.1s delay + 0.8s animation = 1.8s (increased for bounce effect)
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1800),
    );

    // Calculate staggered delay - each card starts 0.1 seconds (100ms) after the previous
    // Convert to fraction of total duration (1800ms)
    final delaySeconds = widget.index * 0.1;
    final animationDurationSeconds = 0.8; // Increased duration for bounce effect
    final totalDurationSeconds = 1.8;
    
    final delayFraction = (delaySeconds / totalDurationSeconds).clamp(0.0, 1.0);
    final endFraction = ((delaySeconds + animationDurationSeconds) / totalDurationSeconds).clamp(0.0, 1.0);
    
    // Slide animation with overshoot: from left (-200) to overshoot (20) then back to (0)
    _slideAnimation = TweenSequence<double>([
      // First phase: slide from -200 to 20 (overshoot forward)
      TweenSequenceItem(
        tween: Tween<double>(begin: -200.0, end: 20.0)
            .chain(CurveTween(curve: Curves.easeOutCubic)),
        weight: 70.0, // 70% of animation time
      ),
      // Second phase: settle back to 0 (final position)
      TweenSequenceItem(
        tween: Tween<double>(begin: 20.0, end: 0.0)
            .chain(CurveTween(curve: Curves.easeInOut)),
        weight: 30.0, // 30% of animation time
      ),
    ]).animate(
      CurvedAnimation(
        parent: _controller,
        curve: Interval(
          delayFraction,
          endFraction,
          curve: Curves.linear,
        ),
      ),
    );

    // Forward animation (scale/translateZ effect) - goes forward then back
    _forwardAnimation = TweenSequence<double>([
      // First phase: move forward (scale up or translateZ forward)
      TweenSequenceItem(
        tween: Tween<double>(begin: 0.0, end: 1.0)
            .chain(CurveTween(curve: Curves.easeOutCubic)),
        weight: 70.0,
      ),
      // Second phase: settle back to original position
      TweenSequenceItem(
        tween: Tween<double>(begin: 1.0, end: 0.0)
            .chain(CurveTween(curve: Curves.easeInOut)),
        weight: 30.0,
      ),
    ]).animate(
      CurvedAnimation(
        parent: _controller,
        curve: Interval(
          delayFraction,
          endFraction,
          curve: Curves.linear,
        ),
      ),
    );

    // Opacity animation
    _opacityAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(
      CurvedAnimation(
        parent: _controller,
        curve: Interval(
          delayFraction,
          endFraction,
          curve: Curves.easeOut,
        ),
      ),
    );

    // Always start with controller at 0 (invisible/hidden state)
    _controller.value = 0.0;
    
    // Mark as animated when animation completes
    _controller.addStatusListener((status) {
      if (status == AnimationStatus.completed) {
        _hasAnimated = true;
      }
    });
    
    // If shouldAnimate is true and hasn't animated yet, start animation
    if (widget.shouldAnimate && !_hasAnimated) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted && !_hasAnimated) {
          _hasAnimated = true;
          _controller.forward();
        }
      });
    }
  }

  @override
  void didUpdateWidget(_AnimatedMiniProjectCard oldWidget) {
    super.didUpdateWidget(oldWidget);
    
    if (widget.shouldAnimate && !oldWidget.shouldAnimate && !_hasAnimated) {
      // Section became visible - start animation only if not already played
      _hasAnimated = true;
      _controller.reset();
      _controller.forward();
    }
    // Don't reset when section goes out of view - keep the animation state
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // Always use animation wrapper - cards start invisible and animate when shouldAnimate is true
    return AnimatedBuilder(
      animation: _controller,
      builder: (context, child) {
        // Get animation values, with fallbacks
        double slideValue = -200.0; // Start hidden
        double opacityValue = 0.0; // Start invisible
        double forwardValue = 0.0; // Forward effect value
        
        try {
          slideValue = _slideAnimation.value;
          opacityValue = _opacityAnimation.value;
          forwardValue = _forwardAnimation.value;
        } catch (e) {
          // If animation values are invalid, use initial hidden state
          slideValue = -200.0;
          opacityValue = 0.0;
          forwardValue = 0.0;
        }
        
        // Clamp values to valid ranges
        slideValue = slideValue.clamp(-200.0, 20.0); // Allow overshoot
        opacityValue = opacityValue.clamp(0.0, 1.0);
        forwardValue = forwardValue.clamp(0.0, 1.0);
        
        // Calculate forward effect: scale up slightly and translate forward in Z
        final scale = 1.0 + (forwardValue * 0.08); // Scale up to 1.08
        final translateZ = forwardValue * 30.0; // Move forward 30 pixels in Z
        
        return Transform(
          alignment: Alignment.center,
          transform: Matrix4.identity()
            ..setEntry(3, 2, 0.001) // Perspective
            ..translate(slideValue, 0.0)
            ..translateByVector3(Vector3(0.0, 0.0, translateZ))
            ..scale(scale),
          child: Opacity(
            opacity: opacityValue,
            child: _MiniProjectCard(
              project: widget.project,
              isMobile: widget.isMobile,
            ),
          ),
        );
      },
    );
  }
}

class _MiniProjectCard extends StatefulWidget {
  final Project project;
  final bool isMobile;

  const _MiniProjectCard({required this.project, required this.isMobile});

  @override
  State<_MiniProjectCard> createState() => _MiniProjectCardState();
}

class _MiniProjectCardState extends State<_MiniProjectCard>
    with TickerProviderStateMixin {
  bool _isHovered = false;
  bool _imageLoadedSuccessfully = false;
  late AnimationController _hoverController;
  late AnimationController _imageScrollController;
  late Animation<double> _projectionAnimation;
  late Animation<double> _glowAnimation;
  late Animation<double> _imageScrollAnimation;
  Offset _mousePosition = Offset.zero;

  @override
  void initState() {
    super.initState();
    _hoverController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 300),
    );
    _projectionAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _hoverController, curve: Curves.easeOutCubic),
    );
    _glowAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _hoverController, curve: Curves.easeOut),
    );
    
    // Image scroll animation controller - loops back and forth
    _imageScrollController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 3), // 3 seconds for full up-down cycle
    );
    // Animation that goes from 0 to 1 (up) and back to 0 (down) in a loop
    _imageScrollAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _imageScrollController,
        curve: Curves.easeInOut,
      ),
    );
    
    // Initialize mouse position to center
    final cardWidth = widget.isMobile ? 300.0 : 340.0;
    final cardHeight = widget.isMobile ? 360.0 : 400.0;
    _mousePosition = Offset(cardWidth / 2, cardHeight / 2);
    
    // Initialize image loaded state - will be set to true when image loads successfully
    _imageLoadedSuccessfully = false;
  }

  @override
  void dispose() {
    _hoverController.dispose();
    _imageScrollController.dispose();
    super.dispose();
  }

  void _onHover(bool hover) {
    setState(() {
      _isHovered = hover;
      if (!hover) {
        // Reset to center when not hovering
        final cardWidth = widget.isMobile ? 300.0 : 340.0;
        final cardHeight = widget.isMobile ? 360.0 : 400.0;
        _mousePosition = Offset(cardWidth / 2, cardHeight / 2);
      }
    });
    if (hover) {
      _hoverController.forward();
      // Start image scroll animation only if image URL exists and image loaded successfully
      final hasValidImageUrl = widget.project.imageUrl.isNotEmpty;
      if (hasValidImageUrl && _imageLoadedSuccessfully) {
        _imageScrollController.repeat(reverse: true);
      }
    } else {
      _hoverController.reverse();
      // Stop and reset image scroll animation
      _imageScrollController.stop();
      _imageScrollController.reset();
    }
  }

  void _onHoverMove(PointerEvent event) {
    if (_isHovered) {
      setState(() {
        _mousePosition = event.localPosition;
      });
    }
  }

  Future<void> _launchUrl(String? url) async {
    if (url != null && url.isNotEmpty) {
      final Uri uri = Uri.parse(url);
      if (await canLaunchUrl(uri)) {
        await launchUrl(uri, mode: LaunchMode.externalApplication);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Listener(
      onPointerMove: _onHoverMove,
      child: MouseRegion(
        onEnter: (_) => _onHover(true),
        onExit: (_) => _onHover(false),
        child: AnimatedBuilder(
          animation: _hoverController,
          builder: (context, child) {
            // Calculate 3D projection based on mouse position
            final cardWidth = widget.isMobile ? 300.0 : 340.0;
            final cardHeight = widget.isMobile ? 360.0 : 400.0;
            
            // Normalize mouse position to -1 to 1 range
            // Use center as default if not hovered
            final normalizedX = _isHovered && _mousePosition.dx > 0
                ? ((_mousePosition.dx / cardWidth) * 2 - 1).clamp(-1.0, 1.0)
                : 0.0;
            final normalizedY = _isHovered && _mousePosition.dy > 0
                ? ((_mousePosition.dy / cardHeight) * 2 - 1).clamp(-1.0, 1.0)
                : 0.0;
            
            // Apply projection effect only when hovered
            final projectionValue = _projectionAnimation.value;
            final rotateX = normalizedY * 8.0 * projectionValue; // Max 8 degrees
            final rotateY = -normalizedX * 8.0 * projectionValue; // Max 8 degrees
            final translateZ = 50.0 * projectionValue; // Move forward 50px for more elevation
            final scale = 1.0 + (0.08 * projectionValue); // Scale up 8% for more prominence
            
            // Calculate glow intensity
            final glowIntensity = _glowAnimation.value;
          
          return Transform(
            alignment: Alignment.center,
            transform: Matrix4.identity()
              ..setEntry(3, 2, 0.001) // Perspective
              ..translateByVector3(Vector3(0.0, 0.0, translateZ))
              ..rotateX(rotateX * (3.14159 / 180)) // Convert degrees to radians
              ..rotateY(rotateY * (3.14159 / 180))
              ..scale(scale),
            child: Container(
              // Outer container for neon glow effect
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(20),
                boxShadow: [
                  // Multiple layered shadows for neon glow effect
                  BoxShadow(
                    color: AppColors.primary.withValues(alpha: 0.8 * glowIntensity),
                    blurRadius: 8 * glowIntensity,
                    spreadRadius: 2 * glowIntensity,
                  ),
                  BoxShadow(
                    color: AppColors.primary.withValues(alpha: 0.6 * glowIntensity),
                    blurRadius: 16 * glowIntensity,
                    spreadRadius: 1 * glowIntensity,
                  ),
                  BoxShadow(
                    color: AppColors.primaryLight.withValues(alpha: 0.7 * glowIntensity),
                    blurRadius: 24 * glowIntensity,
                    spreadRadius: 0.5 * glowIntensity,
                  ),
                  BoxShadow(
                    color: AppColors.primaryLight.withValues(alpha: 0.5 * glowIntensity),
                    blurRadius: 32 * glowIntensity,
                    spreadRadius: 0 * glowIntensity,
                  ),
                  // Elevation shadow
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.3 * glowIntensity),
                    blurRadius: 40 * glowIntensity,
                    spreadRadius: 0,
                    offset: Offset(0, 10 * glowIntensity),
                  ),
                ],
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(20),
                child: Container(
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(
                      color: AppColors.primary.withValues(
                        alpha: 0.3 + (0.7 * glowIntensity),
                      ),
                      width: 1.5 + (1.5 * glowIntensity),
                    ),
                  ),
                  child: Stack(
          children: [
            // Expanded image area with raindrop blur effect
            Positioned.fill(
              child: ClipRRect(
                borderRadius: BorderRadius.circular(20),
                child: Stack(
                  fit: StackFit.expand,
                  children: [
                    // Main image with scroll animation on hover
                    AnimatedBuilder(
                      animation: _imageScrollController,
                      builder: (context, child) {
                        // Calculate scroll offset: moves from 0 (bottom) to -scrollAmount (top)
                        // Using a percentage of the card height for smooth scrolling
                        final cardHeight = widget.isMobile ? 360.0 : 400.0;
                        final scrollAmount = cardHeight * 0.3; // Scroll 30% of card height
                        
                        // Only apply scroll if image loaded successfully
                        final shouldScroll = _imageLoadedSuccessfully && 
                            widget.project.imageUrl.isNotEmpty;
                        final scrollOffset = shouldScroll 
                            ? -scrollAmount * _imageScrollAnimation.value 
                            : 0.0;
                        
                        return Transform.translate(
                          offset: Offset(0, scrollOffset),
                          child: Image.network(
                            widget.project.imageUrl,
                            fit: BoxFit.cover,
                            frameBuilder: (context, child, frame, wasSynchronouslyLoaded) {
                              // Track successful image load
                              if (frame != null && !_imageLoadedSuccessfully) {
                                WidgetsBinding.instance.addPostFrameCallback((_) {
                                  if (mounted) {
                                    setState(() {
                                      _imageLoadedSuccessfully = true;
                                    });
                                    // If already hovering, start the animation
                                    if (_isHovered) {
                                      _imageScrollController.repeat(reverse: true);
                                    }
                                  }
                                });
                              }
                              return child;
                            },
                            errorBuilder: (context, error, stackTrace) {
                              // Mark image as failed to load
                              if (_imageLoadedSuccessfully) {
                                WidgetsBinding.instance.addPostFrameCallback((_) {
                                  if (mounted) {
                                    setState(() {
                                      _imageLoadedSuccessfully = false;
                                    });
                                    // Stop animation if running
                                    _imageScrollController.stop();
                                    _imageScrollController.reset();
                                  }
                                });
                              }
                              return Container(
                                color: AppColors.surfaceLight,
                                alignment: const Alignment(0, -0.5), // Position more upwards
                                child: const Icon(
                                  Icons.image,
                                  size: 40,
                                  color: AppColors.textTertiary,
                                ),
                              );
                            },
                          ),
                        );
                      },
                    ),
                    // Gradient overlay for depth
                    Container(
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          begin: Alignment.topCenter,
                          end: Alignment.bottomCenter,
                          colors: [
                            Colors.transparent,
                            AppColors.background.withValues(alpha: 0.4),
                          ],
                        ),
                      ),
                    ),
                    // Raindrop blur effect below title area - start lower to show more image
                    Positioned(
                      top: 0,
                      left: 0,
                      right: 0,
                      bottom: 0,
                      child: FractionallySizedBox(
                        heightFactor: 0.5,
                        alignment: Alignment.bottomCenter,
                        child: ClipRect(
                          child: BackdropFilter(
                            filter: ImageFilter.blur(sigmaX: 8, sigmaY: 8),
                            child: CustomPaint(
                              painter: _RaindropBlurPainter(),
                              child: Container(
                                decoration: BoxDecoration(
                                  gradient: LinearGradient(
                                    begin: Alignment.topCenter,
                                    end: Alignment.bottomCenter,
                                    colors: [
                                      Colors.transparent,
                                      AppColors.background.withValues(alpha: 0.2),
                                      AppColors.background.withValues(alpha: 0.4),
                                    ],
                                    stops: const [0.0, 0.3, 1.0],
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            // Glass morphism card content
            Positioned.fill(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Title area with glass background
                  Container(
                    padding: const EdgeInsets.fromLTRB(20, 130, 20, 16),
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(12),
                      child: BackdropFilter(
                        filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 12,
                            vertical: 8,
                          ),
                          decoration: BoxDecoration(
                            color: AppColors.surface.withValues(alpha: 0.3),
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(
                              color: AppColors.primary.withValues(alpha: 0.2),
                              width: 1,
                            ),
                          ),
                          child: Text(
                            widget.project.title,
                            style: AppTextStyles.heading4(context).copyWith(
                              color: AppColors.textPrimary,
                              fontWeight: FontWeight.bold,
                              fontSize: 20,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ),
                    ),
                  ),
                  // Glass content area
                  Expanded(
                    child: ClipRRect(
                      borderRadius: const BorderRadius.vertical(
                        bottom: Radius.circular(20),
                      ),
                      child: BackdropFilter(
                        filter: ImageFilter.blur(sigmaX: 15, sigmaY: 15),
                        child: Container(
                          padding: const EdgeInsets.all(20),
  
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                              begin: Alignment.topCenter,
                              end: Alignment.bottomCenter,
                              colors: [
                                AppColors.surface.withValues(alpha: 0.2),
                                AppColors.surface.withValues(alpha: 0.4),
                              ],
                            ),
                            borderRadius: const BorderRadius.vertical(
                              bottom: Radius.circular(20),
                            ),
                            border: Border(
                              top: BorderSide(
                                color: AppColors.primary.withValues(alpha: 0.1),
                                width: 1,
                              ),
                            ),
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Expanded(
                                child: Text(
                                  widget.project.description,
                                  style: AppTextStyles.bodySmall(context).copyWith(
                                    color: AppColors.textSecondary,
                                  ),
                                  maxLines: 3,
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                              const SizedBox(height: 12),
                              Wrap(
                                spacing: 6,
                                runSpacing: 6,
                                children: widget.project.technologies
                                    .take(3)
                                    .map(
                                      (tech) => ClipRRect(
                                        borderRadius: BorderRadius.circular(16),
                                        child: BackdropFilter(
                                          filter: ImageFilter.blur(sigmaX: 5, sigmaY: 5),
                                          child: Container(
                                            padding: const EdgeInsets.symmetric(
                                              horizontal: 10,
                                              vertical: 4,
                                            ),
                                            decoration: BoxDecoration(
                                              color: AppColors.primary.withValues(alpha: 0.25),
                                              borderRadius: BorderRadius.circular(16),
                                              border: Border.all(
                                                color: AppColors.primary.withValues(alpha: 0.3),
                                                width: 1,
                                              ),
                                            ),
                                            child: Text(
                                              tech,
                                              style: AppTextStyles.bodySmall(context).copyWith(
                                                fontSize: 10,
                                                color: AppColors.primaryLight,
                                                fontWeight: FontWeight.w500,
                                              ),
                                            ),
                                          ),
                                        ),
                                      ),
                                    )
                                    .toList(),
                              ),
                              const SizedBox(height: 12),
                              Builder(
                                builder: (context) {
                                  final buttons = <Widget>[];

                                  if (widget.project.githubUrl != null) {
                                    buttons.add(
                                      _ActionButton(
                                        icon: Icons.code,
                                        label: 'Code',
                                        onTap: () => _launchUrl(widget.project.githubUrl),
                                        isSmall: true,
                                      ),
                                    );
                                  }
                                  if (widget.project.iosUrl != null) {
                                    buttons.add(
                                      _ActionButton(
                                        icon: Icons.phone_iphone,
                                        label: 'iOS',
                                        onTap: () => _launchUrl(widget.project.iosUrl),
                                        isSmall: true,
                                      ),
                                    );
                                  }
                                  if (widget.project.androidUrl != null) {
                                    buttons.add(
                                      _ActionButton(
                                        icon: Icons.android,
                                        label: 'Android',
                                        onTap: () => _launchUrl(widget.project.androidUrl),
                                        isSmall: true,
                                      ),
                                    );
                                  }
                                  if (widget.project.userAndroidUrl != null) {
                                    buttons.add(
                                      _ActionButton(
                                        icon: Icons.android,
                                        label: 'User APK',
                                        onTap: () => _launchUrl(widget.project.userAndroidUrl),
                                        isSmall: true,
                                      ),
                                    );
                                  }
                                  if (widget.project.adminAndroidUrl != null) {
                                    buttons.add(
                                      _ActionButton(
                                        icon: Icons.admin_panel_settings,
                                        label: 'Admin APK',
                                        onTap: () => _launchUrl(widget.project.adminAndroidUrl),
                                        isSmall: true,
                                      ),
                                    );
                                  }
                                  if (widget.project.webUrl != null) {
                                    buttons.add(
                                      _ActionButton(
                                        icon: Icons.language,
                                        label: 'Web',
                                        onTap: () => _launchUrl(widget.project.webUrl),
                                        isSmall: true,
                                      ),
                                    );
                                  }

                                  if (buttons.isEmpty) return const SizedBox.shrink();

                                  final rowChildren = <Widget>[];
                                  for (int i = 0; i < buttons.length; i++) {
                                    rowChildren.add(buttons[i]);
                                    if (i < buttons.length - 1) {
                                      rowChildren.add(const SizedBox(width: 8));
                                    }
                                  }

                                  return SizedBox(
                                    height: 40,
                                    child: InteractiveViewer(
                                      constrained: false,
                                      panEnabled: true,
                                      scaleEnabled: false,
                                      minScale: 1.0,
                                      maxScale: 1.0,
                                      child: Row(
                                        mainAxisSize: MainAxisSize.min,
                                        children: rowChildren,
                                      ),
                                    ),
                                  );
                                },
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
                  ),
                ),
              ),
            ),
          );
          },
        ),
      ),
    );
  }
}

// Custom painter for raindrop blur effect
class _RaindropBlurPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    // Create raindrop-like blur patterns with varying sizes
    final raindrops = [
      {'pos': Offset(size.width * 0.15, size.height * 0.2), 'size': 20.0},
      {'pos': Offset(size.width * 0.35, size.height * 0.25), 'size': 15.0},
      {'pos': Offset(size.width * 0.55, size.height * 0.3), 'size': 25.0},
      {'pos': Offset(size.width * 0.75, size.height * 0.28), 'size': 18.0},
      {'pos': Offset(size.width * 0.25, size.height * 0.45), 'size': 22.0},
      {'pos': Offset(size.width * 0.65, size.height * 0.5), 'size': 16.0},
      {'pos': Offset(size.width * 0.85, size.height * 0.48), 'size': 20.0},
      {'pos': Offset(size.width * 0.1, size.height * 0.6), 'size': 14.0},
      {'pos': Offset(size.width * 0.45, size.height * 0.65), 'size': 24.0},
      {'pos': Offset(size.width * 0.7, size.height * 0.7), 'size': 19.0},
      {'pos': Offset(size.width * 0.3, size.height * 0.75), 'size': 17.0},
      {'pos': Offset(size.width * 0.6, size.height * 0.8), 'size': 21.0},
    ];

    for (final drop in raindrops) {
      final pos = drop['pos'] as Offset;
      final radius = drop['size'] as double;
      
      // Draw raindrop with gradient-like effect
      final paint = Paint()
        ..style = PaintingStyle.fill
        ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 12);
      
      // Outer glow
      canvas.drawCircle(
        pos,
        radius,
        paint..color = Colors.white.withValues(alpha: 0.08),
      );
      
      // Inner highlight
      canvas.drawCircle(
        pos,
        radius * 0.6,
        paint..color = Colors.white.withValues(alpha: 0.12),
      );
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

class _ActionButton extends StatefulWidget {
  final IconData icon;
  final String label;
  final VoidCallback onTap;
  final bool isPrimary;
  final bool isSmall;

  const _ActionButton({
    required this.icon,
    required this.label,
    required this.onTap,
    this.isPrimary = false,
    this.isSmall = false,
  });

  @override
  State<_ActionButton> createState() => _ActionButtonState();
}

class _ActionButtonState extends State<_ActionButton>
    with SingleTickerProviderStateMixin {
  bool _isHovered = false;
  late AnimationController _colorAnimationController;
  late Animation<Color?> _iconColorAnimation;
  late Animation<Color?> _textColorAnimation;

  @override
  void initState() {
    super.initState();
    _colorAnimationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 200),
    );
    _iconColorAnimation =
        ColorTween(begin: AppColors.primaryLight, end: Colors.white).animate(
          CurvedAnimation(
            parent: _colorAnimationController,
            curve: Curves.easeInOut,
          ),
        );
    _textColorAnimation =
        ColorTween(begin: AppColors.primaryLight, end: Colors.white).animate(
          CurvedAnimation(
            parent: _colorAnimationController,
            curve: Curves.easeInOut,
          ),
        );
  }

  @override
  void dispose() {
    _colorAnimationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (_isHovered) {
      _colorAnimationController.forward();
    } else {
      _colorAnimationController.reverse();
    }
    return MouseRegion(
      onEnter: (_) => setState(() => _isHovered = true),
      onExit: (_) => setState(() => _isHovered = false),
      child: InkWell(
        onTap: widget.onTap,
        borderRadius: BorderRadius.circular(8),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          padding: EdgeInsets.symmetric(
            horizontal: widget.isSmall ? 12 : 16,
            vertical: widget.isSmall ? 6 : 10,
          ),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: _isHovered
                  ? [
                      AppColors.primaryLight,
                      AppColors.primary,
                      const Color(0xFF8B5CF6),
                    ]
                  : [
                      AppColors.primary.withValues(alpha: 0.2),
                      AppColors.primary.withValues(alpha: 0.2),
                    ],
            ),
            borderRadius: BorderRadius.circular(8),
            border: Border.all(
              color: _isHovered
                  ? AppColors.primaryLight
                  : AppColors.primary.withValues(alpha: 0.3),
              width: _isHovered ? 1.5 : 1,
            ),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              AnimatedBuilder(
                animation: _iconColorAnimation,
                builder: (context, child) {
                  return Icon(
                    widget.icon,
                    size: widget.isSmall ? 16 : 18,
                    color: _iconColorAnimation.value,
                  );
                },
              ),
              SizedBox(width: widget.isSmall ? 4 : 6),
              AnimatedBuilder(
                animation: _textColorAnimation,
                builder: (context, child) {
                  return Text(
                    widget.label,
                    style: AppTextStyles.bodySmall(context).copyWith(
                      color: _textColorAnimation.value,
                      fontWeight: FontWeight.w600,
                      fontSize: widget.isSmall ? 12 : 14,
                    ),
                  );
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _ProjectGalleryPopup extends StatefulWidget {
  final Project project;
  final bool isFromTopLeft;

  const _ProjectGalleryPopup({
    required this.project,
    required this.isFromTopLeft,
  });

  @override
  State<_ProjectGalleryPopup> createState() => _ProjectGalleryPopupState();
}

class _ProjectGalleryPopupState extends State<_ProjectGalleryPopup>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<Offset> _slideAnimation;
  late Animation<double> _scaleAnimation;
  late Animation<double> _opacityAnimation;
  late int _crossAxisCount;
  late double _spacing;
  late List<double>
  _aspectRatios; // Pre-calculated aspect ratios to prevent layout shifts
  late Offset _endOffset; // Store the end offset for closing animation

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 600),
    );

    // Random grid dimensions - more columns for smaller images
    final random = DateTime.now().millisecondsSinceEpoch;
    _crossAxisCount = [3, 4][random % 2]; // 3 or 4 columns for smaller images
    _spacing = 10.0;

    // Pre-calculate aspect ratios once to prevent layout shifts during scrolling
    final images = widget.project.galleryImages ?? [];
    final aspectRatioOptions = [
      0.7,
      0.8,
      0.9,
      1.0,
      1.1,
      1.2,
      1.3,
      1.4,
      1.5,
      1.6,
    ];
    _aspectRatios = List.generate(
      images.length,
      (index) =>
          aspectRatioOptions[(random + index) % aspectRatioOptions.length],
    );

    // Slide animation from top-left or top-right
    final startOffset = widget.isFromTopLeft
        ? const Offset(-1.0, -1.0)
        : const Offset(1.0, -1.0);
    
    // End offset is opposite direction for closing
    _endOffset = widget.isFromTopLeft
        ? const Offset(1.0, -1.0)
        : const Offset(-1.0, -1.0);

    // Create animation that goes to opposite direction when closing
    _slideAnimation = TweenSequence<Offset>([
      TweenSequenceItem(
        tween: Tween<Offset>(
          begin: startOffset,
          end: Offset.zero,
        ).chain(CurveTween(curve: Curves.easeOutCubic)),
        weight: 1.0,
      ),
    ]).animate(_controller);

    _scaleAnimation = Tween<double>(
      begin: 0.3,
      end: 1.0,
    ).animate(CurvedAnimation(parent: _controller, curve: Curves.easeOutCubic));

    _opacityAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(parent: _controller, curve: Curves.easeOut));

    _controller.forward();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _closePopup() {
    // Reset controller and create new animations for closing
    _controller.reset();
    
    // Create new animations from center to opposite direction
    final closeSlideAnimation = Tween<Offset>(
      begin: Offset.zero,
      end: _endOffset,
    ).animate(CurvedAnimation(
      parent: _controller,
      curve: Curves.easeInCubic,
    ));
    
    final closeScaleAnimation = Tween<double>(
      begin: 1.0,
      end: 0.3,
    ).animate(CurvedAnimation(
      parent: _controller,
      curve: Curves.easeInCubic,
    ));
    
    final closeOpacityAnimation = Tween<double>(
      begin: 1.0,
      end: 0.0,
    ).animate(CurvedAnimation(
      parent: _controller,
      curve: Curves.easeIn,
    ));
    
    // Replace animations for closing
    setState(() {
      _slideAnimation = closeSlideAnimation;
      _scaleAnimation = closeScaleAnimation;
      _opacityAnimation = closeOpacityAnimation;
    });
    
    // Animate to opposite direction
    _controller.forward().then((_) {
      if (mounted) {
        Navigator.of(context).pop();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final images = widget.project.galleryImages ?? [];
    if (images.isEmpty) return const SizedBox.shrink();

    return FadeTransition(
      opacity: _opacityAnimation,
      child: SlideTransition(
        position: _slideAnimation,
        child: ScaleTransition(
          scale: _scaleAnimation,
          child: Dialog(
            backgroundColor: Colors.transparent,
            insetPadding: const EdgeInsets.all(20),
            child: Container(
              constraints: BoxConstraints(
                maxWidth: MediaQuery.of(context).size.width * 0.69,
                maxHeight: MediaQuery.of(context).size.height * 0.69,
              ),
              width: MediaQuery.of(context).size.width * 0.69,
              height: MediaQuery.of(context).size.height * 0.69,
              decoration: BoxDecoration(
                color: AppColors.surface,
                borderRadius: BorderRadius.circular(24),
                border: Border.all(
                  color: AppColors.primary.withValues(alpha: 0.5),
                  width: 1.5,
                ),
                boxShadow: [
                  BoxShadow(
                    color: AppColors.primary.withValues(alpha: 0.2),
                    blurRadius: 12,
                    spreadRadius: 1,
                  ),
                  BoxShadow(
                    color: AppColors.primary.withValues(alpha: 0.1),
                    blurRadius: 24,
                    spreadRadius: 2,
                  ),
                ],
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(24),
                child: Stack(
                  children: [
                    // Scrollable Gallery Grid
                    Positioned.fill(
                      child: Padding(
                        padding: const EdgeInsets.fromLTRB(12, 70, 12, 12),
                        child: ClipRRect(
                          borderRadius: const BorderRadius.vertical(
                            top: Radius.circular(20),
                            bottom: Radius.circular(20),
                          ),
                          child: _buildGrid(images),
                        ),
                      ),
                    ),
                    // Glassy Header Overlay
                    Positioned(
                      top: 0,
                      left: 0,
                      right: 0,
                      child: ClipRRect(
                        borderRadius: const BorderRadius.vertical(
                          top: Radius.circular(24),
                        ),
                        child: BackdropFilter(
                          filter: ImageFilter.blur(sigmaX: 15, sigmaY: 15),
                          child: Container(
                            padding: const EdgeInsets.all(12),
                            decoration: BoxDecoration(
                              color: AppColors.surface.withValues(alpha: 0.1),
                              gradient: LinearGradient(
                                begin: Alignment.topCenter,
                                end: Alignment.bottomCenter,
                                colors: [
                                  AppColors.surface.withValues(alpha: 0.4),
                                  AppColors.surface.withValues(alpha: 0.3),
                                  AppColors.surface.withValues(alpha: 0.3),
                                  AppColors.surface.withValues(alpha: 0.2),
                                ],
                                stops: const [0.0, 0.3, 0.7, 1.0],
                              ).withOpacity(0.1),
                              // border: Border(
                              //   bottom: BorderSide(
                              //     color: AppColors.primary.withValues(alpha: 0.2),
                              //     width: 1,
                              //   ),
                              // ),
                            ),
                            child: Row(
                              children: [
                                Container(
                                  width: 14,
                                  height: 14,

                                  decoration: BoxDecoration(
                                    shape: BoxShape.circle,
                                    gradient: AppColors.primaryGradient,
                                  ),
                                ),
                                const SizedBox(width: 12),
                                Expanded(
                                  child: Text(
                                    widget.project.title,
                                    style: AppTextStyles.heading3(context),
                                  ),
                                ),
                                IconButton(
                                  onPressed: _closePopup,
                                  icon: const Icon(
                                    Icons.close,
                                    color: AppColors.textSecondary,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildGrid(List<String> images) {
    // Pinterest-style masonry layout with varying aspect ratios
    return MasonryGridView.count(
      crossAxisCount: _crossAxisCount,
      mainAxisSpacing: _spacing,
      crossAxisSpacing: _spacing,
      itemCount: images.length,
      itemBuilder: (context, index) {
        // Use pre-calculated aspect ratio to prevent layout shifts during scrolling
        final aspectRatio = _aspectRatios[index];

        return Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(8),
            border: Border.all(
              color: Colors.white.withValues(alpha: .3),
              width: 1.5,
            ),
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(8),
            child: AspectRatio(
              aspectRatio: aspectRatio,
              child: Image.network(
                images[index],
                fit: BoxFit.cover,
                // Add loadingBuilder to prevent layout shifts while images load
                loadingBuilder: (context, child, loadingProgress) {
                  if (loadingProgress == null) return child;
                  return Container(
                    color: AppColors.surfaceLight,
                    child: Center(
                      child: CircularProgressIndicator(
                        value: loadingProgress.expectedTotalBytes != null
                            ? loadingProgress.cumulativeBytesLoaded /
                                  loadingProgress.expectedTotalBytes!
                            : null,
                        color: AppColors.primaryLight,
                      ),
                    ),
                  );
                },
                errorBuilder: (context, error, stackTrace) {
                  return Container(
                    color: AppColors.surfaceLight,
                    child: const Icon(
                      Icons.broken_image,
                      color: AppColors.textTertiary,
                    ),
                  );
                },
              ),
            ),
          ),
        );
      },
    );
  }
}
