import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

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

  final List<Widget> _screens = const [
    DiscoverScreen(),
    CreateHubScreen(),
    ProfileScreen(),
  ];

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    return Scaffold(
      body: IndexedStack(
        index: _currentIndex,
        children: _screens,
      ),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _currentIndex,
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
          BottomNavigationBarItem(
            icon: const Icon(CupertinoIcons.add_circled_solid),
            label: l10n.navCreate,
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
