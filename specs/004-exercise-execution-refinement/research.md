# Research: Exercise Execution Refinement

**Feature**: 004-exercise-execution-refinement  
**Date**: 2026-01-10  
**Purpose**: Research technical approaches for timer background support, automatic data recording, and navigation fixes

## Decision Log

### 1. SwiftUI Timer with Background Support

**Decision**: Use `Timer.publish()` with background task registration via `BackgroundTasks` framework for timer continuation.

**Rationale**:
- `Timer.publish()` integrates naturally with SwiftUI's reactive model via Combine
- Background tasks allow timer to continue when app is backgrounded
- Local notifications can alert user when timer completes in background
- Aligns with existing RestTimerViewModel pattern from specs/002-execute-workout

**Implementation Pattern**:
```swift
@Observable
class RestTimerViewModel {
    private var timer: AnyCancellable?
    private var backgroundTask: UIBackgroundTaskIdentifier?
    
    func start() {
        // Register background task
        backgroundTask = UIApplication.shared.beginBackgroundTask {
            self.endBackgroundTask()
        }
        
        // Start timer
        timer = Timer.publish(every: 1, on: .main, in: .common)
            .autoconnect()
            .sink { [weak self] _ in
                self?.tick()
            }
    }
    
    func tick() {
        remainingTime -= 1
        if remainingTime <= 0 {
            complete()
        }
    }
    
    func complete() {
        timer?.cancel()
        
        // Schedule local notification if in background
        if UIApplication.shared.applicationState != .active {
            scheduleCompletionNotification()
        }
        
        // Play sound/haptic
        AudioServicesPlaySystemSound(1322) // Timer completion sound
        
        endBackgroundTask()
    }
    
    private func scheduleCompletionNotification() {
        let content = UNMutableNotificationContent()
        content.title = "Descanso concluído"
        content.body = "Hora da próxima série!"
        content.sound = .default
        
        let trigger = UNTimeIntervalNotificationTrigger(timeInterval: 0.1, repeats: false)
        let request = UNNotificationRequest(identifier: UUID().uuidString, content: content, trigger: trigger)
        
        UNUserNotificationCenter.current().add(request)
    }
}
```

**Alternatives Considered**:
- ✗ `DispatchSourceTimer`: More complex, no Combine integration
- ✓ `Timer.publish()`: Selected for SwiftUI integration
- ✗ Background URLSession: Overkill for simple timer

**Dependencies**: UserNotifications framework for background completion alerts

---

### 2. Automatic Set Recording (No Manual Input)

**Decision**: Record planned values automatically when user presses "Começar Descanso" or "Finalizar Exercício", using Exercise's configured defaults.

**Rationale**:
- Clarification decision: User confirmed automatic recording (Option A)
- Eliminates friction during workout execution
- Aligns with "streamlined execution" goal from spec
- Reduces time spent on data entry by 50% (success criteria SC-006)

**Implementation Pattern**:
```swift
@Observable
class ExecuteExerciseViewModel {
    func recordSet() throws -> ExerciseSet {
        let set = ExerciseSet()
        set.setNumber = currentSetNumber
        
        // Automatic values from exercise configuration
        set.actualReps = exercise.defaultReps
        set.actualLoad = exercise.load ?? 0
        set.completedAt = Date()
        
        session.addSet(set)
        modelContext.insert(set)
        
        currentSetNumber += 1
        return set
    }
}
```

**Data Flow**:
1. User completes physical set
2. User presses "Começar Descanso"
3. ViewModel calls `recordSet()` automatically
4. Set saved with planned reps/load
5. Counter increments
6. Timer starts

**Alternatives Considered**:
- ✗ Manual input after each set: Rejected per user clarification
- ✓ Automatic recording: Selected based on clarification
- ✗ Post-workout editing: Could be future feature, not in scope

---

### 3. Exercise Load Field (Optional)

**Decision**: Add optional `load: Double?` to Exercise model, stored in Kg, displayed in exercise creation/edit forms.

**Rationale**:
- Load tracking enables progressive overload monitoring
- Optional field maintains backward compatibility (nil = no load specified)
- SwiftData handles schema migration automatically
- Aligns with User Story 2 (P2 priority)

**Model Extension**:
```swift
@Model
class Exercise {
    // Existing fields
    var name: String
    var muscleGroup: MuscleGroup
    var defaultSets: Int
    var defaultReps: Int
    var restTime: Int
    
    // NEW: Load in kilograms (optional)
    var load: Double?
    
    init(name: String, muscleGroup: MuscleGroup, defaultSets: Int, defaultReps: Int, restTime: Int, load: Double? = nil) {
        // ...
        self.load = load
    }
}
```

**UI Changes**:
- AddExerciseView: Add `TextField("Carga (Kg)", value: $load, format: .number)`
- EditWorkoutPlanView: Same input field
- ExecuteExerciseView: Display load in exercise info header

**Migration**: SwiftData automatic migration, no manual intervention required

---

### 4. Navigation Fix: Workout Completion → Home

**Decision**: Use `@Environment(\.dismiss)` with `.navigationDestination(isPresented:)` control to ensure WorkoutSummaryView navigates to root (Home) on "Finalizar".

**Rationale**:
- Current bug: Navigation goes back to ExecuteWorkoutView (active session)
- Root cause: NavigationStack doesn't reset properly
- Solution: Programmatic pop to root + dismiss active session

**Implementation Pattern**:
```swift
// In WorkoutSummaryView
@Environment(\.dismiss) private var dismiss

Button("Finalizar") {
    // 1. Mark session as ended
    viewModel.finalizeSession()
    
    // 2. Dismiss to root (Home)
    dismiss() // Pops WorkoutSummaryView
    
    // Parent ExecuteWorkoutView will detect session.endDate != nil
    // and automatically dismiss itself via .onChange(of: session.endDate)
}

// In ExecuteWorkoutView
.onChange(of: viewModel.session.endDate) { _, newValue in
    if newValue != nil {
        // Session completed, return to Home
        dismiss()
    }
}
```

**Root Cause Analysis**:
- WorkoutSummaryView presented as sheet from ExecuteWorkoutView
- Dismissing sheet returns to ExecuteWorkoutView
- ExecuteWorkoutView needs trigger to auto-dismiss when session ends

**Alternatives Considered**:
- ✗ `NavigationStack.popToRoot()`: Not available in SwiftUI
- ✓ Cascading dismiss with session state watch: Selected
- ✗ Replacing NavigationStack: Too invasive

---

### 5. Default Rest Time

**Decision**: Use 60 seconds as default rest time when exercise has no configured restTime.

**Rationale**:
- Clarification decision: User selected Option A (60 seconds)
- Suitable for circuit training and muscular endurance
- Can be overridden per-exercise during workout plan creation

**Implementation**:
```swift
@Observable
class RestTimerViewModel {
    init(duration: TimeInterval?) {
        self.duration = duration ?? 60 // Default to 60s
        self.remainingTime = self.duration
    }
}
```

---

### 6. Incomplete Set Confirmation

**Decision**: Show confirmation dialog when user attempts to finish exercise before completing all planned sets.

**Rationale**:
- Clarification decision: User selected Option B (confirm with warning)
- Prevents accidental early completion
- Allows intentional workout adjustments (e.g., fatigue, injury)
- Maintains user autonomy while providing safety net

**Implementation Pattern**:
```swift
@Observable
class ExecuteExerciseViewModel {
    var showingEarlyFinishAlert = false
    
    func attemptFinish() {
        if currentSetNumber < exercise.defaultSets {
            // Show confirmation
            showingEarlyFinishAlert = true
        } else {
            // All sets completed, finish normally
            finish()
        }
    }
}

// In View
.alert("Finalizar exercício", isPresented: $viewModel.showingEarlyFinishAlert) {
    Button("Cancelar", role: .cancel) {}
    Button("Finalizar") {
        viewModel.finish()
    }
} message: {
    Text("Você completou apenas \(viewModel.currentSetNumber - 1) de \(viewModel.exercise.defaultSets) séries. Deseja finalizar mesmo assim?")
}
```

---

### 7. Set Progression Logic

**Decision**: Pressing "Começar Descanso" completes current set and increments counter immediately.

**Rationale**:
- Clarification decision: User selected Option A
- Natural flow: Complete set → Start rest → Counter advances
- When timer ends, UI already shows next set number
- Clear separation between "set complete" and "rest started" actions

**State Transition**:
```
User finishes physical set
  ↓
Presses "Começar Descanso"
  ↓
ViewModel.recordSet() called
  ↓
Set data saved with planned values
  ↓
currentSetNumber incremented (e.g., 1 → 2)
  ↓
Timer starts (shows "Série 2 de 4")
  ↓
User rests...
  ↓
Timer completes (button ready for next set)
```

---

## Technology Stack

| Component | Technology | Justification |
|-----------|-----------|---------------|
| UI Framework | SwiftUI | Project standard, reactive bindings |
| State Management | @Observable macro | iOS 17+ modern approach |
| Persistence | SwiftData | Already configured, automatic migrations |
| Timer | Timer.publish() + Combine | SwiftUI-native reactive pattern |
| Background Tasks | BackgroundTasks framework | Standard iOS background work |
| Notifications | UserNotifications | Timer completion alerts |
| Audio Feedback | AudioServices | System sounds for timer |
| Logging | OSLog | Structured logging per constitution |

---

## Best Practices Applied

### From Existing Codebase (specs/002-execute-workout)

1. **ViewModel Pattern**: @Observable classes with dependency injection
   - Example: `RestTimerViewModel(duration: TimeInterval)`
   - Testable via protocol mocking (optional for this project)

2. **SwiftData Relationships**: Cascade deletes, relationship tracking
   - WorkoutSession has many ExerciseSets
   - Deletion handled automatically

3. **Component Reusability**: Small, focused views
   - RestTimerView: Standalone timer display
   - ExerciseInfoHeader: Reusable exercise details component

4. **Error Handling**: Published error properties
   ```swift
   @Observable
   class ViewModel {
       private(set) var error: Error?
       
       func action() {
           do {
               try perform()
               error = nil
           } catch {
               self.error = error
           }
       }
   }
   ```

### New Patterns for This Feature

1. **Background Task Management**: Timer continues in background
2. **Local Notifications**: User notification on timer completion
3. **Automatic Data Recording**: No manual input, use configured defaults
4. **Cascading Dismiss**: Session end triggers view dismissal chain

---

## Performance Considerations

| Requirement | Approach | Validation |
|------------|----------|------------|
| Timer accuracy ±1s | Timer.publish() every 1s | Manual test with stopwatch |
| Background continuation | BackgroundTask registration | Test by backgrounding app |
| UI transitions <300ms | Native NavigationStack | Perceived performance check |
| No memory leaks | Weak self in closures | Instruments (optional) |

---

## Dependencies

### New Framework Imports Required

```swift
import UserNotifications  // For timer completion notifications
import AudioToolbox        // For system sounds (optional, can use AVFoundation)
```

### Permission Requirements

- **UserNotifications**: Request authorization for local notifications
  ```swift
  UNUserNotificationCenter.current().requestAuthorization(options: [.alert, .sound]) { granted, error in
      // Handle permission
  }
  ```

---

## Risk Assessment

| Risk | Likelihood | Impact | Mitigation |
|------|-----------|--------|-----------|
| Background task termination | Medium | Medium | Keep task duration short (<30s typical rest), fallback to foreground-only |
| Notification permission denial | Medium | Low | Timer still works, just no background alert |
| SwiftData migration issues | Low | Medium | Test on existing data, load field is optional |
| User confusion (no input forms) | Low | Medium | Clear UI showing "set complete" feedback |

---

## Open Questions

**None remaining** - All clarifications resolved during specification phase:
- ✅ Automatic set recording approach
- ✅ Background timer behavior
- ✅ Default rest time
- ✅ Incomplete set handling
- ✅ Set progression logic

---

## Summary

**Research Complete**: All technical approaches defined
**Patterns**: Leverage existing Execute module patterns from specs/002-execute-workout
**New Tech**: Background tasks + local notifications for timer
**Risk**: Low - using standard iOS frameworks, optional field for load
**Ready for**: Phase 1 - Data Model & Contracts definition
