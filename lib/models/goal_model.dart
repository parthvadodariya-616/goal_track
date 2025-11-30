class Goal {
  final String id;
  final String title;
  final DateTime date; 
  bool isCompleted;
  final int colorValue;

  Goal({
    required this.id,
    required this.title,
    required this.date,
    this.isCompleted = false,
    this.colorValue = 0xFF3F51B5, // Default Indigo
  });

  Map<String, dynamic> toJson() => {
        'id': id,
        'title': title,
        'date': date.toIso8601String(),
        'isCompleted': isCompleted,
        'colorValue': colorValue,
      };

  factory Goal.fromJson(Map<String, dynamic> json) => Goal(
        id: json['id'],
        title: json['title'],
        date: DateTime.parse(json['date']),
        isCompleted: json['isCompleted'],
        colorValue: json['colorValue'] ?? 0xFF3F51B5,
      );
}