import 'package:addrive/Controller/Hompage/activecampain_provider.dart';
import 'package:addrive/Controller/Profile/myprofile.dart';
import 'package:addrive/View/BottomNavigator/bottomnavigator.dart';
import 'package:addrive/View/Widgets/appbackground.dart';
import 'package:addrive/View/Widgets/appfont.dart';
import 'package:addrive/View/Widgets/notificationicon.dart';
import 'package:flutter/material.dart';
import 'package:lottie/lottie.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';

class HomePage extends StatelessWidget {
  const HomePage({super.key});

  Future<void> _refreshData(BuildContext context) async {
    // Get providers
    final campaignProvider = context.read<ActiveCampaignProvider>();
    final profileProvider = context.read<ProfileProvider>();
    
    // Fetch both campaign and profile data simultaneously
    await Future.wait([
      campaignProvider.fetchActiveCampaign(),
      profileProvider.fetchProfileData(),
    ]);
  }

  @override
  Widget build(BuildContext context) {
    // Fetch campaign data when widget loads
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final campaignProvider = context.read<ActiveCampaignProvider>();
      campaignProvider.fetchActiveCampaign();
    });
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final personalDetailsProvider = context.read<ProfileProvider>();
      personalDetailsProvider.fetchProfileData();
    });

    return Scaffold(
      backgroundColor: Colors.white,
      body: Stack(
        children: [
          BackgroundDecoration(),
          SafeArea(
            child: Consumer<ActiveCampaignProvider>(
              builder: (context, campaignProvider, child) {
                // Check states first
                if (campaignProvider.isLoading) {
                  return _buildFullScreenWithHeader(
                    context,
                    Center(
                      child: RefreshIndicator(
                        onRefresh: () => _refreshData(context),
                        color: const Color(0xFF6C3FE4),
                        child: SingleChildScrollView(
                          physics: const AlwaysScrollableScrollPhysics(),
                          child: _buildCenteredContent(_buildCampaignLoading()),
                        ),
                      ),
                    ),
                  );
                }

                if (campaignProvider.error != null) {
                  return _buildFullScreenWithHeader(
                    context,
                    Center(
                      child: RefreshIndicator(
                        onRefresh: () => _refreshData(context),
                        color: const Color(0xFF6C3FE4),
                        child: SingleChildScrollView(
                          physics: const AlwaysScrollableScrollPhysics(),
                          child: _buildCenteredContent(
                            _buildCampaignError(campaignProvider.error!, context),
                          ),
                        ),
                      ),
                    ),
                  );
                }

                final campaignData = campaignProvider.campaignData;

                if (campaignData == null ||
                    campaignData['status'] != 'active_campaign') {
                  return _buildFullScreenWithHeader(
                    context,
                    RefreshIndicator(
                      onRefresh: () => _refreshData(context),
                      color: const Color(0xFF6C3FE4),
                      child: SingleChildScrollView(
                        physics: const AlwaysScrollableScrollPhysics(),
                        child: _buildCenteredContent(
                          _buildNoActiveCampaignHandler(context),
                        ),
                      ),
                    ),
                  );
                }

                // Normal layout for active campaign
                final campaign = campaignData['campaign'];
                return RefreshIndicator(
                  onRefresh: () => _refreshData(context),
                  color: const Color(0xFF6C3FE4),
                  backgroundColor: Colors.white,
                  child: SingleChildScrollView(
                    physics: const AlwaysScrollableScrollPhysics(),
                    padding: const EdgeInsets.all(12.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        SizedBox(height: 20),
                        // Header
                        _buildHeader(context),
                        const SizedBox(height: 8),

                        // Task Card with Campaign
                        _buildTaskCardWithCampaign(campaign),
                        const SizedBox(height: 8),

                        // Participants Section
                        _buildParticipantsSection(),
                      ],
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  // Build header section
  Widget _buildHeader(BuildContext context) {
  return Padding(
    padding: const EdgeInsets.symmetric(horizontal: 5),
    child: Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Expanded( // ✅ Constrains left side properly
          child: Consumer<ProfileProvider>(
            builder: (context, profileProvider, child) {
              final profile = profileProvider.profileData?.profile;

              return Row(
                children: [
                  CircleAvatar(
                    radius: 25,
                    backgroundImage:
                        (profile?.profilePicture?.isNotEmpty ?? false)
                            ? NetworkImage(profile!.profilePicture)
                                as ImageProvider
                            : const AssetImage(
                                'assets/images/placeholder_avatar.jpg',
                              ),
                  ),
                  const SizedBox(width: 12),

                  // ✅ Constrain the text column
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          'Hello!',
                          style: AppTextStyle.base.copyWith(
                            fontSize: 12,
                            color: Colors.grey[600],
                          ),
                        ),
                        Text(
                          profile?.fullName?.isNotEmpty ?? false
                              ? profile!.fullName
                              : 'Driver',
                          maxLines: 1, // ✅ Prevent overflow
                          overflow: TextOverflow.ellipsis, // ✅ Add ...
                          style: AppTextStyle.base.copyWith(
                            fontSize: 17,
                            fontWeight: FontWeight.bold,
                            color: Colors.black87,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              );
            },
          ),
        ),

        const SizedBox(width: 10),

        const NotificationIcon(), // right side icon
      ],
    ),
  );
}


  // Build full screen with header and centered content
  Widget _buildFullScreenWithHeader(
    BuildContext context,
    Widget centeredContent,
  ) {
    return Column(
      children: [
        // Header at top
        Padding(
          padding: const EdgeInsets.all(12.0),
          child: _buildHeader(context),
        ),
        // Centered content takes remaining space
        Expanded(child: centeredContent),
      ],
    );
  }

  // Build centered content wrapper
  Widget _buildCenteredContent(Widget content) {
    return Center(
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: content,
      ),
    );
  }

  // Campaign Loading Widget
  Widget _buildCampaignLoading() {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        CircularProgressIndicator(
          strokeWidth: 2,
          valueColor: AlwaysStoppedAnimation<Color>(Color(0xFFB24BF3)),
        ),
        const SizedBox(height: 16),
        Text(
          'Loading campaign...',
          style: AppTextStyle.base.copyWith(
            fontSize: 14,
            color: Colors.grey[600],
          ),
        ),
      ],
    );
  }

  // Campaign Error Widget
  Widget _buildCampaignError(String error, BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(Icons.error_outline, color: Colors.red, size: 40),
        SizedBox(height: 12),
        Padding(
          padding: const EdgeInsets.all(8.0),
          child: Center(
            child: Text(
              'Please check your internet connection',
              style: AppTextStyle.base.copyWith(
                color: const Color(0xFF6C5CE7),
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ),
       
        SizedBox(height: 16),
        ElevatedButton(
          onPressed: () {
            final campaignProvider = context.read<ActiveCampaignProvider>();
            campaignProvider.fetchActiveCampaign();
          },
          style: ElevatedButton.styleFrom(
            backgroundColor: const Color(0xFF6C5CE7),
            foregroundColor: Colors.white,
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(20),
            ),
          ),
          child: Text('Retry'),
        ),
      ],
    );
  }

  // Build "No Active Campaign" Handler
  Widget _buildNoActiveCampaignHandler(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 10,
            offset: Offset(0, 4),
          ),
          BoxShadow(
            color: Colors.white.withOpacity(0.8),
            blurRadius: 20,
            spreadRadius: -5,
            offset: Offset(0, 0),
          ),
        ],
        border: Border.all(color: Colors.white.withOpacity(0.8), width: 1.5),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Lottie Animation
          Container(
            width: 150,
            height: 150,
            child: Lottie.asset(
              'assets/images/yellow taxi.json',
              fit: BoxFit.contain,
            ),
          ),
          const SizedBox(height: 20),

          // Title
          Text(
            'No Active Campaigns',
            style: AppTextStyle.base.copyWith(
              fontSize: 20,
              fontWeight: FontWeight.w600,
              color: Colors.black87,
            ),
          ),
          const SizedBox(height: 8),

          // Description
          Text(
            'Join exciting campaigns and compete\nwith other drivers',
            style: AppTextStyle.base.copyWith(
              fontSize: 14,
              color: Colors.black54,
              height: 1.5,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 24),

          // Button
          ElevatedButton(
            onPressed: () {
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(
                  builder: (context) => BottomNavigator(initialIndex: 2),
                ),
              );
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Color(0xFF6C3FE4),
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(horizontal: 28, vertical: 14),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              elevation: 0,
            ),
            child: Text(
              'Explore Campaigns',
              style: AppTextStyle.base.copyWith(
                fontSize: 15,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFeatureItem({required IconData icon, required String text}) {
    return Column(
      children: [
        Icon(icon, size: 24, color: Colors.white),
        const SizedBox(height: 4),
        Text(
          text,
          style: AppTextStyle.base.copyWith(
            fontSize: 10,
            color: Colors.white.withOpacity(0.8),
            fontWeight: FontWeight.w500,
          ),
        ),
      ],
    );
  }

  // Build the full task card with campaign details
 Widget _buildTaskCardWithCampaign(Map<String, dynamic> campaign) {
  return Consumer<ActiveCampaignProvider>(
    builder: (context, campaignProvider, child) {
      final progressData = campaignProvider.campaignData?['progress'];
      
      // Handle both data formats
      Map<String, dynamic>? currentProgress;
      double userPercentage = 0.0;
      double currentKm = 0.0;
      double targetKm = 100.0;
      
      if (progressData != null) {
        // Get current driver progress
        currentProgress = campaignProvider.getCurrentDriverProgress();
        
        // Get target km
        if (campaignProvider.isAnalyticsFormat) {
          targetKm = progressData['target_km']?.toDouble() ?? 
                    (double.tryParse(progressData['target']?.toString() ?? '100.0') ?? 100.0);
        } else {
          targetKm = progressData['target_km']?.toDouble() ?? 100.0;
        }
        
        // Get percentage
        if (currentProgress != null && currentProgress['percentage'] != null) {
          try {
            final percentageStr = currentProgress['percentage'].toString();
            userPercentage = double.parse(percentageStr.replaceAll('%', ''));
          } catch (e) {
            userPercentage = 0.0;
          }
        }
        
        // Get current km
        if (currentProgress != null) {
          currentKm = currentProgress['cumulative_km']?.toDouble() ?? 
                     currentProgress['total_lifetime_km']?.toDouble() ?? 0.0;
        }
      }
      
      // Parse and format dates
      final startDate = DateTime.parse(campaign['start_date']);
      final endDate = DateTime.parse(campaign['end_date']);
      final dateFormat = DateFormat('dd MMM yyyy');
      final formattedStartDate = dateFormat.format(startDate);
      final formattedEndDate = dateFormat.format(endDate);

      // Determine text based on percentage
      String progressText;
      if (userPercentage >= 80) {
        progressText = 'Your today\'s task\nalmost done !!';
      } else if (userPercentage >= 50) {
        progressText = 'Great progress!\nKeep going !!';
      } else if (userPercentage >= 25) {
        progressText = 'You\'re on track!\nContinue pushing !!';
      } else if (userPercentage > 0) {
        progressText = 'Getting started!\nEvery km counts !!';
      } else {
        progressText = 'Ready to start?\nBegin your first ride !!';
      }
      
      return Container(
        margin: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: const Color(0xFFB24BF3).withOpacity(0.1),
          borderRadius: BorderRadius.circular(24),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Top Purple Section
            Container(
              padding: const EdgeInsets.all(18),
              decoration: const BoxDecoration(
                gradient: LinearGradient(
                  colors: [Color(0xFF6C3FE4), Color(0xFF6C3FE4)],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(22),
                  topRight: Radius.circular(22),
                  bottomLeft: Radius.circular(22),
                  bottomRight: Radius.circular(22),
                ),
              ),
              child: Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          progressText,
                          style: AppTextStyle.base.copyWith(
                            color: Colors.white,
                            fontSize: 14,
                            fontWeight: FontWeight.w600,
                            height: 1.3,
                          ),
                        ),
                        const SizedBox(height: 16),
                        ElevatedButton(
                          onPressed: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => BottomNavigator(initialIndex: 1), 
                              )
                            );
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.white,
                            foregroundColor: const Color(0xFF7B2CBF),
                            padding: const EdgeInsets.symmetric(
                              horizontal: 24,
                              vertical: 12,
                            ),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(24),
                            ),
                            elevation: 0,
                          ),
                          child: Text(
                            userPercentage > 0 ? 'Continue Ride' : 'Start Ride',
                            style: AppTextStyle.base.copyWith(
                              fontSize: 12,
                              fontWeight: FontWeight.w600,
                              color: const Color(0xFF6C3FE4),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 20),
                  SizedBox(
                    width: 60,
                    height: 60,
                    child: Stack(
                      alignment: Alignment.center,
                      children: [
                        SizedBox(
                          width: 100,
                          height: 100,
                          child: CircularProgressIndicator(
                            value: userPercentage / 100,
                            strokeWidth: 5,
                            backgroundColor: Colors.white.withOpacity(0.3),
                            valueColor: const AlwaysStoppedAnimation<Color>(
                              Colors.white,
                            ),
                          ),
                        ),
                        Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Text(
                              '${userPercentage.toStringAsFixed(0)}%',
                              style: AppTextStyle.base.copyWith(
                                color: Colors.white,
                                fontSize: 14,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            const SizedBox(height: 2),
                            Text(
                              '${currentKm.toStringAsFixed(1)} km',
                              style: AppTextStyle.base.copyWith(
                                color: Colors.white.withOpacity(0.8),
                                fontSize: 9,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),

            // Campaign Details Container
            Container(
              padding: const EdgeInsets.only(
                left: 24,
                right: 24,
                bottom: 24,
                top: 10,
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 8,
                    ),
                    decoration: BoxDecoration(
                      gradient: const LinearGradient(
                        colors: [Color(0xFFB24BF3), Color(0xFF9D4EDD)],
                      ),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Text(
                      'Current Campaign Details',
                      style: AppTextStyle.base.copyWith(
                        color: Colors.white,
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                  const SizedBox(height: 10),
                  Text(
                    campaign['campaign_name'] ?? 'Active Trip Campaign',
                    style: AppTextStyle.base.copyWith(
                      fontSize: 19,
                      fontWeight: FontWeight.bold,
                      color: Colors.black87,
                    ),
                  ),
                  const SizedBox(height: 5),
                  Row(
                    children: [
                      Icon(
                        Icons.calendar_today,
                        size: 14,
                        color: Colors.purple.shade300,
                      ),
                      const SizedBox(width: 8),
                      Text(
                        '$formattedStartDate - $formattedEndDate',
                        style: AppTextStyle.base.copyWith(
                          fontSize: 13,
                          color: Colors.black54,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 2),
                  Row(
                    children: [
                      Icon(
                        Icons.directions_car,
                        size: 15,
                        color: Colors.purple.shade300,
                      ),
                      const SizedBox(width: 8),
                      Text(
                        'Target: ${targetKm.toStringAsFixed(0)} kms',
                        style: AppTextStyle.base.copyWith(
                          fontSize: 13,
                          color: Colors.black54,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 2),
                  Row(
                    children: [
                      Icon(
                        Icons.emoji_events,
                        size: 14,
                        color: Colors.purple.shade300,
                      ),
                      const SizedBox(width: 8),
                      Text(
                        'Your Progress: ${currentKm.toStringAsFixed(1)} kms',
                        style: AppTextStyle.base.copyWith(
                          fontSize: 13,
                          color: Colors.black54,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      );
    },
  );
}

  // Build participants section
  Widget _buildParticipantsSection() {
    return Consumer<ActiveCampaignProvider>(
      builder: (context, campaignProvider, child) {
        final sortedParticipants = campaignProvider.sortedParticipants;

        if (sortedParticipants == null || sortedParticipants.isEmpty) {
          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Text(
                    'Participants',
                    style: AppTextStyle.base.copyWith(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Colors.black87,
                    ),
                  ),
                  const SizedBox(width: 8),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 2,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.grey[200],
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(
                      '0',
                      style: AppTextStyle.base.copyWith(
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                        color: Colors.black54,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              Center(
                child: Text(
                  'No participants yet',
                  style: AppTextStyle.base.copyWith(
                    fontSize: 14,
                    color: Colors.grey[600],
                  ),
                ),
              ),
            ],
          );
        }

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Participants Header
            Row(
              children: [
                Text(
                  'Participants',
                  style: AppTextStyle.base.copyWith(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Colors.black87,
                  ),
                ),
                const SizedBox(width: 8),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 8,
                    vertical: 2,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.grey[200],
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    '${sortedParticipants.length}',
                    style: AppTextStyle.base.copyWith(
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                      color: Colors.black54,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),           
            // Participant List
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Column(
                children: sortedParticipants.asMap().entries.map((entry) {
                  final index = entry.key;
                  final participant = entry.value;
                  final rank = index + 1;
                  final percentage = double.parse(
                    participant['percentage'].replaceAll('%', ''),
                  );
                  final km = participant['cumulative_km']?.toDouble() ?? 0.0;
                  final email = participant['driver'] ?? 'Unknown';
                  final profileImage = participant['profile_image'];

                  // Extract name from email
                  final name = email.split('@').first;
                  final displayName = name.length > 12
                  
                      ? '${name.substring(0, 12)}...'
                      : name;

                  // Assign color based on rank
                  Color rankColor;
                  switch (rank) {
                    case 1:
                      rankColor = const Color(0xFFFFD700); // Gold
                      break;
                    case 2:
                      rankColor = const Color(0xFFC0C0C0); // Silver
                      break;
                    case 3:
                      rankColor = const Color(0xFFCD7F32); // Bronze
                      break;
                    default:
                      rankColor = const Color(0xFF6C3FE4); // Purple
                  }

                  return _buildParticipantTile(
                    rank: rank,
                    name: displayName,
                    distance: '${km.toStringAsFixed(1)} kms',
                    percentage: percentage.toInt(),
                    color: rankColor,
                    profileImage: profileImage,
                    isCurrentUser: participant['driver_id'] == campaignProvider.currentDriverId,);
                }).toList(),
              ),
            ),
          ],
        );
      },
    );
  }

  // Updated Participant Tile with network image
  Widget _buildParticipantTile({
  required int rank,
  required String name,
  required String distance,
  required int percentage,
  required Color color,
  String? profileImage,
  bool isCurrentUser = false,
}) {
  String imageUrl;

  if (profileImage != null && profileImage.isNotEmpty) {
    if (profileImage.startsWith('http')) {
      imageUrl = profileImage;
    } else if (profileImage.startsWith('/')) {
      imageUrl = 'https://addrive.kkms.co.in$profileImage';
    } else {
      imageUrl = profileImage;
    }
  } else {
    imageUrl = ''; // Will use placeholder
  }

  // Rest of your participant tile code remains the same...
  return Container(
    margin: const EdgeInsets.only(bottom: 12),
    padding: const EdgeInsets.all(12),
    decoration: BoxDecoration(
      boxShadow: [
        BoxShadow(
          color: Colors.black.withOpacity(0.1),
          blurRadius: 8,
          offset: const Offset(0, 3),
        ),
      ],
      color: Colors.white,
      borderRadius: BorderRadius.circular(12),
      border: isCurrentUser
          ? Border.all(color: Colors.purple[200]!, width: 1.5)
          : null,
    ),
    child: Row(
      children: [
        // Rank Badge
        Container(
          width: 40,
          child: Column(
            children: [
              Container(
                width: 30,
                height: 30,
                decoration: BoxDecoration(
                  color: Colors.grey[100],
                  shape: BoxShape.circle,
                ),
                child: Center(
                  child: Text(
                    '$rank',
                    style: AppTextStyle.base.copyWith(
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                      color: Colors.black87,
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 4),
              Text(
                'Rank',
                style: AppTextStyle.base.copyWith(
                  fontSize: 10,
                  color: Colors.grey[600],
                ),
              ),
            ],
          ),
        ),
        const SizedBox(width: 12),

        // Profile Image
        imageUrl.isNotEmpty
            ? CircleAvatar(
                radius: 22,
                backgroundImage: NetworkImage(imageUrl),
                backgroundColor: Colors.grey[200],
                onBackgroundImageError: (exception, stackTrace) {
                  // Handle error if image fails to load
                },
              )
            : CircleAvatar(
                radius: 22,
                backgroundColor: Colors.grey[200],
                child: Icon(Icons.person, color: Colors.grey[500]),
              ),
        const SizedBox(width: 12),

        // Name and Distance
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
  children: [
    Expanded(
      child: Text(
        name,
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
        style: AppTextStyle.base.copyWith(
          fontSize: 15,
          fontWeight: FontWeight.w600,
          color: Colors.black87,
        ),
      ),
    ),
    if (isCurrentUser) ...[
      const SizedBox(width: 6),
      Container(
        padding: const EdgeInsets.symmetric(
          horizontal: 6,
          vertical: 2,
        ),
        decoration: BoxDecoration(
          color: Colors.purple[100],
          borderRadius: BorderRadius.circular(4),
        ),
        child: Text(
          'You',
          style: AppTextStyle.base.copyWith(
            fontSize: 10,
            color: Colors.purple[700],
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
    ],
  ],
),
              const SizedBox(height: 2),
              Text(
                distance,
                style: AppTextStyle.base.copyWith(
                  fontSize: 13,
                  color: Colors.grey[600],
                ),
              ),
            ],
          ),
        ),

        // Progress Circle
        SizedBox(
          width: 50,
          height: 50,
          child: Stack(
            alignment: Alignment.center,
            children: [
              Padding(
                padding: const EdgeInsets.all(2.0),
                child: SizedBox(
                  width: 50,
                  height: 50,
                  child: CircularProgressIndicator(
                    value: percentage / 100,
                    strokeWidth: 4,
                    backgroundColor: Colors.grey[200],
                    valueColor: AlwaysStoppedAnimation<Color>(color),
                  ),
                ),
              ),
              Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    '$percentage%',
                    style: AppTextStyle.base.copyWith(
                      color: color,
                      fontSize: 10,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ],
    ),
  );
}
}