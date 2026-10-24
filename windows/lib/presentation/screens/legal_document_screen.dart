import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../core/localization/app_localizations.dart';
import '../providers/user_provider.dart';

enum LegalDocumentType {
  privacyPolicy,
  termsOfService,
  disclaimer,
}

class LegalDocumentScreen extends StatelessWidget {
  const LegalDocumentScreen({
    super.key,
    required this.type,
  });

  final LegalDocumentType type;

  static const String _lastUpdatedDate = '2026-02-23';

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final theme = Theme.of(context);
    final userProvider = context.watch<UserProvider>();
    final acceptedAt = _acceptedAt(userProvider);

    return Scaffold(
      appBar: AppBar(
        title: Text(_title(l10n)),
      ),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.fromLTRB(16, 16, 16, 24),
          children: [
            if (acceptedAt != null)
              Container(
                margin: const EdgeInsets.only(bottom: 16),
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: theme.colorScheme.surface.withOpacity(0.65),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  l10n.t(
                    'legal.accepted_notice',
                    params: {'date': _formatDate(acceptedAt)},
                  ),
                  style: theme.textTheme.bodySmall?.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            Text(
              _title(l10n),
              style: theme.textTheme.headlineSmall?.copyWith(
                fontWeight: FontWeight.w700,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              l10n.t(
                'legal.last_updated',
                params: {'date': _lastUpdatedDate},
              ),
              style: theme.textTheme.bodySmall?.copyWith(
                color: theme.textTheme.bodySmall?.color?.withOpacity(0.75),
              ),
            ),
            const SizedBox(height: 16),
            SelectableText(
              l10n.t(_contentKey()),
              style: theme.textTheme.bodyMedium?.copyWith(height: 1.55),
            ),
          ],
        ),
      ),
    );
  }

  String _title(AppLocalizations l10n) {
    switch (type) {
      case LegalDocumentType.privacyPolicy:
        return l10n.t('settings.privacy_policy');
      case LegalDocumentType.termsOfService:
        return l10n.t('settings.terms');
      case LegalDocumentType.disclaimer:
        return l10n.t('settings.disclaimer');
    }
  }

  String _contentKey() {
    switch (type) {
      case LegalDocumentType.privacyPolicy:
        return 'legal.privacy.content';
      case LegalDocumentType.termsOfService:
        return 'legal.terms.content';
      case LegalDocumentType.disclaimer:
        return 'legal.disclaimer.content';
    }
  }

  DateTime? _acceptedAt(UserProvider userProvider) {
    switch (type) {
      case LegalDocumentType.termsOfService:
        return userProvider.termsAcceptedAt;
      case LegalDocumentType.disclaimer:
        return userProvider.disclaimerAcceptedAt;
      case LegalDocumentType.privacyPolicy:
        return null;
    }
  }

  String _formatDate(DateTime dateTime) {
    final local = dateTime.toLocal();
    final year = local.year.toString().padLeft(4, '0');
    final month = local.month.toString().padLeft(2, '0');
    final day = local.day.toString().padLeft(2, '0');
    return '$year-$month-$day';
  }
}
