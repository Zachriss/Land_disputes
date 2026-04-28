import 'package:flutter/material.dart';
import '../constants/colors.dart';
import '../constants/strings.dart';
import 'auth/login_screen.dart';
import 'auth/register_screen.dart';

class LandingScreen extends StatefulWidget {
  const LandingScreen({super.key});

  @override
  State<LandingScreen> createState() => _LandingScreenState();
}

class _LandingScreenState extends State<LandingScreen> with TickerProviderStateMixin {
  late AnimationController _mainController;
  late AnimationController _cardController;
  late Animation<double> _fadeAnimation;
  late Animation<Offset> _slideAnimation;
  late Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();
    _mainController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1500),
    );

    _cardController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 2000),
    );

    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _mainController, curve: Curves.easeInOutCubic),
    );

    _slideAnimation = Tween<Offset>(
      begin: const Offset(0, 0.4),
      end: Offset.zero,
    ).animate(
      CurvedAnimation(parent: _mainController, curve: Curves.easeOutCubic),
    );

    _scaleAnimation = Tween<double>(begin: 0.8, end: 1.0).animate(
      CurvedAnimation(parent: _mainController, curve: Curves.elasticOut),
    );

    _mainController.forward().then((_) {
      _cardController.forward();
    });
  }

  @override
  void dispose() {
    _mainController.dispose();
    _cardController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              AppColors.primaryColor.withOpacity(0.08),
              Colors.white,
              Colors.white,
            ],
          ),
        ),
        child: SafeArea(
          top: true,
          bottom: true,
          child: FadeTransition(
            opacity: _fadeAnimation,
            child: SlideTransition(
              position: _slideAnimation,
              child: Column(
                children: [
                  Expanded(
                    child: SingleChildScrollView(
                      physics: const BouncingScrollPhysics(),
                      padding: const EdgeInsets.fromLTRB(32, 24, 32, 24),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          ScaleTransition(
                            scale: _scaleAnimation,
                            child: Container(
                              padding: const EdgeInsets.all(28),
                              decoration: BoxDecoration(
                                color: AppColors.primaryColor.withOpacity(0.12),
                                shape: BoxShape.circle,
                                boxShadow: [
                                  BoxShadow(
                                    color: AppColors.primaryColor.withOpacity(0.15),
                                    blurRadius: 30,
                                    spreadRadius: 5,
                                  ),
                                ],
                              ),
                              child: const Icon(
                                Icons.gavel,
                                size: 90,
                                color: AppColors.primaryColor,
                              ),
                            ),
                          ),
                          const SizedBox(height: 36),
                          // App Title
                          const Text(
                            'Land Disputes Resolution App',
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              fontSize: 30,
                              fontWeight: FontWeight.w800,
                              color: Colors.black87,
                              height: 1.2,
                            ),
                          ),
                          const SizedBox(height: 16),
                          // App Subtitle
                          const Text(
                            'Resolve land conflicts fairly, transparently and efficiently with professional mediation services',
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              fontSize: 16,
                              color: Colors.black54,
                              height: 1.6,
                            ),
                          ),
                          const SizedBox(height: 40),

                          // Feature Cards with Staggered Animation
                          AnimatedBuilder(
                            animation: _cardController,
                            builder: (context, child) {
                              return Column(
                                children: [
                                  _buildAnimatedFeatureCard(0),
                                  const SizedBox(height: 16),
                                  _buildAnimatedFeatureCard(1),
                                  const SizedBox(height: 16),
                                  _buildAnimatedFeatureCard(2),
                                  const SizedBox(height: 16),
                                  _buildAnimatedFeatureCard(3),
                                ],
                              );
                            },
                          ),
                          const SizedBox(height: 40),

                          // Trust Indicators
                          Container(
                            padding: const EdgeInsets.all(20),
                            decoration: BoxDecoration(
                              color: Colors.grey[50],
                              borderRadius: BorderRadius.circular(16),
                            ),
                            child: const Row(
                              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                              children: [
                                _TrustIcon(
                                  icon: Icons.verified_user,
                                  label: 'Secure',
                                ),
                                _TrustIcon(
                                  icon: Icons.privacy_tip,
                                  label: 'Private',
                                ),
                                _TrustIcon(
                                  icon: Icons.thumb_up,
                                  label: 'Trusted',
                                ),
                                _TrustIcon(
                                  icon: Icons.support_agent,
                                  label: 'Support',
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(height: 32),
                        ],
                      ),
                    ),
                  ),
                  // Fixed Bottom Section
                  Container(
                    padding: const EdgeInsets.fromLTRB(32, 12, 32, 8),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      boxShadow: [
                        BoxShadow(
                          color: Colors.grey.withOpacity(0.05),
                          blurRadius: 10,
                          offset: const Offset(0, -5),
                        ),
                      ],
                    ),
                    child: Column(
                      children: [
                        // Get Started Button
                        SizedBox(
                          width: double.infinity,
                          child: ElevatedButton(
                            onPressed: () {
                              Navigator.push(context, MaterialPageRoute(builder: (context) => const LoginScreen()));
                            },
                            style: ElevatedButton.styleFrom(
                              backgroundColor: AppColors.primaryColor,
                              padding: const EdgeInsets.symmetric(vertical: 18),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(14),
                              ),
                              elevation: 3,
                              shadowColor: AppColors.primaryColor.withOpacity(0.3),
                            ),
                            child: const Text(
                              'Get Started',
                              style: TextStyle(
                                fontSize: 17,
                                fontWeight: FontWeight.bold,
                                color: Colors.white,
                                letterSpacing: 0.5,
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(height: 24),
                        // Authentication Links
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            const Text(
                              "Don't have an account? ",
                              style: TextStyle(
                                fontSize: 15,
                                color: Colors.grey,
                              ),
                            ),
                            GestureDetector(
                              onTap: () {
                                Navigator.push(context, MaterialPageRoute(builder: (context) => const RegisterScreen()));
                              },
                              child: const Text(
                                'Register',
                                style: TextStyle(
                                  fontSize: 15,
                                  fontWeight: FontWeight.w700,
                                  color: AppColors.primaryColor,
                                ),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 12),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            const Text(
                              "Have an account? ",
                              style: TextStyle(
                                fontSize: 15,
                                color: Colors.grey,
                              ),
                            ),
                            GestureDetector(
                              onTap: () {
                                Navigator.push(context, MaterialPageRoute(builder: (context) => const LoginScreen()));
                              },
                              child: const Text(
                                'Login',
                                style: TextStyle(
                                  fontSize: 15,
                                  fontWeight: FontWeight.w700,
                                  color: AppColors.primaryColor,
                                ),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 16),

                        // App Version
                        const Text(
                          'Version 1.0.0',
                          style: TextStyle(
                            fontSize: 12,
                            color: Colors.grey,
                            fontWeight: FontWeight.w400,
                          ),
                        ),
                        const SizedBox(height: 4),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildAnimatedFeatureCard(int index) {
    final double start = index * 0.15;
    final double end = (start + 0.7).clamp(0.0, 1.0);

    final Animation<double> animation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _cardController,
        curve: Interval(start, end, curve: Curves.easeOut),
      ),
    );

    return AnimatedBuilder(
      animation: animation,
      builder: (context, child) {
        return Transform.translate(
          offset: Offset(0, 30 * (1 - animation.value.clamp(0.0, 1.0))),
          child: Opacity(
            opacity: animation.value.clamp(0.0, 1.0),
            child: child,
          ),
        );
      },
      child: _buildFeatureCard(
        icon: _features[index]['icon'] as IconData,
        title: _features[index]['title'] as String,
        description: _features[index]['description'] as String,
      ),
    );
  }

  final List<Map<String, dynamic>> _features = const [
    {
      'icon': Icons.balance,
      'title': 'Professional Mediation',
      'description': 'Certified neutral mediators ensure fair conflict resolution for all parties',
    },
    {
      'icon': Icons.speed,
      'title': 'Real-Time Tracking',
      'description': 'Monitor your case progress with live status updates and notifications',
    },
    {
      'icon': Icons.security,
      'title': 'Secure & Confidential',
      'description': 'All documents and communications are encrypted and fully protected',
    },
    {
      'icon': Icons.history,
      'title': 'Transparent History',
      'description': 'Complete audit trail of all actions, decisions and communications',
    },
  ];

  Widget _buildFeatureCard({
    required IconData icon,
    required String title,
    required String description,
  }) {
    return Card(
      elevation: 2,
      shadowColor: AppColors.primaryColor.withOpacity(0.08),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(14),
      ),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: AppColors.primaryColor.withOpacity(0.12),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(
                icon,
                color: AppColors.primaryColor,
                size: 28,
              ),
            ),
            const SizedBox(width: 20),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: Colors.black87,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    description,
                    style: const TextStyle(
                      fontSize: 14,
                      color: Colors.black54,
                      height: 1.4,
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
}

class _TrustIcon extends StatelessWidget {
  final IconData icon;
  final String label;

  const _TrustIcon({
    required this.icon,
    required this.label,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Icon(
          icon,
          color: AppColors.primaryColor,
          size: 24,
        ),
        const SizedBox(height: 6),
        Text(
          label,
          style: const TextStyle(
            fontSize: 12,
            color: Colors.black54,
            fontWeight: FontWeight.w500,
          ),
        ),
      ],
    );
  }
}