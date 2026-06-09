double parseJsonNumeric(dynamic value) {
  if (value == null) return 0.0;
  if (value is num) return value.toDouble();
  if (value is String) return double.tryParse(value) ?? 0.0;
  return 0.0;
}

int parseJsonInt(dynamic value) {
  if (value == null) return 0;
  if (value is int) return value;
  if (value is num) return value.toInt();
  if (value is String) return int.tryParse(value) ?? 0;
  return 0;
}

Map<String, double> parseEarningsByProduct(Map<String, dynamic>? json) {
  if (json == null) return {};
  return json.map(
    (key, value) => MapEntry(key, parseJsonNumeric(value)),
  );
}
