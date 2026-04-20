import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';

import '../../../../core/constants/app_colors.dart';
import '../../data/models/notification_model.dart';
import '../providers/notification_provider.dart';
import '../../../../l10n/app_localizations.dart';
import '../../../auth/presentation/screens/profile_screen.dart';
import '../../../chat/presentation/screens/chat_room_screen.dart';
import '../../../jobs/data/repository/job_repository.dart';
import '../../../jobs/presentation/screens/job_detail_screen.dart';

class NotificationScreen extends StatefulWidget {
  const NotificationScreen({super.key});

  @override
  State<NotificationScreen> createState() => _NotificationScreenState();
}

class _NotificationScreenState extends State<NotificationScreen> {
  final ScrollController _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final provider = context.read<NotificationProvider>();
      provider.fetchNotifications(refresh: true);
      provider.fetchUnreadCount();
    });

    _scrollController.addListener(() {
      if (_scrollController.position.pixels == _scrollController.position.maxScrollExtent) {
        context.read<NotificationProvider>().fetchNotifications();
      }
    });
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  void _handleNotificationTap(NotificationModel notification) {
    if (!notification.isRead) {
      context.read<NotificationProvider>().markAsRead(notification.id);
    }

    final refId = notification.referenceId;
    final refModel = (notification.referenceModel ?? '').toUpperCase();
    final type = notification.type.toUpperCase();

    if (refId != null && refId.isNotEmpty) {
      if (refModel == 'CHATSESSION' || type.contains('CHAT') || type.contains('MESSAGE')) {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) => ChatRoomScreen(
              sessionId: refId,
              topic: 'Chat',
            ),
          ),
        );
        return;
      }
      if (refModel == 'JOB' || type.contains('JOB')) {
        _openJobById(refId);
        return;
      }
      if (refModel == 'USER' || type.contains('ACCOUNT')) {
        Navigator.push(
          context,
          MaterialPageRoute(builder: (_) => const ProfileScreen()),
        );
        return;
      }
    }

    switch (notification.type) {
      case 'ACCOUNT_APPROVED':
      case 'ACCOUNT_VERIFIED':
      case 'VERIFICATION_SUCCESS':
        Navigator.push(
          context,
          MaterialPageRoute(builder: (_) => const ProfileScreen()),
        );
        break;
      case 'JOB_PUBLISHED':
      case 'JOB_STATUS_CHANGE':
      case 'JOB_APPLIED':
        if (refId != null && refId.isNotEmpty) {
          _openJobById(refId);
        }
        break;
      case 'MESSAGE_RECEIVED':
      case 'LIVE_CHAT_REQUEST':
        if (refId != null && refId.isNotEmpty) {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) => ChatRoomScreen(
                sessionId: refId,
                topic: 'Chat',
              ),
            ),
          );
        }
        break;
      default:
        break;
    }
  }

  Future<void> _openJobById(String id) async {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (_) => const Center(child: CircularProgressIndicator()),
    );
    try {
      final job = await JobRepository().getJobById(id);
      if (!mounted) return;
      Navigator.pop(context);
      Navigator.push(
        context,
        MaterialPageRoute(builder: (_) => JobDetailScreen(job: job)),
      );
    } catch (e) {
      if (mounted) {
        Navigator.pop(context);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Unable to open job: $e"), backgroundColor: Colors.red),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.notifications),
        actions: [
          TextButton(
            onPressed: () {
              context.read<NotificationProvider>().markAllAsRead();
            },
            child: Text(l10n.markAllRead, style: const TextStyle(color: Colors.white)),
          ),
        ],
      ),
      body: Consumer<NotificationProvider>(
        builder: (context, provider, child) {
          if (provider.isLoading && provider.notifications.isEmpty) {
            return const Center(child: CircularProgressIndicator());
          }

          if (provider.errorMessage != null && provider.notifications.isEmpty) {
            return Center(child: Text(provider.errorMessage!));
          }

          if (provider.notifications.isEmpty) {
            return Center(child: Text(l10n.noNotificationsFound));
          }

          return RefreshIndicator(
            onRefresh: () async {
              await provider.fetchNotifications(refresh: true);
              await provider.fetchUnreadCount();
            },
            child: ListView.builder(
              controller: _scrollController,
              padding: const EdgeInsets.all(12),
              itemCount: provider.notifications.length + (provider.hasMore ? 1 : 0),
              itemBuilder: (context, index) {
                if (index == provider.notifications.length) {
                  return const Padding(
                    padding: EdgeInsets.all(16.0),
                    child: Center(child: CircularProgressIndicator()),
                  );
                }

                final notification = provider.notifications[index];
                return _buildNotificationCard(notification, l10n);
              },
            ),
          );
        },
      ),
    );
  }

  Widget _buildNotificationCard(NotificationModel notification, AppLocalizations l10n) {
    return Card(
      elevation: 0,
      margin: const EdgeInsets.only(bottom: 12),
      color: notification.isRead ? Colors.white : AppColors.appBarBlue.withOpacity(0.05),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(
          color: notification.isRead ? AppColors.dividerGrey : AppColors.appBarBlue.withOpacity(0.5),
        )
      ),
      child: InkWell(
        borderRadius: BorderRadius.circular(12),
        onTap: () => _handleNotificationTap(notification),
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              CircleAvatar(
                backgroundColor: notification.isRead ? Colors.grey.shade200 : AppColors.appBarBlue.withOpacity(0.1),
                child: Icon(
                  _getIconForType(notification.type),
                  color: notification.isRead ? Colors.grey : AppColors.appBarBlue,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      notification.title,
                      style: TextStyle(
                        fontWeight: notification.isRead ? FontWeight.normal : FontWeight.bold,
                        fontSize: 16,
                      ),
                    ),
                    if (notification.category != null && notification.category!.isNotEmpty) ...[
                      const SizedBox(height: 6),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                        decoration: BoxDecoration(
                          color: notification.isEmergency
                              ? Colors.red.shade50
                              : Colors.blue.shade50,
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Text(
                          notification.category!,
                          style: TextStyle(
                            fontSize: 11,
                            fontWeight: FontWeight.w600,
                            color: notification.isEmergency ? Colors.red : Colors.blue,
                          ),
                        ),
                      ),
                    ],
                    const SizedBox(height: 4),
                    Text(
                      notification.body,
                      style: const TextStyle(
                        color: AppColors.textGrey,
                        fontSize: 14,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      _formatDate(notification.createdAt, l10n),
                      style: TextStyle(
                        color: Colors.grey.shade500,
                        fontSize: 12,
                      ),
                    ),
                  ],
                ),
              ),
              if (!notification.isRead)
                 Container(
                  width: 10,
                  height: 10,
                  decoration: BoxDecoration(
                    color: AppColors.errorRed,
                    shape: BoxShape.circle,
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }

  IconData _getIconForType(String type) {
    switch (type) {
      case 'ATTENDANCE_MARKED':
        return Icons.access_time_filled;
      case 'ACCOUNT_APPROVED':
      case 'ACCOUNT_VERIFIED':
      case 'VERIFICATION_SUCCESS':
        return Icons.verified_outlined;
      case 'JOB_APPLIED':
      case 'JOB_PUBLISHED':
      case 'JOB_STATUS_CHANGE':
        return Icons.work;
      case 'MESSAGE_RECEIVED':
      case 'LIVE_CHAT_REQUEST':
      case 'CHAT_REQUEST':
        return Icons.chat_bubble_outline;
      case 'PAYMENT_SUCCESS':
      case 'CONTRIBUTION_VERIFIED':
        return Icons.payments_outlined;
      case 'SCHEME_APPROVED':
        return Icons.verified;
      case 'ORDER_DELIVERED':
        return Icons.local_shipping;
      default:
        return Icons.notifications;
    }
  }

  String _formatDate(DateTime date, AppLocalizations l10n) {
    final now = DateTime.now();
    final difference = now.difference(date);

    if (difference.inDays == 0) {
      return DateFormat.jm().format(date); // e.g., 5:30 PM
    } else if (difference.inDays == 1) {
      return '${l10n.yesterday}, ${DateFormat.jm().format(date)}';
    } else if (difference.inDays < 7) {
      return DateFormat('EEEE, h:mm a').format(date); // e.g., Monday, 5:30 PM
    } else {
      return DateFormat('MMM d, yyyy').format(date); // e.g., Feb 16, 2026
    }
  }
}
