@echo off
title FamilyWealthPlanner – Local Preview
color 0B
cls

echo.
echo  FamilyWealthPlanner — Starting local preview...
echo.

where node >nul 2>&1
if %errorlevel% neq 0 (
    color 0C
    echo  !! Node.js is not installed.
    echo     Go to https://nodejs.org and install the LTS version.
    pause & exit /b 1
)

if not exist "node_modules\" (
    echo  Installing packages for the first time (~1 minute)...
    call npm install --silent
)

echo  Opening in your browser at http://localhost:5173
echo  (Keep this window open while using the app)
echo  (Close this window to stop the app)
echo.
call npm run dev
