@echo off
chcp 65001 >nul
title مزامنة مشروع الذاكرة الخارقة مع GitHub
echo ==========================================================
echo   🚀 جاري تشغيل المزامنة التلقائية مع GitHub...
echo   ✨ أي تعديل تقوم بحفظه في الكود سيتم عمل push له تلقائياً!
echo ==========================================================
echo.
powershell -NoProfile -ExecutionPolicy Bypass -File "%~dp0auto_push.ps1"
pause
