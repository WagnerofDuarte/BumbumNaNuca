# Implementation Plan: Register Check-In Flow

**Branch**: `005-register-check-in` | **Date**: January 15, 2026 | **Spec**: [spec.md](spec.md)
**Input**: Feature specification from `/specs/005-register-check-in/spec.md`

## Summary

Implementar sistema completo de registro de check-ins com foto, permitindo usuários documentar visualmente suas sessões de treino. Feature inclui: (1) Tela de registro com captura de foto (câmera/galeria), campos para tipo de exercício, título, calorias, localização e data/hora; (2) Tab de Check-In com calendário mensal mostrando fotos arredondadas (ou ícones placeholder) nos dias com check-ins; (3) Visualização histórica de todos os meses com check-ins ordenados cronologicamente. Sistema persiste dados localmente via SwiftData com validação de campos obrigatórios e tratamento de permissões.

## Technical Context

**Language/Version**: Swift 5.9+  
**Primary Dependencies**: SwiftUI, SwiftData, PhotosUI, AVFoundation (camera), UserNotifications (permissions)  
**Storage**: SwiftData (CheckIn model com image data, reuso do schema existente)  
**Testing**: Manual validation (per Constitution II - Rapid Development & Manual Validation)  
**Target Platform**: iOS 17.0+  
**Project Type**: Mobile (iOS native app)  
**Performance Goals**: <2s calendar view load, <90s complete check-in flow, smooth 60fps scrolling through 12+ months  
**Constraints**: Image storage <2MB per photo (compression required), offline-first, handle 100+ check-ins without degradation, camera/photo permissions required  
**Scale/Scope**: ~8 new Views (RegisterCheckInView, CheckInTabView, CalendarMonthView, AllCheckInsView, etc), 3 ViewModels (RegisterCheckInViewModel, CheckInViewModel, CalendarViewModel), 1 SwiftData model extension (CheckIn modification), photo selection/capture components

## Constitution Check

*GATE: Must pass before Phase 0 research. Re-check after Phase 1 design.*

### Principle I: Mobile-First SwiftUI Components
- [x] **GATE**: UI features implemented as small, reusable SwiftUI views?
  - RegisterCheckInView, CalendarDayView, MonthCalendarView, PhotoPickerButton, ExerciseTypePicker
  - All components independently previewable with #Preview
- [x] **GATE**: View models are lightweight and focused?
  - RegisterCheckInViewModel (form state), CheckInViewModel (tab summary), CalendarViewModel (month data)
- [x] **GATE**: Localized strings for user-facing text?
  - Check-in titles, exercise types, validation messages, tab labels
- [x] **GATE**: Components documented with usage notes?
  - ✅ Phase 1 complete: All contracts documented in viewmodels.md

### Principle II: Rapid Development & Manual Validation
- [x] **GATE**: Manual testing plan defined instead of automated tests?
  - Test scenarios: photo capture, gallery selection, form validation, calendar display, permissions
  - No automated test suite required per constitution
- [x] **GATE**: Focused on rapid feature delivery?
  - Iterative approach: P1 stories first (check-in registration + monthly calendar), P2 later

### Principle III: Clean Architecture & Module Boundaries
- [x] **GATE**: Code organized by feature (not just by technical role)?
  - Views/CheckIn/, ViewModels/CheckInViewModel.swift, Models/CheckIn.swift extension
- [x] **GATE**: Public APIs between features explicit and minimal?
  - CheckIn model accessed via SwiftData queries, no direct cross-feature coupling
- [x] **GATE**: Dependencies are acyclic?
  - CheckIn → Exercise (for type), no circular dependencies

### Principle IV: Observability & Privacy
- [x] **GATE**: Structured logging integrated?
  - Use existing Logger.swift utility for check-in creation, photo selection, errors
- [x] **GATE**: No sensitive user data logged?
  - ✅ Verified in contracts: Log only exercise type (enum), hasPhoto (bool), error codes
  - ✅ Do NOT log: photo data, title text, location strings
- [x] **GATE**: Crash reporting for production issues?
  - Leverage existing app crash reporting setup

### Principle V: Versioning & Backwards Compatibility
- [x] **GATE**: SwiftData schema changes follow migration plan?
  - CheckIn model already exists in schema (added in Feature 003)
  - This feature extends CheckIn with new fields: photoData, exerciseType, title, calories, location
  - Migration: Additive (optional fields), backward compatible
- [x] **GATE**: Breaking changes documented with migration?
  - ✅ Phase 1 complete: data-model.md documents schema v4→v5 migration with default values

### Additional Constraints
- [x] **GATE**: iOS 17.0+ deployment target confirmed?
  - Using PhotosUI (iOS 14+), SwiftData (iOS 17+) - compliant
- [x] **GATE**: Swift 5.9+ toolchain?
  - Using @Observable macro, modern SwiftUI - compliant
- [x] **GATE**: Third-party libraries justified?
  - Zero external dependencies - using native PhotosUI, AVFoundation, SwiftData
- [x] **GATE**: Secure storage for photos?
  - Photos stored in SwiftData (encrypted at rest by iOS), no cloud upload in MVP
- [x] **GATE**: Permissions handling (camera, photo library)?
  - Request permissions via PhotosPicker (automatic) and AVCaptureDevice (manual request)

### Development Workflow
- [x] **GATE**: Work on feature branch with PR workflow?
  - Branch: 005-register-check-in
- [x] **GATE**: PR includes: description, spec link, screenshots, manual testing notes?
  - ✅ Checklist ready in quickstart.md Phase 5

**Constitution Check Status**: ✅ PASSED (all gates cleared post-Phase 1 design)

**Re-evaluation Date**: January 15, 2026 (post-Phase 1)

## Project Structure

### Documentation (this feature)

```text
specs/[###-feature]/
├── plan.md              # This file (/speckit.plan command output)
├── research.md          # Phase 0 output (/speckit.plan command)
├── data-model.md        # Phase 1 output (/speckit.plan command)
├── quickstart.md        # Phase 1 output (/speckit.plan command)
├── contracts/           # Phase 1 output (/speckit.plan command)
└── tasks.md             # Phase 2 output (/speckit.tasks command - NOT created by /speckit.plan)
```

### Source Code (repository root)

```text
BumbumNaNuca/
├── Models/
│   └── CheckIn.swift              # EXTEND: Add photoData, exerciseType, title, calories, location
├── Views/
│   └── CheckIn/                   # NEW FOLDER
│       ├── RegisterCheckInView.swift        # NEW: Form for creating check-in
│       ├── CheckInTabView.swift             # NEW: Tab with calendar + summary
│       ├── CalendarMonthView.swift          # NEW: Monthly calendar grid
│       ├── CalendarDayView.swift            # NEW: Day cell with photo/icon
│       └── AllCheckInsView.swift            # NEW: Historical months view
├── Components/                    # NEW FOLDER (if doesn't exist) or Views/Components/
│   ├── PhotoPickerButton.swift    # NEW: Camera/gallery selection UI
│   ├── ExerciseTypePicker.swift   # NEW: Exercise type selector
│   └── PlaceholderIconView.swift  # NEW: Rounded icon for no-photo check-ins
├── ViewModels/
│   ├── RegisterCheckInViewModel.swift       # NEW: Form state + validation + save
│   ├── CheckInViewModel.swift               # NEW: Tab summary (count, calendar data)
│   └── CalendarViewModel.swift              # NEW: Month grouping + filtering logic
└── Utilities/
    └── Extensions/
        └── Image+Compression.swift          # NEW: Photo compression helpers
```

**Structure Decision**: Feature-based organization within existing BumbumNaNuca/ structure. 
- New `Views/CheckIn/` folder groups all check-in related views
- Reusable components in `Views/Components/` (or create if doesn't exist)
- ViewModels follow existing naming pattern (CheckInViewModel, RegisterCheckInViewModel)
- Models extend existing CheckIn.swift from Feature 003

## Complexity Tracking

> **No violations - this section intentionally left empty**

Constitution compliance is clean - no complexity violations to justify. All choices align with existing patterns (SwiftUI components, SwiftData persistence, zero external dependencies).
