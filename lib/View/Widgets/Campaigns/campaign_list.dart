// widgets/campaigns_list.dart
import 'package:addrive/Controller/campaigns_tab.dart';
import 'package:addrive/Model/campaigns_model.dart';
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

  @override
  Widget build(BuildContext context) {
    if (isLoading) {
      return const Center(
        child: CircularProgressIndicator(color: Color(0xFF6C5CE7)),
      );
    }

    if (error != null) {
      return _buildErrorState();
    }

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
          Text(
            error!,
            style: AppTextStyle.base.copyWith(color: Colors.red, fontSize: 16),
            textAlign: TextAlign.center,
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
