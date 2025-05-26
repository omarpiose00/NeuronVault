// 🎛️ SPATIAL AUDIO CONTROLS WIDGET
// lib/widgets/core/spatial_audio_controls.dart
// Premium UI controls for 3D neural soundscape

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'dart:ui' as ui;

import '../../core/providers/providers_main.dart';
import '../../core/design_system.dart';
import '../../core/services/spatial_audio_service.dart';

/// 🔊 Spatial Audio Controls Widget
class SpatialAudioControls extends ConsumerStatefulWidget {
  final bool isCompact;

  const SpatialAudioControls({
    super.key,
    this.isCompact = false,
  });

  @override
  ConsumerState<SpatialAudioControls> createState() => _SpatialAudioControlsState();
}

class _SpatialAudioControlsState extends ConsumerState<SpatialAudioControls>
    with TickerProviderStateMixin {

  late AnimationController _glowController;
  late Animation<double> _glowAnimation;

  @override
  void initState() {
    super.initState();

    _glowController = AnimationController(
      duration: const Duration(seconds: 2),
      vsync: this,
    );

    _glowAnimation = Tween<double>(begin: 0.3, end: 1.0)
        .animate(CurvedAnimation(
      parent: _glowController,
      curve: Curves.easeInOut,
    ));

    _glowController.repeat(reverse: true);
  }

  @override
  void dispose() {
    _glowController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final ds = context.ds;
    final spatialAudioService = ref.watch(spatialAudioServiceProvider);

    if (widget.isCompact) {
      return _buildCompactControls(ds, spatialAudioService);
    } else {
      return _buildFullControls(ds, spatialAudioService);
    }
  }

  /// 🎚️ Build Compact Audio Controls
  Widget _buildCompactControls(DesignSystemData ds, SpatialAudioService audioService) {
    return AnimatedBuilder(
      animation: _glowAnimation,
      builder: (context, child) {
        return Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [
                ds.colors.colorScheme.surfaceContainer.withOpacity(0.9),
                ds.colors.colorScheme.surfaceContainer.withOpacity(0.7),
              ],
            ),
            borderRadius: BorderRadius.circular(20),
            border: Border.all(
              color: audioService.isEnabled
                  ? ds.colors.neuralAccent.withOpacity(0.4)
                  : ds.colors.colorScheme.outline.withOpacity(0.3),
              width: 1,
            ),
            boxShadow: audioService.isEnabled ? [
              BoxShadow(
                color: ds.colors.neuralAccent.withOpacity(0.2 * _glowAnimation.value),
                blurRadius: 8,
                spreadRadius: 1,
              ),
            ] : null,
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(20),
            child: BackdropFilter(
              filter: ui.ImageFilter.blur(sigmaX: 10, sigmaY: 10),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  // Audio toggle button
                  GestureDetector(
                    onTap: () {
                      audioService.setEnabled(!audioService.isEnabled);
                      HapticFeedback.lightImpact();
                    },
                    child: Container(
                      padding: const EdgeInsets.all(6),
                      decoration: BoxDecoration(
                        color: audioService.isEnabled
                            ? ds.colors.neuralAccent.withOpacity(0.3)
                            : ds.colors.colorScheme.outline.withOpacity(0.2),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Icon(
                        audioService.isEnabled
                            ? Icons.volume_up
                            : Icons.volume_off,
                        color: audioService.isEnabled
                            ? ds.colors.neuralAccent
                            : ds.colors.colorScheme.onSurface.withOpacity(0.6),
                        size: 16,
                      ),
                    ),
                  ),

                  const SizedBox(width: 8),

                  // Volume indicator
                  if (audioService.isEnabled) ...[
                    Text(
                      '3D AUDIO',
                      style: ds.typography.caption.copyWith(
                        color: ds.colors.neuralAccent,
                        fontWeight: FontWeight.w700,
                        fontSize: 9,
                      ),
                    ),
                    const SizedBox(width: 6),
                    _buildVolumeIndicator(ds, audioService),
                  ] else ...[
                    Text(
                      'MUTED',
                      style: ds.typography.caption.copyWith(
                        color: ds.colors.colorScheme.onSurface.withOpacity(0.6),
                        fontWeight: FontWeight.w600,
                        fontSize: 9,
                      ),
                    ),
                  ],
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  /// 🎛️ Build Full Audio Controls
  Widget _buildFullControls(DesignSystemData ds, SpatialAudioService audioService) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            ds.colors.colorScheme.surfaceContainer.withOpacity(0.9),
            ds.colors.colorScheme.surfaceContainer.withOpacity(0.7),
          ],
        ),
        borderRadius: BorderRadius.circular(24),
        border: Border.all(
          color: ds.colors.neuralAccent.withOpacity(0.3),
          width: 1.5,
        ),
        boxShadow: [
          BoxShadow(
            color: ds.colors.neuralAccent.withOpacity(0.15),
            blurRadius: 20,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(24),
        child: BackdropFilter(
          filter: ui.ImageFilter.blur(sigmaX: 15, sigmaY: 15),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header
              Row(
                children: [
                  AnimatedBuilder(
                    animation: _glowAnimation,
                    builder: (context, child) {
                      return Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          gradient: RadialGradient(
                            colors: [
                              ds.colors.neuralAccent.withOpacity(0.3 * _glowAnimation.value),
                              ds.colors.neuralAccent.withOpacity(0.1),
                            ],
                          ),
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: Icon(
                          Icons.spatial_audio,
                          color: ds.colors.neuralAccent,
                          size: 20,
                        ),
                      );
                    },
                  ),

                  const SizedBox(width: 12),

                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Neural Soundscape',
                          style: ds.typography.h3.copyWith(
                            color: ds.colors.colorScheme.onSurface,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                        Text(
                          '3D Spatial Audio System',
                          style: ds.typography.caption.copyWith(
                            color: ds.colors.colorScheme.onSurface.withOpacity(0.7),
                          ),
                        ),
                      ],
                    ),
                  ),

                  // Master toggle
                  _buildToggleSwitch(
                    audioService.isEnabled,
                        (value) {
                      audioService.setEnabled(value);
                      HapticFeedback.lightImpact();
                    },
                    ds,
                  ),
                ],
              ),

              const SizedBox(height: 24),

              // Audio status
              if (audioService.isEnabled) ...[
                _buildAudioStatus(ds, audioService),
                const SizedBox(height: 20),
              ],

              // Volume controls
              if (audioService.isEnabled) ...[
                _buildVolumeControls(ds, audioService),
              ] else ...[
                _buildDisabledState(ds),
              ],
            ],
          ),
        ),
      ),
    );
  }

  /// 📊 Build Audio Status
  Widget _buildAudioStatus(DesignSystemData ds, SpatialAudioService audioService) {
    return Row(
      children: [
        Expanded(
          child: _buildStatusCard(
            'Active Sources',
            '${audioService.activeSourceCount}',
            Icons.speaker,
            ds.colors.neuralPrimary,
            ds,
          ),
        ),

        const SizedBox(width: 12),

        Expanded(
          child: _buildStatusCard(
            'CPU Usage',
            '${(audioService.cpuUsage * 100).toStringAsFixed(1)}%',
            Icons.memory,
            audioService.cpuUsage > 0.5
                ? ds.colors.connectionRed
                : ds.colors.connectionGreen,
            ds,
          ),
        ),

        const SizedBox(width: 12),

        Expanded(
          child: _buildStatusCard(
            'Status',
            audioService.isInitialized ? 'Ready' : 'Loading',
            Icons.check_circle,
            audioService.isInitialized
                ? ds.colors.connectionGreen
                : ds.colors.neuralSecondary,
            ds,
          ),
        ),
      ],
    );
  }

  /// 📊 Build Status Card
  Widget _buildStatusCard(String label, String value, IconData icon, Color color, DesignSystemData ds) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: ds.colors.colorScheme.surface.withOpacity(0.6),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: color.withOpacity(0.3),
          width: 1,
        ),
      ),
      child: Column(
        children: [
          Icon(icon, color: color, size: 16),
          const SizedBox(height: 4),
          Text(
            value,
            style: ds.typography.body1.copyWith(
              color: ds.colors.colorScheme.onSurface,
              fontWeight: FontWeight.w700,
              fontSize: 16,
            ),
          ),
          Text(
            label,
            style: ds.typography.caption.copyWith(
              color: ds.colors.colorScheme.onSurface.withOpacity(0.7),
              fontSize: 10,
            ),
          ),
        ],
      ),
    );
  }

  /// 🎚️ Build Volume Controls
  Widget _buildVolumeControls(DesignSystemData ds, SpatialAudioService audioService) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Master Volume
        _buildVolumeSlider(
          'Master Volume',
          audioService.masterVolume,
              (value) => audioService.setMasterVolume(value),
          Icons.volume_up,
          ds.colors.neuralPrimary,
          ds,
        ),

        const SizedBox(height: 16),

        // Effects Volume
        _buildVolumeSlider(
          'Neural Effects',
          audioService.masterVolume * 0.8, // Approximate effects volume
              (value) => audioService.setEffectsVolume(value),
          Icons.auto_awesome,
          ds.colors.neuralSecondary,
          ds,
        ),

        const SizedBox(height: 16),

        // Ambient Volume
        _buildVolumeSlider(
          'Ambient Soundscape',
          audioService.masterVolume * 0.3, // Approximate ambient volume
              (value) => audioService.setAmbientVolume(value),
          Icons.waves,
          ds.colors.neuralAccent,
          ds,
        ),
      ],
    );
  }

  /// 🎚️ Build Volume Slider
  Widget _buildVolumeSlider(
      String label,
      double value,
      Function(double) onChanged,
      IconData icon,
      Color color,
      DesignSystemData ds,
      ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(icon, color: color, size: 16),
            const SizedBox(width: 8),
            Text(
              label,
              style: ds.typography.body2.copyWith(
                color: ds.colors.colorScheme.onSurface,
                fontWeight: FontWeight.w600,
              ),
            ),
            const Spacer(),
            Text(
              '${(value * 100).toInt()}%',
              style: ds.typography.caption.copyWith(
                color: color,
                fontWeight: FontWeight.w700,
              ),
            ),
          ],
        ),

        const SizedBox(height: 8),

        SliderTheme(
          data: SliderTheme.of(context).copyWith(
            activeTrackColor: color,
            inactiveTrackColor: color.withOpacity(0.3),
            thumbColor: color,
            overlayColor: color.withOpacity(0.2),
            thumbShape: const RoundSliderThumbShape(enabledThumbRadius: 8),
            overlayShape: const RoundSliderOverlayShape(overlayRadius: 16),
          ),
          child: Slider(
            value: value,
            onChanged: (newValue) {
              onChanged(newValue);
              HapticFeedback.selectionClick();
            },
            min: 0.0,
            max: 1.0,
            divisions: 20,
          ),
        ),
      ],
    );
  }

  /// 🔇 Build Disabled State
  Widget _buildDisabledState(DesignSystemData ds) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: ds.colors.colorScheme.outline.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: ds.colors.colorScheme.outline.withOpacity(0.3),
          width: 1,
        ),
      ),
      child: Column(
        children: [
          Icon(
            Icons.volume_off,
            color: ds.colors.colorScheme.onSurface.withOpacity(0.5),
            size: 32,
          ),
          const SizedBox(height: 8),
          Text(
            'Spatial Audio Disabled',
            style: ds.typography.body1.copyWith(
              color: ds.colors.colorScheme.onSurface.withOpacity(0.7),
              fontWeight: FontWeight.w600,
              fontSize: 16,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            'Enable to experience 3D neural soundscape',
            style: ds.typography.caption.copyWith(
              color: ds.colors.colorScheme.onSurface.withOpacity(0.5),
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  /// 📊 Build Volume Indicator
  Widget _buildVolumeIndicator(DesignSystemData ds, SpatialAudioService audioService) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: List.generate(3, (index) {
        final threshold = (index + 1) / 3;
        final isActive = audioService.masterVolume >= threshold;

        return Container(
          width: 3,
          height: 8 + (index * 2).toDouble(),
          margin: const EdgeInsets.symmetric(horizontal: 1),
          decoration: BoxDecoration(
            color: isActive
                ? ds.colors.neuralAccent
                : ds.colors.colorScheme.outline.withOpacity(0.3),
            borderRadius: BorderRadius.circular(1),
          ),
        );
      }),
    );
  }

  /// 🔘 Build Toggle Switch
  Widget _buildToggleSwitch(bool value, Function(bool) onChanged, DesignSystemData ds) {
    return GestureDetector(
      onTap: () => onChanged(!value),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        width: 44,
        height: 24,
        decoration: BoxDecoration(
          color: value
              ? ds.colors.neuralAccent
              : ds.colors.colorScheme.outline.withOpacity(0.3),
          borderRadius: BorderRadius.circular(12),
          boxShadow: value ? [
            BoxShadow(
              color: ds.colors.neuralAccent.withOpacity(0.3),
              blurRadius: 8,
              spreadRadius: 1,
            ),
          ] : null,
        ),
        child: AnimatedAlign(
          duration: const Duration(milliseconds: 200),
          alignment: value ? Alignment.centerRight : Alignment.centerLeft,
          child: Container(
            width: 20,
            height: 20,
            margin: const EdgeInsets.all(2),
            decoration: BoxDecoration(
              color: Colors.white,
              shape: BoxShape.circle,
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.2),
                  blurRadius: 4,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}