import 'dart:async';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart';
import '../../../main.dart';

class TournamentAnnouncementsScreen extends StatefulWidget {
  final String tournamentId;
  final String tournamentName;
  final String creatorId;

  const TournamentAnnouncementsScreen({
    super.key,
    required this.tournamentId,
    required this.tournamentName,
    required this.creatorId,
  });

  @override
  State<TournamentAnnouncementsScreen> createState() =>
      _TournamentAnnouncementsScreenState();
}

class _TournamentAnnouncementsScreenState
    extends State<TournamentAnnouncementsScreen> {
  final _db = FirebaseFirestore.instance;
  final _msgController = TextEditingController();
  final _scrollController = ScrollController();
  final String? _uid = FirebaseAuth.instance.currentUser?.uid;
  final String _userName =
      FirebaseAuth.instance.currentUser?.displayName ?? 'User';
  bool _sending = false;

  CollectionReference get _col =>
      _db.collection('tournaments').doc(widget.tournamentId).collection('announcements');

  bool get _isCreator => _uid == widget.creatorId;

  @override
  void dispose() {
    _msgController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  Future<void> _send() async {
    final text = _msgController.text.trim();
    if (text.isEmpty || _uid == null) return;
    setState(() => _sending = true);
    try {
      await _col.add({
        'text': text,
        'senderId': _uid,
        'senderName': _userName,
        'isAnnouncement': _isCreator,
        'createdAt': FieldValue.serverTimestamp(),
      });
      _msgController.clear();
      // Scroll to bottom
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (_scrollController.hasClients) {
          _scrollController.animateTo(
            _scrollController.position.maxScrollExtent,
            duration: const Duration(milliseconds: 300),
            curve: Curves.easeOut,
          );
        }
      });
    } catch (_) {} finally {
      if (mounted) setState(() => _sending = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Scaffold(
      backgroundColor: colorScheme.surface,
      appBar: const ModernAppBar(
        title: 'Announcements',
        gradient: AppTheme.primaryGradient,
      ),
      body: Column(
        children: [
          // Announcement banner for creator
          if (_isCreator)
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              color: AppTheme.accentColor.withValues(alpha: 0.15),
              child: Row(children: [
                const Icon(Icons.campaign_rounded,
                    color: AppTheme.accentColor, size: 18),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    'You are the organizer — your messages appear as announcements',
                    style: TextStyle(
                        fontSize: 12,
                        color: AppTheme.accentColor,
                        fontWeight: FontWeight.w500),
                  ),
                ),
              ]),
            ),

          // Messages list
          Expanded(
            child: StreamBuilder<QuerySnapshot>(
              stream: _col
                  .orderBy('createdAt', descending: false)
                  .snapshots(),
              builder: (context, snap) {
                if (snap.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }
                final docs = snap.data?.docs ?? [];
                if (docs.isEmpty) {
                  return Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.campaign_outlined,
                            size: 56, color: colorScheme.onSurfaceVariant),
                        const SizedBox(height: 12),
                        Text('No announcements yet',
                            style: TextStyle(
                                color: colorScheme.onSurfaceVariant,
                                fontSize: 16)),
                        if (_isCreator)
                          Padding(
                            padding: const EdgeInsets.only(top: 8),
                            child: Text('Post the first announcement below',
                                style: TextStyle(
                                    color: colorScheme.onSurfaceVariant,
                                    fontSize: 13)),
                          ),
                      ],
                    ),
                  );
                }

                return ListView.builder(
                  controller: _scrollController,
                  padding: const EdgeInsets.all(16),
                  itemCount: docs.length,
                  itemBuilder: (_, i) {
                    final data = docs[i].data() as Map<String, dynamic>;
                    final isMe = data['senderId'] == _uid;
                    final isAnnouncement = data['isAnnouncement'] == true;
                    final ts = data['createdAt'] as Timestamp?;
                    final time = ts != null
                        ? DateFormat('MMM d, h:mm a').format(ts.toDate())
                        : '';

                    if (isAnnouncement) {
                      return _buildAnnouncementBubble(
                          data['text'] ?? '',
                          data['senderName'] ?? '',
                          time,
                          colorScheme);
                    }
                    return _buildChatBubble(
                        data['text'] ?? '',
                        data['senderName'] ?? '',
                        time,
                        isMe,
                        colorScheme);
                  },
                );
              },
            ),
          ),

          // Input
          Container(
            padding: const EdgeInsets.fromLTRB(12, 8, 12, 12),
            decoration: BoxDecoration(
              color: colorScheme.surfaceContainerHighest,
              border: Border(
                  top: BorderSide(
                      color: colorScheme.outline.withValues(alpha: 0.3))),
            ),
            child: SafeArea(
              top: false,
              child: Row(children: [
                Expanded(
                  child: TextField(
                    controller: _msgController,
                    decoration: InputDecoration(
                      hintText: _isCreator
                          ? 'Post an announcement...'
                          : 'Write a message...',
                      filled: true,
                      fillColor: colorScheme.surface,
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(24),
                        borderSide: BorderSide.none,
                      ),
                      contentPadding: const EdgeInsets.symmetric(
                          horizontal: 16, vertical: 10),
                    ),
                    maxLines: null,
                    textInputAction: TextInputAction.send,
                    onSubmitted: (_) => _send(),
                  ),
                ),
                const SizedBox(width: 8),
                GestureDetector(
                  onTap: _sending ? null : _send,
                  child: Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      gradient: AppTheme.primaryGradient,
                      shape: BoxShape.circle,
                    ),
                    child: _sending
                        ? const SizedBox(
                            width: 20,
                            height: 20,
                            child: CircularProgressIndicator(
                                strokeWidth: 2, color: Colors.white))
                        : const Icon(Icons.send_rounded,
                            color: Colors.white, size: 20),
                  ),
                ),
              ]),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAnnouncementBubble(
      String text, String sender, String time, ColorScheme colorScheme) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        gradient: AppTheme.accentGradient,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Row(children: [
          const Icon(Icons.campaign_rounded, color: Colors.white, size: 16),
          const SizedBox(width: 6),
          Text('Announcement by $sender',
              style: const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                  fontSize: 12)),
          const Spacer(),
          Text(time,
              style: const TextStyle(color: Colors.white70, fontSize: 10)),
        ]),
        const SizedBox(height: 8),
        Text(text,
            style: const TextStyle(color: Colors.white, fontSize: 14)),
      ]),
    );
  }

  Widget _buildChatBubble(String text, String sender, String time, bool isMe,
      ColorScheme colorScheme) {
    return Align(
      alignment: isMe ? Alignment.centerRight : Alignment.centerLeft,
      child: Container(
        margin: const EdgeInsets.only(bottom: 8),
        constraints: BoxConstraints(
            maxWidth: MediaQuery.of(context).size.width * 0.72),
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
        decoration: BoxDecoration(
          gradient: isMe ? AppTheme.primaryGradient : null,
          color: isMe ? null : colorScheme.surfaceContainerHighest,
          borderRadius: BorderRadius.only(
            topLeft: const Radius.circular(16),
            topRight: const Radius.circular(16),
            bottomLeft: Radius.circular(isMe ? 16 : 4),
            bottomRight: Radius.circular(isMe ? 4 : 16),
          ),
        ),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          if (!isMe)
            Text(sender,
                style: TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.bold,
                    color: AppTheme.primaryColor)),
          Text(text,
              style: TextStyle(
                  fontSize: 14,
                  color: isMe ? Colors.white : colorScheme.onSurface)),
          const SizedBox(height: 4),
          Text(time,
              style: TextStyle(
                  fontSize: 10,
                  color: isMe
                      ? Colors.white70
                      : colorScheme.onSurfaceVariant)),
        ]),
      ),
    );
  }
}
