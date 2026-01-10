# Deployment Guide

## 🌐 Web Deployment (GitHub Pages, Firebase, etc.)

### 1. Build the Web Bundle
Run the following command to generate the release build:
```bash
flutter build web --release --web-renderer html
```
*Note: `--web-renderer html` is recommended for better compatibility with some image assets, though `canvaskit` offers better performance.*

### 2. Locate Output
The build files will be in:
`build/web/`

### 3. Deploy
Upload the contents of `build/web/` to your hosting provider.

#### Base Href
If you are deploying to a subpath (e.g. `github.io/my-game/`), you must modify the `<base href="/">` tag in `index.html`:
```html
<base href="/my-game/">
```

## 📱 Mobile Deployment (Android)

### 1. Build APK
```bash
flutter build apk --release
```

### 2. Locate Output
`build/app/outputs/flutter-apk/app-release.apk`
