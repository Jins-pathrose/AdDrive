// tab_provider.dart
import 'package:flutter/material.dart';

class CampaignTabProvider extends ChangeNotifier {
  int _selectedTab = 0;

  int get selectedTab => _selectedTab;

  void setTab(int index) {
    _selectedTab = index;
    notifyListeners();
  }
}