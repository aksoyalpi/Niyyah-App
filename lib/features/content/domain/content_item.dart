enum ContentType { quran, hadith }

final class ContentItem {
  final String id;
  final ContentType type;
  final String arabic;
  final String translationEn;
  final String source;

  const ContentItem({
    required this.id,
    required this.type,
    required this.arabic,
    required this.translationEn,
    required this.source,
  });

  factory ContentItem.fromJson(
    Map<String, dynamic> json, {
    required ContentType type,
  }) {
    return ContentItem(
      id: json['id'] as String,
      type: type,
      arabic: json['arabic'] as String,
      translationEn: json['translationEn'] as String,
      source: json['source'] as String,
    );
  }
}
