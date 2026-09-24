# NeoCanvas Android Repository Bootstrap Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** Populate `neoworkssuite/Canvas_android` with a standalone Android-tablet NeoCanvas baseline equivalent to `Canvas-Mac` commit `42118c2`, without iOS or Windows hosts.

**Architecture:** Retain the shared Kotlin/Compose modules (`core`, `brushes`, `renderer`, `ui`) plus the Android host and its Android-specific persistence/input adapters. The repository is an Android product boundary; it builds Android independently while future upstream shared changes are brought in deliberately.

**Tech Stack:** Kotlin 2.4.20, Compose Multiplatform 1.10.0, Android Gradle Plugin 8.13.0, Android API 36, JDK 17, Git, GitHub Actions.

**Spec:** `docs/superpowers/specs/2026-09-24-neocanvas-android-tablet-migration-design.md`

## Global Constraints

- Source baseline: `C:\Users\Windows11\Documents\ChatGPT\neocanvas - mac\Canvas-Mac` at commit `42118c2` on `ipad-gestures-phase1`.
- Preserve the offline-first product model: no account, network service, telemetry, or cloud-storage dependency.
- Retain `core`, `brushes`, `renderer`, `ui`, and `androidApp`; do not copy `iosApp` or `windowsApp`.
- Use Android API 36 and JDK 17.
- Do not push, force-push, or alter the source `Canvas-Mac` repository.
- The target GitHub repository is `https://github.com/neoworkssuite/Canvas_android.git` on branch `main`.

## Review Focus

- A clean checkout must not retain any iOS/Windows module path or Gradle include that prevents Android configuration.
- The Android manifest, application ID, launcher resources, and `MainActivity` must remain present after extraction.
- Shared UI gesture functions must remain included so two/three/four-finger and QuickMenu behaviors compile with Android input.
- The Android debug unit suite must run without relying on files outside `Canvas_android`.
- Local-only storage and recovery paths must still function after Android extraction; no automatic cloud/service dependency is introduced.

---

## Scope split

The specification has three independently shippable concerns: repository bootstrap, Android input/gesture hardening, and Android file/share completion. This plan implements only the **repository bootstrap**. After it lands and the app builds from a clean checkout, create separate plans for input/gesture hardening and Storage Access Framework/export sharing. This prevents an unreviewable migration commit from also changing gesture or data-safety behavior.

## File structure

| Path | Responsibility |
| --- | --- |
| `settings.gradle.kts` | Android-only module inclusion and dependency repositories |
| `build.gradle.kts`, `gradle.properties`, `gradle/`, `gradlew*` | Reproducible Android Gradle build entrypoint |
| `core/` | Platform-neutral document model, commands, history and persistence contracts |
| `brushes/` | Brush definitions, sampling and bundled brush packs |
| `renderer/` | Tile raster engine, compositing, effects and output encoders |
| `ui/` | Shared Compose editor, tablet gesture behavior and UI tests |
| `androidApp/` | Android activity, Android pointer/file adapters, resources and tests |
| `.github/workflows/` | Android-only CI checks |
| `README.md`, `docs/` | Android product setup, current limitations and release guidance |
| `scripts/` | Android-relevant verification utilities only |

### Task 1: Import the Android parity baseline

**Files:**

- Create: `.gitattributes`, `.gitignore`, `build.gradle.kts`, `gradle.properties`, `gradle/`, `gradlew`, `gradlew.bat`, `README.md`
- Create: `core/`, `brushes/`, `renderer/`, `ui/`, `androidApp/`, `assets/`, `.github/`, Android-relevant `docs/` and `scripts/`
- Modify: `settings.gradle.kts`
- Test: `androidApp/src/test/kotlin/com/neoworksuite/neocanvas/platform/LocalLibraryTest.kt`

**Interfaces:**

- Consumes: source tree at commit `42118c2` and the target's approved design/spec files.
- Produces: an Android-only Gradle project with module graph `androidApp -> ui -> core, brushes, renderer`.

- [ ] **Step 1: Create a source manifest and write the failing boundary test**

Create `scripts/verify-android-repository.ps1` containing:

```powershell
$required = @('core', 'brushes', 'renderer', 'ui', 'androidApp')
$forbidden = @('iosApp', 'windowsApp')
$missing = $required | Where-Object { -not (Test-Path $_) }
$present = $forbidden | Where-Object { Test-Path $_ }
if ($missing.Count -gt 0) { throw "Missing Android repository modules: $($missing -join ', ')" }
if ($present.Count -gt 0) { throw "Non-Android modules present: $($present -join ', ')" }
if ((Get-Content -Raw settings.gradle.kts) -match 'iosApp|windowsApp') { throw 'settings.gradle.kts includes a non-Android module.' }
```

- [ ] **Step 2: Run the boundary test to verify it fails**

Run: `powershell -ExecutionPolicy Bypass -File scripts/verify-android-repository.ps1`

Expected: FAIL because the required Android modules do not exist yet.

- [ ] **Step 3: Copy only the approved source paths**

Use Git-aware copy operations from the exact source commit to bring over `.gitattributes`, `.gitignore`, Gradle files, `core`, `brushes`, `renderer`, `ui`, `androidApp`, `assets`, `.github`, Android-relevant documentation and Android-relevant scripts. Do not copy `iosApp`, `windowsApp`, Apple-only documentation, Apple-only tests, or desktop-only scripts.

Replace `settings.gradle.kts` with:

```kotlin
pluginManagement {
    repositories {
        google()
        mavenCentral()
        gradlePluginPortal()
    }
}

dependencyResolutionManagement {
    repositoriesMode.set(RepositoriesMode.FAIL_ON_PROJECT_REPOS)
    repositories {
        google()
        mavenCentral()
    }
}

rootProject.name = "NeoCanvas Android"
include(":core", ":brushes", ":renderer", ":ui", ":androidApp")
```

- [ ] **Step 4: Run boundary and Gradle configuration checks**

Run: `powershell -ExecutionPolicy Bypass -File scripts/verify-android-repository.ps1`

Expected: PASS.

Run: `./gradlew.bat projects`

Expected: PASS and list only `:androidApp`, `:brushes`, `:core`, `:renderer`, and `:ui`.

- [ ] **Step 5: Commit the independently buildable source baseline**

```bash
git add .gitattributes .gitignore .github assets androidApp brushes core docs gradle gradlew gradlew.bat renderer scripts settings.gradle.kts ui build.gradle.kts gradle.properties README.md
git commit -m "Import Android tablet parity baseline"
```

### Task 2: Make Android project metadata and CI truthful

**Files:**

- Modify: `README.md`
- Modify: `.github/workflows/*`
- Modify: `scripts/verify-android-repository.ps1`
- Test: `scripts/verify-android-repository.ps1`

**Interfaces:**

- Consumes: Android-only module graph created by Task 1.
- Produces: documentation and automated checks that describe and validate only Android support.

- [ ] **Step 1: Write failing metadata assertions**

Append to `scripts/verify-android-repository.ps1`:

```powershell
$readme = Get-Content -Raw README.md
if ($readme -notmatch 'Android') { throw 'README does not identify the Android product.' }
if ($readme -match 'iPad/iPhone host|windowsApp|iosApp') { throw 'README advertises a non-Android host.' }
$workflowFiles = Get-ChildItem .github/workflows -File -ErrorAction SilentlyContinue
foreach ($workflow in $workflowFiles) {
    $workflowText = Get-Content -Raw $workflow.FullName
    if ($workflowText -match 'xcodebuild|iosApp|windowsApp') { throw "Non-Android CI reference in $($workflow.Name)" }
}
```

- [ ] **Step 2: Run the metadata assertions to verify they fail**

Run: `powershell -ExecutionPolicy Bypass -File scripts/verify-android-repository.ps1`

Expected: FAIL until README and CI references are reduced to Android-only scope.

- [ ] **Step 3: Make Android intent explicit**

Update the README title and introduction to identify NeoCanvas as an offline-first Android-tablet drawing studio. Retain the Android build command:

```powershell
./gradlew.bat :androidApp:testDebugUnitTest
```

Remove Apple and Windows prerequisites, targets, commands, release gates and host descriptions. In workflows, retain only checks that can run on a standard Android/JDK runner; remove Apple simulator/device and Windows desktop run jobs. Keep the shared-test and Android debug build/test jobs.

- [ ] **Step 4: Run metadata and Android tests**

Run: `powershell -ExecutionPolicy Bypass -File scripts/verify-android-repository.ps1`

Expected: PASS.

Run: `./gradlew.bat :androidApp:testDebugUnitTest`

Expected: PASS.

- [ ] **Step 5: Commit the Android-only metadata**

```bash
git add README.md .github scripts/verify-android-repository.ps1
git commit -m "Document Android-only repository boundary"
```

### Task 3: Verify clean Android baseline and publish it

**Files:**

- Modify: `.git/config` (local Git remote only; never commit)
- Test: all Android debug unit tests and Gradle project inventory

**Interfaces:**

- Consumes: Android-only project and validation script from Tasks 1-2.
- Produces: `main` published to `neoworkssuite/Canvas_android` with a verified initial Android baseline.

- [ ] **Step 1: Verify the complete repository boundary**

Run:

```powershell
powershell -ExecutionPolicy Bypass -File scripts/verify-android-repository.ps1
./gradlew.bat projects
```

Expected: both PASS; Gradle reports only the five approved modules.

- [ ] **Step 2: Run the Android unit suite and debug assembly**

Run:

```powershell
./gradlew.bat :androidApp:testDebugUnitTest :androidApp:assembleDebug
```

Expected: PASS, producing `androidApp/build/outputs/apk/debug/androidApp-debug.apk`.

- [ ] **Step 3: Inspect the staged publication state**

Run:

```bash
git status --short --branch
git log --oneline --decorate -3
git remote -v
```

Expected: clean `main`, the migration commits are visible, and the only configured remote is `origin https://github.com/neoworkssuite/Canvas_android.git`.

- [ ] **Step 4: Publish `main` with an ordinary push**

Run:

```bash
git push -u origin main
```

Expected: PASS; GitHub `main` shows the design commit and Android baseline commits. Do not force-push.

- [ ] **Step 5: Confirm the remote result**

Run:

```bash
gh api repos/neoworkssuite/Canvas_android/commits/main --jq '.sha[0:7] + " " + .commit.message'
```

Expected: output names the final Android-only metadata commit.

## Follow-on plans required before release

1. Android stylus, palm-rejection and multi-finger gesture acceptance plan.
2. Android Storage Access Framework, sharing, complete export/import and brush-pack plan.
3. Android tablet windowing, performance, accessibility and physical-device release-validation plan.
