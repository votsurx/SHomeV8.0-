@'
# Скрипт мониторинга сборки Flutter с отслеживанием Gradle
param(
    [switch]$Clean,
    [switch]$Verbose
)

$ErrorActionPreference = "Continue"
$startTime = Get-Date

# Цвета
$c = @{
    Cyan = "Cyan"
    Green = "Green"
    Yellow = "Yellow"
    Red = "Red"
    White = "White"
    Gray = "Gray"
    Magenta = "Magenta"
}

# Эмодзи для этапов
$emoji = @{
    gradle = "🐘"
    download = "📥"
    compile = "🔨"
    build = "🏗️"
    install = "📱"
    launch = "🚀"
    error = "❌"
    ok = "✅"
    wait = "⏳"
}

Write-Host ""
Write-Host "╔══════════════════════════════════════════════════════╗" -ForegroundColor $c.Cyan
Write-Host "║        Sonoff Controller - Build Monitor            ║" -ForegroundColor $c.Cyan
Write-Host "╚══════════════════════════════════════════════════════╝" -ForegroundColor $c.Cyan
Write-Host ""

# Функция для отображения прогресса
function Show-Progress {
    param(
        [string]$Stage,
        [string]$Message,
        [string]$Color = "White",
        [string]$Icon = ""
    )
    
    $elapsed = [math]::Round(((Get-Date) - $startTime).TotalSeconds, 1)
    $timeStr = "[{0:D2}:{1:D2}]" -f ([math]::Floor($elapsed / 60)), ($elapsed % 60)
    
    Write-Host "$timeStr $Icon $Message" -ForegroundColor $Color
}

# Анимация спиннера
$spinner = @("⠋", "⠙", "⠹", "⠸", "⠼", "⠴", "⠦", "⠧", "⠇", "⠏")
$spinnerIndex = 0

# Очистка если нужно
if ($Clean) {
    Show-Progress -Stage "clean" -Message "Cleaning project..." -Icon "🧹"
    flutter clean 2>&1 | Out-Null
}

# Этап 1: pub get
Show-Progress -Stage "deps" -Message "Resolving dependencies..." -Icon "📦"
$pubTimer = [System.Diagnostics.Stopwatch]::StartNew()
flutter pub get 2>&1 | ForEach-Object {
    if ($_ -match "Downloading") {
        Show-Progress -Stage "deps" -Message "  $_" -Color $c.Gray
    }
}
$pubTimer.Stop()
Show-Progress -Stage "deps" -Message "Dependencies resolved in $([math]::Round($pubTimer.Elapsed.TotalSeconds, 1))s" -Icon $emoji.ok -Color $c.Green

# Этап 2: Запуск сборки
Show-Progress -Stage "build" -Message "Starting Flutter build..." -Icon $emoji.build -Color $c.Yellow
Show-Progress -Stage "build" -Message "This may take 3-10 minutes on first build" -Icon $emoji.wait -Color $c.Gray
Write-Host ""

# Запускаем Flutter и мониторим вывод
$job = Start-Job -ScriptBlock {
    Set-Location $using:PWD
    flutter run 2>&1
}

# Мониторим прогресс
$gradleStarted = $false
$gradleProgress = 0
$currentTask = ""

while ($job.State -eq "Running") {
    $spinnerIndex = ($spinnerIndex + 1) % $spinner.Length
    $spin = $spinner[$spinnerIndex]
    $elapsed = [math]::Round(((Get-Date) - $startTime).TotalSeconds, 1)
    $timeStr = "[{0:D2}:{1:D2}]" -f ([math]::Floor($elapsed / 60)), ($elapsed % 60)
    
    # Проверяем файлы Gradle для отслеживания прогресса
    $gradleDir = "$env:USERPROFILE\.gradle\wrapper\dists"
    if (Test-Path $gradleDir) {
        $gradleSize = (Get-ChildItem $gradleDir -Recurse -ErrorAction SilentlyContinue | Measure-Object -Property Length -Sum).Sum
        if ($gradleSize -gt 0 -and -not $gradleStarted) {
            $gradleSizeMB = [math]::Round($gradleSize / 1MB, 1)
            Write-Host "`r$timeStr $spin ${emoji.download} Gradle downloading: $gradleSizeMB MB" -NoNewline
        }
    }
    
    # Проверяем кэш сборки
    $buildDir = "android\app\build"
    if (Test-Path $buildDir) {
        $buildSize = (Get-ChildItem $buildDir -Recurse -ErrorAction SilentlyContinue | Measure-Object -Property Length -Sum).Sum
        if ($buildSize -gt 0) {
            $buildSizeMB = [math]::Round($buildSize / 1MB, 1)
            Write-Host "`r$timeStr $spin ${emoji.compile} Building: $buildSizeMB MB" -NoNewline
        }
    }
    
    Start-Sleep -Milliseconds 200
}

# Получаем результат
Write-Host ""
Write-Host ""
$result = Receive-Job $job -ErrorAction SilentlyContinue

# Анализируем результат
$hasError = $false
$result | ForEach-Object {
    $line = $_.ToString()
    
    if ($line -match "BUILD FAILED") {
        $hasError = $true
        Write-Host "`n${emoji.error} BUILD FAILED" -ForegroundColor $c.Red
    }
    elseif ($line -match "BUILD SUCCESSFUL") {
        Write-Host "${emoji.ok} BUILD SUCCESSFUL" -ForegroundColor $c.Green
    }
    elseif ($line -match "Installing") {
        Show-Progress -Stage "install" -Message "Installing on device..." -Icon $emoji.install -Color $c.Cyan
    }
    elseif ($line -match "Launching") {
        Show-Progress -Stage "launch" -Message "Launching app..." -Icon $emoji.launch -Color $c.Green
    }
    elseif ($line -match "error" -and $line -notmatch "warning") {
        if ($Verbose) {
            Write-Host "  $line" -ForegroundColor $c.Red
        }
    }
    elseif ($line -match "Running Gradle task") {
        Show-Progress -Stage "gradle" -Message "Gradle: $($line -replace '.*Running Gradle task ', '')" -Icon $emoji.gradle -Color $c.Magenta
    }
    elseif ($line -match "Downloading") {
        if ($Verbose) {
            Write-Host "  ${emoji.download} $line" -ForegroundColor $c.Gray
        }
    }
}

# Итоги
$totalTime = [math]::Round(((Get-Date) - $startTime).TotalMinutes, 1)
Write-Host ""
Write-Host "══════════════════════════════════════════════════════" -ForegroundColor $c.Cyan

if ($hasError) {
    Write-Host "  ${emoji.error} Build completed with ERRORS in ${totalTime} min" -ForegroundColor $c.Red
    Write-Host ""
    Write-Host "  Quick fixes:" -ForegroundColor $c.Yellow
    Write-Host "  1. flutter clean" -ForegroundColor $c.White
    Write-Host "  2. Remove android\.gradle folder" -ForegroundColor $c.White
    Write-Host "  3. flutter pub get" -ForegroundColor $c.White
    Write-Host "  4. Try again" -ForegroundColor $c.White
} else {
    Write-Host "  ${emoji.ok} Build SUCCESS in ${totalTime} min!" -ForegroundColor $c.Green
}

Write-Host "══════════════════════════════════════════════════════" -ForegroundColor $c.Cyan
Write-Host ""

# Сохраняем лог
$logFile = "build_log_$(Get-Date -Format 'yyyyMMdd_HHmmss').txt"
$result | Out-File $logFile -Encoding UTF8
Write-Host "Full log saved to: $logFile" -ForegroundColor $c.Gray
'@ | Out-File -FilePath "build_monitor.ps1" -Encoding UTF8

Write-Host "Monitor script created!" -ForegroundColor Green
Write-Host ""
Write-Host "Usage:" -ForegroundColor Yellow
Write-Host "  .\build_monitor.ps1              - Normal build with progress" -ForegroundColor White
Write-Host "  .\build_monitor.ps1 -Clean       - Clean before build" -ForegroundColor White
Write-Host "  .\build_monitor.ps1 -Verbose     - Show all details" -ForegroundColor White
Write-Host "  .\build_monitor.ps1 -Clean -Verbose  - Clean + verbose" -ForegroundColor White