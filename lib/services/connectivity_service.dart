import 'dart:async';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter/material.dart';

class ConnectivityService {
  static final Connectivity _connectivity = Connectivity();
  static final StreamController<bool> _controller =
      StreamController<bool>.broadcast();

  static Stream<bool> get onConnectivityChanged => _controller.stream;
  static bool _isOnline = true;
  static bool get isOnline => _isOnline;

  static void init() {
    _connectivity.onConnectivityChanged.listen((results) {
      final online = results.any((r) => r != ConnectivityResult.none);
      if (online != _isOnline) {
        _isOnline = online;
        _controller.add(online);
      }
    });
    // Initial check
    _connectivity.checkConnectivity().then((results) {
      _isOnline = results.any((r) => r != ConnectivityResult.none);
    });
  }

  static void dispose() => _controller.close();
}

/// Wrap any Scaffold body with this to show a "No Internet" banner
class ConnectivityWrapper extends StatefulWidget {
  final Widget child;
  const ConnectivityWrapper({super.key, required this.child});

  @override
  State<ConnectivityWrapper> createState() => _ConnectivityWrapperState();
}

class _ConnectivityWrapperState extends State<ConnectivityWrapper>
    with SingleTickerProviderStateMixin {
  late AnimationController _animController;
  late Animation<Offset> _slideAnim;
  bool _showBanner = false;
  StreamSubscription<bool>? _sub;

  @override
  void initState() {
    super.initState();
    _animController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 300),
    );
    _slideAnim = Tween<Offset>(
      begin: const Offset(0, -1),
      end: Offset.zero,
    ).animate(CurvedAnimation(parent: _animController, curve: Curves.easeOut));

    _sub = ConnectivityService.onConnectivityChanged.listen((online) {
      if (!mounted) return;
      if (!online) {
        setState(() => _showBanner = true);
        _animController.forward();
      } else {
        _animController.reverse().then((_) {
          if (mounted) setState(() => _showBanner = false);
        });
      }
    });

    // Show banner immediately if already offline
    if (!ConnectivityService.isOnline) {
      _showBanner = true;
      _animController.forward();
    }
  }

  @override
  void dispose() {
    _sub?.cancel();
    _animController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        widget.child,
        if (_showBanner)
          Positioned(
            top: 0,
            left: 0,
            right: 0,
            child: SlideTransition(
              position: _slideAnim,
              child: Material(
                color: Colors.transparent,
                child: Container(
                  padding: const EdgeInsets.symmetric(
                      horizontal: 16, vertical: 10),
                  decoration: const BoxDecoration(
                    color: Color(0xFFEF4444),
                    borderRadius: BorderRadius.vertical(
                        bottom: Radius.circular(12)),
                  ),
                  child: SafeArea(
                    bottom: false,
                    child: Row(
                      children: const [
                        Icon(Icons.wifi_off_rounded,
                            color: Colors.white, size: 18),
                        SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            'No internet connection',
                            style: TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.w600,
                                fontSize: 13),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),
      ],
    );
  }
}
