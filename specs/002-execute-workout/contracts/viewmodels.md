# ViewModel Contracts: Executar Treino

**Feature**: 002-execute-workout  
**Date**: 2026-01-07  
**Purpose**: Definir interfaces públicas dos ViewModels

## Overview

Este documento define os contratos (propriedades públicas, métodos e estados) dos ViewModels responsáveis pela execução de treinos. Cada ViewModel é observável (@Observable) e segue MVVM pattern.

---

## WorkoutSessionViewModel

**Responsibility**: Gerenciar estado de uma sessão de treino ativa

### Public Interface

#### Published Properties

```swift
@Observable
class WorkoutSessionViewModel {
    // Session state
    private(set) var session: WorkoutSession
    private(set) var exercises: [Exercise] = []
    
    // UI state
    private(set) var currentExerciseIndex: Int?
    private(set) var completedExercises: Set<UUID> = []
    
    // Computed
    var progressPercentage: Double {
        guard !exercises.isEmpty else { return 0 }
        return Double(completedExercises.count) / Double(exercises.count)
    }
    
    var progressText: String {
        "\(completedExercises.count)/\(exercises.count) exercícios completos"
    }
    
    var isSessionActive: Bool {
        session.endDate == nil
    }
}
```

#### Methods

```swift
// Initialization
init(workoutPlan: WorkoutPlan, modelContext: ModelContext)

// Session management
func startSession() throws
func finalizeSession() throws
func resumeSession(_ existingSession: WorkoutSession)

// Exercise navigation
func selectExercise(_ exercise: Exercise)
func markExerciseComplete(_ exercise: Exercise)

// Query
func isExerciseComplete(_ exercise: Exercise) -> Bool
func exerciseStatus(_ exercise: Exercise) -> ExerciseStatus

// State
enum ExerciseStatus {
    case pending
    case inProgress
    case completed
}
```

### States

```swift
enum SessionState {
    case notStarted
    case active(WorkoutSession)
    case completing
    case completed(summary: SessionSummary)
    case error(SessionError)
}

enum SessionError: Error, LocalizedError {
    case sessionAlreadyExists
    case invalidWorkoutPlan
    case persistenceError(Error)
}
```

### Events

```swift
// Emitted via Combine publishers
var sessionStarted: AnyPublisher<WorkoutSession, Never>
var sessionFinalized: AnyPublisher<SessionSummary, Never>
var exerciseCompleted: AnyPublisher<Exercise, Never>
```

### Usage Example

```swift
// In ExecuteWorkoutView
@State private var viewModel: WorkoutSessionViewModel

init(workoutPlan: WorkoutPlan) {
    _viewModel = State(wrappedValue: WorkoutSessionViewModel(
        workoutPlan: workoutPlan,
        modelContext: modelContext
    ))
}

var body: some View {
    VStack {
        Text(viewModel.progressText)
        
        List(viewModel.exercises) { exercise in
            ExerciseRow(exercise: exercise, status: viewModel.exerciseStatus(exercise))
                .onTapGesture {
                    viewModel.selectExercise(exercise)
                }
        }
    }
    .onAppear {
        try? viewModel.startSession()
    }
}
```

---

## ExecuteExerciseViewModel

**Responsibility**: Gerenciar registro de séries para um exercício específico

### Public Interface

#### Published Properties

```swift
@Observable
class ExecuteExerciseViewModel {
    // Exercise context
    private(set) var exercise: Exercise
    private(set) var session: WorkoutSession
    
    // Input state
    var weightText: String = ""
    var repsText: String = ""
    
    // Validation
    private(set) var weightError: String?
    private(set) var repsError: String?
    
    // Series tracking
    private(set) var completedSets: [ExerciseSet] = []
    private(set) var currentSetNumber: Int = 1
    
    // Last workout reference
    private(set) var lastWorkoutData: LastWorkoutData?
    
    // Computed
    var isFormValid: Bool {
        weightError == nil && repsError == nil && !repsText.isEmpty
    }
    
    var progressText: String {
        "Série \(currentSetNumber) de \(exercise.defaultSets)"
    }
    
    var hasReachedDefaultSets: Bool {
        completedSets.count >= exercise.defaultSets
    }
}
```

#### Methods

```swift
// Initialization
init(exercise: Exercise, session: WorkoutSession, modelContext: ModelContext)

// Input validation (real-time)
func validateWeight()  // Updates weightError
func validateReps()    // Updates repsError

// Set management
func recordSet() throws -> ExerciseSet
func clearInputs()

// Completion
func markExerciseComplete()

// Query
func fetchLastWorkoutData()

struct LastWorkoutData {
    let weight: Double?
    let reps: Int
    let date: Date
    
    var formattedText: String {
        let weightStr = weight.map { String(format: "%.1f kg", $0) } ?? "Peso corporal"
        return "Último: \(weightStr) × \(reps) reps"
    }
}
```

### States

```swift
enum SetRecordingState {
    case idle
    case validating
    case recording
    case recorded(ExerciseSet)
    case error(SetRecordingError)
}

enum SetRecordingError: Error, LocalizedError {
    case invalidWeight
    case invalidReps
    case persistenceError(Error)
}
```

### Validation Rules

```swift
// Weight validation
func validateWeight() {
    guard !weightText.isEmpty else {
        weightError = nil  // Empty is valid (bodyweight)
        return
    }
    
    guard let weight = Double(weightText), weight > 0 else {
        weightError = "Peso deve ser positivo"
        return
    }
    
    weightError = nil
}

// Reps validation
func validateReps() {
    guard let reps = Int(repsText), reps > 0 else {
        repsError = "Repetições devem ser maior que zero"
        return
    }
    
    repsError = nil
}
```

### Usage Example

```swift
// In ExecuteExerciseView
@State private var viewModel: ExecuteExerciseViewModel

var body: some View {
    Form {
        if let lastData = viewModel.lastWorkoutData {
            Text(lastData.formattedText)
                .foregroundColor(.secondary)
        }
        
        TextField("Peso (kg)", text: $viewModel.weightText)
            .keyboardType(.decimalPad)
            .onChange(of: viewModel.weightText) {
                viewModel.validateWeight()
            }
            .border(viewModel.weightError != nil ? .red : .clear, width: 2)
        
        if let error = viewModel.weightError {
            Text(error)
                .font(.caption)
                .foregroundColor(.red)
        }
        
        Button("Concluir Série") {
            try? viewModel.recordSet()
        }
        .disabled(!viewModel.isFormValid)
    }
}
```

---

## RestTimerViewModel

**Responsibility**: Gerenciar timer de descanso entre séries

### Public Interface

#### Published Properties

```swift
@Observable
class RestTimerViewModel {
    // Timer state
    private(set) var duration: TimeInterval
    private(set) var remainingTime: TimeInterval
    private(set) var isRunning: Bool = false
    private(set) var isPaused: Bool = false
    
    // Computed
    var progress: Double {
        1.0 - (remainingTime / duration)
    }
    
    var formattedTime: String {
        let minutes = Int(remainingTime) / 60
        let seconds = Int(remainingTime) % 60
        return String(format: "%02d:%02d", minutes, seconds)
    }
    
    var isComplete: Bool {
        remainingTime <= 0
    }
}
```

#### Methods

```swift
// Initialization
init(duration: TimeInterval)

// Timer control
func start()
func pause()
func resume()
func skip()
func reset()

// Background support
func enterBackground()
func enterForeground()
```

### States

```swift
enum TimerState {
    case idle
    case running(startTime: Date)
    case paused(pauseTime: Date, elapsedTime: TimeInterval)
    case completed
}
```

### Events

```swift
// Emitted when timer completes
var timerCompleted: AnyPublisher<Void, Never>

// For haptic/audio feedback
var shouldTriggerFeedback: AnyPublisher<Void, Never>
```

### Background Handling

```swift
private var backgroundTask: UIBackgroundTaskIdentifier?

func enterBackground() {
    backgroundTask = UIApplication.shared.beginBackgroundTask {
        [weak self] in
        self?.pause()
    }
}

func enterForeground() {
    if let task = backgroundTask, task != .invalid {
        UIApplication.shared.endBackgroundTask(task)
        backgroundTask = nil
    }
}
```

### Usage Example

```swift
// In RestTimerView
@State private var viewModel: RestTimerViewModel

init(restTime: Int) {
    _viewModel = State(wrappedValue: RestTimerViewModel(
        duration: TimeInterval(restTime)
    ))
}

var body: some View {
    ZStack {
        ProgressRing(progress: viewModel.progress)
        
        Text(viewModel.formattedTime)
            .font(.largeTitle.monospacedDigit())
        
        HStack {
            Button(viewModel.isPaused ? "Resume" : "Pause") {
                viewModel.isPaused ? viewModel.resume() : viewModel.pause()
            }
            
            Button("Skip") {
                viewModel.skip()
            }
        }
    }
    .onAppear {
        viewModel.start()
    }
    .onReceive(viewModel.timerCompleted) {
        // Trigger haptic and audio
        HapticFeedback.shared.timerCompleted()
        AudioFeedback.playTimerComplete()
    }
}
```

---

## WorkoutSummaryViewModel

**Responsibility**: Calcular e apresentar resumo da sessão finalizada

### Public Interface

#### Published Properties

```swift
@Observable
class WorkoutSummaryViewModel {
    private(set) var session: WorkoutSession
    
    // Summary data
    private(set) var duration: TimeInterval
    private(set) var completedExercisesCount: Int
    private(set) var totalSets: Int
    private(set) var totalReps: Int
    
    // Computed
    var formattedDuration: String {
        let hours = Int(duration) / 3600
        let minutes = Int(duration) / 60 % 60
        if hours > 0 {
            return "\(hours)h \(minutes)min"
        }
        return "\(minutes)min"
    }
}
```

#### Methods

```swift
// Initialization
init(session: WorkoutSession)

// Calculations (performed on init)
private func calculateSummary()

// Sharing (future feature)
func shareWorkout() -> String
```

### Calculations

```swift
private func calculateSummary() {
    duration = session.duration ?? 0
    completedExercisesCount = session.completedExercises.count
    totalSets = session.totalSets
    totalReps = session.totalReps
}
```

### Usage Example

```swift
// In WorkoutSummaryView
@State private var viewModel: WorkoutSummaryViewModel

var body: some View {
    List {
        Section("Resumo") {
            SummaryRow(title: "Duração", value: viewModel.formattedDuration)
            SummaryRow(title: "Exercícios", value: "\(viewModel.completedExercisesCount)")
            SummaryRow(title: "Séries", value: "\(viewModel.totalSets)")
            SummaryRow(title: "Repetições", value: "\(viewModel.totalReps)")
        }
    }
}
```

---

## Dependency Injection

All ViewModels receive dependencies via initializer:

```swift
// ModelContext for SwiftData
init(..., modelContext: ModelContext)

// Domain models
init(workoutPlan: WorkoutPlan, ...)
init(exercise: Exercise, session: WorkoutSession, ...)

// Configuration
init(duration: TimeInterval)
```

**Testability**: Mock ModelContext via protocol for unit tests

```swift
protocol ModelContextProtocol {
    func insert(_ model: any PersistentModel)
    func delete(_ model: any PersistentModel)
    func fetch<T>(_ descriptor: FetchDescriptor<T>) throws -> [T]
}

// In tests, inject MockModelContext
class MockModelContext: ModelContextProtocol { ... }
```

---

## Error Handling

All ViewModels expose errors via published properties or throws:

```swift
@Observable
class SomeViewModel {
    private(set) var error: Error?
    
    func someAction() {
        do {
            try performAction()
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

**ViewModels Defined**: 4
- WorkoutSessionViewModel (session orchestration)
- ExecuteExerciseViewModel (set recording)
- RestTimerViewModel (timer management)
- WorkoutSummaryViewModel (summary calculation)

**Key Patterns**:
- @Observable for state management
- Dependency injection for testability
- Validation in real-time (computed properties)
- Combine publishers for events
- Error handling via published properties

All interfaces defined. Ready for implementation.
