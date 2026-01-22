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

class _ProjectsSectionState extends State<ProjectsSection> {
  // Viewport fraction keeps three cards visible (prev/active/next)
  late final PageController _mainProjectsController;
  int _currentMainProjectIndex = 0;

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
    });
  }

  @override
  void dispose() {
    _mainProjectsController.dispose();
    super.dispose();
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

    return Container(
      width: double.infinity,
      constraints: BoxConstraints(minHeight: size.height),
      color: AppColors.background,
      padding: EdgeInsets.symmetric(
        horizontal: isMobile ? 20 : 60,
        vertical: isMobile ? 60 : 100,
      ),
      child: SingleChildScrollView(
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
              _buildMainProjectsCarousel(context, mainProjects, isMobile),
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
      height: isMobile ? 320 : 360,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        itemCount: projects.length,
        itemBuilder: (context, index) {
          return Container(
            width: isMobile ? 280 : 320,
            margin: EdgeInsets.only(
              right: index < projects.length - 1 ? 24 : 0,
            ),
            child: _MiniProjectCard(
              project: projects[index],
              isMobile: isMobile,
            ),
          );
        },
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

class _MiniProjectCard extends StatelessWidget {
  final Project project;
  final bool isMobile;

  const _MiniProjectCard({required this.project, required this.isMobile});

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
    return Container(
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: AppColors.primary.withValues(alpha: 0.2),
          width: 1,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          ClipRRect(
            borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
            child: Container(
              height: 160,
              width: double.infinity,
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [
                    AppColors.primary.withValues(alpha: 0.1),
                    AppColors.surfaceLight,
                  ],
                ),
              ),
              child: Stack(
                fit: StackFit.expand,
                children: [
                  Image.network(
                    project.imageUrl,
                    fit: BoxFit.cover,
                    errorBuilder: (context, error, stackTrace) {
                      return Container(
                        color: AppColors.surfaceLight,
                        child: const Icon(
                          Icons.image,
                          size: 40,
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
                ],
              ),
            ),
          ),
          Expanded(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    project.title,
                    style: AppTextStyles.heading4(context),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 8),
                  Expanded(
                    child: Text(
                      project.description,
                      style: AppTextStyles.bodySmall(context),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  const SizedBox(height: 12),
                  Wrap(
                    spacing: 6,
                    runSpacing: 6,
                    children: project.technologies
                        .take(3)
                        .map(
                          (tech) => Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 10,
                              vertical: 4,
                            ),
                            decoration: BoxDecoration(
                              color: AppColors.primary.withValues(alpha: 0.2),
                              borderRadius: BorderRadius.circular(16),
                            ),
                            child: Text(
                              tech,
                              style: AppTextStyles.bodySmall(context).copyWith(
                                fontSize: 10,
                                color: AppColors.primaryLight,
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

                      if (project.githubUrl != null) {
                        buttons.add(
                          _ActionButton(
                            icon: Icons.code,
                            label: 'Code',
                            onTap: () => _launchUrl(project.githubUrl),
                            isSmall: true,
                          ),
                        );
                      }
                      if (project.iosUrl != null) {
                        buttons.add(
                          _ActionButton(
                            icon: Icons.phone_iphone,
                            label: 'iOS',
                            onTap: () => _launchUrl(project.iosUrl),
                            isSmall: true,
                          ),
                        );
                      }
                      if (project.androidUrl != null) {
                        buttons.add(
                          _ActionButton(
                            icon: Icons.android,
                            label: 'Android',
                            onTap: () => _launchUrl(project.androidUrl),
                            isSmall: true,
                          ),
                        );
                      }
                      if (project.userAndroidUrl != null) {
                        buttons.add(
                          _ActionButton(
                            icon: Icons.android,
                            label: 'User APK',
                            onTap: () => _launchUrl(project.userAndroidUrl),
                            isSmall: true,
                          ),
                        );
                      }
                      if (project.adminAndroidUrl != null) {
                        buttons.add(
                          _ActionButton(
                            icon: Icons.admin_panel_settings,
                            label: 'Admin APK',
                            onTap: () => _launchUrl(project.adminAndroidUrl),
                            isSmall: true,
                          ),
                        );
                      }
                      if (project.webUrl != null) {
                        buttons.add(
                          _ActionButton(
                            icon: Icons.language,
                            label: 'Web',
                            onTap: () => _launchUrl(project.webUrl),
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
        ],
      ),
    );
  }
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
