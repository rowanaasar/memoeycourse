# Auto Git Push Script for Memory Course Platform
# يقوم هذا السكربت بمراقبة أي تعديل في الملفات ورفعه فوراً إلى GitHub

$Path = $PSScriptRoot
if (-not $Path) { $Path = Get-Location }

Write-Host "==========================================================" -ForegroundColor Cyan
Write-Host "  🚀 جاري تفعيل المراقبة والمزامنة التلقائية مع GitHub..." -ForegroundColor Yellow
Write-Host "  📁 مسار المشروع: $Path" -ForegroundColor Gray
Write-Host "  ✨ أي حفظ أو تعديل على الملفات سيتم عمل push له فوراً!" -ForegroundColor Green
Write-Host "==========================================================" -ForegroundColor Cyan

# إنشاء مراقب الملفات
$Watcher = New-Object System.IO.FileSystemWatcher
$Watcher.Path = $Path
$Watcher.IncludeSubdirectories = $true
$Watcher.EnableRaisingEvents = $true
$Watcher.Filter = "*.*"

$LastPushTime = [DateTime]::MinValue
$DebounceSeconds = 3 # الانتظار 3 ثوانٍ لتجميع التعديلات

$Action = {
    param($source, $event)
    
    $FilePath = $event.FullPath
    
    # تجاهل التعديلات داخل مجلد .git
    if ($FilePath -like "*\.git\*") { return }

    $Now = [DateTime]::Now
    if (($Now - $script:LastPushTime).TotalSeconds -lt $script:DebounceSeconds) {
        return
    }
    $script:LastPushTime = $Now

    Start-Sleep -Seconds 1

    Write-Host "`n[$(Get-Date -Format 'HH:mm:ss')] 📝 تم رصد تعديل في: $($event.Name)" -ForegroundColor Yellow
    Write-Host "⏳ جاري الرفع التلقائي على GitHub..." -ForegroundColor Cyan

    try {
        git add .
        $status = git status --porcelain
        if ($status) {
            $CommitMsg = "تحديث تلقائي: $(Get-Date -Format 'yyyy-MM-dd HH:mm:ss')"
            git commit -m $CommitMsg
            $pushResult = git push origin main 2>&1
            Write-Host "✅ تم الرفع بنجاح على GitHub! (origin main)" -ForegroundColor Green
        } else {
            Write-Host "ℹ لا توجد تغييرات جديدة للرفع." -ForegroundColor Gray
        }
    } catch {
        Write-Host "❌ حدث خطأ أثناء الرفع: $_" -ForegroundColor Red
    }
}

# ربط الأحداث (تعديل، إنشاء، حذف، إعادة تسمية)
Register-ObjectEvent $Watcher "Changed" -Action $Action | Out-Null
Register-ObjectEvent $Watcher "Created" -Action $Action | Out-Null
Register-ObjectEvent $Watcher "Deleted" -Action $Action | Out-Null
Register-ObjectEvent $Watcher "Renamed" -Action $Action | Out-Null

Write-Host "`n🟢 المراقب يعمل الآن في الخلفية... (اضغط Ctrl+C للإيقاف في أي وقت)" -ForegroundColor Green

# البقاء في وضع الاستماع
try {
    while ($true) {
        Start-Sleep -Seconds 1
    }
} finally {
    Unregister-Event -SourceIdentifier * -ErrorAction SilentlyContinue
    $Watcher.Dispose()
    Write-Host "`n🛑 تم إيقاف المراقبة التلقائية." -ForegroundColor Yellow
}
