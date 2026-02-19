import 'package:addrive/Model/notificationsmodel.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';

class NotificationTabProvider extends ChangeNotifier {
  int _selectedIndex = 0;
  List<NotificationModel> _notifications = [];
  bool _isLoading = false;
  String? _error;

  int get selectedIndex => _selectedIndex;
  List<NotificationModel> get notifications => _notifications;
  List<NotificationModel> get newNotifications => 
      _notifications.where((n) => !n.isRead).toList();
  List<NotificationModel> get oldNotifications => 
      _notifications.where((n) => n.isRead).toList();
  int get unreadCount => _notifications.where((n) => !n.isRead).length;
  bool get isLoading => _isLoading;
  String? get error => _error;

  void setTab(int index) {
    _selectedIndex = index;
    notifyListeners();
  }

  Future<void> fetchNotifications() async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('access_token');
      
      if (token == null) {
        throw Exception('Authentication token not found');
      }
      final response = await http.get(
        Uri.parse('https://addrive.kkms.co.in/api/notification-list/'),
        headers: {
          'Content-Type': 'application/json',
          // Add your authorization header if needed
          'Authorization': 'Bearer $token',
        },
      );

      if (response.statusCode == 200) {
        List<dynamic> data = json.decode(response.body);

        _notifications = data.map((json) => NotificationModel.fromJson(json)).toList();
        
        // Sort by date (newest first)
        _notifications.sort((a, b) => b.createdAt.compareTo(a.createdAt));
        
        _error = null;
      } else {
        _error = 'Failed to load notifications: ${response.statusCode}';
      }
    } catch (e) {
      _error = 'Error fetching notifications: $e';
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<bool> deleteNotification(int notificationId) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('access_token');
      
      if (token == null) {
        throw Exception('Authentication token not found');
      }
      print('Deleting notification with ID: $notificationId');
      final response = await http.delete(
        Uri.parse('https://addrive.kkms.co.in/api/notification-delete/$notificationId/'),
        headers: {
          'Content-Type': 'application/json',
          // Add your authorization header if needed
          'Authorization': 'Bearer $token',
        },
      );

      if (response.statusCode == 200 || response.statusCode == 204) {
        // Remove from local list
        _notifications.removeWhere((n) => n.id == notificationId);
        notifyListeners();
        return true;
      } else {
        print('Failed to delete notification: ${response.statusCode}');
        return false;
      }
    } catch (e) {
      print('Error deleting notification: $e');
      return false;
    }
  }

  Future<void> markAsRead(int notificationId) async {
    try {
      // You might want to call an API to mark as read
      // For now, we'll update locally
      final index = _notifications.indexWhere((n) => n.id == notificationId);
      if (index != -1) {
        _notifications[index].isRead = true;
        notifyListeners();
      }
    } catch (e) {
      print('Error marking as read: $e');
    }
  }

  Future<void> markAllAsRead() async {
    for (var notification in _notifications) {
      notification.isRead = true;
    }
    notifyListeners();
  }

  String getTimeAgo(DateTime dateTime) {
    final now = DateTime.now();
    final difference = now.difference(dateTime);

    if (difference.inDays > 7) {
      return '${dateTime.day}/${dateTime.month}/${dateTime.year}';
    } else if (difference.inDays > 0) {
      return '${difference.inDays} ${difference.inDays == 1 ? 'day' : 'days'} ago';
    } else if (difference.inHours > 0) {
      return '${difference.inHours} ${difference.inHours == 1 ? 'hour' : 'hours'} ago';
    } else if (difference.inMinutes > 0) {
      return '${difference.inMinutes} ${difference.inMinutes == 1 ? 'minute' : 'minutes'} ago';
    } else {
      return 'Just now';
    }
  }
}
