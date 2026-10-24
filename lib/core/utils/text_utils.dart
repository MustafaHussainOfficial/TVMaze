class TextUtils {
  TextUtils._();

  static final RegExp _htmlTag = RegExp(r'<[^>]*>');

  static String? stripHtml(String? html) {
    if (html == null) return null;
    final text = html
        .replaceAll(RegExp(r'<br\s*/?>'), '\n')
        .replaceAll('</p>', '\n')
        .replaceAll(_htmlTag, '')
        .replaceAll('&amp;', '&')
        .replaceAll('&quot;', '"')
        .replaceAll('&#39;', "'")
        .replaceAll('&apos;', "'")
        .replaceAll('&lt;', '<')
        .replaceAll('&gt;', '>')
        .replaceAll('&nbsp;', ' ')
        .replaceAll(RegExp(r'\n{2,}'), '\n')
        .trim();
    return text.isEmpty ? null : text;
  }

  static const _months = [
    'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
    'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec',
  ];

  static String formatDate(DateTime? date) {
    if (date == null) return 'TBA';
    return '${_months[date.month - 1]} ${date.day}, ${date.year}';
  }
}
