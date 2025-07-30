class CardModel {
  final String name;
  final String code;
  final String date;
  final String? image;

  CardModel({
    required this.name,
    required this.code,
    required this.date,
    this.image,
  });

  factory CardModel.fromMap(Map map) {
    return CardModel(
      name: map['name'] ?? '',
      code: map['code'] ?? '',
      date: map['date'] ?? '',
      image: map['image'],
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'name': name,
      'code': code,
      'date': date,
      'image': image,
    };
  }
}
