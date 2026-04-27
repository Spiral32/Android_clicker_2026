class WebSocketStatus {
  const WebSocketStatus({
    this.enabled = false,
    this.running = false,
    this.clientConnected = false,
    this.port,
    this.token = '',
    this.clientAddress,
    this.transport = 'ws',
    this.authMode = 'query_token',
    this.urls = const <String>[],
  });

  final bool enabled;
  final bool running;
  final bool clientConnected;
  final int? port;
  final String token;
  final String? clientAddress;
  final String transport;
  final String authMode;
  final List<String> urls;

  factory WebSocketStatus.fromMap(Map<String, dynamic> map) {
    final rawPort = map['port'];
    final port = switch (rawPort) {
      int value => value,
      String value => int.tryParse(value),
      _ => null,
    };

    return WebSocketStatus(
      enabled: map['enabled'] as bool? ?? false,
      running: map['running'] as bool? ?? false,
      clientConnected: map['clientConnected'] as bool? ?? false,
      port: port,
      token: map['token']?.toString() ?? '',
      clientAddress: map['clientAddress']?.toString(),
      transport: map['transport']?.toString() ?? 'ws',
      authMode: map['authMode']?.toString() ?? 'query_token',
      urls: ((map['urls'] as List?) ?? const [])
          .map((value) => value.toString())
          .where((value) => value.isNotEmpty)
          .toList(growable: false),
    );
  }

  WebSocketStatus copyWith({
    bool? enabled,
    bool? running,
    bool? clientConnected,
    int? port,
    bool clearPort = false,
    String? token,
    String? clientAddress,
    bool clearClientAddress = false,
    String? transport,
    String? authMode,
    List<String>? urls,
  }) {
    return WebSocketStatus(
      enabled: enabled ?? this.enabled,
      running: running ?? this.running,
      clientConnected: clientConnected ?? this.clientConnected,
      port: clearPort ? null : (port ?? this.port),
      token: token ?? this.token,
      clientAddress: clearClientAddress
          ? null
          : (clientAddress ?? this.clientAddress),
      transport: transport ?? this.transport,
      authMode: authMode ?? this.authMode,
      urls: urls ?? this.urls,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'enabled': enabled,
      'running': running,
      'clientConnected': clientConnected,
      'port': port,
      'token': token,
      'clientAddress': clientAddress,
      'transport': transport,
      'authMode': authMode,
      'urls': urls,
    };
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is WebSocketStatus &&
        other.enabled == enabled &&
        other.running == running &&
        other.clientConnected == clientConnected &&
        other.port == port &&
        other.token == token &&
        other.clientAddress == clientAddress &&
        other.transport == transport &&
        other.authMode == authMode &&
        _listEquals(other.urls, urls);
  }

  @override
  int get hashCode => Object.hash(
        enabled,
        running,
        clientConnected,
        port,
        token,
        clientAddress,
        transport,
        authMode,
        Object.hashAll(urls),
      );

  static bool _listEquals(List<String> a, List<String> b) {
    if (a.length != b.length) return false;
    for (var index = 0; index < a.length; index++) {
      if (a[index] != b[index]) return false;
    }
    return true;
  }
}
