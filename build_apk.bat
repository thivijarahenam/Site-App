@echo off
echo ==============================================
echo Building Release APK for Site Management App...
echo ==============================================
cd /d "%~dp0android"
call .\gradlew.bat assembleRelease -x extractReleaseAnnotations
if %ERRORLEVEL% equ 0 (
    echo.
    echo ==============================================
    echo BUILD SUCCESSFUL!
    echo APK Location:
    echo %~dp0build\app\outputs\flutter-apk\app-release.apk
    echo %~dp0build\app\outputs\apk\release\app-release.apk
    echo ==============================================
    if not exist "%~dp0build\app\outputs\flutter-apk" mkdir "%~dp0build\app\outputs\flutter-apk"
    copy /y "%~dp0build\app\outputs\apk\release\app-release.apk" "%~dp0build\app\outputs\flutter-apk\app-release.apk" >nul 2>&1
) else (
    echo BUILD FAILED!
)
pause
