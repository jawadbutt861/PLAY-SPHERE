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

  CollectionReference get _chatCol =>
      _db.collection('bookings').doc(widget.bookingId).collection('chat');

  @override
  void initState() {
    super.initState();
    _stableBookingStream = _db
        .collection('bookings')
        .doc(widget.bookingId)
        .snapshots()
        .map((s) => s.exists ? {...s.data()!, 'id': s.id} : widget.booking);

    // Payment stream — resolve managerId from booking then listen to manager's paymentInfo
    _stablePaymentStream = _db
        .collection('bookings')
        .doc(widget.bookingId)
        .snapshots()
        .asyncExpand((bookingSnap) {
          final data = bookingSnap.exists ? bookingSnap.data()! : <String, dynamic>{};
          // Try widget.booking first, then Firestore booking doc
          final managerId = (data['managerId'] as String?)?.isNotEmpty == true
              ? data['managerId'] as String
              : (widget.booking['managerId'] as String? ?? '');

          if (managerId.isEmpty) return Stream.value(<String, dynamic>{});

          return _db
              .collection('users')
              .doc(managerId)
              .snapshots()
              .map((s) {
                if (!s.exists) return <String, dynamic>{};
                final pi = s.data()?['paymentInfo'];
                if (pi is Map) return Map<String, dynamic>.from(pi);
                return <String, dynamic>{};
              });
        });
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
    } catch (_) {
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
    if (mounted) Navigator.pop(context);
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

          return Column(
            children: [
              _buildOrderBanner(b, status),
              if (widget.isManager && status == 'pending')
                _buildManagerActions(),
              // ── Pinned Payment Card (Binance style) ──
              StreamBuilder<Map<String, dynamic>>(
                stream: _stablePaymentStream,
                builder: (context, piSnap) {
                  final paymentInfo = piSnap.data ?? {};
                  return _buildPinnedPaymentCard(paymentInfo);
                },
              ),
              Expanded(child: _buildMessages(chatBg)),
              if (status != 'rejected' && status != 'cancelled')
                _buildInputBar(),
            ],
          );
        },
      ),
    );
  }

  PreferredSizeWidget _buildAppBar() {
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
            // Avatar
            CircleAvatar(
              radius: 20,
              backgroundColor: AppTheme.primaryColor.withValues(alpha: 0.3),
              child: Icon(
                widget.isManager ? Icons.person_rounded : Icons.stadium_rounded,
                color: AppTheme.primaryColor,
                size: 20,
              ),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    widget.isManager ? 'Booking Request' : widget.booking['groundName'] ?? 'Order Chat',
                    style: const TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                        fontSize: 16),
                  ),
                  Text(
                    'Order #${widget.bookingId.substring(0, 6).toUpperCase()}',
                    style: TextStyle(
                        color: Colors.white.withValues(alpha: 0.6),
                        fontSize: 12),
                  ),
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

    // Clear color distinction:
    // My messages (right) — dark green WhatsApp style
    // Manager messages (left) — dark blue/teal
    // Other user messages (left) — dark grey
    const myBubble    = Color(0xFF005C4B); // WhatsApp sent — dark green
    const managerBubble = Color(0xFF1A3A4A); // Manager — dark teal/blue
    const userBubble  = Color(0xFF1F2C34); // Other user — dark grey

    final bubbleColor = isMe ? myBubble : (isManager ? managerBubble : userBubble);

    // Name color
    final nameColor = isManager ? const Color(0xFFFF9500) : AppTheme.primaryColor;

    final borderRadius = BorderRadius.only(
      topLeft: Radius.circular(isMe ? 12 : (isGrouped ? 12 : 4)),
      topRight: Radius.circular(isMe ? (isGrouped ? 12 : 4) : 12),
      bottomLeft: const Radius.circular(12),
      bottomRight: const Radius.circular(12),
    );

    return Padding(
      padding: EdgeInsets.only(bottom: isGrouped ? 2 : 6, top: isGrouped ? 0 : 2),
      child: Align(
        alignment: isMe ? Alignment.centerRight : Alignment.centerLeft,
        child: Container(
          margin: EdgeInsets.only(left: isMe ? 60 : 8, right: isMe ? 8 : 60),
          padding: EdgeInsets.only(
            left: imageUrl != null ? 4 : 10,
            right: imageUrl != null ? 4 : 10,
            top: imageUrl != null ? 4 : 7,
            bottom: 5,
          ),
          decoration: BoxDecoration(
            color: bubbleColor,
            borderRadius: borderRadius,
            // Subtle left border for received messages
            border: isMe ? null : Border(
              left: BorderSide(color: nameColor.withValues(alpha: 0.6), width: 3),
            ),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              // Sender name — only first bubble in a group, only for received
              if (!isMe && showName) ...[
                Row(children: [
                  Text(
                    sender,
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                      color: nameColor,
                    ),
                  ),
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
                    borderRadius: BorderRadius.circular(8),
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
              // Text + time
              if (text.isNotEmpty) ...[
                Text(text,
                    style: const TextStyle(color: Colors.white, fontSize: 14)),
                const SizedBox(height: 2),
              ],
              // Time row (always at bottom right)
              Row(
                mainAxisSize: MainAxisSize.min,
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  if (text.isEmpty) const SizedBox(width: 4),
                  Text(time,
                      style: TextStyle(
                          fontSize: 10,
                          color: Colors.white.withValues(alpha: 0.5))),
                  if (isMe) ...[
                    const SizedBox(width: 3),
                    Icon(Icons.done_all_rounded,
                        size: 13,
                        color: AppTheme.primaryColor.withValues(alpha: 0.8)),
                  ],
                ],
              ),
            ],
          ),
        ),
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
    return Container(
      color: const Color(0xFF1F2C34),
      padding: const EdgeInsets.fromLTRB(8, 8, 8, 12),
      child: SafeArea(
        top: false,
        child: Row(children: [
          // Image button
          GestureDetector(
            onTap: (_sending || _uploadingImage) ? null : _pickAndSendImage,
            child: Container(
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
          // Text field
          Expanded(
            child: Container(
              decoration: BoxDecoration(
                color: const Color(0xFF2A3942),
                borderRadius: BorderRadius.circular(24),
              ),
              child: TextField(
                controller: _msgCtrl,
                style: const TextStyle(color: Colors.white, fontSize: 15),
                decoration: InputDecoration(
                  hintText: 'Message',
                  hintStyle: TextStyle(
                      color: Colors.white.withValues(alpha: 0.4), fontSize: 15),
                  border: InputBorder.none,
                  contentPadding: const EdgeInsets.symmetric(
                      horizontal: 16, vertical: 10),
                ),
                maxLines: null,
                textInputAction: TextInputAction.send,
                onSubmitted: (_) => _send(),
                onChanged: (_) => setState(() {}),
              ),
            ),
          ),
          const SizedBox(width: 8),
          // Send button
          GestureDetector(
            onTap: _sending ? null : _send,
            child: Container(
              padding: const EdgeInsets.all(12),
              decoration: const BoxDecoration(
                color: AppTheme.primaryColor,
                shape: BoxShape.circle,
              ),
              child: _sending
                  ? const SizedBox(
                      width: 20, height: 20,
                      child: CircularProgressIndicator(
                          strokeWidth: 2, color: Colors.white))
                  : const Icon(Icons.send_rounded,
                      color: Colors.white, size: 20),
            ),
          ),
        ]),
      ),
    );
  }
}
