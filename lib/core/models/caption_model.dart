class CaptionModel {
  final String shortCaption;
  final String longCaption;
  final String emojiCaption;
  final List<String> hashtags;

  const CaptionModel({
    required this.shortCaption,
    required this.longCaption,
    required this.emojiCaption,
    required this.hashtags,
  });

  factory CaptionModel.fromJson(Map<String, dynamic> json) {
    return CaptionModel(
      shortCaption: json['short'] as String? ?? '',
      longCaption: json['long'] as String? ?? '',
      emojiCaption: _asString(json['emoji']),
      hashtags: List<String>.from(json['hashtags'] as List? ?? []),
    );
  }

  // Groq sometimes returns the emoji field as a JSON array instead of a single string.
  static String _asString(dynamic value) {
    if (value is String) return value;
    if (value is List) return value.join(' ');
    return '';
  }

  Map<String, dynamic> toJson() => {
        'short': shortCaption,
        'long': longCaption,
        'emoji': emojiCaption,
        'hashtags': hashtags,
      };

  String get hashtagsString => hashtags.map((h) => '#$h').join(' ');
}
