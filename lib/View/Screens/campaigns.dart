import 'package:addrive/Controller/campaigns_tab.dart';
import 'package:addrive/View/Widgets/appbackground.dart';
import 'package:addrive/View/Widgets/appfont.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class CampaignsPage extends StatelessWidget {
  const CampaignsPage({super.key});

  @override
  Widget build(BuildContext context) {
    final tabProvider = Provider.of<CampaignTabProvider>(context);
    return Scaffold(
      backgroundColor: Colors.white,
      body: Stack(
        children: [
         BackgroundDecoration(),
          // Main content
          SafeArea(
            child: Column(
              children: [
                Padding(
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
                       Container(
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
                          ),
                    ],
                  ),
                ),

                // Tabs
                Padding(
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
                ),

                const SizedBox(height: 20),

                // Campaign list
                Expanded(
                  child: tabProvider.selectedTab == 0
                      ? _buildAllCampaignsList()
                      : _buildCompletedCampaignsList(),
                ),
              ],
            ),
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

  Widget _buildCampaignCard(
    String name,
    String date,
    String distance,
    String drivers,
    String logoPath,
    Color logoColor,
  ) {
    return Container(
      margin: const EdgeInsets.only(bottom: 20),
      padding: const EdgeInsets.only(left: 10, top: 5, right: 10, bottom: 5),
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
                      name,
                      style: AppTextStyle.base.copyWith(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: Colors.black,
                      ),
                    ),
                    Container(
                      width: 60,
                      height: 60,
                      decoration: BoxDecoration(
                        color: logoColor.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      clipBehavior: Clip.hardEdge,
                      child: Image.asset(
                        logoPath, // replace with your image path
                        fit: BoxFit
                            .fill, // optional: applies color tint like the icon color
                      ),
                    ),
                  ],
                ),
                Row(
                  children: [
                    const Icon(
                      Icons.calendar_today,
                      size: 14,
                      color: Color(0xFF6C5CE7),
                    ),
                    const SizedBox(width: 6),
                    Text(
                      date,
                      style: AppTextStyle.base.copyWith(
                        fontSize: 12,
                        color: Colors.grey[600],
                      ),
                    ),
                  ],
                ),
                Row(
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
                          distance,
                          style: AppTextStyle.base.copyWith(
                            fontSize: 12,
                            color: Colors.grey[600],
                          ),
                        ),
                        const SizedBox(width: 5),
                        Container(
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
                                drivers,
                                style: AppTextStyle.base.copyWith(
                                  fontSize: 11,
                                  color: Color(0xFF6C5CE7),
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),

                    ElevatedButton(
                      onPressed: () {},
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
                ),
                const SizedBox(height: 12),
              ],
            ),
          ),
        ],
      ),
    );
  }
    Widget _buildAllCampaignsList() {
    return ListView(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      children: [
       _buildCampaignCard(
                        'Kalyan Hypermarket',
                        '15 Aug 2025 - 18 Sep 2025',
                        '5,500 kms',
                        '10 Drivers',
                        'assets/images/kallyan silks.jpeg',
                        Colors.red,
                      ),
                      _buildCampaignCard(
                        'Lulu Hypermarket',
                        '20 Aug 2025 - 23 Sep 2025',
                        '7,500 kms',
                        '15 Drivers',
                        'assets/images/lulu_hypermarket_supermarket_department_store_-_en-ar_2.png',
                        Colors.green,
                      ),
                      _buildCampaignCard(
                        'Addidas',
                        '15 Aug 2025 - 18 Sep 2025',
                        '3,500 kms',
                        '10 Drivers',
                        'assets/images/adidas-logo-white-symbol-with-name-clothes-design-icon-abstract-football-illustration-with-black-background-free-vector.jpg',
                        Colors.black,
                      ),
                      _buildCampaignCard(
                        'Allen Solly',
                        '15 Aug 2025 - 18 Sep 2025',
                        '3,500 kms',
                        '10 Drivers',
                        'assets/images/9d37fa3248cc052d74a835729783f8dc.jpg',
                        Colors.black,
                      ),
                      _buildCampaignCard(
                        'Peter England',
                        '15 Aug 2025 - 18 Sep 2025',
                        '3,500 kms',
                        '10 Drivers',
                        'assets/images/wp11150839.jpg',
                        const Color(0xFF1E3A5F),
                      ),
                      _buildCampaignCard(
                        'Royal Enfield',
                        '15 Aug 2025 - 18 Sep 2025',
                        '3,500 kms',
                        '10 Drivers',
                        'assets/images/ro6160r603-royal-enfield-logo-royal-enfield-classic-500-logo-vector-pesquisa-google-royal.png',
                        Colors.red,
                      ),
                      _buildCampaignCard(
                        'Lenovo',
                        '15 Aug 2025 - 18 Sep 2025',
                        '3,500 kms',
                        '10 Drivers',
                        'assets/images/lenovo-logo-brand-phone-symbol-design-china-mobile-illustration-red-and-white-free-vector.jpg',
                        Colors.red,
                      ),
      ],
    );
  }
    Widget _buildCompletedCampaignsList() {
    return const Center(
      child: Text(
        'No completed campaigns',
        style: TextStyle(
          fontSize: 16,
          color: Colors.grey,
        ),
      ),
    );
  }
}

