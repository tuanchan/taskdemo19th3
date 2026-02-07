import 'package:flutter/material.dart';
import '../models/song.dart';
import '../providers/music_provider.dart';
import 'package:provider/provider.dart';

class SongListItem extends StatelessWidget {
  final Song song;
  final VoidCallback? onTap;
  final bool showAlbum;

  const SongListItem({
    Key? key,
    required this.song,
    this.onTap,
    this.showAlbum = true,
  }) : super(key: key);

  String _formatDuration(int seconds) {
    final minutes = seconds ~/ 60;
    final remainingSeconds = seconds % 60;
    return '$minutes:${remainingSeconds.toString().padLeft(2, '0')}';
  }

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        child: Row(
          children: [
            // Album Art
            Container(
              width: 56,
              height: 56,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(8),
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [
                    Colors.purple.withOpacity(0.6),
                    Colors.pink.withOpacity(0.6),
                  ],
                ),
              ),
              child: Icon(
                Icons.music_note,
                color: Colors.white.withOpacity(0.9),
                size: 28,
              ),
            ),
            const SizedBox(width: 12),
            
            // Song Info
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    song.title,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 4),
                  Text(
                    showAlbum ? '${song.artist} • ${song.album}' : song.artist,
                    style: TextStyle(
                      color: Colors.white.withOpacity(0.6),
                      fontSize: 14,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),
            
            // Duration
            if (song.duration > 0)
              Padding(
                padding: const EdgeInsets.only(left: 8),
                child: Text(
                  _formatDuration(song.duration),
                  style: TextStyle(
                    color: Colors.white.withOpacity(0.5),
                    fontSize: 13,
                  ),
                ),
              ),
            
            // More Options
            PopupMenuButton<String>(
              icon: Icon(
                Icons.more_vert,
                color: Colors.white.withOpacity(0.7),
              ),
              color: Colors.grey[900],
              onSelected: (value) {
                final provider = Provider.of<MusicProvider>(context, listen: false);
                
                switch (value) {
                  case 'favorite':
                    provider.toggleFavorite(song);
                    break;
                  case 'add_to_playlist':
                    _showAddToPlaylistDialog(context, song);
                    break;
                  case 'delete':
                    _showDeleteDialog(context, song);
                    break;
                }
              },
              itemBuilder: (context) => [
                PopupMenuItem(
                  value: 'favorite',
                  child: Row(
                    children: [
                      Icon(
                        song.isFavorite ? Icons.favorite : Icons.favorite_border,
                        color: song.isFavorite ? Colors.pink : Colors.white,
                        size: 20,
                      ),
                      const SizedBox(width: 12),
                      Text(
                        song.isFavorite ? 'Bỏ yêu thích' : 'Yêu thích',
                        style: const TextStyle(color: Colors.white),
                      ),
                    ],
                  ),
                ),
                const PopupMenuItem(
                  value: 'add_to_playlist',
                  child: Row(
                    children: [
                      Icon(Icons.playlist_add, color: Colors.white, size: 20),
                      SizedBox(width: 12),
                      Text('Thêm vào playlist', style: TextStyle(color: Colors.white)),
                    ],
                  ),
                ),
                const PopupMenuItem(
                  value: 'delete',
                  child: Row(
                    children: [
                      Icon(Icons.delete, color: Colors.red, size: 20),
                      SizedBox(width: 12),
                      Text('Xóa', style: TextStyle(color: Colors.red)),
                    ],
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  void _showAddToPlaylistDialog(BuildContext context, Song song) {
    final provider = Provider.of<MusicProvider>(context, listen: false);
    
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: Colors.grey[900],
        title: const Text('Thêm vào playlist', style: TextStyle(color: Colors.white)),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ...provider.playlists.map((playlist) => ListTile(
              title: Text(playlist.name, style: const TextStyle(color: Colors.white)),
              onTap: () {
                provider.addToPlaylist(playlist.id, song.id);
                Navigator.pop(context);
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text('Đã thêm vào ${playlist.name}')),
                );
              },
            )),
            const Divider(color: Colors.white24),
            ListTile(
              leading: const Icon(Icons.add, color: Colors.white),
              title: const Text('Tạo playlist mới', style: TextStyle(color: Colors.white)),
              onTap: () {
                Navigator.pop(context);
                _showCreatePlaylistDialog(context, song);
              },
            ),
          ],
        ),
      ),
    );
  }

  void _showCreatePlaylistDialog(BuildContext context, Song song) {
    final controller = TextEditingController();
    
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: Colors.grey[900],
        title: const Text('Tạo playlist mới', style: TextStyle(color: Colors.white)),
        content: TextField(
          controller: controller,
          style: const TextStyle(color: Colors.white),
          decoration: InputDecoration(
            hintText: 'Tên playlist',
            hintStyle: TextStyle(color: Colors.white.withOpacity(0.5)),
            enabledBorder: UnderlineInputBorder(
              borderSide: BorderSide(color: Colors.white.withOpacity(0.3)),
            ),
            focusedBorder: const UnderlineInputBorder(
              borderSide: BorderSide(color: Colors.purple),
            ),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Hủy'),
          ),
          TextButton(
            onPressed: () {
              if (controller.text.isNotEmpty) {
                final provider = Provider.of<MusicProvider>(context, listen: false);
                provider.createPlaylist(controller.text).then((_) {
                  final newPlaylist = provider.playlists.first;
                  provider.addToPlaylist(newPlaylist.id, song.id);
                });
                Navigator.pop(context);
              }
            },
            child: const Text('Tạo'),
          ),
        ],
      ),
    );
  }

  void _showDeleteDialog(BuildContext context, Song song) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: Colors.grey[900],
        title: const Text('Xóa bài hát', style: TextStyle(color: Colors.white)),
        content: Text(
          'Bạn có chắc muốn xóa "${song.title}"?',
          style: const TextStyle(color: Colors.white),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Hủy'),
          ),
          TextButton(
            onPressed: () {
              final provider = Provider.of<MusicProvider>(context, listen: false);
              provider.deleteSong(song);
              Navigator.pop(context);
            },
            child: const Text('Xóa', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }
}
