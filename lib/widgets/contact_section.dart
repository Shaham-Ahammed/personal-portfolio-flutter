import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import '../constants/colors.dart';
import '../constants/text_styles.dart';
import '../constants/portfolio_data.dart';

class ContactSection extends StatefulWidget {
  const ContactSection({super.key});

  @override
  State<ContactSection> createState() => _ContactSectionState();
}

class _ContactSectionState extends State<ContactSection> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _messageController = TextEditingController();
  bool _isSending = false;

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
        queryParameters: {'subject': name, 'body': message},
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
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final isMobile = size.width < 768;

    return Container(
      width: double.infinity,
      decoration: const BoxDecoration(gradient: AppColors.backgroundGradient),
      child: Stack(
        children: [
          // Tilted background shape
          if (!isMobile)
            Positioned.fill(
              child: CustomPaint(painter: _TiltedBackgroundPainter()),
            ),
          // Content
          Padding(
            padding: EdgeInsets.only(
              left: isMobile ? 20 : 60,
              right: isMobile ? 20 : 60,
              top: isMobile ? 60 : 100,
              bottom: isMobile ? 40 : 60,
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('CONTACT', style: AppTextStyles.sectionTitle(context)),
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
              Wrap(
                spacing: 16,
                runSpacing: 16,
                children: [
                  if (PortfolioData.githubUrl.isNotEmpty)
                    _SocialIconButton(
                      icon: Icons.code,
                      url: PortfolioData.githubUrl,
                      onTap: () => _launchUrl(PortfolioData.githubUrl),
                    ),
                  if (PortfolioData.linkedinUrl.isNotEmpty)
                    _SocialIconButton(
                      icon: Icons.business_center,
                      url: PortfolioData.linkedinUrl,
                      onTap: () => _launchUrl(PortfolioData.linkedinUrl),
                    ),
                  if (PortfolioData.twitterUrl.isNotEmpty)
                    _SocialIconButton(
                      icon: Icons.alternate_email,
                      url: PortfolioData.twitterUrl,
                      onTap: () => _launchUrl(PortfolioData.twitterUrl),
                    ),
                  if (PortfolioData.instagramUrl.isNotEmpty)
                    _SocialIconButton(
                      icon: Icons.camera_alt,
                      url: PortfolioData.instagramUrl,
                      onTap: () => _launchUrl(PortfolioData.instagramUrl),
                    ),
                ],
              ),
            ],
          ),
        ),
        const SizedBox(width: 40),
        // Center: Contact Form
        Expanded(flex: 2, child: Center(child: _buildContactForm(context))),
        const SizedBox(width: 40),
        // Right side: Empty space for balance
        const Expanded(child: SizedBox()),
      ],
    );
  }

  Widget _buildMobileLayout(BuildContext context) {
    return Column(
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
        Wrap(
          spacing: 16,
          runSpacing: 16,
          alignment: WrapAlignment.center,
          children: [
            if (PortfolioData.githubUrl.isNotEmpty)
              _SocialIconButton(
                icon: Icons.code,
                url: PortfolioData.githubUrl,
                onTap: () => _launchUrl(PortfolioData.githubUrl),
              ),
            if (PortfolioData.linkedinUrl.isNotEmpty)
              _SocialIconButton(
                icon: Icons.business_center,
                url: PortfolioData.linkedinUrl,
                onTap: () => _launchUrl(PortfolioData.linkedinUrl),
              ),
            if (PortfolioData.twitterUrl.isNotEmpty)
              _SocialIconButton(
                icon: Icons.alternate_email,
                url: PortfolioData.twitterUrl,
                onTap: () => _launchUrl(PortfolioData.twitterUrl),
              ),
            if (PortfolioData.instagramUrl.isNotEmpty)
              _SocialIconButton(
                icon: Icons.camera_alt,
                url: PortfolioData.instagramUrl,
                onTap: () => _launchUrl(PortfolioData.instagramUrl),
              ),
          ],
        ),
        const SizedBox(height: 40),
        // Contact Form
        Center(child: _buildContactForm(context)),
      ],
    );
  }

  Widget _buildContactForm(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final maxWidth = size.width < 768 ? double.infinity : 500.0;

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
              decoration: InputDecoration(
                labelText: 'Name',
                hintText: 'Your name',
                border: UnderlineInputBorder(
                  borderSide: BorderSide(
                    color: AppColors.primary.withValues(alpha: 0.3),
                  ),
                ),
                enabledBorder: UnderlineInputBorder(
                  borderSide: BorderSide(
                    color: AppColors.primary.withValues(alpha: 0.3),
                  ),
                ),
                focusedBorder: const UnderlineInputBorder(
                  borderSide: BorderSide(
                    color: AppColors.primaryLight,
                    width: 2,
                  ),
                ),
                labelStyle: AppTextStyles.bodyMedium(context),
              ),
              style: AppTextStyles.bodyMedium(context),
              validator: (value) {
                if (value == null || value.trim().isEmpty) {
                  return 'Please enter your name';
                }
                return null;
              },
            ),
            const SizedBox(height: 20),
            // Email field
            TextFormField(
              controller: _emailController,
              decoration: InputDecoration(
                labelText: 'Email',
                hintText: 'your.email@example.com',
                border: UnderlineInputBorder(
                  borderSide: BorderSide(
                    color: AppColors.primary.withValues(alpha: 0.3),
                  ),
                ),
                enabledBorder: UnderlineInputBorder(
                  borderSide: BorderSide(
                    color: AppColors.primary.withValues(alpha: 0.3),
                  ),
                ),
                focusedBorder: const UnderlineInputBorder(
                  borderSide: BorderSide(
                    color: AppColors.primaryLight,
                    width: 2,
                  ),
                ),
                labelStyle: AppTextStyles.bodyMedium(context),
              ),
              style: AppTextStyles.bodyMedium(context),
              keyboardType: TextInputType.emailAddress,
              validator: (value) {
                if (value == null || value.trim().isEmpty) {
                  return 'Please enter your email';
                }
                if (!value.contains('@')) {
                  return 'Please enter a valid email';
                }
                return null;
              },
            ),
            const SizedBox(height: 20),
            // Message field
            TextFormField(
              controller: _messageController,
              decoration: InputDecoration(
                labelText: 'Message',
                hintText: 'Your message...',
                border: UnderlineInputBorder(
                  borderSide: BorderSide(
                    color: AppColors.primary.withValues(alpha: 0.3),
                  ),
                ),
                enabledBorder: UnderlineInputBorder(
                  borderSide: BorderSide(
                    color: AppColors.primary.withValues(alpha: 0.3),
                  ),
                ),
                focusedBorder: const UnderlineInputBorder(
                  borderSide: BorderSide(
                    color: AppColors.primaryLight,
                    width: 2,
                  ),
                ),
                labelStyle: AppTextStyles.bodyMedium(context),
              ),
              style: AppTextStyles.bodyMedium(context),
              maxLines: 4,
              validator: (value) {
                if (value == null || value.trim().isEmpty) {
                  return 'Please enter a message';
                }
                return null;
              },
            ),
            const SizedBox(height: 30),
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
                      style: AppTextStyles.bodyMedium(context).copyWith(
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

  const _ExpandableContactTile({
    required this.icon,
    required this.value,
    required this.label,
    this.onTap,
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
  }

  @override
  void dispose() {
    _expandController.dispose();
    _rotationController.dispose();
    super.dispose();
  }

  void _onHoverStart() {
    _expandController.forward();
    _rotationController.repeat();
  }

  void _onHoverEnd() {
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
    const double defaultBorderWidth = 1.0;
    const double hoverBorderWidth = 3.0;

    // Colors for the chasing border effect
    const Color bgColor = Color(0xFF1E293B); // Same as surface/background
    const Color darkChaseColor = Color(
      0xFF060A12,
    ); // Very dark, darker than background

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

class _SocialIconButton extends StatelessWidget {
  final IconData icon;
  final String url;
  final VoidCallback onTap;

  const _SocialIconButton({
    required this.icon,
    required this.url,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: AppColors.primary.withValues(alpha: 0.3),
            width: 1,
          ),
        ),
        child: Icon(icon, color: AppColors.primaryLight, size: 20),
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
