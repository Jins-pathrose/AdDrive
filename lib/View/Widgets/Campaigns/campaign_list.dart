// widgets/campaigns_list.dart
import 'package:addrive/Controller/campaigns_tab.dart';
import 'package:addrive/Model/campaigns_model.dart';
import 'package:addrive/View/Widgets/Campaigns/fleetcampaign_card.dart';
import 'package:addrive/View/Widgets/appfont.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'campaign_card.dart';

class CampaignsList extends StatelessWidget {
  final List<Campaign> campaigns;
  final bool isCompletedTab;
  final VoidCallback onRetry;
  final bool isLoading;
  final String? error;
  final BuildContext rootContext;

  const CampaignsList({
    super.key,
    required this.campaigns,
    required this.isCompletedTab,
    required this.onRetry,
    this.isLoading = false,
    this.error,
    required this.rootContext,
  });

  // In CampaignsList widget build method, replace with:
@override
Widget build(BuildContext context) {
  final campaignsProvider = Provider.of<CampaignsProvider>(context, listen: true);
  
  if (campaignsProvider.isLoading) {
    return const Center(
      child: CircularProgressIndicator(color: Color(0xFF6C5CE7)),
    );
  }

  if (campaignsProvider.error != null) {
    return _buildErrorState();
  }

  // Check if driver is fleet and show fleet campaigns
  if (campaignsProvider.isFleetDriver) {
    final fleetCampaigns = campaignsProvider.fleetCampaigns;
    
    if (fleetCampaigns.isEmpty) {
      return Center(
        child: Text(
          'No fleet campaigns available',
          style: const TextStyle(fontSize: 16, color: Colors.grey),
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      itemCount: fleetCampaigns.length,
      itemBuilder: (context, index) {
        final campaign = fleetCampaigns[index];
        return FleetCampaignCard(campaign: campaign);
      },
    );
  }

  // Original logic for non-fleet drivers
  if (campaigns.isEmpty) {
    return _buildEmptyState();
  }

  return ListView.builder(
    padding: const EdgeInsets.symmetric(horizontal: 16),
    itemCount: campaigns.length,
    itemBuilder: (context, index) {
      final campaign = campaigns[index];
      return CampaignCard(
        campaign: campaign,
        onJoinPressed: () => _handleJoinCampaign(context, campaign),
      );
    },
  );
}

  Widget _buildErrorState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Text(
              "Please check your internet connection and try again",
              style: AppTextStyle.base.copyWith(color: Color(0xFF5B4BDB)),
              textAlign: TextAlign.center,
            ),
          ),
          const SizedBox(height: 16),
          ElevatedButton(
            onPressed: onRetry,
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF6C5CE7),
              foregroundColor: Colors.white,
            ),
            child: const Text('Retry'),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Text(
        isCompletedTab ? 'No completed campaigns' : 'No campaigns available',
        style: const TextStyle(fontSize: 16, color: Colors.grey),
      ),
    );
  }

  void _handleJoinCampaign(BuildContext context, Campaign campaign) {
    final parentContext = context; // <-- store safe context

    showDialog(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Join Campaign'),
        content: Text('Do you want to join ${campaign.name}?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () async {
              Navigator.pop(dialogContext); // close dialog

              bool success = await Provider.of<CampaignsProvider>(
                parentContext,
                listen: false,
              ).joinCampaign(campaign.id);

              // Use safe parent context, not dialogContext
              ScaffoldMessenger.of(rootContext).showSnackBar(
                SnackBar(
                  content: Text(
                    success
                        ? "Join request submitted successfully!"
                        : "Failed to submit join request.",
                  ),
                  backgroundColor: success ? Colors.green : Colors.red,
                ),
              );
            },
            child: const Text('Join'),
          ),
        ],
      ),
    );
  }
}
