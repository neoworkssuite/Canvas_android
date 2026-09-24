$required = @('core', 'brushes', 'renderer', 'ui', 'androidApp')
$forbidden = @('iosApp', 'windowsApp')
$missing = $required | Where-Object { -not (Test-Path $_) }
$present = $forbidden | Where-Object { Test-Path $_ }
if ($missing.Count -gt 0) { throw "Missing Android repository modules: $($missing -join ', ')" }
if ($present.Count -gt 0) { throw "Non-Android modules present: $($present -join ', ')" }
if ((Get-Content -Raw settings.gradle.kts) -match 'iosApp|windowsApp') { throw 'settings.gradle.kts includes a non-Android module.' }
