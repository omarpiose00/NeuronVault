// lib/widgets/neural_app_bar.dart
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../core/design_system.dart';
import '../core/accessibility/accessibility_manager.dart';

/// 🧠 NEURAL APP BAR
/// App bar moderna con animazioni neurali e supporto accessibilità completo
class NeuralAppBar extends StatefulWidget implements PreferredSizeWidget {
  final bool isConnected;
  final VoidCallback onConnectionToggle;
  final Animation<double> pulseAnimation;

  const NeuralAppBar({
    super.key,
    required this.isConnected,
    required this.onConnectionToggle,
    required this.pulseAnimation,
  });

  @override
  State<NeuralAppBar> createState() => _NeuralAppBarState();

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);
}

class _NeuralAppBarState extends State<NeuralAppBar> with TickerProviderStateMixin {
  late AnimationController _logoController;
  late AnimationController _connectionController;
  late Animation<double> _logoRotation;
  late Animation<Color?> _connectionColor;

  @override
  void initState() {
    super.initState();
    _initializeAnimations();
    _setupKeyboardShortcuts();
  }

  void _initializeAnimations() {
    // Logo rotation animation
    _logoController = AnimationController(
      duration: const Duration(seconds: 8),
      vsync: this,
    );
    _logoRotation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _logoController,
      curve: Curves.linear,
    ));
    _logoController.repeat();

    // Connection status color animation
    _connectionController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );
    _updateConnectionAnimation();
  }

  void _updateConnectionAnimation() {
    final ds = DesignSystem.instance.current;
    _connectionColor = ColorTween(
      begin: widget.isConnected ? ds.colors.connectionGreen : ds.colors.connectionRed,
      end: widget.isConnected ? ds.colors.connectionGreen.withOpacity(0.7) : ds.colors.connectionRed.withOpacity(0.7),
    ).animate(CurvedAnimation(
      parent: _connectionController,
      curve: Curves.easeInOut,
    ));

    if (widget.isConnected) {
      _connectionController.repeat(reverse: true);
    } else {
      _connectionController.stop();
      _connectionController.value = 1.0;
    }
  }

  void _setupKeyboardShortcuts() {
    // Keyboard shortcuts will be handled globally
  }

  @override
  void didUpdateWidget(NeuralAppBar oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.isConnected != widget.isConnected) {
      _updateConnectionAnimation();
    }
  }

  @override
  void dispose() {
    _logoController.dispose();
    _connectionController.dispose();
    super.dispose();
  }

  /// 🧠 Build Neural Logo
  dynamic _buildNeuralLogo() {
    final ds = DesignSystem.instance.current;
    return AnimatedBuilder(
      animation: Listenable.merge([widget.pulseAnimation, _logoRotation]),
      builder: (context, child) {
        return Transform.scale(
          scale: widget.pulseAnimation.value,
          child: Transform.rotate(
            angle: _logoRotation.value * 0.1,
            child: Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(12),
                boxShadow: [
                  BoxShadow(
                    color: ds.colors.neuralPrimary.withOpacity(0.3),
                    blurRadius: 12,
                    spreadRadius: 2,
                  ),
                ],
              ),
              clipBehavior: Clip.hardEdge,
              child: Image.asset(
                'assets/images/neuronvault_logo.png',
                fit: BoxFit.contain,
              ),
            ),
          ),
        );
      },
    );
  }



  /// 🔌 Build Connection Status
  Widget _buildConnectionStatus() {
    final ds = DesignSystem.instance.current;

    return GestureDetector(
      onTap: () {
        widget.onConnectionToggle();
        HapticFeedback.lightImpact();
      },
      child: AnimatedBuilder(
        animation: _connectionColor,
        builder: (context, child) {
          return Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(
              color: (_connectionColor.value ?? ds.colors.connectionGreen).withOpacity(0.2),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(
                color: _connectionColor.value ?? ds.colors.connectionGreen,
                width: 1,
              ),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  width: 8,
                  height: 8,
                  decoration: BoxDecoration(
                    color: _connectionColor.value ?? ds.colors.connectionGreen,
                    shape: BoxShape.circle,
                  ),
                ),
                const SizedBox(width: 8),
                Text(
                  widget.isConnected ? 'Connected' : 'Disconnected',
                  style: ds.typography.caption.copyWith(
                    color: _connectionColor.value ?? ds.colors.connectionGreen,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  /// ⚙️ Build Settings Button
  Widget _buildSettingsButton() {
    final ds = DesignSystem.instance.current;

    return GestureDetector(
      onTap: _showSettingsMenu,
      child: Container(
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: ds.colors.colorScheme.surfaceContainer,
          borderRadius: BorderRadius.circular(8),
          border: Border.all(
            color: ds.colors.colorScheme.outline.withOpacity(0.3),
            width: 1,
          ),
        ),
        child: Icon(
          Icons.settings,
          color: ds.colors.colorScheme.onSurface,
          size: 20,
        ),
      ),
    );
  }

  /// 📊 Build System Stats
  Widget _buildSystemStats() {
    final ds = DesignSystem.instance.current;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: ds.colors.colorScheme.surfaceContainer.withOpacity(0.7),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            Icons.memory,
            color: ds.colors.neuralAccent,
            size: 16,
          ),
          const SizedBox(width: 6),
          Text(
            '23.5K',
            style: ds.typography.caption.copyWith(
              color: ds.colors.colorScheme.onSurface,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(width: 8),
          Icon(
            Icons.speed,
            color: ds.colors.neuralSecondary,
            size: 16,
          ),
          const SizedBox(width: 6),
          Text(
            '1.2s',
            style: ds.typography.caption.copyWith(
              color: ds.colors.colorScheme.onSurface,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }

  /// ⚙️ Show Settings Menu
  void _showSettingsMenu() {
    final ds = DesignSystem.instance.current;

    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (context) => Container(
        decoration: BoxDecoration(
          color: ds.colors.colorScheme.surfaceContainer,
          borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Handle
            Container(
              width: 40,
              height: 4,
              margin: const EdgeInsets.symmetric(vertical: 12),
              decoration: BoxDecoration(
                color: ds.colors.colorScheme.outline,
                borderRadius: BorderRadius.circular(2),
              ),
            ),

            // Title
            Padding(
              padding: const EdgeInsets.all(20),
              child: Text(
                'Settings',
                style: ds.typography.h2.copyWith(
                  color: ds.colors.colorScheme.onSurface,
                ),
              ),
            ),

            // Settings Options
            ListTile(
              leading: Icon(Icons.palette, color: ds.colors.neuralPrimary),
              title: Text('Theme Options', style: ds.typography.body1),
              trailing: const Icon(Icons.arrow_forward_ios, size: 16),
              onTap: () {
                Navigator.pop(context);
                AccessibilityManager().announce('Theme options selected');
              },
            ),

            ListTile(
              leading: Icon(Icons.tune, color: ds.colors.neuralSecondary),
              title: Text('AI Configuration', style: ds.typography.body1),
              trailing: const Icon(Icons.arrow_forward_ios, size: 16),
              onTap: () {
                Navigator.pop(context);
                AccessibilityManager().announce('AI configuration selected');
              },
            ),

            ListTile(
              leading: Icon(Icons.accessibility, color: ds.colors.neuralAccent),
              title: Text('Accessibility', style: ds.typography.body1),
              trailing: const Icon(Icons.arrow_forward_ios, size: 16),
              onTap: () {
                Navigator.pop(context);
                AccessibilityManager().announce('Accessibility options selected');
              },
            ),

            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final ds = DesignSystem.instance.current;

    return Container(
      height: kToolbarHeight,
      decoration: BoxDecoration(
        color: ds.colors.colorScheme.surface.withOpacity(0.95),
        border: Border(
          bottom: BorderSide(
            color: ds.colors.colorScheme.outline.withOpacity(0.2),
            width: 1,
          ),
        ),
        boxShadow: [
          BoxShadow(
            color: ds.colors.colorScheme.shadow.withOpacity(0.1),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20),
        child: Row(
          children: [
            // Logo Section
            _buildNeuralLogo(),

            const SizedBox(width: 16),

            // Title
            Text(
              'NeuronVault',
              style: ds.typography.h2.copyWith(
                color: ds.colors.colorScheme.onSurface,
                fontWeight: FontWeight.w700,
              ),
            ),

            const Spacer(),

            // System Stats
            _buildSystemStats(),

            const SizedBox(width: 16),

            // Connection Status
            _buildConnectionStatus(),

            const SizedBox(width: 16),

            // Settings Button
            _buildSettingsButton(),
          ],
        ),
      ),
    );
  }
}