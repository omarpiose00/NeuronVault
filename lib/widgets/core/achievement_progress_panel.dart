// 🏆 NEURONVAULT ACHIEVEMENT PROGRESS PANEL - PHASE 3.3 LUXURY ENHANCED
// lib/widgets/core/achievement_progress_panel.dart
// Revolutionary hover preview system + Spectacular UI luxury + Audio integration

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'dart:ui' as ui;
import '../../core/state/state_models.dart';
import '../../core/providers/providers_main.dart';
import '../../core/theme/neural_theme_system.dart';

/// 🏆 Achievement Progress Panel - PHASE 3.3 LUXURY ENHANCED
/// Revolutionary hover preview system + Spectacular animations + Audio integration
class AchievementProgressPanel extends ConsumerStatefulWidget {
  const AchievementProgressPanel({super.key});

  @override
  ConsumerState<AchievementProgressPanel> createState() =>
      _AchievementProgressPanelState();
}

class _AchievementProgressPanelState
    extends ConsumerState<AchievementProgressPanel>
    with TickerProviderStateMixin {

  late TabController _tabController;
  AchievementCategory _selectedCategory = AchievementCategory.particles;

  // 🎨 PHASE 3.3: HOVER PREVIEW SYSTEM
  String? _hoveredAchievementId;
  final LayerLink _layerLink = LayerLink();
  OverlayEntry? _hoverOverlay;

  // 💫 PHASE 3.3: ENHANCED ANIMATIONS
  late AnimationController _hoverController;
  late AnimationController _glowController;
  late AnimationController _pulseController;

  late Animation<double> _hoverAnimation;
  late Animation<double> _glowAnimation;
  late Animation<double> _pulseAnimation;

  // 🔍 PHASE 3.3: SEARCH & FILTER
  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = '';
  AchievementRarity? _filterRarity;
  bool _showUnlockedOnly = false;

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
        _hideHoverPreview(); // Hide preview when switching tabs
      }
    });

    _initializeAnimations();
    _setupSearchListener();
  }

  void _initializeAnimations() {
    // 🎨 HOVER ANIMATION
    _hoverController = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );
    _hoverAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _hoverController,
      curve: Curves.easeOutCubic,
    ));

    // ✨ GLOW ANIMATION
    _glowController = AnimationController(
      duration: const Duration(milliseconds: 2000),
      vsync: this,
    );
    _glowAnimation = Tween<double>(
      begin: 0.3,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _glowController,
      curve: Curves.easeInOut,
    ));
    _glowController.repeat(reverse: true);

    // 💫 PULSE ANIMATION
    _pulseController = AnimationController(
      duration: const Duration(milliseconds: 1500),
      vsync: this,
    );
    _pulseAnimation = Tween<double>(
      begin: 0.8,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _pulseController,
      curve: Curves.easeInOut,
    ));
  }

  void _setupSearchListener() {
    _searchController.addListener(() {
      setState(() {
        _searchQuery = _searchController.text.toLowerCase();
      });
    });
  }

  @override
  void dispose() {
    _tabController.dispose();
    _hoverController.dispose();
    _glowController.dispose();
    _pulseController.dispose();
    _searchController.dispose();
    _hideHoverPreview();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = NeuralThemeSystem().currentTheme;
    final stats = ref.watch(achievementStatsProvider);

    return CompositedTransformTarget(
      link: _layerLink,
      child: Container(
        height: 700, // Increased height for search bar
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(20),
          color: theme.colors.surface.withOpacity(0.1),
          border: Border.all(
            color: theme.colors.primary.withOpacity(0.2),
            width: 1,
          ),
          boxShadow: [
            BoxShadow(
              color: theme.colors.primary.withOpacity(0.1),
              blurRadius: 20,
              spreadRadius: 2,
            ),
          ],
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(20),
          child: BackdropFilter(
            filter: ui.ImageFilter.blur(sigmaX: 10, sigmaY: 10),
            child: Column(
              children: [
                // 🎯 ENHANCED HEADER
                _buildEnhancedHeader(theme, stats),

                // 🔍 SEARCH & FILTER BAR
                _buildSearchAndFilterBar(theme),

                // 📊 CATEGORY TABS
                _buildEnhancedCategoryTabs(theme),

                // 🏆 ACHIEVEMENT GRID
                Expanded(
                  child: _buildEnhancedAchievementGrid(theme),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  // 🎯 BUILD ENHANCED HEADER
  Widget _buildEnhancedHeader(NeuralThemeData theme, AchievementStats stats) {
    return AnimatedBuilder(
      animation: _glowAnimation,
      builder: (context, child) {
        return Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            border: Border(
              bottom: BorderSide(
                color: theme.colors.primary.withOpacity(0.2),
                width: 1,
              ),
            ),
            boxShadow: [
              BoxShadow(
                color: theme.colors.primary.withOpacity(_glowAnimation.value * 0.1),
                blurRadius: 15,
                spreadRadius: 1,
              ),
            ],
          ),
          child: Column(
            children: [
              // 🏆 TITLE ROW
              Row(
                children: [
                  // 💫 ANIMATED TROPHY ICON
                  Container(
                    width: 50,
                    height: 50,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      gradient: RadialGradient(
                        colors: [
                          theme.colors.primary.withOpacity(0.3),
                          theme.colors.primary.withOpacity(0.1),
                        ],
                      ),
                      border: Border.all(
                        color: theme.colors.primary.withOpacity(0.4),
                        width: 1,
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: theme.colors.primary.withOpacity(_glowAnimation.value * 0.4),
                          blurRadius: 15,
                          spreadRadius: 2,
                        ),
                      ],
                    ),
                    child: Icon(
                      Icons.emoji_events,
                      color: theme.colors.primary,
                      size: 24,
                    ),
                  ),

                  const SizedBox(width: 16),

                  // 📊 TITLE WITH LIVE STATS
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Neural Achievements',
                          style: TextStyle(
                            color: theme.colors.onSurface,
                            fontSize: 22,
                            fontWeight: FontWeight.bold,
                            letterSpacing: 0.5,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          '${stats.unlockedAchievements} of ${stats.totalAchievements} unlocked • ${stats.completionPercentage.toStringAsFixed(1)}% complete',
                          style: TextStyle(
                            color: theme.colors.onSurface.withOpacity(0.7),
                            fontSize: 12,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ],
                    ),
                  ),

                  // 🏆 ENHANCED COMPLETION BADGE
                  _buildEnhancedCompletionBadge(theme, stats),
                ],
              ),

              const SizedBox(height: 20),

              // 📊 ENHANCED STATS ROW
              _buildEnhancedStatsRow(theme, stats),
            ],
          ),
        );
      },
    );
  }

  // 🏆 BUILD ENHANCED COMPLETION BADGE
  Widget _buildEnhancedCompletionBadge(NeuralThemeData theme, AchievementStats stats) {
    final completionLevel = _getCompletionLevel(stats.completionPercentage);

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            completionLevel.color.withOpacity(0.3),
            completionLevel.color.withOpacity(0.1),
          ],
        ),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: completionLevel.color.withOpacity(0.5),
          width: 1,
        ),
        boxShadow: [
          BoxShadow(
            color: completionLevel.color.withOpacity(0.3),
            blurRadius: 8,
            spreadRadius: 1,
          ),
        ],
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            completionLevel.icon,
            color: completionLevel.color,
            size: 16,
          ),
          const SizedBox(width: 6),
          Text(
            '${stats.completionPercentage.toStringAsFixed(1)}%',
            style: TextStyle(
              color: completionLevel.color,
              fontSize: 14,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }

  // 📊 BUILD ENHANCED STATS ROW
  Widget _buildEnhancedStatsRow(NeuralThemeData theme, AchievementStats stats) {
    return Row(
      children: [
        Expanded(child: _buildEnhancedStatCard(theme, 'Total', '${stats.unlockedAchievements}/${stats.totalAchievements}', Icons.category, theme.colors.primary)),
        const SizedBox(width: 12),
        Expanded(child: _buildEnhancedStatCard(theme, 'Points', '${ref.watch(totalPointsProvider)}', Icons.stars, Colors.amber)),
        const SizedBox(width: 12),
        Expanded(child: _buildEnhancedStatCard(theme, 'Rare+', '${stats.rareUnlocked + stats.epicUnlocked + stats.legendaryUnlocked}', Icons.diamond, Colors.purple)),
        const SizedBox(width: 12),
        Expanded(child: _buildEnhancedStatCard(theme, 'Legendary', '${stats.legendaryUnlocked}', Icons.auto_awesome, Colors.orange)),
      ],
    );
  }

  // 📊 BUILD ENHANCED STAT CARD
  Widget _buildEnhancedStatCard(NeuralThemeData theme, String label, String value, IconData icon, Color color) {
    return AnimatedBuilder(
      animation: _pulseAnimation,
      builder: (context, child) {
        return Container(
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                color.withOpacity(0.15),
                color.withOpacity(0.05),
              ],
            ),
            borderRadius: BorderRadius.circular(14),
            border: Border.all(
              color: color.withOpacity(0.3),
              width: 1,
            ),
            boxShadow: [
              BoxShadow(
                color: color.withOpacity(0.2),
                blurRadius: 8,
                spreadRadius: 1,
              ),
            ],
          ),
          child: Column(
            children: [
              // 🔢 VALUE WITH ICON
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    icon,
                    color: color,
                    size: 16,
                  ),
                  const SizedBox(width: 6),
                  Text(
                    value,
                    style: TextStyle(
                      color: color,
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 6),
              // 📝 LABEL
              Text(
                label,
                style: TextStyle(
                  color: theme.colors.onSurface.withOpacity(0.7),
                  fontSize: 11,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  // 🔍 BUILD SEARCH AND FILTER BAR
  Widget _buildSearchAndFilterBar(NeuralThemeData theme) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
      decoration: BoxDecoration(
        border: Border(
          bottom: BorderSide(
            color: theme.colors.primary.withOpacity(0.1),
            width: 1,
          ),
        ),
      ),
      child: Row(
        children: [
          // 🔍 SEARCH BAR
          Expanded(
            flex: 2,
            child: Container(
              height: 36,
              decoration: BoxDecoration(
                color: theme.colors.surface.withOpacity(0.1),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: theme.colors.primary.withOpacity(0.2),
                  width: 1,
                ),
              ),
              child: TextField(
                controller: _searchController,
                style: TextStyle(
                  color: theme.colors.onSurface,
                  fontSize: 14,
                ),
                decoration: InputDecoration(
                  hintText: 'Search achievements...',
                  hintStyle: TextStyle(
                    color: theme.colors.onSurface.withOpacity(0.5),
                    fontSize: 14,
                  ),
                  prefixIcon: Icon(
                    Icons.search,
                    color: theme.colors.primary.withOpacity(0.7),
                    size: 18,
                  ),
                  border: InputBorder.none,
                  contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                ),
              ),
            ),
          ),

          const SizedBox(width: 12),

          // 🎯 RARITY FILTER
          _buildRarityFilter(theme),

          const SizedBox(width: 12),

          // ✅ UNLOCKED FILTER
          _buildUnlockedFilter(theme),
        ],
      ),
    );
  }

  // 🎯 BUILD RARITY FILTER
  Widget _buildRarityFilter(NeuralThemeData theme) {
    return PopupMenuButton<AchievementRarity?>(
      initialValue: _filterRarity,
      onSelected: (rarity) {
        setState(() {
          _filterRarity = rarity;
        });
      },
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        decoration: BoxDecoration(
          color: _filterRarity != null
              ? _filterRarity!.color.withOpacity(0.2)
              : theme.colors.surface.withOpacity(0.1),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: _filterRarity?.color.withOpacity(0.5) ?? theme.colors.primary.withOpacity(0.2),
            width: 1,
          ),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              Icons.filter_list,
              color: _filterRarity?.color ?? theme.colors.primary.withOpacity(0.7),
              size: 16,
            ),
            const SizedBox(width: 4),
            Text(
              _filterRarity?.displayName ?? 'All',
              style: TextStyle(
                color: _filterRarity?.color ?? theme.colors.onSurface,
                fontSize: 12,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(width: 4),
            Icon(
              Icons.arrow_drop_down,
              color: _filterRarity?.color ?? theme.colors.primary.withOpacity(0.7),
              size: 16,
            ),
          ],
        ),
      ),
      itemBuilder: (context) => [
        const PopupMenuItem<AchievementRarity?>(
          value: null,
          child: Text('All Rarities'),
        ),
        ...AchievementRarity.values.map((rarity) => PopupMenuItem<AchievementRarity?>(
          value: rarity,
          child: Row(
            children: [
              Container(
                width: 12,
                height: 12,
                decoration: BoxDecoration(
                  color: rarity.color,
                  shape: BoxShape.circle,
                ),
              ),
              const SizedBox(width: 8),
              Text(rarity.displayName),
            ],
          ),
        )),
      ],
    );
  }

  // ✅ BUILD UNLOCKED FILTER
  Widget _buildUnlockedFilter(NeuralThemeData theme) {
    return GestureDetector(
      onTap: () {
        setState(() {
          _showUnlockedOnly = !_showUnlockedOnly;
        });
        HapticFeedback.lightImpact();
      },
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        decoration: BoxDecoration(
          color: _showUnlockedOnly
              ? Colors.green.withOpacity(0.2)
              : theme.colors.surface.withOpacity(0.1),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: _showUnlockedOnly
                ? Colors.green.withOpacity(0.5)
                : theme.colors.primary.withOpacity(0.2),
            width: 1,
          ),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              _showUnlockedOnly ? Icons.check_circle : Icons.check_circle_outline,
              color: _showUnlockedOnly ? Colors.green : theme.colors.primary.withOpacity(0.7),
              size: 16,
            ),
            const SizedBox(width: 4),
            Text(
              'Unlocked',
              style: TextStyle(
                color: _showUnlockedOnly ? Colors.green : theme.colors.onSurface,
                fontSize: 12,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
      ),
    );
  }

  // 📊 BUILD ENHANCED CATEGORY TABS
  Widget _buildEnhancedCategoryTabs(NeuralThemeData theme) {
    return Container(
      height: 60,
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: TabBar(
        controller: _tabController,
        isScrollable: true,
        tabAlignment: TabAlignment.start,
        indicator: BoxDecoration(
          gradient: LinearGradient(
            colors: [
              theme.colors.primary.withOpacity(0.3),
              theme.colors.primary.withOpacity(0.1),
            ],
          ),
          borderRadius: BorderRadius.circular(14),
          border: Border.all(
            color: theme.colors.primary.withOpacity(0.5),
            width: 1,
          ),
          boxShadow: [
            BoxShadow(
              color: theme.colors.primary.withOpacity(0.3),
              blurRadius: 8,
              spreadRadius: 1,
            ),
          ],
        ),
        dividerColor: Colors.transparent,
        labelColor: theme.colors.primary,
        unselectedLabelColor: theme.colors.onSurface.withOpacity(0.6),
        labelStyle: const TextStyle(
          fontSize: 12,
          fontWeight: FontWeight.bold,
        ),
        tabs: AchievementCategory.values.map((category) {
          final categoryStats = ref.watch(categoryStatsProvider(category));
          final totalUnlocked = categoryStats.values.fold(0, (sum, count) => sum + count);

          return Tab(
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 14),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(category.icon, size: 16),
                  const SizedBox(width: 6),
                  Text(category.displayName),
                  if (totalUnlocked > 0) ...[
                    const SizedBox(width: 4),
                    Container(
                      padding: const EdgeInsets.all(2),
                      decoration: BoxDecoration(
                        color: theme.colors.primary.withOpacity(0.2),
                        shape: BoxShape.circle,
                      ),
                      child: Text(
                        '$totalUnlocked',
                        style: TextStyle(
                          color: theme.colors.primary,
                          fontSize: 8,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ],
                ],
              ),
            ),
          );
        }).toList(),
      ),
    );
  }

  // 🏆 BUILD ENHANCED ACHIEVEMENT GRID
  Widget _buildEnhancedAchievementGrid(NeuralThemeData theme) {
    return TabBarView(
      controller: _tabController,
      children: AchievementCategory.values.map((category) {
        final achievements = ref.watch(achievementsByCategoryProvider(category));
        final filteredAchievements = _filterAchievements(achievements);

        return Padding(
          padding: const EdgeInsets.all(16),
          child: filteredAchievements.isEmpty
              ? _buildEmptyState(theme)
              : GridView.builder(
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2,
              childAspectRatio: 1.1,
              crossAxisSpacing: 12,
              mainAxisSpacing: 12,
            ),
            itemCount: filteredAchievements.length,
            itemBuilder: (context, index) {
              final achievement = filteredAchievements[index];
              return _buildEnhancedAchievementCard(theme, achievement);
            },
          ),
        );
      }).toList(),
    );
  }

  // 🔍 FILTER ACHIEVEMENTS
  List<Achievement> _filterAchievements(List<Achievement> achievements) {
    var filtered = achievements;

    // Search filter
    if (_searchQuery.isNotEmpty) {
      filtered = filtered.where((a) =>
      a.title.toLowerCase().contains(_searchQuery) ||
          a.description.toLowerCase().contains(_searchQuery)
      ).toList();
    }

    // Rarity filter
    if (_filterRarity != null) {
      filtered = filtered.where((a) => a.rarity == _filterRarity).toList();
    }

    // Unlocked filter
    if (_showUnlockedOnly) {
      filtered = filtered.where((a) => a.isUnlocked).toList();
    }

    return filtered;
  }

  // 🏆 BUILD ENHANCED ACHIEVEMENT CARD (WITH HOVER SYSTEM)
  Widget _buildEnhancedAchievementCard(NeuralThemeData theme, Achievement achievement) {
    final progress = ref.watch(achievementProgressProvider(achievement.id));
    final isUnlocked = achievement.isUnlocked;
    final isHovered = _hoveredAchievementId == achievement.id;

    return MouseRegion(
      onEnter: (_) => _showHoverPreview(achievement),
      onExit: (_) => _hideHoverPreview(),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        curve: Curves.easeOutCubic,
        transform: Matrix4.identity()..scale(isHovered ? 1.02 : 1.0),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(16),
          color: isUnlocked
              ? achievement.rarity.color.withOpacity(0.15)
              : theme.colors.surface.withOpacity(0.05),
          border: Border.all(
            color: isUnlocked
                ? achievement.rarity.color.withOpacity(isHovered ? 0.6 : 0.3)
                : theme.colors.onSurface.withOpacity(isHovered ? 0.3 : 0.1),
            width: isHovered ? 2 : 1,
          ),
          boxShadow: isUnlocked ? [
            BoxShadow(
              color: achievement.rarity.color.withOpacity(isHovered ? 0.4 : 0.2),
              blurRadius: isHovered ? 15 : 8,
              spreadRadius: isHovered ? 2 : 1,
            ),
          ] : isHovered ? [
            BoxShadow(
              color: theme.colors.primary.withOpacity(0.2),
              blurRadius: 10,
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
                  // 🎯 ENHANCED HEADER ROW
                  _buildAchievementHeader(theme, achievement, isUnlocked),

                  const SizedBox(height: 12),

                  // 📝 TITLE AND DESCRIPTION
                  _buildAchievementContent(theme, achievement, isUnlocked),

                  const Spacer(),

                  // 📊 PROGRESS OR UNLOCK INFO
                  _buildAchievementFooter(theme, achievement, progress, isUnlocked),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  // 🎯 BUILD ACHIEVEMENT HEADER
  Widget _buildAchievementHeader(NeuralThemeData theme, Achievement achievement, bool isUnlocked) {
    return Row(
      children: [
        // 🏆 ENHANCED ICON
        Container(
          width: 40,
          height: 40,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            gradient: RadialGradient(
              colors: [
                isUnlocked
                    ? achievement.rarity.color.withOpacity(0.3)
                    : theme.colors.onSurface.withOpacity(0.1),
                isUnlocked
                    ? achievement.rarity.color.withOpacity(0.1)
                    : theme.colors.onSurface.withOpacity(0.05),
              ],
            ),
            border: Border.all(
              color: isUnlocked
                  ? achievement.rarity.color.withOpacity(0.5)
                  : theme.colors.onSurface.withOpacity(0.2),
              width: 1,
            ),
          ),
          child: Icon(
            achievement.icon,
            size: 20,
            color: isUnlocked
                ? achievement.rarity.color
                : theme.colors.onSurface.withOpacity(0.5),
          ),
        ),

        const Spacer(),

        // 💎 ENHANCED RARITY BADGE
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [
                achievement.rarity.color.withOpacity(0.3),
                achievement.rarity.color.withOpacity(0.1),
              ],
            ),
            borderRadius: BorderRadius.circular(10),
            border: Border.all(
              color: achievement.rarity.color.withOpacity(0.5),
              width: 1,
            ),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                _getRarityIcon(achievement.rarity),
                color: achievement.rarity.color,
                size: 10,
              ),
              const SizedBox(width: 4),
              Text(
                achievement.rarity.displayName.toUpperCase(),
                style: TextStyle(
                  color: achievement.rarity.color,
                  fontSize: 8,
                  fontWeight: FontWeight.bold,
                  letterSpacing: 0.5,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  // 📝 BUILD ACHIEVEMENT CONTENT
  Widget _buildAchievementContent(NeuralThemeData theme, Achievement achievement, bool isUnlocked) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // 🏆 TITLE
        Text(
          achievement.title,
          style: TextStyle(
            color: isUnlocked
                ? theme.colors.onSurface
                : theme.colors.onSurface.withOpacity(0.7),
            fontSize: 15,
            fontWeight: FontWeight.bold,
            letterSpacing: 0.2,
          ),
          maxLines: 2,
          overflow: TextOverflow.ellipsis,
        ),

        const SizedBox(height: 6),

        // 📝 DESCRIPTION
        Text(
          achievement.description,
          style: TextStyle(
            color: isUnlocked
                ? theme.colors.onSurface.withOpacity(0.8)
                : theme.colors.onSurface.withOpacity(0.5),
            fontSize: 12,
            height: 1.3,
          ),
          maxLines: 2,
          overflow: TextOverflow.ellipsis,
        ),
      ],
    );
  }

  // 📊 BUILD ACHIEVEMENT FOOTER
  Widget _buildAchievementFooter(NeuralThemeData theme, Achievement achievement, AchievementProgress? progress, bool isUnlocked) {
    if (isUnlocked && achievement.unlockedAt != null) {
      return Row(
        children: [
          Icon(
            Icons.check_circle,
            color: achievement.rarity.color,
            size: 14,
          ),
          const SizedBox(width: 6),
          Text(
            'Unlocked ${_formatDate(achievement.unlockedAt!)}',
            style: TextStyle(
              color: achievement.rarity.color.withOpacity(0.8),
              fontSize: 10,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      );
    }

    if (!isUnlocked && progress != null) {
      return _buildEnhancedProgressBar(theme, achievement, progress);
    }

    return const SizedBox.shrink();
  }

  // 📊 BUILD ENHANCED PROGRESS BAR
  Widget _buildEnhancedProgressBar(NeuralThemeData theme, Achievement achievement, AchievementProgress progress) {
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
                fontSize: 10,
                fontWeight: FontWeight.w600,
              ),
            ),
            Text(
              '${achievement.currentProgress}/${achievement.targetProgress}',
              style: TextStyle(
                color: theme.colors.onSurface.withOpacity(0.6),
                fontSize: 10,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
        const SizedBox(height: 6),
        Container(
          height: 6,
          decoration: BoxDecoration(
            color: theme.colors.onSurface.withOpacity(0.1),
            borderRadius: BorderRadius.circular(3),
          ),
          child: Stack(
            children: [
              FractionallySizedBox(
                alignment: Alignment.centerLeft,
                widthFactor: percentage,
                child: Container(
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [
                        achievement.rarity.color,
                        achievement.rarity.color.withOpacity(0.7),
                      ],
                    ),
                    borderRadius: BorderRadius.circular(3),
                    boxShadow: [
                      BoxShadow(
                        color: achievement.rarity.color.withOpacity(0.3),
                        blurRadius: 4,
                        spreadRadius: 1,
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  // 🚫 BUILD EMPTY STATE
  Widget _buildEmptyState(NeuralThemeData theme) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.search_off,
            color: theme.colors.onSurface.withOpacity(0.3),
            size: 48,
          ),
          const SizedBox(height: 16),
          Text(
            'No achievements found',
            style: TextStyle(
              color: theme.colors.onSurface.withOpacity(0.6),
              fontSize: 16,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Try adjusting your search or filters',
            style: TextStyle(
              color: theme.colors.onSurface.withOpacity(0.4),
              fontSize: 12,
            ),
          ),
        ],
      ),
    );
  }

  // 👁️ SHOW HOVER PREVIEW (PHASE 3.3 REVOLUTIONARY FEATURE)
  void _showHoverPreview(Achievement achievement) {
    setState(() {
      _hoveredAchievementId = achievement.id;
    });

    // Play hover sound effect
    _playHoverSound();

    // Haptic feedback
    HapticFeedback.selectionClick();

    // Start hover animation
    _hoverController.forward();

    // Show detailed overlay
    _showDetailedHoverOverlay(achievement);
  }

  // 🔊 PLAY HOVER SOUND
  void _playHoverSound() {
    try {
      final audioService = ref.read(spatialAudioServiceProvider);
      // audioService.playNeuralSound('hover'); // Uncomment when audio integration ready
    } catch (e) {
      // Audio service not available, continue silently
    }
  }

  // 📊 SHOW DETAILED HOVER OVERLAY
  void _showDetailedHoverOverlay(Achievement achievement) {
    _hideHoverPreview(); // Remove any existing overlay

    final theme = NeuralThemeSystem().currentTheme;
    final progress = ref.read(achievementProgressProvider(achievement.id));

    _hoverOverlay = OverlayEntry(
      builder: (context) => CompositedTransformFollower(
        link: _layerLink,
        targetAnchor: Alignment.centerRight,
        followerAnchor: Alignment.centerLeft,
        offset: const Offset(10, 0),
        child: Material(
          color: Colors.transparent,
          child: AnimatedBuilder(
            animation: _hoverAnimation,
            builder: (context, child) {
              return Transform.scale(
                scale: _hoverAnimation.value,
                child: Opacity(
                  opacity: _hoverAnimation.value,
                  child: _buildHoverPreviewCard(theme, achievement, progress),
                ),
              );
            },
          ),
        ),
      ),
    );

    Overlay.of(context).insert(_hoverOverlay!);
  }

  // 🏆 BUILD HOVER PREVIEW CARD
  Widget _buildHoverPreviewCard(NeuralThemeData theme, Achievement achievement, AchievementProgress? progress) {
    return Container(
      width: 300,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: theme.colors.surface.withOpacity(0.95),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: achievement.rarity.color.withOpacity(0.5),
          width: 2,
        ),
        boxShadow: [
          BoxShadow(
            color: achievement.rarity.color.withOpacity(0.3),
            blurRadius: 20,
            spreadRadius: 3,
          ),
          BoxShadow(
            color: Colors.black.withOpacity(0.2),
            blurRadius: 10,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(16),
        child: BackdropFilter(
          filter: ui.ImageFilter.blur(sigmaX: 10, sigmaY: 10),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              // 🏆 HEADER
              Row(
                children: [
                  Container(
                    width: 50,
                    height: 50,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      gradient: RadialGradient(
                        colors: [
                          achievement.rarity.color.withOpacity(0.4),
                          achievement.rarity.color.withOpacity(0.1),
                        ],
                      ),
                      border: Border.all(
                        color: achievement.rarity.color.withOpacity(0.6),
                        width: 2,
                      ),
                    ),
                    child: Icon(
                      achievement.icon,
                      size: 24,
                      color: achievement.rarity.color,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          achievement.title,
                          style: TextStyle(
                            color: theme.colors.onSurface,
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                          decoration: BoxDecoration(
                            color: achievement.rarity.color.withOpacity(0.2),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Text(
                            '${achievement.rarity.displayName.toUpperCase()} • ${_getRarityPoints(achievement.rarity)} pts',
                            style: TextStyle(
                              color: achievement.rarity.color,
                              fontSize: 10,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 16),

              // 📝 DESCRIPTION
              Text(
                achievement.description,
                style: TextStyle(
                  color: theme.colors.onSurface.withOpacity(0.8),
                  fontSize: 14,
                  height: 1.4,
                ),
              ),

              const SizedBox(height: 16),

              // 📊 DETAILED STATS
              if (achievement.isUnlocked) ...[
                _buildUnlockedStats(theme, achievement),
              ] else if (progress != null) ...[
                _buildProgressStats(theme, achievement, progress),
              ] else ...[
                _buildHiddenStats(theme, achievement),
              ],
            ],
          ),
        ),
      ),
    );
  }

  // ✅ BUILD UNLOCKED STATS
  Widget _buildUnlockedStats(NeuralThemeData theme, Achievement achievement) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: achievement.rarity.color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: achievement.rarity.color.withOpacity(0.3),
          width: 1,
        ),
      ),
      child: Column(
        children: [
          Row(
            children: [
              Icon(
                Icons.check_circle,
                color: achievement.rarity.color,
                size: 16,
              ),
              const SizedBox(width: 8),
              Text(
                'UNLOCKED',
                style: TextStyle(
                  color: achievement.rarity.color,
                  fontSize: 12,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Unlocked',
                      style: TextStyle(
                        color: theme.colors.onSurface.withOpacity(0.6),
                        fontSize: 10,
                      ),
                    ),
                    Text(
                      _formatDate(achievement.unlockedAt!),
                      style: TextStyle(
                        color: theme.colors.onSurface,
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Points Earned',
                      style: TextStyle(
                        color: theme.colors.onSurface.withOpacity(0.6),
                        fontSize: 10,
                      ),
                    ),
                    Text(
                      '${_getRarityPoints(achievement.rarity)}',
                      style: TextStyle(
                        color: Colors.amber,
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  // 📊 BUILD PROGRESS STATS
  Widget _buildProgressStats(NeuralThemeData theme, Achievement achievement, AchievementProgress progress) {
    final percentage = achievement.progressPercentage;

    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: theme.colors.surface.withOpacity(0.5),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: theme.colors.primary.withOpacity(0.2),
          width: 1,
        ),
      ),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Progress',
                style: TextStyle(
                  color: theme.colors.onSurface,
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                ),
              ),
              Text(
                '${percentage.toStringAsFixed(1)}%',
                style: TextStyle(
                  color: achievement.rarity.color,
                  fontSize: 12,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Container(
            height: 8,
            decoration: BoxDecoration(
              color: theme.colors.onSurface.withOpacity(0.1),
              borderRadius: BorderRadius.circular(4),
            ),
            child: FractionallySizedBox(
              alignment: Alignment.centerLeft,
              widthFactor: percentage / 100,
              child: Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      achievement.rarity.color,
                      achievement.rarity.color.withOpacity(0.7),
                    ],
                  ),
                  borderRadius: BorderRadius.circular(4),
                ),
              ),
            ),
          ),
          const SizedBox(height: 8),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Current: ${achievement.currentProgress}',
                style: TextStyle(
                  color: theme.colors.onSurface.withOpacity(0.6),
                  fontSize: 10,
                ),
              ),
              Text(
                'Target: ${achievement.targetProgress}',
                style: TextStyle(
                  color: theme.colors.onSurface.withOpacity(0.6),
                  fontSize: 10,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  // 🔒 BUILD HIDDEN STATS
  Widget _buildHiddenStats(NeuralThemeData theme, Achievement achievement) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: theme.colors.onSurface.withOpacity(0.05),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: theme.colors.onSurface.withOpacity(0.1),
          width: 1,
        ),
      ),
      child: Row(
        children: [
          Icon(
            Icons.lock,
            color: theme.colors.onSurface.withOpacity(0.5),
            size: 16,
          ),
          const SizedBox(width: 8),
          Text(
            'Hidden achievement - discover to unlock!',
            style: TextStyle(
              color: theme.colors.onSurface.withOpacity(0.5),
              fontSize: 12,
              fontStyle: FontStyle.italic,
            ),
          ),
        ],
      ),
    );
  }

  // 👁️ HIDE HOVER PREVIEW
  void _hideHoverPreview() {
    setState(() {
      _hoveredAchievementId = null;
    });

    _hoverController.reverse();

    _hoverOverlay?.remove();
    _hoverOverlay = null;
  }

  // 🎯 UTILITY METHODS
  CompletionLevel _getCompletionLevel(double percentage) {
    if (percentage >= 100) return CompletionLevel.master;
    if (percentage >= 80) return CompletionLevel.expert;
    if (percentage >= 60) return CompletionLevel.advanced;
    if (percentage >= 40) return CompletionLevel.intermediate;
    if (percentage >= 20) return CompletionLevel.beginner;
    return CompletionLevel.novice;
  }

  IconData _getRarityIcon(AchievementRarity rarity) {
    switch (rarity) {
      case AchievementRarity.common:
        return Icons.circle;
      case AchievementRarity.rare:
        return Icons.hexagon;
      case AchievementRarity.epic:
        return Icons.diamond;
      case AchievementRarity.legendary:
        return Icons.auto_awesome;
    }
  }

  int _getRarityPoints(AchievementRarity rarity) {
    switch (rarity) {
      case AchievementRarity.common:
        return 10;
      case AchievementRarity.rare:
        return 25;
      case AchievementRarity.epic:
        return 50;
      case AchievementRarity.legendary:
        return 100;
    }
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

// 🎯 COMPLETION LEVEL DATA CLASS
class CompletionLevel {
  final String name;
  final Color color;
  final IconData icon;

  const CompletionLevel({
    required this.name,
    required this.color,
    required this.icon,
  });

  static const novice = CompletionLevel(
    name: 'Novice',
    color: Colors.grey,
    icon: Icons.stars,
  );

  static const beginner = CompletionLevel(
    name: 'Beginner',
    color: Colors.blue,
    icon: Icons.star,
  );

  static const intermediate = CompletionLevel(
    name: 'Intermediate',
    color: Colors.green,
    icon: Icons.star_half,
  );

  static const advanced = CompletionLevel(
    name: 'Advanced',
    color: Colors.orange,
    icon: Icons.star_border,
  );

  static const expert = CompletionLevel(
    name: 'Expert',
    color: Colors.purple,
    icon: Icons.military_tech,
  );

  static const master = CompletionLevel(
    name: 'Master',
    color: Colors.amber,
    icon: Icons.emoji_events,
  );
}

/// 🎯 Achievement Quick Stats Widget - Enhanced version
class AchievementQuickStats extends ConsumerWidget {
  const AchievementQuickStats({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = NeuralThemeSystem().currentTheme;
    final stats = ref.watch(achievementStatsProvider);
    final recentAchievements = ref.watch(recentAchievementsProvider);

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            theme.colors.surface.withOpacity(0.2),
            theme.colors.surface.withOpacity(0.1),
          ],
        ),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: theme.colors.primary.withOpacity(0.3),
          width: 1,
        ),
        boxShadow: [
          BoxShadow(
            color: theme.colors.primary.withOpacity(0.1),
            blurRadius: 8,
            spreadRadius: 1,
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(12),
        child: BackdropFilter(
          filter: ui.ImageFilter.blur(sigmaX: 5, sigmaY: 5),
          child: Row(
            children: [
              // 🏆 ENHANCED TROPHY ICON
              Container(
                width: 24,
                height: 24,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: RadialGradient(
                    colors: [
                      theme.colors.primary.withOpacity(0.3),
                      theme.colors.primary.withOpacity(0.1),
                    ],
                  ),
                ),
                child: Icon(
                  Icons.emoji_events,
                  color: theme.colors.primary,
                  size: 16,
                ),
              ),

              const SizedBox(width: 10),

              // 📊 STATS
              Text(
                '${stats.unlockedAchievements}/${stats.totalAchievements}',
                style: TextStyle(
                  color: theme.colors.onSurface,
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                ),
              ),

              if (recentAchievements.isNotEmpty) ...[
                const SizedBox(width: 8),
                Container(
                  width: 4,
                  height: 4,
                  decoration: BoxDecoration(
                    color: theme.colors.primary,
                    shape: BoxShape.circle,
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    'Latest: ${recentAchievements.first.title}',
                    style: TextStyle(
                      color: theme.colors.onSurface.withOpacity(0.7),
                      fontSize: 12,
                    ),
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}