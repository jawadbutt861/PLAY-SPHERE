/// Client-side rate limiter for sensitive auth actions.
/// Prevents brute-force login attempts and spam on password reset.
///
/// Usage:
///   if (!RateLimiter.allow('login')) {
///     // show "too many attempts" error
///     return;
///   }
class RateLimiter {
  RateLimiter._();

  // action -> list of attempt timestamps
  static final Map<String, List<DateTime>> _attempts = {};

  // Per-action config: (maxAttempts, windowSeconds, cooldownSeconds)
  static const Map<String, _Config> _configs = {
    'login':          _Config(maxAttempts: 5,  windowSeconds: 60,  cooldownSeconds: 120),
    'signup':         _Config(maxAttempts: 3,  windowSeconds: 60,  cooldownSeconds: 60),
    'password_reset': _Config(maxAttempts: 3,  windowSeconds: 300, cooldownSeconds: 300),
    'google_signin':  _Config(maxAttempts: 5,  windowSeconds: 60,  cooldownSeconds: 60),
  };

  /// Returns true if the action is allowed, false if rate-limited.
  static bool allow(String action) {
    final config = _configs[action];
    if (config == null) return true; // unknown action — allow

    final now = DateTime.now();
    final window = Duration(seconds: config.windowSeconds);

    // Prune old attempts outside the window
    _attempts[action] = (_attempts[action] ?? [])
        .where((t) => now.difference(t) < window)
        .toList();

    if ((_attempts[action]?.length ?? 0) >= config.maxAttempts) {
      return false;
    }

    _attempts[action]!.add(now);
    return true;
  }

  /// Seconds remaining until the action is allowed again. 0 if allowed now.
  static int cooldownRemaining(String action) {
    final config = _configs[action];
    if (config == null) return 0;

    final now = DateTime.now();
    final window = Duration(seconds: config.windowSeconds);
    final recent = (_attempts[action] ?? [])
        .where((t) => now.difference(t) < window)
        .toList();

    if (recent.length < config.maxAttempts) return 0;

    // Oldest attempt in window + cooldown - now
    recent.sort();
    final unlockAt = recent.first.add(Duration(seconds: config.cooldownSeconds));
    final remaining = unlockAt.difference(now).inSeconds;
    return remaining > 0 ? remaining : 0;
  }

  /// Reset attempts for an action (e.g. after successful login).
  static void reset(String action) => _attempts.remove(action);
}

class _Config {
  final int maxAttempts;
  final int windowSeconds;
  final int cooldownSeconds;
  const _Config({
    required this.maxAttempts,
    required this.windowSeconds,
    required this.cooldownSeconds,
  });
}
