import 'package:addrive/Controller/campaigns_tab.dart';
import 'package:addrive/Model/fleetcampaign.dart';
import 'package:addrive/View/Widgets/appfont.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class FleetCampaignCard extends StatelessWidget {
  final FleetCampaign campaign;

  const FleetCampaignCard({super.key, required this.campaign});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 20),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.4),
            spreadRadius: 1,
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Text(
                  campaign.campaignName,
                  style: AppTextStyle.base.copyWith(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: Colors.black,
                  ),
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 6,
                ),
                decoration: BoxDecoration(
                  color: Colors.green.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: Colors.green, width: 1),
                ),
                child: Text(
                  'Fleet Campaign',
                  style: AppTextStyle.base.copyWith(
                    fontSize: 12,
                    color: Colors.green,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ],
          ),

          const SizedBox(height: 8),

          // Fleet Name
          Row(
            children: [
              const Icon(Icons.business, size: 14, color: Color(0xFF6C5CE7)),
              const SizedBox(width: 6),
              Text(
                campaign.fleetName,
                style: AppTextStyle.base.copyWith(
                  fontSize: 12,
                  color: Colors.grey[600],
                ),
              ),
            ],
          ),

          const SizedBox(height: 8),

          // Date Range
          Row(
            children: [
              const Icon(
                Icons.calendar_today,
                size: 14,
                color: Color(0xFF6C5CE7),
              ),
              const SizedBox(width: 6),
              Text(
                '${_formatDate(campaign.startDate)} - ${_formatDate(campaign.endDate)}',
                style: AppTextStyle.base.copyWith(
                  fontSize: 12,
                  color: Colors.grey[600],
                ),
              ),
            ],
          ),

          const SizedBox(height: 8),

          // Target Kilometers
          Row(
            children: [
              const Icon(Icons.route, size: 14, color: Color(0xFF6C5CE7)),
              const SizedBox(width: 6),
              Text(
                '${campaign.targetKilometers} kms',
                style: AppTextStyle.base.copyWith(
                  fontSize: 12,
                  color: Colors.grey[600],
                ),
              ),
              const Spacer(),
              Text(
                'Assigned on ${_formatDate(campaign.assignedAt)}',
                style: AppTextStyle.base.copyWith(
                  fontSize: 11,
                  color: Colors.grey[500],
                ),
              ),
            ],
          ),

          const SizedBox(height: 8),

          // Status Badge
          Row(
            children: [
              Align(
                alignment: Alignment.centerRight,
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 6,
                  ),
                  decoration: BoxDecoration(
                    color: _getStatusColor().withOpacity(0.1),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(Icons.circle, size: 8, color: _getStatusColor()),
                      const SizedBox(width: 6),
                      Text(
                        campaign.status,
                        style: AppTextStyle.base.copyWith(
                          fontSize: 12,
                          color: _getStatusColor(),
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const Spacer(),
              // In your FleetCampaignCard widget, update the button section:
              Consumer<CampaignsProvider>(
                builder: (context, provider, child) {
                  final isJoined = provider.isFleetCampaignJoined(
                    campaign.campaignId,
                  );
                  final isLoading = provider.isFleetCampaignLoading(
                    campaign.campaignId,
                  );

                  if (isLoading) {
                    return const SizedBox(
                      width: 24,
                      height: 24,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    );
                  } else if (isJoined) {
                    return _buildActiveBadge();
                  } else {
                    return ElevatedButton(
                      onPressed: () async {
                        final success = await provider.joinFleetCampaign(
                          campaign.campaignId,
                        );
                        if (success) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text(
                                'Successfully joined ${campaign.campaignName}!',
                              ),
                              backgroundColor: Colors.green,
                            ),
                          );
                        } else {
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text('Failed to join campaign'),
                              backgroundColor: Colors.red,
                            ),
                          );
                        }
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF6C5CE7),
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(
                          horizontal: 15,
                          vertical: 0,
                        ),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(20),
                        ),
                        elevation: 0,
                      ),
                      child: Text(
                        'Join Campaign',
                        style: AppTextStyle.base.copyWith(
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    );
                  }
                },
              ),
            ],
          ),
        ],
      ),
    );
  }

  String _formatDate(DateTime date) {
    return '${date.day} ${_getMonthName(date.month)} ${date.year}';
  }

  String _getMonthName(int month) {
    const months = [
      'Jan',
      'Feb',
      'Mar',
      'Apr',
      'May',
      'Jun',
      'Jul',
      'Aug',
      'Sep',
      'Oct',
      'Nov',
      'Dec',
    ];
    return months[month - 1];
  }

  Color _getStatusColor() {
    switch (campaign.status.toLowerCase()) {
      case 'ongoing':
        return Colors.green;
      default:
        return const Color(0xFF6C5CE7);
    }
  }

  Widget _buildActiveBadge() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 6),
      decoration: BoxDecoration(
        color: Colors.green.withOpacity(0.1),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.green, width: 1),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(Icons.check_circle, size: 14, color: Colors.green),
          const SizedBox(width: 6),
          Text(
            'Active',
            style: AppTextStyle.base.copyWith(
              fontSize: 12,
              color: Colors.green,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }
}
