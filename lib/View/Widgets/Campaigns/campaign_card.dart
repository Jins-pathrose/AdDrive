// widgets/campaign_card.dart
import 'package:addrive/Controller/campaigns_tab.dart';
import 'package:addrive/Model/campaigns_model.dart';
import 'package:addrive/View/Widgets/appfont.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class CampaignCard extends StatefulWidget {
  final Campaign campaign;
  final VoidCallback? onJoinPressed;
  final String? campaignStatus;
  final String? requestId;

  const CampaignCard({
    super.key,
    required this.campaign,
    this.onJoinPressed,
    this.campaignStatus,
    this.requestId,
  });

  @override
  State<CampaignCard> createState() => _CampaignCardState();
}

class _CampaignCardState extends State<CampaignCard> {
  String? _status;
  String? _requestId;
  bool _isProcessing = false;

  @override
  void initState() {
    super.initState();
    _status = widget.campaignStatus;
    _requestId = widget.requestId;
    
    // If status is not provided in constructor, fetch it
    if (_status == null) {
      _fetchCampaignStatus();
    }
  }

  Future<void> _fetchCampaignStatus() async {
    final provider = Provider.of<CampaignsProvider>(context, listen: false);
    final statusData = await provider.checkCampaignStatus(widget.campaign.id);
    
    if (statusData != null && mounted) {
      setState(() {
        _status = statusData['status'];
        _requestId = statusData['request_id'].toString();
      });
    }
  }

  Future<void> _handleJoinCampaign() async {
    if (_isProcessing) return;

    // Show confirmation dialog
    final confirmed = await _showJoinConfirmationDialog();
    if (!confirmed) return;

    setState(() => _isProcessing = true);
    
    final provider = Provider.of<CampaignsProvider>(context, listen: false);
    final success = await provider.joinCampaign(widget.campaign.id);
    
    if (success && mounted) {
      setState(() {
        _status = 'applied';
        _isProcessing = false;
      });
      _showSuccessDialog('Successfully applied for the campaign!');
    } else if (mounted) {
      setState(() => _isProcessing = false);
      _showErrorDialog('Failed to apply for campaign. Please try again.');
    }
  }

  Future<void> _handleCancelRequest() async {
    if (_isProcessing || _requestId == null) return;

    // Show confirmation dialog
    final confirmed = await _showCancelConfirmationDialog();
    if (!confirmed) return;

    setState(() => _isProcessing = true);
    
    final provider = Provider.of<CampaignsProvider>(context, listen: false);
    final success = await provider.cancelCampaignRequest(_requestId!);
    
    if (success && mounted) {
      setState(() {
        _status = 'pending';
        _requestId = null;
        _isProcessing = false;
      });
      _showSuccessDialog('Campaign request cancelled successfully!');
    } else if (mounted) {
      setState(() => _isProcessing = false);
      _showErrorDialog('Failed to cancel request. Please try again.');
    }
  }

  Future<bool> _showJoinConfirmationDialog() async {
    return await showDialog<bool>(
      context: context,
      barrierDismissible: true,
      builder: (BuildContext context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          title: Text(
            'Join Campaign',
            style: AppTextStyle.base.copyWith(
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Are you sure you want to join this campaign?',
                style: AppTextStyle.base.copyWith(
                  fontSize: 14,
                  color: Colors.grey[700],
                ),
              ),
              const SizedBox(height: 8),
              Text(
                'Campaign: ${widget.campaign.name}',
                style: AppTextStyle.base.copyWith(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                ),
              ),
              Text(
                'Target: ${widget.campaign.targetKilometers} km',
                style: AppTextStyle.base.copyWith(
                  fontSize: 14,
                  color: Colors.grey[600],
                ),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(false),
              child: Text(
                'Cancel',
                style: AppTextStyle.base.copyWith(
                  color: Colors.grey[600],
                ),
              ),
            ),
            ElevatedButton(
              onPressed: () => Navigator.of(context).pop(true),
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF6C5CE7),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              child: Text(
                'Join',
                style: AppTextStyle.base.copyWith(
                  color: Colors.white,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ],
        );
      },
    ) ?? false;
  }

  Future<bool> _showCancelConfirmationDialog() async {
    return await showDialog<bool>(
      context: context,
      barrierDismissible: true,
      builder: (BuildContext context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          title: Text(
            'Cancel Request',
            style: AppTextStyle.base.copyWith(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Colors.red,
            ),
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Are you sure you want to cancel your request for this campaign?',
                style: AppTextStyle.base.copyWith(
                  fontSize: 14,
                  color: Colors.grey[700],
                ),
              ),
              const SizedBox(height: 8),
              Text(
                'Campaign: ${widget.campaign.name}',
                style: AppTextStyle.base.copyWith(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(false),
              child: Text(
                'No, Keep It',
                style: AppTextStyle.base.copyWith(
                  color: Colors.grey[600],
                ),
              ),
            ),
            ElevatedButton(
              onPressed: () => Navigator.of(context).pop(true),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.red,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              child: Text(
                'Yes, Cancel',
                style: AppTextStyle.base.copyWith(
                  color: Colors.white,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ],
        );
      },
    ) ?? false;
  }

  void _showSuccessDialog(String message) {
    showDialog(
      context: context,
      barrierDismissible: true,
      builder: (BuildContext context) {
        Future.delayed(const Duration(seconds: 2), () {
          if (mounted) {
            Navigator.of(context).pop();
          }
        });
        
        return AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                Icons.check_circle,
                size: 48,
                color: Colors.green,
              ),
              const SizedBox(height: 16),
              Text(
                message,
                textAlign: TextAlign.center,
                style: AppTextStyle.base.copyWith(
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  void _showErrorDialog(String message) {
    showDialog(
      context: context,
      barrierDismissible: true,
      builder: (BuildContext context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          title: Text(
            'Error',
            style: AppTextStyle.base.copyWith(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Colors.red,
            ),
          ),
          content: Text(
            message,
            style: AppTextStyle.base.copyWith(
              fontSize: 14,
              color: Colors.grey[700],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: Text(
                'OK',
                style: AppTextStyle.base.copyWith(
                  color: const Color(0xFF6C5CE7),
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ],
        );
      },
    );
  }

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
                      widget.campaign.name,
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
    if (widget.campaign.logoPath.isEmpty) {
      return _buildPlaceholderImage();
    }

    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: Container(
        width: 60,
        height: 60,
        decoration: BoxDecoration(
          color: _getStatusColor().withOpacity(0.1),
          borderRadius: BorderRadius.circular(12),
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(12),
          child: Image.network(
            widget.campaign.logoPath,
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
        color: _getStatusColor().withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Icon(
        Icons.campaign,
        color: _getStatusColor(),
        size: 30,
      ),
    );
  }

  Widget _buildLoadingImage() {
    return Container(
      decoration: BoxDecoration(
        color: _getStatusColor().withOpacity(0.1),
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
          '${_formatDate(widget.campaign.startDate)} - ${_formatDate(widget.campaign.endDate)}',
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
              color: Color(0xFF6CCE7),
            ),
            const SizedBox(width: 6),
            Text(
              '${widget.campaign.targetKilometers} kms',
              style: AppTextStyle.base.copyWith(
                fontSize: 12,
                color: Colors.grey[600],
              ),
            ),
            const SizedBox(width: 5),
            _buildDriverCount(),
          ],
        ),
        _buildActionButton(),
      ],
    );
  }

  Widget _buildActionButton() {
    // If status is not loaded yet, show loading
    if (_status == null) {
      return const SizedBox(
        width: 24,
        height: 24,
        child: CircularProgressIndicator(strokeWidth: 2),
      );
    }

    // If processing, show loading
    if (_isProcessing) {
      return const SizedBox(
        width: 24,
        height: 24,
        child: CircularProgressIndicator(strokeWidth: 2),
      );
    }

    switch (_status!.toLowerCase()) {
      case 'pending':
        return _buildJoinButton();
      case 'applied':
        return _buildCancelButton();
      case 'approved':
        return _buildCurrentCampaignBadge();
      case 'rejected':
        return _buildRejectedBadge();
      default:
        return _buildJoinButton(); // Default to join button
    }
  }

  Widget _buildJoinButton() {
    return ElevatedButton(
      onPressed: _handleJoinCampaign,
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

  Widget _buildCancelButton() {
    return ElevatedButton(
      onPressed: _handleCancelRequest,
      style: ElevatedButton.styleFrom(
        backgroundColor: Colors.grey[300],
        foregroundColor: Colors.black87,
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
        'Cancel',
        style: AppTextStyle.base.copyWith(
          fontSize: 12,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }

  Widget _buildCurrentCampaignBadge() {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: 12,
        vertical: 6,
      ),
      decoration: BoxDecoration(
        color: Colors.green.withOpacity(0.1),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: Colors.green,
          width: 1,
        ),
      ),
      child: Row(
        children: [
          const Icon(
            Icons.check_circle,
            size: 14,
            color: Colors.green,
          ),
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

  Widget _buildRejectedBadge() {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: 12,
        vertical: 6,
      ),
      decoration: BoxDecoration(
        color: Colors.red.withOpacity(0.1),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: Colors.red,
          width: 1,
        ),
      ),
      child: Row(
        children: [
          const Icon(
            Icons.cancel,
            size: 14,
            color: Colors.red,
          ),
          const SizedBox(width: 6),
          Text(
            'Rejected',
            style: AppTextStyle.base.copyWith(
              fontSize: 12,
              color: Colors.red,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
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

  Color _getStatusColor() {
    switch (_status?.toLowerCase()) {
      case 'approved':
        return Colors.green;
      case 'rejected':
        return Colors.red;
      case 'applied':
        return Colors.orange;
      case 'pending':
        return Colors.blue;
      default:
        return const Color(0xFF6C5CE7);
    }
  }
}