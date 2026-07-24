import 'dart:convert';

class ChecklistItem {
  final String text;
  final bool isChecked;

  ChecklistItem({
    required this.text,
    this.isChecked = false,
  });

  ChecklistItem copyWith({
    String? text,
    bool? isChecked,
  }) {
    return ChecklistItem(
      text: text ?? this.text,
      isChecked: isChecked ?? this.isChecked,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'text': text,
      'isChecked': isChecked,
    };
  }

  factory ChecklistItem.fromMap(Map<String, dynamic> map) {
    return ChecklistItem(
      text: map['text'] ?? '',
      isChecked: map['isChecked'] ?? false,
    );
  }

  String toJson() => json.encode(toMap());

  factory ChecklistItem.fromJson(String source) => ChecklistItem.fromMap(json.decode(source));

  static List<ChecklistItem> fromJsonList(String jsonString) {
    if (jsonString.isEmpty) return [];
    try {
      final List<dynamic> parsed = json.decode(jsonString);
      return parsed.map((e) => ChecklistItem.fromMap(e as Map<String, dynamic>)).toList();
    } catch (e) {
      return [];
    }
  }

  static String toJsonList(List<ChecklistItem> items) {
    return json.encode(items.map((e) => e.toMap()).toList());
  }
}
