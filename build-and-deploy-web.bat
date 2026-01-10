@echo off
echo ========================================
echo Crypto Mining Empire - Web Build
echo ========================================
echo.

echo Building web version...
flutter build web --release --web-renderer canvaskit

if %errorlevel% neq 0 (
    echo ERROR: Build failed!
    pause
    exit /b 1
)

echo.
echo ===================================
echo BUILD SUCCESSFUL!
echo ===================================
echo.
echo Output location: build\web\
echo.
echo To test locally:
echo   cd build\web
echo   python -m http.server 8000
echo   Then visit: http://localhost:8000
echo.
echo To deploy:
echo   - Netlify: Drag build\web folder to netlify.com
echo   - Vercel: Run 'vercel --prod' in build\web folder
echo   - GitHub Pages: Push build\web to gh-pages branch
echo.
pause
