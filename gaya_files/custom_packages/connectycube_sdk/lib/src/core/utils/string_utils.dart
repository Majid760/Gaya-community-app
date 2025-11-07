const String EMPTY_STRING = "";

bool isEmpty(String? string) {
  return string == null || string.length == 0;
}

// Returns query parameters string, e.g.
// application_id=774&auth_key=aY7WwSRmu2-GbfA&nonce=1451135156
String getQueryString(Map params,
    {String prefix: '&', bool inRecursion: false}) {
  String query = '';

  params.forEach((key, value) {
    if (inRecursion) {
      key = Uri.encodeComponent('[$key]');
    }

    if (value is String || value is int || value is double || value is bool) {
      query += '$prefix$key=${Uri.encodeComponent(value.toString())}';
    } else if (value is List || value is Map) {
      if (value is List) value = value.asMap();
      value.forEach((k, v) {
        query +=
            getQueryString({k: v}, prefix: '$prefix$key', inRecursion: true);
      });
    }
  });

  return inRecursion || query.isEmpty
      ? query
      : query.substring(1, query.length);
}
