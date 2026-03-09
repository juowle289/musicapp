class Comment {
  final String? id; // Changed from int? to String?
  final String songId; // Changed from int to String
  final String authorEmail;
  final String content;
  final DateTime createdAt;

  Comment({
    this.id,
    required this.songId,
    required this.authorEmail,
    required this.content,
    required this.createdAt,
  });

  Comment copyWith({
    String? id,
    String? songId,
    String? authorEmail,
    String? content,
    DateTime? createdAt,
  }) {
    return Comment(
      id: id ?? this.id,
      songId: songId ?? this.songId,
      authorEmail: authorEmail ?? this.authorEmail,
      content: content ?? this.content,
      createdAt: createdAt ?? this.createdAt,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'songId': songId,
      'authorEmail': authorEmail,
      'content': content,
      'createdAt': createdAt.toIso8601String(),
    };
  }

  factory Comment.fromMap(Map<String, dynamic> map) {
    return Comment(
      id: map['id']?.toString(),
      songId: map['songId']?.toString() ?? '',
      authorEmail: map['authorEmail'] as String? ?? '',
      content: map['content'] as String? ?? '',
      createdAt: map['createdAt'] != null
          ? DateTime.parse(map['createdAt'] as String)
          : DateTime.now(),
    );
  }

  // Firestore methods
  Map<String, dynamic> toFirestore() {
    return {
      'songId': songId,
      'authorEmail': authorEmail,
      'content': content,
      'createdAt': createdAt.toIso8601String(),
    };
  }
}
