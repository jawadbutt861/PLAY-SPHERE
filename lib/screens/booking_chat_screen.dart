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

  CollectionReference get _chatCol =>
      _db.collection('bookings').doc(widget.bookingId).collection('chat');

  Stream<Map<String, dynamic>> get _bookingStream => _db
      .collection('bookings')
      .doc(widget.bookingId)
      .snapshots()
      .map((s) => s.exists ? {...s.data()!, 'id': s.id} : widget.booking);

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

    // Fetch manager's payment info
    final managerId = widget.booking['managerId'] as String? ?? '';
    Map<String, dynamic> paymentInfo = {};
    if (managerId.isNotEmpty) {
      try {
        final doc = await FirebaseFirestore.instance
            .collection('users')
            .doc(managerId)
            .get();
        if (doc.exists) {
          final pi = doc.data()?['paymentInfo'];
          if (pi is Map) paymentInfo = Map<String, dynamic>.from(pi);
        }
      } catch (_) {}
    }

    // System confirm message
    await _chatCol.add({
      'text': '✅ Booking confirmed by manager. Please complete payment.',
      'senderId': 'system',
      'senderName': 'System',
      'isSystem': true,
      'createdAt': FieldValue.serverTimestamp(),
    });

    // Payment card message
    if (paymentInfo.isNotEmpty) {
      await _chatCol.add({
        'senderId': _uid,
        'senderName': _userName,
        'isManager': true,
        'isPaymentCard': true,
        'paymentInfo': paymentInfo,
        'createdAt': FieldValue.serverTimestamp(),
      });
    }

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
    final colorScheme = Theme.of(context).colorScheme;

    return Scaffold(
      backgroundColor: colorScheme.surface,
      appBar: ModernAppBar(
        title: widget.isManager ? 'Booking Request' : 'Order Chat',
        gradient: AppTheme.primaryGradient,
      ),
      body: StreamBuilder<Map<String, dynamic>>(
        stream: _bookingStream,
        initialData: widget.booking,
        builder: (context, snap) {
          final b = snap.data ?? widget.booking;
          final status = b['status'] as String? ?? 'pending';

          return Column(
            children: [
              // ── Booking Info Card (Binance P2P style) ──
              _buildOrderCard(b, status, colorScheme),

              // ── Manager action buttons ──
              if (widget.isManager && status == 'pending')
                _buildManagerActions(),

              // ── Chat messages ──
              Expanded(child: _buildMessages(colorScheme)),

              // ── Input bar ──
              if (status != 'rejected' && status != 'cancelled')
                _buildInputBar(colorScheme),
            ],
          );
        },
      ),
    );
  }

  Widget _buildOrderCard(
      Map<String, dynamic> b, String status, ColorScheme colorScheme) {
    Color statusColor;
    IconData statusIcon;
    String statusLabel;
    if (status == 'confirmed') {
      statusColor = AppTheme.successColor;
      statusIcon = Icons.check_circle_rounded;
      statusLabel = 'Confirmed';
    } else if (status == 'rejected') {
      statusColor = AppTheme.errorColor;
      statusIcon = Icons.cancel_rounded;
      statusLabel = 'Rejected';
    } else {
      statusColor = AppTheme.warningColor;
      statusIcon = Icons.hourglass_top_rounded;
      statusLabel = 'Pending Approval';
    }

    return Container(
      margin: const EdgeInsets.all(12),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: colorScheme.surfaceContainerHighest,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: statusColor.withValues(alpha: 0.4), width: 1.5),
      ),
      child: Column(
        children: [
          // Status row
          Row(children: [
            Icon(statusIcon, color: statusColor, size: 18),
            const SizedBox(width: 8),
            Text(statusLabel,
                style: TextStyle(
                    color: statusColor,
                    fontWeight: FontWeight.bold,
                    fontSize: 13)),
            const Spacer(),
            Text('Order #${widget.bookingId.substring(0, 6).toUpperCase()}',
                style: TextStyle(
                    fontSize: 11, color: colorScheme.onSurfaceVariant)),
          ]),
          const SizedBox(height: 10),
          Divider(height: 1, color: Colors.grey.withValues(alpha: 0.2)),
          const SizedBox(height: 10),
          // Details grid
          _orderRow(Icons.stadium_rounded, 'Venue', b['groundName'] ?? ''),
          _orderRow(Icons.sports_outlined, 'Sport', b['groundCategory'] ?? ''),
          _orderRow(Icons.calendar_today_outlined, 'Date', b['date'] ?? ''),
          _orderRow(Icons.access_time_outlined, 'Slot', b['slot'] ?? ''),
          _orderRow(Icons.payments_outlined, 'Payment', 'Pay at Venue'),
          if (b['price'] != null)
            _orderRow(Icons.attach_money_rounded, 'Amount',
                'PKR ${b['price']}',
                valueColor: AppTheme.successColor),
        ],
      ),
    );
  }

  Widget _orderRow(IconData icon, String label, String value,
      {Color? valueColor}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(children: [
        Icon(icon, size: 14, color: AppTheme.primaryColor),
        const SizedBox(width: 8),
        Text(label,
            style: const TextStyle(fontSize: 12, color: Colors.grey)),
        const Spacer(),
        Text(value,
            style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w600,
                color: valueColor)),
      ]),
    );
  }

  Widget _buildManagerActions() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(12, 0, 12, 8),
      child: Row(children: [
        Expanded(
          child: GradientButton(
            text: 'Confirm',
            icon: Icons.check_circle_outline_rounded,
            gradient: const LinearGradient(
                colors: [Color(0xFF34C759), Color(0xFF28A745)]),
            height: 44,
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            textStyle: const TextStyle(
                color: Colors.white,
                fontSize: 13,
                fontWeight: FontWeight.bold),
            onPressed: _confirm,
          ),
        ),
        const SizedBox(width: 10),
        Expanded(
          child: GradientButton(
            text: 'Reject',
            icon: Icons.cancel_outlined,
            gradient: const LinearGradient(
                colors: [Color(0xFFEF4444), Color(0xFFDC2626)]),
            height: 44,
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            textStyle: const TextStyle(
                color: Colors.white,
                fontSize: 13,
                fontWeight: FontWeight.bold),
            onPressed: _reject,
          ),
        ),
      ]),
    );
  }

  Widget _buildMessages(ColorScheme colorScheme) {
    return StreamBuilder<QuerySnapshot>(
      stream: _chatCol.orderBy('createdAt', descending: false).snapshots(),
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
                Icon(Icons.chat_bubble_outline_rounded,
                    size: 48, color: colorScheme.onSurfaceVariant),
                const SizedBox(height: 12),
                Text('No messages yet',
                    style: TextStyle(
                        color: colorScheme.onSurfaceVariant, fontSize: 14)),
                const SizedBox(height: 6),
                Text('Ask the manager about payment details',
                    style: TextStyle(
                        color: colorScheme.onSurfaceVariant, fontSize: 12)),
              ],
            ),
          );
        }
        return ListView.builder(
          controller: _scrollCtrl,
          padding: const EdgeInsets.fromLTRB(12, 8, 12, 8),
          itemCount: docs.length,
          itemBuilder: (_, i) {
            final data = docs[i].data() as Map<String, dynamic>;
            final isSystem = data['isSystem'] == true;
            if (isSystem) return _buildSystemMsg(data['text'] ?? '', colorScheme);
            // Payment card
            if (data['isPaymentCard'] == true) {
              return _buildPaymentCard(
                  Map<String, dynamic>.from(data['paymentInfo'] ?? {}),
                  colorScheme);
            }
            final isMe = data['senderId'] == _uid;
            final ts = data['createdAt'] as Timestamp?;
            final time = ts != null
                ? DateFormat('h:mm a').format(ts.toDate())
                : '';
            return _buildBubble(
                data['text'] ?? '',
                data['senderName'] ?? '',
                time,
                isMe,
                data['isManager'] == true,
                colorScheme,
                imageUrl: data['imageUrl'] as String?);
          },
        );
      },
    );
  }

  Widget _buildSystemMsg(String text, ColorScheme colorScheme) {
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 8),
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
      decoration: BoxDecoration(
        color: AppTheme.primaryColor.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppTheme.primaryColor.withValues(alpha: 0.3)),
      ),
      child: Row(children: [
        const Icon(Icons.info_outline_rounded,
            size: 16, color: AppTheme.primaryColor),
        const SizedBox(width: 8),
        Expanded(
          child: Text(text,
              style: const TextStyle(
                  fontSize: 13, fontWeight: FontWeight.w500)),
        ),
      ]),
    );
  }

  Widget _buildPaymentCard(
      Map<String, dynamic> info, ColorScheme colorScheme) {
    final bank = info['bank'] as String? ?? '';
    final account = info['account'] as String? ?? '';
    final accountName = info['accountName'] as String? ?? '';
    final instructions = info['instructions'] as String? ?? '';

    return Container(
      margin: const EdgeInsets.symmetric(vertical: 10),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
            color: AppTheme.successColor.withValues(alpha: 0.5), width: 1.5),
        color: colorScheme.surfaceContainerHighest,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                  colors: [Color(0xFF10B981), Color(0xFF059669)]),
              borderRadius:
                  const BorderRadius.vertical(top: Radius.circular(14)),
            ),
            child: Row(children: [
              const Icon(Icons.account_balance_wallet_rounded,
                  color: Colors.white, size: 18),
              const SizedBox(width: 8),
              const Text('Payment Details',
                  style: TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                      fontSize: 14)),
              const Spacer(),
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.2),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Text('Pay Now',
                    style: TextStyle(
                        color: Colors.white,
                        fontSize: 10,
                        fontWeight: FontWeight.bold)),
              ),
            ]),
          ),
          // Details
          Padding(
            padding: const EdgeInsets.all(14),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                if (bank.isNotEmpty)
                  _payRow(Icons.account_balance_rounded, 'Bank / Service', bank),
                if (account.isNotEmpty) ...[
                  const SizedBox(height: 8),
                  _payRow(Icons.numbers_rounded, 'Account Number', account,
                      copyable: true),
                ],
                if (accountName.isNotEmpty) ...[
                  const SizedBox(height: 8),
                  _payRow(Icons.person_outline_rounded, 'Account Name',
                      accountName),
                ],
                if (instructions.isNotEmpty) ...[
                  const Divider(height: 20),
                  Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
                    const Icon(Icons.info_outline_rounded,
                        size: 14, color: Colors.grey),
                    const SizedBox(width: 6),
                    Expanded(
                      child: Text(instructions,
                          style: const TextStyle(
                              fontSize: 12, color: Colors.grey)),
                    ),
                  ]),
                ],
                const SizedBox(height: 12),
                Container(
                  padding: const EdgeInsets.symmetric(
                      horizontal: 10, vertical: 8),
                  decoration: BoxDecoration(
                    color: AppTheme.warningColor.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(
                        color: AppTheme.warningColor.withValues(alpha: 0.3)),
                  ),
                  child: const Row(children: [
                    Icon(Icons.warning_amber_rounded,
                        size: 14, color: AppTheme.warningColor),
                    SizedBox(width: 6),
                    Expanded(
                      child: Text(
                        'Send payment screenshot in this chat after transfer.',
                        style: TextStyle(
                            fontSize: 11,
                            color: AppTheme.warningColor,
                            fontWeight: FontWeight.w500),
                      ),
                    ),
                  ]),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _payRow(IconData icon, String label, String value,
      {bool copyable = false}) {
    return Row(children: [
      Icon(icon, size: 14, color: AppTheme.primaryColor),
      const SizedBox(width: 8),
      Text(label,
          style: const TextStyle(fontSize: 12, color: Colors.grey)),
      const Spacer(),
      if (copyable)
        GestureDetector(
          onTap: () {
            Clipboard.setData(ClipboardData(text: value));
          },
          child: Row(children: [
            Text(value,
                style: const TextStyle(
                    fontSize: 13, fontWeight: FontWeight.bold)),
            const SizedBox(width: 4),
            const Icon(Icons.copy_rounded,
                size: 14, color: AppTheme.primaryColor),
          ]),
        )
      else
        Text(value,
            style: const TextStyle(
                fontSize: 13, fontWeight: FontWeight.bold)),
    ]);
  }

  Widget _buildBubble(String text, String sender, String time, bool isMe,
      bool isManager, ColorScheme colorScheme, {String? imageUrl}) {
    return Align(
      alignment: isMe ? Alignment.centerRight : Alignment.centerLeft,
      child: Container(
        margin: const EdgeInsets.only(bottom: 8),
        constraints:
            BoxConstraints(maxWidth: MediaQuery.of(context).size.width * 0.72),
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
        child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              if (!isMe)
                Row(children: [
                  Text(sender,
                      style: TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.bold,
                          color: AppTheme.primaryColor)),
                  if (isManager) ...[
                    const SizedBox(width: 4),
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 5, vertical: 1),
                      decoration: BoxDecoration(
                        color: AppTheme.secondaryColor.withValues(alpha: 0.2),
                        borderRadius: BorderRadius.circular(4),
                      ),
                      child: const Text('Manager',
                          style: TextStyle(
                              fontSize: 9,
                              color: AppTheme.secondaryColor,
                              fontWeight: FontWeight.bold)),
                    ),
                  ],
                ]),
              if (!isMe) const SizedBox(height: 4),
              // Image
              if (imageUrl != null) ...[
                ClipRRect(
                  borderRadius: BorderRadius.circular(10),
                  child: Image.network(
                    imageUrl,
                    width: 200,
                    fit: BoxFit.cover,
                    loadingBuilder: (_, child, progress) => progress == null
                        ? child
                        : const SizedBox(
                            width: 200,
                            height: 120,
                            child: Center(
                                child: CircularProgressIndicator(strokeWidth: 2))),
                    errorBuilder: (_, _, _) => const Icon(Icons.broken_image),
                  ),
                ),
                const SizedBox(height: 4),
              ],
              if (text.isNotEmpty)
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

  Widget _buildInputBar(ColorScheme colorScheme) {
    return Container(
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
          // Image picker button
          GestureDetector(
            onTap: (_sending || _uploadingImage) ? null : _pickAndSendImage,
            child: Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: colorScheme.surface,
                shape: BoxShape.circle,
                border: Border.all(
                    color: AppTheme.primaryColor.withValues(alpha: 0.4)),
              ),
              child: _uploadingImage
                  ? const SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(
                          strokeWidth: 2, color: AppTheme.primaryColor))
                  : const Icon(Icons.image_outlined,
                      color: AppTheme.primaryColor, size: 20),
            ),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: TextField(
              controller: _msgCtrl,
              decoration: InputDecoration(
                hintText: widget.isManager
                    ? 'Send payment instructions...'
                    : 'Ask about payment details...',
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
              decoration: const BoxDecoration(
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
    );
  }
}
