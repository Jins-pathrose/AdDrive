
import 'package:addrive/Controller/campaigns_tab.dart';
import 'package:addrive/View/Widgets/Campaigns/campaign_list.dart';
import 'package:addrive/View/Widgets/appbackground.dart';
import 'package:addrive/View/Widgets/appfont.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

class CampaignsPage extends StatefulWidget {
  const CampaignsPage({super.key});

  @override
  State<CampaignsPage> createState() => _CampaignsPageState();
}

class _CampaignsPageState extends State<CampaignsPage> {
  @override
  void initState() {
    super.initState();
    _loadCampaigns();
  }

  Future<void> _loadCampaigns() async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('access_token');

    if (token != null) {
      await Provider.of<CampaignsProvider>(
        context,
        listen: false,
      ).fetchCampaigns(token);
    }
  }

  @override
  Widget build(BuildContext context) {
    final tabProvider = Provider.of<CampaignTabProvider>(context);
    final campaignsProvider = Provider.of<CampaignsProvider>(context);

    // Get campaigns from provider
    final allCampaigns = campaignsProvider.campaigns;

    final completedCampaigns = campaignsProvider.completedCampaigns;

    final currentCampaigns = tabProvider.selectedTab == 0
        ? allCampaigns
        : completedCampaigns;

    return Scaffold(
      backgroundColor: Colors.white,
      body: Stack(
        children: [
          const BackgroundDecoration(),
          SafeArea(
            child: Column(
              children: [
                _buildAppBar(),
                _buildTabs(tabProvider),
                const SizedBox(height: 20),
                Expanded(
  child: CampaignsList(
    campaigns: currentCampaigns,
    isCompletedTab: tabProvider.selectedTab == 1,
    onRetry: _loadCampaigns,
    isLoading: campaignsProvider.isLoading,
    error: campaignsProvider.error,
    rootContext: context, // <-- ADD THIS
  ),
),

              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAppBar() {
    return Padding(
      padding: const EdgeInsets.all(18.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            'Campaigns',
            style: AppTextStyle.base.copyWith(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: Colors.black,
            ),
          ),
          _buildNotificationIcon(),
        ],
      ),
    );
  }

  Widget _buildNotificationIcon() {
    return Container(
      padding: const EdgeInsets.all(8),
      decoration: BoxDecoration(
        color: Colors.grey[100],
        shape: BoxShape.circle,
      ),
      child: Stack(
        children: [
          const Icon(
            Icons.notifications_outlined,
            color: Colors.black87,
            size: 24,
          ),
          Positioned(
            right: 0,
            top: 0,
            child: Container(
              width: 8,
              height: 8,
              decoration: const BoxDecoration(
                color: Colors.red,
                shape: BoxShape.circle,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTabs(CampaignTabProvider tabProvider) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0),
      child: Row(
        children: [
          _buildTab(
            'All Campaigns',
            tabProvider.selectedTab == 0,
            () => tabProvider.setTab(0),
          ),
          const SizedBox(width: 12),
          _buildTab(
            'Completed',
            tabProvider.selectedTab == 1,
            () => tabProvider.setTab(1),
          ),
        ],
      ),
    );
  }

  Widget _buildTab(String text, bool isActive, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
        decoration: BoxDecoration(
          color: isActive ? const Color(0xFFE8E3FF) : Colors.transparent,
          borderRadius: BorderRadius.circular(10),
        ),
        child: Text(
          text,
          style: AppTextStyle.base.copyWith(
            color: isActive ? const Color(0xFF6C5CE7) : Colors.grey,
            fontWeight: isActive ? FontWeight.w600 : FontWeight.normal,
            fontSize: 12,
          ),
        ),
      ),
    );
  }
}
