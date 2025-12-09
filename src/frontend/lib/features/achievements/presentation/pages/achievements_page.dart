import 'dart:async';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:frontend/core/di/injection_container.dart' as di;
import 'package:frontend/features/achievements/domain/entities/achievement.dart';
import 'package:frontend/features/achievements/domain/entities/user_achievement.dart';
import 'package:frontend/features/achievements/domain/usecases/get_user_achievements.dart';
import 'package:frontend/features/achievements/presentation/bloc/achievements_bloc.dart';
import 'package:frontend/features/achievements/presentation/bloc/achievements_event.dart';
import 'package:frontend/features/achievements/presentation/bloc/achievements_state.dart';
import 'package:frontend/features/achievements/presentation/widgets/achievement_card.dart';

/// Achievements page displaying user's achievements (FR-008)
class AchievementsPage extends StatefulWidget {
  const AchievementsPage({super.key});

  @override
  State<AchievementsPage> createState() => _AchievementsPageState();
}

class _AchievementsPageState extends State<AchievementsPage> {
  late final String userId;

  // Filter states
  String _selectedStatus = 'all'; // all, unlocked, locked, in_progress
  AchievementType? _selectedType; // null means all types

  @override
  void initState() {
    super.initState();
    final currentUser = FirebaseAuth.instance.currentUser;
    userId = currentUser?.uid ?? '';
  }

  /// Build empty state widget
  Widget _buildEmptyState(BuildContext context) => Center(
        child: Padding(
          padding: const EdgeInsets.all(32),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.emoji_events_outlined,
                size: 100,
                color: Colors.grey[400],
              ),
              const SizedBox(height: 24),
              Text(
                'No achievements yet',
                style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
              ),
              const SizedBox(height: 12),
              Text(
                'Complete workouts and build habits to earn achievements!',
                style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                      color: Colors.grey[600],
                    ),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      );

  /// Build error state widget
  Widget _buildErrorState(BuildContext context, String message) => Center(
        child: Padding(
          padding: const EdgeInsets.all(32),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.error_outline, size: 64, color: Colors.red[300]),
              const SizedBox(height: 16),
              Text(
                'Error loading achievements',
                style: TextStyle(fontSize: 18, color: Colors.grey[700]),
              ),
              const SizedBox(height: 8),
              Text(
                message,
                style: TextStyle(fontSize: 14, color: Colors.grey[600]),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 16),
              ElevatedButton.icon(
                onPressed: () {
                  context
                      .read<AchievementsBloc>()
                      .add(LoadAchievements(userId: userId));
                },
                icon: const Icon(Icons.refresh),
                label: const Text('Try again'),
              ),
            ],
          ),
        ),
      );

  /// Build summary card with yellow/orange gradient
  Widget _buildSummaryCard(
    BuildContext context,
    UserAchievementsResult result,
  ) {
    final unlockedCount = result.unlockedAchievements.length;
    final totalCount = result.achievements.length;
    final totalPoints = result.unlockedAchievements.fold<int>(
      0,
      (sum, a) => sum + a.points,
    );
    final progressPercent =
        totalCount > 0 ? ((unlockedCount / totalCount) * 100).toInt() : 0;

    return Container(
      margin: const EdgeInsets.all(16),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFFFFC107), Color(0xFFFFB300)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFFFFC107).withValues(alpha: 0.4),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _buildStatColumn(
                Icons.emoji_events,
                '$unlockedCount/$totalCount',
                'Unlocked',
              ),
              _buildStatColumn(
                Icons.star,
                totalPoints.toString(),
                'Points',
              ),
              _buildStatColumn(
                Icons.percent,
                '$progressPercent%',
                'Complete',
              ),
            ],
          ),
          const SizedBox(height: 16),
          // Progress bar
          ClipRRect(
            borderRadius: BorderRadius.circular(4),
            child: LinearProgressIndicator(
              value: totalCount > 0 ? unlockedCount / totalCount : 0,
              backgroundColor: Colors.white.withValues(alpha: 0.3),
              valueColor: const AlwaysStoppedAnimation<Color>(Colors.white),
              minHeight: 6,
            ),
          ),
        ],
      ),
    );
  }

  /// Build stat column for summary card
  Widget _buildStatColumn(IconData icon, String value, String label) => Column(
        children: [
          Icon(icon, size: 28, color: Colors.white),
          const SizedBox(height: 6),
          Text(
            value,
            style: const TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
          Text(
            label,
            style: TextStyle(
              fontSize: 12,
              color: Colors.white.withValues(alpha: 0.9),
            ),
          ),
        ],
      );

  /// Build status filter chips
  Widget _buildStatusFilters() => SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 16),
        child: Row(
          children: [
            _buildFilterChip('All', 'all', _selectedStatus == 'all'),
            const SizedBox(width: 8),
            _buildFilterChip(
                'Unlocked', 'unlocked', _selectedStatus == 'unlocked'),
            const SizedBox(width: 8),
            _buildFilterChip('Locked', 'locked', _selectedStatus == 'locked'),
            const SizedBox(width: 8),
            _buildFilterChip(
                'In Progress', 'in_progress', _selectedStatus == 'in_progress'),
          ],
        ),
      );

  /// Build type filter chips
  Widget _buildTypeFilters() => SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 16),
        child: Row(
          children: [
            _buildTypeChip('All Types', null, _selectedType == null),
            const SizedBox(width: 8),
            _buildTypeChip(
              'Streak',
              AchievementType.streak,
              _selectedType == AchievementType.streak,
              Icons.local_fire_department,
            ),
            const SizedBox(width: 8),
            _buildTypeChip(
              'Habit',
              AchievementType.habit,
              _selectedType == AchievementType.habit,
              Icons.track_changes,
            ),
            const SizedBox(width: 8),
            _buildTypeChip(
              'Workout',
              AchievementType.workout,
              _selectedType == AchievementType.workout,
              Icons.fitness_center,
            ),
          ],
        ),
      );

  /// Build status filter chip
  Widget _buildFilterChip(String label, String value, bool isSelected) =>
      FilterChip(
        label: Text(label),
        selected: isSelected,
        onSelected: (_) => setState(() => _selectedStatus = value),
        selectedColor: Colors.green,
        checkmarkColor: Colors.white,
        labelStyle: TextStyle(
          color: isSelected ? Colors.white : Colors.black87,
          fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
        ),
        backgroundColor: Colors.grey[200],
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
        ),
        showCheckmark: isSelected,
        padding: const EdgeInsets.symmetric(horizontal: 4),
      );

  /// Build type filter chip
  Widget _buildTypeChip(
    String label,
    AchievementType? type,
    bool isSelected, [
    IconData? icon,
  ]) =>
      FilterChip(
        avatar: icon != null
            ? Icon(
                icon,
                size: 18,
                color: isSelected ? Colors.white : Colors.grey[600],
              )
            : null,
        label: Text(label),
        selected: isSelected,
        onSelected: (_) => setState(() => _selectedType = type),
        selectedColor: Colors.green,
        checkmarkColor: Colors.white,
        labelStyle: TextStyle(
          color: isSelected ? Colors.white : Colors.black87,
          fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
        ),
        backgroundColor: Colors.grey[200],
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
        ),
        showCheckmark: isSelected && icon == null,
        padding: const EdgeInsets.symmetric(horizontal: 4),
      );

  /// Filter achievements based on selected filters
  List<Achievement> _filterAchievements(
    UserAchievementsResult result,
  ) {
    List<Achievement> filtered;

    // Filter by status
    switch (_selectedStatus) {
      case 'unlocked':
        filtered = result.unlockedAchievements;
      case 'locked':
        filtered = result.lockedAchievements;
      case 'in_progress':
        filtered = result.inProgressAchievements;
      default:
        filtered = result.achievements;
    }

    // Filter by type
    if (_selectedType != null) {
      filtered = filtered.where((a) => a.type == _selectedType).toList();
    }

    return filtered;
  }

  /// Show achievement details dialog
  void _showAchievementDetails(
    BuildContext context,
    Achievement achievement,
    UserAchievement? userAchievement,
  ) {
    final isUnlocked = userAchievement?.isUnlocked ?? false;

    unawaited(showDialog<void>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: Row(
          children: [
            Icon(
              _getTypeIcon(achievement.type),
              color: _getTierColor(achievement.tier),
            ),
            const SizedBox(width: 12),
            Expanded(child: Text(achievement.name)),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(achievement.description),
            const SizedBox(height: 16),
            Row(
              children: [
                Chip(
                  label: Text(_getTierName(achievement.tier)),
                  backgroundColor:
                      _getTierColor(achievement.tier).withValues(alpha: 0.2),
                ),
                const SizedBox(width: 8),
                Chip(
                  label: Text('${achievement.points} points'),
                  backgroundColor: Colors.purple.withValues(alpha: 0.2),
                ),
              ],
            ),
            const SizedBox(height: 16),
            if (isUnlocked)
              const Row(
                children: [
                  Icon(Icons.check_circle, color: Colors.green, size: 20),
                  SizedBox(width: 8),
                  Text(
                    'Unlocked!',
                    style: TextStyle(
                      color: Colors.green,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              )
            else
              const Row(
                children: [
                  Icon(Icons.lock_outline, color: Colors.grey, size: 20),
                  SizedBox(width: 8),
                  Text(
                    'Not yet unlocked',
                    style: TextStyle(color: Colors.grey),
                  ),
                ],
              ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(dialogContext).pop(),
            child: const Text('Close'),
          ),
        ],
      ),
    ));
  }

  /// Get tier color
  Color _getTierColor(AchievementTier tier) {
    switch (tier) {
      case AchievementTier.bronze:
        return const Color(0xFFCD7F32);
      case AchievementTier.silver:
        return const Color(0xFFC0C0C0);
      case AchievementTier.gold:
        return const Color(0xFFFFD700);
      case AchievementTier.platinum:
        return const Color(0xFFE5E4E2);
    }
  }

  /// Get tier name
  String _getTierName(AchievementTier tier) {
    switch (tier) {
      case AchievementTier.bronze:
        return 'Bronze';
      case AchievementTier.silver:
        return 'Silver';
      case AchievementTier.gold:
        return 'Gold';
      case AchievementTier.platinum:
        return 'Platinum';
    }
  }

  /// Get type icon
  IconData _getTypeIcon(AchievementType type) {
    switch (type) {
      case AchievementType.streak:
        return Icons.local_fire_department;
      case AchievementType.habit:
        return Icons.track_changes;
      case AchievementType.workout:
        return Icons.fitness_center;
      case AchievementType.milestone:
        return Icons.flag;
      case AchievementType.special:
        return Icons.star;
    }
  }

  @override
  Widget build(BuildContext context) {
    if (userId.isEmpty) {
      return const Scaffold(
        body: Center(child: Text('Please sign in')),
      );
    }

    return BlocProvider(
      create: (context) =>
          di.sl<AchievementsBloc>()..add(LoadAchievements(userId: userId)),
      child: Scaffold(
        body: BlocBuilder<AchievementsBloc, AchievementsState>(
          builder: (context, state) {
            if (state is AchievementsInitial || state is AchievementsLoading) {
              return const Center(child: CircularProgressIndicator());
            }

            if (state is AchievementsError) {
              return _buildErrorState(context, state.message);
            }

            if (state is AchievementsLoaded) {
              final result = state.result;

              if (result.achievements.isEmpty) {
                return _buildEmptyState(context);
              }

              final filteredAchievements = _filterAchievements(result);

              return RefreshIndicator(
                onRefresh: () async {
                  context
                      .read<AchievementsBloc>()
                      .add(LoadAchievements(userId: userId));
                  await Future<void>.delayed(const Duration(milliseconds: 500));
                },
                child: CustomScrollView(
                  slivers: [
                    // Summary card
                    SliverToBoxAdapter(
                      child: _buildSummaryCard(context, result),
                    ),
                    // Status filter chips
                    SliverToBoxAdapter(
                      child: _buildStatusFilters(),
                    ),
                    const SliverToBoxAdapter(child: SizedBox(height: 12)),
                    // Type filter chips
                    SliverToBoxAdapter(
                      child: _buildTypeFilters(),
                    ),
                    const SliverToBoxAdapter(child: SizedBox(height: 16)),
                    // Achievements list
                    if (filteredAchievements.isEmpty)
                      SliverFillRemaining(
                        child: Center(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(
                                Icons.search_off,
                                size: 64,
                                color: Colors.grey[400],
                              ),
                              const SizedBox(height: 16),
                              Text(
                                'No achievements found',
                                style: Theme.of(context)
                                    .textTheme
                                    .titleMedium
                                    ?.copyWith(
                                      color: Colors.grey[600],
                                    ),
                              ),
                            ],
                          ),
                        ),
                      )
                    else
                      SliverPadding(
                        padding: const EdgeInsets.symmetric(horizontal: 16),
                        sliver: SliverList(
                          delegate: SliverChildBuilderDelegate(
                            (context, index) {
                              final achievement = filteredAchievements[index];
                              final userAchievement =
                                  result.getUserAchievement(achievement.id);

                              return Padding(
                                padding: const EdgeInsets.only(bottom: 12),
                                child: AchievementCard(
                                  achievement: achievement,
                                  userAchievement: userAchievement,
                                  onTap: () => _showAchievementDetails(
                                    context,
                                    achievement,
                                    userAchievement,
                                  ),
                                ),
                              );
                            },
                            childCount: filteredAchievements.length,
                          ),
                        ),
                      ),
                    // Bottom padding
                    const SliverToBoxAdapter(child: SizedBox(height: 16)),
                  ],
                ),
              );
            }

            return const Center(child: Text('Unknown state'));
          },
        ),
      ),
    );
  }
}
