import 'package:flutter/material.dart';
import 'dart:ui';
import '../services/audio_player_service.dart';
import '../providers/music_provider.dart';
import 'package:provider/provider.dart';

class NowPlayingScreen extends StatefulWidget {
  const NowPlayingScreen({Key? key}) : super(key: key);

  @override
  State<NowPlayingScreen> createState() => _NowPlayingScreenState();
}

class _NowPlayingScreenState extends State<NowPlayingScreen> {
  final audioService = AudioPlayerService.instance;

  String _formatDuration(Duration? duration) {
    if (duration == null) return '0:00';
    String twoDigits(int n) => n.toString().padLeft(2, '0');
    final hours = duration.inHours;
    final minutes = duration.inMinutes.remainder(60);
    final seconds = duration.inSeconds.remainder(60);
    return hours > 0
        ? '$hours:${twoDigits(minutes)}:${twoDigits(seconds)}'
        : '$minutes:${twoDigits(seconds)}';
  }

  @override
  Widget build(BuildContext context) {
    final currentSong = audioService.currentSong;
    if (currentSong == null) {
      Navigator.pop(context);
      return const SizedBox.shrink();
    }

    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            Colors.purple[900]!,
            Colors.black,
            Colors.pink[900]!,
          ],
        ),
      ),
      child: Scaffold(
        backgroundColor: Colors.transparent,
        body: SafeArea(
          child: Column(
            children: [
              // Header
              Padding(
                padding: const EdgeInsets.all(16),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    IconButton(
                      icon: const Icon(Icons.keyboard_arrow_down, color: Colors.white, size: 32),
                      onPressed: () => Navigator.pop(context),
                    ),
                    Column(
                      children: [
                        Text(
                          'Đang phát từ',
                          style: TextStyle(
                            color: Colors.white.withOpacity(0.7),
                            fontSize: 12,
                          ),
                        ),
                        Text(
                          currentSong.album,
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 14,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                    IconButton(
                      icon: const Icon(Icons.more_vert, color: Colors.white),
                      onPressed: () {},
                    ),
                  ],
                ),
              ),

              const Spacer(),

              // Album Art with Blur
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 40),
                child: AspectRatio(
                  aspectRatio: 1,
                  child: Container(
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(20),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.purple.withOpacity(0.3),
                          blurRadius: 40,
                          spreadRadius: 10,
                        ),
                      ],
                    ),
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(20),
                      child: BackdropFilter(
                        filter: ImageFilter.blur(sigmaX: 30, sigmaY: 30),
                        child: Container(
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                              begin: Alignment.topLeft,
                              end: Alignment.bottomRight,
                              colors: [
                                Colors.purple.withOpacity(0.5),
                                Colors.pink.withOpacity(0.5),
                              ],
                            ),
                            border: Border.all(
                              color: Colors.white.withOpacity(0.2),
                              width: 2,
                            ),
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: const Center(
                            child: Icon(
                              Icons.music_note,
                              size: 100,
                              color: Colors.white,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
              ),

              const SizedBox(height: 40),

              // Song Info
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 40),
                child: Column(
                  children: [
                    Text(
                      currentSong.title,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                      ),
                      textAlign: TextAlign.center,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 8),
                    Text(
                      currentSong.artist,
                      style: TextStyle(
                        color: Colors.white.withOpacity(0.7),
                        fontSize: 18,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 40),

              // Progress Bar
              StreamBuilder<Duration>(
                stream: audioService.positionStream,
                builder: (context, snapshot) {
                  final position = snapshot.data ?? Duration.zero;
                  final duration = audioService.audioPlayer.duration ?? Duration.zero;

                  return Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 40),
                    child: Column(
                      children: [
                        SliderTheme(
                          data: SliderTheme.of(context).copyWith(
                            activeTrackColor: Colors.white,
                            inactiveTrackColor: Colors.white.withOpacity(0.2),
                            thumbColor: Colors.white,
                            thumbShape: const RoundSliderThumbShape(enabledThumbRadius: 6),
                            overlayColor: Colors.white.withOpacity(0.2),
                            trackHeight: 3,
                          ),
                          child: Slider(
                            value: position.inMilliseconds.toDouble(),
                            max: duration.inMilliseconds.toDouble() > 0
                                ? duration.inMilliseconds.toDouble()
                                : 1.0,
                            onChanged: (value) {
                              audioService.seek(Duration(milliseconds: value.toInt()));
                            },
                          ),
                        ),
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 8),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                _formatDuration(position),
                                style: TextStyle(
                                  color: Colors.white.withOpacity(0.7),
                                  fontSize: 12,
                                ),
                              ),
                              Text(
                                _formatDuration(duration),
                                style: TextStyle(
                                  color: Colors.white.withOpacity(0.7),
                                  fontSize: 12,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  );
                },
              ),

              const SizedBox(height: 20),

              // Controls
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 40),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    // Shuffle
                    IconButton(
                      icon: Icon(
                        Icons.shuffle,
                        color: audioService.isShuffle
                            ? Colors.purple[300]
                            : Colors.white.withOpacity(0.7),
                        size: 24,
                      ),
                      onPressed: () {
                        setState(() {
                          audioService.toggleShuffle();
                        });
                      },
                    ),

                    // Previous
                    IconButton(
                      icon: const Icon(Icons.skip_previous, color: Colors.white, size: 40),
                      onPressed: () => audioService.skipToPrevious(),
                    ),

                    // Play/Pause
                    StreamBuilder<PlayerState>(
                      stream: audioService.playerStateStream,
                      builder: (context, snapshot) {
                        final isPlaying = snapshot.data?.playing ?? false;

                        return Container(
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            gradient: LinearGradient(
                              colors: [
                                Colors.purple.withOpacity(0.8),
                                Colors.pink.withOpacity(0.8),
                              ],
                            ),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.purple.withOpacity(0.4),
                                blurRadius: 20,
                                spreadRadius: 2,
                              ),
                            ],
                          ),
                          child: IconButton(
                            iconSize: 50,
                            icon: Icon(
                              isPlaying ? Icons.pause : Icons.play_arrow,
                              color: Colors.white,
                            ),
                            onPressed: () {
                              if (isPlaying) {
                                audioService.pause();
                              } else {
                                audioService.play();
                              }
                            },
                          ),
                        );
                      },
                    ),

                    // Next
                    IconButton(
                      icon: const Icon(Icons.skip_next, color: Colors.white, size: 40),
                      onPressed: () => audioService.skipToNext(),
                    ),

                    // Repeat
                    IconButton(
                      icon: Icon(
                        audioService.isRepeatOne ? Icons.repeat_one : Icons.repeat,
                        color: audioService.isRepeatOne
                            ? Colors.purple[300]
                            : Colors.white.withOpacity(0.7),
                        size: 24,
                      ),
                      onPressed: () {
                        setState(() {
                          audioService.toggleRepeatOne();
                        });
                      },
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 20),

              // Favorite Button
              Consumer<MusicProvider>(
                builder: (context, musicProvider, child) {
                  return IconButton(
                    icon: Icon(
                      currentSong.isFavorite ? Icons.favorite : Icons.favorite_border,
                      color: currentSong.isFavorite ? Colors.pink : Colors.white,
                      size: 32,
                    ),
                    onPressed: () {
                      musicProvider.toggleFavorite(currentSong);
                    },
                  );
                },
              ),

              const Spacer(),
            ],
          ),
        ),
      ),
    );
  }
}
