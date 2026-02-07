import 'package:flutter/material.dart';
import 'dart:ui';
import '../services/audio_player_service.dart';
import '../models/song.dart';
import '../screens/now_playing_screen.dart';

class NowPlayingBar extends StatelessWidget {
  const NowPlayingBar({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final audioService = AudioPlayerService.instance;

    return StreamBuilder<PlayerState>(
      stream: audioService.playerStateStream,
      builder: (context, snapshot) {
        final currentSong = audioService.currentSong;
        if (currentSong == null) return const SizedBox.shrink();

        final isPlaying = snapshot.data?.playing ?? false;

        return GestureDetector(
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => const NowPlayingScreen(),
              ),
            );
          },
          child: ClipRRect(
            child: BackdropFilter(
              filter: ImageFilter.blur(sigmaX: 20, sigmaY: 20),
              child: Container(
                height: 70,
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [
                      Colors.purple.withOpacity(0.3),
                      Colors.pink.withOpacity(0.2),
                    ],
                  ),
                  border: Border(
                    top: BorderSide(
                      color: Colors.white.withOpacity(0.2),
                      width: 1,
                    ),
                  ),
                ),
                child: StreamBuilder<Duration>(
                  stream: audioService.positionStream,
                  builder: (context, posSnapshot) {
                    final position = posSnapshot.data ?? Duration.zero;
                    final duration = audioService.audioPlayer.duration ?? Duration.zero;
                    final progress = duration.inMilliseconds > 0
                        ? position.inMilliseconds / duration.inMilliseconds
                        : 0.0;

                    return Column(
                      children: [
                        LinearProgressIndicator(
                          value: progress,
                          backgroundColor: Colors.white.withOpacity(0.1),
                          valueColor: AlwaysStoppedAnimation<Color>(
                            Colors.white.withOpacity(0.8),
                          ),
                          minHeight: 2,
                        ),
                        Expanded(
                          child: Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 16),
                            child: Row(
                              children: [
                                // Album Art
                                Container(
                                  width: 50,
                                  height: 50,
                                  decoration: BoxDecoration(
                                    borderRadius: BorderRadius.circular(8),
                                    gradient: LinearGradient(
                                      colors: [
                                        Colors.purple.withOpacity(0.5),
                                        Colors.pink.withOpacity(0.5),
                                      ],
                                    ),
                                  ),
                                  child: Icon(
                                    Icons.music_note,
                                    color: Colors.white.withOpacity(0.8),
                                  ),
                                ),
                                const SizedBox(width: 12),
                                
                                // Song Info
                                Expanded(
                                  child: Column(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        currentSong.title,
                                        style: const TextStyle(
                                          color: Colors.white,
                                          fontSize: 16,
                                          fontWeight: FontWeight.w600,
                                        ),
                                        maxLines: 1,
                                        overflow: TextOverflow.ellipsis,
                                      ),
                                      const SizedBox(height: 2),
                                      Text(
                                        currentSong.artist,
                                        style: TextStyle(
                                          color: Colors.white.withOpacity(0.7),
                                          fontSize: 13,
                                        ),
                                        maxLines: 1,
                                        overflow: TextOverflow.ellipsis,
                                      ),
                                    ],
                                  ),
                                ),
                                
                                // Controls
                                Row(
                                  children: [
                                    IconButton(
                                      icon: Icon(
                                        isPlaying ? Icons.pause : Icons.play_arrow,
                                        color: Colors.white,
                                        size: 32,
                                      ),
                                      onPressed: () {
                                        if (isPlaying) {
                                          audioService.pause();
                                        } else {
                                          audioService.play();
                                        }
                                      },
                                    ),
                                    IconButton(
                                      icon: const Icon(
                                        Icons.skip_next,
                                        color: Colors.white,
                                        size: 28,
                                      ),
                                      onPressed: () => audioService.skipToNext(),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ),
                        ),
                      ],
                    );
                  },
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}
