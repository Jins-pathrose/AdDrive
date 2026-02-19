import 'package:addrive/Controller/MyRide/myride.dart';
import 'package:addrive/View/Screens/imageuploads.dart';
import 'package:addrive/View/Widgets/appfont.dart';
import 'package:addrive/View/Widgets/notificationicon.dart';
import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:provider/provider.dart';

class MyRidePage extends StatelessWidget {
  const MyRidePage({super.key});

  @override
  Widget build(BuildContext context) {
    // Initialize location and fetch campaign when widget builds
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final rideProvider = context.read<RideProvider>();
      rideProvider.initializeLocation();
      rideProvider.fetchActiveCampaign(); // Add this line
      rideProvider.loadRideState();
    });

    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Consumer<RideProvider>(
          builder: (context, rideProvider, child) {
            return Column(
              children: [
                // Header (unchanged)
                Padding(
                  padding: const EdgeInsets.all(18.0),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        '  My Ride',
                        style: AppTextStyle.base.copyWith(
                          fontSize: 24,
                          fontWeight: FontWeight.w600,
                          color: Colors.black,
                        ),
                      ),
                                const NotificationIcon(), 

                      // Container(
                      //   padding: const EdgeInsets.all(8),
                      //   decoration: BoxDecoration(
                      //     color: Colors.grey[100],
                      //     shape: BoxShape.circle,
                      //   ),
                      //   child: Stack(
                      //     children: [
                      //       const Icon(
                      //         Icons.notifications_outlined,
                      //         color: Colors.black87,
                      //         size: 24,
                      //       ),
                      //       Positioned(
                      //         right: 0,
                      //         top: 0,
                      //         child: Container(
                      //           width: 8,
                      //           height: 8,
                      //           decoration: const BoxDecoration(
                      //             color: Colors.red,
                      //             shape: BoxShape.circle,
                      //           ),
                      //         ),
                      //       ),
                      //     ],
                      //   ),
                      // ),
                    ],
                  ),
                ),

                // Map Container
                // Expanded map section
                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16.0),
                    child: Container(
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(20),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.grey.withOpacity(0.3),
                            spreadRadius: 2,
                            blurRadius: 8,
                            offset: const Offset(0, 3),
                          ),
                        ],
                      ),
                      clipBehavior: Clip.antiAlias,
                      child: Stack(
                        children: [
                          // Show map only when location is loaded
                          if (!rideProvider.isLoading &&
                              rideProvider.currentLocation != null)
                            FlutterMap(
                              mapController: rideProvider
                                  .mapController, // Add MapController to your provider
                              options: MapOptions(
                                initialCenter: rideProvider.currentLocation!,
                                initialZoom: 16.0,
                                interactionOptions: const InteractionOptions(
                                  flags: InteractiveFlag.all,
                                ),
                                onMapReady: () {
                                  // Use a slight delay to ensure map is fully initialized
                                  Future.delayed(
                                    const Duration(milliseconds: 200),
                                    () {
                                      if (rideProvider.currentLocation !=
                                          null) {
                                        rideProvider.mapController.move(
                                          rideProvider.currentLocation!,
                                          16.0,
                                        );
                                      }
                                    },
                                  );
                                },
                              ),
                              children: [
                                TileLayer(
                                  urlTemplate:
                                      'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                                  userAgentPackageName: 'com.techfifo.addrive',
                                  tileProvider: NetworkTileProvider(),
                                  tileBuilder: (context, tileWidget, tile) {
                                    return ClipRect(child: tileWidget);
                                  },
                                  errorImage: const NetworkImage(
                                    'https://via.placeholder.com/256/cccccc/ffffff?text=Map+Tile',
                                  ),
                                ),
                                // Accuracy circle (background)
                                CircleLayer(
                                  circles: [
                                    CircleMarker(
                                      point: rideProvider.currentLocation!,
                                      radius: 20,
                                      useRadiusInMeter: false,
                                      color: Colors.blue.withOpacity(0.15),
                                      borderColor: Colors.blue.withOpacity(0.3),
                                      borderStrokeWidth: 1.5,
                                    ),
                                  ],
                                ),
                                // Car Driver Marker
                                MarkerLayer(
                                  markers: [
                                    Marker(
                                      width: 60.0,
                                      height: 60.0,
                                      point: rideProvider.currentLocation!,
                                      child: Container(
                                        decoration: BoxDecoration(
                                          color: Colors.white,
                                          shape: BoxShape.circle,
                                          boxShadow: [
                                            BoxShadow(
                                              color: Colors.black.withOpacity(
                                                0.2,
                                              ),
                                              blurRadius: 8,
                                              spreadRadius: 1,
                                              offset: const Offset(0, 2),
                                            ),
                                          ],
                                          border: Border.all(
                                            color: const Color(0xFF2196F3),
                                            width: 3,
                                          ),
                                        ),
                                        child: Stack(
                                          alignment: Alignment.center,
                                          children: [
                                            // Main car icon
                                            const Icon(
                                              Icons.directions_car,
                                              color: Color(0xFF2196F3),
                                              size: 32,
                                            ),
                                            // Small pulse indicator
                                            Positioned(
                                              bottom: 8,
                                              child: Container(
                                                width: 8,
                                                height: 8,
                                                decoration: BoxDecoration(
                                                  color: const Color(
                                                    0xFF4CAF50,
                                                  ),
                                                  shape: BoxShape.circle,
                                                  boxShadow: [
                                                    BoxShadow(
                                                      color: const Color(
                                                        0xFF4CAF50,
                                                      ).withOpacity(0.5),
                                                      blurRadius: 4,
                                                      spreadRadius: 1,
                                                    ),
                                                  ],
                                                ),
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                            )
                          else if (!rideProvider.isLoading &&
                              rideProvider.currentLocation == null)
                            // Show error if location failed to load
                            Container(
                              color: Colors.white,
                              child: Center(
                                child: Column(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Icon(
                                      Icons.location_off,
                                      size: 48,
                                      color: Colors.grey,
                                    ),
                                    SizedBox(height: 16),
                                    Text(
                                      'Unable to get location',
                                      style: TextStyle(
                                        fontSize: 16,
                                        color: Colors.grey[600],
                                      ),
                                    ),
                                    SizedBox(height: 8),
                                    Text(
                                      'Please enable location services',
                                      style: TextStyle(
                                        fontSize: 14,
                                        color: Colors.grey,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),

                          // Loading overlay - Show when location is loading OR when map is initializing
                          if (rideProvider.isLoading ||
                              rideProvider.currentLocation == null)
                            Container(
                              color: Colors.white,
                              child: const Center(
                                child: Column(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    CircularProgressIndicator(
                                      valueColor: AlwaysStoppedAnimation<Color>(
                                        Colors.blue,
                                      ),
                                    ),
                                    SizedBox(height: 16),
                                    Text(
                                      'Getting your location...',
                                      style: TextStyle(
                                        fontSize: 14,
                                        color: Colors.grey,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),

                          // Map controls - Only show when map is loaded
                          if (!rideProvider.isLoading &&
                              rideProvider.currentLocation != null)
                            Positioned(
                              bottom: 16,
                              right: 16,
                              child: FloatingActionButton(
                                backgroundColor: Colors.white,
                                elevation: 4,
                                onPressed: () {
                                  rideProvider.recenterMap();
                                },
                                child: const Icon(
                                  Icons.my_location,
                                  color: Color(0xFF5B4BDB),
                                  size: 24,
                                ),
                              ),
                            ),
                        ],
                      ),
                    ),
                  ),
                ),

                // Ride Info Card
                Container(
                  margin: const EdgeInsets.all(16),
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(20),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.grey.withOpacity(0.2),
                        spreadRadius: 2,
                        blurRadius: 8,
                        offset: const Offset(0, -2),
                      ),
                    ],
                  ),
                  child: Consumer<RideProvider>(
                    builder: (context, rideProvider, child) {
                      // Show loading while fetching campaign
                      if (rideProvider.isFetchingCampaign) {
                        return const Center(
                          child: CircularProgressIndicator(
                            valueColor: AlwaysStoppedAnimation<Color>(
                              Color(0xFF5B4AC7),
                            ),
                          ),
                        );
                      }

                      // Show campaign data if available
                      if (rideProvider.activeCampaign != null) {
                        final campaign = rideProvider.activeCampaign!;

                        // Format dates
                        final startDate = _formatDate(campaign.startDate);
                        final endDate = _formatDate(campaign.endDate);

                        return Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      startDate, // Use campaign start date
                                      style: AppTextStyle.base.copyWith(
                                        fontSize: 12,
                                        color: Colors.grey[600],
                                      ),
                                    ),
                                    const SizedBox(height: 4),
                                    Text(
                                      '${campaign.targetKilometers ?? 0} Kms', // Use campaign target
                                      style: AppTextStyle.base.copyWith(
                                        fontSize: 21,
                                        fontWeight: FontWeight.bold,
                                        color: Color(0xFF5B4AC7),
                                      ),
                                    ),
                                    const SizedBox(height: 2),
                                    Text(
                                      campaign.status, // Use campaign status
                                      style: AppTextStyle.base.copyWith(
                                        fontSize: 12,
                                        color: campaign.status == 'Ongoing'
                                            ? Colors.green
                                            : Colors.orange,
                                      ),
                                    ),
                                  ],
                                ),
                                // Campaign Logo
                                Container(
                                  width: 60,
                                  height: 60,
                                  decoration: BoxDecoration(
                                    color: Colors.red,
                                    borderRadius: BorderRadius.circular(12),
                                    border: Border.all(
                                      color: Colors.white,
                                      width: 2,
                                    ),
                                    boxShadow: [
                                      BoxShadow(
                                        color: Colors.grey.withOpacity(0.3),
                                        spreadRadius: 2,
                                        blurRadius: 8,
                                        offset: const Offset(0, 3),
                                      ),
                                    ],
                                  ),
                                  child: ClipRRect(
                                    borderRadius: BorderRadius.circular(12),
                                    child: campaign.campaignProfile != null
                                        ? Image.network(
                                            campaign.campaignProfile!,
                                            fit: BoxFit.cover,
                                            errorBuilder:
                                                (context, error, stackTrace) {
                                                  return _buildDefaultCampaignIcon(
                                                    campaign.campaignName,
                                                  );
                                                },
                                            loadingBuilder:
                                                (
                                                  context,
                                                  child,
                                                  loadingProgress,
                                                ) {
                                                  if (loadingProgress == null)
                                                    return child;
                                                  return const Center(
                                                    child: CircularProgressIndicator(
                                                      valueColor:
                                                          AlwaysStoppedAnimation<
                                                            Color
                                                          >(Colors.white),
                                                      strokeWidth: 2,
                                                    ),
                                                  );
                                                },
                                          )
                                        : _buildDefaultCampaignIcon(
                                            campaign.campaignName,
                                          ),
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 20),
                            // Replace the button section with this:
                            SizedBox(
                              width: double.infinity,
                              child: ElevatedButton(
                                onPressed: () {
                                  if (rideProvider.isRideActive) {
                                    // Call pause function
                                    rideProvider.pauseRide();
                                  } else {
                                    // Call start ride function
                                    _handleStartRide(context, rideProvider);
                                  }
                                },
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: rideProvider.isRideActive
                                      ? Colors
                                            .orange // Color for Pause button
                                      : const Color(
                                          0xFF5B4AC7,
                                        ), // Color for Start button
                                  padding: const EdgeInsets.symmetric(
                                    vertical: 16,
                                  ),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(30),
                                  ),
                                ),
                                child: Text(
                                  rideProvider.isRideActive
                                      ? 'Pause Ride'
                                      : 'Start a Ride',
                                  style: AppTextStyle.base.copyWith(
                                    fontSize: 20,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.white,
                                  ),
                                ),
                              ),
                            ),
                            const SizedBox(height: 12),
                            Center(
                              child: Text(
                                'Campaign ends on $endDate', // Use campaign end date
                                style: AppTextStyle.base.copyWith(
                                  fontSize: 12,
                                  color: Colors.grey[600],
                                ),
                              ),
                            ),
                            // Show campaign name
                            const SizedBox(height: 8),
                            Center(
                              child: Text(
                                campaign.campaignName,
                                style: AppTextStyle.base.copyWith(
                                  fontSize: 14,
                                  fontWeight: FontWeight.w600,
                                  color: Colors.black87,
                                ),
                              ),
                            ),
                            // Show error if any
                            if (rideProvider.error != null)
                              Padding(
                                padding: const EdgeInsets.only(top: 8),
                                child: Text(
                                  "Please try again later",
                                  style: AppTextStyle.base.copyWith(
                                    fontSize: 12,
                                    color: Colors.red,
                                  ),
                                  textAlign: TextAlign.center,
                                ),
                              ),
                          ],
                        );
                      } else {
                        // No active campaign
                        return Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Center(
                              child: Column(
                                children: [
                                  Icon(
                                    Icons.campaign_outlined,
                                    size: 40,
                                    color: Colors.grey[400],
                                  ),
                                  const SizedBox(height: 12),
                                  Text(
                                    'No Active Campaign',
                                    style: AppTextStyle.base.copyWith(
                                      fontSize: 16,
                                      color: Colors.grey[600],
                                    ),
                                  ),
                                  const SizedBox(height: 8),
                                  Text(
                                    'You are not currently enrolled in any campaign',
                                    style: AppTextStyle.base.copyWith(
                                      fontSize: 12,
                                      color: Colors.grey[500],
                                    ),
                                    textAlign: TextAlign.center,
                                  ),
                                ],
                              ),
                            ),
                            const SizedBox(height: 20),
                            SizedBox(
                              width: double.infinity,
                              child: ElevatedButton(
                                onPressed: rideProvider.activeCampaign != null
                                    ? () => _handleStartRide(
                                        context,
                                        rideProvider,
                                      )
                                    : null,
                                style: ElevatedButton.styleFrom(
                                  backgroundColor:
                                      rideProvider.activeCampaign != null
                                      ? const Color(0xFF5B4AC7)
                                      : Colors.grey[300],
                                  padding: const EdgeInsets.symmetric(
                                    vertical: 16,
                                  ),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(30),
                                  ),
                                ),
                                child: Text(
                                  'Start a Ride',
                                  style: AppTextStyle.base.copyWith(
                                    fontSize: 20,
                                    fontWeight: FontWeight.bold,
                                    color: rideProvider.activeCampaign != null
                                        ? Colors.white
                                        : Colors.grey[600],
                                  ),
                                ),
                              ),
                            ),
                          ],
                        );
                      }
                    },
                  ),
                ),
              ],
            );
          },
        ),
      ),
    );
  }

  // Add these helper methods to your MyRidePage class
  String _formatDate(String dateString) {
    try {
      final date = DateTime.parse(dateString);
      final day = date.day;
      final month = _getMonthName(date.month);
      final year = date.year;
      return '$day $month $year';
    } catch (e) {
      return dateString;
    }
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

  Widget _buildDefaultCampaignIcon(String campaignName) {
    return Container(
      color: const Color(0xFF5B4AC7),
      child: Center(
        child: Text(
          campaignName.isNotEmpty ? campaignName[0] : 'C',
          style: const TextStyle(
            color: Colors.white,
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
    );
  }

  void _handleStartRide(BuildContext context, RideProvider rideProvider) async {
    // Check if there's an active campaign
    if (rideProvider.activeCampaign == null) {
      showDialog(
        context: context,
        builder: (context) => AlertDialog(
          title: Text('No Active Campaign'),
          content: Text(
            'You need to be enrolled in a campaign to start a ride.',
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: Text('OK'),
            ),
          ],
        ),
      );
      return;
    }

    final campaignId = rideProvider.activeCampaign!.id;

    // Show loading dialog
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        content: Row(
          children: [
            CircularProgressIndicator(),
            SizedBox(width: 20),
            Text('Checking upload status...'),
          ],
        ),
      ),
    );

    // Check weekly upload status first
    await rideProvider.checkWeeklyUploadStatus(context, campaignId);

    // Dismiss loading dialog
    Navigator.of(context).pop();

    // Check has_uploaded_before
    final shouldNavigate = rideProvider.shouldNavigateToUpload;

if (shouldNavigate) {
      // Navigate to ImageUploads
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => ImageUploads(campaignId: campaignId.toString()),
        ),
      );
      return;
    }

    // User has uploaded before, continue with ride start
    // Show loading dialog for ride start
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        content: Row(
          children: [
            CircularProgressIndicator(),
            SizedBox(width: 20),
            Text('Starting ride...'),
          ],
        ),
      ),
    );

    // Start ride with tracking
    bool success = await rideProvider.startRideWithTracking(
      context,
      campaignId,
    );

    // Dismiss loading dialog
    Navigator.of(context).pop();

    if (success && rideProvider.isRideActive) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Ride started successfully!'),
          backgroundColor: Colors.green,
          duration: Duration(seconds: 2),
        ),
      );
    } else {
      showDialog(
        context: context,
        builder: (context) => AlertDialog(
          title: Text('Failed to Start Ride'),
          content: Text(
            'Unable to start ride. Please try again.',
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: Text('OK'),
            ),
          ],
        ),
      );
    }
  }
}
