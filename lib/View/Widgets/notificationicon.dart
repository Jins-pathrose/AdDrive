import 'package:addrive/View/Screens/notifications.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../Controller/notifications_tab.dart';

class NotificationIcon extends StatelessWidget {
  final VoidCallback? onTap;
  final double iconSize;
  final Color iconColor;
  final Color badgeColor;
  final double badgeSize; // This will be used for small dot when count is 0

  const NotificationIcon({
    super.key,
    this.onTap,
    this.iconSize = 24,
    this.iconColor = Colors.black87,
    this.badgeColor = Colors.red,
    this.badgeSize = 8, // Small dot size when no count needed
  });

  @override
  Widget build(BuildContext context) {
    return Consumer<NotificationTabProvider>(
      builder: (context, provider, child) {
        // Fetch notifications when the widget is first built
        WidgetsBinding.instance.addPostFrameCallback((_) {
          if (provider.notifications.isEmpty && !provider.isLoading) {
            provider.fetchNotifications();
          }
        });

        return GestureDetector(
          onTap: onTap ?? () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => const Notifications(),
              ),
            );
          },
          child: Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: Colors.grey[100],
              shape: BoxShape.circle,
            ),
            child: Stack(
              clipBehavior: Clip.none,
              children: [
                Icon(
                  Icons.notifications_outlined,
                  color: iconColor,
                  size: iconSize,
                ),
                if (provider.unreadCount > 0)
                  Positioned(
                    right: -2,
                    top: -2,
                    child: Container(
                      width: 18, // Fixed size for count badge
                      height: 18, // Fixed size for count badge
                      decoration: BoxDecoration(
                        color: badgeColor,
                        shape: BoxShape.circle,
                      ),
                      child: Center(
                        child: Text(
                          provider.unreadCount > 99 ? '99+' : provider.unreadCount.toString(),
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 10,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ),
                  ),
              ],
            ),
          ),
        );
      },
    );
  }
}