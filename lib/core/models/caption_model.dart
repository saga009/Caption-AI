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
      emojiCaption: json['emoji'] as String? ?? '',
      hashtags: List<String>.from(json['hashtags'] as List? ?? []),
    );
  }

  Map<String, dynamic> toJson() => {
        'short': shortCaption,
        'long': longCaption,
        'emoji': emojiCaption,
        'hashtags': hashtags,
      };

  String get hashtagsString => hashtags.map((h) => '#$h').join(' ');
}
