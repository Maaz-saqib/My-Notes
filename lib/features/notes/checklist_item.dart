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

  factory ChecklistItem.fromMap(Map<dynamic, dynamic> map) {
    return ChecklistItem(
      text: map['text']?.toString() ?? '',
      isChecked: map['isChecked'] == true,
    );
  }

  String toJson() => json.encode(toMap());

  factory ChecklistItem.fromJson(String source) => ChecklistItem.fromMap(json.decode(source));

  static List<ChecklistItem> fromJsonList(String jsonString) {
    if (jsonString.isEmpty) return [];
    try {
      final dynamic parsed = json.decode(jsonString);
      if (parsed is! List) return [];
      return parsed
          .whereType<Map>()
          .map((e) => ChecklistItem.fromMap(e))
          .toList();
    } catch (e) {
      return [];
    }
  }

  static String toJsonList(List<ChecklistItem> items) {
    return json.encode(items.map((e) => e.toMap()).toList());
  }
}
