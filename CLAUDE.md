# Flutter GPS Map App - 프로젝트 정보

## 프로젝트 개요
- **앱 이름**: GPS Map App
- **현재 위치**: `/Users/wykim/flutter/test1`
- **GitHub 저장소**: https://github.com/syrikx/flutter-gps-map-app
- **최신 릴리스**: v1.1.0 (네이버 지도 적용)

## 현재 상태
- ✅ Google Maps → Naver Maps 마이그레이션 완료
- ✅ Android/iOS 설정 업데이트 완료
- ✅ 빌드 성공 (139.2MB APK)
- ✅ GitHub 푸시 완료
- ❌ **현재 이슈**: 네이버 지도 인증 실패

## 해결 필요한 이슈

### 네이버 지도 API 인증 설정
**문제**: 앱 실행 시 네이버 지도 인증 실패
**원인**: 클라이언트 ID가 빈 값으로 설정됨 (`lib/main.dart:7`)

**해결 방법**:
1. 네이버 클라우드 플랫폼에서 Maps API 클라이언트 ID 발급
   - URL: https://www.ncloud.com/
   - 서비스: AI·Application Service > Maps
   - Bundle ID: `com.example.gpsmap.test1`

2. `lib/main.dart` 파일의 clientId 업데이트:
   ```dart
   await NaverMapSdk.instance.initialize(clientId: 'YOUR_ACTUAL_CLIENT_ID');
   ```

## 기술 스펙
- **Flutter SDK**: ^3.8.1
- **지도 라이브러리**: flutter_naver_map: ^1.4.1+1
- **위치 서비스**: geolocator: ^13.0.1
- **권한 관리**: permission_handler: ^11.3.1
- **Android**: compileSdk 36, minSdk 23
- **iOS**: 위치 권한 설정 완료

## 주요 파일 구조
```
lib/
├── main.dart (네이버 SDK 초기화)
├── screens/
│   └── map_screen.dart (네이버 지도 화면)
└── services/
    └── location_service.dart (GPS 위치 서비스)
```

## 빌드 명령어
```bash
flutter pub get
flutter build apk
```

## Git 명령어
```bash
git add .
git commit -m "Fix Naver Maps authentication with client ID"
git push origin main
```

## 릴리스 명령어
```bash
gh release create vX.X.X build/app/outputs/flutter-apk/app-release.apk --title "Title" --notes "Release notes"
```

## 다음 할 일
1. [ ] 네이버 클라우드 플랫폼에서 클라이언트 ID 발급
2. [ ] main.dart에 실제 클라이언트 ID 적용
3. [ ] 앱 테스트 및 재빌드
4. [ ] 새 버전 릴리스 (v1.1.1)

## 대안 옵션
인증 이슈가 지속되면 다음 대안 고려:
- OpenStreetMap (flutter_map 패키지)
- 카카오맵 (kakao_map_plugin)
- 기본 위치 정보만 표시하는 단순 앱

---
*마지막 업데이트: 2025-08-07*