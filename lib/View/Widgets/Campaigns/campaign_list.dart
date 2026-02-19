// // widgets/campaigns_list.dart
import 'package:addrive/Controller/campaigns_tab.dart';
import 'package:addrive/Model/campaigns_model.dart';
import 'package:addrive/Model/completedcampaigns_model.dart';
import 'package:addrive/View/Widgets/Campaigns/fleetcampaign_card.dart';
import 'package:addrive/View/Widgets/appfont.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'campaign_card.dart';

class CampaignsList extends StatelessWidget {
  final List<dynamic> campaigns;
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

  @override
  Widget build(BuildContext context) {
    final campaignsProvider = Provider.of<CampaignsProvider>(context, listen: true);
    final tabProvider = Provider.of<CampaignTabProvider>(context, listen: true);
    
    if (campaignsProvider.isLoading) {
      return const Center(
        child: CircularProgressIndicator(color: Color(0xFF6C5CE7)),
      );
    }

    if (campaignsProvider.error != null) {
      return _buildErrorState();
    }

    // For fleet drivers
    if (campaignsProvider.isFleetDriver) {
      // Check which tab is selected
      if (tabProvider.selectedTab == 1) {
        // COMPLETED TAB - Show completed campaigns from the dedicated endpoint
        final completedCampaigns = campaignsProvider.completedCampaigns;
        
        if (completedCampaigns.isEmpty) {
          return Center(
            child: Text(
              'No completed campaigns',
              style: const TextStyle(fontSize: 16, color: Colors.grey),
            ),
          );
        }

        return ListView.builder(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          itemCount: completedCampaigns.length,
          itemBuilder: (context, index) {
            final completedCampaign = completedCampaigns[index];
            // You might need a specific card for completed campaigns
            // For now, using a generic container
            return _buildCompletedCampaignCard(completedCampaign);
          },
        );
      } else {
        // ALL CAMPAIGNS TAB - Show active fleet campaigns
        final activeFleetCampaigns = campaignsProvider.fleetCampaigns
            .where((c) => c.status.toLowerCase() != 'completed')
            .toList();
        
        if (activeFleetCampaigns.isEmpty) {
          return Center(
            child: Text(
              'No active fleet campaigns',
              style: const TextStyle(fontSize: 16, color: Colors.grey),
            ),
          );
        }

        return ListView.builder(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          itemCount: activeFleetCampaigns.length,
          itemBuilder: (context, index) {
            final campaign = activeFleetCampaigns[index];
            return FleetCampaignCard(campaign: campaign);
          },
        );
      }
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

  Widget _buildCompletedCampaignCard(CompletedCampaign campaign) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              campaign.campaignName,
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text('Target: ${campaign.targetKilometers} km'),
                Text('Earned: ₹${campaign.totalEarnedAmount}'),
              ],
            ),
            const SizedBox(height: 4),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text('Period: ${campaign.startDate} to ${campaign.endDate}'),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 8,
                    vertical: 4,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.green.shade100,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: const Text(
                    'Completed',
                    style: TextStyle(
                      color: Colors.green,
                      fontSize: 12,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
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
              style: AppTextStyle.base.copyWith(color: const Color(0xFF5B4BDB)),
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
    final parentContext = context;

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
              Navigator.pop(dialogContext);

              bool success = await Provider.of<CampaignsProvider>(
                parentContext,
                listen: false,
              ).joinCampaign(campaign.id);

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