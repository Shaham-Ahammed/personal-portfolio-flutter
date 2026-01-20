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

class _PortfolioScreenState extends State<PortfolioScreen> {
  final ScrollController _scrollController = ScrollController();
  int _currentSection = 0;

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(_onScroll);
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
                  child: const HomeSection(),
                ),
                SizedBox(
                  // height: MediaQuery.of(context).size.height,
                  child: const AboutSection(),
                ),
                SizedBox(
                  // height: MediaQuery.of(context).size.height,
                  child: const ProjectsSection(),
                ),
                SizedBox(
                  // height: MediaQuery.of(context).size.height,
                  child: const ExperienceSection(),
                ),
                SizedBox(
                  // height: MediaQuery.of(context).size.height,
                  child: const ContactSection(),
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

