const List<String> _months = [
  'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
  'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec',
];

const String kAppVersion = '1.0.0';
const List<String> kCurrencies = ['₹', '\$', '€', '£', '¥'];

String money(double v, String sym) {
  final parts = v.abs().toStringAsFixed(2).split('.');
  final intPart = parts[0];
  final buf = StringBuffer();
  for (int i = 0; i < intPart.length; i++) {
    if (i > 0 && (intPart.length - i) % 3 == 0) buf.write(',');
    buf.write(intPart[i]);
  }
  final sign = v < 0 ? '-' : '';
  return '$sign$sym${buf.toString()}.${parts[1]}';
}

String fullDate(DateTime d) => '${d.day} ${_months[d.month - 1]} ${d.year}';

String relativeDate(DateTime d) {
  final now = DateTime.now();
  final today = DateTime(now.year, now.month, now.day);
  final day = DateTime(d.year, d.month, d.day);
  final diff = today.difference(day).inDays;
  if (diff == 0) return 'Today';
  if (diff == 1) return 'Yesterday';
  return fullDate(d);
}

String plainAmount(double v) {
  final s = v.toStringAsFixed(2);
  if (s.endsWith('.00')) return s.substring(0, s.length - 3);
  return s;
}
