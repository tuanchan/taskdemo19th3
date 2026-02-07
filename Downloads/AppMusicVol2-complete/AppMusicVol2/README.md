# AppMusicVol2 - Music Player iOS

Ứng dụng phát nhạc iOS hiện đại với giao diện blur effect đẹp mắt, được xây dựng bằng Flutter.

## Tính năng

✅ **Import nhạc đa dạng**
- Import file MP3, M4A, WAV, AAC từ Files app
- Import cả thư mục nhạc
- Import thư mục với cấu trúc (tự động tạo playlists theo tên thư mục)
- Hỗ trợ iTunes File Sharing
- Hỗ trợ AirDrop và Share Extension

✅ **Quản lý nhạc**
- Thư viện nhạc đầy đủ
- Danh sách yêu thích
- Tạo và quản lý playlists tùy chỉnh
- Thêm/xóa bài hát khỏi playlist
- Xóa bài hát khỏi thư viện

✅ **Phát nhạc**
- Phát/tạm dừng
- Chuyển bài (tiến/lùi)
- Shuffle (phát ngẫu nhiên)
- Repeat (lặp lại 1 bài)
- Thanh tiến trình với seek
- Phát nhạc nền

✅ **Giao diện**
- Blur effects hiện đại như SoundCloud
- Gradient màu tím/hồng đẹp mắt
- Mini player ở dưới màn hình
- Màn hình Now Playing toàn màn hình
- Animation mượt mà

## Yêu cầu hệ thống

- iOS 14.0 trở lên
- Flutter 3.16.0 trở lên

## Cài đặt

### 1. Clone repository

```bash
git clone <repository-url>
cd AppMusicVol2
```

### 2. Cài đặt dependencies

```bash
flutter pub get
cd ios && pod install && cd ..
```

### 3. Build IPA

#### Sử dụng GitHub Actions (Khuyến nghị)

1. Push code lên GitHub
2. Vào tab "Actions"
3. Chọn workflow "Build iOS IPA"
4. Nhấn "Run workflow"
5. Sau khi build xong, download file IPA từ Artifacts

#### Build thủ công

```bash
flutter build ios --release --no-codesign
cd build/ios/iphoneos
mkdir Payload
cp -r Runner.app Payload/
zip -r AppMusicVol2.ipa Payload
```

### 4. Ký và cài đặt bằng ESign

1. Mở ESign
2. Import file `AppMusicVol2.ipa`
3. Chọn certificate của bạn
4. Nhấn Sign
5. Cài đặt vào iPhone

## Cấu trúc dự án

```
lib/
├── main.dart                 # Entry point
├── models/
│   ├── song.dart            # Song model
│   └── playlist.dart        # Playlist model
├── providers/
│   └── music_provider.dart  # State management
├── screens/
│   ├── home_screen.dart
│   ├── library_screen.dart
│   ├── favorites_screen.dart
│   ├── playlists_screen.dart
│   ├── playlist_detail_screen.dart
│   └── now_playing_screen.dart
├── services/
│   ├── database_helper.dart        # SQLite database
│   ├── audio_player_service.dart   # Audio player
│   └── file_import_service.dart    # File import
└── widgets/
    ├── blurred_container.dart
    ├── now_playing_bar.dart
    └── song_list_item.dart
```

## Sử dụng

### Import nhạc

1. Mở app
2. Vào tab "Thư viện"
3. Nhấn nút "+" ở góc trên
4. Chọn:
   - "Thêm file nhạc": Chọn nhiều file
   - "Thêm thư mục": Import cả folder
   - "Thêm thư mục (tạo playlists)": Tự động tạo playlist theo cấu trúc thư mục

### Tạo Playlist

1. Vào tab "Playlists"
2. Nhấn nút "+"
3. Nhập tên playlist
4. Thêm bài hát vào playlist từ menu "..." của mỗi bài

### Phát nhạc

1. Nhấn vào bài hát để phát
2. Thanh mini player xuất hiện ở dưới
3. Nhấn vào mini player để mở màn hình Now Playing đầy đủ
4. Sử dụng các nút điều khiển để phát/tạm dừng, chuyển bài, shuffle, repeat

## Permissions

App yêu cầu các quyền sau:

- **File Access**: Để import file nhạc từ Files app
- **Background Audio**: Để phát nhạc khi màn hình tắt
- **Photo Library** (tùy chọn): Để chọn ảnh bìa album

## Troubleshooting

### App không mở được

- Vào Settings > General > VPN & Device Management
- Trust certificate của bạn

### Không import được file

- Kiểm tra file có định dạng MP3/M4A/WAV/AAC
- Đảm bảo file không bị corrupt

### Không phát được nhạc

- Kiểm tra quyền Background Audio
- Restart app

## Credits

- Developed with Flutter
- UI inspired by SoundCloud
- Audio playback: just_audio
- Database: sqflite
- State management: provider

## License

All rights reserved.

## Contact

Nếu có vấn đề hoặc đóng góp, vui lòng tạo issue trên GitHub.
