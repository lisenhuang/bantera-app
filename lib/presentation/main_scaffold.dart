import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import '../core/apple_system_version.dart';
import '../l10n/app_localizations.dart';
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

  static const List<Widget> _threeTabs = [
    DiscoverScreen(),
    CreateHubScreen(),
    ProfileScreen(),
  ];

  static const List<Widget> _twoTabs = [
    DiscoverScreen(),
    ProfileScreen(),
  ];

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback(_migrateTabIndexIfLegacyApple);
  }

  /// If state ever held Profile as index 2 (3-tab), remap to 1 (2-tab). Index 1 is not migrated (Create vs Profile is ambiguous).
  void _migrateTabIndexIfLegacyApple(Duration _) {
    if (!mounted) return;
    if (!isLegacyAppleOsPre26) return;
    if (_currentIndex == 2) {
      setState(() => _currentIndex = 1);
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final legacy = isLegacyAppleOsPre26;
    final screens = legacy ? _twoTabs : _threeTabs;
    final maxIndex = screens.length - 1;
    final stackIndex = _currentIndex.clamp(0, maxIndex);

    return Scaffold(
      body: IndexedStack(
        index: stackIndex,
        children: screens,
      ),
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
          if (!legacy) ...[
            BottomNavigationBarItem(
              icon: const Icon(CupertinoIcons.add_circled_solid),
              label: l10n.navCreate,
            ),
          ],
          BottomNavigationBarItem(
            icon: const Icon(CupertinoIcons.person_solid),
            label: l10n.navProfile,
          ),
        ],
      ),
    );
  }
}
