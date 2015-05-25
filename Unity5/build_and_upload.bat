:: Move to root folder
pushd %~dp0
cd ../..

:: Save current commit hash
for /f %%i in ('git rev-parse HEAD') do set commithash=%%i

:: Get current time
for /f "tokens=2-4 delims=/ " %%a in ('date /t') do (set currentdate=%%c-%%a-%%b)


:: Create builds
"E:/Program Files (x86)/Unity5/Editor/Unity.exe" -quit -projectPath "%~dp0/../../../0_unity" -batchmode -nographics -buildWebPlayer "Build/automated/%currentdate%_%commithash%/web"
"E:/Program Files (x86)/Unity5/Editor/Unity.exe" -quit -projectPath "%~dp0/../../../0_unity" -batchmode -nographics -buildWindowsPlayer "Build/automated/%currentdate%_%commithash%/win_x86/wej5.exe"
"E:/Program Files (x86)/Unity5/Editor/Unity.exe" -quit -projectPath "%~dp0/../../../0_unity" -batchmode -nographics -buildWindows64Player "Build/automated/%currentdate%_%commithash%/win_x86_64/wej5.exe"
"E:/Program Files (x86)/Unity5/Editor/Unity.exe" -quit -projectPath "%~dp0/../../../0_unity" -batchmode -nographics -buildOSXUniversalPlayer  "Build/automated/%currentdate%_%commithash%/osx/wej5.exe"

:: Copy to temporary folder to prevent "too long filename"-errors
robocopy "Build/automated/%currentdate%_%commithash%" "C:/tmp/abu" /MIR /log:backup_log.txt

:: Zip them up
"C:/Program Files (x86)/7-Zip/7z.exe" a -tzip "%~dp0/../../../0_unity/Build/automated/recent/win_x86.zip" "C:/tmp/abu/win_x86/"
"C:/Program Files (x86)/7-Zip/7z.exe" a -tzip "%~dp0/../../../0_unity/Build/automated/recent/win_x86_64.zip" "C:/tmp/abu/win_x86_64/"
"C:/Program Files (x86)/7-Zip/7z.exe" a -tzip "%~dp0/../../../0_unity/Build/automated/recent/osx.zip" "C:/tmp/abu/osx/"

:: Special case: Directly upload the web build
robocopy "C:/tmp/abu/web" "%~dp0/../../../0_unity/Build/automated/recent/web" /MIR /log:backup_log.txt


:: Generate info.txt
@echo off
@echo Build created: %currentdate%> "%~dp0/../../../0_unity/Build/automated/recent/info.txt"
@echo SHA-1 Hash of commit: %commithash%>> "%~dp0/../../../0_unity/Build/automated/recent/info.txt"

:: Add info.txt to zip-files
"C:/Program Files (x86)/7-Zip/7z.exe" a -tzip "%~dp0/../../../0_unity/Build/automated/recent/win_x86.zip" "%~dp0/../../../0_unity/Build/automated/recent/info.txt"
"C:/Program Files (x86)/7-Zip/7z.exe" a -tzip "%~dp0/../../../0_unity/Build/automated/recent/win_x86_64.zip" "%~dp0/../../../0_unity/Build/automated/recent/info.txt"
"C:/Program Files (x86)/7-Zip/7z.exe" a -tzip "%~dp0/../../../0_unity/Build/automated/recent/osx.zip" "%~dp0/../../../0_unity/Build/automated/recent/info.txt"

:: Establish ftp-connection
ftp -s:%~dp0/credentials.dat
 
:: Move back to start folder
cd %~dp0