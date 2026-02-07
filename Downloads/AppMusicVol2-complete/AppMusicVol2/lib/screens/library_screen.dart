import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'dart:ui';
import '../providers/music_provider.dart';
import '../widgets/song_list_item.dart';
import '../widgets/blurred_container.dart';

class LibraryScreen extends StatelessWidget {
  const LibraryScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Consumer<MusicProvider>(
      builder: (context, musicProvider, child) {
        return CustomScrollView(
          slivers: [
            // App Bar
            SliverAppBar(
              expandedHeight: 120,
              floating: false,
              pinned: true,
              backgroundColor: Colors.transparent,
              flexibleSpace: FlexibleSpaceBar(
                background: Container(
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                      colors: [
                        Colors.purple.withOpacity(0.5),
                        Colors.transparent,
                      ],
                    ),
                  ),
                ),
                title: const Text(
                  'Thư Viện Nhạc',
                  style: TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              actions: [
                IconButton(
                  icon: const Icon(Icons.search, color: Colors.white),
                  onPressed: () {
                    // TODO: Implement search
                  },
                ),
                PopupMenuButton<String>(
                  icon: const Icon(Icons.add, color: Colors.white),
                  color: Colors.grey[900],
                  onSelected: (value) {
                    switch (value) {
                      case 'import_files':
                        musicProvider.importFiles();
                        break;
                      case 'import_folder':
                        musicProvider.importFolder();
                        break;
                      case 'import_folder_structure':
                        musicProvider.importFolderWithPlaylists();
                        break;
                    }
                  },
                  itemBuilder: (context) => [
                    const PopupMenuItem(
                      value: 'import_files',
                      child: Row(
                        children: [
                          Icon(Icons.audio_file, color: Colors.white),
                          SizedBox(width: 12),
                          Text('Thêm file nhạc', style: TextStyle(color: Colors.white)),
                        ],
                      ),
                    ),
                    const PopupMenuItem(
                      value: 'import_folder',
                      child: Row(
                        children: [
                          Icon(Icons.folder, color: Colors.white),
                          SizedBox(width: 12),
                          Text('Thêm thư mục', style: TextStyle(color: Colors.white)),
                        ],
                      ),
                    ),
                    const PopupMenuItem(
                      value: 'import_folder_structure',
                      child: Row(
                        children: [
                          Icon(Icons.folder_special, color: Colors.white),
                          SizedBox(width: 12),
                          Text('Thêm thư mục (tạo playlists)', style: TextStyle(color: Colors.white)),
                        ],
                      ),
                    ),
                  ],
                ),
              ],
            ),

            // Stats
            if (musicProvider.allSongs.isNotEmpty)
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: BlurredContainer(
                    borderRadius: BorderRadius.circular(16),
                    padding: const EdgeInsets.all(20),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceAround,
                      children: [
                        _buildStatItem(
                          Icons.music_note,
                          '${musicProvider.allSongs.length}',
                          'Bài hát',
                        ),
                        Container(
                          width: 1,
                          height: 40,
                          color: Colors.white.withOpacity(0.2),
                        ),
                        _buildStatItem(
                          Icons.favorite,
                          '${musicProvider.favoriteSongs.length}',
                          'Yêu thích',
                        ),
                        Container(
                          width: 1,
                          height: 40,
                          color: Colors.white.withOpacity(0.2),
                        ),
                        _buildStatItem(
                          Icons.library_music,
                          '${musicProvider.playlists.length}',
                          'Playlists',
                        ),
                      ],
                    ),
                  ),
                ),
              ),

            // Play All Button
            if (musicProvider.allSongs.isNotEmpty)
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  child: InkWell(
                    onTap: () => musicProvider.playAll(),
                    child: BlurredContainer(
                      borderRadius: BorderRadius.circular(12),
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      color: Colors.purple.withOpacity(0.3),
                      child: const Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.play_arrow, color: Colors.white, size: 28),
                          SizedBox(width: 8),
                          Text(
                            'Phát tất cả',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),

            // Songs List
            if (musicProvider.isLoading)
              const SliverFillRemaining(
                child: Center(
                  child: CircularProgressIndicator(
                    valueColor: AlwaysStoppedAnimation<Color>(Colors.purple),
                  ),
                ),
              )
            else if (musicProvider.allSongs.isEmpty)
              SliverFillRemaining(
                child: Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.music_note,
                        size: 80,
                        color: Colors.white.withOpacity(0.3),
                      ),
                      const SizedBox(height: 16),
                      Text(
                        'Chưa có bài hát nào',
                        style: TextStyle(
                          color: Colors.white.withOpacity(0.5),
                          fontSize: 18,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'Nhấn nút + để thêm nhạc',
                        style: TextStyle(
                          color: Colors.white.withOpacity(0.3),
                          fontSize: 14,
                        ),
                      ),
                    ],
                  ),
                ),
              )
            else
              SliverList(
                delegate: SliverChildBuilderDelegate(
                  (context, index) {
                    final song = musicProvider.allSongs[index];
                    return SongListItem(
                      song: song,
                      onTap: () => musicProvider.playSong(song),
                    );
                  },
                  childCount: musicProvider.allSongs.length,
                ),
              ),

            // Bottom Padding for Now Playing Bar
            const SliverToBoxAdapter(
              child: SizedBox(height: 80),
            ),
          ],
        );
      },
    );
  }

  Widget _buildStatItem(IconData icon, String value, String label) {
    return Column(
      children: [
        Icon(icon, color: Colors.white, size: 28),
        const SizedBox(height: 8),
        Text(
          value,
          style: const TextStyle(
            color: Colors.white,
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),
        ),
        Text(
          label,
          style: TextStyle(
            color: Colors.white.withOpacity(0.7),
            fontSize: 12,
          ),
        ),
      ],
    );
  }
}
