# Tasks: Exercise Execution Refinement

**Input**: Design documents from `/specs/004-exercise-execution-refinement/`
**Prerequisites**: plan.md, spec.md, research.md, data-model.md, contracts/

**Tests**: NO automated tests per constitution - manual validation only

**Organization**: Tasks grouped by user story (US1, US2, US3) for independent implementation and testing

## Format: `- [ ] [ID] [P?] [Story] Description`

- **[P]**: Can run in parallel (different files, no dependencies)
- **[Story]**: Which user story this task belongs to (US1, US2, US3)
- Include exact file paths in descriptions

---

## Phase 1: Setup (Shared Infrastructure)

**Purpose**: Project initialization and permission configuration

- [ ] T001 Request UserNotifications permission in BumbumNaNuca/BumbumNaNucaApp.swift for timer alerts

**Checkpoint**: Permission requested on app launch

---

## Phase 2: Foundational (Blocking Prerequisites)

**Purpose**: Model changes that ALL user stories depend on

**⚠️ CRITICAL**: No user story work can begin until this phase is complete

- [ ] T002 Add optional load field to Exercise model in BumbumNaNuca/Models/Exercise.swift
- [ ] T003 Update Exercise init() to accept optional load parameter in BumbumNaNuca/Models/Exercise.swift

**Checkpoint**: Foundation ready - SwiftData migration automatic, user story implementation can now begin

---

## Phase 3: User Story 1 - Streamlined Exercise Execution with Rest Timer (Priority: P1) 🎯 MVP

**Goal**: Enable distraction-free exercise execution with automatic set recording and integrated rest timer

**Independent Test**: Start workout → select exercise → complete all sets with rest periods → verify no manual input required, timer works, navigation flows correctly

### Components for User Story 1

- [ ] T004 [P] [US1] Create ExerciseInfoHeader component in BumbumNaNuca/Views/Components/ExerciseInfoHeader.swift
- [ ] T005 [P] [US1] Create InfoPill subcomponent in BumbumNaNuca/Views/Components/ExerciseInfoHeader.swift
- [ ] T006 [P] [US1] Create TimerDisplay component in BumbumNaNuca/Views/Components/TimerDisplay.swift
- [ ] T007 [P] [US1] Create ProgressIndicator component in BumbumNaNuca/Views/Components/ProgressIndicator.swift (inline or separate file)

### ViewModels for User Story 1

- [ ] T008 [US1] Refactor ExecuteExerciseViewModel: remove input fields (weightText, repsText, errors) in BumbumNaNuca/ViewModels/Execute/ExecuteExerciseViewModel.swift
- [ ] T009 [US1] Add automatic set recording to ExecuteExerciseViewModel.recordSet() using exercise defaults in BumbumNaNuca/ViewModels/Execute/ExecuteExerciseViewModel.swift
- [ ] T010 [US1] Add early finish confirmation logic (attemptFinish, finish methods) to ExecuteExerciseViewModel in BumbumNaNuca/ViewModels/Execute/ExecuteExerciseViewModel.swift
- [ ] T011 [US1] Add computed properties (isLastSet, setsRemaining) to ExecuteExerciseViewModel in BumbumNaNuca/ViewModels/Execute/ExecuteExerciseViewModel.swift
- [ ] T012 [US1] Enhance RestTimerViewModel with background task support in BumbumNaNuca/ViewModels/Execute/RestTimerViewModel.swift
- [ ] T013 [US1] Add local notification scheduling to RestTimerViewModel in BumbumNaNuca/ViewModels/Execute/RestTimerViewModel.swift
- [ ] T014 [US1] Add default 60s rest time to RestTimerViewModel.init in BumbumNaNuca/ViewModels/Execute/RestTimerViewModel.swift
- [ ] T015 [US1] Add sound/haptic feedback to RestTimerViewModel.complete() in BumbumNaNuca/ViewModels/Execute/RestTimerViewModel.swift

### Views for User Story 1

- [ ] T016 [US1] Refactor ExecuteExerciseView: remove SetInputView and input forms in BumbumNaNuca/Views/Workout/Execute/ExecuteExerciseView.swift
- [ ] T017 [US1] Add ExerciseInfoHeader to ExecuteExerciseView top section in BumbumNaNuca/Views/Workout/Execute/ExecuteExerciseView.swift
- [ ] T018 [US1] Add inline timer display (TimerDisplay component) to ExecuteExerciseView in BumbumNaNuca/Views/Workout/Execute/ExecuteExerciseView.swift
- [ ] T019 [US1] Add ProgressIndicator to ExecuteExerciseView when timer not running in BumbumNaNuca/Views/Workout/Execute/ExecuteExerciseView.swift
- [ ] T020 [US1] Implement dynamic button ("Começar Descanso" / "Finalizar Exercício") in ExecuteExerciseView in BumbumNaNuca/Views/Workout/Execute/ExecuteExerciseView.swift
- [ ] T021 [US1] Add early finish confirmation alert to ExecuteExerciseView in BumbumNaNuca/Views/Workout/Execute/ExecuteExerciseView.swift
- [ ] T022 [US1] Wire up "Começar Descanso" button to recordSet() and timer start in ExecuteExerciseView in BumbumNaNuca/Views/Workout/Execute/ExecuteExerciseView.swift

### Manual Validation for User Story 1

- [ ] T023 [US1] Manual test: Automatic set recording (press "Começar Descanso" → set recorded with planned values)
- [ ] T024 [US1] Manual test: Background timer (background app → notification appears when timer completes)
- [ ] T025 [US1] Manual test: Last set finish (button shows "Finalizar Exercício" on last set)
- [ ] T026 [US1] Manual test: Early finish confirmation (finish before all sets → alert shows)
- [ ] T027 [US1] Manual test: Set progression (counter increments after "Começar Descanso")
- [ ] T028 [US1] Manual test: Default rest time (exercise without rest time → uses 60s)
- [ ] T029 [US1] Manual test: Timer accuracy (verify ±1 second with stopwatch)

**Checkpoint**: User Story 1 fully functional - can ship as MVP

---

## Phase 4: User Story 2 - Exercise Load Tracking (Priority: P2)

**Goal**: Enable users to configure and track load (weight) for each exercise

**Independent Test**: Create exercise → enter load value → save → verify load persisted and displayed during execution

### ViewModels for User Story 2

- [ ] T030 [P] [US2] Add loadText property to AddExerciseViewModel in BumbumNaNuca/ViewModels/AddExerciseViewModel.swift
- [ ] T031 [P] [US2] Add loadError validation to AddExerciseViewModel.validateInputs() in BumbumNaNuca/ViewModels/AddExerciseViewModel.swift
- [ ] T032 [US2] Update AddExerciseViewModel.saveExercise() to parse and save load field in BumbumNaNuca/ViewModels/AddExerciseViewModel.swift

### Views for User Story 2

- [ ] T033 [US2] Add load TextField to AddExerciseView form in BumbumNaNuca/Views/Workout/AddExerciseView.swift
- [ ] T034 [US2] Add load validation error display to AddExerciseView in BumbumNaNuca/Views/Workout/AddExerciseView.swift
- [ ] T035 [US2] Add help text ("Deixe em branco...") for load field in AddExerciseView in BumbumNaNuca/Views/Workout/AddExerciseView.swift
- [ ] T036 [US2] Add onChange handler for loadText validation in AddExerciseView in BumbumNaNuca/Views/Workout/AddExerciseView.swift

### Integration for User Story 2

- [ ] T037 [US2] Verify ExerciseInfoHeader displays load value (already implemented in T004)
- [ ] T038 [US2] Verify automatic set recording includes load (already implemented in T009)

### Manual Validation for User Story 2

- [ ] T039 [US2] Manual test: Create exercise with load (enter "50.5" → saves correctly)
- [ ] T040 [US2] Manual test: Create exercise without load (leave blank → saves as nil)
- [ ] T041 [US2] Manual test: Load validation (enter invalid value → shows error)
- [ ] T042 [US2] Manual test: Load displayed during execution (ExerciseInfoHeader shows "50.5 kg")
- [ ] T043 [US2] Manual test: Existing exercises migration (open app → existing exercises have load = nil)

**Checkpoint**: User Story 2 complete - load tracking fully functional

---

## Phase 5: User Story 3 - Correct Workout Completion Navigation (Priority: P1)

**Goal**: Fix navigation to return to Home screen after workout completion

**Independent Test**: Complete workout → press "Finalizar" on summary → verify navigation goes to Home (not back to ExecuteWorkoutView)

### ViewModels for User Story 3

- [ ] T044 [US3] Verify WorkoutSessionViewModel.finalizeSession() sets session.endDate (no changes needed) in BumbumNaNuca/ViewModels/Execute/WorkoutSessionViewModel.swift

### Views for User Story 3

- [ ] T045 [US3] Add onChange(session.endDate) handler to ExecuteWorkoutView for auto-dismiss in BumbumNaNuca/Views/Workout/Execute/ExecuteWorkoutView.swift
- [ ] T046 [US3] Verify WorkoutSummaryView "Finalizar" button calls dismiss() (no changes needed) in BumbumNaNuca/Views/Workout/Execute/WorkoutSummaryView.swift

### Manual Validation for User Story 3

- [ ] T047 [US3] Manual test: Complete workout navigation (finish all exercises → press "Finalizar" → navigates to Home)
- [ ] T048 [US3] Manual test: Session marked ended (check session.endDate is set after completion)
- [ ] T049 [US3] Manual test: No back navigation (cannot navigate back to ExecuteWorkoutView after finish)
- [ ] T050 [US3] Manual test: Completed session recorded (verify workout appears in history)

**Checkpoint**: User Story 3 complete - navigation bug fixed

---

## Phase 6: Polish & Cross-Cutting Concerns

**Purpose**: Cleanup, deprecation, and final validation

- [ ] T051 [P] Deprecate or remove SetInputView component in BumbumNaNuca/Views/Components/SetInputView.swift
- [ ] T052 [P] Add OSLog statements for timer events (start, complete, background) in RestTimerViewModel
- [ ] T053 [P] Add OSLog statements for session transitions (start, finish) in WorkoutSessionViewModel
- [ ] T054 [P] Add SwiftUI Previews for ExerciseInfoHeader component
- [ ] T055 [P] Add SwiftUI Previews for TimerDisplay component
- [ ] T056 [P] Add SwiftUI Previews for ExecuteExerciseView

### Final Integration Testing

- [ ] T057 Complete all 8 manual tests from quickstart.md (T023-T029, T039-T043, T047-T050)
- [ ] T058 Verify no compiler warnings in project
- [ ] T059 Verify SwiftUI previews render correctly for all new components
- [ ] T060 Verify SwiftData migration successful (no data loss, load field optional)
- [ ] T061 Verify timer accuracy with stopwatch (±1 second tolerance)
- [ ] T062 Verify background timer notifications work correctly

**Checkpoint**: Feature complete and validated

---

## Dependency Graph

### User Story Completion Order

```
Phase 1: Setup (T001)
    ↓
Phase 2: Foundation (T002, T003)
    ↓
    ├─→ User Story 1 (T004-T029) [P1] 🎯 MVP - CAN SHIP HERE
    ├─→ User Story 2 (T030-T043) [P2] - Independent, can implement in parallel
    └─→ User Story 3 (T044-T050) [P1] - Independent, can implement in parallel
    ↓
Phase 6: Polish (T051-T062)
```

### Parallel Execution Examples

**After Foundation Complete (T002-T003)**:
- Parallel Track A: Components (T004-T007) - different files
- Parallel Track B: ViewModels (T008-T015) - can start simultaneously with Track A
- Sequential: Views (T016-T022) - depends on T004-T015 completion

**After US1 Complete**:
- Parallel: US2 (T030-T043) AND US3 (T044-T050) - completely independent

**During Polish**:
- All T051-T056 can run in parallel (different files)

---

## Implementation Strategy

### MVP (Minimum Viable Product)

**Recommended MVP Scope**: User Story 1 only (T001-T029)

**Reasoning**:
- US1 delivers core value: streamlined execution with timer
- US2 (load tracking) is enhancement, not blocker
- US3 (navigation fix) is important but US1 provides working execution flow

**MVP Delivery**: ~4-5 hours
- Phase 1: 5 min (T001)
- Phase 2: 30 min (T002-T003)
- US1 Implementation: 3-4 hours (T004-T022)
- US1 Validation: 30 min (T023-T029)

### Incremental Delivery Beyond MVP

1. **MVP Release**: Ship US1 (streamlined execution + timer)
2. **Increment 2**: Add US2 (load tracking) - ~1-2 hours
3. **Increment 3**: Add US3 (navigation fix) - ~30 min
4. **Polish Release**: Complete Phase 6 - ~1 hour

---

## Summary

**Total Tasks**: 62
- Setup: 1 task
- Foundation: 2 tasks
- User Story 1 (P1 MVP): 26 tasks (4 components, 8 ViewModel, 7 View, 7 validation)
- User Story 2 (P2): 14 tasks (3 ViewModel, 4 View, 5 validation)
- User Story 3 (P1): 7 tasks (1 ViewModel, 2 View, 4 validation)
- Polish: 12 tasks (cleanup, logging, previews, final validation)

**Estimated Time**: 6-8 hours total
- MVP (US1 only): 4-5 hours
- Full feature: 6-8 hours

**Parallel Opportunities**: 15+ tasks can run in parallel after foundation
**Manual Tests**: 19 validation scenarios (no automated tests per constitution)

**Risk Mitigation**:
- Foundation phase ensures model compatibility before any UI work
- Each user story independently testable
- Parallel tracks reduce timeline
- Comprehensive manual validation checklist

**Ready for**: Implementation with `/speckit.implement` or manual execution following quickstart.md
