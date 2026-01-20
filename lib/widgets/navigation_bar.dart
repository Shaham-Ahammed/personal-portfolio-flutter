import 'package:flutter/material.dart';
import '../constants/colors.dart';
import '../constants/text_styles.dart';

class PortfolioNavigationBar extends StatelessWidget {
  final int currentSection;
  final Function(int) onSectionTap;

  const PortfolioNavigationBar({
    super.key,
    required this.currentSection,
    required this.onSectionTap,
  });

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
        color: AppColors.background.withOpacity(0.9),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
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
                onTap: () => onSectionTap(0),
                isActive: currentSection == 0,
              ),
              const SizedBox(width: 30),
              _NavItem(
                label: 'Skills',
                onTap: () => onSectionTap(1),
                isActive: currentSection == 1,
              ),
              const SizedBox(width: 30),
              _NavItem(
                label: 'Projects',
                onTap: () => onSectionTap(2),
                isActive: currentSection == 2,
              ),
              const SizedBox(width: 30),
              _NavItem(
                label: 'Experience',
                onTap: () => onSectionTap(3),
                isActive: currentSection == 3,
              ),
              const SizedBox(width: 30),
              _NavItem(
                label: 'Contact',
                onTap: () => onSectionTap(4),
                isActive: currentSection == 4,
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildMobileNavBar(BuildContext context) {
    return Container(
      height: 70,
      padding: const EdgeInsets.symmetric(horizontal: 20),
      decoration: BoxDecoration(
        color: AppColors.background.withOpacity(0.9),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
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
            icon: const Icon(Icons.menu, color: AppColors.textPrimary),
            onPressed: () => _showMobileMenu(context),
          ),
        ],
      ),
    );
  }

  void _showMobileMenu(BuildContext context) {
    showModalBottomSheet(
      context: context,
      backgroundColor: AppColors.surface,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => Container(
        padding: const EdgeInsets.all(20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            _MobileNavItem(
              label: 'Home',
              icon: Icons.home,
              onTap: () {
                Navigator.pop(context);
                onSectionTap(0);
              },
            ),
            _MobileNavItem(
              label: 'Skills',
              icon: Icons.code,
              onTap: () {
                Navigator.pop(context);
                onSectionTap(1);
              },
            ),
            _MobileNavItem(
              label: 'Projects',
              icon: Icons.folder,
              onTap: () {
                Navigator.pop(context);
                onSectionTap(2);
              },
            ),
            _MobileNavItem(
              label: 'Experience',
              icon: Icons.work,
              onTap: () {
                Navigator.pop(context);
                onSectionTap(3);
              },
            ),
            _MobileNavItem(
              label: 'Contact',
              icon: Icons.contact_mail,
              onTap: () {
                Navigator.pop(context);
                onSectionTap(4);
              },
            ),
          ],
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
              color: isActive ? AppColors.primary.withOpacity(0.2) : Colors.transparent,
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

class _MobileNavItem extends StatelessWidget {
  final String label;
  final IconData icon;
  final VoidCallback onTap;

  const _MobileNavItem({
    required this.label,
    required this.icon,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return ListTile(
      leading: Icon(icon, color: AppColors.primaryLight),
      title: Text(
        label,
        style: AppTextStyles.bodyMedium(context),
      ),
      onTap: onTap,
    );
  }
}

