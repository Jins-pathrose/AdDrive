// widgets/campaign_card.dart
import 'package:addrive/Model/campaigns_model.dart';
import 'package:addrive/View/Widgets/appfont.dart';
import 'package:flutter/material.dart';

class CampaignCard extends StatelessWidget {
  final Campaign campaign;
  final VoidCallback onJoinPressed;

  const CampaignCard({
    super.key,
    required this.campaign,
    required this.onJoinPressed,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 20),
      padding: const EdgeInsets.only(left: 10, top: 0, right: 10, bottom: 0),
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
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      campaign.name,
                      style: AppTextStyle.base.copyWith(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: Colors.black,
                      ),
                    ),
                    _buildCampaignImage(),
                  ],
                ),
                _buildDateInfo(),
                _buildFooter(),
                const SizedBox(height: 8),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCampaignImage() {
    if (campaign.logoPath.isEmpty) {
      return _buildPlaceholderImage();
    }

    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: Container(
        width: 60,
        height: 60,
        decoration: BoxDecoration(
          color: _getColorFromStatus().withOpacity(0.1),
          borderRadius: BorderRadius.circular(12),
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(12),
          child: Image.network(
            campaign.logoPath,
            fit: BoxFit.cover,
            errorBuilder: (context, error, stackTrace) => _buildPlaceholderImage(),
            loadingBuilder: (context, child, loadingProgress) {
              if (loadingProgress == null) return child;
              return _buildLoadingImage();
            },
          ),
        ),
      ),
    );
  }

  Widget _buildPlaceholderImage() {
    return Container(
      width: 60,
      height: 60,
      decoration: BoxDecoration(
        color: _getColorFromStatus().withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Icon(
        Icons.campaign,
        color: _getColorFromStatus(),
        size: 30,
      ),
    );
  }

  Widget _buildLoadingImage() {
    return Container(
      decoration: BoxDecoration(
        color: _getColorFromStatus().withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
      ),
      child: const Center(
        child: CircularProgressIndicator(
          color: Color(0xFF6C5CE7),
          strokeWidth: 2,
        ),
      ),
    );
  }

  Widget _buildDateInfo() {
    return Row(
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
    );
  }

  Widget _buildFooter() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Row(
          children: [
            const Icon(
              Icons.route,
              size: 14,
              color: Color(0xFF6C5CE7),
            ),
            const SizedBox(width: 6),
            Text(
              '${campaign.targetKilometers} kms',
              style: AppTextStyle.base.copyWith(
                fontSize: 12,
                color: Colors.grey[600],
              ),
            ),
            const SizedBox(width: 5),
            _buildDriverCount(),
          ],
        ),
        ElevatedButton(
          onPressed: onJoinPressed,
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
        ),
      ],
    );
  }

  Widget _buildDriverCount() {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: 8,
        vertical: 2,
      ),
      decoration: BoxDecoration(
        color: const Color(0xFFE8E3FF),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          const Icon(
            Icons.person,
            size: 12,
            color: Color(0xFF6C5CE7),
          ),
          const SizedBox(width: 4),
          Text(
            // "${campaign.driverCount}+ drivers",
            "10+ drivers",
            style: AppTextStyle.base.copyWith(
              fontSize: 11,
              color: const Color(0xFF6C5CE7),
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }

  String _formatDate(DateTime date) {
    return '${date.day} ${_getMonthName(date.month)} ${date.year}';
  }

  String _getMonthName(int month) {
    const months = ['Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun', 'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'];
    return months[month - 1];
  }

  Color _getColorFromStatus() {
    switch (campaign.status.toLowerCase()) {
      case 'completed':
        return Colors.green;
      case 'upcoming':
        return Colors.blue;
      case 'active':
        return Colors.orange;
      default:
        return const Color(0xFF6C5CE7);
    }
  }
}