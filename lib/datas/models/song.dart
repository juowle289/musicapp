import 'package:cloud_firestore/cloud_firestore.dart';

class Song {
  final String? id; // Changed from int? to String? for Firestore
  final String title;
  final String artist;
  final String album;
  final int duration;
  final String? coverPath;
  final String? audioPath;
  final String? creatorEmail;
  final int playCount; // Thêm trường đếm số lượt nghe

  Song({
    this.id,
    required this.title,
    required this.artist,
    required this.album,
    required this.duration,
    this.coverPath,
    this.audioPath,
    this.creatorEmail,
    this.playCount = 0,
  });

  Song copyWith({
    String? id,
    String? title,
    String? artist,
    String? album,
    int? duration,
    String? coverPath,
    String? audioPath,
    String? creatorEmail,
    int? playCount,
  }) {
    return Song(
      id: id ?? this.id,
      title: title ?? this.title,
      artist: artist ?? this.artist,
      album: album ?? this.album,
      duration: duration ?? this.duration,
      coverPath: coverPath ?? this.coverPath,
      audioPath: audioPath ?? this.audioPath,
      creatorEmail: creatorEmail ?? this.creatorEmail,
      playCount: playCount ?? this.playCount,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'title': title,
      'artist': artist,
      'album': album,
      'duration': duration,
      'coverPath': coverPath,
      'audioPath': audioPath,
      'creatorEmail': creatorEmail,
      'playCount': playCount,
    };
  }

  factory Song.fromMap(Map<String, dynamic> map) {
    return Song(
      id: map['id'],
      title: map['title'],
      artist: map['artist'],
      album: map['album'],
      duration: map['duration'],
      coverPath: map['coverPath'],
      audioPath: map['audioPath'],
      creatorEmail: map['creatorEmail'],
      playCount: map['playCount'] ?? 0,
    );
  }

  // Firestore methods
  Map<String, dynamic> toFirestore() {
    return {
      'title': title,
      'artist': artist,
      'album': album,
      'duration': duration,
      'coverPath': coverPath,
      'audioPath': audioPath,
      'creatorEmail': creatorEmail,
      'playCount': playCount,
    };
  }

  factory Song.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return Song(
      id: doc.id,
      title: data['title'] ?? '',
      artist: data['artist'] ?? '',
      album: data['album'] ?? '',
      duration: data['duration'] ?? 0,
      coverPath: data['coverPath'],
      audioPath: data['audioPath'],
      creatorEmail: data['creatorEmail'],
      playCount: data['playCount'] ?? 0,
    );
  }
}
