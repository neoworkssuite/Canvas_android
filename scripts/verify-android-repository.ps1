$required = @('core', 'brushes', 'renderer', 'ui', 'androidApp')
$forbidden = @('iosApp', 'windowsApp')
$missing = $required | Where-Object { -not (Test-Path $_) }
$present = $forbidden | Where-Object { Test-Path $_ }
if ($missing.Count -gt 0) { throw "Missing Android repository modules: $($missing -join ', ')" }
if ($present.Count -gt 0) { throw "Non-Android modules present: $($present -join ', ')" }
if ((Get-Content -Raw settings.gradle.kts) -match 'iosApp|windowsApp') { throw 'settings.gradle.kts includes a non-Android module.' }

$readme = Get-Content -Raw README.md
if ($readme -notmatch 'Android') { throw 'README does not identify the Android product.' }
if ($readme -match 'iPad/iPhone host|windowsApp|iosApp') { throw 'README advertises a non-Android host.' }
$workflowFiles = Get-ChildItem .github/workflows -File -ErrorAction SilentlyContinue
foreach ($workflow in $workflowFiles) {
    $workflowText = Get-Content -Raw $workflow.FullName
    if ($workflowText -match 'xcodebuild|iosApp|windowsApp') { throw "Non-Android CI reference in $($workflow.Name)" }
}
