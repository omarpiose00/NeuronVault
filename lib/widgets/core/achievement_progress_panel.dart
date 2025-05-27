// 🏆 NEURONVAULT ACHIEVEMENT PROGRESS PANEL
// lib/widgets/core/achievement_progress_panel.dart
// Neural luxury achievement browser with glassmorphism and theme-reactive design

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'dart:ui' as ui;
import 'dart:math' as math;
import '../../core/state/state_models.dart';
import '../../core/providers/providers_main.dart';
import '../../core/theme/neural_theme_system.dart';

/// 🏆 Achievement Progress Panel - Main achievement browser
class AchievementProgressPanel extends ConsumerStatefulWidget {
  const AchievementProgressPanel({Key? key}) : super(key: key);

  @override
  ConsumerState<AchievementProgressPanel> createState() =>
      _AchievementProgressPanelState();
}

class _AchievementProgressPanelState
    extends ConsumerState<AchievementProgressPanel>
    with TickerProviderStateMixin {

  late TabController _tabController;
  AchievementCategory _selectedCategory = AchievementCategory.particles;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(
      length: AchievementCategory.values.length,
      vsync: this,
    );

    _tabController.addListener(() {
      if (_tabController.indexIsChanging) {
        setState(() {
          _selectedCategory = AchievementCategory.values[_tabController.index];
        });
      }
    });
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = NeuralThemeSystem().currentTheme;
    final stats = ref.watch(achievementStatsProvider);

    return Container(
      height: 600,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(20),
        color: theme.colors.surface.withOpacity(0.1),
        border: Border.all(
          color: theme.colors.primary.withOpacity(0.2),
          width: 1,
        ),
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(20),
        child: BackdropFilter(
          filter: ui.ImageFilter.blur(sigmaX: 10, sigmaY: 10),
          child: Column(
            children: [
              // Header with stats
              _buildHeader(theme, stats),

              // Category tabs
              _buildCategoryTabs(theme),

              // Achievement grid
              Expanded(
                child: _buildAchievementGrid(theme),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHeader(NeuralThemeData theme, AchievementStats stats) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        border: Border(
          bottom: BorderSide(
            color: theme.colors.primary.withOpacity(0.2),
            width: 1,
          ),
        ),
      ),
      child: Column(
        children: [
          // Title
          Row(
            children: [
              Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: theme.colors.primary.withOpacity(0.2),
                  border: Border.all(
                    color: theme.colors.primary.withOpacity(0.4),
                    width: 1,
                  ),
                ),
                child: Icon(
                  Icons.emoji_events,
                  color: theme.colors.primary,
                  size: 20,
                ),
              ),
              const SizedBox(width: 12),
              Text(
                'Neural Achievements',
                style: TextStyle(
                  color: theme.colors.onSurface,
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const Spacer(),
              _buildCompletionBadge(theme, stats),
            ],
          ),

          const SizedBox(height: 16),

          // Stats row
          Row(
            children: [
              Expanded(child: _buildStatCard(theme, 'Total', '${stats.unlockedAchievements}/${stats.totalAchievements}', Colors.blue)),
              const SizedBox(width: 12),
              Expanded(child: _buildStatCard(theme, 'Points', '${ref.watch(totalPointsProvider)}', Colors.amber)),
              const SizedBox(width: 12),
              Expanded(child: _buildStatCard(theme, 'Legendary', '${stats.legendaryUnlocked}', Colors.orange)),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildCompletionBadge(NeuralThemeData theme, AchievementStats stats) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: theme.colors.primary.withOpacity(0.2),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: theme.colors.primary.withOpacity(0.4),
          width: 1,
        ),
      ),
      child: Text(
        '${stats.completionPercentage.toStringAsFixed(1)}% Complete',
        style: TextStyle(
          color: theme.colors.primary,
          fontSize: 12,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }

  Widget _buildStatCard(NeuralThemeData theme, String label, String value, Color color) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: color.withOpacity(0.2),
          width: 1,
        ),
      ),
      child: Column(
        children: [
          Text(
            value,
            style: TextStyle(
              color: color,
              fontSize: 16,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            label,
            style: TextStyle(
              color: theme.colors.onSurface.withOpacity(0.7),
              fontSize: 11,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCategoryTabs(NeuralThemeData theme) {
    return Container(
      height: 60,
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: TabBar(
        controller: _tabController,
        isScrollable: true,
        tabAlignment: TabAlignment.start,
        indicator: BoxDecoration(
          color: theme.colors.primary.withOpacity(0.2),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: theme.colors.primary.withOpacity(0.4),
            width: 1,
          ),
        ),
        dividerColor: Colors.transparent,
        labelColor: theme.colors.primary,
        unselectedLabelColor: theme.colors.onSurface.withOpacity(0.6),
        labelStyle: const TextStyle(
          fontSize: 12,
          fontWeight: FontWeight.bold,
        ),
        tabs: AchievementCategory.values.map((category) => Tab(
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 12),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(category.icon, size: 16),
                const SizedBox(width: 6),
                Text(category.displayName),
              ],
            ),
          ),
        )).toList(),
      ),
    );
  }

  Widget _buildAchievementGrid(NeuralThemeData theme) {
    final achievements = ref.watch(achievementsByCategoryProvider(_selectedCategory));

    return TabBarView(
      controller: _tabController,
      children: AchievementCategory.values.map((category) {
        final categoryAchievements = ref.watch(achievementsByCategoryProvider(category));

        return Padding(
          padding: const EdgeInsets.all(16),
          child: GridView.builder(
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2,
              childAspectRatio: 1.2,
              crossAxisSpacing: 12,
              mainAxisSpacing: 12,
            ),
            itemCount: categoryAchievements.length,
            itemBuilder: (context, index) {
              final achievement = categoryAchievements[index];
              return _buildAchievementCard(theme, achievement);
            },
          ),
        );
      }).toList(),
    );
  }

  Widget _buildAchievementCard(NeuralThemeData theme, Achievement achievement) {
    final progress = ref.watch(achievementProgressProvider(achievement.id));
    final isUnlocked = achievement.isUnlocked;

    return AnimatedContainer(
      duration: const Duration(milliseconds: 300),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16),
        color: isUnlocked
            ? achievement.rarity.color.withOpacity(0.1)
            : theme.colors.surface.withOpacity(0.05),
        border: Border.all(
          color: isUnlocked
              ? achievement.rarity.color.withOpacity(0.3)
              : theme.colors.onSurface.withOpacity(0.1),
          width: 1,
        ),
        boxShadow: isUnlocked ? [
          BoxShadow(
            color: achievement.rarity.color.withOpacity(0.2),
            blurRadius: 8,
            spreadRadius: 1,
          ),
        ] : null,
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(16),
        child: BackdropFilter(
          filter: ui.ImageFilter.blur(sigmaX: 5, sigmaY: 5),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Icon and rarity
                Row(
                  children: [
                    Container(
                      width: 36,
                      height: 36,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: isUnlocked
                            ? achievement.rarity.color.withOpacity(0.2)
                            : theme.colors.onSurface.withOpacity(0.1),
                      ),
                      child: Icon(
                        achievement.icon,
                        size: 18,
                        color: isUnlocked
                            ? achievement.rarity.color
                            : theme.colors.onSurface.withOpacity(0.5),
                      ),
                    ),
                    const Spacer(),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 3),
                      decoration: BoxDecoration(
                        color: achievement.rarity.color.withOpacity(0.2),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text(
                        achievement.rarity.displayName.substring(0, 1).toUpperCase(),
                        style: TextStyle(
                          color: achievement.rarity.color,
                          fontSize: 10,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 12),

                // Title
                Text(
                  achievement.title,
                  style: TextStyle(
                    color: isUnlocked
                        ? theme.colors.onSurface
                        : theme.colors.onSurface.withOpacity(0.7),
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),

                const SizedBox(height: 6),

                // Description
                Text(
                  achievement.description,
                  style: TextStyle(
                    color: isUnlocked
                        ? theme.colors.onSurface.withOpacity(0.8)
                        : theme.colors.onSurface.withOpacity(0.5),
                    fontSize: 11,
                    height: 1.2,
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),

                const Spacer(),

                // Progress bar
                if (!isUnlocked && progress != null)
                  _buildProgressBar(theme, achievement, progress),

                // Unlock date
                if (isUnlocked && achievement.unlockedAt != null)
                  Text(
                    'Unlocked ${_formatDate(achievement.unlockedAt!)}',
                    style: TextStyle(
                      color: achievement.rarity.color.withOpacity(0.8),
                      fontSize: 9,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildProgressBar(NeuralThemeData theme, Achievement achievement, AchievementProgress progress) {
    final percentage = achievement.progressPercentage / 100;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'Progress',
              style: TextStyle(
                color: theme.colors.onSurface.withOpacity(0.6),
                fontSize: 9,
              ),
            ),
            Text(
              '${achievement.currentProgress}/${achievement.targetProgress}',
              style: TextStyle(
                color: theme.colors.onSurface.withOpacity(0.6),
                fontSize: 9,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
        const SizedBox(height: 4),
        Container(
          height: 4,
          decoration: BoxDecoration(
            color: theme.colors.onSurface.withOpacity(0.1),
            borderRadius: BorderRadius.circular(2),
          ),
          child: FractionallySizedBox(
            alignment: Alignment.centerLeft,
            widthFactor: percentage,
            child: Container(
              decoration: BoxDecoration(
                color: achievement.rarity.color,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
          ),
        ),
      ],
    );
  }

  String _formatDate(DateTime date) {
    final now = DateTime.now();
    final difference = now.difference(date);

    if (difference.inDays > 0) {
      return '${difference.inDays}d ago';
    } else if (difference.inHours > 0) {
      return '${difference.inHours}h ago';
    } else if (difference.inMinutes > 0) {
      return '${difference.inMinutes}m ago';
    } else {
      return 'Just now';
    }
  }
}

/// 🎯 Achievement Quick Stats Widget - Compact stats display
class AchievementQuickStats extends ConsumerWidget {
  const AchievementQuickStats({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = NeuralThemeSystem().currentTheme;
    final stats = ref.watch(achievementStatsProvider);
    final recentAchievements = ref.watch(recentAchievementsProvider);

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: theme.colors.surface.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: theme.colors.primary.withOpacity(0.2),
          width: 1,
        ),
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(12),
        child: BackdropFilter(
          filter: ui.ImageFilter.blur(sigmaX: 5, sigmaY: 5),
          child: Row(
            children: [
              Icon(
                Icons.emoji_events,
                color: theme.colors.primary,
                size: 20,
              ),
              const SizedBox(width: 8),
              Text(
                '${stats.unlockedAchievements}/${stats.totalAchievements}',
                style: TextStyle(
                  color: theme.colors.onSurface,
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(width: 8),
              if (recentAchievements.isNotEmpty) ...[
                Container(
                  width: 4,
                  height: 4,
                  decoration: BoxDecoration(
                    color: theme.colors.primary,
                    shape: BoxShape.circle,
                  ),
                ),
                const SizedBox(width: 8),
                Text(
                  'Latest: ${recentAchievements.first.title}',
                  style: TextStyle(
                    color: theme.colors.onSurface.withOpacity(0.7),
                    fontSize: 12,
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}