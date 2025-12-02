// import 'package:addrive/Controller/campaigns_tab.dart';
// import 'package:addrive/View/Widgets/appbackground.dart';
// import 'package:addrive/View/Widgets/appfont.dart';
// import 'package:flutter/material.dart';
// import 'package:provider/provider.dart';
// import 'package:shared_preferences/shared_preferences.dart';

// class CampaignsPage extends StatefulWidget {
//   const CampaignsPage({super.key});

//   @override
//   State<CampaignsPage> createState() => _CampaignsPageState();
// }

// class _CampaignsPageState extends State<CampaignsPage> {
//   @override
//   void initState() {
//     super.initState();
//     _loadCampaigns();
//   }

//   Future<void> _loadCampaigns() async {
//     final prefs = await SharedPreferences.getInstance();
//     final token = prefs.getString('access_token');

//     if (token != null) {
//       await Provider.of<CampaignsProvider>(context, listen: false).fetchCampaigns(token);
//     }
//   }

//   @override
//   Widget build(BuildContext context) {
//     final tabProvider = Provider.of<CampaignTabProvider>(context);
//     final campaignsProvider = Provider.of<CampaignsProvider>(context);

//     return Scaffold(
//       backgroundColor: Colors.white,
//       body: Stack(
//         children: [
//           BackgroundDecoration(),
//           // Main content
//           SafeArea(
//             child: Column(
//               children: [
//                 Padding(
//                   padding: const EdgeInsets.all(18.0),
//                   child: Row(
//                     mainAxisAlignment: MainAxisAlignment.spaceBetween,
//                     children: [
//                       Text(
//                         'Campaigns',
//                         style: AppTextStyle.base.copyWith(
//                           fontSize: 24,
//                           fontWeight: FontWeight.bold,
//                           color: Colors.black,
//                         ),
//                       ),
//                       Container(
//                         padding: const EdgeInsets.all(8),
//                         decoration: BoxDecoration(
//                           color: Colors.grey[100],
//                           shape: BoxShape.circle,
//                         ),
//                         child: Stack(
//                           children: [
//                             const Icon(
//                               Icons.notifications_outlined,
//                               color: Colors.black87,
//                               size: 24,
//                             ),
//                             Positioned(
//                               right: 0,
//                               top: 0,
//                               child: Container(
//                                 width: 8,
//                                 height: 8,
//                                 decoration: const BoxDecoration(
//                                   color: Colors.red,
//                                   shape: BoxShape.circle,
//                                 ),
//                               ),
//                             ),
//                           ],
//                         ),
//                       ),
//                     ],
//                   ),
//                 ),

//                 // Tabs
//                 Padding(
//                   padding: const EdgeInsets.symmetric(horizontal: 16.0),
//                   child: Row(
//                     children: [
//                       _buildTab(
//                         'All Campaigns',
//                         tabProvider.selectedTab == 0,
//                         () => tabProvider.setTab(0),
//                       ),
//                       const SizedBox(width: 12),
//                       _buildTab(
//                         'Completed',
//                         tabProvider.selectedTab == 1,
//                         () => tabProvider.setTab(1),
//                       ),
//                     ],
//                   ),
//                 ),

//                 const SizedBox(height: 20),

//                 // Loading and Error states
//                 if (campaignsProvider.isLoading)
//                   const Expanded(
//                     child: Center(
//                       child: CircularProgressIndicator(
//                         color: Color(0xFF6C5CE7),
//                       ),
//                     ),
//                   )
//                 else if (campaignsProvider.error != null)
//                   Expanded(
//                     child: Center(
//                       child: Column(
//                         mainAxisAlignment: MainAxisAlignment.center,
//                         children: [
//                           Text(
//                             campaignsProvider.error!,
//                             style: AppTextStyle.base.copyWith(
//                               color: Colors.red,
//                               fontSize: 16,
//                             ),
//                             textAlign: TextAlign.center,
//                           ),
//                           const SizedBox(height: 16),
//                           ElevatedButton(
//                             onPressed: _loadCampaigns,
//                             style: ElevatedButton.styleFrom(
//                               backgroundColor: const Color(0xFF6C5CE7),
//                               foregroundColor: Colors.white,
//                             ),
//                             child: const Text('Retry'),
//                           ),
//                         ],
//                       ),
//                     ),
//                   )
//                 else
//                   // Campaign list
//                   Expanded(
//                     child: tabProvider.selectedTab == 0
//                         ? _buildAllCampaignsList(campaignsProvider.campaigns)
//                         : _buildCompletedCampaignsList(campaignsProvider.completedCampaigns),
//                   ),
//               ],
//             ),
//           ),
//         ],
//       ),
//     );
//   }

//   Widget _buildTab(String text, bool isActive, VoidCallback onTap) {
//     return GestureDetector(
//       onTap: onTap,
//       child: Container(
//         padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
//         decoration: BoxDecoration(
//           color: isActive ? const Color(0xFFE8E3FF) : Colors.transparent,
//           borderRadius: BorderRadius.circular(10),
//         ),
//         child: Text(
//           text,
//           style: AppTextStyle.base.copyWith(
//             color: isActive ? const Color(0xFF6C5CE7) : Colors.grey,
//             fontWeight: isActive ? FontWeight.w600 : FontWeight.normal,
//             fontSize: 12,
//           ),
//         ),
//       ),
//     );
//   }

//   Widget _buildCampaignCard(Map<String, dynamic> campaign) {
//     final String name = campaign['campaign_name'] ?? 'Unnamed Campaign';
//     final String startDate = _formatDate(campaign['start_date']);
//     final String endDate = _formatDate(campaign['end_date']);
//     final String targetKm = '${campaign['target_kilometers']?.toString() ?? '0'} kms';
//     final String logoPath = campaign['campaign_profile'] ?? '';
//     final String status = campaign['status'] ?? 'Upcoming';

//     return Container(
//       margin: const EdgeInsets.only(bottom: 20),
//       padding: const EdgeInsets.only(left: 10, top: 0, right: 10, bottom: 0),
//       decoration: BoxDecoration(
//         color: Colors.white,
//         borderRadius: BorderRadius.circular(16),
//         boxShadow: [
//           BoxShadow(
//             color: Colors.grey.withOpacity(0.4),
//             spreadRadius: 1,
//             blurRadius: 10,
//             offset: const Offset(0, 2),
//           ),
//         ],
//       ),
//       child: Row(
//         children: [
//           Expanded(
//             child: Column(
//               crossAxisAlignment: CrossAxisAlignment.start,
//               children: [
//                 Row(
//                   mainAxisAlignment: MainAxisAlignment.spaceBetween,
//                   children: [
//                     Text(
//                       name,
//                       style: AppTextStyle.base.copyWith(
//                         fontSize: 16,
//                         fontWeight: FontWeight.bold,
//                         color: Colors.black,
//                       ),
//                     ),
//                     // Campaign image
//                     if (logoPath.isNotEmpty)
//                       Padding(
//                         padding: const EdgeInsets.all(8.0),
//                         child: Container(
//                           width: 60,
//                           height: 60,
//                           decoration: BoxDecoration(
//                             color: _getColorFromStatus(status).withOpacity(0.1),
//                             borderRadius: BorderRadius.circular(12),
//                           ),
//                           child: ClipRRect(
//                             borderRadius: BorderRadius.circular(12),
//                             child: Image.network(
//                               logoPath,
//                               fit: BoxFit.cover,
//                               errorBuilder: (context, error, stackTrace) {
//                                 return Container(
//                                   decoration: BoxDecoration(
//                                     color: _getColorFromStatus(status).withOpacity(0.1),
//                                     borderRadius: BorderRadius.circular(12),
//                                   ),
//                                   child: Icon(
//                                     Icons.campaign,
//                                     color: _getColorFromStatus(status),
//                                     size: 30,
//                                   ),
//                                 );
//                               },
//                               loadingBuilder: (context, child, loadingProgress) {
//                                 if (loadingProgress == null) return child;
//                                 return Container(
//                                   decoration: BoxDecoration(
//                                     color: _getColorFromStatus(status).withOpacity(0.1),
//                                     borderRadius: BorderRadius.circular(12),
//                                   ),
//                                   child: const Center(
//                                     child: CircularProgressIndicator(
//                                       color: Color(0xFF6C5CE7),
//                                       strokeWidth: 2,
//                                     ),
//                                   ),
//                                 );
//                               },
//                             ),
//                           ),
//                         ),
//                       ),
//                   ],
//                 ),
//                 const SizedBox(height: 0),
//                 Row(
//                   children: [
//                     const Icon(
//                       Icons.calendar_today,
//                       size: 14,
//                       color: Color(0xFF6C5CE7),
//                     ),
//                     const SizedBox(width: 6),
//                     Text(
//                       '$startDate - $endDate',
//                       style: AppTextStyle.base.copyWith(
//                         fontSize: 12,
//                         color: Colors.grey[600],
//                       ),
//                     ),
//                   ],
//                 ),
//                 const SizedBox(height: 0),
//                 Row(
//                   mainAxisAlignment: MainAxisAlignment.spaceBetween,
//                   children: [
//                     Row(
//                       children: [
//                         const Icon(
//                           Icons.route,
//                           size: 14,
//                           color: Color(0xFF6C5CE7),
//                         ),
//                         const SizedBox(width: 6),
//                         Text(
//                           targetKm,
//                           style: AppTextStyle.base.copyWith(
//                             fontSize: 12,
//                             color: Colors.grey[600],
//                           ),
//                         ),
//                         const SizedBox(width: 5),
//                          Container(
//                           padding: const EdgeInsets.symmetric(
//                             horizontal: 8,
//                             vertical: 2,
//                           ),
//                           decoration: BoxDecoration(
//                             color: const Color(0xFFE8E3FF),
//                             borderRadius: BorderRadius.circular(12),
//                           ),
//                           child: Row(
//                             children: [
//                               const Icon(
//                                 Icons.person,
//                                 size: 12,
//                                 color: Color(0xFF6C5CE7),
//                               ),
//                               const SizedBox(width: 4),
//                               Text(
//                                 "10+ drivers",
//                                 style: AppTextStyle.base.copyWith(
//                                   fontSize: 11,
//                                   color: Color(0xFF6C5CE7),
//                                   fontWeight: FontWeight.w600,
//                                 ),
//                               ),
//                             ],
//                           ),
//                         ),
//                       ],
//                     ),
//                     ElevatedButton(
//                       onPressed: () {
//                         // Handle join campaign
//                       },
//                       style: ElevatedButton.styleFrom(
//                         backgroundColor: const Color(0xFF6C5CE7),
//                         foregroundColor: Colors.white,
//                         padding: const EdgeInsets.symmetric(
//                           horizontal: 15,
//                           vertical: 0,
//                         ),
//                         shape: RoundedRectangleBorder(
//                           borderRadius: BorderRadius.circular(20),
//                         ),
//                         elevation: 0,
//                       ),
//                       child: Text(
//                         'Join Campaign',
//                         style: AppTextStyle.base.copyWith(
//                           fontSize: 12,
//                           fontWeight: FontWeight.w600,
//                         ),
//                       ),
//                     ),
//                   ],
//                 ),
//                 const SizedBox(height: 12),
//               ],
//             ),
//           ),
//         ],
//       ),
//     );
//   }

//   Widget _buildAllCampaignsList(List<dynamic> campaigns) {
//     if (campaigns.isEmpty) {
//       return const Center(
//         child: Text(
//           'No campaigns available',
//           style: TextStyle(
//             fontSize: 16,
//             color: Colors.grey,
//           ),
//         ),
//       );
//     }

//     return ListView(
//       padding: const EdgeInsets.symmetric(horizontal: 16),
//       children: campaigns.map((campaign) => _buildCampaignCard(campaign)).toList(),
//     );
//   }

//   Widget _buildCompletedCampaignsList(List<dynamic> completedCampaigns) {
//     if (completedCampaigns.isEmpty) {
//       return const Center(
//         child: Text(
//           'No completed campaigns',
//           style: TextStyle(
//             fontSize: 16,
//             color: Colors.grey,
//           ),
//         ),
//       );
//     }

//     return ListView(
//       padding: const EdgeInsets.symmetric(horizontal: 16),
//       children: completedCampaigns.map((campaign) => _buildCampaignCard(campaign)).toList(),
//     );
//   }

//   String _formatDate(String dateString) {
//     try {
//       final date = DateTime.parse(dateString);
//       return '${date.day} ${_getMonthName(date.month)} ${date.year}';
//     } catch (e) {
//       return 'Invalid Date';
//     }
//   }

//   String _getMonthName(int month) {
//     const months = ['Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun', 'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'];
//     return months[month - 1];
//   }

//   Color _getColorFromStatus(String status) {
//     switch (status.toLowerCase()) {
//       case 'completed':
//         return Colors.green;
//       case 'upcoming':
//         return Colors.blue;
//       case 'active':
//         return Colors.orange;
//       default:
//         return const Color(0xFF6C5CE7);
//     }
//   }

// }

// campaigns_page.dart
import 'package:addrive/Controller/campaigns_tab.dart';
import 'package:addrive/Model/campaigns_model.dart';
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
