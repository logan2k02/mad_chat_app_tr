import 'package:flutter/material.dart';

/// Custom logo widget for the Quick Chat app
class AppLogo extends StatelessWidget {
  final double size;
  final Color? backgroundColor;
  final Color? iconColor;

  const AppLogo({
    super.key,
    this.size = 50,
    this.backgroundColor,
    this.iconColor,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(size / 4),
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            backgroundColor ?? const Color(0xFF2AABEE),
            backgroundColor?.withOpacity(0.8) ?? const Color(0xFF1E8BC3),
          ],
        ),
        boxShadow: [
          BoxShadow(
            color: (backgroundColor ?? const Color(0xFF2AABEE)).withOpacity(
              0.3,
            ),
            blurRadius: size / 8,
            spreadRadius: 2,
            offset: Offset(0, size / 12),
          ),
        ],
      ),
      child: Stack(
        children: [
          // Main chat bubble
          Positioned(
            left: size * 0.15,
            top: size * 0.25,
            child: Container(
              width: size * 0.45,
              height: size * 0.35,
              decoration: BoxDecoration(
                color: iconColor ?? Colors.white,
                borderRadius: BorderRadius.circular(size * 0.1),
              ),
            ),
          ),
          // Second chat bubble (smaller, offset)
          Positioned(
            right: size * 0.15,
            top: size * 0.4,
            child: Container(
              width: size * 0.35,
              height: size * 0.25,
              decoration: BoxDecoration(
                color: (iconColor ?? Colors.white).withOpacity(0.8),
                borderRadius: BorderRadius.circular(size * 0.08),
              ),
            ),
          ),
          // Dots inside first bubble
          Positioned(
            left: size * 0.22,
            top: size * 0.35,
            child: Row(
              children: [
                _buildDot(
                  size * 0.04,
                  (backgroundColor ?? const Color(0xFF2AABEE)),
                ),
                SizedBox(width: size * 0.03),
                _buildDot(
                  size * 0.04,
                  (backgroundColor ?? const Color(0xFF2AABEE)),
                ),
                SizedBox(width: size * 0.03),
                _buildDot(
                  size * 0.04,
                  (backgroundColor ?? const Color(0xFF2AABEE)),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDot(double size, Color color) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(color: color, shape: BoxShape.circle),
    );
  }
}

/// Alternative simpler logo with modern messaging icon
class AppLogoSimple extends StatelessWidget {
  final double size;
  final Color? backgroundColor;
  final Color? iconColor;

  const AppLogoSimple({
    super.key,
    this.size = 50,
    this.backgroundColor,
    this.iconColor,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(size / 4),
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            backgroundColor ?? const Color(0xFF2AABEE),
            backgroundColor?.withOpacity(0.7) ?? const Color(0xFF1E8BC3),
          ],
        ),
        boxShadow: [
          BoxShadow(
            color: (backgroundColor ?? const Color(0xFF2AABEE)).withOpacity(
              0.3,
            ),
            blurRadius: size / 8,
            spreadRadius: 1,
            offset: Offset(0, size / 12),
          ),
        ],
      ),
      child: Icon(
        Icons.forum_rounded, // More modern chat icon
        color: iconColor ?? Colors.white,
        size: size * 0.6,
      ),
    );
  }
}

/// Premium logo with lightning bolt for "instant" chat
class AppLogoPremium extends StatelessWidget {
  final double size;
  final Color? backgroundColor;
  final Color? iconColor;

  const AppLogoPremium({
    super.key,
    this.size = 50,
    this.backgroundColor,
    this.iconColor,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(size / 4),
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            backgroundColor ?? const Color(0xFF2AABEE),
            backgroundColor?.withOpacity(0.8) ?? const Color(0xFF1E8BC3),
            const Color(0xFF0D7377),
          ],
        ),
        boxShadow: [
          BoxShadow(
            color: (backgroundColor ?? const Color(0xFF2AABEE)).withOpacity(
              0.4,
            ),
            blurRadius: size / 6,
            spreadRadius: 2,
            offset: Offset(0, size / 10),
          ),
        ],
      ),
      child: Stack(
        alignment: Alignment.center,
        children: [
          // Chat bubble background
          Icon(
            Icons.chat_bubble_rounded,
            color: (iconColor ?? Colors.white).withOpacity(0.9),
            size: size * 0.5,
          ),
          // Lightning bolt overlay
          Positioned(
            right: size * 0.15,
            top: size * 0.15,
            child: Icon(
              Icons.flash_on,
              color: const Color(0xFFFFD700), // Gold color for premium feel
              size: size * 0.25,
            ),
          ),
        ],
      ),
    );
  }
}
