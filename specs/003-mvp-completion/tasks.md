# Tasks: MVP Completion

**Input**: Design documents from `/specs/003-mvp-completion/`
**Prerequisites**: plan.md ✅, spec.md ✅, research.md ✅, data-model.md ✅, quickstart.md ✅

**Tests**: NOT included (per Constitution II - Rapid Development with manual validation only)

**Organization**: Tasks are grouped by user story to enable independent implementation and testing of each story.

## Format: `- [ ] [ID] [P?] [Story] Description`

- **[P]**: Can run in parallel (different files, no dependencies)
- **[Story]**: Which user story this task belongs to (e.g., US1, US2, US3)
- Include exact file paths in descriptions

---

## Phase 1: Setup (Shared Infrastructure)

**Purpose**: SwiftData schema migration and navigation structure

- [ ] T001 Register CheckIn model in SwiftData schema in BumbumNaNuca/BumbumNaNucaApp.swift
- [ ] T002 [P] Create Calendar+Extensions.swift with CheckInStreak helper in BumbumNaNuca/Utilities/Extensions/Calendar+Extensions.swift
- [ ] T003 [P] Add toHeaderString() and toTimeString() methods to Date+Extensions.swift in BumbumNaNuca/Utilities/Extensions/Date+Extensions.swift

---

## Phase 2: Foundational (Blocking Prerequisites)

**Purpose**: Core models and tab navigation that MUST be complete before ANY user story can be implemented

**⚠️ CRITICAL**: No user story work can begin until this phase is complete

- [ ] T004 Create CheckIn model with SwiftData annotations in BumbumNaNuca/Models/CheckIn.swift
- [ ] T005 Modify ContentView to implement TabView with 4 tabs in BumbumNaNuca/ContentView.swift
- [ ] T006 Create Tab enum and navigation environment key in BumbumNaNuca/ContentView.swift
- [ ] T007 [P] Create HomeViewModel with dashboard data aggregation in BumbumNaNuca/ViewModels/HomeViewModel.swift
- [ ] T008 [P] Create CheckInViewModel with streak calculation logic in BumbumNaNuca/ViewModels/CheckInViewModel.swift
- [ ] T009 [P] Create ProgressViewModel with history queries in BumbumNaNuca/ViewModels/ProgressViewModel.swift
- [ ] T010 [P] Create CheckInCard reusable component in BumbumNaNuca/Views/Components/CheckInCard.swift
- [ ] T011 [P] Create StatCard reusable component in BumbumNaNuca/Views/Components/StatCard.swift
- [ ] T012 [P] Create StreakBadge reusable component in BumbumNaNuca/Views/Components/StreakBadge.swift

**Checkpoint**: Foundation ready - user story implementation can now begin in parallel

---

## Phase 3: User Story 5 - Navegação por Tabs (Priority: P1) 🎯 MVP Foundation

**Goal**: Implementar TabView com navegação independente entre 4 seções principais do app

**Independent Test**: Tocar em cada tab e verificar que troca de tela corretamente. Estado de navegação preservado ao alternar tabs.

### Implementation for User Story 5

- [ ] T013 [US5] Setup independent NavigationStack for each tab in ContentView in BumbumNaNuca/ContentView.swift
- [ ] T014 [US5] Implement tab icons and labels using SF Symbols in BumbumNaNuca/ContentView.swift
- [ ] T015 [US5] Add pop-to-root behavior on tab re-tap in BumbumNaNuca/ContentView.swift
- [ ] T016 [US5] Implement cross-tab navigation environment for Home to Workouts in BumbumNaNuca/ContentView.swift

**Checkpoint**: At this point, TabView navigation should be fully functional with all 4 tabs accessible

---

## Phase 4: User Story 1 - Dashboard Principal (Priority: P1) 🎯 MVP Core

**Goal**: Usuário visualiza dashboard com check-in status, plano ativo e último treino completado

**Independent Test**: Abrir app e verificar que mostra: (1) data atual, (2) card de check-in, (3) plano ativo com botão "Iniciar Treino", (4) resumo do último treino com duração.

### Implementation for User Story 1

- [ ] T017 [US1] Create Home folder structure in BumbumNaNuca/Views/Home/
- [ ] T018 [US1] Implement HomeView with header and greeting in BumbumNaNuca/Views/Home/HomeView.swift
- [ ] T019 [US1] Add active plan card with "Iniciar Treino" button in BumbumNaNuca/Views/Home/HomeView.swift
- [ ] T020 [US1] Add last workout card with duration and relative time in BumbumNaNuca/Views/Home/HomeView.swift
- [ ] T021 [US1] Add check-in status card using CheckInCard component in BumbumNaNuca/Views/Home/HomeView.swift
- [ ] T022 [US1] Implement loadDashboard() query logic in HomeViewModel in BumbumNaNuca/ViewModels/HomeViewModel.swift
- [ ] T023 [US1] Implement performQuickCheckIn() action in HomeViewModel in BumbumNaNuca/ViewModels/HomeViewModel.swift
- [ ] T024 [US1] Add empty states for no active plan and no workout history in BumbumNaNuca/Views/Home/HomeView.swift
- [ ] T025 [US1] Wire cross-tab navigation from "Iniciar Treino" to ExecuteWorkoutView in BumbumNaNuca/Views/Home/HomeView.swift

**Checkpoint**: At this point, Home Dashboard should show all cards and navigate to workout execution

---

## Phase 5: User Story 2 - Check-in na Academia (Priority: P2)

**Goal**: Usuário registra check-in diário, acompanha sequência de dias consecutivos e visualiza estatísticas mensais

**Independent Test**: Fazer check-in, verificar que só permite 1 por dia, observar cálculo de sequência (dias consecutivos) e visualizar estatísticas mensais.

### Implementation for User Story 2

- [ ] T026 [US2] Create CheckIn folder structure in BumbumNaNuca/Views/CheckIn/
- [ ] T027 [US2] Implement CheckInView with main check-in button in BumbumNaNuca/Views/CheckIn/CheckInView.swift
- [ ] T028 [US2] Add current streak display with StreakBadge in BumbumNaNuca/Views/CheckIn/CheckInView.swift
- [ ] T029 [US2] Add longest streak display with StatCard in BumbumNaNuca/Views/CheckIn/CheckInView.swift
- [ ] T030 [US2] Add monthly stats section (total/percentage) in BumbumNaNuca/Views/CheckIn/CheckInView.swift
- [ ] T031 [US2] Add recent check-ins list (last 30) in BumbumNaNuca/Views/CheckIn/CheckInView.swift
- [ ] T032 [US2] Implement performCheckIn() with single-per-day validation in BumbumNaNuca/ViewModels/CheckInViewModel.swift
- [ ] T033 [US2] Implement calculateCurrentStreak() using Calendar+Extensions in BumbumNaNuca/ViewModels/CheckInViewModel.swift
- [ ] T034 [US2] Implement calculateLongestStreak() logic in BumbumNaNuca/ViewModels/CheckInViewModel.swift
- [ ] T035 [US2] Implement calculateMonthlyStats() for current month in BumbumNaNuca/ViewModels/CheckInViewModel.swift
- [ ] T036 [US2] Add button disabled state when already checked in today in BumbumNaNuca/Views/CheckIn/CheckInView.swift
- [ ] T037 [US2] Add empty state when no check-ins exist in BumbumNaNuca/Views/CheckIn/CheckInView.swift

**Checkpoint**: At this point, Check-in system should be fully functional with gamification features

---

## Phase 6: User Story 3 - Histórico de Treinos (Priority: P2)

**Goal**: Usuário visualiza todos os treinos executados com detalhes de data, duração, plano usado e séries executadas

**Independent Test**: Completar 3+ treinos e verificar que lista mostra todas as sessões ordenadas por data. Tocar em sessão deve mostrar exercícios e séries executadas.

### Implementation for User Story 3

- [ ] T038 [US3] Create Progress folder structure in BumbumNaNuca/Views/Progress/
- [ ] T039 [US3] Implement ProgressView with segmented control (Treinos/Exercícios tabs) in BumbumNaNuca/Views/Progress/ProgressView.swift
- [ ] T040 [US3] Implement WorkoutHistoryListView for treinos tab in BumbumNaNuca/Views/Progress/WorkoutHistoryListView.swift
- [ ] T041 [US3] Create WorkoutHistoryRow component showing plan name, date, duration in BumbumNaNuca/Views/Progress/WorkoutHistoryListView.swift
- [ ] T042 [US3] Implement SessionDetailView with exercise list in BumbumNaNuca/Views/Progress/SessionDetailView.swift
- [ ] T043 [US3] Add exercise sets display in SessionDetailView (weight × reps format) in BumbumNaNuca/Views/Progress/SessionDetailView.swift
- [ ] T044 [US3] Implement loadWorkoutHistory() with fetchLimit 50 in BumbumNaNuca/ViewModels/ProgressViewModel.swift
- [ ] T045 [US3] Add navigation from WorkoutHistoryListView to SessionDetailView in BumbumNaNuca/Views/Progress/WorkoutHistoryListView.swift
- [ ] T046 [US3] Add empty state "Nenhum treino realizado" in BumbumNaNuca/Views/Progress/WorkoutHistoryListView.swift
- [ ] T047 [US3] Implement relative time display using Date+Extensions.toRelativeString() in BumbumNaNuca/Views/Progress/WorkoutHistoryListView.swift

**Checkpoint**: At this point, Workout History should show all completed sessions with navigation to details

---

## Phase 7: User Story 4 - Histórico por Exercício (Priority: P3)

**Goal**: Usuário visualiza evolução de exercícios específicos, identifica recorde pessoal e vê histórico completo de séries

**Independent Test**: Executar mesmo exercício em múltiplas sessões com pesos diferentes, acessar aba "Exercícios" e verificar que mostra recorde pessoal correto e histórico completo.

### Implementation for User Story 4

- [ ] T048 [P] [US4] Implement ExerciseHistoryListView for exercícios tab in BumbumNaNuca/Views/Progress/ExerciseHistoryListView.swift
- [ ] T049 [P] [US4] Implement ExerciseHistoryView with PR and stats in BumbumNaNuca/Views/Progress/ExerciseHistoryView.swift
- [ ] T050 [US4] Create ExerciseStatsRow component showing last execution and total in BumbumNaNuca/Views/Progress/ExerciseHistoryListView.swift
- [ ] T051 [US4] Implement loadExerciseHistory() with grouping logic in BumbumNaNuca/ViewModels/ProgressViewModel.swift
- [ ] T052 [US4] Implement calculatePersonalRecord() algorithm (max weight × max reps) in BumbumNaNuca/ViewModels/ProgressViewModel.swift
- [ ] T053 [US4] Add personal record display in ExerciseHistoryView header in BumbumNaNuca/Views/Progress/ExerciseHistoryView.swift
- [ ] T054 [US4] Add all sets history list with date and workout name in BumbumNaNuca/Views/Progress/ExerciseHistoryView.swift
- [ ] T055 [US4] Add navigation from ExerciseHistoryListView to ExerciseHistoryView in BumbumNaNuca/Views/Progress/ExerciseHistoryListView.swift
- [ ] T056 [US4] Add empty state "Nenhum exercício realizado ainda" in BumbumNaNuca/Views/Progress/ExerciseHistoryListView.swift

**Checkpoint**: All user stories should now be independently functional

---

## Phase 8: Polish & Cross-Cutting Concerns

**Purpose**: Improvements that affect multiple user stories

- [ ] T057 [P] Add VoiceOver labels to all interactive elements across views
- [ ] T058 [P] Test Dynamic Type scaling on all text elements
- [ ] T059 [P] Verify color contrast for badges and secondary text
- [ ] T060 Performance optimization: verify Home loads <1s with 50+ sessions
- [ ] T061 Performance optimization: verify Progress loads <1s with fetchLimit working
- [ ] T062 Memory profiling: verify app uses <50MB with full history loaded
- [ ] T063 Run complete manual testing checklist from quickstart.md
- [ ] T064 Update IMPLEMENTATION_STATUS.md with Phase 3 completion status

---

## Dependencies & Execution Order

### Phase Dependencies

- **Setup (Phase 1)**: No dependencies - can start immediately
- **Foundational (Phase 2)**: Depends on Setup completion - BLOCKS all user stories
- **User Stories (Phase 3-7)**: All depend on Foundational phase completion
  - US5 (Navigation) is foundation for US1-4
  - US1 (Home) can start after US5
  - US2 (Check-in) can start after US5 - independent from US1
  - US3 (Workout History) can start after US5 - independent from US1, US2
  - US4 (Exercise History) can start after US5 - independent from US1, US2, US3
- **Polish (Phase 8)**: Depends on all desired user stories being complete

### User Story Dependencies

- **User Story 5 (P1 - Navigation)**: Foundation for all other stories - MUST complete first
- **User Story 1 (P1 - Home)**: Depends on US5 - No dependencies on other stories
- **User Story 2 (P2 - Check-in)**: Depends on US5 - Independent from US1, US3, US4
- **User Story 3 (P2 - Workout History)**: Depends on US5 - Independent from US1, US2, US4
- **User Story 4 (P3 - Exercise History)**: Depends on US5 - Independent from US1, US2, US3

### Within Each User Story

- Phase 2 (Foundational) must complete before any user story
- User Story 5 (Navigation) must complete before US1-4
- All other user stories (US1-4) can proceed in parallel after US5
- Models and ViewModels created in Phase 2
- Views reference ViewModels from Phase 2
- Components from Phase 2 reused across user stories

### Parallel Opportunities

**Phase 1 (Setup)** - All tasks can run in parallel:
- T002: Calendar+Extensions (different file)
- T003: Date+Extensions (different file)
- T001: Sequential (modifies same file as app entry point)

**Phase 2 (Foundational)** - Many tasks can run in parallel:
- T007, T008, T009: All ViewModels (different files)
- T010, T011, T012: All components (different files)
- T004: CheckIn model (dependency for ViewModels)
- T005, T006: ContentView modifications (sequential - same file)

**Phase 4-7 (User Stories)** - After US5 completes:
- US1, US2, US3, US4 can all be worked on in parallel by different developers
- Within each story, tasks marked [P] can run in parallel

**Phase 8 (Polish)** - Accessibility tasks can run in parallel:
- T057, T058, T059: Different aspects of accessibility testing

---

## Parallel Example: Phase 2 Foundational

```bash
# ViewModels can be created in parallel:
Task T007: "Create HomeViewModel" → BumbumNaNuca/ViewModels/HomeViewModel.swift
Task T008: "Create CheckInViewModel" → BumbumNaNuca/ViewModels/CheckInViewModel.swift
Task T009: "Create ProgressViewModel" → BumbumNaNuca/ViewModels/ProgressViewModel.swift

# Components can be created in parallel:
Task T010: "Create CheckInCard" → BumbumNaNuca/Views/Components/CheckInCard.swift
Task T011: "Create StatCard" → BumbumNaNuca/Views/Components/StatCard.swift
Task T012: "Create StreakBadge" → BumbumNaNuca/Views/Components/StreakBadge.swift
```

---

## Parallel Example: User Stories After US5

```bash
# Once US5 (Navigation) is complete, all other stories can start:
Developer A: Phase 4 (User Story 1 - Home Dashboard)
Developer B: Phase 5 (User Story 2 - Check-in System)
Developer C: Phase 6 (User Story 3 - Workout History)
Developer D: Phase 7 (User Story 4 - Exercise History)

# Each story is independently completable and testable
```

---

## Implementation Strategy

### MVP First (User Stories 5 + 1 Only)

1. Complete Phase 1: Setup
2. Complete Phase 2: Foundational (CRITICAL - blocks all stories)
3. Complete Phase 3: User Story 5 (Navigation foundation)
4. Complete Phase 4: User Story 1 (Home Dashboard)
5. **STOP and VALIDATE**: Test independently using quickstart.md
6. Deploy/demo if ready

**Minimal Viable Product = Navigation + Home Dashboard**

### Incremental Delivery

1. Complete Setup + Foundational → Foundation ready
2. Add US5 (Navigation) → Test tab switching → Foundational navigation works
3. Add US1 (Home) → Test dashboard independently → Deploy/Demo (MVP!)
4. Add US2 (Check-in) → Test check-in and streaks independently → Deploy/Demo
5. Add US3 (Workout History) → Test history listing independently → Deploy/Demo
6. Add US4 (Exercise History) → Test exercise tracking independently → Deploy/Demo
7. Each story adds value without breaking previous stories

### Parallel Team Strategy

With multiple developers:

1. **Week 1**: Team completes Setup + Foundational together
2. **Week 2**: Complete US5 (Navigation) together - foundation for all
3. **Week 3+**: Once US5 is done, parallel development:
   - Developer A: User Story 1 (Home)
   - Developer B: User Story 2 (Check-in)
   - Developer C: User Story 3 (Workout History)
   - Developer D: User Story 4 (Exercise History)
4. Stories complete and integrate independently without conflicts

---

## Notes

- **[P] tasks**: Different files, no dependencies - safe to parallelize
- **[Story] label**: Maps task to specific user story for traceability
- **Each user story**: Independently completable and testable per spec.md requirements
- **No tests**: Manual validation only (Constitution II - Rapid Development)
- **Commit frequency**: After each task or logical group
- **Checkpoints**: Stop at any checkpoint to validate story independently
- **SwiftData migration**: Auto-migration from schema v1 to v2 (additive, safe)

---

## Success Validation

After completing all tasks, verify against spec.md Success Criteria:

- [ ] SC-001: Check-in completes in <3 seconds
- [ ] SC-002: Streak calculation 100% correct in all test cases
- [ ] SC-003: Home loads in <1 second with 50+ workouts
- [ ] SC-004: Tab navigation maintains 60fps
- [ ] SC-005: Workout history shows all completed sessions correctly
- [ ] SC-006: Personal records identified correctly (100% accuracy)
- [ ] SC-007: Memory usage <50MB with full history
- [ ] SC-008: Find specific session in <5 seconds
- [ ] SC-009: 90% users complete check-in first try (beta feedback)
- [ ] SC-010: Monthly stats correct for 28/30/31 day months
- [ ] SC-011: All empty states are informative with next action
- [ ] SC-012: App remains responsive with 100+ records

Run complete manual testing checklist from quickstart.md (42 test cases: TC-H1 through TC-P8).
