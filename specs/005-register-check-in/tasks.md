# Tasks: Register Check-In Flow

**Feature**: 005-register-check-in  
**Input**: Design documents from `/specs/005-register-check-in/`  
**Generated**: January 15, 2026

**Organization**: Tasks are grouped by user story to enable independent implementation and testing of each story.

---

## Format: `[ID] [P?] [Story] Description`

- **[P]**: Can run in parallel (different files, no dependencies)
- **[Story]**: Which user story this task belongs to (e.g., US1, US2, US3, US4)
- Include exact file paths in descriptions

---

## Phase 1: Setup (Shared Infrastructure)

**Purpose**: Project initialization and data layer foundation

- [X] T001 Extend CheckIn model with new fields (photoData, exerciseType, title, calories, location) in BumbumNaNuca/Models/CheckIn.swift
- [X] T002 [P] Create ExerciseType helper with 8 predefined types and icon mapping in BumbumNaNuca/Utilities/ExerciseType.swift
- [X] T003 [P] Add UIImage compression extension (JPEG 0.7 quality, <2MB target) in BumbumNaNuca/Utilities/Extensions/UIImage+Compression.swift
- [X] T004 [P] Add Calendar extensions (startOfMonth, endOfMonth, daysInMonth) in BumbumNaNuca/Utilities/Extensions/Calendar+CheckIn.swift
- [X] T005 [P] Create Logger extension for check-in operations in BumbumNaNuca/Utilities/Helpers/Logger.swift

---

## Phase 2: Foundational (Blocking Prerequisites)

**Purpose**: Core UI components that MUST be complete before ANY user story can be implemented

**⚠️ CRITICAL**: No user story work can begin until this phase is complete

- [X] T006 Create CameraPicker UIViewControllerRepresentable for camera capture in BumbumNaNuca/Views/Components/CameraPicker.swift
- [X] T007 [P] Create PlaceholderIconView component for exercise type icons (40-48pt rounded) in BumbumNaNuca/Views/Components/PlaceholderIconView.swift
- [X] T008 [P] Create ExerciseTypePicker component for exercise type selection in BumbumNaNuca/Views/Components/ExerciseTypePicker.swift

**Checkpoint**: Foundation ready - user story implementation can now begin in parallel

---

## Phase 3: User Story 1 - Quick Check-In Registration (Priority: P1) 🎯 MVP

**Goal**: Enable users to register a check-in with photo, exercise type, and title

**Independent Test**: 
1. Tap "Check In" button on Home screen
2. Select exercise type from predefined list
3. Add photo via camera or gallery
4. Enter title (required)
5. Tap "Check In" to save
6. Verify navigation to Home screen and check-in count incremented

### Implementation for User Story 1

- [X] T009 [P] [US1] Create RegisterCheckInViewModel with form state, validation, and save logic in BumbumNaNuca/ViewModels/RegisterCheckInViewModel.swift
- [X] T010 [US1] Create RegisterCheckInView with form UI (exercise picker, title field, photo buttons, date picker) in BumbumNaNuca/Views/CheckIn/RegisterCheckInView.swift
- [X] T011 [US1] Add "Check In" button to Home screen that presents RegisterCheckInView in BumbumNaNuca/Views/Home/HomeView.swift
- [X] T012 [US1] Implement photo selection flow (camera + gallery) with permissions handling in RegisterCheckInView
- [X] T013 [US1] Add form validation (required: exercise type, title; future date prevention) in RegisterCheckInViewModel
- [X] T014 [US1] Implement save action with SwiftData persistence and navigation dismissal in RegisterCheckInViewModel
- [X] T015 [US1] Add error display for validation failures and save errors in RegisterCheckInView
- [X] T016 [US1] Add unsaved changes warning when navigating away from RegisterCheckInView

**Checkpoint**: At this point, User Story 1 should be fully functional - users can create check-ins with photos

---

## Phase 4: User Story 2 - Detailed Training Metrics Capture (Priority: P2)

**Goal**: Allow users to add optional calories and location to check-ins

**Independent Test**: 
1. Open Register Check-In screen
2. Add required fields (exercise type, title)
3. Add optional fields (calories, location)
4. Select custom date/time (not default)
5. Save and verify all fields persisted

### Implementation for User Story 2

- [X] T017 [P] [US2] Add calories input field (numeric, optional) to RegisterCheckInView in BumbumNaNuca/Views/CheckIn/RegisterCheckInView.swift
- [X] T018 [P] [US2] Add location input field (text, optional, max 200 chars) to RegisterCheckInView in BumbumNaNuca/Views/CheckIn/RegisterCheckInView.swift
- [X] T019 [US2] Implement date/time picker with future date restriction in RegisterCheckInView
- [X] T020 [US2] Add numeric validation for calories (non-negative) in RegisterCheckInViewModel
- [X] T021 [US2] Update save logic to persist optional fields in RegisterCheckInViewModel

**Checkpoint**: At this point, User Stories 1 AND 2 should both work - check-ins can have full detail capture

---

## Phase 5: User Story 3 - Monthly Calendar Overview (Priority: P1) 🎯 MVP

**Goal**: Display current month calendar with check-in photos on respective days

**Independent Test**: 
1. Create 3-5 check-ins on different days
2. Navigate to Check-In tab
3. Verify summary shows correct total count
4. Verify current month calendar displays photos on check-in days
5. Verify placeholder icons shown for check-ins without photos
6. Verify most recent photo shown when multiple check-ins on same day

### Implementation for User Story 3

- [X] T022 [P] [US3] Create CheckInViewModel with total count and current month data in BumbumNaNuca/ViewModels/CheckInViewModel.swift
- [X] T023 [P] [US3] Create CalendarDayView component showing photo/icon with rounded style in BumbumNaNuca/Views/CheckIn/CalendarDayView.swift
- [X] T024 [P] [US3] Create CalendarMonthView with 7-column LazyVGrid layout in BumbumNaNuca/Views/CheckIn/CalendarMonthView.swift
- [X] T025 [US3] Create CheckInTabView with summary section (total count) at top in BumbumNaNuca/Views/CheckIn/CheckInTabView.swift
- [X] T026 [US3] Add current month calendar display to CheckInTabView below summary
- [X] T027 [US3] Implement SwiftData query for check-ins grouped by calendar day in CheckInViewModel
- [X] T028 [US3] Add logic to show most recent photo when multiple check-ins on same day in CalendarDayView
- [X] T029 [US3] Add placeholder icon display for check-ins without photos in CalendarDayView
- [X] T030 [US3] Add Check-In tab to main TabView navigation in BumbumNaNuca/ContentView.swift

**Checkpoint**: At this point, User Stories 1 AND 3 should work independently - MVP calendar visualization complete

---

## Phase 6: User Story 4 - Historical Check-In Calendar Navigation (Priority: P2)

**Goal**: Display all historical months with check-ins in scrollable list

**Independent Test**: 
1. Create check-ins spanning 3+ months
2. Navigate to Check-In tab
3. Tap "View All Check-Ins" button
4. Verify all months with check-ins displayed (current → earliest)
5. Verify months without check-ins excluded
6. Verify smooth scrolling through 12+ months

### Implementation for User Story 4

- [X] T031 [P] [US4] Create CalendarViewModel with month grouping logic (current → earliest) in BumbumNaNuca/ViewModels/CalendarViewModel.swift
- [X] T032 [US4] Create AllCheckInsView with scrollable list of monthly calendars in BumbumNaNuca/Views/CheckIn/AllCheckInsView.swift
- [X] T033 [US4] Implement SwiftData query for all months containing check-ins in CalendarViewModel
- [X] T034 [US4] Add month filtering (exclude empty months) in CalendarViewModel
- [X] T035 [US4] Add "View All Check-Ins" button below calendar in CheckInTabView
- [X] T036 [US4] Connect button to AllCheckInsView navigation in CheckInTabView
- [X] T037 [US4] Optimize scrolling performance with LazyVStack for 100+ check-ins in AllCheckInsView

**Checkpoint**: All user stories should now be independently functional - complete feature delivered

---

## Phase 7: Polish & Cross-Cutting Concerns

**Purpose**: Improvements that affect multiple user stories

- [X] T038 [P] Add haptic feedback on successful check-in save in RegisterCheckInViewModel
- [X] T039 [P] Add pull-to-refresh on CheckInTabView to reload check-ins
- [X] T040 Add empty state view when no check-ins exist in CheckInTabView
- [ ] T041 [P] Add loading indicators during photo loading in RegisterCheckInView
- [ ] T042 [P] OPTIONAL: Add accessibility labels for VoiceOver support on all check-in views (not required per Constitution v2.0)
- [X] T043 Verify image compression and format compatibility (JPEG/PNG/HEIC) and corrupted image handling in UIImage+Compression.swift and CheckIn.photo
- [X] T044 Add error handling for corrupted image data in CheckIn.photo computed property
- [X] T045 [P] Verify no sensitive data logged (photo data, titles, locations excluded) in Logger usage
- [X] T046 Test permissions flow for denied camera/gallery access in RegisterCheckInView
- [ ] T047 Performance test: Load calendar with 100+ check-ins (<2s load time) in CheckInTabView
- [ ] T048 Performance test: Scroll through 12+ months (60fps smooth) in AllCheckInsView
- [X] T049 Test backward compatibility with existing CheckIn records (Feature 003) in BumbumNaNuca/Models/CheckIn.swift
- [X] T050 [P] Add SwiftUI previews for all new views with sample data
- [ ] T051 Run quickstart.md manual testing scenarios across all user stories
- [X] T052 Update IMPLEMENTATION_STATUS.md with Feature 005 completion status
- [X] T053 [P] Implement permission denial error UI (camera/gallery) with user guidance in RegisterCheckInView per FR-027

---

## Dependencies & Execution Order

### Phase Dependencies

- **Setup (Phase 1)**: No dependencies - can start immediately
- **Foundational (Phase 2)**: Depends on Setup completion - BLOCKS all user stories
- **User Story 1 (Phase 3)**: Depends on Foundational - MVP core check-in registration
- **User Story 2 (Phase 4)**: Depends on Foundational - Can run in parallel with US1/US3 if staffed
- **User Story 3 (Phase 5)**: Depends on Foundational - MVP core calendar display
- **User Story 4 (Phase 6)**: Depends on US3 (reuses CalendarMonthView component)
- **Polish (Phase 7)**: Depends on all user stories being complete

### User Story Dependencies

- **User Story 1 (P1)**: Can start after Foundational (Phase 2) - No dependencies on other stories ✅ **MVP Priority**
- **User Story 2 (P2)**: Can start after Foundational (Phase 2) - Extends US1 form but independently testable
- **User Story 3 (P1)**: Can start after Foundational (Phase 2) - Independent calendar visualization ✅ **MVP Priority**
- **User Story 4 (P2)**: Depends on US3 (reuses CalendarMonthView) - Historical extension

### Within Each User Story

**User Story 1 (Quick Check-In Registration)**:
1. T009 (ViewModel) before T010 (View)
2. T010 (RegisterCheckInView) before T011 (Home button integration)
3. T011-T014 can run in parallel (different aspects of same feature)
4. T015-T016 (error handling) after T014 (save logic)

**User Story 2 (Detailed Metrics)**:
- All T017-T021 can run in parallel (independent field additions)

**User Story 3 (Monthly Calendar)**:
1. T022-T024 can run in parallel (different components)
2. T025-T026 (views) depend on T022 (ViewModel)
3. T027-T029 (data/logic) can run in parallel
4. T030 (navigation) after T025-T026 complete

**User Story 4 (Historical Calendar)**:
1. T031 (ViewModel) before T032 (View)
2. T033-T034 (queries) can run in parallel
3. T035-T036 (button/navigation) after T032 complete
4. T037 (optimization) after basic functionality works

### Parallel Opportunities

**Setup Phase (Phase 1)**:
- T002, T003, T004, T005 can all run in parallel (different utility files)

**Foundational Phase (Phase 2)**:
- T007, T008 can run in parallel (different components)

**User Story 1 (Phase 3)**:
- T009, T010 can start in parallel if separate developers

**User Story 2 (Phase 4)**:
- T017, T018 can run in parallel (different fields)

**User Story 3 (Phase 5)**:
- T022, T023, T024 can all run in parallel (different files)
- T027, T028, T029 can run in parallel (different logic aspects)

**User Story 4 (Phase 6)**:
- T033, T034 can run in parallel (different query aspects)

**Polish Phase (Phase 7)**:
- T038, T039, T041, T042, T043, T045, T050 can all run in parallel (different files/aspects)

---

## Parallel Example: User Story 3 (Monthly Calendar)

```bash
# Developer A: ViewModel
git checkout -b feature/005-us3-viewmodel
# Implement T022: CheckInViewModel

# Developer B: Calendar Components (simultaneously)
git checkout -b feature/005-us3-components
# Implement T023: CalendarDayView
# Implement T024: CalendarMonthView

# Developer C: Tab View (after A & B merge)
git checkout -b feature/005-us3-tabview
# Implement T025-T026: CheckInTabView with calendar integration
```

---

## MVP Scope Recommendation

For fastest time-to-value, implement in this order:

**Iteration 1 (MVP - ~6-7 hours)**:
- Phase 1: Setup (T001-T005) - 1 hour
- Phase 2: Foundational (T006-T008) - 1 hour
- Phase 3: User Story 1 (T009-T016) - 3-4 hours
- Phase 5: User Story 3 (T022-T030) - 3-4 hours

**Delivers**: Users can create check-ins with photos and see them in current month calendar

**Iteration 2 (Enhanced - ~3-4 hours)**:
- Phase 4: User Story 2 (T017-T021) - 2 hours
- Phase 6: User Story 4 (T031-T037) - 2-3 hours

**Delivers**: Full detail capture + complete historical view

**Iteration 3 (Polish - ~1-2 hours)**:
- Phase 7: Polish & Testing (T038-T052) - 1-2 hours

**Delivers**: Production-ready feature with all refinements

---

## Task Validation Summary

- **Total Tasks**: 53
- **Setup Tasks**: 5 (Phase 1)
- **Foundational Tasks**: 3 (Phase 2)
- **User Story 1 Tasks**: 8 (Phase 3)
- **User Story 2 Tasks**: 5 (Phase 4)
- **User Story 3 Tasks**: 9 (Phase 5)
- **User Story 4 Tasks**: 7 (Phase 6)
- **Polish Tasks**: 16 (Phase 7)

**Parallel Tasks Identified**: 19 tasks marked with [P]

**Format Validation**: ✅ All tasks follow checklist format (checkbox, ID, optional [P], [Story] label for US phases, description with file path)

**User Story Coverage**:
- ✅ US1: 8 tasks covering form creation, photo handling, validation, save
- ✅ US2: 5 tasks covering optional fields (calories, location, date/time)
- ✅ US3: 9 tasks covering calendar display with photos/icons
- ✅ US4: 7 tasks covering historical month navigation

**Requirement Coverage**: 100% (all 28 FRs covered including FR-027 permissions and FR-028 unsaved changes)

**Independent Test Criteria**: Each user story has clear acceptance tests and can be demonstrated standalone

**MVP Identification**: US1 + US3 marked as 🎯 MVP (minimum viable feature for user value)
