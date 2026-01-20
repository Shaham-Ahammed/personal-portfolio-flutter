import 'package:flutter/material.dart';
import 'package:personal_portfoliio/constants/images.dart';

import '../constants/colors.dart';
import '../constants/text_styles.dart';
import '../constants/portfolio_data.dart';

class AboutSection extends StatelessWidget {
  const AboutSection({super.key});

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final isMobile = size.width < 768;

    return Container(
      width: double.infinity,
      constraints: BoxConstraints(minHeight: size.height),
      color: AppColors.backgroundLight,
      padding: EdgeInsets.symmetric(
        horizontal: isMobile ? 20 : 60,
        vertical: isMobile ? 60 : 100,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('ABOUT', style: AppTextStyles.sectionTitle(context)),
          const SizedBox(height: 16),
          Text('Who I Am', style: AppTextStyles.heading2(context)),
          const SizedBox(height: 40),
          isMobile
              ? _buildContentBox(context)
              : Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(flex: 2, child: _buildContentBox(context)),
                    const SizedBox(width: 60),
                    Expanded(flex: 1, child: _buildGifContainer(context)),
                  ],
                ),
        ],
      ),
    );
  }

  Widget _buildContentBox(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(32),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.primary.withOpacity(0.2), width: 1),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 20,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            PortfolioData.bio,
            style: AppTextStyles.bodyLarge(
              context,
            ).copyWith(color: AppColors.textSecondary, height: 1.7),
          ),
          const SizedBox(height: 40),
          Text(
            'Skills & Tools',
            style: AppTextStyles.heading4(
              context,
            ).copyWith(color: AppColors.primaryLight),
          ),
          const SizedBox(height: 20),
          Wrap(
            spacing: 12,
            runSpacing: 12,
            children: [
              for (final skillMap in PortfolioData.skills)
                _SkillBullet(name: skillMap['name'] as String),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildGifContainer(BuildContext context) {
    return Center(
      child: SizedBox(
        width: 300,

        child: Stack(
          clipBehavior: Clip.none,
          children: [
            // Decorative outlined container behind/offset from the GIF
            Positioned(
              top: 26,
              left: 46,
              child: Container(
                width: 230,
                height: 300,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(
                    color: AppColors.primary.withOpacity(0.4),
                    width: 3,
                  ),
                  color: Colors.transparent,
                ),
              ),
            ),
            // Main GIF card
            Container(
              height: 300,
              width: 250,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(20),
                color: Colors.black,
                border: Border.all(
                  color: AppColors.primary.withOpacity(0.2),
                  width: 1,
                ),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.18),
                    blurRadius: 20,
                    offset: const Offset(0, 8),
                  ),
                ],
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(20),
                child: Image.asset(
                  AppImages.aboutAnimation,
                  fit: BoxFit.cover,
                  errorBuilder: (context, error, stackTrace) {
                    return Container(
                      height: 220,
                      decoration: BoxDecoration(
                        color: AppColors.surface,
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(
                          color: AppColors.primary.withOpacity(0.2),
                          width: 1,
                        ),
                      ),
                      child: const Center(
                        child: Icon(
                          Icons.image,
                          size: 80,
                          color: AppColors.textSecondary,
                        ),
                      ),
                    );
                  },
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _SkillBullet extends StatelessWidget {
  const _SkillBullet({required this.name});

  final String name;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: AppColors.primary.withOpacity(0.35),
          width: 1,
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 6,
            height: 6,
            decoration: const BoxDecoration(
              shape: BoxShape.circle,
              color: AppColors.primaryLight,
            ),
          ),
          const SizedBox(width: 8),
          Text(
            name,
            style: AppTextStyles.bodyMedium(context).copyWith(
              color: AppColors.textSecondary,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }
}
