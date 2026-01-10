# ViewModel Contracts: Exercise Execution Refinement

**Feature**: 004-exercise-execution-refinement  
**Date**: 2026-01-10  
**Purpose**: Define ViewModel interfaces for refactored exercise execution

## Overview

This feature refactors 4 existing ViewModels:

1. **ExecuteExerciseViewModel** - Remove input forms, add automatic recording
2. **RestTimerViewModel** - Add background support and notifications
3. **WorkoutSessionViewModel** - Update navigation logic
4. **WorkoutSummaryViewModel** - Fix navigation to Home

All ViewModels use `@Observable` macro for state management (iOS 17+).

---

## ExecuteExerciseViewModel (REFACTOR)

**Responsibility**: Manage exercise set completion without manual input forms

### Public Interface

#### Published Properties

```swift
@Observable
class ExecuteExerciseViewModel {
    // Exercise context
    private(set) var exercise: Exercise
    private(set) var session: WorkoutSession
    
    // Set tracking
    private(set) var completedSets: [ExerciseSet] = []
    private(set) var currentSetNumber: Int = 1
    
    // Alert state
    var showingEarlyFinishAlert = false
    
    // Computed properties
    var isLastSet: Bool {
        currentSetNumber >= exercise.defaultSets
    }
    
    var progressText: String {
        "Série \(currentSetNumber) de \(exercise.defaultSets)"
    }
    
    var setsRemaining: Int {
        max(0, exercise.defaultSets - (currentSetNumber - 1))
    }
}
```

#### Methods

```swift
// Initialization
init(exercise: Exercise, session: WorkoutSession, modelContext: ModelContext)

// Set management (automatic recording)
func recordSet() throws -> ExerciseSet

// Exercise completion
func attemptFinish()
func finish()

// Helpers
func canFinish() -> Bool
```

### Implementation Details

#### Automatic Set Recording

```swift
func recordSet() throws -> ExerciseSet {
    let set = ExerciseSet(
        setNumber: currentSetNumber,
        weight: exercise.load,          // Automatic from Exercise
        reps: exercise.defaultReps,     // Automatic from Exercise
        completedDate: Date()
    )
    
    set.exercise = exercise
    set.session = session
    
    modelContext.insert(set)
    session.sets.append(set)
    
    completedSets.append(set)
    currentSetNumber += 1
    
    return set
}
```

#### Early Finish with Confirmation

```swift
func attemptFinish() {
    if currentSetNumber < exercise.defaultSets {
        // Show alert: "Você completou apenas X de Y séries"
        showingEarlyFinishAlert = true
    } else {
        finish()
    }
}

func finish() {
    // Exercise marked complete (handled by parent ViewModel)
    // View dismissed
}
```

### Changes from Current Implementation

| Aspect | Before | After |
|--------|--------|-------|
| Input forms | TextField for reps/weight | No input forms |
| Set recording | Manual button press with validation | Automatic on "Começar Descanso" |
| Data source | User input | Exercise defaults |
| Validation | Real-time input validation | Pre-validated defaults |

### Usage Example

```swift
// In ExecuteExerciseView
@State private var viewModel: ExecuteExerciseViewModel

init(exercise: Exercise, session: WorkoutSession) {
    _viewModel = State(wrappedValue: ExecuteExerciseViewModel(
        exercise: exercise,
        session: session,
        modelContext: modelContext
    ))
}

var body: some View {
    VStack {
        // Exercise info header (name, muscle group, sets, reps, load)
        ExerciseInfoHeader(exercise: exercise)
        
        Spacer()
        
        // Progress indicator
        Text(viewModel.progressText)
        
        Spacer()
        
        // Timer (if running) - managed separately
        if timerRunning {
            RestTimerView(...)
        }
        
        Spacer()
        
        // Action button
        if viewModel.isLastSet {
            Button("Finalizar Exercício") {
                viewModel.attemptFinish()
            }
        } else {
            Button("Começar Descanso") {
                // Record set automatically
                try? viewModel.recordSet()
                // Start timer
                startRestTimer()
            }
        }
    }
    .alert("Finalizar exercício", isPresented: $viewModel.showingEarlyFinishAlert) {
        Button("Cancelar", role: .cancel) {}
        Button("Finalizar") {
            viewModel.finish()
            dismiss()
        }
    } message: {
        Text("Você completou apenas \(viewModel.currentSetNumber - 1) de \(viewModel.exercise.defaultSets) séries. Deseja finalizar mesmo assim?")
    }
}
```

---

## RestTimerViewModel (REFACTOR)

**Responsibility**: Manage countdown timer with background support and notifications

### Public Interface

#### Published Properties

```swift
@Observable
class RestTimerViewModel {
    // Timer configuration
    private(set) var duration: TimeInterval
    
    // Timer state
    private(set) var remainingTime: TimeInterval
    private(set) var isRunning = false
    private(set) var isCompleted = false
    
    // Computed properties
    var progress: Double {
        guard duration > 0 else { return 0 }
        return 1.0 - (remainingTime / duration)
    }
    
    var formattedTime: String {
        let minutes = Int(remainingTime) / 60
        let seconds = Int(remainingTime) % 60
        return String(format: "%d:%02d", minutes, seconds)
    }
}
```

#### Methods

```swift
// Initialization
init(duration: TimeInterval?)  // nil = use default 60s

// Timer control
func start()
func pause()
func resume()
func stop()
func reset()

// Background support (internal)
private func registerBackgroundTask()
private func scheduleCompletionNotification()
private func endBackgroundTask()
```

### Implementation Details

#### Background Task Support

```swift
import UserNotifications
import AudioToolbox

@Observable
class RestTimerViewModel {
    private var timer: AnyCancellable?
    private var backgroundTask: UIBackgroundTaskIdentifier?
    
    func start() {
        isRunning = true
        isCompleted = false
        
        // Register background task
        backgroundTask = UIApplication.shared.beginBackgroundTask { [weak self] in
            self?.endBackgroundTask()
        }
        
        // Start timer
        timer = Timer.publish(every: 1, on: .main, in: .common)
            .autoconnect()
            .sink { [weak self] _ in
                self?.tick()
            }
    }
    
    private func tick() {
        guard remainingTime > 0 else {
            complete()
            return
        }
        remainingTime -= 1
    }
    
    private func complete() {
        isRunning = false
        isCompleted = true
        timer?.cancel()
        
        // Sound/haptic
        AudioServicesPlaySystemSound(1322)
        
        // Notification if backgrounded
        if UIApplication.shared.applicationState != .active {
            scheduleCompletionNotification()
        }
        
        endBackgroundTask()
    }
    
    private func scheduleCompletionNotification() {
        let content = UNMutableNotificationContent()
        content.title = "Descanso concluído"
        content.body = "Hora da próxima série!"
        content.sound = .default
        
        let trigger = UNTimeIntervalNotificationTrigger(timeInterval: 0.1, repeats: false)
        let request = UNNotificationRequest(
            identifier: UUID().uuidString,
            content: content,
            trigger: trigger
        )
        
        UNUserNotificationCenter.current().add(request)
    }
    
    private func endBackgroundTask() {
        if let task = backgroundTask {
            UIApplication.shared.endBackgroundTask(task)
            backgroundTask = nil
        }
    }
}
```

#### Default Rest Time

```swift
init(duration: TimeInterval? = nil) {
    self.duration = duration ?? 60  // Default to 60 seconds
    self.remainingTime = self.duration
}
```

### Changes from Current Implementation

| Aspect | Before | After |
|--------|--------|-------|
| Background | Pauses or undefined | Continues with background task |
| Notification | None | Local notification on completion |
| Default time | Configurable only | Default 60s if not specified |
| State management | Basic | Enhanced with pause/resume |

### Usage Example

```swift
// In ExecuteExerciseView
@State private var timerViewModel: RestTimerViewModel?

func startRestTimer() {
    timerViewModel = RestTimerViewModel(duration: TimeInterval(exercise.defaultRestTime))
    timerViewModel?.start()
}

var body: some View {
    VStack {
        if let timer = timerViewModel, timer.isRunning {
            VStack {
                // Circular progress
                CircularProgressView(progress: timer.progress)
                    .frame(width: 150, height: 150)
                
                // Time display
                Text(timer.formattedTime)
                    .font(.system(size: 48, weight: .bold, design: .monospaced))
            }
        }
    }
    .onAppear {
        // Request notification permission once
        UNUserNotificationCenter.current().requestAuthorization(options: [.alert, .sound]) { _, _ in }
    }
}
```

---

## WorkoutSessionViewModel (MODIFY)

**Responsibility**: Orchestrate workout session with proper navigation handling

### Public Interface (Minimal Changes)

#### Published Properties

```swift
@Observable
class WorkoutSessionViewModel {
    // Session state (existing)
    private(set) var session: WorkoutSession
    private(set) var exercises: [Exercise] = []
    private(set) var completedExercises: Set<UUID> = []
    
    // NEW: Navigation coordination
    var shouldDismissAfterCompletion = false
}
```

#### Methods

```swift
// Existing methods (no changes)
init(workoutPlan: WorkoutPlan, modelContext: ModelContext)
func startSession() throws
func markExerciseComplete(_ exercise: Exercise)

// MODIFIED: Now sets shouldDismissAfterCompletion flag
func finalizeSession() throws
```

### Implementation Details

#### Session Finalization with Navigation Flag

```swift
func finalizeSession() throws {
    guard session.endDate == nil else {
        throw SessionError.sessionAlreadyEnded
    }
    
    session.endDate = Date()
    
    // Signal to view that navigation should occur
    shouldDismissAfterCompletion = true
    
    // SwiftData auto-saves
}
```

### Usage Example

```swift
// In ExecuteWorkoutView
@State private var viewModel: WorkoutSessionViewModel

var body: some View {
    // ... existing UI ...
    
    .onChange(of: viewModel.session.endDate) { _, newValue in
        if newValue != nil {
            // Session completed, dismiss to Home
            dismiss()
        }
    }
}
```

---

## WorkoutSummaryViewModel (MODIFY)

**Responsibility**: Display session summary and handle navigation to Home

### Public Interface

#### Published Properties (No Changes)

```swift
@Observable
class WorkoutSummaryViewModel {
    private(set) var session: WorkoutSession
    private(set) var duration: TimeInterval
    private(set) var completedExercisesCount: Int
    private(set) var totalSets: Int
    private(set) var totalReps: Int
    
    var formattedDuration: String {
        let hours = Int(duration) / 3600
        let minutes = Int(duration) / 60 % 60
        return hours > 0 ? "\(hours)h \(minutes)min" : "\(minutes)min"
    }
}
```

#### Methods (No Changes to Logic)

```swift
init(session: WorkoutSession)
private func calculateSummary()
```

### Usage Example (View Change Only)

```swift
// In WorkoutSummaryView
@State private var viewModel: WorkoutSummaryViewModel
@Environment(\.dismiss) private var dismiss

var body: some View {
    VStack {
        // Summary stats (unchanged)
        Text("Treino Concluído!")
        Text(viewModel.formattedDuration)
        // ...
        
        // MODIFIED: Dismiss button behavior
        PrimaryButton("Finalizar") {
            // Session already finalized by WorkoutSessionViewModel
            // Just dismiss to Home
            dismiss()
        }
    }
    .navigationBarBackButtonHidden(true)
}

// In ExecuteWorkoutView (parent)
.sheet(isPresented: $showingSummary) {
    NavigationStack {
        WorkoutSummaryView(session: viewModel.session)
    }
}
.onChange(of: viewModel.session.endDate) { _, newValue in
    if newValue != nil {
        // Auto-dismiss ExecuteWorkoutView after summary dismissed
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
            dismiss()
        }
    }
}
```

---

## AddExerciseViewModel (MODIFY)

**Responsibility**: Handle exercise creation with optional load field

### Public Interface

#### Published Properties

```swift
@Observable
class AddExerciseViewModel {
    // Existing fields
    var name: String = ""
    var selectedMuscleGroup: MuscleGroup = .glutes
    var defaultSets: String = "3"
    var defaultReps: String = "12"
    var defaultRestTime: String = "60"
    
    // NEW: Load field
    var loadText: String = ""
    
    // Validation
    private(set) var nameError: String?
    private(set) var loadError: String?
    
    var isFormValid: Bool {
        !name.isEmpty && loadError == nil
    }
}
```

#### Methods

```swift
// Existing
init(workoutPlan: WorkoutPlan, modelContext: ModelContext)
func validateInputs()

// MODIFIED: Include load in exercise creation
func saveExercise() throws -> Exercise
```

### Implementation Details

#### Load Parsing and Validation

```swift
func validateInputs() {
    // Existing validations...
    
    // NEW: Validate load
    if !loadText.isEmpty {
        if let load = Double(loadText.replacingOccurrences(of: ",", with: ".")), load > 0 {
            loadError = nil
        } else {
            loadError = "Carga deve ser um número maior que 0"
        }
    } else {
        loadError = nil  // Optional field
    }
}

func saveExercise() throws -> Exercise {
    validateInputs()
    guard isFormValid else { throw ValidationError.invalidForm }
    
    let parsedSets = Int(defaultSets) ?? 3
    let parsedReps = Int(defaultReps) ?? 12
    let parsedRest = Int(defaultRestTime) ?? 60
    
    // NEW: Parse optional load
    let parsedLoad: Double? = loadText.isEmpty ? nil : Double(loadText.replacingOccurrences(of: ",", with: "."))
    
    let exercise = Exercise(
        name: name,
        muscleGroup: selectedMuscleGroup,
        defaultSets: parsedSets,
        defaultReps: parsedReps,
        defaultRestTime: parsedRest,
        order: workoutPlan.exercises.count,
        load: parsedLoad  // NEW parameter
    )
    
    exercise.workoutPlan = workoutPlan
    modelContext.insert(exercise)
    
    return exercise
}
```

---

## Dependency Injection

All ViewModels receive dependencies via initializer:

```swift
// ModelContext for SwiftData
init(..., modelContext: ModelContext)

// Domain models
init(exercise: Exercise, session: WorkoutSession, ...)

// Configuration
init(duration: TimeInterval? = nil)
```

---

## Error Handling

All ViewModels expose errors via published properties:

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

// In View
.alert(item: $viewModel.error) { error in
    Alert(title: Text("Erro"), message: Text(error.localizedDescription))
}
```

---

## Summary

**ViewModels Modified**: 5
- ExecuteExerciseViewModel (remove forms, automatic recording)
- RestTimerViewModel (background support, notifications)
- WorkoutSessionViewModel (navigation coordination)
- WorkoutSummaryViewModel (no logic changes, view usage updated)
- AddExerciseViewModel (load field support)

**Key Changes**:
- Automatic set recording (no manual input)
- Background timer with notifications
- Cascading dismiss on session completion
- Optional load field for exercises

**Dependencies**:
- UserNotifications framework
- AudioToolbox (or AVFoundation)
- BackgroundTasks implicit via UIApplication

All interfaces defined. Ready for View contracts.
