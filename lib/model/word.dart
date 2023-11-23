class Word {
  final int? id;
  final String value;
  final String? meaning;
  final int? type;
  final bool? isFinished;
  final String? createdAt;
  final String? updatedAt;

  Word({
    this.id,
    required this.value,
    this.meaning,
    this.type,
    this.isFinished,
    this.createdAt,
    this.updatedAt,
  });

  factory Word.fromSqfliteDatabase(Map<String, dynamic> map) => Word(
        id: map['id'].toInt() ?? 0,
        value: map['value'] ?? '',
        meaning: map['meaning'] ?? '',
        type: map['type'].toInt() ?? 0,
        isFinished: (map['isFinished'] == null || map['isFinished'] == 0)
            ? false
            : true,
        createdAt: DateTime.fromMillisecondsSinceEpoch(map['created_at'])
            .toIso8601String(),
        updatedAt: (map['updated_at'] == null)
            ? null
            : DateTime.fromMillisecondsSinceEpoch(map['updated_at'])
                .toIso8601String(),
      );
}
