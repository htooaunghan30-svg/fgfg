import '../../data/models/badge_achievement.dart';
import 'app_localizations.dart';

class BadgeTextLocalizer {
  static String localizedName(AppLocalizations l10n, BadgeAchievement badge) {
    switch (badge.badgeId) {
      case 'first_workout':
        return l10n.t('badge.first_workout.name');
      case 'prep_phase_15_v2':
        return l10n.t('badge.prep.name');
      case 'month_1_bronze':
        return l10n.t('badge.bronze.name');
      case 'month_2_silver':
        return l10n.t('badge.silver.name');
      case 'month_3_gold':
        return l10n.t('badge.gold.name');
      default:
        return badge.name;
    }
  }

  static String localizedNarrative(
    AppLocalizations l10n,
    BadgeAchievement badge,
  ) {
    switch (badge.badgeId) {
      case 'first_workout':
        return l10n.t('badge.first_workout.narrative');
      case 'prep_phase_15_v2':
        return l10n.t('badge.prep.narrative');
      case 'month_1_bronze':
        return l10n.t('badge.bronze.narrative');
      case 'month_2_silver':
        return l10n.t('badge.silver.narrative');
      case 'month_3_gold':
        return l10n.t('badge.gold.narrative');
      default:
        return badge.description;
    }
  }

  static List<String> localizedPlanDetails(
    AppLocalizations l10n,
    BadgeAchievement badge,
  ) {
    switch (badge.badgeId) {
      case 'first_workout':
        return [
          l10n.t('badge.first_workout.detail1'),
          l10n.t('badge.first_workout.detail2'),
          l10n.t('badge.first_workout.detail3'),
          l10n.t('badge.first_workout.detail4'),
        ];
      case 'prep_phase_15_v2':
        return [
          l10n.t('badge.prep.detail1'),
          l10n.t('badge.prep.detail2'),
          l10n.t('badge.prep.detail3'),
          l10n.t('badge.prep.detail4'),
          l10n.t('badge.prep.detail5'),
          l10n.t('badge.prep.detail6'),
          l10n.t('badge.prep.detail7'),
          l10n.t('badge.prep.detail8'),
        ];
      case 'month_1_bronze':
        return [
          l10n.t('badge.bronze.detail1'),
          l10n.t('badge.bronze.detail2'),
          l10n.t('badge.bronze.detail3'),
          l10n.t('badge.bronze.detail4'),
          l10n.t('badge.bronze.detail5'),
          l10n.t('badge.bronze.detail6'),
        ];
      case 'month_2_silver':
        return [
          l10n.t('badge.silver.detail1'),
          l10n.t('badge.silver.detail2'),
          l10n.t('badge.silver.detail3'),
          l10n.t('badge.silver.detail4'),
          l10n.t('badge.silver.detail5'),
          l10n.t('badge.silver.detail6'),
        ];
      case 'month_3_gold':
        return [
          l10n.t('badge.gold.detail1'),
          l10n.t('badge.gold.detail2'),
          l10n.t('badge.gold.detail3'),
          l10n.t('badge.gold.detail4'),
          l10n.t('badge.gold.detail5'),
          l10n.t('badge.gold.detail6'),
        ];
      default:
        return [
          l10n.t(
            'badge.default.goal',
            params: {'description': badge.description},
          ),
          l10n.t(
            'badge.default.requirement',
            params: {'requirement': '${badge.requirement}'},
          ),
          l10n.t(
            'badge.default.status',
            params: {
              'progress': '${badge.progress}',
              'requirement': '${badge.requirement}',
            },
          ),
        ];
    }
  }

  static String tierLabel(AppLocalizations l10n, BadgeAchievement badge) {
    switch (badge.tier.name.toLowerCase()) {
      case 'bronze':
        return l10n.t('tier.bronze');
      case 'silver':
        return l10n.t('tier.silver');
      case 'gold':
        return l10n.t('tier.gold');
      case 'platinum':
        return l10n.t('tier.platinum');
      default:
        return badge.tier.name;
    }
  }
}
