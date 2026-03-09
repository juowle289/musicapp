import 'package:cloud_firestore/cloud_firestore.dart';

class Playlist {
  final String? id; // Changed from int? to String? for Firestore
  final String name;
  final String? coverPath;
  final DateTime createdAt;
  final List<String> songIds; // Changed from List<int> to List<String>
  final String? creatorEmail;

  Playlist({
    this.id,
    required this.name,
    this.coverPath,
    DateTime? createdAt,
    List<String>? songIds,
    this.creatorEmail,
  }) : createdAt = createdAt ?? DateTime.now(),
       songIds = songIds ?? [];

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'coverPath': coverPath,
      'createdAt': createdAt.toIso8601String(),
      'songIds': songIds,
      'creatorEmail': creatorEmail,
    };
  }

  factory Playlist.fromMap(Map<String, dynamic> map) {
    final songIdsList = map['songIds'];
    List<String> songIds = [];
    if (songIdsList is List) {
      songIds = songIdsList.map((e) => e.toString()).toList();
    }
    return Playlist(
      id: map['id']?.toString(),
      name: map['name'] ?? '',
      coverPath: map['coverPath'],
      createdAt: map['createdAt'] != null 
          ? DateTime.parse(map['createdAt']) 
          : DateTime.now(),
      songIds: songIds,
      creatorEmail: map['creatorEmail'],
    );
  }

  // Firestore methods
  Map<String, dynamic> toFirestore() {
    return {
      'name': name,
      'coverPath': coverPath,
      'createdAt': createdAt.toIso8601String(),
      'songIds': songIds,
      'creatorEmail': creatorEmail,
    };
  }

  factory Playlist.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    final songIdsList = data['songIds'];
    List<String> songIds = [];
    if (songIdsList is List) {
      songIds = songIdsList.map((e) => e.toString()).toList();
    }
    return Playlist(
      id: doc.id,
      name: data['name'] ?? '',
      coverPath: data['coverPath'],
      createdAt: data['createdAt'] != null 
          ? DateTime.parse(data['createdAt']) 
          : DateTime.now(),
      songIds: songIds,
      creatorEmail: data['creatorEmail'],
    );
  }

  Playlist copyWith({
    String? id,
    String? name,
    String? coverPath,
    DateTime? createdAt,
    List<String>? songIds,
    String? creatorEmail,
  }) {
    return Playlist(
      id: id ?? this.id,
      name: name ?? this.name,
      coverPath: coverPath ?? this.coverPath,
      createdAt: createdAt ?? this.createdAt,
      songIds: songIds ?? this.songIds,
      creatorEmail: creatorEmail ?? this.creatorEmail,
    );
  }
}
