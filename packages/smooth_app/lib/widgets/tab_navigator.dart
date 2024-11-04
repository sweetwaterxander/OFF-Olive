import 'package:flutter/material.dart';
import 'package:smooth_app/pages/history_page.dart';
import 'package:smooth_app/pages/map_page.dart';
import 'package:smooth_app/pages/page_manager.dart';
import 'package:smooth_app/pages/preferences/user_preferences_page.dart';
import 'package:smooth_app/pages/scan/scan_page.dart';
import 'package:smooth_app/pages/search/search_page.dart';
import 'package:smooth_app/pages/search/search_product_helper.dart';

class TabNavigator extends StatelessWidget {
  const TabNavigator({
    required this.navigatorKey,
    required this.tabItem,
  });

  final GlobalKey<NavigatorState> navigatorKey;
  final BottomNavigationTab tabItem;

  @override
  Widget build(BuildContext context) {
    return Navigator(
      key: navigatorKey,
      initialRoute: '/',
      onGenerateRoute: (RouteSettings routeSettings) {
        return MaterialPageRoute<void>(
          builder: (BuildContext context) => _buildBody(context),
          settings: const RouteSettings(name: '/'),
        );
      },
    );
  }

  Widget _buildBody(BuildContext context) {
    switch (tabItem) {
      case BottomNavigationTab.History:
        return const HistoryPage();
      case BottomNavigationTab.Search:
        return SearchPage(SearchProductHelper());
      case BottomNavigationTab.Scan:
        return const ScanPage();
      case BottomNavigationTab.Map:
        return const MapPage();
      case BottomNavigationTab.Profile:
        return const UserPreferencesPage();
      default:
        return const SizedBox.shrink();
    }
  }
}