class ActiveSession {
  final int id;
  final String sid;
  final String? deviceName;
  final String? deviceType;
  final String? platform;
  final String? browser;
  final String? ipAddress;
  final DateTime createdAt;
  final DateTime lastActivity;
  final bool isCurrent;

  ActiveSession({
    required this.id,
    required this.sid,
    this.deviceName,
    this.deviceType,
    this.platform,
    this.browser,
    this.ipAddress,
    required this.createdAt,
    required this.lastActivity,
    this.isCurrent = false,
  });

  factory ActiveSession.fromJson(Map<String, dynamic> json) {
    return ActiveSession(
      id: json['id'],
      sid: json['sid'],
      deviceName: json['device_name'],
      deviceType: json['device_type'],
      platform: json['platform'],
      browser: json['browser'],
      ipAddress: json['ip_address'],
      createdAt: DateTime.parse(json['created_at']),
      lastActivity: DateTime.parse(json['last_activity']),
      isCurrent: json['is_current'] ?? false,
    );
  }

  String get deviceIcon {
    switch (deviceType?.toLowerCase()) {
      case 'mobile':
        return '📱';
      case 'tablet':
        return '📱';
      case 'desktop':
        return '💻';
      default:
        return '🖥️';
    }
  }

  String get timeAgo {
    final difference = DateTime.now().difference(lastActivity);

    if (difference.inMinutes < 1) return 'Agora';
    if (difference.inMinutes < 60) return '${difference.inMinutes}min atrás';
    if (difference.inHours < 24) return '${difference.inHours}h atrás';
    return '${difference.inDays}d atrás';
  }
}