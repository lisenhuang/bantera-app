import 'package:flutter/material.dart';

import '../../core/app_locale.dart';
import '../../core/auth_session_notifier.dart';
import '../../core/settings_notifier.dart';
import '../../l10n/app_localizations.dart';
import '../auth/api_base_url_screen.dart';
import 'account_more_screen.dart';
import 'edit_profile_screen.dart';

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
      MaterialPageRoute(builder: (context) => const ApiBaseUrlScreen()),
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
                                icon: const Icon(Icons.brightness_auto_outlined),
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
                            padding: const EdgeInsets.symmetric(horizontal: 12),
                            items: [
                              DropdownMenuItem(
                                value: AppLocalePreference.system,
                                child: Text(l10n.languageSystem),
                              ),
                              DropdownMenuItem(
                                value: AppLocalePreference.en,
                                child: Text(l10n.languageEnglish),
                              ),
                              DropdownMenuItem(
                                value: AppLocalePreference.zhCn,
                                child: Text(l10n.languageChineseSimplified),
                              ),
                              DropdownMenuItem(
                                value: AppLocalePreference.ko,
                                child: Text(l10n.languageKorean),
                              ),
                              DropdownMenuItem(
                                value: AppLocalePreference.ja,
                                child: Text(l10n.languageJapanese),
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
              ),
              const SizedBox(height: 24),
              _buildSectionHeader(context, l10n.sectionAccount),
              Card(
                margin: EdgeInsets.zero,
                child: Column(
                  children: [
                    ListTile(
                      leading: const Icon(Icons.verified_user_outlined),
                      title: Text(auth.session?.accountLabel ?? l10n.signedOutLabel),
                      subtitle: Text(
                        auth.session == null
                            ? l10n.noActiveSession
                            : l10n.signedInWith(auth.session!.providerLabel),
                      ),
                    ),
                    const Divider(height: 1),
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
                    const Divider(height: 1),
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
                    const Divider(height: 1),
                    ListTile(
                      leading: const Icon(Icons.logout, color: Colors.red),
                      title: Text(
                        l10n.signOut,
                        style: const TextStyle(color: Colors.red),
                      ),
                      onTap: auth.session == null ? null : _confirmSignOut,
                    ),
                  ],
                ),
              ),
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
