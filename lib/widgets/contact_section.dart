import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:simple_icons/simple_icons.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:visibility_detector/visibility_detector.dart';
import '../constants/colors.dart';
import '../constants/text_styles.dart';
import '../constants/portfolio_data.dart';

class ContactSection extends StatefulWidget {
  final Function(VoidCallback)? onRegisterReset;
  
  const ContactSection({super.key, this.onRegisterReset});

  @override
  State<ContactSection> createState() => _ContactSectionState();
}

class _ContactSectionState extends State<ContactSection>
    with SingleTickerProviderStateMixin {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _messageController = TextEditingController();
  bool _isSending = false;
  
  late AnimationController _socialIconsController;
  bool _hasAnimated = false;

  @override
  void initState() {
    super.initState();
    _socialIconsController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1500),
    );
    
    // Register reset callback with parent
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted && widget.onRegisterReset != null) {
        widget.onRegisterReset!(resetAnimations);
      }
    });
  }

  void resetAnimations() {
    setState(() {
      _hasAnimated = false;
    });
    _socialIconsController.reset();
  }

  void _onVisibilityChanged(VisibilityInfo info) {
    // Start animation when at least 30% of the widget is visible
    if (info.visibleFraction > 0.3 && !_hasAnimated && mounted) {
      _socialIconsController.forward();
      _hasAnimated = true;
    }
  }

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

  Future<void> _sendEmail() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    setState(() {
      _isSending = true;
    });

    try {
      final name = _nameController.text.trim();
      final message = _messageController.text.trim();

      final Uri emailUri = Uri(
        scheme: 'mailto',
        path: 'shahamahammed66@gmail.com',
        queryParameters: {'subject': 'name: $name', 'body': message},
      );

      if (await canLaunchUrl(emailUri)) {
        await launchUrl(emailUri);
        // Clear form after sending
        _nameController.clear();
        _emailController.clear();
        _messageController.clear();

        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Email client opened. Please send the email.'),
              backgroundColor: AppColors.primary,
            ),
          );
        }
      } else {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Could not open email client.'),
              backgroundColor: Colors.red,
            ),
          );
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: $e'), backgroundColor: Colors.red),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isSending = false;
        });
      }
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _messageController.dispose();
    _socialIconsController.dispose();
    super.dispose();
  }

  List<Widget> _buildAnimatedSocialIcons() {
    final socialIcons = <Map<String, dynamic>>[
      if (PortfolioData.githubUrl.isNotEmpty)
        {
          'icon': SimpleIcons.github,
          'color': const Color(0xFF181717),
          'url': PortfolioData.githubUrl,
        },
      if (PortfolioData.linkedinUrl.isNotEmpty)
        {
          'icon': FontAwesomeIcons.linkedin,
          'color': const Color(0xFF0A66C2),
          'url': PortfolioData.linkedinUrl,
        },
      if (PortfolioData.instagramUrl.isNotEmpty)
        {
          'icon': SimpleIcons.instagram,
          'color': const Color(0xFFE4405F),
          'url': PortfolioData.instagramUrl,
        },
      if (PortfolioData.leetcodeUrl.isNotEmpty)
        {
          'icon': SimpleIcons.leetcode,
          'color': const Color(0xFFFFA116),
          'url': PortfolioData.leetcodeUrl,
        },
      if (PortfolioData.whatsappUrl.isNotEmpty)
        {
          'icon': SimpleIcons.whatsapp,
          'color': const Color(0xFF25D366),
          'url': PortfolioData.whatsappUrl,
        },
    ];

    return List.generate(socialIcons.length, (index) {
      // Stagger each icon's animation
      final startInterval = index * 0.15;
      final endInterval = startInterval + 0.4;
      
      final animation = CurvedAnimation(
        parent: _socialIconsController,
        curve: Interval(
          startInterval.clamp(0.0, 1.0),
          endInterval.clamp(0.0, 1.0),
          curve: Curves.easeOutBack,
        ),
      );

      return AnimatedBuilder(
        animation: animation,
        builder: (context, child) {
          // Clamp opacity to valid range (easeOutBack can overshoot)
          final clampedOpacity = animation.value.clamp(0.0, 1.0);
          return Transform.translate(
            offset: Offset(0, -50 * (1 - animation.value)),
            child: Opacity(
              opacity: clampedOpacity,
              child: child,
            ),
          );
        },
        child: _SocialIconButton(
          icon: socialIcons[index]['icon'] as IconData,
          brandColor: socialIcons[index]['color'] as Color,
          onTap: () => _launchUrl(socialIcons[index]['url'] as String),
        ),
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final isMobile = size.width < 768;
    // Get keyboard height for bottom padding on mobile
    final keyboardHeight = MediaQuery.viewInsetsOf(context).bottom;

    return Container(
      width: double.infinity,
      decoration: const BoxDecoration(gradient: AppColors.backgroundGradient),
      child: Stack(
        children: [
          // Tilted background shape - desktop
          if (!isMobile)
            Positioned.fill(
              child: CustomPaint(painter: _TiltedBackgroundPainter()),
            ),
          // Tilted background shape - mobile (positioned for form area)
          if (isMobile)
            Positioned(
              left: 0,
              right: 0,
              top: 235, // Position where the form starts (after title, subtitle, description, spacing)
              height:kIsWeb? 320: 460, // Approximate form height
              child: CustomPaint(painter: _MobileFormBackgroundPainter()),
            ),
          // Content - Use AnimatedPadding for smooth keyboard transitions
          AnimatedPadding(
            duration: const Duration(milliseconds: 200),
            curve: Curves.easeOut,
            padding: EdgeInsets.only(
              left: isMobile ? 20 : 60,
              right: isMobile ? 20 : 60,
              top: isMobile ? 60 : 100,
              // Add keyboard height to bottom padding on mobile
              bottom: isMobile ? 40 + keyboardHeight : 60,
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('CONTACT ME', style: AppTextStyles.sectionTitle(context)),
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
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDesktopLayout(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        // Left side: Email and Phone tiles + Social Media
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // Email tile
              _ExpandableContactTile(
                icon: Icons.email,
                label: 'Email',
                value: PortfolioData.email,
                onTap: () => _launchEmail(PortfolioData.email),
              ),
              const SizedBox(height: 16),
              // Phone tile
              _ExpandableContactTile(
                icon: Icons.phone,
                label: 'Phone',
                value: PortfolioData.phone,
                onTap: () => _launchPhone(PortfolioData.phone),
              ),
              const SizedBox(height: 24),
              // Social Media Icons
              VisibilityDetector(
                key: const Key('social-icons-desktop'),
                onVisibilityChanged: _onVisibilityChanged,
                child: Wrap(
                  spacing: 16,
                  runSpacing: 16,
                  children: _buildAnimatedSocialIcons(),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(width: 40),
        // Center: Contact Form
        Expanded(flex: 2, child: Center(child: _buildContactForm(context, isMobile: false))),
        const SizedBox(width: 40),
        // Right side: Empty space for balance
        const Expanded(child: SizedBox()),
      ],
    );
  }

  Widget _buildMobileLayout(BuildContext context) {
    // Always show expanded tiles in mobile view
    const isRealMobile = true;
    
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Contact Form first on mobile (tilted background is in main Stack)
        Padding(
          padding: const EdgeInsets.symmetric(vertical: 16),
          child: _buildContactForm(context, isMobile: true),
        ),
        const SizedBox(height: 40),
        // Email tile - always expanded only on real mobile devices
        _ExpandableContactTile(
          icon: Icons.email,
          label: 'Email',
          value: PortfolioData.email,
          onTap: () => _launchEmail(PortfolioData.email),
          isRealMobile: isRealMobile,
        ),
        const SizedBox(height: 16),
        // Phone tile - always expanded only on real mobile devices
        _ExpandableContactTile(
          icon: Icons.phone,
          label: 'Phone',
          value: PortfolioData.phone,
          onTap: () => _launchPhone(PortfolioData.phone),
          isRealMobile: isRealMobile,
        ),
        const SizedBox(height: 24),
        // Social Media Icons - aligned to start
        VisibilityDetector(
          key: const Key('social-icons-mobile'),
          onVisibilityChanged: _onVisibilityChanged,
          child: Wrap(
            spacing: 16,
            runSpacing: 16,
            alignment: WrapAlignment.start,
            children: _buildAnimatedSocialIcons(),
          ),
        ),
      ],
    );
  }

  Widget _buildContactForm(BuildContext context, {bool isMobile = false}) {
    final size = MediaQuery.of(context).size;
    final maxWidth = size.width < 768 ? double.infinity : 500.0;
    
    // Smaller text style for mobile
    final fieldTextStyle = isMobile 
        ? AppTextStyles.bodySmall(context)
        : AppTextStyles.bodyMedium(context);
    final fieldSpacing = isMobile ? 14.0 : 20.0;
    final contentPadding = isMobile 
        ? const EdgeInsets.symmetric(horizontal: 12, vertical: 12)
        : null;
    
    // Border styles - outlined for mobile, underline for desktop
    final borderRadius = BorderRadius.circular(10);
    final border = isMobile 
        ? OutlineInputBorder(
            borderRadius: borderRadius,
            borderSide: BorderSide(
              color: AppColors.primary.withValues(alpha: 0.55),
            ),
          )
        : UnderlineInputBorder(
            borderSide: BorderSide(
              color: AppColors.primary.withValues(alpha: 0.3),
            ),
          );
    final focusedBorder = isMobile
        ? OutlineInputBorder(
            borderRadius: borderRadius,
            borderSide: const BorderSide(
              color: AppColors.primaryLight,
              width: 2,
            ),
          )
        : const UnderlineInputBorder(
            borderSide: BorderSide(
              color: AppColors.primaryLight,
              width: 2,
            ),
          );

    return SizedBox(
      width: maxWidth,
      child: Form(
        key: _formKey,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Name field
            TextFormField(
              controller: _nameController,
              autovalidateMode: AutovalidateMode.onUnfocus,
              decoration: InputDecoration(
                labelText: 'Name',
                hintText: 'Your name',
                isDense: isMobile,
                contentPadding: contentPadding,
                border: border,
                enabledBorder: border,
                focusedBorder: focusedBorder,
                labelStyle: fieldTextStyle,
                filled: isMobile,
                fillColor: isMobile ? AppColors.background.withValues(alpha: 0.5) : null,
              ),
              style: fieldTextStyle,
              validator: (value) {
                if (value == null || value.trim().isEmpty) {
                  return 'Please enter your name';
                }
                return null;
              },
            ),
            SizedBox(height: fieldSpacing),
            // Email field
            TextFormField(
              controller: _emailController,
              autovalidateMode: AutovalidateMode.onUnfocus,
              decoration: InputDecoration(
                labelText: 'Email',
                hintText: 'your.email@example.com',
                isDense: isMobile,
                contentPadding: contentPadding,
                border: border,
                enabledBorder: border,
                focusedBorder: focusedBorder,
                labelStyle: fieldTextStyle,
                filled: isMobile,
                fillColor: isMobile ? AppColors.background.withValues(alpha: 0.5) : null,
              ),
              style: fieldTextStyle,
              keyboardType: TextInputType.emailAddress,
              validator: (value) {
                if (value == null || value.trim().isEmpty) {
                  return 'Please enter your email';
                }
                // RFC 5322 compliant email regex
                final emailRegex = RegExp(
                  r'^[a-zA-Z0-9.!#$%&*+/=?^_`{|}~-]+@[a-zA-Z0-9](?:[a-zA-Z0-9-]{0,61}[a-zA-Z0-9])?(?:\.[a-zA-Z0-9](?:[a-zA-Z0-9-]{0,61}[a-zA-Z0-9])?)*$',
                );
                if (!emailRegex.hasMatch(value.trim())) {
                  return 'Please enter a valid email address';
                }
                return null;
              },
            ),
            SizedBox(height: fieldSpacing),
            // Message field
            TextFormField(
              controller: _messageController,
              autovalidateMode: AutovalidateMode.onUnfocus,
              decoration: InputDecoration(
                labelText: 'Message',
                hintText: 'Your message...',
                isDense: isMobile,
                contentPadding: contentPadding,
                border: border,
                enabledBorder: border,
                focusedBorder: focusedBorder,
                labelStyle: fieldTextStyle,
                filled: isMobile,
                fillColor: isMobile ? AppColors.background.withValues(alpha: 0.5) : null,
              ),
              style: fieldTextStyle,
              maxLines: isMobile ? 3 : 4,
              validator: (value) {
                if (value == null || value.trim().isEmpty) {
                  return 'Please enter a message';
                }
                return null;
              },
            ),
            SizedBox(height: isMobile ? 20 : 30),
            // Send button
            _HoverButton(
              onPressed: _isSending ? null : _sendEmail,
              child: _isSending
                  ? const SizedBox(
                      height: 20,
                      width: 20,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                      ),
                    )
                  : Text(
                      'Send Message',
                      style: (isMobile ? AppTextStyles.bodySmall(context) : AppTextStyles.bodyMedium(context)).copyWith(
                        color: Colors.white,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
            ),
          ],
        ),
      ),
    );
  }
}

class _ExpandableContactTile extends StatefulWidget {
  final IconData icon;
  final String value;
  final String label;
  final VoidCallback? onTap;
  final bool isRealMobile;

  const _ExpandableContactTile({
    required this.icon,
    required this.value,
    required this.label,
    this.onTap,
    this.isRealMobile = false,
  });

  @override
  State<_ExpandableContactTile> createState() => _ExpandableContactTileState();
}

class _ExpandableContactTileState extends State<_ExpandableContactTile>
    with TickerProviderStateMixin {
  late AnimationController _expandController;
  late AnimationController _rotationController;
  late Animation<double> _expandAnimation;

  @override
  void initState() {
    super.initState();
    _expandController = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );
    _expandAnimation = CurvedAnimation(
      parent: _expandController,
      curve: Curves.easeInOut,
    );

    _rotationController = AnimationController(
      duration: const Duration(milliseconds: 2000),
      vsync: this,
    );
    
    // On real mobile device, start in expanded state
    if (widget.isRealMobile) {
      _expandController.value = 1.0;
    }
  }

  @override
  void dispose() {
    _expandController.dispose();
    _rotationController.dispose();
    super.dispose();
  }

  void _onHoverStart() {
    // On real mobile device, always stay expanded
    if (widget.isRealMobile) return;
    _expandController.forward();
    _rotationController.repeat();
  }

  void _onHoverEnd() {
    // On real mobile device, always stay expanded
    if (widget.isRealMobile) return;
    _expandController.reverse();
    _rotationController.stop();
    _rotationController.reset();
  }

  @override
  Widget build(BuildContext context) {
    // Define the collapsed and expanded widths
    const double collapsedWidth = 130.0;
    const double expandedWidth = 280.0;
    const double borderRadius = 12.0;

    // Colors for the chasing border effect
    const Color bgColor = Color(0xFF1E293B); // Same as surface/background

    // On real mobile device, always show expanded with full width
    if (widget.isRealMobile) {
      return GestureDetector(
        onTap: widget.onTap,
        child: Container(
          width: double.infinity, // Full width for consistent sizing
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
          decoration: BoxDecoration(
            color: AppColors.surface,
            borderRadius: BorderRadius.circular(borderRadius),
            border: Border.all(
              color: AppColors.primary.withValues(alpha: 0.3),
              width: 1,
            ),
          ),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Icon(
                widget.icon,
                color: AppColors.primaryLight,
                size: 20,
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      widget.label,
                      style: AppTextStyles.bodySmall(context).copyWith(
                        color: AppColors.textSecondary,
                        fontSize: 12,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      widget.value,
                      style: AppTextStyles.bodySmall(context).copyWith(
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      );
    }

    return MouseRegion(
      onEnter: (_) => _onHoverStart(),
      onExit: (_) => _onHoverEnd(),
      cursor: widget.onTap != null
          ? SystemMouseCursors.click
          : SystemMouseCursors.basic,
      child: GestureDetector(
        onTap: widget.onTap,
        child: AnimatedBuilder(
          animation: Listenable.merge([_expandAnimation, _rotationController]),
          builder: (context, child) {
            final currentWidth =
                collapsedWidth +
                (_expandAnimation.value * (expandedWidth - collapsedWidth));
            final isHovered = _expandAnimation.value > 0;
            final currentBorderWidth = isHovered ? 3.0 : 1.0;

            return CustomPaint(
              painter: isHovered
                  ? _RotatingBorderPainter(
                      rotation: _rotationController.value,
                      borderRadius: borderRadius,
                      borderWidth: currentBorderWidth,
                      gradientColors: [
                        bgColor, // Invisible (same as bg)
                        bgColor, // Invisible
                        AppColors.primary, // Dark chasing segment start
                        AppColors.primary, // Dark chasing segment peak
                        bgColor, // Invisible
                        bgColor, // Invisible
                      ],
                      gradientStops: const [0.0, 0.6, 0.7, 0.85, 0.95, 1.0],
                    )
                  : null,
              child: Container(
                width: currentWidth,
                padding: EdgeInsets.symmetric(
                  horizontal: 12 + (_expandAnimation.value * 4),
                  vertical: 10 + (_expandAnimation.value * 8),
                ),
                decoration: BoxDecoration(
                  color: AppColors.surface,
                  borderRadius: BorderRadius.circular(borderRadius),
                  border: isHovered
                      ? null
                      : Border.all(
                          color: AppColors.primary.withValues(alpha: 0.3),
                          width: 1,
                        ),
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          widget.icon,
                          color: AppColors.primaryLight,
                          size: 18,
                        ),
                        const SizedBox(width: 6),
                        Text(
                          widget.label,
                          style: AppTextStyles.bodySmall(context),
                        ),
                      ],
                    ),
                    SizeTransition(
                      sizeFactor: _expandAnimation,
                      axisAlignment: -1.0,
                      child: Opacity(
                        opacity: _expandAnimation.value,
                        child: Padding(
                          padding: const EdgeInsets.only(top: 8),
                          child: Text(
                            widget.value,
                            style: AppTextStyles.bodySmall(context),
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}

class _RotatingBorderPainter extends CustomPainter {
  final double rotation;
  final double borderRadius;
  final double borderWidth;
  final List<Color> gradientColors;
  final List<double> gradientStops;

  static const double _twoPi = 2 * 3.14159265359;

  _RotatingBorderPainter({
    required this.rotation,
    required this.borderRadius,
    required this.borderWidth,
    required this.gradientColors,
    required this.gradientStops,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final rect = Rect.fromLTWH(0, 0, size.width, size.height);
    final center = Offset(size.width / 2, size.height / 2);

    // Create a larger rect centered for the gradient to avoid clipping
    final gradientRect = Rect.fromCenter(
      center: center,
      width: size.width * 1.5,
      height: size.height * 1.5,
    );

    final rrect = RRect.fromRectAndRadius(
      rect.deflate(borderWidth / 2),
      Radius.circular(borderRadius - borderWidth / 2),
    );

    // Create smooth rotating sweep gradient using GradientRotation transform
    final gradient = SweepGradient(
      center: Alignment.center,
      colors: gradientColors,
      stops: gradientStops,
      transform: GradientRotation(rotation * _twoPi),
    );

    final paint = Paint()
      ..shader = gradient.createShader(gradientRect)
      ..style = PaintingStyle.stroke
      ..strokeWidth = borderWidth
      ..strokeCap = StrokeCap.round;

    canvas.drawRRect(rrect, paint);
  }

  @override
  bool shouldRepaint(covariant _RotatingBorderPainter oldDelegate) {
    return oldDelegate.rotation != rotation ||
        oldDelegate.borderWidth != borderWidth;
  }
}

class _SocialIconButton extends StatefulWidget {
  final IconData icon;
  final VoidCallback onTap;
  final Color brandColor;

  const _SocialIconButton({
    required this.icon,
    required this.onTap,
    required this.brandColor,
  });

  @override
  State<_SocialIconButton> createState() => _SocialIconButtonState();
}

class _SocialIconButtonState extends State<_SocialIconButton> {
  bool _isHovered = false;

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      onEnter: (_) => setState(() => _isHovered = true),
      onExit: (_) => setState(() => _isHovered = false),
      cursor: SystemMouseCursors.click,
      child: GestureDetector(
        onTap: widget.onTap,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          curve: Curves.easeInOut,
          width: 48,
          height: 48,
          decoration: BoxDecoration(
            color: _isHovered ? widget.brandColor : AppColors.surface,
            shape: BoxShape.circle,
            border: Border.all(
              color: _isHovered 
                  ? widget.brandColor 
                  : AppColors.primary.withValues(alpha: 0.3),
              width: _isHovered ? 2 : 1,
            ),
            boxShadow: _isHovered
                ? [
                    // Outer glow
                    BoxShadow(
                      color: widget.brandColor.withValues(alpha: 0.6),
                      blurRadius: 18,
                      spreadRadius: 3,
                    ),
                    // Inner intense glow
                    BoxShadow(
                      color: widget.brandColor.withValues(alpha: 0.9),
                      blurRadius: 12,
                      spreadRadius: 1,
                    ),
                  ]
                : null,
          ),
          child: Center(
            child: Icon(
              widget.icon,
              color: _isHovered ? Colors.white : AppColors.primaryLight,
              size: 22,
            ),
          ),
        ),
      ),
    );
  }
}

class _TiltedBackgroundPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = AppColors.surface.withValues(alpha: 0.4)
      ..style = PaintingStyle.fill;

    // Account for padding (60px horizontal, 100px vertical)
    final horizontalPadding = 60.0;
    final verticalPadding = 100.0;

    // Calculate where the form area starts
    // Left side takes ~1/3, then 40px gap, then form starts
    // Form starts around 50-55% of the content width (after padding)
    final contentWidth = size.width - (horizontalPadding * 2);
    final formStartX = horizontalPadding + (contentWidth * 0.32);

    // Diagonal height - where the tilted line ends and vertical starts
    // This should be around where the form content starts (after title, description, etc.)
    final diagonalHeight =
        verticalPadding + 180.0; // Approximate start of form content

    final path = Path();

    // Start from top-left (beginning of contact page)
    path.moveTo(size.width / 1.5, 0);

    // Go diagonally to form start position
    path.lineTo(formStartX, diagonalHeight);

    // Go straight down to bottom
    path.lineTo(formStartX, size.height);

    // Go to bottom-right
    path.lineTo(size.width, size.height);

    // Go to top-right
    path.lineTo(size.width, 0);

    // Close the path
    path.close();

    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

class _MobileFormBackgroundPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    // Light primary color for fill
    final fillPaint = Paint()
      ..color = const Color.fromARGB(255, 82, 76, 145).withValues(alpha: .16)
      ..style = PaintingStyle.fill;

    // Create the tilted shape path - tilt from left to right
    final path = Path();
    
    // Start from top left (slightly down)
    path.moveTo(0,  0);
    
    // Go diagonally to top right (higher)
    path.lineTo(size.width, 30);
    
    // Go down to bottom right
    path.lineTo(size.width, size.height * 1);
    
    // Go diagonally to bottom left (lower)
    path.lineTo(0, size.height);
    
    // Close back to start
    path.close();

    // Draw the filled area only (no border)
    canvas.drawPath(path, fillPaint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

class _HoverButton extends StatefulWidget {
  final VoidCallback? onPressed;
  final Widget child;

  const _HoverButton({required this.onPressed, required this.child});

  @override
  State<_HoverButton> createState() => _HoverButtonState();
}

class _HoverButtonState extends State<_HoverButton> {
  bool _isHovered = false;

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      onEnter: (_) => setState(() => _isHovered = true),
      onExit: (_) => setState(() => _isHovered = false),
      cursor: widget.onPressed != null
          ? SystemMouseCursors.click
          : SystemMouseCursors.basic,
      child: GestureDetector(
        onTap: widget.onPressed,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 32),
          decoration: BoxDecoration(
            color: _isHovered
                ? AppColors.primary.withValues(alpha: 0.2)
                : Colors.transparent,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: _isHovered
                  ? AppColors.primaryLight
                  : AppColors.primary.withValues(alpha: 0.5),
              width: 2,
            ),
          ),
          child: Center(child: widget.child),
        ),
      ),
    );
  }
}
