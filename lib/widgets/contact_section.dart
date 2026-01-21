import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import '../constants/colors.dart';
import '../constants/text_styles.dart';
import '../constants/portfolio_data.dart';

class ContactSection extends StatelessWidget {
  const ContactSection({super.key});

  Future<void> _launchUrl(String url) async {
    final Uri uri = Uri.parse(url);
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    }
  }

  Future<void> _launchEmail(String email) async {
    final Uri uri = Uri.parse('mailto:$email');
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri);
    }
  }

  Future<void> _launchPhone(String phone) async {
    final Uri uri = Uri.parse('tel:$phone');
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri);
    }
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final isMobile = size.width < 768;

    return Container(
      width: double.infinity,
      constraints: BoxConstraints(
        minHeight: size.height,
      ),
      decoration: const BoxDecoration(
        gradient: AppColors.backgroundGradient,
      ),
      padding: EdgeInsets.symmetric(
        horizontal: isMobile ? 20 : 60,
        vertical: isMobile ? 60 : 100,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'CONTACT',
            style: AppTextStyles.sectionTitle(context),
          ),
          const SizedBox(height: 16),
          Text(
            'Let\'s Get In Touch',
            style: AppTextStyles.heading2(context),
          ),
          const SizedBox(height: 16),
          Text(
            'I\'m always open to discussing new projects, creative ideas, or opportunities to be part of your visions.',
            style: AppTextStyles.bodyLarge(context),
          ),
          const SizedBox(height: 60),
          isMobile
              ? _buildMobileLayout(context)
              : _buildDesktopLayout(context),
          const SizedBox(height: 60),
          Text(
            'Social Media',
            style: AppTextStyles.heading3(context),
          ),
          const SizedBox(height: 24),
          _buildSocialLinks(context, isMobile),
        ],
      ),
    );
  }

  Widget _buildDesktopLayout(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: _ContactCard(
            icon: Icons.email,
            title: 'Email',
            subtitle: PortfolioData.email,
            onTap: () => _launchEmail(PortfolioData.email),
          ),
        ),
        const SizedBox(width: 24),
        Expanded(
          child: _ContactCard(
            icon: Icons.phone,
            title: 'Phone',
            subtitle: PortfolioData.phone,
            onTap: () => _launchPhone(PortfolioData.phone),
          ),
        ),
        const SizedBox(width: 24),
        Expanded(
          child: _ContactCard(
            icon: Icons.location_on,
            title: 'Location',
            subtitle: PortfolioData.location,
            onTap: null,
          ),
        ),
      ],
    );
  }

  Widget _buildMobileLayout(BuildContext context) {
    return Column(
      children: [
        _ContactCard(
          icon: Icons.email,
          title: 'Email',
          subtitle: PortfolioData.email,
          onTap: () => _launchEmail(PortfolioData.email),
        ),
        const SizedBox(height: 16),
        _ContactCard(
          icon: Icons.phone,
          title: 'Phone',
          subtitle: PortfolioData.phone,
          onTap: () => _launchPhone(PortfolioData.phone),
        ),
        const SizedBox(height: 16),
        _ContactCard(
          icon: Icons.location_on,
          title: 'Location',
          subtitle: PortfolioData.location,
          onTap: null,
        ),
      ],
    );
  }

  Widget _buildSocialLinks(BuildContext context, bool isMobile) {
    return Wrap(
      spacing: 16,
      runSpacing: 16,
      alignment: WrapAlignment.start,
      children: [
        if (PortfolioData.githubUrl.isNotEmpty)
          _SocialLinkButton(
            icon: Icons.code,
            label: 'GitHub',
            url: PortfolioData.githubUrl,
            onTap: () => _launchUrl(PortfolioData.githubUrl),
          ),
        if (PortfolioData.linkedinUrl.isNotEmpty)
          _SocialLinkButton(
            icon: Icons.business_center,
            label: 'LinkedIn',
            url: PortfolioData.linkedinUrl,
            onTap: () => _launchUrl(PortfolioData.linkedinUrl),
          ),
        if (PortfolioData.twitterUrl.isNotEmpty)
          _SocialLinkButton(
            icon: Icons.alternate_email,
            label: 'Twitter',
            url: PortfolioData.twitterUrl,
            onTap: () => _launchUrl(PortfolioData.twitterUrl),
          ),
        if (PortfolioData.instagramUrl.isNotEmpty)
          _SocialLinkButton(
            icon: Icons.camera_alt,
            label: 'Instagram',
            url: PortfolioData.instagramUrl,
            onTap: () => _launchUrl(PortfolioData.instagramUrl),
          ),
      ],
    );
  }
}

class _ContactCard extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;
  final VoidCallback? onTap;

  const _ContactCard({
    required this.icon,
    required this.title,
    required this.subtitle,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(16),
      child: Container(
        padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: AppColors.primary.withValues(alpha: 0.2),
            width: 1,
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: AppColors.primary.withValues(alpha: 0.2),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(
                icon,
                color: AppColors.primaryLight,
                size: 28,
              ),
            ),
            const SizedBox(height: 20),
            Text(
              title,
              style: AppTextStyles.bodyMedium(context).copyWith(
                color: AppColors.primaryLight,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              subtitle,
              style: AppTextStyles.bodySmall(context),
            ),
          ],
        ),
      ),
    );
  }
}

class _SocialLinkButton extends StatelessWidget {
  final IconData icon;
  final String label;
  final String url;
  final VoidCallback onTap;

  const _SocialLinkButton({
    required this.icon,
    required this.label,
    required this.url,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: AppColors.primary.withValues(alpha: 0.3),
            width: 1,
          ),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, color: AppColors.primaryLight, size: 20),
            const SizedBox(width: 12),
            Text(
              label,
              style: AppTextStyles.bodyMedium(context).copyWith(
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

