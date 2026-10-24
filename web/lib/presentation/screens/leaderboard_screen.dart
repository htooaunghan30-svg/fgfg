import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../providers/user_provider.dart';
import '../../core/localization/app_localizations.dart';
import '../../core/localization/badge_text_localizer.dart';
import '../../data/models/badge_achievement.dart';

class LeaderboardScreen extends StatefulWidget {
  const LeaderboardScreen({super.key});

  @override
  State<LeaderboardScreen> createState() => _LeaderboardScreenState();
}

class _LeaderboardScreenState extends State<LeaderboardScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.t('leaderboard.title')),
        bottom: TabBar(
          controller: _tabController,
          tabs: [
            Tab(text: l10n.t('leaderboard.achievements')),
            Tab(text: l10n.t('leaderboard.global')),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: const [
          _AchievementsTab(),
          _GlobalLeaderboardTab(),
        ],
      ),
    );
  }
}

class _AchievementsTab extends StatelessWidget {
  const _AchievementsTab();

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final userProvider = Provider.of<UserProvider>(context);
    final badges = userProvider.badges;

    final bronzeBadges =
        badges.where((b) => b.tier == BadgeTier.bronze).toList();
    final silverBadges =
        badges.where((b) => b.tier == BadgeTier.silver).toList();
    final goldBadges = badges.where((b) => b.tier == BadgeTier.gold).toList();
    final platinumBadges =
        badges.where((b) => b.tier == BadgeTier.platinum).toList();

    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        _buildAchievementStats(context, badges),
        const SizedBox(height: 24),
        if (bronzeBadges.isNotEmpty)
          _buildBadgeTierSection(
            context,
            'tier.bronze',
            bronzeBadges,
            const Color(0xFFCD7F32),
          ),
        if (silverBadges.isNotEmpty)
          _buildBadgeTierSection(
            context,
            'tier.silver',
            silverBadges,
            const Color(0xFFC0C0C0),
          ),
        if (goldBadges.isNotEmpty)
          _buildBadgeTierSection(
            context,
            'tier.gold',
            goldBadges,
            const Color(0xFFFFD700),
          ),
        if (platinumBadges.isNotEmpty)
          _buildBadgeTierSection(
            context,
            'tier.platinum',
            platinumBadges,
            const Color(0xFFE5E4E2),
          ),
        if (badges.isEmpty)
          Padding(
            padding: const EdgeInsets.only(top: 24),
            child: Text(
              l10n.t('badges.empty'),
              textAlign: TextAlign.center,
              style: const TextStyle(color: Colors.grey),
            ),
          ),
      ],
    );
  }

  Widget _buildAchievementStats(
    BuildContext context,
    List<BadgeAchievement> badges,
  ) {
    final l10n = context.l10n;
    final unlocked = badges.where((b) => b.isUnlocked).length;
    final total = badges.length;
    final percentage = total > 0 ? (unlocked / total * 100).toInt() : 0;

    final bronzeBadges =
        badges.where((b) => b.tier == BadgeTier.bronze).toList();
    final silverBadges =
        badges.where((b) => b.tier == BadgeTier.silver).toList();
    final goldBadges = badges.where((b) => b.tier == BadgeTier.gold).toList();
    final platinumBadges =
        badges.where((b) => b.tier == BadgeTier.platinum).toList();

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            Text(
              l10n.t('leaderboard.achievement_progress'),
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            Stack(
              alignment: Alignment.center,
              children: [
                SizedBox(
                  width: 150,
                  height: 150,
                  child: CircularProgressIndicator(
                    value: total == 0 ? 0 : unlocked / total,
                    strokeWidth: 10,
                    backgroundColor: Colors.grey[200],
                    valueColor: AlwaysStoppedAnimation<Color>(
                      _getProgressColor(percentage),
                    ),
                  ),
                ),
                Column(
                  children: [
                    Text(
                      '$percentage%',
                      style: const TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    Text(
                      '$unlocked/$total',
                      style: const TextStyle(
                        fontSize: 16,
                        color: Colors.grey,
                      ),
                    ),
                  ],
                ),
              ],
            ),
            const SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                _buildTierStat(context, BadgeTier.bronze, bronzeBadges),
                _buildTierStat(context, BadgeTier.silver, silverBadges),
                _buildTierStat(context, BadgeTier.gold, goldBadges),
                _buildTierStat(context, BadgeTier.platinum, platinumBadges),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTierStat(
    BuildContext context,
    BadgeTier tier,
    List<BadgeAchievement> badges,
  ) {
    final l10n = context.l10n;
    final unlocked = badges.where((b) => b.isUnlocked).length;
    final tierKey = 'tier.${tier.name}';
    return Column(
      children: [
        Container(
          width: 40,
          height: 40,
          decoration: BoxDecoration(
            color: _getTierColor(tier),
            shape: BoxShape.circle,
          ),
          child: Center(
            child: Text(
              '$unlocked',
              style: const TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ),
        const SizedBox(height: 4),
        Text(
          l10n.t(tierKey),
          style: const TextStyle(
            fontSize: 12,
            color: Colors.grey,
          ),
        ),
      ],
    );
  }

  Widget _buildBadgeTierSection(
    BuildContext context,
    String tierKey,
    List<BadgeAchievement> badges,
    Color tierColor,
  ) {
    final l10n = context.l10n;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Container(
              width: 16,
              height: 16,
              decoration: BoxDecoration(
                color: tierColor,
                shape: BoxShape.circle,
              ),
            ),
            const SizedBox(width: 8),
            Text(
              l10n.t(tierKey),
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            ),
            const Spacer(),
            Text(
              '${badges.where((b) => b.isUnlocked).length}/${badges.length}',
              style: const TextStyle(
                color: Colors.grey,
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        GridView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 3,
            crossAxisSpacing: 12,
            mainAxisSpacing: 12,
            childAspectRatio: 0.9,
          ),
          itemCount: badges.length,
          itemBuilder: (context, index) {
            return _buildBadgeCard(context, badges[index]);
          },
        ),
        const SizedBox(height: 24),
      ],
    );
  }

  Widget _buildBadgeCard(BuildContext context, BadgeAchievement badge) {
    final l10n = context.l10n;
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 60,
              height: 60,
              decoration: BoxDecoration(
                color: badge.isUnlocked
                    ? _getTierColor(badge.tier)
                    : Colors.grey[300],
                shape: BoxShape.circle,
                border: Border.all(
                  color: badge.isUnlocked ? Colors.amber : Colors.grey,
                  width: 2,
                ),
              ),
              child: Center(
                child: badge.isUnlocked
                    ? const Icon(Icons.star, color: Colors.white, size: 30)
                    : const Icon(Icons.lock, color: Colors.grey, size: 30),
              ),
            ),
            const SizedBox(height: 8),
            Text(
              BadgeTextLocalizer.localizedName(l10n, badge),
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w600,
                color: badge.isUnlocked ? Colors.black : Colors.grey,
              ),
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
            const SizedBox(height: 4),
            if (!badge.isUnlocked)
              Text(
                '${badge.progress}/${badge.requirement}',
                style: const TextStyle(
                  fontSize: 10,
                  color: Colors.grey,
                ),
              ),
            if (badge.isUnlocked)
              Text(
                l10n.t(
                  'badges.unlocked_on',
                  params: {'date': _formatDate(badge.unlockedAt)},
                ),
                style: const TextStyle(
                  fontSize: 10,
                  color: Colors.green,
                ),
              ),
          ],
        ),
      ),
    );
  }

  Color _getProgressColor(int percentage) {
    if (percentage >= 75) return Colors.green;
    if (percentage >= 50) return Colors.orange;
    if (percentage >= 25) return Colors.blue;
    return Colors.grey;
  }

  Color _getTierColor(BadgeTier tier) {
    switch (tier) {
      case BadgeTier.bronze:
        return const Color(0xFFCD7F32);
      case BadgeTier.silver:
        return const Color(0xFFC0C0C0);
      case BadgeTier.gold:
        return const Color(0xFFFFD700);
      case BadgeTier.platinum:
        return const Color(0xFFE5E4E2);
    }
  }

  String _formatDate(DateTime date) {
    return '${date.day}/${date.month}/${date.year}';
  }
}

class _GlobalLeaderboardTab extends StatelessWidget {
  const _GlobalLeaderboardTab();

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        _buildPersonalBestCard(context),
        const SizedBox(height: 20),
        _buildSimulatedLeaderboard(context),
      ],
    );
  }

  Widget _buildPersonalBestCard(BuildContext context) {
    final l10n = context.l10n;
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              l10n.t('leaderboard.personal_bests'),
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                _buildPersonalBestItem(
                  l10n.t('leaderboard.most_reps'),
                  '150',
                  'Push-up',
                ),
                _buildPersonalBestItem(
                  l10n.t('leaderboard.best_accuracy'),
                  '98%',
                  'Squat',
                ),
                _buildPersonalBestItem(
                  l10n.t('leaderboard.longest_streak'),
                  '21',
                  l10n.t('leaderboard.days'),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPersonalBestItem(String title, String value, String subtitle) {
    return Column(
      children: [
        Text(
          value,
          style: const TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.bold,
          ),
        ),
        Text(
          title,
          style: const TextStyle(
            fontSize: 12,
            color: Colors.grey,
          ),
        ),
        Text(
          subtitle,
          style: const TextStyle(
            fontSize: 10,
            color: Colors.grey,
          ),
        ),
      ],
    );
  }

  Widget _buildSimulatedLeaderboard(BuildContext context) {
    final l10n = context.l10n;
    final leaderboardData = [
      _LeaderboardEntry(name: 'You', score: 1250, rank: 1),
      _LeaderboardEntry(name: 'Fitness Pro', score: 1150, rank: 2),
      _LeaderboardEntry(name: 'Gym Rat', score: 1020, rank: 3),
      _LeaderboardEntry(name: 'Workout Warrior', score: 980, rank: 4),
      _LeaderboardEntry(name: 'Exercise Expert', score: 850, rank: 5),
    ];

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              l10n.t('leaderboard.global_simulated'),
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            ListView.separated(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: leaderboardData.length,
              separatorBuilder: (context, index) => const Divider(),
              itemBuilder: (context, index) {
                return _buildLeaderboardItem(context, leaderboardData[index]);
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildLeaderboardItem(BuildContext context, _LeaderboardEntry entry) {
    final l10n = context.l10n;
    return ListTile(
      leading: Container(
        width: 40,
        height: 40,
        decoration: BoxDecoration(
          color: entry.rank == 1 ? Colors.amber : Colors.grey[300],
          shape: BoxShape.circle,
        ),
        child: Center(
          child: Text(
            '${entry.rank}',
            style: TextStyle(
              color: entry.rank == 1 ? Colors.white : Colors.black,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
      ),
      title: Text(
        entry.name,
        style: TextStyle(
          fontWeight: entry.rank == 1 ? FontWeight.bold : FontWeight.normal,
        ),
      ),
      trailing: Text(
        l10n.t('leaderboard.points', params: {'score': '${entry.score}'}),
        style: const TextStyle(
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }
}

class _LeaderboardEntry {
  final String name;
  final int score;
  final int rank;

  _LeaderboardEntry({
    required this.name,
    required this.score,
    required this.rank,
  });
}
