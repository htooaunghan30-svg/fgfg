import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';

import '../../core/localization/app_localizations.dart';
import '../providers/user_provider.dart';

class OnboardingFlowScreen extends StatefulWidget {
  const OnboardingFlowScreen({super.key});

  @override
  State<OnboardingFlowScreen> createState() => _OnboardingFlowScreenState();
}

class _OnboardingFlowScreenState extends State<OnboardingFlowScreen> {
  int _step = 0;
  bool _initialized = false;
  String? _selectedLanguage;
  final TextEditingController _nameController = TextEditingController();
  String? _nameError;
  bool _disclaimerChecked = false;
  bool _termsChecked = false;

  @override
  void dispose() {
    _nameController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final userProvider = context.watch<UserProvider>();
    final l10n = context.l10n;
    if (userProvider.isLoading) {
      return const Scaffold(
        body: Center(
          child: CircularProgressIndicator(),
        ),
      );
    }
    if (!_initialized) {
      _selectedLanguage = userProvider.appLanguage;
      _nameController.text = userProvider.userName;
      _disclaimerChecked = userProvider.disclaimerAccepted;
      _termsChecked = userProvider.termsAccepted;
      if (!userProvider.appLanguageSelected) {
        _step = 0;
      } else if (userProvider.userName.trim().isEmpty) {
        _step = 1;
      } else if (!userProvider.disclaimerAccepted) {
        _step = 2;
      } else if (!userProvider.termsAccepted) {
        _step = 3;
      } else {
        _step = 3;
      }
      _initialized = true;
    }
    return PopScope(
      canPop: false,
      child: Scaffold(
        body: SafeArea(
          child: AnimatedSwitcher(
            duration: const Duration(milliseconds: 220),
            child: _step == 0
                ? _buildLanguageStep(l10n)
                : _step == 1
                    ? _buildNameStep(l10n)
                    : _step == 2
                        ? _buildLegalStep(
                            title: l10n.t('onboarding.disclaimer_title'),
                            contentKey: 'legal.disclaimer.content',
                            isChecked: _disclaimerChecked,
                            onChecked: (value) {
                              setState(
                                  () => _disclaimerChecked = value ?? false);
                            },
                            onContinue: _handleDisclaimerContinue,
                            buttonLabel: l10n.t('onboarding.continue'),
                          )
                        : _buildLegalStep(
                            title: l10n.t('onboarding.terms_title'),
                            contentKey: 'legal.terms.content',
                            isChecked: _termsChecked,
                            onChecked: (value) {
                              setState(() => _termsChecked = value ?? false);
                            },
                            onContinue: _handleTermsContinue,
                            buttonLabel: l10n.t('onboarding.start_app'),
                          ),
          ),
        ),
      ),
    );
  }

  Widget _buildLanguageStep(AppLocalizations l10n) {
    final options = _languageOptions;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(20, 16, 20, 8),
          child: Text(
            l10n.t('onboarding.language_title'),
            style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                  fontWeight: FontWeight.w700,
                ),
          ),
        ),
        Padding(
          padding: const EdgeInsets.fromLTRB(20, 0, 20, 16),
          child: Text(
            l10n.t('onboarding.language_subtitle'),
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: Theme.of(context)
                      .textTheme
                      .bodyMedium
                      ?.color
                      ?.withOpacity(0.7),
                ),
          ),
        ),
        Expanded(
          child: ListView.separated(
            padding: const EdgeInsets.symmetric(horizontal: 12),
            itemBuilder: (context, index) {
              final option = options[index];
              return RadioListTile<String>(
                value: option.code,
                groupValue: _selectedLanguage,
                onChanged: (value) {
                  setState(() => _selectedLanguage = value);
                },
                title: Text(option.label),
                subtitle: Text(option.code.toUpperCase()),
              );
            },
            separatorBuilder: (_, __) => const Divider(height: 1),
            itemCount: options.length,
          ),
        ),
        Padding(
          padding: const EdgeInsets.fromLTRB(20, 12, 20, 20),
          child: SizedBox(
            width: double.infinity,
            child: FilledButton(
              onPressed:
                  _selectedLanguage == null ? null : _handleLanguageContinue,
              child: Text(l10n.t('onboarding.continue')),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildNameStep(AppLocalizations l10n) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(20, 16, 20, 8),
          child: Text(
            l10n.t('onboarding.name_title'),
            style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                  fontWeight: FontWeight.w700,
                ),
          ),
        ),
        Padding(
          padding: const EdgeInsets.fromLTRB(20, 0, 20, 16),
          child: Text(
            l10n.t('onboarding.name_subtitle'),
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: Theme.of(context)
                      .textTheme
                      .bodyMedium
                      ?.color
                      ?.withOpacity(0.7),
                ),
          ),
        ),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          child: TextField(
            controller: _nameController,
            textInputAction: TextInputAction.done,
            maxLength: 40,
            keyboardType: TextInputType.text,
            inputFormatters: [
              FilteringTextInputFormatter.deny(RegExp(r'[\n\r]')),
            ],
            decoration: InputDecoration(
              hintText: l10n.t('onboarding.name_hint'),
              errorText: _nameError,
              prefixIcon: const Icon(Icons.person_outline),
              border: const OutlineInputBorder(),
            ),
            onChanged: (_) {
              if (_nameError != null) {
                setState(() => _nameError = null);
              }
            },
            onSubmitted: (_) => _handleNameContinue(),
          ),
        ),
        const Spacer(),
        Padding(
          padding: const EdgeInsets.fromLTRB(20, 12, 20, 20),
          child: SizedBox(
            width: double.infinity,
            child: FilledButton(
              onPressed: _handleNameContinue,
              child: Text(l10n.t('onboarding.continue')),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildLegalStep({
    required String title,
    required String contentKey,
    required bool isChecked,
    required ValueChanged<bool?> onChecked,
    required VoidCallback onContinue,
    required String buttonLabel,
  }) {
    final l10n = context.l10n;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(20, 16, 20, 8),
          child: Text(
            title,
            style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                  fontWeight: FontWeight.w700,
                ),
          ),
        ),
        Expanded(
          child: ListView(
            padding: const EdgeInsets.fromLTRB(20, 0, 20, 16),
            children: [
              Text(
                l10n.t(contentKey),
                style: Theme.of(context)
                    .textTheme
                    .bodyMedium
                    ?.copyWith(height: 1.55),
              ),
            ],
          ),
        ),
        Padding(
          padding: const EdgeInsets.fromLTRB(12, 0, 12, 0),
          child: CheckboxListTile(
            value: isChecked,
            onChanged: onChecked,
            title: Text(l10n.t('onboarding.accept_checkbox')),
            subtitle: Text(l10n.t('onboarding.accept_notice')),
            controlAffinity: ListTileControlAffinity.leading,
          ),
        ),
        Padding(
          padding: const EdgeInsets.fromLTRB(20, 8, 20, 20),
          child: SizedBox(
            width: double.infinity,
            child: FilledButton(
              onPressed: isChecked ? onContinue : null,
              child: Text(buttonLabel),
            ),
          ),
        ),
      ],
    );
  }

  List<_LanguageOption> get _languageOptions => const [
        _LanguageOption(code: 'en', label: 'English'),
        _LanguageOption(code: 'my', label: 'မြန်မာ'),
        _LanguageOption(code: 'es', label: 'Español'),
        _LanguageOption(code: 'ja', label: '日本語'),
        _LanguageOption(code: 'hi', label: 'हिन्दी'),
        _LanguageOption(code: 'pt', label: 'Português'),
        _LanguageOption(code: 'zh', label: '中文'),
        _LanguageOption(code: 'de', label: 'Deutsch'),
      ];

  Future<void> _handleLanguageContinue() async {
    final selected = _selectedLanguage;
    if (selected == null) {
      return;
    }
    final userProvider = context.read<UserProvider>();
    await userProvider.setAppLanguage(selected);
    if (mounted) {
      setState(() => _step = 1);
    }
  }

  Future<void> _handleNameContinue() async {
    final l10n = context.l10n;
    final name = _nameController.text.trim();
    if (name.isEmpty) {
      setState(() => _nameError = l10n.t('onboarding.name_required'));
      return;
    }
    final userProvider = context.read<UserProvider>();
    await userProvider.setUserName(name);
    if (mounted) {
      setState(() {
        _nameError = null;
        _step = 2;
      });
    }
  }

  Future<void> _handleDisclaimerContinue() async {
    if (!_disclaimerChecked) {
      return;
    }
    final userProvider = context.read<UserProvider>();
    await userProvider.acceptDisclaimer();
    if (mounted) {
      setState(() => _step = 3);
    }
  }

  Future<void> _handleTermsContinue() async {
    if (!_termsChecked) {
      return;
    }
    final userProvider = context.read<UserProvider>();
    await userProvider.acceptTerms();
    await userProvider.completeOnboarding();
  }
}

class _LanguageOption {
  final String code;
  final String label;

  const _LanguageOption({
    required this.code,
    required this.label,
  });
}
