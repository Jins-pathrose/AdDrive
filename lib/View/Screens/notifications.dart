import 'package:addrive/Controller/notifications_tab.dart';
import 'package:addrive/View/Widgets/appbackground.dart';
import 'package:addrive/View/Widgets/appfont.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class Notifications extends StatelessWidget {
  const Notifications({super.key});

  @override
  Widget build(BuildContext context) {
    final notificationtab = Provider.of<NotificationTabProvider>(
      context,
    ); // <--->
    return Scaffold(
      backgroundColor: Colors.white,
      body: Stack(
        children: [
         BackgroundDecoration(),
          SafeArea(
            child: Column(
              children: [
                // Header
                Padding(
                  padding: const EdgeInsets.all(18.0),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'Notifications',
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
                        '''What's New''',
                        notificationtab.selectedIndex == 0,
                        () => notificationtab.setTab(0),
                      ),
                      const SizedBox(width: 12),
                      _buildTab(
                        'Previously',
                        notificationtab.selectedIndex == 1,
                        () => notificationtab.setTab(1),
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 20),

                Expanded(
                  child: notificationtab.selectedIndex == 0
                      ? _buildnotificationtiles()
                      : _oldnotifications(),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildnotificationtiles() {
    return ListView(
      padding: const EdgeInsets.symmetric(horizontal: 16),

      children: [
        _buildNotificationCard(
          '"Your campaign is live!"',
          'Start driving and earn for every trip you make. Check your campaign dashboard now.',
          '',
        ),
        _buildNotificationCard(
          '"Only a few kilometers away from your bonus! 🚀"',
          'Your weekly target is almost complete — just a few more trips to go. Hit your distance goal before Sunday night to claim your full campaign bonus. Open your app to track your real-time progress and finish strong!',
          '',
        ),

        _buildNotificationCard(
          '"Campaign extended 🎉"',
          'Good news! The current marketing campaign of Lenovo has been extended — keep driving and earning.',
          '',
        ),
        _buildNotificationCard(
          '"Bonus alert! 💰"',
          'Hit your weekly distance goal to unlock extra rewards!',
          '',
        ),
        _buildNotificationCard(
          'Nike wants to ride with you! ⭐',
          'We\'ve partnered with an exciting new brand for this month\'s campaign. Join now to start earning with higher visibility rewards and exclusive bonuses. Tap below to see campaign details and register before slots fill up.',
          '',
        ),
        _buildNotificationCard(
          'Your current campaign ends soon 🏆',
          'We\'re wrapping up the current brand campaign in a few days. Complete your remaining drives and update your vehicle status.',
          '',
        ),
      ],
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
          style: TextStyle(
            color: isActive ? const Color(0xFF6C5CE7) : Colors.grey,
            fontWeight: isActive ? FontWeight.w600 : FontWeight.normal,
            fontSize: 13,
          ),
        ),
      ),
    );
  }

  Widget _buildNotificationCard(
    String title,
    String description,
    String timeAgo,
  ) {
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.4),
            spreadRadius: 1,
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
        color: const Color.fromARGB(255, 255, 255, 255),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey.withOpacity(0.1), width: 1),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: AppTextStyle.base.copyWith(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: Colors.black,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            description,
            style: AppTextStyle.base.copyWith(
              fontSize: 12,
              color: Colors.grey[700],
              height: 1.5,
            ),
          ),
          if (timeAgo.isNotEmpty) ...[
            const SizedBox(height: 8),
            Text(
              timeAgo,
              style: AppTextStyle.base.copyWith(
                fontSize: 11,
                color: Colors.grey[500],
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _oldnotifications() {
    return const Center(
      child: Text(
        'No old notifications',
        style: TextStyle(fontSize: 16, color: Colors.grey),
      ),
    );
  }
}
