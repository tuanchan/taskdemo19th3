# Hướng dẫn Build IPA

## Phương pháp 1: GitHub Actions (Khuyến nghị - Tự động)

1. **Push code lên GitHub**
   ```bash
   git init
   git add .
   git commit -m "Initial commit"
   git remote add origin <your-github-repo-url>
   git push -u origin main
   ```

2. **Build tự động**
   - Vào repository trên GitHub
   - Click tab "Actions"
   - Chọn "Build iOS IPA"
   - Click "Run workflow" > "Run workflow"
   - Đợi 5-10 phút

3. **Download IPA**
   - Sau khi build xong (màu xanh ✓)
   - Click vào workflow run
   - Scroll xuống "Artifacts"
   - Download "AppMusicVol2-IPA"

4. **Ký bằng ESign**
   - Mở ESign trên iPhone/iPad
   - Import file IPA
   - Chọn certificate
   - Sign và install

## Phương pháp 2: Build thủ công (Cần macOS)

### Yêu cầu
- macOS
- Xcode 14+
- Flutter 3.16+

### Các bước

1. **Cài đặt dependencies**
   ```bash
   cd AppMusicVol2
   flutter pub get
   cd ios
   pod install
   cd ..
   ```

2. **Build**
   ```bash
   flutter build ios --release --no-codesign
   ```

3. **Tạo IPA**
   ```bash
   cd build/ios/iphoneos
   mkdir Payload
   cp -r Runner.app Payload/
   zip -r ../../../AppMusicVol2.ipa Payload
   cd ../../..
   ```

4. **File IPA** sẽ ở: `AppMusicVol2.ipa`

## Ký bằng ESign

1. Cài ESign từ App Store hoặc sideload
2. Mở ESign
3. Chọn "Import" > chọn file IPA
4. Chọn certificate của bạn
5. Nhấn "Sign"
6. Sau khi ký xong, nhấn "Install"
7. Vào Settings > General > VPN & Device Management
8. Trust certificate

## Lưu ý quan trọng

- **Bundle ID**: com.appmusicvol2.app
- **Min iOS**: 14.0
- **Quyền cần thiết**: 
  - File Access
  - Background Audio
  - Photo Library (optional)

- **Certificate expires**: Ký lại sau 7 ngày với free account
- **File size**: ~50-70MB

## Troubleshooting

**Build failed trên GitHub Actions**
- Kiểm tra file pubspec.yaml có đúng format
- Kiểm tra dependencies có tương thích

**ESign không ký được**
- Kiểm tra certificate còn hạn
- Thử certificate khác
- Revoke và tạo certificate mới

**App crash khi mở**
- Xóa app
- Restart iPhone
- Cài lại
- Trust certificate

## Support

Nếu gặp vấn đề, tạo issue trên GitHub.
