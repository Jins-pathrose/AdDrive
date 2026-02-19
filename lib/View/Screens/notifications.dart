import 'package:addrive/Controller/notifications_tab.dart';
import 'package:addrive/View/Widgets/appbackground.dart';
import 'package:addrive/View/Widgets/appfont.dart';
import 'package:addrive/View/Widgets/notificationicon.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class Notifications extends StatefulWidget {
  const Notifications({super.key});

  @override
  State<Notifications> createState() => _NotificationsState();
}

class _NotificationsState extends State<Notifications> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Provider.of<NotificationTabProvider>(
        context,
        listen: false,
      ).fetchNotifications();
    });
  }

  Future<void> _handleDelete(BuildContext context, int notificationId) async {
    final provider = Provider.of<NotificationTabProvider>(
      context,
      listen: false,
    );

    // Show confirmation dialog
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Notification'),
        content: const Text(
          'Are you sure you want to delete this notification?',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            child: const Text('Delete'),
          ),
        ],
      ),
    );

    if (confirm == true) {
      // Show loading indicator
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Deleting notification...'),
          duration: Duration(seconds: 1),
        ),
      );

      final success = await provider.deleteNotification(notificationId);

      if (success) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Notification deleted successfully'),
            backgroundColor: Colors.green,
          ),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Failed to delete notification'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Stack(
        children: [
          const BackgroundDecoration(),
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
                      Consumer<NotificationTabProvider>(
                        builder: (context, provider, child) {
                          return NotificationIcon(
                            onTap: () {
                              // Refresh notifications when tapped
                              provider.fetchNotifications();
                            },
                            badgeSize: provider.unreadCount > 0 ? 18 : 8,
                          );
                        },
                      ),
                    ],
                  ),
                ),

                // Tabs
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16.0),
                  child: Consumer<NotificationTabProvider>(
                    builder: (context, provider, child) {
                      return Row(
                        children: [
                          _buildTab(
                            'What\'s New (${provider.newNotifications.length})',
                            provider.selectedIndex == 0,
                            () => provider.setTab(0),
                          ),
                          const SizedBox(width: 12),
                          // _buildTab(
                          //   'Previously (${provider.oldNotifications.length})',
                          //   provider.selectedIndex == 1,
                          //   () => provider.setTab(1),
                          // ),
                        ],
                      );
                    },
                  ),
                ),

                const SizedBox(height: 20),

                // Notifications List with Swipe to Delete
                Expanded(
  child: Consumer<NotificationTabProvider>(
    builder: (context, provider, child) {
      // Show error first
      if (provider.error != null) {
        return Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                "Please check your internet connection and try again",
                style: const TextStyle(color: Color(0xFF5B4BDB)),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 16),
              ElevatedButton(
                onPressed: () => provider.fetchNotifications(),
                child: const Text('Retry'),
              ),
            ],
          ),
        );
      }

      // Show loading only when actually loading
      // if (provider.isLoading) {
      //   return const Center(child: CircularProgressIndicator());
      // }

      // Get notifications based on selected tab
      final notifications = provider.selectedIndex == 0
          ? provider.newNotifications
          : provider.oldNotifications;

      // Show empty state
      if (notifications.isEmpty) {
        return Center(
          child: Text(
            provider.selectedIndex == 0
                ? 'No new notifications'
                : 'No old notifications',
            style: const TextStyle(
              fontSize: 16,
              color: Colors.grey,
            ),
          ),
        );
      }

                      return ListView.builder(
                        padding: const EdgeInsets.symmetric(horizontal: 16),
                        itemCount: notifications.length,
                        itemBuilder: (context, index) {
                          final notification = notifications[index];
                          return Dismissible(
                            key: Key('notification_${notification.id}'),
                            direction: DismissDirection.endToStart,
                            background: Container(
                              alignment: Alignment.centerRight,
                              padding: const EdgeInsets.only(right: 20),
                              decoration: BoxDecoration(
                                color: Colors.red,
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: const Icon(
                                Icons.delete,
                                color: Colors.white,
                                size: 30,
                              ),
                            ),
                            confirmDismiss: (direction) async {
                              return await showDialog(
                                context: context,
                                builder: (BuildContext context) {
                                  return AlertDialog(
                                    title: const Text('Delete Notification'),
                                    content: const Text(
                                      'Are you sure you want to delete this notification?',
                                    ),
                                    actions: [
                                      TextButton(
                                        onPressed: () =>
                                            Navigator.of(context).pop(false),
                                        child: const Text('Cancel'),
                                      ),
                                      TextButton(
                                        onPressed: () =>
                                            Navigator.of(context).pop(true),
                                        style: TextButton.styleFrom(
                                          foregroundColor: Colors.red,
                                        ),
                                        child: const Text('Delete'),
                                      ),
                                    ],
                                  );
                                },
                              );
                            },
                            onDismissed: (direction) async {
                              final success = await provider.deleteNotification(
                                notification.id,
                              );

                              if (success) {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(
                                    content: Text('Notification deleted'),
                                    duration: const Duration(seconds: 2),
                                    // action: SnackBarAction(
                                    //   label: 'UNDO',
                                    //   textColor: Colors.white,
                                    //   onPressed: () {
                                    //     // You would need to implement undo functionality
                                    //     // This would require storing the deleted notification
                                    //   },
                                    // ),
                                  ),
                                );
                              } else {
                                // If delete failed, refresh the list
                                provider.fetchNotifications();
                                ScaffoldMessenger.of(context).showSnackBar(
                                  const SnackBar(
                                    content: Text(
                                      'Failed to delete notification',
                                    ),
                                    backgroundColor: Colors.red,
                                  ),
                                );
                              }
                            },
                            child: _buildNotificationCard(
                              notification.title,
                              notification.message,
                              provider.getTimeAgo(notification.createdAt),
                              isRead: notification.isRead,
                              onTap: () => provider.markAsRead(notification.id),
                            ),
                          );
                        },
                      );
                    },
                  ),
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
          color: Color(0xFFEDE8FF),
          borderRadius: BorderRadius.circular(10),
        ),
        child: Text(
          text,
          style: AppTextStyle.base.copyWith(
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
    String timeAgo, {
    bool isRead = false,
    VoidCallback? onTap,
  }) {
    return GestureDetector(
      // onTap: onTap,
      child: Container(
        margin: const EdgeInsets.only(bottom: 10),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          boxShadow: [
            BoxShadow(
              color: Colors.grey.withOpacity(0.3),
              spreadRadius: 3,
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
          color: isRead
              ? const Color.fromARGB(255, 255, 255, 255)
              : const Color.fromARGB(255, 255, 255, 255),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: const Color.fromARGB(255, 255, 255, 255)!,
            width: isRead ? 1 : 1.5,
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Expanded(
                  child: Text(
                    '"$title"',

                    style: AppTextStyle.base.copyWith(
                      fontSize: 16,
                      fontWeight: isRead ? FontWeight.normal : FontWeight.bold,
                      color: Colors.black,
                    ),
                  ),
                ),
                if (!isRead)
                  Container(
                    width: 8,
                    height: 8,
                    decoration: const BoxDecoration(
                      color: Colors.blue,
                      shape: BoxShape.circle,
                    ),
                  ),
              ],
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
            const SizedBox(height: 8),
            Text(
              timeAgo,
              style: AppTextStyle.base.copyWith(
                fontSize: 11,
                color: Colors.grey[500],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
