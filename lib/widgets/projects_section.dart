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
    // Calculate initial page to show first item (index 0)
    final allProjects = PortfolioData.projects
        .map((project) => Project.fromMap(project))
        .toList();
    final mainProjects = allProjects
        .where((p) => p.type == ProjectType.main)
        .toList();
    final projectsCount = mainProjects.length;
    // Set initial page to a multiple of projectsCount to ensure it shows index 0
    final initialPage = projectsCount > 0 ? (1000 ~/ projectsCount) * projectsCount : 1000;
    
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
            SizedBox(
              height: 40,
              child: InteractiveViewer(
                constrained: false,
                panEnabled: true,
                scaleEnabled: false,
                minScale: 1.0,
                maxScale: 1.0,
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: widget.project.technologies
                      .asMap()
                      .entries
                      .map(
                        (entry) {
                          final index = entry.key;
                          final tech = entry.value;
                          return Container(
                            margin: EdgeInsets.only(
                              right: index < widget.project.technologies.length - 1 ? 8 : 0,
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
                        },
                      )
                      .toList(),
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
    _iconColorAnimation = ColorTween(
      begin: AppColors.primaryLight,
      end: Colors.white,
    ).animate(CurvedAnimation(
      parent: _colorAnimationController,
      curve: Curves.easeInOut,
    ));
    _textColorAnimation = ColorTween(
      begin: AppColors.primaryLight,
      end: Colors.white,
    ).animate(CurvedAnimation(
      parent: _colorAnimationController,
      curve: Curves.easeInOut,
    ));
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
