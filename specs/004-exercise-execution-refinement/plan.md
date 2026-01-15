# Implementation Plan: Exercise Execution Refinement

**Branch**: `004-exercise-execution-refinement` | **Date**: 2026-01-10 | **Spec**: [spec.md](./spec.md)
**Input**: Feature specification from `/specs/004-exercise-execution-refinement/spec.md`

**Note**: This template is filled in by the `/speckit.plan` command. See `.specify/templates/commands/plan.md` for the execution workflow.

## Summary

Refatorar fluxo de execução de exercícios para remover entrada manual de dados durante treino, implementar timer automático de descanso com suporte a background, adicionar campo de carga aos exercícios, e corrigir navegação pós-treino. A abordagem técnica utiliza SwiftUI @Observable para timer reativo, SwiftData para persistência automática de séries com valores planejados, e NavigationStack para fluxo correto de conclusão.

## Technical Context

**Language/Version**: Swift 5.9+  
**Primary Dependencies**: SwiftUI, SwiftData (iOS native frameworks)  
**Storage**: SwiftData (local persistence, already configured)  
**Testing**: Manual validation (per constitution - no automated tests required)  
**Target Platform**: iOS 17.0+  
**Project Type**: Mobile (iOS native app)  
**Performance Goals**: Timer accuracy ±1 second, UI transitions <300ms, background timer continues without interruption  
**Constraints**: Timer must work in background, must emit notification/sound when complete, no data entry forms during execution  
**Scale/Scope**: 4 ViewModels to refactor/create, 3-4 Views to refactor, 2 Model extensions (Exercise.load, automatic set recording)

## Constitution Check

*GATE: Must pass before Phase 0 research. Re-check after Phase 1 design.*

### Principle I: Mobile-First SwiftUI Components ✅ PASS
- [x] **GATE**: All UI features implemented as small, reusable SwiftUI views?  
  **Status**: PASS - Refactoring existing ExecuteExerciseView, creating refined components (timer display, exercise info header)
- [x] **GATE**: Views accessible (VoiceOver labels, dynamic type, contrast)?  
  **Status**: OPTIONAL per constitution - Not required for this project
- [x] **GATE**: Localized user-facing strings?  
  **Status**: PASS - All Portuguese strings will be in code (simple approach, localization optional)
- [x] **GATE**: Components independently previewable?  
  **Status**: PASS - SwiftUI previews for timer component and exercise info display

### Principle II: Rapid Development & Manual Validation ✅ PASS
- [x] **GATE**: Manual testing planned for all features?  
  **Status**: PASS - Manual validation of timer behavior, background operation, data recording, navigation flow
- [x] **GATE**: No automated testing overhead?  
  **Status**: PASS - No test files required per constitution

### Principle III: Clean Architecture & Module Boundaries ✅ PASS
- [x] **GATE**: Code organized by feature (not technical role only)?  
  **Status**: PASS - Exercise execution remains in BumbumNaNuca/Views/Workout/Execute/, ViewModels in ViewModels/Execute/
- [x] **GATE**: Public APIs between features explicit and minimal?  
  **Status**: PASS - Shared Exercise and WorkoutSession models via SwiftData
- [x] **GATE**: Dependencies acyclic?  
  **Status**: PASS - Execute depends on Models only, no circular refs
- [x] **GATE**: Small protocols for dependency inversion?  
  **Status**: N/A - Direct SwiftData coupling acceptable for single-app context

### Principle IV: Observability & Privacy ✅ PASS
- [x] **GATE**: Structured logging for timer events and session transitions?  
  **Status**: PASS - Will use OSLog for timer start/stop, background transitions, session completion
- [x] **GATE**: No sensitive data in logs?  
  **Status**: PASS - Only exercise names and counts logged, no personal metrics
- [x] **GATE**: Telemetry reviewed?  
  **Status**: N/A - No external telemetry in this feature

### Principle V: Versioning, Backwards Compatibility & Releases ⚠️ REQUIRES ATTENTION
- [x] **GATE**: Breaking changes documented with migration plan?  
  **Status**: PASS - Exercise model extended with optional load field (backward compatible - nil for existing exercises)
- [x] **GATE**: Data format changes have migration path?  
  **Status**: PASS - SwiftData handles schema migration automatically, load field is optional

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
│   ├── Exercise.swift                 # MODIFY - add optional load: Double?
│   ├── ExerciseSet.swift              # EXISTING - already tracks reps/load
│   ├── WorkoutSession.swift           # EXISTING - used for session management
│   └── [other existing models...]
├── ViewModels/
│   ├── Execute/
│   │   ├── ExecuteExerciseViewModel.swift    # REFACTOR - remove input forms, auto-record
│   │   ├── RestTimerViewModel.swift          # REFACTOR - add background support
│   │   ├── WorkoutSessionViewModel.swift     # MODIFY - update navigation logic
│   │   └── WorkoutSummaryViewModel.swift     # MODIFY - fix navigation to Home
│   ├── AddExerciseViewModel.swift            # MODIFY - add load input field
│   └── [other existing ViewModels...]
├── Views/
│   ├── Workout/
│   │   ├── Execute/
│   │   │   ├── ExecuteExerciseView.swift     # REFACTOR - remove forms, show timer
│   │   │   ├── ExecuteWorkoutView.swift      # EXISTING - minimal changes
│   │   │   ├── WorkoutSummaryView.swift      # MODIFY - navigate to Home on finish
│   │   │   └── RestTimerView.swift           # REFACTOR - background support, notifications
│   │   ├── AddExerciseView.swift             # MODIFY - add load input field
│   │   └── [other workout views...]
│   └── Components/
│       ├── SetInputView.swift                # REMOVE or DEPRECATE - no longer needed
│       └── [other components...]
└── Utilities/
    ├── Helpers/
    │   └── Logger.swift                      # EXISTING - use for timer/session logging
    └── Extensions/
        └── [existing extensions...]
```

**Structure Decision**: Mantendo estrutura existente de feature modules. A refatoração ocorre dentro do módulo Execute já existente, com extensão do modelo Exercise para adicionar campo load. Componente SetInputView será removido pois entrada manual de dados não é mais necessária durante execução.

## Complexity Tracking

> **No violations - this section intentionally left empty**

All constitution principles pass without requiring complexity justification. The feature follows established patterns from existing Execute module (specs/002-execute-workout), uses standard SwiftUI/SwiftData approaches, and maintains clean architecture boundaries.

---

## Post-Design Constitution Re-evaluation

**Date**: 2026-01-10  
**Phase**: After Phase 1 (Design & Contracts)

### Validation Results: ✅ ALL GATES PASS

After completing research, data model design, and contract definitions, all constitution principles remain compliant:

- **Principle I (Mobile-First SwiftUI)**: ✅ PASS - 4 new reusable components (ExerciseInfoHeader, TimerDisplay, ActionButton, ProgressIndicator) with previews
- **Principle II (Rapid Development)**: ✅ PASS - Comprehensive manual testing checklist in quickstart.md, no automated tests
- **Principle III (Clean Architecture)**: ✅ PASS - Feature-based organization maintained, no new dependencies introduced
- **Principle IV (Observability)**: ✅ PASS - OSLog integration specified for timer and session events, no PII in logs
- **Principle V (Versioning)**: ✅ PASS - SwiftData lightweight migration confirmed, load field optional for full backward compatibility

**Conclusion**: Design approved. Ready for Phase 2 (Tasks generation with `/speckit.tasks`).

---

## Implementation Summary

**Artifacts Generated**:
- ✅ [research.md](./research.md) - Technical decisions and patterns
- ✅ [data-model.md](./data-model.md) - Schema changes and migration strategy
- ✅ [contracts/viewmodels.md](./contracts/viewmodels.md) - ViewModel interfaces
- ✅ [contracts/views.md](./contracts/views.md) - View layouts and components
- ✅ [quickstart.md](./quickstart.md) - Step-by-step implementation guide

**Estimated Implementation Time**: 6-8 hours (detailed in quickstart.md)

**Risk Level**: LOW
- No breaking changes
- Backward compatible data model
- Existing patterns from specs/002-execute-workout
- Manual validation approach

**Dependencies**: UserNotifications framework (iOS system framework, no external deps)

---
