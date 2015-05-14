:: Move to project-root folder
pushd %~dp0
cd ../..

:: Save current commit hash
for /f %%i in ('git rev-parse HEAD') do set commithash=%%i

:: Get current time
for /f "tokens=2-4 delims=/ " %%a in ('date /t') do (set currentdate=%%c-%%a-%%b)


:: Create builds
CALL "%ue4path%/4.7/Engine/Build/BatchFiles/RunUAT.bat" BuildCookRun -rocket -nocompile -installed -nop4 -project="%~dp0/../../../0_unreal/TBS.uproject" -cook -allmaps -stage -archive -archivedirectory="%~dp0/../../../../builds/automated/%currentdate%_%commithash%" -package -clientconfig=Development -ue4exe="UE4Editor-Cmd.exe" -clean -pak -prereqs -nodebuginfo -targetplatform=Win64 -build -utf8output -NoCompile

:: Copy to temporary folder to prevent "too long filename"-errors
robocopy "%~dp0/../../../../builds/automated/%currentdate%_%commithash%" "C:/tmp/abu" /MIR /log:backup_log.txt

:: Zip them up
"%7zippath%/7z.exe" a -tzip "%~dp0/../../../../builds/automated/recent/recent.zip" "C:/tmp/abu"

rmdir "C:/tmp/abu" /s /q

:: Generate info.txt
@echo off
@echo Build created: %currentdate%> "%~dp0/../../../../builds/automated/recent/info.txt"
@echo SHA-1 Hash of commit: %commithash%>> "%~dp0/../../../../builds/automated/recent/info.txt"

:: Add info.txt to zip-files
"%7zippath%/7z.exe" a -tzip "%~dp0/../../../../builds/automated/recent/recent.zip" "%~dp0/../../../../builds/automated/recent/info.txt"

:: Establish ftp-connection
ftp -s:%~dp0/credentials.dat
 