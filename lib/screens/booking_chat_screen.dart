import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:image_picker/image_picker.dart';
import 'package:intl/intl.dart';
import '../main.dart';
import '../services/booking_service.dart';
import '../services/cloudinary_service.dart';

class BookingChatScreen extends StatefulWidget {
  final String bookingId;
  final Map<String, dynamic> booking;
  final bool isManager;

  const BookingChatScreen({
    super.key,
    required this.bookingId,
    required this.booking,
    required this.isManager,
  });

  /// chatId = userId_managerId — same pair ka hamesha ek hi chat
  static String chatId(String userId, String managerId) => '${userId}_$managerId';

  @override
  State<BookingChatScreen> createState() => _BookingChatScreenState();
}

class _BookingChatScreenState extends State<BookingChatScreen> {
  final _db = FirebaseFirestore.instance;
  final _msgCtrl = TextEditingController();
  final _scrollCtrl = ScrollController();
  final String? _uid = FirebaseAuth.instance.currentUser?.uid;
  final String _userName =
      FirebaseAuth.instance.currentUser?.displayName ??
      FirebaseAuth.instance.currentUser?.email ??
      'User';
  bool _sending = false;
  bool _uploadingImage = false;
  bool _paymentCardExpanded = false;

  // Stable stream references — created once, not on every rebuild
  late final Stream<Map<String, dynamic>> _stableBookingStream;
  late final Stream<Map<String, dynamic>> _stablePaymentStream;

  /// userId_managerId — ek user aur manager ke beech hamesha ek hi chat
  String get _chatId {
    final managerId = widget.booking['managerId'] as String? ?? '';
    // userId: booking map se lo, fallback current user
    final userId = (widget.booking['userId'] as String?)?.isNotEmpty == true
        ? widget.booking['userId'] as String
        : (_uid ?? '');
    return '${userId}_$managerId';
  }

  CollectionReference get _chatCol =>
      _db.collection('chats').doc(_chatId).collection('messages');

  @override
  void initState() {
    super.initState();
    _stableBookingStream = _db
        .collection('bookings')
        .doc(widget.bookingId)
        .snapshots()
        .map((s) => s.exists ? {...s.data()!, 'id': s.id} : widget.booking);

    // Payment stream — managerId se manager ki paymentInfo
    final managerId = widget.booking['managerId'] as String? ?? '';
    _stablePaymentStream = managerId.isNotEmpty
        ? _db.collection('users').doc(managerId).snapshots().map((s) {
            if (!s.exists) return <String, dynamic>{};
            final pi = s.data()?['paymentInfo'];
            if (pi is Map) return Map<String, dynamic>.from(pi);
            return <String, dynamic>{};
          })
        : Stream.value(<String, dynamic>{});
  }

  Future<void> _pickAndSendImage() async {
    final picker = ImagePicker();
    final picked = await picker.pickImage(
        source: ImageSource.gallery, imageQuality: 80);
    if (picked == null || _uid == null) return;
    setState(() => _uploadingImage = true);
    try {
      final url = await CloudinaryService.uploadImage(
          File(picked.path), folder: 'chat');
      if (url != null) {
        await _chatCol.add({
          'imageUrl': url,
          'senderId': _uid,
          'senderName': _userName,
          'senderRole': widget.isManager ? 'manager' : 'user',
          'isManager': widget.isManager,
          'createdAt': FieldValue.serverTimestamp(),
        });
        _scrollToBottom();
      }
    } catch (_) {
    } finally {
      if (mounted) setState(() => _uploadingImage = false);
    }
  }

  void _scrollToBottom() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_scrollCtrl.hasClients) {
        _scrollCtrl.animateTo(
          _scrollCtrl.position.maxScrollExtent,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOut,
        );
      }
    });
  }

  Future<void> _send() async {
    final text = _msgCtrl.text.trim();
    if (text.isEmpty || _uid == null) return;
    setState(() => _sending = true);
    try {
      await _chatCol.add({
        'text': text,
        'senderId': _uid,
        'senderName': _userName,
        'senderRole': widget.isManager ? 'manager' : 'user',
        'isManager': widget.isManager,
        'createdAt': FieldValue.serverTimestamp(),
      });
      _msgCtrl.clear();
      _scrollToBottom();
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          content: Text('Failed to send: $e'),
          backgroundColor: Colors.red,
          behavior: SnackBarBehavior.floating,
        ));
      }
    } finally {
      if (mounted) setState(() => _sending = false);
    }
  }

  Future<void> _confirm() async {
    await BookingService.confirmBooking(widget.bookingId);

    // Only send system confirm message — payment card already shown at order placement
    await _chatCol.add({
      'text': '✅ Booking confirmed by manager.',
      'senderId': 'system',
      'senderName': 'System',
      'isSystem': true,
      'createdAt': FieldValue.serverTimestamp(),
    });

    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: const Text('Booking confirmed!'),
        backgroundColor: AppTheme.successColor,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      ));
    }
  }

  Future<void> _reject() async {
    await BookingService.rejectBooking(widget.bookingId);
    await _chatCol.add({
      'text': '❌ Manager has rejected this booking.',
      'senderId': 'system',
      'senderName': 'System',
      'isSystem': true,
      'createdAt': FieldValue.serverTimestamp(),
    });
  }

  @override
  void dispose() {
    _msgCtrl.dispose();
    _scrollCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    const chatBg = Color(0xFF0B141A);

    return Scaffold(
      backgroundColor: chatBg,
      appBar: _buildAppBar(),
      body: StreamBuilder<Map<String, dynamic>>(
        stream: _stableBookingStream,
        initialData: widget.booking,
        builder: (context, snap) {
          final b = snap.data ?? widget.booking;
          final status = b['status'] as String? ?? 'pending';

          return Stack(
            children: [
              // WhatsApp-style subtle background pattern
              Positioned.fill(
                child: CustomPaint(painter: _ChatBgPainter()),
              ),
              Column(
                children: [
                  _buildOrderBanner(b, status),
                  if (widget.isManager && status == 'pending')
                    _buildManagerActions(),
                  StreamBuilder<Map<String, dynamic>>(
                    stream: _stablePaymentStream,
                    builder: (context, piSnap) {
                      final paymentInfo = piSnap.data ?? {};
                      return _buildPinnedPaymentCard(paymentInfo);
                    },
                  ),
                  Expanded(child: _buildMessages(chatBg)),
                  _buildInputBar(),
                ],
              ),
            ],
          );
        },
      ),
    );
  }

  PreferredSizeWidget _buildAppBar() {
    final otherName = widget.isManager 
        ? (widget.booking['userName'] as String? ?? widget.booking['userEmail'] as String? ?? 'User')
        : (widget.booking['groundName'] as String? ?? 'Manager');
    
    // Avatar initials
    String initials = '';
    final words = otherName.split(' ');
    if (words.isNotEmpty) {
      initials = words.length > 1 
          ? '${words[0][0]}${words[1][0]}'.toUpperCase()
          : words[0].substring(0, words[0].length > 1 ? 2 : 1).toUpperCase();
    }

    return PreferredSize(
      preferredSize: const Size.fromHeight(kToolbarHeight),
      child: Container(
        decoration: const BoxDecoration(color: Color(0xFF1F2C34)),
        child: SafeArea(
          bottom: false,
          child: Row(children: [
            IconButton(
              icon: const Icon(Icons.arrow_back, color: Colors.white),
              onPressed: () => Navigator.pop(context),
            ),
            // Avatar with initials
            CircleAvatar(
              radius: 20,
              backgroundColor: AppTheme.primaryColor,
              child: Text(initials,
                  style: const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                      fontSize: 14)),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(otherName,
                      style: const TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.w600,
                          fontSize: 16),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis),
                  Text('Tap for booking info',
                      style: TextStyle(
                          color: Colors.white.withValues(alpha: 0.6),
                          fontSize: 12)),
                ],
              ),
            ),
            IconButton(
              icon: const Icon(Icons.info_outline_rounded, color: Colors.white),
              onPressed: () => _showOrderDetails(),
            ),
          ]),
        ),
      ),
    );
  }

  void _showOrderDetails() {
    final b = widget.booking;
    showModalBottomSheet(
      context: context,
      backgroundColor: const Color(0xFF1F2C34),
      shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
      builder: (_) => Padding(
        padding: const EdgeInsets.all(20),
        child: Column(mainAxisSize: MainAxisSize.min, children: [
          Container(
            width: 40, height: 4,
            decoration: BoxDecoration(
                color: Colors.white30,
                borderRadius: BorderRadius.circular(2)),
          ),
          const SizedBox(height: 16),
          const Text('Order Details',
              style: TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                  fontSize: 18)),
          const SizedBox(height: 16),
          _detailRow('Venue', b['groundName'] ?? ''),
          _detailRow('Sport', b['groundCategory'] ?? ''),
          _detailRow('Date', b['date'] ?? ''),
          _detailRow('Slot', b['slot'] ?? ''),
          _detailRow('Payment', 'Pay at Venue'),
          if (b['price'] != null)
            _detailRow('Amount', 'PKR ${b['price']}', valueColor: AppTheme.successColor),
          const SizedBox(height: 8),
        ]),
      ),
    );
  }

  Widget _detailRow(String label, String value, {Color? valueColor}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(children: [
        Text(label, style: TextStyle(color: Colors.white.withValues(alpha: 0.6), fontSize: 13)),
        const Spacer(),
        Text(value,
            style: TextStyle(
                color: valueColor ?? Colors.white,
                fontWeight: FontWeight.w600,
                fontSize: 13)),
      ]),
    );
  }

  Widget _buildPinnedPaymentCard(Map<String, dynamic> info) {
    final bank = info['bank'] as String? ?? '';
    final account = info['account'] as String? ?? '';
    final accountName = info['accountName'] as String? ?? '';
    final instructions = info['instructions'] as String? ?? '';
    final hasInfo = bank.isNotEmpty || account.isNotEmpty;

    return AnimatedContainer(
      duration: const Duration(milliseconds: 250),
      color: const Color(0xFF0D2137),
      child: Column(
        children: [
          // ── Header row — tap to expand/collapse ──
          GestureDetector(
            onTap: () => setState(() => _paymentCardExpanded = !_paymentCardExpanded),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 9),
              decoration: const BoxDecoration(
                gradient: LinearGradient(
                    colors: [Color(0xFF0D6E4E), Color(0xFF0A5C42)]),
              ),
              child: Row(children: [
                const Icon(Icons.account_balance_wallet_rounded,
                    color: Colors.white, size: 16),
                const SizedBox(width: 8),
                const Text('Payment Info',
                    style: TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                        fontSize: 13)),
                const SizedBox(width: 8),
                if (hasInfo)
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 2),
                    decoration: BoxDecoration(
                      color: Colors.white.withValues(alpha: 0.15),
                      borderRadius: BorderRadius.circular(6),
                    ),
                    child: Text(bank.isNotEmpty ? bank : 'Set',
                        style: const TextStyle(
                            color: Colors.white70, fontSize: 10)),
                  ),
                const Spacer(),
                Icon(
                  _paymentCardExpanded
                      ? Icons.keyboard_arrow_up_rounded
                      : Icons.keyboard_arrow_down_rounded,
                  color: Colors.white70,
                  size: 20,
                ),
              ]),
            ),
          ),
          // ── Expanded details ──
          if (_paymentCardExpanded)
            Container(
              width: double.infinity,
              padding: const EdgeInsets.fromLTRB(14, 10, 14, 12),
              child: hasInfo
                  ? Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        if (bank.isNotEmpty)
                          _pinnedRow(Icons.account_balance_rounded, 'Bank', bank),
                        if (account.isNotEmpty) ...[
                          const SizedBox(height: 8),
                          _pinnedRow(Icons.numbers_rounded, 'Account', account,
                              copyable: true),
                        ],
                        if (accountName.isNotEmpty) ...[
                          const SizedBox(height: 8),
                          _pinnedRow(Icons.person_outline_rounded, 'Name', accountName),
                        ],
                        if (instructions.isNotEmpty) ...[
                          const SizedBox(height: 8),
                          Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Icon(Icons.info_outline_rounded,
                                  size: 13,
                                  color: Colors.white.withValues(alpha: 0.4)),
                              const SizedBox(width: 6),
                              Expanded(
                                child: Text(instructions,
                                    style: TextStyle(
                                        fontSize: 11,
                                        color: Colors.white.withValues(alpha: 0.6))),
                              ),
                            ],
                          ),
                        ],
                        const SizedBox(height: 8),
                        Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 10, vertical: 6),
                          decoration: BoxDecoration(
                            color: AppTheme.warningColor.withValues(alpha: 0.1),
                            borderRadius: BorderRadius.circular(6),
                            border: Border.all(
                                color: AppTheme.warningColor.withValues(alpha: 0.3)),
                          ),
                          child: Row(children: [
                            const Icon(Icons.warning_amber_rounded,
                                size: 12, color: AppTheme.warningColor),
                            const SizedBox(width: 6),
                            const Expanded(
                              child: Text(
                                'Send payment screenshot in chat after transfer.',
                                style: TextStyle(
                                    fontSize: 10,
                                    color: AppTheme.warningColor),
                              ),
                            ),
                          ]),
                        ),
                      ],
                    )
                  : Row(children: [
                      Icon(Icons.info_outline_rounded,
                          size: 13,
                          color: Colors.white.withValues(alpha: 0.4)),
                      const SizedBox(width: 8),
                      Text(
                        'Manager has not set payment details yet.',
                        style: TextStyle(
                            fontSize: 12,
                            color: Colors.white.withValues(alpha: 0.5)),
                      ),
                    ]),
            ),
          Divider(height: 1, color: Colors.white.withValues(alpha: 0.08)),
        ],
      ),
    );
  }

  Widget _pinnedRow(IconData icon, String label, String value,
      {bool copyable = false}) {
    return Row(children: [
      Icon(icon, size: 13, color: AppTheme.primaryColor),
      const SizedBox(width: 8),
      Text(label,
          style: TextStyle(
              fontSize: 11, color: Colors.white.withValues(alpha: 0.5))),
      const Spacer(),
      if (copyable)
        GestureDetector(
          onTap: () {
            Clipboard.setData(ClipboardData(text: value));
            ScaffoldMessenger.of(context).showSnackBar(SnackBar(
              content: const Text('Copied!'),
              duration: const Duration(seconds: 1),
              behavior: SnackBarBehavior.floating,
              backgroundColor: AppTheme.successColor,
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8)),
            ));
          },
          child: Row(children: [
            Text(value,
                style: const TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                    color: Colors.white)),
            const SizedBox(width: 5),
            const Icon(Icons.copy_rounded,
                size: 13, color: AppTheme.primaryColor),
          ]),
        )
      else
        Text(value,
            style: const TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.bold,
                color: Colors.white)),
    ]);
  }

  Widget _buildOrderBanner(Map<String, dynamic> b, String status) {
    Color statusColor;
    String statusLabel;
    if (status == 'confirmed') { statusColor = AppTheme.successColor; statusLabel = '✅ Confirmed'; }
    else if (status == 'rejected') { statusColor = AppTheme.errorColor; statusLabel = '❌ Rejected'; }
    else { statusColor = AppTheme.warningColor; statusLabel = '⏳ Pending Approval'; }

    return Container(
      color: const Color(0xFF1F2C34),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Row(children: [
        Icon(Icons.stadium_rounded, size: 16, color: Colors.white.withValues(alpha: 0.7)),
        const SizedBox(width: 8),
        Expanded(
          child: Text(
            '${b['groundName'] ?? ''} • ${b['date'] ?? ''} • ${b['slot'] ?? ''}',
            style: TextStyle(color: Colors.white.withValues(alpha: 0.8), fontSize: 12),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ),
        const SizedBox(width: 8),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
          decoration: BoxDecoration(
            color: statusColor.withValues(alpha: 0.2),
            borderRadius: BorderRadius.circular(8),
            border: Border.all(color: statusColor.withValues(alpha: 0.5)),
          ),
          child: Text(statusLabel,
              style: TextStyle(color: statusColor, fontSize: 10, fontWeight: FontWeight.bold)),
        ),
      ]),
    );
  }

  Widget _buildManagerActions() {
    return Container(
      color: const Color(0xFF1F2C34),
      padding: const EdgeInsets.fromLTRB(12, 6, 12, 10),
      child: Row(children: [
        Expanded(
          child: GradientButton(
            text: 'Confirm',
            icon: Icons.check_circle_outline_rounded,
            gradient: const LinearGradient(colors: [Color(0xFF34C759), Color(0xFF28A745)]),
            height: 42,
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            textStyle: const TextStyle(color: Colors.white, fontSize: 13, fontWeight: FontWeight.bold),
            onPressed: _confirm,
          ),
        ),
        const SizedBox(width: 10),
        Expanded(
          child: GradientButton(
            text: 'Reject',
            icon: Icons.cancel_outlined,
            gradient: const LinearGradient(colors: [Color(0xFFEF4444), Color(0xFFDC2626)]),
            height: 42,
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            textStyle: const TextStyle(color: Colors.white, fontSize: 13, fontWeight: FontWeight.bold),
            onPressed: _reject,
          ),
        ),
      ]),
    );
  }

  Widget _buildMessages(Color chatBg) {
    return StreamBuilder<QuerySnapshot>(
      stream: _chatCol.orderBy('createdAt', descending: false).snapshots(),
      builder: (context, snap) {
        if (snap.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator(color: AppTheme.primaryColor));
        }
        final docs = snap.data?.docs ?? [];

        // Auto scroll on new message
        WidgetsBinding.instance.addPostFrameCallback((_) => _scrollToBottom());

        if (docs.isEmpty) {
          return Center(
            child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
              Icon(Icons.chat_bubble_outline_rounded, size: 56,
                  color: Colors.white.withValues(alpha: 0.3)),
              const SizedBox(height: 12),
              Text('No messages yet',
                  style: TextStyle(color: Colors.white.withValues(alpha: 0.5), fontSize: 15)),
            ]),
          );
        }

        return ListView.builder(
          controller: _scrollCtrl,
          padding: const EdgeInsets.fromLTRB(8, 12, 8, 8),
          itemCount: docs.length,
          itemBuilder: (_, i) {
            final data = docs[i].data() as Map<String, dynamic>;
            final ts = data['createdAt'] as Timestamp?;
            final time = ts != null ? DateFormat('h:mm a').format(ts.toDate()) : '';

            // Date separator
            Widget? separator;
            if (i == 0 || _isDifferentDay(
                (docs[i - 1].data() as Map)['createdAt'] as Timestamp?,
                ts)) {
              separator = _buildDateSeparator(ts);
            }

            // Check if same sender as previous (for grouping)
            final prevData = i > 0 ? docs[i - 1].data() as Map<String, dynamic> : null;
            final sameSenderAsPrev = prevData != null &&
                prevData['senderRole'] == data['senderRole'] &&
                prevData['senderId'] == data['senderId'] &&
                !_isDifferentDay(prevData['createdAt'] as Timestamp?, ts);

            Widget msg;
            if (data['isSystem'] == true) {
              msg = _buildSystemMsg(data['text'] ?? '');
            } else if (data['isPaymentCard'] == true) {
              // Skip — payment info is shown in the pinned card above
              return const SizedBox.shrink();
            } else {
              // isMe: agar mera role match kare message ke role se
              final senderRole = data['senderRole'] as String?;
              final isMe = senderRole != null
                  ? (widget.isManager ? senderRole == 'manager' : senderRole == 'user')
                  : data['senderId'] == _uid; // fallback for old messages
              msg = _buildBubble(
                data['text'] ?? '',
                data['senderName'] ?? '',
                time,
                isMe,
                data['isManager'] == true,
                imageUrl: data['imageUrl'] as String?,
                showName: !isMe && !sameSenderAsPrev,
                isGrouped: sameSenderAsPrev,
              );
            }

            if (separator != null) {
              return Column(children: [separator, msg]);
            }
            return msg;
          },
        );
      },
    );
  }

  bool _isDifferentDay(Timestamp? a, Timestamp? b) {
    if (a == null || b == null) return false;
    final da = a.toDate();
    final db = b.toDate();
    return da.year != db.year || da.month != db.month || da.day != db.day;
  }

  Widget _buildDateSeparator(Timestamp? ts) {
    if (ts == null) return const SizedBox.shrink();
    final date = ts.toDate();
    final now = DateTime.now();
    String label;
    if (date.year == now.year && date.month == now.month && date.day == now.day) {
      label = 'Today';
    } else if (date.year == now.year && date.month == now.month && date.day == now.day - 1) {
      label = 'Yesterday';
    } else {
      label = DateFormat('MMM d, yyyy').format(date);
    }
    return Center(
      child: Container(
        margin: const EdgeInsets.symmetric(vertical: 12),
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 5),
        decoration: BoxDecoration(
          color: const Color(0xFF1F2C34),
          borderRadius: BorderRadius.circular(10),
        ),
        child: Text(label,
            style: TextStyle(
                color: Colors.white.withValues(alpha: 0.6),
                fontSize: 12,
                fontWeight: FontWeight.w500)),
      ),
    );
  }

  Widget _buildSystemMsg(String text) {
    return Center(
      child: Container(
        margin: const EdgeInsets.symmetric(vertical: 6),
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
        decoration: BoxDecoration(
          color: const Color(0xFF1F2C34),
          borderRadius: BorderRadius.circular(10),
        ),
        child: Text(text,
            textAlign: TextAlign.center,
            style: TextStyle(
                fontSize: 12,
                color: Colors.white.withValues(alpha: 0.7))),
      ),
    );
  }

  Widget _buildBubble(String text, String sender, String time, bool isMe,
      bool isManager, {String? imageUrl, bool showName = true, bool isGrouped = false}) {

    // WhatsApp color scheme
    const myBubble      = Color(0xFF005C4B); // sent — dark green
    const theirBubble   = Color(0xFF1F2C34); // received — dark grey

    final bubbleColor = isMe ? myBubble : theirBubble;
    final nameColor   = isManager ? const Color(0xFFFF9500) : const Color(0xFF00BFA5);

    // WhatsApp-style border radius with tail on first message
    final borderRadius = isMe
        ? BorderRadius.only(
            topLeft:     const Radius.circular(18),
            topRight:    Radius.circular(isGrouped ? 18 : 4),
            bottomLeft:  const Radius.circular(18),
            bottomRight: const Radius.circular(18),
          )
        : BorderRadius.only(
            topLeft:     Radius.circular(isGrouped ? 18 : 4),
            topRight:    const Radius.circular(18),
            bottomLeft:  const Radius.circular(18),
            bottomRight: const Radius.circular(18),
          );

    return Padding(
      padding: EdgeInsets.only(
        bottom: isGrouped ? 2 : 4,
        top: isGrouped ? 0 : 2,
        left: isMe ? 60 : 8,
        right: isMe ? 8 : 60,
      ),
      child: Row(
        mainAxisAlignment: isMe ? MainAxisAlignment.end : MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          // Tail for first message in group (received only)
          if (!isMe && !isGrouped)
            CustomPaint(
              painter: _BubbleTailPainter(color: theirBubble, isMe: false),
              child: const SizedBox(width: 8, height: 8),
            ),
          if (!isMe && isGrouped) const SizedBox(width: 8),
          Flexible(
            child: Container(
              padding: EdgeInsets.only(
                left: imageUrl != null ? 3 : 10,
                right: imageUrl != null ? 3 : 10,
                top: imageUrl != null ? 3 : 7,
                bottom: 6,
              ),
              decoration: BoxDecoration(
                color: bubbleColor,
                borderRadius: borderRadius,
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.2),
                    blurRadius: 4,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  // Sender name badge (received, first in group)
                  if (!isMe && showName) ...[
                    Row(children: [
                      Text(sender,
                          style: TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.bold,
                              color: nameColor)),
                      if (isManager) ...[
                        const SizedBox(width: 6),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 1),
                          decoration: BoxDecoration(
                            color: const Color(0xFFFF9500).withValues(alpha: 0.2),
                            borderRadius: BorderRadius.circular(4),
                          ),
                          child: const Text('Manager',
                              style: TextStyle(
                                  fontSize: 9,
                                  color: Color(0xFFFF9500),
                                  fontWeight: FontWeight.bold)),
                        ),
                      ],
                    ]),
                    const SizedBox(height: 3),
                  ],
                  // Image
                  if (imageUrl != null)
                    GestureDetector(
                      onTap: () => _viewImage(imageUrl),
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(10),
                        child: Image.network(
                          imageUrl,
                          width: 220,
                          fit: BoxFit.cover,
                          loadingBuilder: (_, child, progress) => progress == null
                              ? child
                              : Container(
                                  width: 220, height: 140,
                                  color: Colors.black26,
                                  child: const Center(
                                      child: CircularProgressIndicator(
                                          strokeWidth: 2,
                                          color: AppTheme.primaryColor))),
                          errorBuilder: (_, _, _) =>
                              const Icon(Icons.broken_image, color: Colors.white54),
                        ),
                      ),
                    ),
                  if (imageUrl != null && text.isNotEmpty) const SizedBox(height: 4),
                  // Text
                  if (text.isNotEmpty)
                    Text(text,
                        style: const TextStyle(color: Colors.white, fontSize: 14.5, height: 1.3)),
                  const SizedBox(height: 2),
                  // Time + ticks row — bottom right
                  Row(
                    mainAxisSize: MainAxisSize.min,
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      Text(time,
                          style: TextStyle(
                              fontSize: 10,
                              color: Colors.white.withValues(alpha: 0.5))),
                      if (isMe) ...[
                        const SizedBox(width: 4),
                        Icon(Icons.done_all_rounded,
                            size: 14,
                            color: const Color(0xFF53BDEB)),
                      ],
                    ],
                  ),
                ],
              ),
            ),
          ),
          // Tail for sent messages
          if (isMe && !isGrouped)
            CustomPaint(
              painter: _BubbleTailPainter(color: myBubble, isMe: true),
              child: const SizedBox(width: 8, height: 8),
            ),
          if (isMe && isGrouped) const SizedBox(width: 8),
        ],
      ),
    );
  }

  void _viewImage(String url) {
    Navigator.push(context, MaterialPageRoute(
      builder: (_) => Scaffold(
        backgroundColor: Colors.black,
        appBar: AppBar(backgroundColor: Colors.black,
            iconTheme: const IconThemeData(color: Colors.white)),
        body: Center(
          child: InteractiveViewer(
            child: Image.network(url, fit: BoxFit.contain),
          ),
        ),
      ),
    ));
  }

  Widget _buildInputBar() {
    final hasText = _msgCtrl.text.trim().isNotEmpty;
    return Container(
      color: const Color(0xFF1F2C34),
      padding: const EdgeInsets.fromLTRB(8, 6, 8, 10),
      child: SafeArea(
        top: false,
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            // Attach button
            GestureDetector(
              onTap: (_sending || _uploadingImage) ? null : _pickAndSendImage,
              child: Container(
                margin: const EdgeInsets.only(bottom: 2),
                padding: const EdgeInsets.all(10),
                decoration: const BoxDecoration(
                  color: Color(0xFF2A3942),
                  shape: BoxShape.circle,
                ),
                child: _uploadingImage
                    ? const SizedBox(
                        width: 20, height: 20,
                        child: CircularProgressIndicator(
                            strokeWidth: 2, color: AppTheme.primaryColor))
                    : Icon(Icons.attach_file_rounded,
                        color: Colors.white.withValues(alpha: 0.7), size: 22),
              ),
            ),
            const SizedBox(width: 8),
            // Text field — rounded pill like WhatsApp
            Expanded(
              child: Container(
                constraints: const BoxConstraints(maxHeight: 120),
                decoration: BoxDecoration(
                  color: const Color(0xFF2A3942),
                  borderRadius: BorderRadius.circular(26),
                ),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    const SizedBox(width: 16),
                    Expanded(
                      child: TextField(
                        controller: _msgCtrl,
                        style: const TextStyle(color: Colors.white, fontSize: 15),
                        decoration: InputDecoration(
                          hintText: 'Message',
                          hintStyle: TextStyle(
                              color: Colors.white.withValues(alpha: 0.4),
                              fontSize: 15),
                          border: InputBorder.none,
                          contentPadding: const EdgeInsets.symmetric(vertical: 10),
                        ),
                        maxLines: null,
                        textInputAction: TextInputAction.newline,
                        onChanged: (_) => setState(() {}),
                      ),
                    ),
                    const SizedBox(width: 8),
                  ],
                ),
              ),
            ),
            const SizedBox(width: 8),
            // Send / Mic button
            GestureDetector(
              onTap: _sending ? null : _send,
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: hasText ? AppTheme.primaryColor : const Color(0xFF00A884),
                  shape: BoxShape.circle,
                ),
                child: _sending
                    ? const SizedBox(
                        width: 20, height: 20,
                        child: CircularProgressIndicator(
                            strokeWidth: 2, color: Colors.white))
                    : Icon(
                        hasText ? Icons.send_rounded : Icons.mic_rounded,
                        color: Colors.white,
                        size: 22,
                      ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ── WhatsApp-style subtle background pattern ──────────────
class _ChatBgPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = const Color(0xFF1A2530).withValues(alpha: 0.6)
      ..style = PaintingStyle.fill;

    // Subtle dot grid pattern
    const spacing = 28.0;
    for (double x = 0; x < size.width; x += spacing) {
      for (double y = 0; y < size.height; y += spacing) {
        canvas.drawCircle(Offset(x, y), 1.2, paint);
      }
    }
  }

  @override
  bool shouldRepaint(_ChatBgPainter old) => false;
}

// ── Bubble tail painter (WhatsApp style) ─────────────────
class _BubbleTailPainter extends CustomPainter {
  final Color color;
  final bool isMe;
  const _BubbleTailPainter({required this.color, required this.isMe});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()..color = color..style = PaintingStyle.fill;
    final path = Path();
    if (isMe) {
      path.moveTo(0, 0);
      path.lineTo(size.width, 0);
      path.lineTo(0, size.height);
      path.close();
    } else {
      path.moveTo(0, 0);
      path.lineTo(size.width, 0);
      path.lineTo(size.width, size.height);
      path.close();
    }
    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(_BubbleTailPainter old) => old.color != color || old.isMe != isMe;
}
