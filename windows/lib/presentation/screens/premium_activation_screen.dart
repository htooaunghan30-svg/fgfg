import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../features/premium/license_models.dart';
import '../providers/user_provider.dart';

class PremiumActivationScreen extends StatefulWidget {
  const PremiumActivationScreen({super.key});

  @override
  State<PremiumActivationScreen> createState() =>
      _PremiumActivationScreenState();
}

class _PremiumActivationScreenState extends State<PremiumActivationScreen> {
  final TextEditingController _licenseController = TextEditingController();
  bool _submitting = false;

  static const String _phoneDisplay = '+959676728417';
  static const String _phoneDigits = '959676728417';

  static final List<_ContactItem> _contactItems = [
    _ContactItem(
      label: 'WhatsApp',
      value: _phoneDisplay,
      icon: Icons.chat_rounded,
      primaryUri: Uri.parse('whatsapp://send?phone=$_phoneDigits'),
      fallbackUri: Uri.parse('https://wa.me/$_phoneDigits'),
    ),
    _ContactItem(
      label: 'Viber',
      value: _phoneDisplay,
      icon: Icons.phone_in_talk_rounded,
      primaryUri: Uri.parse('viber://chat?number=%2B$_phoneDigits'),
      fallbackUri: Uri.parse('https://www.viber.com/'),
    ),
    _ContactItem(
      label: 'Telegram',
      value: _phoneDisplay,
      icon: Icons.send_rounded,
      primaryUri: Uri.parse('tg://resolve?phone=$_phoneDigits'),
      fallbackUri: Uri.parse('https://t.me/+$_phoneDigits'),
    ),
    _ContactItem(
      label: 'Website',
      value: 'https://www.hanproduct.com',
      icon: Icons.public_rounded,
      primaryUri: Uri.parse('https://www.hanproduct.com'),
    ),
  ];

  @override
  void dispose() {
    _licenseController.dispose();
    super.dispose();
  }

  Future<void> _activate() async {
    final key = _licenseController.text.trim();
    if (key.isEmpty) {
      _showMessage('Please enter your license key.');
      return;
    }

    setState(() => _submitting = true);
    final provider = context.read<UserProvider>();
    final result = await provider.activatePremiumLicense(key);
    if (!mounted) {
      return;
    }

    setState(() => _submitting = false);
    _showMessage(_statusMessage(result));
  }

  Future<void> _deactivate() async {
    setState(() => _submitting = true);
    await context.read<UserProvider>().deactivatePremiumLicense();
    if (!mounted) {
      return;
    }
    setState(() => _submitting = false);
    _showMessage('Premium disabled on this device.');
  }

  @override
  Widget build(BuildContext context) {
    final userProvider = context.watch<UserProvider>();
    final busy =
        _submitting || userProvider.isLoading || userProvider.isPremiumSyncing;
    final expiresAt = userProvider.premiumExpiresAt;
    final colorScheme = Theme.of(context).colorScheme;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Premium License'),
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Text(
            'Contact and Premium License Purchasing',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.w800,
              color: colorScheme.onSurface,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            'Contact Us',
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w600,
              color: colorScheme.onSurface.withOpacity(0.7),
              letterSpacing: 0.2,
            ),
          ),
          const SizedBox(height: 12),
           Card(
             elevation: 0,
             shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
             ),
             child: Padding(
               padding: const EdgeInsets.symmetric(vertical: 8),
               child: Column(
                children: List.generate(_contactItems.length, (index) {
                  final item = _contactItems[index];
                  return Column(
                    children: [
                      _ContactTile(
                        item: item,
                        onOpen: () => _openContact(item),
                        onCopy: () => _copyValue(item.value),
                      ),
                      if (index != _contactItems.length - 1)
                        Divider(
                          height: 1,
                          color: colorScheme.outlineVariant.withOpacity(0.35),
                        ),
                    ],
                  );
                }),
              ),
            ),
          ),
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Icon(
                        userProvider.isPremium
                            ? Icons.verified_rounded
                            : Icons.lock_outline_rounded,
                        color: userProvider.isPremium
                            ? Colors.green
                            : Colors.orange,
                      ),
                      const SizedBox(width: 10),
                      Text(
                        userProvider.isPremium
                            ? 'Premium Active'
                            : 'Premium Inactive',
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ],
                  ),
                  if (expiresAt != null) ...[
                    const SizedBox(height: 10),
                    Text('Expires: ${expiresAt.toLocal()}'),
                  ],
                  if ((userProvider.premiumMessage ?? '').isNotEmpty) ...[
                    const SizedBox(height: 10),
                    Text(
                      userProvider.premiumMessage!,
                      style: TextStyle(
                        color: Theme.of(context).colorScheme.primary,
                      ),
                    ),
                  ],
                ],
              ),
            ),
          ),
          const SizedBox(height: 16),
          TextField(
            controller: _licenseController,
            textCapitalization: TextCapitalization.characters,
            enabled: !busy,
            decoration: const InputDecoration(
              labelText: 'License Key',
              hintText: 'HF-XXXX-XXXX-XXXX-XXXX',
              border: OutlineInputBorder(),
            ),
          ),
          const SizedBox(height: 12),
          FilledButton.icon(
            onPressed: busy ? null : _activate,
            icon: const Icon(Icons.vpn_key),
            label: Text(busy ? 'Please wait...' : 'Activate License'),
          ),
          const SizedBox(height: 8),
          TextButton.icon(
            onPressed: busy || !userProvider.isPremium ? null : _deactivate,
            icon: const Icon(Icons.delete_outline),
            label: const Text('Deactivate on this device'),
          ),
          const SizedBox(height: 18),
          const Text(
            'Security Notes',
            style: TextStyle(fontWeight: FontWeight.w700),
          ),
          const SizedBox(height: 8),
          const Text(
            'If activation is verified on the server, stored with encrypted secure storage, and bound to this device.',
            style: TextStyle(height: 1.35),
          ),
        ],
      ),
    );
  }

  Future<void> _openContact(_ContactItem item) async {
    final opened = await _launchUri(item.primaryUri);
    if (!opened && item.fallbackUri != null) {
      await _launchUri(item.fallbackUri!);
    }
  }

  Future<bool> _launchUri(Uri uri) async {
    if (!_isAllowedUri(uri)) {
      return false;
    }
    try {
      return await launchUrl(uri, mode: LaunchMode.externalApplication);
    } catch (_) {
      return false;
    }
  }

  bool _isAllowedUri(Uri uri) {
    const allowedSchemes = <String>{
      'https',
      'whatsapp',
      'viber',
      'tg',
    };
    if (!allowedSchemes.contains(uri.scheme)) {
      return false;
    }
    if (uri.scheme == 'https') {
      const allowedHosts = <String>{
        'wa.me',
        'www.viber.com',
        'viber.com',
        't.me',
        'telegram.me',
        'www.hanproduct.com',
        'hanproduct.com',
      };
      return allowedHosts.contains(uri.host);
    }
    return true;
  }

  void _copyValue(String value) {
    Clipboard.setData(ClipboardData(text: value));
    _showMessage('Copied: $value');
  }

  void _showMessage(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message)),
    );
  }

  String _statusMessage(LicenseActivationResult result) {
    if (result.ok) {
      return result.code == LicenseStatusCode.alreadyBound
          ? 'License is already active on this device.'
          : 'Premium activated successfully.';
    }
    return result.message;
  }
}

class _ContactItem {
  final String label;
  final String value;
  final IconData icon;
  final Uri primaryUri;
  final Uri? fallbackUri;

  const _ContactItem({
    required this.label,
    required this.value,
    required this.icon,
    required this.primaryUri,
    this.fallbackUri,
  });
}

class _ContactTile extends StatelessWidget {
  final _ContactItem item;
  final VoidCallback onOpen;
  final VoidCallback onCopy;

  const _ContactTile({
    required this.item,
    required this.onOpen,
    required this.onCopy,
  });

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    return InkWell(
      onTap: onOpen,
      borderRadius: BorderRadius.circular(12),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
        child: Row(
          children: [
            Container(
              width: 44,
              height: 44,
              decoration: BoxDecoration(
                color: colorScheme.primaryContainer.withOpacity(0.2),
                shape: BoxShape.circle,
              ),
              child: Icon(
                item.icon,
                color: colorScheme.primary,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    item.label,
                    style: const TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    item.value,
                    style: TextStyle(
                      fontSize: 13,
                      color: colorScheme.onSurface.withOpacity(0.65),
                    ),
                  ),
                ],
              ),
            ),
            IconButton(
              onPressed: onCopy,
              tooltip: 'Copy',
              icon: const Icon(Icons.copy_rounded),
            ),
            Icon(
              Icons.open_in_new_rounded,
              size: 18,
              color: colorScheme.onSurface.withOpacity(0.5),
            ),
          ],
        ),
      ),
    );
  }
}
