import 'package:flutter/material.dart';
import '../main.dart';
import '../services/review_service.dart';

class ReviewBottomSheet extends StatefulWidget {
  final String groundId;
  final String groundName;
  final String userId;
  final String userName;

  const ReviewBottomSheet({
    super.key,
    required this.groundId,
    required this.groundName,
    required this.userId,
    required this.userName,
  });

  static Future<void> show(
    BuildContext context, {
    required String groundId,
    required String groundName,
    required String userId,
    required String userName,
  }) async {
    // Check: completed booking hai?
    final canReview =
        await ReviewService.hasCompletedBooking(userId, groundId);
    if (!context.mounted) return;
    if (!canReview) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text(
              'You can only review after a completed booking',
              style: TextStyle(color: Colors.white)),
          backgroundColor: AppTheme.warningColor,
          behavior: SnackBarBehavior.floating,
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        ),
      );
      return;
    }

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => ReviewBottomSheet(
        groundId: groundId,
        groundName: groundName,
        userId: userId,
        userName: userName,
      ),
    );
  }

  @override
  State<ReviewBottomSheet> createState() => _ReviewBottomSheetState();
}

class _ReviewBottomSheetState extends State<ReviewBottomSheet> {
  double _rating = 0;
  final _commentCtrl = TextEditingController();
  bool _loading = false;

  @override
  void initState() {
    super.initState();
    _loadExisting();
  }

  Future<void> _loadExisting() async {
    final existing =
        await ReviewService.getUserReview(widget.userId, widget.groundId);
    if (existing != null && mounted) {
      setState(() {
        _rating = (existing['rating'] as num?)?.toDouble() ?? 0;
        _commentCtrl.text = existing['comment'] as String? ?? '';
      });
    }
  }

  @override
  void dispose() {
    _commentCtrl.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (_rating == 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please select a rating')),
      );
      return;
    }
    setState(() => _loading = true);
    final ok = await ReviewService.submitReview(
      groundId: widget.groundId,
      userId: widget.userId,
      userName: widget.userName,
      rating: _rating,
      comment: _commentCtrl.text.trim(),
    );
    if (!mounted) return;
    setState(() => _loading = false);
    Navigator.pop(context);
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
            ok ? 'Review submitted!' : 'Failed to submit review',
            style: const TextStyle(color: Colors.white)),
        backgroundColor: ok ? AppTheme.successColor : AppTheme.errorColor,
        behavior: SnackBarBehavior.floating,
        shape:
            RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Padding(
      padding:
          EdgeInsets.only(bottom: MediaQuery.of(context).viewInsets.bottom),
      child: Container(
        decoration: BoxDecoration(
          color: theme.colorScheme.surface,
          borderRadius:
              const BorderRadius.vertical(top: Radius.circular(24)),
        ),
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(
              child: Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: Colors.grey[300],
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),
            const SizedBox(height: 16),
            Text('Rate ${widget.groundName}',
                style: theme.textTheme.titleLarge
                    ?.copyWith(fontWeight: FontWeight.bold)),
            const SizedBox(height: 20),
            // Star rating
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: List.generate(5, (i) {
                final star = i + 1;
                return GestureDetector(
                  onTap: () => setState(() => _rating = star.toDouble()),
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 6),
                    child: Icon(
                      _rating >= star ? Icons.star_rounded : Icons.star_border_rounded,
                      color: _rating >= star
                          ? AppTheme.accentColor
                          : Colors.grey[400],
                      size: 40,
                    ),
                  ),
                );
              }),
            ),
            const SizedBox(height: 20),
            TextField(
              controller: _commentCtrl,
              maxLines: 3,
              decoration: InputDecoration(
                hintText: 'Write your review (optional)',
                border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12)),
              ),
            ),
            const SizedBox(height: 20),
            GradientButton(
              text: 'Submit Review',
              icon: Icons.send_rounded,
              onPressed: _loading ? () {} : _submit,
              width: double.infinity,
              height: 50,
            ),
            const SizedBox(height: 8),
          ],
        ),
      ),
    );
  }
}
