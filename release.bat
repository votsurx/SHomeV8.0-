@echo off
chcp 65001 >nul
title SHome Release Manager
cd /d "%~dp0"
dart run lib/scripts/release.dart
echo.
echo Нажмите любую клавишу для выхода...
pause >nul