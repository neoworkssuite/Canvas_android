# NeoCanvas Android Tablet Migration Design

## Purpose

Create `neoworkssuite/Canvas_android` as NeoCanvas's Android-tablet product repository. It will start with the same creative-editor capability and gesture contract as the iPad implementation, then evolve Android-specific input, file integration, testing, and release work independently.

The product remains offline-first: no account, network service, telemetry, or cloud-storage dependency is introduced.

## Baseline and repository boundary

The initial source baseline is `Canvas-Mac` commit `42118c2` on `ipad-gestures-phase1` (`Restore responsive colour picker and brush return [ipad]`). The Android repository receives:

- Gradle root configuration and wrapper.
- Shared `core`, `brushes`, `renderer`, and `ui` modules.
- The `androidApp` host.
- Android-relevant assets, scripts, documentation, tests, CI configuration, and project metadata.

It does not receive `iosApp` or `windowsApp`, Apple-specific resources/tests, or desktop host code. Android's source-of-truth repository is therefore focused on the Android product, not a mirror of every platform.

`Canvas-Mac` remains the source for subsequent shared-editor changes. Android imports upstream changes deliberately, by documented commit selection and Android validation, rather than through an automatic bidirectional sync.

## Architecture

`Canvas_android` retains the established module boundaries:

```text
androidApp
  -> ui
  -> core, brushes, renderer
```

`core` owns documents, commands, history, recovery contracts, gallery data, and persistence format. `brushes` owns brush definitions and stroke sampling. `renderer` owns tile storage, compositing, effects, and export encoders. `ui` owns the shared Compose editor and platform-neutral interaction behavior. `androidApp` owns Android lifecycle, stylus/pointer facts, document/file pickers, sharing, storage, window configuration, and Android-specific tests.

All feature parity work belongs in shared modules when it is platform-neutral. Android-only behavior stays in `androidApp` so it cannot destabilize iPad behavior.

## Required parity contract

At the baseline, Android must expose the same editor capabilities already provided by the shared modules: pressure-sensitive drawing, brush library/studio, selections and transforms, editable objects, layer/mask/group controls, effects and Liquify, Workbench, versions, local gallery, recovery, native `.neocanvas` packages, and supported import/export workflows.

The Android gesture contract is:

| Input | Action |
| --- | --- |
| Stylus | Pressure-sensitive drawing, erasing, smudging, and tool interaction |
| Two fingers | Canvas pan and zoom; optional rotation; tap/hold rapid Undo; pinch-in fit/reset |
| Three fingers | Tap/hold rapid Redo; horizontal swipe artwork clipboard; horizontal scrub clears active raster layer |
| Four-finger tap | Toggle canvas-only mode |
| Finger hold while finger painting is disabled | Open QuickMenu |

These gestures must be tested with touch-only tablets and stylus-capable tablets. Android implementations may offer accessible visible controls and user-configurable alternatives, but must not silently replace the listed actions.

## Android-specific completion work

1. **Input quality.** Validate pointer classification, pressure normalization, multi-touch cancellation, palm rejection, stylus eraser ends and barrel buttons where devices expose them. Verify Samsung S Pen, USI, and a touch-only tablet; unsupported capabilities degrade predictably.
2. **Files and sharing.** Use Android's Storage Access Framework and system share sheet for open, save/export, import and brush-pack workflows. Keep app-local autosave/recovery, but avoid trapping the user's artwork in private app storage. Surface PNG, JPEG, PDF, TIFF, PSD, `.neocanvas`, and brush-pack capabilities where the shared engine supports them.
3. **Tablet windowing.** Support portrait/landscape, edge-to-edge insets, split screen, external keyboard/mouse and screen sizes from approximately 8 to 14 inches without obscuring canvas controls.
4. **Reliability and performance.** Exercise large documents, deep layer stacks, long undo chains, background/foreground recovery, process death and low-storage failures on physical hardware.
5. **Release readiness.** Add Android CI for unit tests, debug/release builds and lint; retain a manual physical-tablet acceptance pass for drawing latency, gestures, input accessories, storage/export and recovery.

## Migration sequence

1. Create the Android repository history from the specified source commit, preserving authorship where feasible.
2. Remove non-Android host modules and their platform-only assets, docs, scripts and CI references; update Gradle settings, README and workflows so the project builds independently.
3. Build and run the Android unit suite before making parity changes. Fix only migration breakages first.
4. Add Android integration tests for input, gesture recognition, Storage Access Framework contracts, recovery and export/share behavior.
5. Complete Android-specific work in small, separately reviewed changes. Each must preserve shared test coverage and add an Android test where platform behavior changes.
6. Release only after automated checks and physical-tablet acceptance pass.

## Error handling and data safety

All document writes remain atomic where supported, with recovery saved separately from user artwork. Failed open/import/export actions leave the active document unchanged and show an actionable error. Unsupported stylus features and unavailable storage providers never cause drawing or saving to fail. Destructive layer-clearing gestures remain a single undoable history action.

## Acceptance criteria

- `Canvas_android` has independent Git history, a `main` branch, a remote at `neoworkssuite/Canvas_android`, and no iOS/Windows host modules.
- The Android app builds from a clean checkout and shared tests pass.
- Every listed gesture works on an Android tablet or presents a documented, user-accessible equivalent when the device cannot produce the required input.
- Stylus and touch drawing do not generate accidental marks during canvas navigation.
- Users can import and export their artwork through standard Android file/share flows, while recovery survives backgrounding and process restart.
- Automated Android checks and physical-tablet acceptance are green before release.

## Out of scope

This migration does not add cloud sync, accounts, telemetry, animation, multi-page sketchbooks, new vector systems, or a new rendering engine. Those are separate product initiatives after Android parity is established.
