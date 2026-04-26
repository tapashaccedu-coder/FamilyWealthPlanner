@echo off
setlocal EnableDelayedExpansion
title FamilyWealthPlanner – Deploy to GitHub + Vercel
color 0B
cls

echo.
echo  ============================================================
echo    FamilyWealthPlanner — One-Click Deploy Wizard
echo    Publishes your app FREE to the internet via Vercel
echo  ============================================================
echo.
echo  What this wizard does:
echo    1. Checks your tools are installed
echo    2. Builds the app
echo    3. Uploads code to GitHub
echo    4. Deploys live to Vercel
echo.
echo  You need:  github.com account  +  vercel.com account
echo  (Both are free. Sign in to Vercel with your GitHub account.)
echo.
echo  Press any key to start...
pause >nul

:: ============================================================
:: STEP 1 — Check tools
:: ============================================================
cls
echo.
echo  [STEP 1 of 5]  Checking required tools...
echo.

:: Check Node.js
where node >nul 2>&1
if %errorlevel% neq 0 (
    color 0C
    echo  !! Node.js is NOT installed.
    echo.
    echo  Please install it:
    echo    1. Your browser will open  https://nodejs.org
    echo    2. Click the big green "LTS" button to download
    echo    3. Run the installer – click Next through everything
    echo    4. When done, CLOSE this window and open it again
    echo.
    echo  Press any key to open nodejs.org now...
    pause >nul
    start https://nodejs.org
    exit /b 1
)
for /f "tokens=*" %%v in ('node --version 2^>nul') do set NODE_VER=%%v
echo  [OK] Node.js %NODE_VER%

:: Check Git
where git >nul 2>&1
if %errorlevel% neq 0 (
    color 0C
    echo.
    echo  !! Git is NOT installed.
    echo.
    echo  Please install it:
    echo    1. Your browser will open  https://git-scm.com
    echo    2. Click "Download for Windows"
    echo    3. Run the installer – click Next through everything
    echo       (Use all the default options)
    echo    4. When done, CLOSE this window and open it again
    echo.
    echo  Press any key to open git-scm.com now...
    pause >nul
    start https://git-scm.com/download/win
    exit /b 1
)
for /f "tokens=*" %%v in ('git --version 2^>nul') do set GIT_VER=%%v
echo  [OK] %GIT_VER%

:: Check / install Vercel CLI
where vercel >nul 2>&1
if %errorlevel% neq 0 (
    echo.
    echo  [..] Installing Vercel command-line tool (one-time, takes ~30s)...
    call npm install -g vercel --silent
    if %errorlevel% neq 0 (
        color 0C
        echo  !! Could not install Vercel CLI.
        echo     Make sure you are connected to the internet and try again.
        pause
        exit /b 1
    )
    echo  [OK] Vercel CLI installed
) else (
    for /f "tokens=*" %%v in ('vercel --version 2^>nul') do set VCLI_VER=%%v
    echo  [OK] Vercel CLI %VCLI_VER%
)

echo.
echo  All tools ready!  Press any key to continue...
pause >nul

:: ============================================================
:: STEP 2 — Build the app
:: ============================================================
cls
echo.
echo  [STEP 2 of 5]  Building the app...
echo.

if not exist "package.json" (
    color 0C
    echo  !! This window must be opened FROM INSIDE the FamilyWealthPlanner folder.
    echo.
    echo  How to fix:
    echo    1. Open the FamilyWealthPlanner folder in File Explorer
    echo    2. Right-click DEPLOY.bat
    echo    3. Click "Run as administrator"  (or just double-click it)
    echo.
    pause
    exit /b 1
)

if not exist "node_modules\" (
    echo  [..] Installing packages (first time only, ~1 minute)...
    call npm install --silent
    if %errorlevel% neq 0 (
        color 0C
        echo  !! npm install failed. Check your internet connection.
        pause & exit /b 1
    )
)

echo  [..] Creating production build...
call npm run build
if %errorlevel% neq 0 (
    color 0C
    echo  !! Build failed.
    echo     Make sure the app works locally first (double-click START.bat).
    pause & exit /b 1
)
echo  [OK] Build complete

echo.
pause >nul

:: ============================================================
:: STEP 3 — Git setup
:: ============================================================
cls
echo.
echo  [STEP 3 of 5]  Setting up Git version control...
echo.

:: Configure git user if not set
for /f "tokens=*" %%e in ('git config --global user.email 2^>nul') do set GIT_EMAIL=%%e
if "!GIT_EMAIL!"=="" (
    echo  Git needs your name and email for version history.
    echo  These just need to match your GitHub account.
    echo.
    set /p GIT_NAME=  Your full name (e.g. Jane Smith): 
    set /p GIT_EMAIL=  Your email (e.g. jane@gmail.com): 
    git config --global user.name "!GIT_NAME!"
    git config --global user.email "!GIT_EMAIL!"
    echo.
    echo  [OK] Git identity saved
) else (
    echo  [OK] Git already configured as: !GIT_EMAIL!
)

:: Init repo
if not exist ".git\" (
    git init -b main >nul 2>&1
    if %errorlevel% neq 0 git init >nul 2>&1
    echo  [OK] Git repository created
) else (
    echo  [OK] Git repository already exists
)

:: Create .gitignore
if not exist ".gitignore" (
    (
        echo node_modules/
        echo dist/
        echo .env
        echo .vercel
        echo *.bat.bak
    ) > .gitignore
    echo  [OK] .gitignore created
)

:: Commit everything
git add . >nul 2>&1
git commit -m "FamilyWealthPlanner deploy" >nul 2>&1
echo  [OK] Files committed

echo.
pause >nul

:: ============================================================
:: STEP 4 — GitHub
:: ============================================================
cls
echo.
echo  [STEP 4 of 5]  Connecting to GitHub...
echo.
echo  ----------------------------------------------------------------
echo   You need a NEW empty repository on GitHub.
echo  ----------------------------------------------------------------
echo.
echo   1. Press any key — github.com will open in your browser
echo   2. Click the  [+]  icon (top right of GitHub)
echo   3. Click  "New repository"
echo   4. Name it:   FamilyWealthPlanner
echo   5. Set it to  PUBLIC
echo   6. Do NOT tick any checkboxes (no README, no .gitignore)
echo   7. Click  "Create repository"
echo   8. On the next page, copy the URL at the top.
echo      It looks like:
echo.
echo        https://github.com/YourName/FamilyWealthPlanner.git
echo.
echo  ----------------------------------------------------------------
echo.
echo  Press any key to open GitHub now...
pause >nul
start https://github.com/new

echo.
echo  Paste your GitHub repository URL below and press Enter.
echo  (It must end in .git)
echo.
set /p REPO_URL=  Repository URL: 

if "!REPO_URL!"=="" (
    color 0C
    echo  !! No URL entered. Run the wizard again.
    pause & exit /b 1
)

:: Set remote
git remote remove origin >nul 2>&1
git remote add origin !REPO_URL!

echo.
echo  [..] Uploading your code to GitHub...
echo       (A browser login window may appear — sign in to GitHub)
echo.

git branch -M main >nul 2>&1
git push -u origin main
if %errorlevel% neq 0 (
    color 0C
    echo.
    echo  !! Upload to GitHub failed.
    echo.
    echo  Most common fix:
    echo    Your browser should have asked you to log in to GitHub.
    echo    If you missed it, run this wizard again — it will retry.
    echo.
    echo  If it keeps failing:
    echo    Go to  github.com  ^> Settings ^> Developer settings
    echo    ^> Personal access tokens ^> Tokens (classic)
    echo    ^> Generate new token  ^> tick "repo"  ^> Generate
    echo    Copy the token and use it as your password when asked.
    echo.
    pause & exit /b 1
)
echo.
echo  [OK] Code is now on GitHub!

pause >nul

:: ============================================================
:: STEP 5 — Vercel deploy
:: ============================================================
cls
echo.
echo  [STEP 5 of 5]  Deploying to Vercel...
echo.
echo  ----------------------------------------------------------------
echo   A browser window will open asking you to log in to Vercel.
echo   Sign in with your GitHub account.
echo  ----------------------------------------------------------------
echo.
echo  When Vercel asks questions in this window, answer:
echo.
echo    "Set up and deploy?" .......................  Y  then Enter
echo    "Which scope?" ...........................  pick your account
echo    "Link to existing project?" ..............  N  then Enter
echo    "What is your project name?" .............  familywealthplanner
echo    "In which directory is your code?" .......  just press Enter  (./)
echo    "Want to override settings?" .............  N  then Enter
echo.
echo  It takes about 30-60 seconds, then shows a URL like:
echo    https://familywealthplanner-abc123.vercel.app
echo.
echo  Press any key when ready...
pause >nul

call vercel --prod

if %errorlevel% neq 0 (
    echo.
    echo  !! Vercel deployment had an issue.
    echo.
    echo  Easy manual alternative:
    echo    1. Go to  vercel.com  and sign in with GitHub
    echo    2. Click  "Add New Project"
    echo    3. Click  "Import"  next to FamilyWealthPlanner
    echo    4. Click  "Deploy"  (leave all settings as-is)
    echo.
    start https://vercel.com/new
    pause & exit /b 0
)

:: ============================================================
:: SUCCESS
:: ============================================================
cls
color 0A
echo.
echo  ============================================================
echo.
echo    Your app is LIVE on the internet!
echo.
echo    The URL was shown above (ends in .vercel.app)
echo    Bookmark it — it works from any phone, tablet, or computer.
echo.
echo  ============================================================
echo.
echo  ---- Saving your financial data ----
echo.
echo  Your plan is saved in THIS browser only.
echo  To use it on another device:
echo.
echo    On this computer:
echo      Dashboard ^> NavBar ^> "Save / Load" ^> "Download settings file"
echo.
echo    On the other device:
echo      Open your Vercel URL ^> "Save / Load" ^> "Load settings file"
echo.
echo  ---- Updating the app later ----
echo.
echo  When you get a new version (new .zip from Claude):
echo    1. Unzip into this same folder, replacing files
echo    2. Double-click DEPLOY.bat again
echo    3. It pushes the update — your URL stays the same
echo.
echo  ============================================================
echo.
echo  Press any key to finish.
pause >nul
