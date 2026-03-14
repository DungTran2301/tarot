class TarotCard {
  final String name;
  final String nameVn;
  final String number;
  final String arcana;
  final String suit;
  final String img;
  final List<String> fortuneTelling;
  final List<String> keywords;
  final Map<String, List<String>> meaningsLight;
  final Map<String, List<String>> meaningsShadow;
  final String archetype;
  final String hebrewAlphabet;
  final String numerology;
  final String elemental;
  final String mythicalSpiritual;
  final List<String> questionsToAsk;
  bool isReversed; // Track drawn orientation

  TarotCard({
    required this.name,
    this.nameVn = '',
    required this.number,
    required this.arcana,
    required this.suit,
    required this.img,
    required this.fortuneTelling,
    required this.keywords,
    required this.meaningsLight,
    required this.meaningsShadow,
    this.archetype = '',
    this.hebrewAlphabet = '',
    this.numerology = '',
    this.elemental = '',
    this.mythicalSpiritual = '',
    this.questionsToAsk = const [],
    this.isReversed = false,
  });

  factory TarotCard.fromJson(Map<String, dynamic> json) {
    return TarotCard(
      name: json['name'] ?? '',
      nameVn: json['nameVn'] ?? '',
      number: json['number'] ?? '',
      arcana: json['arcana'] ?? '',
      suit: json['suit'] ?? '',
      img: json['img'] ?? '',
      fortuneTelling: List<String>.from(json['fortune_telling'] ?? []),
      keywords: List<String>.from(json['keywords'] ?? []),
      meaningsLight: _parseMeanings(json, 'light'),
      meaningsShadow: _parseMeanings(json, 'shadow'),
      archetype: json['Archetype'] ?? '',
      hebrewAlphabet: json['Hebrew Alphabet'] ?? '',
      numerology: json['Numerology'] ?? '',
      elemental: json['Elemental'] ?? '',
      mythicalSpiritual: json['Mythical/Spiritual'] ?? '',
      questionsToAsk: List<String>.from(json['Questions to Ask'] ?? []),
    );
  }

  static Map<String, List<String>> _parseMeanings(
    Map<String, dynamic> json,
    String type,
  ) {
    if (json['meanings'] != null && json['meanings'][type] != null) {
      // Since 'meanings' might have weird formats, handle it safely
      var items = json['meanings'][type];
      if (items is List) {
        return {type: List<String>.from(items)};
      } else if (items is Map) {
        return items.map(
          (key, value) => MapEntry(key, List<String>.from(value)),
        );
      }
    }
    return {};
  }
}
