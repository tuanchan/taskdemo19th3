class Playlist {
  final String id;
  String name;
  final DateTime createdDate;
  List<String> songIds;
  String? coverArt;

  Playlist({
    required this.id,
    required this.name,
    required this.createdDate,
    this.songIds = const [],
    this.coverArt,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'createdDate': createdDate.toIso8601String(),
      'songIds': songIds.join(','),
      'coverArt': coverArt,
    };
  }

  factory Playlist.fromMap(Map<String, dynamic> map) {
    return Playlist(
      id: map['id'],
      name: map['name'],
      createdDate: DateTime.parse(map['createdDate']),
      songIds: map['songIds'] != null && map['songIds'].toString().isNotEmpty
          ? map['songIds'].toString().split(',')
          : [],
      coverArt: map['coverArt'],
    );
  }

  Playlist copyWith({
    String? id,
    String? name,
    DateTime? createdDate,
    List<String>? songIds,
    String? coverArt,
  }) {
    return Playlist(
      id: id ?? this.id,
      name: name ?? this.name,
      createdDate: createdDate ?? this.createdDate,
      songIds: songIds ?? this.songIds,
      coverArt: coverArt ?? this.coverArt,
    );
  }
}
