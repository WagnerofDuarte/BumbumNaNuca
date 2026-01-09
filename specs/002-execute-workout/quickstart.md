# Quickstart Guide: Executar Treino

**Feature**: 002-execute-workout  
**Date**: 2026-01-07  
**Audience**: Developers implementing this feature

## Overview

This guide provides step-by-step instructions for implementing the "Execute Workout" feature from scratch. Follow the phases in order.

**Estimated Time**: 2-3 days for full implementation + tests

---

## Prerequisites

✅ Ensure these are complete before starting:
- [ ] Phase 0 research completed (research.md)
- [ ] Data model designed (data-model.md)
- [ ] View contracts defined (contracts/views.md, contracts/viewmodels.md)
- [ ] WorkoutPlan and Exercise models exist and are working
- [ ] Xcode project configured for iOS 17.0+

---

## Phase 1: Data Layer (2-3 hours)

### Step 1.1: Create SwiftData Models

**File**: `BumbumNaNuca/Models/WorkoutSession.swift`

```swift
import Foundation
import SwiftData

@Model
final class WorkoutSession {
    @Attribute(.unique) var id: UUID
    var startDate: Date
    var endDate: Date?
    var isCompleted: Bool
    var notes: String
    
    @Relationship(deleteRule: .nullify, inverse: \WorkoutPlan.sessions)
    var workoutPlan: WorkoutPlan?
    
    @Relationship(deleteRule: .cascade)
    var exerciseSets: [ExerciseSet]
    
    init(
        id: UUID = UUID(),
        startDate: Date = Date(),
        endDate: Date? = nil,
        isCompleted: Bool = false,
        notes: String = "",
        workoutPlan: WorkoutPlan? = nil
    ) {
        self.id = id
        self.startDate = startDate
        self.endDate = endDate
        self.isCompleted = isCompleted
        self.notes = notes
        self.workoutPlan = workoutPlan
        self.exerciseSets = []
    }
    
    // Computed properties from data-model.md
    var duration: TimeInterval? {
        guard let end = endDate else { return nil }
        return end.timeIntervalSince(startDate)
    }
    
    var totalSets: Int {
        exerciseSets.count
    }
    
    var totalReps: Int {
        exerciseSets.reduce(0) { $0 + $1.reps }
    }
    
    var completedExercises: Set<UUID> {
        Set(exerciseSets.compactMap { $0.exercise?.id })
    }
}
```

**File**: `BumbumNaNuca/Models/ExerciseSet.swift`

```swift
import Foundation
import SwiftData

@Model
final class ExerciseSet {
    @Attribute(.unique) var id: UUID
    var setNumber: Int
    var weight: Double?  // nil = bodyweight
    var reps: Int
    var completedDate: Date
    var notes: String
    
    @Relationship(deleteRule: .nullify)
    var exercise: Exercise?
    
    @Relationship(deleteRule: .nullify, inverse: \WorkoutSession.exerciseSets)
    var session: WorkoutSession?
    
    init(
        id: UUID = UUID(),
        setNumber: Int,
        weight: Double? = nil,
        reps: Int,
        completedDate: Date = Date(),
        notes: String = "",
        exercise: Exercise? = nil,
        session: WorkoutSession? = nil
    ) {
        self.id = id
        self.setNumber = setNumber
        self.weight = weight
        self.reps = reps
        self.completedDate = completedDate
        self.notes = notes
        self.exercise = exercise
        self.session = session
    }
    
    var formattedWeight: String {
        guard let w = weight else { return "Peso corporal" }
        return String(format: "%.1f kg", w)
    }
}
```

### Step 1.2: Extend Exercise Model

**File**: `BumbumNaNuca/Models/Exercise.swift` (ADD these properties)

```swift
// Add to existing Exercise model
var defaultSets: Int = 3
var defaultReps: Int = 12
var defaultRestTime: Int = 60  // seconds

// Update init to include new properties
init(..., defaultSets: Int = 3, defaultReps: Int = 12, defaultRestTime: Int = 60) {
    // ... existing init
    self.defaultSets = defaultSets
    self.defaultReps = defaultReps
    self.defaultRestTime = defaultRestTime
}
```

### Step 1.3: Extend WorkoutPlan Model

**File**: `BumbumNaNuca/Models/WorkoutPlan.swift` (ADD relationship)

```swift
// Add to existing WorkoutPlan model
@Relationship(deleteRule: .nullify)
var sessions: [WorkoutSession] = []
```

### Step 1.4: Update App Schema

**File**: `BumbumNaNucaApp.swift`

```swift
var sharedModelContainer: ModelContainer = {
    let schema = Schema([
        WorkoutPlan.self,
        Exercise.self,
        WorkoutSession.self,  // NEW
        ExerciseSet.self,      // NEW
        MuscleGroup.self
    ])
    let modelConfiguration = ModelConfiguration(schema: schema)
    return try! ModelContainer(for: schema, configurations: [modelConfiguration])
}()
```

**✅ Checkpoint**: Build project - should compile without errors

---

## Phase 2: Helpers & Utilities (1 hour)

### Step 2.1: Haptic Feedback

**File**: `BumbumNaNuca/Utilities/Helpers/HapticFeedback.swift`

```swift
import UIKit

class HapticFeedback {
    static let shared = HapticFeedback()
    
    private let notificationGenerator = UINotificationFeedbackGenerator()
    
    private init() {
        notificationGenerator.prepare()
    }
    
    func timerCompleted() {
        notificationGenerator.notificationOccurred(.success)
    }
}
```

### Step 2.2: Audio Feedback

**File**: `BumbumNaNuca/Utilities/Helpers/AudioFeedback.swift`

```swift
import AVFoundation

class AudioFeedback {
    static func playTimerComplete() {
        // System sound 1057 = SMS Received (brief, non-intrusive)
        AudioServicesPlaySystemSound(1057)
    }
}
```

**✅ Checkpoint**: Test haptic/audio in Simulator or device

---

## Phase 3: ViewModels (4-5 hours)

Implement ViewModels in order of dependency.

### Step 3.1: RestTimerViewModel

**File**: `BumbumNaNuca/ViewModels/Execute/RestTimerViewModel.swift`

```swift
import Foundation
import Combine
import UIKit

@Observable
class RestTimerViewModel {
    private(set) var duration: TimeInterval
    private(set) var remainingTime: TimeInterval
    private(set) var isRunning: Bool = false
    private(set) var isPaused: Bool = false
    
    private var timerCancellable: AnyCancellable?
    private var backgroundTask: UIBackgroundTaskIdentifier = .invalid
    
    private let timerCompletedSubject = PassthroughSubject<Void, Never>()
    var timerCompleted: AnyPublisher<Void, Never> {
        timerCompletedSubject.eraseToAnyPublisher()
    }
    
    init(duration: TimeInterval) {
        self.duration = duration
        self.remainingTime = duration
    }
    
    // See contracts/viewmodels.md for full implementation
    // Key methods: start(), pause(), resume(), skip(), enterBackground(), enterForeground()
}
```

**📝 Full implementation**: Copy from `contracts/viewmodels.md` section "RestTimerViewModel"

### Step 3.2: WorkoutSummaryViewModel

**File**: `BumbumNaNuca/ViewModels/Execute/WorkoutSummaryViewModel.swift`

```swift
import Foundation

@Observable
class WorkoutSummaryViewModel {
    private(set) var session: WorkoutSession
    private(set) var duration: TimeInterval
    private(set) var completedExercisesCount: Int
    private(set) var totalSets: Int
    private(set) var totalReps: Int
    
    init(session: WorkoutSession) {
        self.session = session
        self.duration = session.duration ?? 0
        self.completedExercisesCount = session.completedExercises.count
        self.totalSets = session.totalSets
        self.totalReps = session.totalReps
    }
    
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

### Step 3.3: ExecuteExerciseViewModel

**File**: `BumbumNaNuca/ViewModels/Execute/ExecuteExerciseViewModel.swift`

📝 See `contracts/viewmodels.md` for full implementation - includes validation logic

### Step 3.4: WorkoutSessionViewModel

**File**: `BumbumNaNuca/ViewModels/Execute/WorkoutSessionViewModel.swift`

📝 See `contracts/viewmodels.md` for full implementation - orchestrates session

**✅ Checkpoint**: All ViewModels compile without errors

---

## Phase 4: Shared Components (2 hours)

### Step 4.1: Progress Ring

**File**: `BumbumNaNuca/Views/Workout/Execute/Components/ProgressRing.swift`

```swift
import SwiftUI

struct ProgressRing: View {
    let progress: Double  // 0.0 to 1.0
    
    var body: some View {
        Circle()
            .stroke(lineWidth: 15)
            .opacity(0.3)
            .foregroundColor(.white)
            .overlay(
                Circle()
                    .trim(from: 0.0, to: CGFloat(min(progress, 1.0)))
                    .stroke(style: StrokeStyle(lineWidth: 15, lineCap: .round))
                    .foregroundColor(.green)
                    .rotationEffect(Angle(degrees: 270))
            )
    }
}
```

### Step 4.2-4.5: Other Components

Create these files (full code in `contracts/views.md`):
- `ValidationFeedback.swift`
- `SetInputView.swift`
- `ExerciseExecutionRow.swift`
- `SummaryCard.swift`

**✅ Checkpoint**: Preview all components in Xcode

---

## Phase 5: Main Views (3-4 hours)

### Step 5.1: RestTimerView

**File**: `BumbumNaNuca/Views/Workout/Execute/RestTimerView.swift`

📝 Copy implementation from `contracts/views.md`

**Test**: Preview with 10 seconds duration, verify countdown works

### Step 5.2: WorkoutSummaryView

**File**: `BumbumNaNuca/Views/Workout/Execute/WorkoutSummaryView.swift`

📝 Copy implementation from `contracts/views.md`

**Test**: Preview with mock session data

### Step 5.3: ExecuteExerciseView

**File**: `BumbumNaNuca/Views/Workout/Execute/ExecuteExerciseView.swift`

📝 Copy implementation from `contracts/views.md`

**Test**: 
1. Preview with mock exercise
2. Test validation (enter invalid values)
3. Test set recording (breakpoint in `recordSet()`)

### Step 5.4: ExecuteWorkoutView

**File**: `BumbumNaNuca/Views/Workout/Execute/ExecuteWorkoutView.swift`

📝 Copy implementation from `contracts/views.md`

**Test**:
1. Preview with mock workout plan
2. Test navigation to exercise view
3. Test progress tracking

---

## Phase 6: Integration (1 hour)

### Step 6.1: Add "Iniciar Treino" Button

**File**: `BumbumNaNuca/Views/Workout/WorkoutPlanDetailView.swift`

```swift
// Add to toolbar or body
Button("Iniciar Treino") {
    showingExecuteView = true
}
.buttonStyle(.borderedProminent)

// Add state
@State private var showingExecuteView = false

// Add sheet
.sheet(isPresented: $showingExecuteView) {
    ExecuteWorkoutView(workoutPlan: workoutPlan)
}
```

**✅ Checkpoint**: Full flow from plan detail → execute → summary works

---

## Phase 7: Testing (3-4 hours)

### Step 7.1: Unit Tests

**File**: `BumbumNaNucaTests/Execute/RestTimerViewModelTests.swift`

```swift
import XCTest
@testable import BumbumNaNuca

final class RestTimerViewModelTests: XCTestCase {
    func testTimerInitialization() {
        let viewModel = RestTimerViewModel(duration: 60)
        
        XCTAssertEqual(viewModel.duration, 60)
        XCTAssertEqual(viewModel.remainingTime, 60)
        XCTAssertFalse(viewModel.isRunning)
    }
    
    func testTimerCountdown() {
        let viewModel = RestTimerViewModel(duration: 5)
        let expectation = expectation(description: "Timer completes")
        
        var completed = false
        let cancellable = viewModel.timerCompleted.sink {
            completed = true
            expectation.fulfill()
        }
        
        viewModel.start()
        
        waitForExpectations(timeout: 6)
        XCTAssertTrue(completed)
        cancellable.cancel()
    }
}
```

Create similar tests for:
- `ExecuteExerciseViewModelTests`
- `WorkoutSessionViewModelTests`
- `ValidationTests`

### Step 7.2: UI Tests

**File**: `BumbumNaNucaUITests/ExecuteWorkoutUITests.swift`

```swift
import XCTest

final class ExecuteWorkoutUITests: XCTestCase {
    var app: XCUIApplication!
    
    override func setUp() {
        super.setUp()
        continueAfterFailure = false
        app = XCUIApplication()
        app.launch()
    }
    
    func testCompleteWorkoutFlow() {
        // 1. Navigate to workout plan
        app.buttons["Treinos"].tap()
        app.tables.cells.firstMatch.tap()
        
        // 2. Start workout
        app.buttons["Iniciar Treino"].tap()
        
        // 3. Select first exercise
        app.tables.cells.firstMatch.tap()
        
        // 4. Record a set
        let weightField = app.textFields["Peso (kg)"]
        weightField.tap()
        weightField.typeText("80")
        
        let repsField = app.textFields["Repetições"]
        repsField.tap()
        repsField.typeText("10")
        
        app.buttons["Concluir Série"].tap()
        
        // 5. Skip timer
        app.buttons["Pular"].tap()
        
        // 6. Complete exercise
        app.buttons["Concluir Exercício"].tap()
        
        // 7. Finalize workout
        app.buttons["Finalizar"].tap()
        
        // 8. Verify summary
        XCTAssertTrue(app.staticTexts["Treino Concluído!"].exists)
    }
}
```

**✅ Checkpoint**: All tests pass

---

## Phase 8: Polish & Accessibility (1-2 hours)

### Step 8.1: Add VoiceOver Labels

Review all views and ensure:
- [ ] All buttons have `.accessibilityLabel()`
- [ ] Timer announces time remaining
- [ ] Progress indicators have text alternatives

### Step 8.2: Test Dynamic Type

```swift
// In Xcode: Environment Overrides → Text Size → XXXL
// Verify all text scales properly
```

### Step 8.3: Test Dark Mode

```swift
// In Xcode: Environment Overrides → Appearance → Dark
// Verify all colors have sufficient contrast
```

**✅ Checkpoint**: Accessibility audit passes

---

## Phase 9: Final Validation (30 min)

### Pre-Merge Checklist

- [ ] All Constitution checks pass (from plan.md)
- [ ] All tests pass (unit + UI)
- [ ] SwiftLint warnings resolved (if configured)
- [ ] No force unwraps (`!`) in production code
- [ ] All ViewModels have SwiftUI Previews
- [ ] All user-facing strings use String catalog
- [ ] Memory leaks checked (Instruments → Leaks)
- [ ] Performance acceptable (60 fps on target device)
- [ ] Code reviewed by at least one other developer

---

## Troubleshooting

### Timer doesn't continue in background
- ✅ Ensure `UIApplication.shared.beginBackgroundTask` is called
- ✅ Check that background time is requested before timer starts
- ✅ Test on real device (Simulator has different background behavior)

### SwiftData not persisting sets
- ✅ Verify `modelContext` is injected via `@Environment`
- ✅ Check relationships are bidirectional
- ✅ Ensure ExerciseSet is added to session.exerciseSets array

### Validation not working in real-time
- ✅ Verify `.onChange(of:)` is called on TextField
- ✅ Check that validation methods are marked with `@MainActor`
- ✅ Ensure error properties are `@Published` or in `@Observable` class

### Timer audio not playing
- ✅ Test on real device (Simulator doesn't play system sounds reliably)
- ✅ Check device is not in Silent Mode
- ✅ Verify sound ID is valid (1057 for SMS Received)

---

## Next Steps

After implementation:
1. Create PR with description, screenshots, Constitution checklist
2. Request code review
3. Address feedback
4. Merge to main
5. Update IMPLEMENTATION_STATUS.md

---

## Additional Resources

- [Apple: SwiftData Documentation](https://developer.apple.com/documentation/swiftdata)
- [Apple: Background Tasks](https://developer.apple.com/documentation/uikit/app_and_environment/scenes/preparing_your_ui_to_run_in_the_background)
- [Apple: Accessibility](https://developer.apple.com/accessibility/)
- Constitution: `.specify/memory/constitution.md`
- Data Model: `specs/002-execute-workout/data-model.md`
- Research: `specs/002-execute-workout/research.md`

---

**Estimated Total Time**: 15-20 hours (full implementation + tests)

**Priority**: P1 (Critical for MVP)

Good luck! 🚀
