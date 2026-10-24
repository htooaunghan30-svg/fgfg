// lib/presentation/widgets/exercise_card.dart
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../data/models/exercise_model.dart';
import '../providers/exercise_provider.dart';
import '../../core/localization/app_localizations.dart';
import '../../core/themes/color_scheme.dart';

class ExerciseCard extends StatelessWidget {
  final ExerciseModel exercise;
  final bool isFavorite;
  final VoidCallback onTap;
  final VoidCallback? onFavoriteToggle;
  final bool showStats;

  const ExerciseCard({
    super.key,
    required this.exercise,
    this.isFavorite = false,
    required this.onTap,
    this.onFavoriteToggle,
    this.showStats = true,
  });

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header Row
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  // Exercise Name
                  Expanded(
                    child: Text(
                      exercise.name,
                      style: Theme.of(context).textTheme.titleLarge?.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),

                  // Favorite Button
                  if (onFavoriteToggle != null)
                    IconButton(
                      onPressed: onFavoriteToggle,
                      icon: Icon(
                        isFavorite ? Icons.favorite : Icons.favorite_border,
                        color: isFavorite ? Colors.red : Colors.grey,
                      ),
                    ),
                ],
              ),

              const SizedBox(height: 8),

              // Type + View badges aligned to card width
              Row(
                children: [
                  Flexible(
                    fit: FlexFit.loose,
                    child: Align(
                      alignment: Alignment.centerLeft,
                      child: _buildBadge(
                        context,
                        exercise.type == 'dynamic'
                            ? l10n.t('exercise.card.type.dynamic')
                            : l10n.t('exercise.card.type.static'),
                        exercise.type == 'dynamic'
                            ? Colors.blue
                            : Colors.purple,
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Flexible(
                    fit: FlexFit.loose,
                    child: Align(
                      alignment: Alignment.centerRight,
                      child: _buildBadge(
                        context,
                        exercise.viewRequired == 'side'
                            ? l10n.t('exercise.card.view.side')
                            : l10n.t('exercise.card.view.front'),
                        exercise.viewRequired == 'side'
                            ? Colors.green
                            : Colors.orange,
                      ),
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 16),

              // Stats Row
              if (showStats) _buildStatsRow(context),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildBadge(BuildContext context, String text, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withOpacity(0.3)),
      ),
      child: Text(
        text,
        style: Theme.of(context).textTheme.labelSmall?.copyWith(
              color: color,
              fontWeight: FontWeight.w600,
            ),
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
      ),
    );
  }

  Widget _buildStatsRow(BuildContext context) {
    final l10n = context.l10n;
    return Row(
      children: [
        Expanded(
          child: _buildStatItem(
            context,
            '${exercise.totalReps}',
            l10n.t('exercise.card.total_reps'),
            Icons.repeat,
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: _buildStatItem(
            context,
            '${(exercise.averageAccuracy * 100).toStringAsFixed(1)}%',
            l10n.t('exercise.card.avg_accuracy'),
            Icons.assessment,
          ),
        ),
      ],
    );
  }

  Widget _buildStatItem(
    BuildContext context,
    String value,
    String label,
    IconData icon,
  ) {
    return Column(
      children: [
        FittedBox(
          fit: BoxFit.scaleDown,
          child: Row(
            children: [
              Icon(
                icon,
                size: 16,
                color: AppColorScheme.secondary,
              ),
              const SizedBox(width: 4),
              Text(
                value,
                style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 2),
        Text(
          label,
          style: Theme.of(context).textTheme.labelSmall?.copyWith(
                color: AppColorScheme.textSecondary,
              ),
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          textAlign: TextAlign.center,
        ),
      ],
    );
  }


}

class ExerciseGrid extends StatelessWidget {
  final List<ExerciseModel> exercises;
  final List<String> favoriteExercises;
  final Function(String) onExerciseTap;
  final Function(String)? onFavoriteToggle;

  const ExerciseGrid({
    super.key,
    required this.exercises,
    required this.favoriteExercises,
    required this.onExerciseTap,
    this.onFavoriteToggle,
  });

  @override
  Widget build(BuildContext context) {
    return GridView.builder(
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        crossAxisSpacing: 12,
        mainAxisSpacing: 12,
        childAspectRatio: 0.8,
      ),
      padding: const EdgeInsets.all(16),
      itemCount: exercises.length,
      itemBuilder: (context, index) {
        final exercise = exercises[index];
        final isFavorite = favoriteExercises.contains(exercise.exerciseId);

        return ExerciseCard(
          exercise: exercise,
          isFavorite: isFavorite,
          onTap: () => onExerciseTap(exercise.exerciseId),
          onFavoriteToggle: onFavoriteToggle != null
              ? () => onFavoriteToggle!(exercise.exerciseId)
              : null,
        );
      },
    );
  }
}

class ExerciseListView extends StatelessWidget {
  final List<ExerciseModel> exercises;
  final List<String> favoriteExercises;
  final Function(String) onExerciseTap;
  final Function(String)? onFavoriteToggle;

  const ExerciseListView({
    super.key,
    required this.exercises,
    required this.favoriteExercises,
    required this.onExerciseTap,
    this.onFavoriteToggle,
  });

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: exercises.length,
      itemBuilder: (context, index) {
        final exercise = exercises[index];
        final isFavorite = favoriteExercises.contains(exercise.exerciseId);

        return Padding(
          padding: const EdgeInsets.only(bottom: 12),
          child: ExerciseCard(
            exercise: exercise,
            isFavorite: isFavorite,
            onTap: () => onExerciseTap(exercise.exerciseId),
            onFavoriteToggle: onFavoriteToggle != null
                ? () => onFavoriteToggle!(exercise.exerciseId)
                : null,
          ),
        );
      },
    );
  }
}

// ============ ADD EXERCISE SELECTION BUTTONS ============
class ExerciseSelectionButtons extends StatelessWidget {
  final List<ExerciseModel> exercises;
  final Function(String) onExerciseSelected;

  const ExerciseSelectionButtons({
    super.key,
    required this.exercises,
    required this.onExerciseSelected,
  });

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            l10n.t('exercise.card.select'),
            style: const TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 16),
          Wrap(
            spacing: 12,
            runSpacing: 12,
            children: exercises.map((exercise) {
              return _buildExerciseButton(exercise, context);
            }).toList(),
          ),
        ],
      ),
    );
  }

  Widget _buildExerciseButton(ExerciseModel exercise, BuildContext context) {
    return ElevatedButton(
      onPressed: () => onExerciseSelected(exercise.exerciseId),
      style: ElevatedButton.styleFrom(
        backgroundColor: _getExerciseColor(exercise.exerciseId),
        foregroundColor: Colors.white,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            _getExerciseIcon(exercise.exerciseId),
            size: 28,
          ),
          const SizedBox(height: 8),
          Text(
            exercise.name,
            style: const TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }

  IconData _getExerciseIcon(String exerciseId) {
    switch (exerciseId) {
      case 'squat':
        return Icons.arrow_upward;
      case 'pushup':
        return Icons.touch_app;
      case 'bicep_curl':
        return Icons.fitness_center;
      case 'shoulder_press':
        return Icons.arrow_upward;
      case 'bench_press':
        return Icons.fitness_center;
      case 'lateral_raise':
        return Icons.accessibility_new;
      case 'front_raise':
        return Icons.accessibility_new;
      case 'situp':
        return Icons.arrow_upward;
      case 'leg_extension':
        return Icons.directions_run;
      default:
        return Icons.fitness_center;
    }
  }

  Color _getExerciseColor(String exerciseId) {
    switch (exerciseId) {
      case 'squat':
        return Colors.blue;
      case 'pushup':
        return Colors.red;
      case 'bicep_curl':
        return Colors.green;
      case 'shoulder_press':
        return Colors.orange;
      case 'bench_press':
        return Colors.indigo;
      case 'lateral_raise':
        return Colors.pink;
      case 'front_raise':
        return Colors.deepOrange;
      case 'situp':
        return Colors.purple;
      case 'leg_extension':
        return Colors.teal;
      default:
        return AppColorScheme.primary;
    }
  }
}
