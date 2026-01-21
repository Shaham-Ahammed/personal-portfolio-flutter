import 'package:flutter/material.dart';
import '../constants/colors.dart';
import '../constants/text_styles.dart';
import '../constants/portfolio_data.dart';
import '../models/experience_model.dart';

class ExperienceSection extends StatelessWidget {
  const ExperienceSection({super.key});

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final isMobile = size.width < 768;

    return Container(
      width: double.infinity,
      constraints: BoxConstraints(
        minHeight: size.height,
      ),
      color: AppColors.backgroundLight,
      padding: EdgeInsets.symmetric(
        horizontal: isMobile ? 20 : 60,
        vertical: isMobile ? 60 : 100,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'EXPERIENCE',
            style: AppTextStyles.sectionTitle(context),
          ),
          const SizedBox(height: 16),
          Text(
            'My Career Journey',
            style: AppTextStyles.heading2(context),
          ),
          const SizedBox(height: 60),
          _buildExperiencesList(context, isMobile),
        ],
      ),
    );
  }

  Widget _buildExperiencesList(BuildContext context, bool isMobile) {
    final experiences = PortfolioData.experiences
        .map((exp) => Experience.fromMap(exp))
        .toList();

    return isMobile
        ? Column(
            children: experiences
                .asMap()
                .entries
                .map((entry) => Padding(
                      padding: const EdgeInsets.only(bottom: 32),
                      child: _ExperienceCard(
                        experience: entry.value,
                        isLast: entry.key == experiences.length - 1,
                        isMobile: true,
                      ),
                    ))
                .toList(),
          )
        : Column(
            children: experiences
                .asMap()
                .entries
                .map((entry) => Padding(
                      padding: const EdgeInsets.only(bottom: 40),
                      child: _ExperienceCard(
                        experience: entry.value,
                        isLast: entry.key == experiences.length - 1,
                        isMobile: false,
                      ),
                    ))
                .toList(),
          );
  }
}

class _ExperienceCard extends StatelessWidget {
  final Experience experience;
  final bool isLast;
  final bool isMobile;

  const _ExperienceCard({
    required this.experience,
    required this.isLast,
    required this.isMobile,
  });

  @override
  Widget build(BuildContext context) {
    if (isMobile) {
      return _buildMobileCard(context);
    } else {
      return _buildDesktopCard(context);
    }
  }

  Widget _buildDesktopCard(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Column(
          children: [
            Container(
              width: 16,
              height: 16,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: AppColors.primary,
                border: Border.all(
                  color: AppColors.backgroundLight,
                  width: 4,
                ),
              ),
            ),
            if (!isLast)
              Container(
                width: 2,
                height: 120,
                color: AppColors.primary.withValues(alpha: 0.3),
              ),
          ],
        ),
        const SizedBox(width: 24),
        Expanded(
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
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            experience.title,
                            style: AppTextStyles.heading4(context),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            experience.company,
                            style: AppTextStyles.bodyLarge(context).copyWith(
                              color: AppColors.primaryLight,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ],
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 8,
                      ),
                      decoration: BoxDecoration(
                        color: AppColors.primary.withValues(alpha: 0.2),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Text(
                        experience.period,
                        style: AppTextStyles.bodySmall(context).copyWith(
                          color: AppColors.primaryLight,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                Row(
                  children: [
                    Icon(
                      Icons.location_on,
                      size: 16,
                      color: AppColors.textTertiary,
                    ),
                    const SizedBox(width: 4),
                    Text(
                      experience.location,
                      style: AppTextStyles.bodySmall(context),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                Text(
                  experience.description,
                  style: AppTextStyles.bodyMedium(context),
                ),
                const SizedBox(height: 16),
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: experience.technologies
                      .map((tech) => Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 12,
                              vertical: 6,
                            ),
                            decoration: BoxDecoration(
                              color: AppColors.surfaceLight,
                              borderRadius: BorderRadius.circular(20),
                            ),
                            child: Text(
                              tech,
                              style: AppTextStyles.bodySmall(context),
                            ),
                          ))
                      .toList(),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildMobileCard(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
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
          Text(
            experience.title,
            style: AppTextStyles.heading4(context),
          ),
          const SizedBox(height: 4),
          Text(
            experience.company,
            style: AppTextStyles.bodyMedium(context).copyWith(
              color: AppColors.primaryLight,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 8),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  Icon(
                    Icons.location_on,
                    size: 14,
                    color: AppColors.textTertiary,
                  ),
                  const SizedBox(width: 4),
                  Text(
                    experience.location,
                    style: AppTextStyles.bodySmall(context),
                  ),
                ],
              ),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 6,
                ),
                decoration: BoxDecoration(
                  color: AppColors.primary.withValues(alpha: 0.2),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  experience.period,
                  style: AppTextStyles.bodySmall(context).copyWith(
                    color: AppColors.primaryLight,
                    fontWeight: FontWeight.w600,
                    fontSize: 12,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Text(
            experience.description,
            style: AppTextStyles.bodyMedium(context),
          ),
          const SizedBox(height: 16),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: experience.technologies
                .map((tech) => Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 10,
                        vertical: 6,
                      ),
                      decoration: BoxDecoration(
                        color: AppColors.surfaceLight,
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Text(
                        tech,
                        style: AppTextStyles.bodySmall(context).copyWith(
                          fontSize: 12,
                        ),
                      ),
                    ))
                .toList(),
          ),
        ],
      ),
    );
  }
}

