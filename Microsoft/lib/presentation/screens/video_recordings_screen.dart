import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';
import 'package:video_player/video_player.dart';
import '../../core/localization/app_localizations.dart';
import '../../core/localization/badge_text_localizer.dart';
import '../../data/models/badge_achievement.dart';
import '../../data/services/profile_photo_storage.dart';
import '../../data/services/video_recording_storage.dart';
import '../providers/exercise_provider.dart';
import '../providers/user_provider.dart';

class VideoRecordingsScreen extends StatefulWidget {
  const VideoRecordingsScreen({super.key});

  @override
  State<VideoRecordingsScreen> createState() => _VideoRecordingsScreenState();
}

class _VideoRecordingsScreenState extends State<VideoRecordingsScreen>
    with SingleTickerProviderStateMixin {
  static const int _minPlayableRecordingBytes = 5 * 1024;
  late final TabController _tabController;
  late Future<List<RecordedVideoInfo>> _recordingsFuture;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    _recordingsFuture = VideoRecordingStorage.listRecordings();
  }

  Future<void> _reload() async {
    setState(() {
      _recordingsFuture = VideoRecordingStorage.listRecordings();
    });
    await _recordingsFuture;
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final bool isDark = theme.brightness == Brightness.dark;
    return Column(
      children: [
        Container(
          color: theme.scaffoldBackgroundColor,
          padding: const EdgeInsets.fromLTRB(16, 12, 16, 6),
          child: DecoratedBox(
            decoration: BoxDecoration(
              color: isDark
                  ? const Color(0xFF1D172C)
                  : colorScheme.surface.withOpacity(0.92),
              borderRadius: BorderRadius.circular(22),
              border: Border.all(
                color: colorScheme.primary.withOpacity(isDark ? 0.20 : 0.10),
              ),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(isDark ? 0.18 : 0.06),
                  blurRadius: 16,
                  offset: const Offset(0, 8),
                ),
              ],
            ),
            child: Padding(
              padding: const EdgeInsets.all(6),
              child: TabBar(
                controller: _tabController,
                dividerColor: Colors.transparent,
                indicator: BoxDecoration(
                  borderRadius: BorderRadius.circular(16),
                  gradient: LinearGradient(
                    colors: [
                      colorScheme.primary,
                      colorScheme.secondary.withOpacity(0.95),
                    ],
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: colorScheme.primary.withOpacity(0.24),
                      blurRadius: 12,
                      offset: const Offset(0, 5),
                    ),
                  ],
                ),
                indicatorSize: TabBarIndicatorSize.tab,
                labelColor: colorScheme.onPrimary,
                unselectedLabelColor:
                    colorScheme.onSurface.withOpacity(isDark ? 0.78 : 0.66),
                labelStyle: const TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w800,
                  letterSpacing: 0.15,
                ),
                unselectedLabelStyle: const TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w700,
                  letterSpacing: 0.1,
                ),
                tabs: [
                  Tab(text: l10n.t('recordings.tab.recordings')),
                  Tab(text: l10n.t('recordings.tab.profile')),
                ],
              ),
            ),
          ),
        ),
        Expanded(
          child: TabBarView(
            controller: _tabController,
            children: [
              _buildRecordingsTab(context),
              const _ProfileTab(),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildRecordingsTab(BuildContext context) {
    final l10n = context.l10n;
    return FutureBuilder<List<RecordedVideoInfo>>(
      future: _recordingsFuture,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }

        if (snapshot.hasError) {
          return Center(
            child: Text(
              l10n.t('recordings.failed_load'),
              style: TextStyle(color: Theme.of(context).colorScheme.error),
            ),
          );
        }

        final recordings = (snapshot.data ?? [])
            .where((recording) =>
                recording.sizeBytes >= _minPlayableRecordingBytes)
            .toList();

        if (recordings.isEmpty) {
          return Center(
            child: Text(
              l10n.t('recordings.empty'),
              style: const TextStyle(color: Colors.grey),
            ),
          );
        }

        return RefreshIndicator(
          onRefresh: _reload,
          child: ListView.separated(
            padding: const EdgeInsets.all(16),
            itemCount: recordings.length,
            separatorBuilder: (_, __) => const SizedBox(height: 8),
            itemBuilder: (context, index) {
              final recording = recordings[index];
              final fileName = _fileName(recording.file);
              return Card(
                child: ListTile(
                  leading: const _RecordingThumbnail(),
                  title: Text(fileName),
                  subtitle: Text(
                    '${_formatDateTime(recording.modifiedAt)} | ${_formatSize(recording.sizeBytes)}',
                  ),
                  trailing: const Icon(Icons.play_arrow),
                  onTap: () => _openShortsPlayer(
                    context,
                    recordings,
                    index,
                  ),
                ),
              );
            },
          ),
        );
      },
    );
  }

  void _openShortsPlayer(
    BuildContext context,
    List<RecordedVideoInfo> recordings,
    int initialIndex,
  ) {
    final l10n = context.l10n;
    if (recordings.isEmpty ||
        initialIndex < 0 ||
        initialIndex >= recordings.length) {
      return;
    }

    final file = recordings[initialIndex].file;
    try {
      if (!file.existsSync()) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(l10n.t('recordings.file_not_found')),
            backgroundColor: Colors.red,
          ),
        );
        return;
      }

      if (file.lengthSync() < _minPlayableRecordingBytes) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(l10n.t('recordings.file_incomplete')),
            backgroundColor: Colors.red,
          ),
        );
        return;
      }
    } catch (_) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(l10n.t('recordings.failed_load')),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => ShortsPlayerScreen(
          recordings: recordings,
          initialIndex: initialIndex,
        ),
      ),
    );
  }

  String _fileName(File file) {
    final parts = file.path.split(Platform.pathSeparator);
    return parts.isNotEmpty ? parts.last : file.path;
  }

  String _formatSize(int bytes) {
    const kb = 1024;
    const mb = 1024 * kb;
    if (bytes >= mb) {
      final value = bytes / mb;
      return '${value.toStringAsFixed(1)} MB';
    }
    if (bytes >= kb) {
      final value = bytes / kb;
      return '${value.toStringAsFixed(1)} KB';
    }
    return '$bytes B';
  }

  String _formatDateTime(DateTime dt) {
    final y = dt.year.toString().padLeft(4, '0');
    final m = dt.month.toString().padLeft(2, '0');
    final d = dt.day.toString().padLeft(2, '0');
    final h = dt.hour.toString().padLeft(2, '0');
    final min = dt.minute.toString().padLeft(2, '0');
    return '$y-$m-$d $h:$min';
  }
}

class _ProfileTab extends StatelessWidget {
  const _ProfileTab();

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final theme = Theme.of(context);
    final userProvider = context.watch<UserProvider>();
    final exerciseProvider = context.watch<ExerciseProvider>();
    final userName = userProvider.userName.trim().isEmpty
        ? l10n.t('profile.guest_name')
        : userProvider.userName.trim();
    final exercises = exerciseProvider.exercises;
    final unlockedBadges =
        userProvider.badges.where((badge) => badge.isUnlocked).toList();
    final hasBadgePosterSaveFailure = unlockedBadges.any(
      (badge) => userProvider.isBadgePosterSaveFailed(badge.badgeId),
    );

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  theme.colorScheme.primary.withOpacity(0.16),
                  theme.colorScheme.secondary.withOpacity(0.08),
                ],
              ),
              borderRadius: BorderRadius.circular(18),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    CircleAvatar(
                      radius: 28,
                      backgroundColor:
                          theme.colorScheme.primary.withOpacity(0.2),
                      child: Text(
                        _initialsFromName(userName),
                        style: TextStyle(
                          fontWeight: FontWeight.w700,
                          color: theme.colorScheme.primary,
                          fontSize: 18,
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            l10n.t('profile.user_name_label'),
                            style: theme.textTheme.bodySmall?.copyWith(
                              color:
                                  theme.colorScheme.onSurface.withOpacity(0.6),
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            userName,
                            style: theme.textTheme.titleLarge?.copyWith(
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        ],
                      ),
                    ),
                    TextButton.icon(
                      onPressed: () =>
                          _showEditNameDialog(context, userProvider),
                      icon: const Icon(Icons.edit, size: 18),
                      label: Text(l10n.t('profile.edit_name')),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                _ProfilePhotoSection(
                  photoPath: userProvider.profilePhotoPath,
                  onPick: () => _pickProfilePhoto(context, userProvider),
                  onRemove: () => _removeProfilePhoto(context, userProvider),
                ),
              ],
            ),
          ),
          const SizedBox(height: 20),
          Text(
            l10n.t('profile.exercise_totals_title'),
            style: theme.textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            l10n.t('profile.exercise_totals_subtitle'),
            style: theme.textTheme.bodySmall?.copyWith(
              color: theme.colorScheme.onSurface.withOpacity(0.6),
            ),
          ),
          const SizedBox(height: 12),
          if (exerciseProvider.isLoading)
            const Center(child: CircularProgressIndicator())
          else if (exercises.isEmpty)
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 12),
              child: Text(
                l10n.t('profile.exercise_empty'),
                style: const TextStyle(color: Colors.grey),
              ),
            )
          else
            ListView.separated(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: exercises.length,
              separatorBuilder: (_, __) => const SizedBox(height: 8),
              itemBuilder: (context, index) {
                final exercise = exercises[index];
                return Card(
                  child: ListTile(
                    title: Text(exercise.name),
                    trailing: Column(
                      mainAxisSize: MainAxisSize.min,
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        Text(
                          '${exercise.totalReps}',
                          style: const TextStyle(
                            fontWeight: FontWeight.w700,
                            fontSize: 16,
                          ),
                        ),
                        Text(
                          l10n.t('exercise.card.total_reps'),
                          style: theme.textTheme.bodySmall?.copyWith(
                            color: theme.colorScheme.onSurface.withOpacity(0.6),
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
          const SizedBox(height: 20),
          Text(
            l10n.t('profile.badges_title'),
            style: theme.textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 12),
          if (unlockedBadges.isEmpty)
            Text(
              l10n.t('profile.badges_empty'),
              style: const TextStyle(color: Colors.grey),
            )
          else
            Wrap(
              spacing: 10,
              runSpacing: 10,
              children: unlockedBadges.map((badge) {
                return _BadgeChip(badge: badge);
              }).toList(),
            ),
          if (unlockedBadges.isNotEmpty) ...[
            const SizedBox(height: 8),
            Text(
              hasBadgePosterSaveFailure
                  ? l10n.t('badges.poster_save_failed_note')
                  : l10n.t(
                      'profile.badge_gallery_saved_note',
                      params: {'album': userProvider.badgePosterAlbumName},
                    ),
              style: theme.textTheme.bodySmall?.copyWith(
                color: theme.colorScheme.onSurface.withOpacity(0.7),
              ),
            ),
          ],
        ],
      ),
    );
  }

  String _formatRelativeDate(DateTime date, AppLocalizations l10n) {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final target = DateTime(date.year, date.month, date.day);
    final diff = today.difference(target).inDays;
    if (diff <= 0) {
      return l10n.t('exercise.time.today');
    }
    if (diff == 1) {
      return l10n.t('exercise.time.yesterday');
    }
    if (diff < 7) {
      return l10n.t('exercise.time.days_ago', params: {'value': '$diff'});
    }
    if (diff < 30) {
      final weeks = (diff / 7).floor();
      return l10n.t('exercise.time.weeks_ago', params: {'value': '$weeks'});
    }
    final months = (diff / 30).floor();
    return l10n.t('exercise.time.months_ago', params: {'value': '$months'});
  }

  String _initialsFromName(String name) {
    final cleaned = name.trim();
    if (cleaned.isEmpty) {
      return '?';
    }
    final parts = cleaned.split(RegExp(r'\\s+'));
    if (parts.length == 1) {
      return parts.first.characters.first.toUpperCase();
    }
    final first = parts.first.characters.first.toUpperCase();
    final last = parts.last.characters.first.toUpperCase();
    return '$first$last';
  }

  Future<void> _showEditNameDialog(
    BuildContext context,
    UserProvider userProvider,
  ) async {
    final l10n = context.l10n;
    final controller = TextEditingController(text: userProvider.userName);
    final result = await showDialog<String>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(l10n.t('profile.user_name_label')),
        content: TextField(
          controller: controller,
          maxLength: 40,
          keyboardType: TextInputType.text,
          inputFormatters: [
            FilteringTextInputFormatter.deny(RegExp(r'[\n\r]')),
          ],
          decoration: InputDecoration(
            hintText: l10n.t('profile.name_hint'),
          ),
          textInputAction: TextInputAction.done,
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(l10n.t('common.cancel')),
          ),
          FilledButton(
            onPressed: () {
              final name = controller.text.trim();
              if (name.isEmpty) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text(l10n.t('onboarding.name_required')),
                  ),
                );
                return;
              }
              Navigator.pop(context, name);
            },
            child: Text(l10n.t('profile.save_name')),
          ),
        ],
      ),
    );
    if (result != null && result.trim().isNotEmpty) {
      await userProvider.setUserName(result.trim());
    }
  }

  Future<void> _pickProfilePhoto(
    BuildContext context,
    UserProvider userProvider,
  ) async {
    final l10n = context.l10n;
    final picker = ImagePicker();
    XFile? picked;

    try {
      picked = await picker.pickImage(
        source: ImageSource.gallery,
        maxWidth: 2000,
        maxHeight: 3000,
        imageQuality: 92,
      );
    } catch (_) {
      if (!context.mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(l10n.t('profile.photo_error'))),
      );
      return;
    }

    if (picked == null) {
      return;
    }

    if (!context.mounted) return;
    final status = await userProvider.updateProfilePhoto(picked);
    if (!context.mounted) return;

    if (status == ProfilePhotoSaveStatus.success) {
      return;
    }
    if (status == ProfilePhotoSaveStatus.tooLarge) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(l10n.t('profile.photo_too_large'))),
      );
      return;
    }
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(l10n.t('profile.photo_error'))),
    );
  }

  Future<void> _removeProfilePhoto(
    BuildContext context,
    UserProvider userProvider,
  ) async {
    final l10n = context.l10n;
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(l10n.t('profile.photo_remove')),
        content: Text(l10n.t('profile.photo_remove_confirm')),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: Text(l10n.t('common.cancel')),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(context, true),
            child: Text(l10n.t('common.ok')),
          ),
        ],
      ),
    );
    if (confirm != true) return;
    await userProvider.removeProfilePhoto();
  }

}

class _ProfilePhotoSection extends StatelessWidget {
  final String? photoPath;
  final VoidCallback onPick;
  final VoidCallback onRemove;

  const _ProfilePhotoSection({
    required this.photoPath,
    required this.onPick,
    required this.onRemove,
  });

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final theme = Theme.of(context);
    final hasPhoto = photoPath != null && photoPath!.trim().isNotEmpty;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          l10n.t('profile.photo_title'),
          style: theme.textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.w700,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          l10n.t('profile.photo_subtitle'),
          style: theme.textTheme.bodySmall?.copyWith(
            color: theme.colorScheme.onSurface.withOpacity(0.6),
          ),
        ),
        const SizedBox(height: 10),
        ClipRRect(
          borderRadius: BorderRadius.circular(16),
          child: Container(
            decoration: BoxDecoration(
              border: Border.all(
                color: theme.colorScheme.primary.withOpacity(0.2),
              ),
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [
                  theme.colorScheme.primary.withOpacity(0.08),
                  theme.colorScheme.secondary.withOpacity(0.06),
                ],
              ),
            ),
            child: AspectRatio(
              aspectRatio: 3 / 4,
              child: Stack(
                fit: StackFit.expand,
                children: [
                  if (hasPhoto)
                    Image.file(
                      File(photoPath!),
                      fit: BoxFit.cover,
                      errorBuilder: (context, error, _) {
                        return _ProfilePhotoPlaceholder(
                          accentColor: theme.colorScheme.primary,
                        );
                      },
                    )
                  else
                    _ProfilePhotoPlaceholder(
                      accentColor: theme.colorScheme.primary,
                    ),
                  Positioned(
                    right: 12,
                    bottom: 12,
                    child: FilledButton.icon(
                      onPressed: onPick,
                      icon: const Icon(Icons.photo_camera_outlined, size: 18),
                      label: Text(
                        hasPhoto
                            ? l10n.t('profile.photo_change')
                            : l10n.t('profile.photo_add'),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
        if (hasPhoto) ...[
          const SizedBox(height: 8),
          TextButton.icon(
            onPressed: onRemove,
            icon: const Icon(Icons.delete_outline, size: 18),
            label: Text(l10n.t('profile.photo_remove')),
          ),
        ] else ...[
          const SizedBox(height: 8),
          Text(
            l10n.t('profile.photo_badge_notice'),
            style: theme.textTheme.bodySmall?.copyWith(
              color: theme.colorScheme.onSurface.withOpacity(0.66),
              fontStyle: FontStyle.italic,
            ),
          ),
        ],
      ],
    );
  }
}

class _ProfilePhotoPlaceholder extends StatelessWidget {
  final Color accentColor;

  const _ProfilePhotoPlaceholder({required this.accentColor});

  @override
  Widget build(BuildContext context) {
    return Container(
      color: Colors.black.withOpacity(0.05),
      child: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              Icons.person_outline,
              size: 48,
              color: accentColor.withOpacity(0.6),
            ),
            const SizedBox(height: 8),
            Text(
              context.l10n.t('profile.photo_add'),
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: accentColor.withOpacity(0.7),
                  ),
            ),
          ],
        ),
      ),
    );
  }
}

class _BadgeChip extends StatelessWidget {
  final BadgeAchievement badge;

  const _BadgeChip({required this.badge});

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final theme = Theme.of(context);
    final color = _tierColor(badge.tier.name);
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
      decoration: BoxDecoration(
        color: color.withOpacity(0.12),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: color.withOpacity(0.4)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (badge.iconPath.isNotEmpty)
            Image.asset(
              badge.iconPath,
              width: 22,
              height: 22,
              errorBuilder: (_, __, ___) => Icon(
                Icons.emoji_events_rounded,
                color: color,
                size: 20,
              ),
            )
          else
            Icon(
              Icons.emoji_events_rounded,
              color: color,
              size: 20,
            ),
          const SizedBox(width: 8),
          Text(
            BadgeTextLocalizer.localizedName(l10n, badge),
            style: theme.textTheme.bodySmall?.copyWith(
              fontWeight: FontWeight.w600,
              color: theme.colorScheme.onSurface,
            ),
          ),
        ],
      ),
    );
  }

  Color _tierColor(String tier) {
    switch (tier.toLowerCase()) {
      case 'bronze':
        return const Color(0xFFCD7F32);
      case 'silver':
        return const Color(0xFFC0C0C0);
      case 'gold':
        return const Color(0xFFFFD700);
      case 'platinum':
        return const Color(0xFFE5E4E2);
      default:
        return const Color(0xFF60A5FA);
    }
  }
}

class ShortsPlayerScreen extends StatefulWidget {
  final List<RecordedVideoInfo> recordings;
  final int initialIndex;

  const ShortsPlayerScreen({
    super.key,
    required this.recordings,
    required this.initialIndex,
  });

  @override
  State<ShortsPlayerScreen> createState() => _ShortsPlayerScreenState();
}

class _ShortsPlayerScreenState extends State<ShortsPlayerScreen> {
  // Keep decoder usage low to avoid jank/force-stop on repeated scrolling.
  static const int _maxKeptControllers = 3;
  late final PageController _pageController;
  final Map<int, _ControllerEntry> _controllers = {};
  int _currentIndex = 0;
  bool _isDisposed = false;

  @override
  void initState() {
    super.initState();
    _currentIndex = widget.initialIndex;
    _pageController = PageController(initialPage: _currentIndex);
    // Initialize current video first to reduce startup stutter.
    _initController(_currentIndex);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Future<void>.delayed(const Duration(milliseconds: 180), () {
        if (!mounted || _isDisposed) return;
        _prepareAround(
          _currentIndex,
          extraKeepIndices: {_currentIndex - 1, _currentIndex + 1},
        );
        _syncPlaybackForActiveIndex(_currentIndex);
      });
    });
  }

  @override
  void dispose() {
    _isDisposed = true;
    for (final entry in _controllers.values) {
      entry.controller.dispose();
    }
    _controllers.clear();
    _pageController.dispose();
    super.dispose();
  }

  void _prepareAround(int index, {Set<int> extraKeepIndices = const {}}) {
    _initController(index);
    for (final keepIndex in extraKeepIndices) {
      _initController(keepIndex);
    }
    _disposeFar(index, extraKeepIndices: extraKeepIndices);
    _trimControllerPool(index, extraKeepIndices: extraKeepIndices);
    if (mounted) {
      setState(() {});
    }
  }

  void _initController(int index) {
    if (index < 0 || index >= widget.recordings.length) return;
    if (_controllers.containsKey(index)) return;
    final file = widget.recordings[index].file;
    try {
      if (!file.existsSync()) return;
    } catch (_) {
      return;
    }
    final controller = VideoPlayerController.file(file);
    final initFuture = () async {
      try {
        await controller.initialize();
      } catch (_) {
        if (_controllers[index]?.controller == controller) {
          _controllers.remove(index);
        }
        controller.dispose();
        return;
      }

      if (!mounted) return;
      if (_controllers[index]?.controller != controller) return;
      try {
        await controller.setLooping(true);
        await controller.setVolume(index == _currentIndex ? 1.0 : 0.0);
      } catch (_) {
        return;
      }
      if (_currentIndex == index) {
        try {
          await controller.play();
        } catch (_) {
          return;
        }
      }
    }();
    _controllers[index] = _ControllerEntry(
      controller: controller,
      initialized: initFuture,
    );
  }

  void _disposeFar(int index, {Set<int> extraKeepIndices = const {}}) {
    final keysToRemove = _controllers.keys
        .where((k) => k != index && !extraKeepIndices.contains(k))
        .toList();
    for (final key in keysToRemove) {
      _controllers[key]?.controller.dispose();
      _controllers.remove(key);
    }
  }

  void _trimControllerPool(int index, {Set<int> extraKeepIndices = const {}}) {
    if (_controllers.length <= _maxKeptControllers) return;
    final entries = _controllers.entries.toList()
      ..sort((a, b) {
        int score(MapEntry<int, _ControllerEntry> e) {
          if (e.key == index) return -1000;
          if (extraKeepIndices.contains(e.key)) return -500;
          return (e.key - index).abs();
        }

        return score(b).compareTo(score(a));
      });

    while (_controllers.length > _maxKeptControllers && entries.isNotEmpty) {
      final toDispose = entries.removeAt(0).key;
      if (toDispose == index || extraKeepIndices.contains(toDispose)) continue;
      _controllers[toDispose]?.controller.dispose();
      _controllers.remove(toDispose);
    }
  }

  void _syncPlaybackForActiveIndex(int activeIndex) {
    for (final entry in _controllers.entries) {
      final controller = entry.value.controller;
      if (!controller.value.isInitialized) continue;

      if (entry.key == activeIndex) {
        controller.setVolume(1.0).catchError((_) {});
        if (!controller.value.isPlaying) {
          controller.play().catchError((_) {});
        }
      } else {
        controller.setVolume(0.0).catchError((_) {});
        if (controller.value.isPlaying) {
          controller.pause().catchError((_) {});
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final mediaPadding = MediaQuery.of(context).padding;
    return Scaffold(
      backgroundColor: Colors.black,
      body: Stack(
        children: [
          PageView.builder(
            scrollDirection: Axis.vertical,
            controller: _pageController,
            allowImplicitScrolling: false,
            itemCount: widget.recordings.length,
            onPageChanged: (index) {
              _currentIndex = index;
              _prepareAround(
                index,
                extraKeepIndices: {index - 1, index + 1},
              );
              _syncPlaybackForActiveIndex(index);
            },
            itemBuilder: (context, index) {
              final recording = widget.recordings[index];
              final activeEntry = _controllers[index];
              if (activeEntry == null) {
                return const Center(child: CircularProgressIndicator());
              }

              return FutureBuilder<void>(
                future: activeEntry.initialized,
                builder: (context, snapshot) {
                  if (snapshot.connectionState != ConnectionState.done) {
                    return const Center(child: CircularProgressIndicator());
                  }
                  if (snapshot.hasError ||
                      !activeEntry.controller.value.isInitialized) {
                    return Center(
                      child: Text(
                        l10n.t('recordings.failed_load'),
                        style: const TextStyle(color: Colors.white),
                      ),
                    );
                  }
                  try {
                    if (!recording.file.existsSync()) {
                      return Center(
                        child: Text(
                          l10n.t('recordings.file_not_found'),
                          style: const TextStyle(color: Colors.white),
                        ),
                      );
                    }
                  } catch (_) {
                    return Center(
                      child: Text(
                        l10n.t('recordings.failed_load'),
                        style: const TextStyle(color: Colors.white),
                      ),
                    );
                  }
                  final videoValue = activeEntry.controller.value;
                  final size = videoValue.size;
                  if (size.width <= 0 || size.height <= 0) {
                    return Center(
                      child: Text(
                        l10n.t('recordings.failed_load'),
                        style: const TextStyle(color: Colors.white),
                      ),
                    );
                  }

                  final isQuarterTurn =
                      (videoValue.rotationCorrection ~/ 90).abs().isOdd;
                  final displayWidth = isQuarterTurn ? size.height : size.width;
                  final displayHeight =
                      isQuarterTurn ? size.width : size.height;
                  return GestureDetector(
                    behavior: HitTestBehavior.opaque,
                    onTap: () {
                      final controller = activeEntry.controller;
                      if (!controller.value.isInitialized) return;
                      if (controller.value.isPlaying) {
                        controller.pause();
                      } else {
                        controller.play();
                      }
                    },
                    child: Stack(
                      children: [
                        Positioned.fill(
                          child: ColoredBox(
                            color: Colors.black,
                            child: Center(
                              child: FittedBox(
                                fit: BoxFit.cover,
                                alignment: Alignment.center,
                                child: SizedBox(
                                  width: displayWidth,
                                  height: displayHeight,
                                  child: VideoPlayer(activeEntry.controller),
                                ),
                              ),
                            ),
                          ),
                        ),
                        Positioned(
                          right: 16,
                          bottom: mediaPadding.bottom + 24,
                          child: ValueListenableBuilder<VideoPlayerValue>(
                            valueListenable: activeEntry.controller,
                            builder: (context, value, _) {
                              return Icon(
                                value.isPlaying
                                    ? Icons.pause_circle
                                    : Icons.play_circle,
                                color: Colors.white70,
                                size: 40,
                              );
                            },
                          ),
                        ),
                        Positioned(
                          left: 16,
                          right: 16,
                          bottom: mediaPadding.bottom + 24,
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              _SeekButton(
                                icon: Icons.replay_10,
                                onPressed: () => _seekBySeconds(
                                  activeEntry.controller,
                                  -10,
                                ),
                              ),
                              _SeekButton(
                                icon: Icons.forward_10,
                                onPressed: () => _seekBySeconds(
                                  activeEntry.controller,
                                  10,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  );
                },
              );
            },
          ),
          Positioned(
            top: mediaPadding.top + 8,
            left: 8,
            child: Material(
              color: Colors.black54,
              shape: const CircleBorder(),
              child: IconButton(
                icon: const Icon(Icons.arrow_back, color: Colors.white),
                onPressed: () => Navigator.of(context).maybePop(),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _seekBySeconds(
    VideoPlayerController controller,
    int deltaSeconds,
  ) async {
    if (!controller.value.isInitialized) return;
    final current = controller.value.position;
    final duration = controller.value.duration;
    if (duration == Duration.zero) return;
    final targetSeconds =
        (current.inSeconds + deltaSeconds).clamp(0, duration.inSeconds);
    await controller.seekTo(Duration(seconds: targetSeconds));
  }
}

class _ControllerEntry {
  final VideoPlayerController controller;
  final Future<void> initialized;

  _ControllerEntry({
    required this.controller,
    required this.initialized,
  });
}

class _SeekButton extends StatelessWidget {
  final IconData icon;
  final VoidCallback onPressed;

  const _SeekButton({
    required this.icon,
    required this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.black54,
      shape: const CircleBorder(),
      child: IconButton(
        icon: Icon(icon, color: Colors.white),
        onPressed: onPressed,
      ),
    );
  }
}

class _RecordingThumbnail extends StatelessWidget {
  const _RecordingThumbnail();

  @override
  Widget build(BuildContext context) {
    return const SizedBox(
      width: 64,
      height: 48,
      child: DecoratedBox(
        decoration: BoxDecoration(color: Color(0xFF1E1E1E)),
        child: Icon(Icons.videocam, color: Colors.white70),
      ),
    );
  }
}
