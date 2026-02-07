class Song {
  final String id;
  final String title;
  final String artist;
  final String album;
  final String filePath;
  final int duration; // in seconds
  final String? albumArt;
  final DateTime addedDate;
  bool isFavorite;

  Song({
    required this.id,
    required this.title,
    required this.artist,
    required this.album,
    required this.filePath,
    required this.duration,
    this.albumArt,
    required this.addedDate,
    this.isFavorite = false,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'title': title,
      'artist': artist,
      'album': album,
      'filePath': filePath,
      'duration': duration,
      'albumArt': albumArt,
      'addedDate': addedDate.toIso8601String(),
      'isFavorite': isFavorite ? 1 : 0,
    };
  }

  factory Song.fromMap(Map<String, dynamic> map) {
    return Song(
      id: map['id'],
      title: map['title'],
      artist: map['artist'] ?? 'Unknown Artist',
      album: map['album'] ?? 'Unknown Album',
      filePath: map['filePath'],
      duration: map['duration'] ?? 0,
      albumArt: map['albumArt'],
      addedDate: DateTime.parse(map['addedDate']),
      isFavorite: map['isFavorite'] == 1,
    );
  }

  Song copyWith({
    String? id,
    String? title,
    String? artist,
    String? album,
    String? filePath,
    int? duration,
    String? albumArt,
    DateTime? addedDate,
    bool? isFavorite,
  }) {
    return Song(
      id: id ?? this.id,
      title: title ?? this.title,
      artist: artist ?? this.artist,
      album: album ?? this.album,
      filePath: filePath ?? this.filePath,
      duration: duration ?? this.duration,
      albumArt: albumArt ?? this.albumArt,
      addedDate: addedDate ?? this.addedDate,
      isFavorite: isFavorite ?? this.isFavorite,
    );
  }
}
