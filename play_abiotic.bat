@echo off
setlocal enabledelayedexpansion

:: ========================================================
:: CONFIGURATION
:: ========================================================
set "REPO_PATH=C:\GameSaves\abiotic-world"
set "GAME_EXE=E:\Abiotic Factor\Abiotic Factor\AbioticFactor.exe"
set "BRANCH=main"

echo ========================================================
echo             ABIOTIC FACTOR SAVE SYNC
echo ========================================================
echo.

cd /d "%REPO_PATH%"
if %errorlevel% neq 0 (
    echo [ERROR] Git repository folder not found at %REPO_PATH%
    echo Make sure you ran 'git clone' into C:\GameSaves\abiotic-world first!
    pause
    exit /b
)

:: Step 1: Pull latest changes
echo [1/3] Downloading latest save from GitHub...
git pull origin %BRANCH%
if %errorlevel% neq 0 (
    echo [ERROR] Git pull failed! Resolve conflicts before playing.
    pause
    exit /b
)
echo [SUCCESS] Save files are up to date!
echo.

:: Step 2: Launch Game
echo [2/3] Starting Abiotic Factor...
echo Script will wait here until you quit the game.
start /wait "" "%GAME_EXE%"

echo.
echo [3/3] Game closed! Checking for world save changes...

:: Step 3: Stage and Commit
git add -A

git status --porcelain | findstr . >nul
if %errorlevel% neq 0 (
    echo [INFO] No save changes detected. Nothing to upload.
    goto END
)

for /f "tokens=2 delims==" %%I in ('wmic os get localdatetime /value') do set "datetime=%%I"
set "TIMESTAMP=%datetime:~0,4%-%datetime:~4,2%-%datetime:~6,2% %datetime:~8,2%:%datetime:~10,2%"

echo Committing updated save file...
git commit -m "World update by Bagus"

:: Step 4: Push to GitHub
echo Uploading latest world save to GitHub...
git push origin %BRANCH%
if %errorlevel% neq 0 (
    echo [ERROR] Failed to push save file to GitHub!
    pause
    exit /b
)

echo [SUCCESS] World save successfully synced to GitHub!

:END
echo.
pause