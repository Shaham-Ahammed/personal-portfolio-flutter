import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:vector_math/vector_math_64.dart' show Vector3;
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
    // Large initial page to simulate infinite loop feel
    _mainProjectsController = PageController(
      viewportFraction: 0.62,
      initialPage: 1000,
    );
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

    final mainProjects = allProjects.where((p) => p.type == ProjectType.main).toList();
    final miniProjects = allProjects.where((p) => p.type == ProjectType.mini).toList();

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
              Text(
                'Mini Projects',
                style: AppTextStyles.heading3(context),
              ),
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
                      final scale =
                          (1 - (clamped.abs() * 0.4)).clamp(0.6, 1.0);
                      final translateZ = -80 * clamped.abs(); // curve back slightly
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
                          ..scaleByVector3(
                            Vector3(scale, scale, scale),
                          ),
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
                        if (_currentMainProjectIndex > 0) {
                          _mainProjectsController.previousPage(
                            duration: const Duration(milliseconds: 400),
                            curve: Curves.easeInOut,
                          );
                        }
                      },
                      isEnabled: _currentMainProjectIndex > 0,
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
                        if (_currentMainProjectIndex < projects.length - 1) {
                          _mainProjectsController.nextPage(
                            duration: const Duration(milliseconds: 400),
                            curve: Curves.easeInOut,
                          );
                        }
                      },
                      isEnabled: _currentMainProjectIndex < projects.length - 1,
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
        (index) => GestureDetector(
          onTap: () {
            _mainProjectsController.animateToPage(
              index,
              duration: const Duration(milliseconds: 400),
              curve: Curves.easeInOut,
            );
          },
          child: AnimatedContainer(
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
  }

  @override
  void dispose() {
    _animationController.dispose();
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
                    color: AppColors.primary.withValues(alpha:
                      0.3 * _glowAnimation.value * (isActive ? 1 : 0.5),
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
        Expanded(
          flex: 5,
          child: _buildImageSection(),
        ),
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
    return ClipRRect(
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
          ],
        ),
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
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: widget.project.technologies
                  .map(
                    (tech) => Container(
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
                    ),
                  )
                  .toList(),
            ),
            const SizedBox(height: 24),
            Row(
              children: [
                if (widget.project.githubUrl != null)
                  Expanded(
                    child: _ActionButton(
                      icon: Icons.code,
                      label: 'Code',
                      onTap: () => _launchUrl(widget.project.githubUrl),
                      isPrimary: true,
                    ),
                  ),
                if (widget.project.githubUrl != null &&
                    widget.project.liveUrl != null)
                  const SizedBox(width: 12),
                if (widget.project.liveUrl != null)
                  Expanded(
                    child: _ActionButton(
                      icon: Icons.open_in_new,
                      label: 'Live',
                      onTap: () => _launchUrl(widget.project.liveUrl),
                      isPrimary: false,
                    ),
                  ),
              ],
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

  const _MiniProjectCard({
    required this.project,
    required this.isMobile,
  });

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
                  if (project.githubUrl != null || project.liveUrl != null)
                    Row(
                      children: [
                        if (project.githubUrl != null)
                          _ActionButton(
                            icon: Icons.code,
                            label: 'Code',
                            onTap: () => _launchUrl(project.githubUrl),
                            isPrimary: false,
                            isSmall: true,
                          ),
                        if (project.githubUrl != null && project.liveUrl != null)
                          const SizedBox(width: 8),
                        if (project.liveUrl != null)
                          _ActionButton(
                            icon: Icons.open_in_new,
                            label: 'Live',
                            onTap: () => _launchUrl(project.liveUrl),
                            isPrimary: false,
                            isSmall: true,
                          ),
                      ],
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

class _ActionButton extends StatelessWidget {
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
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(8),
      child: Container(
        padding: EdgeInsets.symmetric(
          horizontal: isSmall ? 12 : 16,
          vertical: isSmall ? 6 : 10,
        ),
        decoration: BoxDecoration(
          gradient: isPrimary ? AppColors.primaryGradient : null,
          color: isPrimary ? null : AppColors.primary.withValues(alpha: 0.2),
          borderRadius: BorderRadius.circular(8),
          border: Border.all(
            color: AppColors.primary.withValues(alpha: isPrimary ? 0.5 : 0.3),
            width: 1,
          ),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              icon,
              size: isSmall ? 16 : 18,
              color: isPrimary ? Colors.white : AppColors.primaryLight,
            ),
            SizedBox(width: isSmall ? 4 : 6),
            Text(
              label,
              style: AppTextStyles.bodySmall(context).copyWith(
                color: isPrimary ? Colors.white : AppColors.primaryLight,
                fontWeight: FontWeight.w600,
                fontSize: isSmall ? 12 : 14,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
