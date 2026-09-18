import 'package:flutter/material.dart';
import 'package:phosphoricons_flutter/phosphoricons_flutter.dart';
import '../screens/ai/compact_ai_chat_sheet.dart';
import '../theme/app_theme.dart';

/// GlobalFloatingAiButton:
/// Persistent floating AI assistant button designed for Proton Dark Theme.
/// Features a vibrant violet gradient, glowing halo, online status badge,
/// and instant launch of the CompactAiChatSheet dialog.
class GlobalFloatingAiButton extends StatefulWidget {
  final double bottomOffset;
  final double rightOffset;

  const GlobalFloatingAiButton({
    super.key,
    this.bottomOffset = 84.0,
    this.rightOffset = 16.0,
  });

  @override
  State<GlobalFloatingAiButton> createState() => _GlobalFloatingAiButtonState();
}

class _GlobalFloatingAiButtonState extends State<GlobalFloatingAiButton>
    with SingleTickerProviderStateMixin {
  late final AnimationController _pulseController;
  late final Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();
    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 2000),
    )..repeat(reverse: true);

    _scaleAnimation = Tween<double>(begin: 1.0, end: 1.06).animate(
      CurvedAnimation(
        parent: _pulseController,
        curve: Curves.easeInOut,
      ),
    );
  }

  @override
  void dispose() {
    _pulseController.dispose();
    super.dispose();
  }

  void _openAiAssistant(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => const CompactAiChatSheet(),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Positioned(
      right: widget.rightOffset,
      bottom: widget.bottomOffset,
      child: AnimatedBuilder(
        animation: _scaleAnimation,
        builder: (context, child) {
          return Transform.scale(
            scale: _scaleAnimation.value,
            child: child,
          );
        },
        child: Material(
          color: Colors.transparent,
          child: InkWell(
            onTap: () => _openAiAssistant(context),
            borderRadius: BorderRadius.circular(AppRadius.pill),
            splashColor: Colors.white.withValues(alpha: 0.25),
            highlightColor: Colors.white.withValues(alpha: 0.1),
            child: Container(
              width: 52,
              height: 52,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: const LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [
                    AppColors.primaryGradientStart,
                    AppColors.primaryGradientEnd,
                  ],
                ),
                border: Border.all(
                  color: Colors.white.withValues(alpha: 0.35),
                  width: 1.5,
                ),
                boxShadow: [
                  BoxShadow(
                    color: AppColors.primary.withValues(alpha: 0.40),
                    blurRadius: 18,
                    offset: const Offset(0, 6),
                    spreadRadius: 1,
                  ),
                ],
              ),
              child: Stack(
                clipBehavior: Clip.none,
                alignment: Alignment.center,
                children: [
                  const PhosphorIcon(
                    PhosphorIconsFill.sparkle,
                    size: 24,
                    color: Colors.white,
                  ),
                  // Online green pulse badge
                  Positioned(
                    top: 2,
                    right: 2,
                    child: Container(
                      width: 13,
                      height: 13,
                      decoration: BoxDecoration(
                        color: AppColors.success,
                        shape: BoxShape.circle,
                        border: Border.all(
                          color: Colors.white,
                          width: 2.2,
                        ),
                      ),
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
}
