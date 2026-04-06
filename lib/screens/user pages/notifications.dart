import 'dart:async';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:intl/intl.dart';
import '../../main.dart';
import '../../services/notification_service.dart';

class Notifications extends StatefulWidget {
  const Notifications({super.key});

  @override
  State<Notifications> createState() => _NotificationsState();
}

class _NotificationsState extends State<Notifications> {
  final String? _uid = FirebaseAuth.instance.currentUser?.uid;
  List<Map<String, dynamic>> _notifications = [];
  bool _loading = true;
  StreamSubscription? _sub;

  @override
  void initState() {
    super.initState();
    if (_uid != null) {
      _sub = NotificationService.getUserNotifications(_uid).listen(
        (list) {
          if (mounted) setState(() { _notifications = list; _loading = false; });
        },
        onError: (_) { if (mounted) setState(() => _loading = false); },
      );
    } else {
      setState(() => _loading = false);
    }
  }

  @override
  void dispose() { _sub?.cancel(); super.dispose(); }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Scaffold(
      backgroundColor: colorScheme.surface,
      appBar: ModernAppBar(
        title: 'Notifications',
        gradient: AppTheme.primaryGradient,
        actions: [
          if (_notifications.isNotEmpty)
            PopupMenuButton<String>(
              icon: const Icon(Icons.more_vert, color: Colors.white),
              onSelected: (val) async {
                if (_uid == null) return;
                if (val == 'read') {
                  await NotificationService.markAllAsRead('userId', _uid);
                } else if (val == 'clear') {
                  await NotificationService.clearAll('userId', _uid);
                }
              },
              itemBuilder: (_) => const [
                PopupMenuItem(value: 'read', child: Text('Mark all as read')),
                PopupMenuItem(value: 'clear', child: Text('Clear all')),
              ],
            ),
        ],
      ),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : _notifications.isEmpty
              ? Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Container(
                        padding: const EdgeInsets.all(28),
                        decoration: BoxDecoration(
                          gradient: AppTheme.primaryGradient,
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(Icons.notifications_outlined,
                            size: 60, color: Colors.white),
                      ),
                      const SizedBox(height: 24),
                      Text('No Notifications',
                          style: theme.textTheme.headlineSmall
                              ?.copyWith(fontWeight: FontWeight.bold)),
                      const SizedBox(height: 8),
                      Text(
                        'Booking confirmations and slot reminders\nwill appear here',
                        style: theme.textTheme.bodyMedium?.copyWith(
                            color: colorScheme.onSurfaceVariant),
                        textAlign: TextAlign.center,
                      ),
                    ],
                  ),
                )
              : ListView.builder(
                  padding: const EdgeInsets.all(16),
                  itemCount: _notifications.length,
                  itemBuilder: (_, i) {
                    final n = _notifications[i];
                    final isUnread = n['isRead'] == false;
                    final isSlotStart =
                        n['title']?.toString().contains('started') == true;
                    final ts = n['createdAt'];
                    String timeStr = '';
                    if (ts != null) {
                      try {
                        final dt = (ts as dynamic).toDate() as DateTime;
                        timeStr = DateFormat('d MMM • h:mm a').format(dt);
                      } catch (_) {}
                    }

                    return GestureDetector(
                      onTap: () async {
                        if (isUnread) {
                          await NotificationService.markAsRead(n['id']);
                        }
                      },
                      child: Container(
                        margin: const EdgeInsets.only(bottom: 10),
                        padding: const EdgeInsets.all(14),
                        decoration: BoxDecoration(
                          color: isUnread
                              ? AppTheme.primaryColor.withValues(alpha: 0.08)
                              : colorScheme.surfaceContainerHighest,
                          borderRadius: BorderRadius.circular(16),
                          border: isUnread
                              ? Border.all(
                                  color: AppTheme.primaryColor
                                      .withValues(alpha: 0.4),
                                  width: 1.5)
                              : null,
                        ),
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Container(
                              padding: const EdgeInsets.all(10),
                              decoration: BoxDecoration(
                                gradient: isSlotStart
                                    ? AppTheme.accentGradient
                                    : isUnread
                                        ? AppTheme.primaryGradient
                                        : const LinearGradient(colors: [
                                            Color(0xFF4A5568),
                                            Color(0xFF2D3748)
                                          ]),
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: Icon(
                                isSlotStart
                                    ? Icons.play_circle_outline_rounded
                                    : Icons.event_available_rounded,
                                color: Colors.white,
                                size: 20,
                              ),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Row(children: [
                                    Expanded(
                                      child: Text(
                                        n['title'] ?? 'Notification',
                                        style: TextStyle(
                                            fontWeight: isUnread
                                                ? FontWeight.bold
                                                : FontWeight.w600,
                                            fontSize: 14),
                                      ),
                                    ),
                                    if (isUnread)
                                      Container(
                                        width: 8,
                                        height: 8,
                                        decoration: const BoxDecoration(
                                            color: AppTheme.primaryColor,
                                            shape: BoxShape.circle),
                                      ),
                                  ]),
                                  const SizedBox(height: 4),
                                  Text(
                                    n['body'] ?? '',
                                    style: theme.textTheme.bodySmall?.copyWith(
                                        color: colorScheme.onSurfaceVariant),
                                    maxLines: 3,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                  if (timeStr.isNotEmpty) ...[
                                    const SizedBox(height: 6),
                                    Text(
                                      timeStr,
                                      style: theme.textTheme.bodySmall
                                          ?.copyWith(
                                              color: colorScheme
                                                  .onSurfaceVariant
                                                  .withValues(alpha: 0.6),
                                              fontSize: 11),
                                    ),
                                  ],
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                ),
    );
  }
}
