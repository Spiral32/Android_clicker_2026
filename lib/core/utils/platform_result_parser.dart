class PlatformResultParser {
  const PlatformResultParser._();

  static Map<String, dynamic> parseMap(dynamic value) {
    if (value is Map) {
      return value.map(
        (key, dynamic mapValue) => MapEntry(key.toString(), mapValue),
      );
    }

    return const <String, dynamic>{};
  }
}
