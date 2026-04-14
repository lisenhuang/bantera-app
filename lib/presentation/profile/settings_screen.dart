import 'package:flutter/material.dart';
import 'package:in_app_review/in_app_review.dart';
import 'package:share_plus/share_plus.dart';

import '../../core/app_locale.dart';
import '../../core/auth_session_notifier.dart';
import '../../core/settings_notifier.dart';
import '../../l10n/app_localizations.dart';
import '../dev/dev_screen.dart';
import 'account_more_screen.dart';
import 'edit_profile_screen.dart';
import 'permissions_screen.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  int _titleTapCount = 0;

  Future<void> _confirmSignOut() async {
    final l10n = AppLocalizations.of(context)!;
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(l10n.signOutDialogTitle),
        content: Text(l10n.signOutDialogBody),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: Text(l10n.cancel),
          ),
          TextButton(
            onPressed: () => Navigator.pop(ctx, true),
            child: Text(l10n.signOut),
          ),
        ],
      ),
    );
    if (confirmed != true || !mounted) return;
    AuthSessionNotifier.instance.signOut();
    Navigator.of(context).popUntil((route) => route.isFirst);
  }

  void _handleTitleTap() async {
    _titleTapCount++;
    if (_titleTapCount < 16) return;
    _titleTapCount = 0;

    final auth = AuthSessionNotifier.instance;
    final changed = await Navigator.of(context).push<bool>(
      MaterialPageRoute(builder: (context) => const DevScreen()),
    );

    if (changed == true && mounted) {
      auth.signOut();
      Navigator.of(context).popUntil((route) => route.isFirst);
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    return Scaffold(
      appBar: AppBar(
        title: GestureDetector(
          onTap: _handleTitleTap,
          behavior: HitTestBehavior.opaque,
          child: Text(l10n.settingsTitle),
        ),
      ),
      body: ListenableBuilder(
        listenable: AuthSessionNotifier.instance,
        builder: (context, _) {
          final auth = AuthSessionNotifier.instance;

          return ListView(
            padding: const EdgeInsets.all(16),
            children: [
              _buildSectionHeader(context, l10n.sectionAppearance),
              ListenableBuilder(
                listenable: SettingsNotifier.instance,
                builder: (context, _) {
                  final settings = SettingsNotifier.instance;
                  return Card(
                    margin: EdgeInsets.zero,
                    child: Padding(
                      padding: const EdgeInsets.fromLTRB(16, 12, 16, 16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Icon(
                                Icons.brightness_6_outlined,
                                color: Theme.of(context).colorScheme.primary,
                              ),
                              const SizedBox(width: 12),
                              Text(
                                l10n.themeLabel,
                                style: Theme.of(context).textTheme.titleMedium,
                              ),
                            ],
                          ),
                          const SizedBox(height: 12),
                          SegmentedButton<ThemeMode>(
                            style: SegmentedButton.styleFrom(
                              side: BorderSide(
                                color: Theme.of(
                                  context,
                                ).colorScheme.outlineVariant,
                              ),
                            ),
                            segments: [
                              ButtonSegment<ThemeMode>(
                                value: ThemeMode.light,
                                label: Text(l10n.themeLight),
                                icon: const Icon(Icons.light_mode_outlined),
                              ),
                              ButtonSegment<ThemeMode>(
                                value: ThemeMode.dark,
                                label: Text(l10n.themeDark),
                                icon: const Icon(Icons.dark_mode_outlined),
                              ),
                              ButtonSegment<ThemeMode>(
                                value: ThemeMode.system,
                                label: Text(l10n.themeSystem),
                                icon: const Icon(
                                  Icons.brightness_auto_outlined,
                                ),
                              ),
                            ],
                            selected: {settings.themeMode},
                            onSelectionChanged: (Set<ThemeMode> next) {
                              if (next.isEmpty) {
                                return;
                              }
                              SettingsNotifier.instance.setThemeMode(
                                next.first,
                              );
                            },
                          ),
                        ],
                      ),
                    ),
                  );
                },
              ),
              const SizedBox(height: 24),
              _buildSectionHeader(context, l10n.sectionLanguage),
              Card(
                margin: EdgeInsets.zero,
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(16, 12, 16, 16),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Padding(
                        padding: const EdgeInsets.only(top: 2),
                        child: Icon(
                          Icons.language_outlined,
                          color: Theme.of(context).colorScheme.primary,
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              l10n.languageSectionSubtitle,
                              style: Theme.of(context).textTheme.bodySmall,
                            ),
                            const SizedBox(height: 12),
                            ListenableBuilder(
                              listenable: SettingsNotifier.instance,
                              builder: (context, _) {
                                final settings = SettingsNotifier.instance;
                                return DropdownButton<AppLocalePreference>(
                                  isExpanded: true,
                                  value: settings.appLocalePreference,
                                  borderRadius: BorderRadius.circular(12),
                                  padding: EdgeInsets.zero,
                                  alignment: AlignmentDirectional.centerStart,
                                  items: [
                                    DropdownMenuItem(
                                      value: AppLocalePreference.system,
                                      child: const Text(
                                        AppLocaleAutonyms.systemDefault,
                                      ),
                                    ),
                                    DropdownMenuItem(
                                      value: AppLocalePreference.en,
                                      child: const Text(
                                        AppLocaleAutonyms.english,
                                      ),
                                    ),
                                    DropdownMenuItem(
                                      value: AppLocalePreference.zhCn,
                                      child: const Text(
                                        AppLocaleAutonyms.chineseSimplified,
                                      ),
                                    ),
                                    DropdownMenuItem(
                                      value: AppLocalePreference.ko,
                                      child: const Text(
                                        AppLocaleAutonyms.korean,
                                      ),
                                    ),
                                    DropdownMenuItem(
                                      value: AppLocalePreference.ja,
                                      child: const Text(
                                        AppLocaleAutonyms.japanese,
                                      ),
                                    ),
                                  ],
                                  onChanged: (v) {
                                    if (v != null) {
                                      SettingsNotifier.instance
                                          .setAppLocalePreference(v);
                                    }
                                  },
                                );
                              },
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 24),
              _buildSectionHeader(context, l10n.sectionPermissions),
              Card(
                margin: EdgeInsets.zero,
                child: ListTile(
                  leading: const Icon(Icons.privacy_tip_outlined),
                  title: Text(l10n.appPermissionsTitle),
                  subtitle: Text(l10n.appPermissionsSubtitle),
                  trailing: const Icon(Icons.chevron_right),
                  onTap: () {
                    Navigator.of(context).push(
                      MaterialPageRoute<void>(
                        builder: (context) => const PermissionsScreen(),
                      ),
                    );
                  },
                ),
              ),
              const SizedBox(height: 24),
              _buildSectionHeader(context, l10n.sectionAccount),
              Card(
                margin: EdgeInsets.zero,
                child: Column(
                  children: [
                    ListTile(
                      leading: const Icon(Icons.verified_user_outlined),
                      title: Text(
                        auth.session?.accountLabel ?? l10n.signedOutLabel,
                      ),
                      subtitle: Text(
                        auth.session == null
                            ? l10n.noActiveSession
                            : l10n.signedInWith(auth.session!.providerLabel),
                      ),
                    ),
                    Divider(
                      height: 1,
                      thickness: 1,
                      color: Theme.of(context).colorScheme.outlineVariant,
                    ),
                    ListTile(
                      leading: const Icon(Icons.person),
                      title: Text(l10n.editProfile),
                      trailing: const Icon(Icons.chevron_right),
                      onTap: auth.session == null
                          ? null
                          : () {
                              Navigator.of(context).push(
                                MaterialPageRoute(
                                  builder: (context) =>
                                      const EditProfileScreen(),
                                ),
                              );
                            },
                    ),
                    Divider(
                      height: 1,
                      thickness: 1,
                      color: Theme.of(context).colorScheme.outlineVariant,
                    ),
                    ListTile(
                      leading: const Icon(Icons.more_horiz),
                      title: Text(l10n.more),
                      trailing: const Icon(Icons.chevron_right),
                      onTap: auth.session == null
                          ? null
                          : () {
                              Navigator.of(context).push(
                                MaterialPageRoute<void>(
                                  builder: (context) =>
                                      const AccountMoreScreen(),
                                ),
                              );
                            },
                    ),
                    Divider(
                      height: 1,
                      thickness: 1,
                      color: Theme.of(context).colorScheme.outlineVariant,
                    ),
                    ListTile(
                      leading: const Icon(Icons.logout),
                      title: Text(l10n.signOut),
                      onTap: auth.session == null ? null : _confirmSignOut,
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 24),
              _buildSectionHeader(context, l10n.sectionRateAndShare),
              Card(
                margin: EdgeInsets.zero,
                child: Column(
                  children: [
                    ListTile(
                      leading: const Icon(Icons.star_rounded),
                      title: Text(l10n.settingsRateAppButton),
                      trailing: const Icon(Icons.chevron_right),
                      onTap: () async {
                        final review = InAppReview.instance;
                        if (await review.isAvailable()) {
                          await review.requestReview();
                        }
                      },
                    ),
                    Divider(
                      height: 1,
                      thickness: 1,
                      color: Theme.of(context).colorScheme.outlineVariant,
                    ),
                    ListTile(
                      leading: const Icon(Icons.ios_share_rounded),
                      title: Text(l10n.settingsShareButton),
                      trailing: const Icon(Icons.chevron_right),
                      onTap: () {
                        SharePlus.instance.share(
                          ShareParams(
                            uri: Uri.parse('https://bantera.app?from=iOS'),
                          ),
                        );
                      },
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),
            ],
          );
        },
      ),
    );
  }

  Widget _buildSectionHeader(BuildContext context, String title) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8.0, left: 4.0),
      child: Text(
        title,
        style: Theme.of(context).textTheme.titleMedium?.copyWith(
          color: Theme.of(context).colorScheme.primary,
        ),
      ),
    );
  }
}
