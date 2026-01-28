import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import '../constants/colors.dart';
import '../constants/text_styles.dart';

class PortfolioNavigationBar extends StatefulWidget {
  final int currentSection;
  final Function(int) onSectionTap;

  const PortfolioNavigationBar({
    super.key,
    required this.currentSection,
    required this.onSectionTap,
  });

  @override
  State<PortfolioNavigationBar> createState() => _PortfolioNavigationBarState();
}

class _PortfolioNavigationBarState extends State<PortfolioNavigationBar>
    with SingleTickerProviderStateMixin {
  bool _isMenuOpen = false;
  late AnimationController _menuController;
  late Animation<double> _menuAnimation;
  late Animation<double> _glowAnimation;

  @override
  void initState() {
    super.initState();
    _menuController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 300),
    );
    _menuAnimation = CurvedAnimation(
      parent: _menuController,
      curve: Curves.easeOutCubic,
      reverseCurve: Curves.easeInCubic,
    );
    _glowAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _menuController,
        curve: Curves.easeOut,
      ),
    );
  }

  @override
  void dispose() {
    _menuController.dispose();
    super.dispose();
  }

  void _toggleMenu() {
    setState(() {
      _isMenuOpen = !_isMenuOpen;
      if (_isMenuOpen) {
        _menuController.forward();
      } else {
        _menuController.reverse();
      }
    });
  }

  void _closeMenu() {
    if (_isMenuOpen) {
      setState(() {
        _isMenuOpen = false;
        _menuController.reverse();
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final isMobile = MediaQuery.of(context).size.width < 768;

    if (isMobile) {
      return _buildMobileNavBar(context);
    } else {
      return _buildDesktopNavBar(context);
    }
  }

  Widget _buildDesktopNavBar(BuildContext context) {
    return Container(
      height: 80,
      padding: const EdgeInsets.symmetric(horizontal: 40),
      decoration: BoxDecoration(
        color: AppColors.background.withValues(alpha: 0.9),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.1),
            blurRadius: 10,
          ),
        ],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            'Portfolio',
            style: AppTextStyles.heading4(context).copyWith(
              color: AppColors.primaryLight,
            ),
          ),
          Row(
            children: [
              _NavItem(
                label: 'Home',
                onTap: () => widget.onSectionTap(0),
                isActive: widget.currentSection == 0,
              ),
              const SizedBox(width: 30),
              _NavItem(
                label: 'About',
                onTap: () => widget.onSectionTap(1),
                isActive: widget.currentSection == 1,
              ),
              const SizedBox(width: 30),
              _NavItem(
                label: 'Projects',
                onTap: () => widget.onSectionTap(2),
                isActive: widget.currentSection == 2,
              ),
              const SizedBox(width: 30),
              _NavItem(
                label: 'Experience',
                onTap: () => widget.onSectionTap(3),
                isActive: widget.currentSection == 3,
              ),
              const SizedBox(width: 30),
              _NavItem(
                label: 'Contact',
                onTap: () => widget.onSectionTap(4),
                isActive: widget.currentSection == 4,
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildMobileNavBar(BuildContext context) {
    final screenHeight = MediaQuery.of(context).size.height;
    
    return SizedBox(
      height: _isMenuOpen || _menuController.isAnimating ? screenHeight : null,
      child: Stack(
        children: [
          // Shadow overlay when menu is open
          if (_isMenuOpen || _menuController.isAnimating)
            Positioned(
              top: 70, // Below nav bar
              left: 0,
              right: 0,
              bottom: 0,
              child: GestureDetector(
                onTap: _closeMenu,
                behavior: HitTestBehavior.opaque,
                child: MouseRegion(
                  cursor: SystemMouseCursors.click,
                  child: AnimatedBuilder(
                    animation: _menuAnimation,
                    builder: (context, child) {
                      return Container(
                        color: Colors.black.withValues(alpha: 0.6 * _menuAnimation.value),
                      );
                    },
                  ),
                ),
              ),
            ),
          // Nav bar and menu
          Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Nav bar
              Container(
                height: 70,
                padding: const EdgeInsets.symmetric(horizontal: 20),
                decoration: BoxDecoration(
                  color: AppColors.background.withValues(alpha: 0.9),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.1),
                      blurRadius: 10,
                    ),
                  ],
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Portfolio',
                      style: AppTextStyles.heading4(context).copyWith(
                        color: AppColors.primaryLight,
                        fontSize: 20,
                      ),
                    ),
                    IconButton(
                      icon: AnimatedIcon(
                        icon: AnimatedIcons.menu_close,
                        progress: _menuAnimation,
                        color: AppColors.textPrimary,
                      ),
                      onPressed: _toggleMenu,
                    ),
                  ],
                ),
              ),
              // Dropdown menu with glass effect
              AnimatedBuilder(
                animation: _menuAnimation,
                builder: (context, child) {
                  return ClipRRect(
                    borderRadius: const BorderRadius.only(
                      bottomLeft: Radius.circular(40),
                      bottomRight: Radius.circular(40),
                    ),
                    child: Align(
                      alignment: Alignment.topCenter,
                      heightFactor: _menuAnimation.value,
                      child: child,
                    ),
                  );
                },
                child: _buildGlassMenu(context),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildGlassMenu(BuildContext context) {
    final menuItems = [
      {'label': 'Home', 'icon': FontAwesomeIcons.house, 'index': 0},
      {'label': 'About', 'icon': FontAwesomeIcons.user, 'index': 1},
      {'label': 'Projects', 'icon': FontAwesomeIcons.folderOpen, 'index': 2},
      {'label': 'Experience', 'icon': Icons.work_outline_rounded, 'index': 3},
      {'label': 'Contact', 'icon': FontAwesomeIcons.addressBook, 'index': 4},
    ];

    return ClipRRect(
      borderRadius: const BorderRadius.only(
        bottomLeft: Radius.circular(40),
        bottomRight: Radius.circular(40),
      ),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 20, sigmaY: 20),
        child: AnimatedBuilder(
          animation: _glowAnimation,
          builder: (context, child) {
            return Container(
              width: double.infinity,
              decoration: BoxDecoration(
                // Glass effect background
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    AppColors.surface.withValues(alpha: 0.7),
                    AppColors.background.withValues(alpha: 0.5),
                  ],
                ),
                borderRadius: const BorderRadius.only(
                  bottomLeft: Radius.circular(40),
                  bottomRight: Radius.circular(40),
                ),
                // Subtle top border for separation
                border: Border(
                  top: BorderSide(
                    color: AppColors.primaryLight.withValues(alpha: 0.1),
                    width: 1,
                  ),
                ),
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  // Menu items with dividers
                  Column(
                    children: [
                      for (int i = 0; i < menuItems.length; i++) ...[
                        _GlassMobileNavItem(
                          label: menuItems[i]['label'] as String,
                          icon: menuItems[i]['icon'] as IconData,
                          onTap: () {
                            _closeMenu();
                            widget.onSectionTap(menuItems[i]['index'] as int);
                          },
                          isActive: widget.currentSection == menuItems[i]['index'],
                        ),
                        // Add divider after each item except the last
                        if (i < menuItems.length - 1)
                          _buildDivider(
                            isNextActive: widget.currentSection == menuItems[i + 1]['index'],
                            isPrevActive: widget.currentSection == menuItems[i]['index'],
                          ),
                      ],
                    ],
                  ),
                  // Glowing curved bottom border
                  SizedBox(
                    height: 25,
                    child: CustomPaint(
                      size: const Size(double.infinity, 25),
                      painter: _CurvedGlowBorderPainter(
                        glowIntensity: _glowAnimation.value,
                        borderRadius: 40,
                      ),
                    ),
                  ),
                ],
              ),
            );
          },
        ),
      ),
    );
  }

  Widget _buildDivider({required bool isNextActive, required bool isPrevActive}) {
    final isHighlighted = isNextActive || isPrevActive;
    return Container(
      height: 1,
      margin: const EdgeInsets.symmetric(horizontal: 20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: isHighlighted
              ? [
                  Colors.transparent,
                  AppColors.primaryLight.withValues(alpha: 0.4),
                  AppColors.primary.withValues(alpha: 0.6),
                  AppColors.primaryLight.withValues(alpha: 0.4),
                  Colors.transparent,
                ]
              : [
                  Colors.transparent,
                  AppColors.textSecondary.withValues(alpha: 0.15),
                  AppColors.textSecondary.withValues(alpha: 0.25),
                  AppColors.textSecondary.withValues(alpha: 0.15),
                  Colors.transparent,
                ],
        ),
      ),
    );
  }
}

class _GlassMobileNavItem extends StatefulWidget {
  final String label;
  final IconData icon;
  final VoidCallback onTap;
  final bool isActive;

  const _GlassMobileNavItem({
    required this.label,
    required this.icon,
    required this.onTap,
    required this.isActive,
  });

  @override
  State<_GlassMobileNavItem> createState() => _GlassMobileNavItemState();
}

class _GlassMobileNavItemState extends State<_GlassMobileNavItem> {
  bool _isPressed = false;

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      cursor: SystemMouseCursors.click,
      child: GestureDetector(
        onTapDown: (_) => setState(() => _isPressed = true),
        onTapUp: (_) => setState(() => _isPressed = false),
        onTapCancel: () => setState(() => _isPressed = false),
        onTap: widget.onTap,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 150),
          width: double.infinity,
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
          color: _isPressed
              ? AppColors.primary.withValues(alpha: 0.1)
              : Colors.transparent,
          child: Row(
            children: [
              FaIcon(
                widget.icon,
                color: widget.isActive
                    ? AppColors.primaryLight
                    : AppColors.textSecondary,
                size: 20,
              ),
              const SizedBox(width: 16),
              Text(
                widget.label,
                style: AppTextStyles.bodyMedium(context).copyWith(
                  color: widget.isActive
                      ? AppColors.primaryLight
                      : AppColors.textPrimary,
                  fontWeight: widget.isActive ? FontWeight.w600 : FontWeight.normal,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _NavItem extends StatefulWidget {
  final String label;
  final VoidCallback onTap;
  final bool isActive;

  const _NavItem({
    required this.label,
    required this.onTap,
    required this.isActive,
  });

  @override
  State<_NavItem> createState() => _NavItemState();
}

class _NavItemState extends State<_NavItem> {
  bool _isHovered = false;

  @override
  Widget build(BuildContext context) {
    final bool isActive = widget.isActive;

    return MouseRegion(
      onEnter: (_) => setState(() => _isHovered = true),
      onExit: (_) => setState(() => _isHovered = false),
      child: AnimatedScale(
        scale: _isHovered ? 1.2 : 1.0,
        duration: const Duration(milliseconds: 140),
        curve: Curves.easeOut,
        child: InkWell(
          onTap: widget.onTap,
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            decoration: BoxDecoration(
              color: isActive ? AppColors.primary.withValues(alpha: 0.2) : Colors.transparent,
              borderRadius: BorderRadius.circular(8),
            ),
            child: Text(
              widget.label,
              style: AppTextStyles.bodyMedium(context).copyWith(
                color: _isHovered
                    ? AppColors.primaryLight
                    : (isActive ? AppColors.primaryLight : AppColors.textSecondary),
                fontWeight: isActive ? FontWeight.w600 : FontWeight.normal,
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _CurvedGlowBorderPainter extends CustomPainter {
  final double glowIntensity;
  final double borderRadius;

  _CurvedGlowBorderPainter({
    required this.glowIntensity,
    required this.borderRadius,
  });

  @override
  void paint(Canvas canvas, Size size) {
    if (glowIntensity <= 0) return;

    final path = Path();
    
    // Only draw the bottom curved edge (U shape at bottom)
    path.moveTo(0, 0);
    path.lineTo(0, size.height - borderRadius);
    path.quadraticBezierTo(0, size.height, borderRadius, size.height);
    path.lineTo(size.width - borderRadius, size.height);
    path.quadraticBezierTo(size.width, size.height, size.width, size.height - borderRadius);
    path.lineTo(size.width, 0);

    // Use solid color with glow - no fading at corners
    final glowColor = AppColors.primary.withValues(alpha: 0.7 * glowIntensity);
    final lightGlowColor = AppColors.primaryLight.withValues(alpha: 0.5 * glowIntensity);

    // Outer glow layer (largest blur)
    final outerGlowPaint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 8
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round
      ..maskFilter = MaskFilter.blur(BlurStyle.normal, 12 * glowIntensity)
      ..color = AppColors.primary.withValues(alpha: 0.4 * glowIntensity);

    canvas.drawPath(path, outerGlowPaint);

    // Middle glow layer
    final glowPaint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 4
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round
      ..maskFilter = MaskFilter.blur(BlurStyle.normal, 6 * glowIntensity)
      ..color = glowColor;

    canvas.drawPath(path, glowPaint);

    // Sharp inner line
    final linePaint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round
      ..color = lightGlowColor;

    canvas.drawPath(path, linePaint);
  }

  @override
  bool shouldRepaint(_CurvedGlowBorderPainter oldDelegate) {
    return oldDelegate.glowIntensity != glowIntensity ||
        oldDelegate.borderRadius != borderRadius;
  }
}

