/// Typed domain model for a note, replacing raw `Map<String, dynamic>`.
class Note {
  final String id;
  final String title;
  final String content;
  final String? imagePath;
  final DateTime createdAt;

  const Note({
    required this.id,
    required this.title,
    required this.content,
    this.imagePath,
    required this.createdAt,
  });

  /// Whether this note has a non-empty image stored in Supabase Storage.
  bool get hasImage => imagePath != null && imagePath!.isNotEmpty;

  factory Note.fromJson(Map<String, dynamic> json) {
    return Note(
      id: json['id'].toString(),
      title: json['title'] as String? ?? '',
      content: json['content'] as String? ?? '',
      imagePath: json['image_path'] as String?,
      createdAt:
          DateTime.tryParse(json['created_at'] as String? ?? '') ??
          DateTime.now(),
    );
  }

  Map<String, dynamic> toJson() => {
    'title': title,
    'content': content,
    'image_path': imagePath,
  };

  Note copyWith({
    String? id,
    String? title,
    String? content,
    String? imagePath,
    bool clearImage = false,
    DateTime? createdAt,
  }) {
    return Note(
      id: id ?? this.id,
      title: title ?? this.title,
      content: content ?? this.content,
      imagePath: clearImage ? null : (imagePath ?? this.imagePath),
      createdAt: createdAt ?? this.createdAt,
    );
  }
}
