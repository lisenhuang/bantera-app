import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

import '../core/apple_system_version.dart';
import '../core/app_resume_notifier.dart';
import '../infrastructure/app_update_service.dart';
import '../l10n/app_localizations.dart';
import 'chats/chats_screen.dart';
import 'create/create_hub_screen.dart';
import 'discover/discover_screen.dart';
import 'profile/profile_screen.dart';

class MainScaffold extends StatefulWidget {
  const MainScaffold({super.key});

  @override
  State<MainScaffold> createState() => _MainScaffoldState();
}

class _MainScaffoldState extends State<MainScaffold> {
  int _currentIndex = 0;
  bool _checkingUpdate = false;

  static const List<Widget> _fourTabs = [
    DiscoverScreen(),
    CreateHubScreen(),
    ChatsScreen(),
    ProfileScreen(),
  ];

  static const List<Widget> _threeTabs = [
    DiscoverScreen(),
    ChatsScreen(),
    ProfileScreen(),
  ];

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback(
      _migrateTabIndexIfCreateHidden,
    );
    WidgetsBinding.instance.addPostFrameCallback((_) => _checkForUpdate());
    AppResumeNotifier.instance.addListener(_onResume);
  }

  @override
  void dispose() {
    AppResumeNotifier.instance.removeListener(_onResume);
    super.dispose();
  }

  void _onResume() => _checkForUpdate();

  Future<void> _checkForUpdate() async {
    if (_checkingUpdate) return;
    _checkingUpdate = true;
    try {
      final result = await AppUpdateService.checkForUpdate();
      if (!mounted) return;
      if (result != null && result.needsUpdate) {
        _showUpdateDialog(result.storeUrl);
      }
    } finally {
      _checkingUpdate = false;
    }
  }

  void _showUpdateDialog(String storeUrl) {
    final l10n = AppLocalizations.of(context)!;
    showDialog<void>(
      context: context,
      barrierDismissible: false,
      builder: (ctx) => AlertDialog(
        title: Text(l10n.updateAlertTitle),
        content: Text(l10n.updateAlertMessage),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: Text(l10n.updateAlertLater),
          ),
          TextButton(
            onPressed: () async {
              Navigator.pop(ctx);
              await launchUrl(
                Uri.parse(storeUrl),
                mode: LaunchMode.externalApplication,
              );
            },
            child: Text(l10n.updateAlertUpdate),
          ),
        ],
      ),
    );
  }

  /// If state ever held Chats/Profile as indices 2/3 (4-tab), remap to 1/2
  /// when Create is hidden. Index 1 naturally becomes Chats in the 3-tab layout.
  void _migrateTabIndexIfCreateHidden(Duration _) {
    if (!mounted) return;
    if (supportsCreateTabOnApple) return;
    if (_currentIndex == 2) {
      setState(() => _currentIndex = 1);
    } else if (_currentIndex == 3) {
      setState(() => _currentIndex = 2);
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final showCreateTab = supportsCreateTabOnApple;
    final screens = showCreateTab ? _fourTabs : _threeTabs;
    final maxIndex = screens.length - 1;
    final stackIndex = _currentIndex.clamp(0, maxIndex);

    return Scaffold(
      body: IndexedStack(index: stackIndex, children: screens),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: stackIndex,
        onTap: (index) {
          setState(() {
            _currentIndex = index;
          });
        },
        items: [
          BottomNavigationBarItem(
            icon: const Icon(CupertinoIcons.compass),
            label: l10n.navDiscover,
          ),
          if (showCreateTab) ...[
            BottomNavigationBarItem(
              icon: const Icon(CupertinoIcons.add_circled_solid),
              label: l10n.navCreate,
            ),
          ],
          BottomNavigationBarItem(
            icon: const Icon(CupertinoIcons.chat_bubble_text_fill),
            label: l10n.chatsTitle,
          ),
          BottomNavigationBarItem(
            icon: const Icon(CupertinoIcons.person_solid),
            label: l10n.navProfile,
          ),
        ],
      ),
    );
  }
}
