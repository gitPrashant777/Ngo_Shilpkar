import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/notification_provider.dart';
import '../screens/notification_screen.dart';

class NotificationBell extends StatelessWidget {
  final Color iconColor;
  const NotificationBell({super.key, this.iconColor = Colors.white});

  @override
  Widget build(BuildContext context) {
    return Stack(
      alignment: Alignment.center,
      children: [
        IconButton(
          icon: Icon(Icons.notifications_none_rounded, color: iconColor, size: 26),
          onPressed: () {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => const NotificationScreen()),
            );
          },
        ),
        Consumer<NotificationProvider>(
          builder: (context, provider, child) {
            if (provider.unreadCount == 0) return const SizedBox.shrink();

            return Positioned(
              right: 8,
              top: 8,
              child: Container(
                padding: const EdgeInsets.all(4),
                decoration: const BoxDecoration(
                  color: Colors.red,
                  shape: BoxShape.circle,
                ),
                constraints: const BoxConstraints(
                  minWidth: 16,
                  minHeight: 16,
                ),
                child: Text(
                  provider.unreadCount > 99 ? '99+' : '${provider.unreadCount}',
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 8,
                    fontWeight: FontWeight.bold,
                  ),
                  textAlign: TextAlign.center,
                ),
              ),
            );
          },
        ),
      ],
    );
  }
}
