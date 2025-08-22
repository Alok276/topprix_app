import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

// Notification Model
class AppNotification {
  final String id;
  final String title;
  final String message;
  final String type; // deal, coupon, system, store
  final DateTime timestamp;
  final bool isRead;
  final String? imageUrl;
  final Map<String, dynamic>? actionData;

  AppNotification({
    required this.id,
    required this.title,
    required this.message,
    required this.type,
    required this.timestamp,
    this.isRead = false,
    this.imageUrl,
    this.actionData,
  });
}

class NotificationsPage extends ConsumerStatefulWidget {
  const NotificationsPage({super.key});

  @override
  ConsumerState<NotificationsPage> createState() => _NotificationsPageState();
}

class _NotificationsPageState extends ConsumerState<NotificationsPage>
    with TickerProviderStateMixin {
  late TabController _tabController;

  // Mock notifications data
  final List<AppNotification> _notifications = [
    AppNotification(
      id: '1',
      title: 'New Deal Alert! 🔥',
      message: 'Best Buy has a 50% off deal on electronics. Don\'t miss out!',
      type: 'deal',
      timestamp: DateTime.now().subtract(const Duration(minutes: 30)),
      imageUrl: 'https://via.placeholder.com/60x60',
    ),
    AppNotification(
      id: '2',
      title: 'Coupon Expiring Soon ⏰',
      message: 'Your Target 20% off coupon expires in 2 hours.',
      type: 'coupon',
      timestamp: DateTime.now().subtract(const Duration(hours: 1)),
      isRead: true,
    ),
    AppNotification(
      id: '3',
      title: 'Welcome to TopPrix! 🎉',
      message: 'Start saving money with exclusive deals and coupons.',
      type: 'system',
      timestamp: DateTime.now().subtract(const Duration(days: 1)),
      isRead: true,
    ),
    AppNotification(
      id: '4',
      title: 'New Store Added',
      message: 'Walmart is now available in your area with amazing deals.',
      type: 'store',
      timestamp: DateTime.now().subtract(const Duration(days: 2)),
    ),
    AppNotification(
      id: '5',
      title: 'Flash Sale Alert! ⚡',
      message: 'Target is having a flash sale for the next 4 hours only!',
      type: 'deal',
      timestamp: DateTime.now().subtract(const Duration(days: 3)),
      isRead: true,
    ),
  ];

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 4, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: _buildAppBar(),
      body: Column(
        children: [
          _buildTabBar(),
          Expanded(
            child: _buildTabBarView(),
          ),
        ],
      ),
    );
  }

  PreferredSizeWidget _buildAppBar() {
    final unreadCount = _notifications.where((n) => !n.isRead).length;

    return AppBar(
      backgroundColor: Colors.white,
      elevation: 0,
      leading: IconButton(
        icon: const Icon(Icons.arrow_back, color: Colors.black),
        onPressed: () => Navigator.pop(context),
      ),
      title: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Notifications',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Colors.black,
            ),
          ),
          if (unreadCount > 0)
            Text(
              '$unreadCount unread',
              style: const TextStyle(
                fontSize: 12,
                color: Colors.grey,
              ),
            ),
        ],
      ),
      actions: [
        if (unreadCount > 0)
          TextButton(
            onPressed: () => _markAllAsRead(),
            child: const Text('Mark all read'),
          ),
        PopupMenuButton<String>(
          onSelected: (value) {
            switch (value) {
              case 'settings':
                _navigateToNotificationSettings();
                break;
              case 'clear':
                _clearAllNotifications();
                break;
            }
          },
          itemBuilder: (context) => [
            const PopupMenuItem(
              value: 'settings',
              child: Row(
                children: [
                  Icon(Icons.settings, color: Colors.grey),
                  SizedBox(width: 12),
                  Text('Notification Settings'),
                ],
              ),
            ),
            const PopupMenuItem(
              value: 'clear',
              child: Row(
                children: [
                  Icon(Icons.clear_all, color: Colors.grey),
                  SizedBox(width: 12),
                  Text('Clear All'),
                ],
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildTabBar() {
    return Container(
      color: Colors.white,
      child: TabBar(
        controller: _tabController,
        labelColor: const Color(0xFF6366F1),
        unselectedLabelColor: Colors.grey[600],
        indicatorColor: const Color(0xFF6366F1),
        isScrollable: true,
        tabAlignment: TabAlignment.start,
        tabs: [
          Tab(
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Text('All'),
                const SizedBox(width: 4),
                _buildNotificationBadge(_notifications.length),
              ],
            ),
          ),
          Tab(
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Text('Deals'),
                const SizedBox(width: 4),
                _buildNotificationBadge(_getNotificationsByType('deal').length),
              ],
            ),
          ),
          Tab(
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Text('Coupons'),
                const SizedBox(width: 4),
                _buildNotificationBadge(
                    _getNotificationsByType('coupon').length),
              ],
            ),
          ),
          Tab(
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Text('Updates'),
                const SizedBox(width: 4),
                _buildNotificationBadge(
                    _getNotificationsByType('system').length),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildNotificationBadge(int count) {
    if (count == 0) return const SizedBox.shrink();

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
      decoration: BoxDecoration(
        color: const Color(0xFF6366F1),
        borderRadius: BorderRadius.circular(10),
      ),
      child: Text(
        count.toString(),
        style: const TextStyle(
          color: Colors.white,
          fontSize: 10,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }

  Widget _buildTabBarView() {
    return TabBarView(
      controller: _tabController,
      children: [
        _buildNotificationsList(_notifications),
        _buildNotificationsList(_getNotificationsByType('deal')),
        _buildNotificationsList(_getNotificationsByType('coupon')),
        _buildNotificationsList(_getNotificationsByType('system')),
      ],
    );
  }

  Widget _buildNotificationsList(List<AppNotification> notifications) {
    if (notifications.isEmpty) {
      return _buildEmptyState();
    }

    return RefreshIndicator(
      onRefresh: () async {
        // TODO: Implement refresh functionality
        await Future.delayed(const Duration(seconds: 1));
      },
      child: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: notifications.length,
        itemBuilder: (context, index) {
          final notification = notifications[index];
          return _buildNotificationItem(notification);
        },
      ),
    );
  }

  Widget _buildNotificationItem(AppNotification notification) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: notification.isRead
            ? Colors.white
            : const Color(0xFF6366F1).withOpacity(0.05),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: notification.isRead
              ? Colors.grey[200]!
              : const Color(0xFF6366F1).withOpacity(0.2),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: InkWell(
        onTap: () => _handleNotificationTap(notification),
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Notification Icon/Image
              _buildNotificationIcon(notification),
              const SizedBox(width: 12),

              // Notification Content
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: Text(
                            notification.title,
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: notification.isRead
                                  ? FontWeight.w500
                                  : FontWeight.bold,
                              color: const Color(0xFF1F2937),
                            ),
                          ),
                        ),
                        if (!notification.isRead)
                          Container(
                            width: 8,
                            height: 8,
                            decoration: const BoxDecoration(
                              color: Color(0xFF6366F1),
                              shape: BoxShape.circle,
                            ),
                          ),
                      ],
                    ),
                    const SizedBox(height: 4),
                    Text(
                      notification.message,
                      style: TextStyle(
                        fontSize: 14,
                        color: Colors.grey[600],
                        height: 1.4,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        _buildTypeChip(notification.type),
                        const Spacer(),
                        Text(
                          _formatTimestamp(notification.timestamp),
                          style: const TextStyle(
                            fontSize: 12,
                            color: Colors.grey,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),

              // Actions Menu
              PopupMenuButton<String>(
                onSelected: (value) =>
                    _handleNotificationAction(notification, value),
                itemBuilder: (context) => [
                  PopupMenuItem(
                    value: notification.isRead ? 'unread' : 'read',
                    child: Row(
                      children: [
                        Icon(
                          notification.isRead
                              ? Icons.mark_email_unread
                              : Icons.mark_email_read,
                          color: Colors.grey,
                          size: 20,
                        ),
                        const SizedBox(width: 8),
                        Text(notification.isRead
                            ? 'Mark as unread'
                            : 'Mark as read'),
                      ],
                    ),
                  ),
                  const PopupMenuItem(
                    value: 'delete',
                    child: Row(
                      children: [
                        Icon(Icons.delete, color: Colors.red, size: 20),
                        SizedBox(width: 8),
                        Text('Delete', style: TextStyle(color: Colors.red)),
                      ],
                    ),
                  ),
                ],
                child: const Icon(Icons.more_vert, color: Colors.grey),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildNotificationIcon(AppNotification notification) {
    if (notification.imageUrl != null) {
      return Container(
        width: 48,
        height: 48,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(8),
          image: DecorationImage(
            image: NetworkImage(notification.imageUrl!),
            fit: BoxFit.cover,
          ),
        ),
      );
    }

    IconData icon;
    Color color;

    switch (notification.type) {
      case 'deal':
        icon = Icons.local_offer;
        color = Colors.red;
        break;
      case 'coupon':
        icon = Icons.confirmation_number;
        color = Colors.green;
        break;
      case 'store':
        icon = Icons.store;
        color = Colors.blue;
        break;
      case 'system':
        icon = Icons.info;
        color = Colors.orange;
        break;
      default:
        icon = Icons.notifications;
        color = Colors.grey;
    }

    return Container(
      width: 48,
      height: 48,
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Icon(icon, color: color, size: 24),
    );
  }

  Widget _buildTypeChip(String type) {
    Color color;
    String label;

    switch (type) {
      case 'deal':
        color = Colors.red;
        label = 'Deal';
        break;
      case 'coupon':
        color = Colors.green;
        label = 'Coupon';
        break;
      case 'store':
        color = Colors.blue;
        label = 'Store';
        break;
      case 'system':
        color = Colors.orange;
        label = 'Update';
        break;
      default:
        color = Colors.grey;
        label = 'Info';
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Text(
        label,
        style: TextStyle(
          fontSize: 10,
          color: color,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.notifications_none,
            size: 64,
            color: Colors.grey[400],
          ),
          const SizedBox(height: 16),
          Text(
            'No notifications yet',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w600,
              color: Colors.grey[600],
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'We\'ll notify you about new deals and updates',
            style: TextStyle(
              fontSize: 14,
              color: Colors.grey[500],
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  // Helper methods
  List<AppNotification> _getNotificationsByType(String type) {
    return _notifications.where((n) => n.type == type).toList();
  }

  String _formatTimestamp(DateTime timestamp) {
    final now = DateTime.now();
    final difference = now.difference(timestamp);

    if (difference.inMinutes < 60) {
      return '${difference.inMinutes}m ago';
    } else if (difference.inHours < 24) {
      return '${difference.inHours}h ago';
    } else if (difference.inDays < 7) {
      return '${difference.inDays}d ago';
    } else {
      return '${timestamp.day}/${timestamp.month}/${timestamp.year}';
    }
  }

  // Action methods
  void _handleNotificationTap(AppNotification notification) {
    // Mark as read if not already read
    if (!notification.isRead) {
      setState(() {
        notification = AppNotification(
          id: notification.id,
          title: notification.title,
          message: notification.message,
          type: notification.type,
          timestamp: notification.timestamp,
          isRead: true,
          imageUrl: notification.imageUrl,
          actionData: notification.actionData,
        );
      });
    }

    // Navigate to relevant content based on notification type
    switch (notification.type) {
      case 'deal':
        _navigateToDeals();
        break;
      case 'coupon':
        _navigateToCoupons();
        break;
      case 'store':
        _navigateToStores();
        break;
      default:
        break;
    }
  }

  void _handleNotificationAction(AppNotification notification, String action) {
    switch (action) {
      case 'read':
      case 'unread':
        setState(() {
          // Toggle read status
          final index =
              _notifications.indexWhere((n) => n.id == notification.id);
          if (index != -1) {
            _notifications[index] = AppNotification(
              id: notification.id,
              title: notification.title,
              message: notification.message,
              type: notification.type,
              timestamp: notification.timestamp,
              isRead: action == 'read',
              imageUrl: notification.imageUrl,
              actionData: notification.actionData,
            );
          }
        });
        break;
      case 'delete':
        _deleteNotification(notification);
        break;
    }
  }

  void _markAllAsRead() {
    setState(() {
      for (int i = 0; i < _notifications.length; i++) {
        _notifications[i] = AppNotification(
          id: _notifications[i].id,
          title: _notifications[i].title,
          message: _notifications[i].message,
          type: _notifications[i].type,
          timestamp: _notifications[i].timestamp,
          isRead: true,
          imageUrl: _notifications[i].imageUrl,
          actionData: _notifications[i].actionData,
        );
      }
    });
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('All notifications marked as read')),
    );
  }

  void _deleteNotification(AppNotification notification) {
    setState(() {
      _notifications.removeWhere((n) => n.id == notification.id);
    });
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Notification deleted')),
    );
  }

  void _clearAllNotifications() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Clear All Notifications'),
        content: const Text(
            'Are you sure you want to clear all notifications? This action cannot be undone.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              setState(() {
                _notifications.clear();
              });
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('All notifications cleared')),
              );
            },
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            child:
                const Text('Clear All', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }

  void _navigateToNotificationSettings() {
    // TODO: Navigate to notification settings
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Notification settings coming soon!')),
    );
  }

  void _navigateToDeals() {
    Navigator.pop(context); // Go back to main app
    // TODO: Navigate to deals tab
  }

  void _navigateToCoupons() {
    Navigator.pop(context); // Go back to main app
    // TODO: Navigate to coupons tab
  }

  void _navigateToStores() {
    Navigator.pop(context); // Go back to main app
    // TODO: Navigate to stores tab
  }
}
