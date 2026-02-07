import 'package:just_audio/just_audio.dart';
import 'package:audio_service/audio_service.dart';
import '../models/song.dart';

class AudioPlayerService {
  static final AudioPlayerService instance = AudioPlayerService._init();
  
  final AudioPlayer _audioPlayer = AudioPlayer();
  List<Song> _playlist = [];
  int _currentIndex = 0;
  bool _isRepeatOne = false;
  bool _isShuffle = false;

  AudioPlayerService._init();

  AudioPlayer get audioPlayer => _audioPlayer;
  List<Song> get playlist => _playlist;
  int get currentIndex => _currentIndex;
  Song? get currentSong => _playlist.isEmpty ? null : _playlist[_currentIndex];
  bool get isRepeatOne => _isRepeatOne;
  bool get isShuffle => _isShuffle;

  Stream<Duration> get positionStream => _audioPlayer.positionStream;
  Stream<Duration?> get durationStream => _audioPlayer.durationStream;
  Stream<PlayerState> get playerStateStream => _audioPlayer.playerStateStream;

  Future<void> setPlaylist(List<Song> songs, {int initialIndex = 0}) async {
    _playlist = songs;
    _currentIndex = initialIndex;
    if (_playlist.isNotEmpty) {
      await _loadSong(_playlist[_currentIndex]);
    }
  }

  Future<void> _loadSong(Song song) async {
    try {
      await _audioPlayer.setFilePath(song.filePath);
    } catch (e) {
      print('Error loading song: $e');
    }
  }

  Future<void> play() async {
    await _audioPlayer.play();
  }

  Future<void> pause() async {
    await _audioPlayer.pause();
  }

  Future<void> stop() async {
    await _audioPlayer.stop();
  }

  Future<void> seek(Duration position) async {
    await _audioPlayer.seek(position);
  }

  Future<void> skipToNext() async {
    if (_playlist.isEmpty) return;
    
    if (_isShuffle) {
      _currentIndex = (_currentIndex + 1) % _playlist.length;
    } else {
      _currentIndex = (_currentIndex + 1) % _playlist.length;
    }
    
    await _loadSong(_playlist[_currentIndex]);
    await play();
  }

  Future<void> skipToPrevious() async {
    if (_playlist.isEmpty) return;
    
    if (_audioPlayer.position.inSeconds > 3) {
      await seek(Duration.zero);
    } else {
      _currentIndex = (_currentIndex - 1 + _playlist.length) % _playlist.length;
      await _loadSong(_playlist[_currentIndex]);
      await play();
    }
  }

  Future<void> playAtIndex(int index) async {
    if (index >= 0 && index < _playlist.length) {
      _currentIndex = index;
      await _loadSong(_playlist[_currentIndex]);
      await play();
    }
  }

  void toggleRepeatOne() {
    _isRepeatOne = !_isRepeatOne;
    _audioPlayer.setLoopMode(_isRepeatOne ? LoopMode.one : LoopMode.off);
  }

  void toggleShuffle() {
    _isShuffle = !_isShuffle;
  }

  Future<void> setVolume(double volume) async {
    await _audioPlayer.setVolume(volume.clamp(0.0, 1.0));
  }

  void dispose() {
    _audioPlayer.dispose();
  }
}
