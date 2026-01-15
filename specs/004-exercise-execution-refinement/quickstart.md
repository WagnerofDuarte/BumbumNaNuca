# Quickstart Guide: Exercise Execution Refinement

**Feature**: 004-exercise-execution-refinement  
**Date**: 2026-01-10  
**Estimated Time**: 6-8 hours  
**Difficulty**: Intermediate

## Prerequisites

- Xcode 15.0+
- iOS 17.0+ deployment target
- Existing BumbumNaNuca project with Execute module (from specs/002-execute-workout)
- User notification permission (will be requested at runtime)

## Implementation Phases

```
Phase 1: Models (30 min)
Phase 2: ViewModels (3-4 hours)
Phase 3: Views & Components (2-3 hours)
Phase 4: Integration & Testing (1 hour)
```

---

## Phase 1: Model Extensions (30 minutes)

### Step 1.1: Add Load Field to Exercise

**File**: `BumbumNaNuca/Models/Exercise.swift`

**Action**: Add optional `load` field

```swift
@Model
final class Exercise {
    // ... existing fields ...
    
    // ADD THIS:
    var load: Double?
    
    init(
        id: UUID = UUID(),
        name: String,
        muscleGroup: MuscleGroup,
        defaultSets: Int = 3,
        defaultReps: Int = 12,
        defaultRestTime: Int = 60,
        order: Int = 0,
        load: Double? = nil  // ADD THIS PARAMETER
    ) {
        // ... existing assignments ...
        self.load = load  // ADD THIS ASSIGNMENT
    }
}
```

**Validation**:
- Build project - should compile without errors
- SwiftData will auto-migrate schema
- Existing exercises will have `load = nil`

---

## Phase 2: ViewModels (3-4 hours)

### Step 2.1: Refactor ExecuteExerciseViewModel

**File**: `BumbumNaNuca/ViewModels/Execute/ExecuteExerciseViewModel.swift`

**Remove**:
- `weightText: String`
- `repsText: String`
- `weightError: String?`
- `repsError: String?`
- All validation methods related to input

**Add**:
```swift
// Alert state
var showingEarlyFinishAlert = false

// Computed
var isLastSet: Bool {
    currentSetNumber >= exercise.defaultSets
}

var setsRemaining: Int {
    max(0, exercise.defaultSets - (currentSetNumber - 1))
}
```

**Modify `recordSet()`**:
```swift
func recordSet() throws -> ExerciseSet {
    let set = ExerciseSet(
        setNumber: currentSetNumber,
        weight: exercise.load,           // CHANGED: automatic from exercise
        reps: exercise.defaultReps,      // CHANGED: automatic from exercise
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

**Add methods**:
```swift
func attemptFinish() {
    if currentSetNumber < exercise.defaultSets {
        showingEarlyFinishAlert = true
    } else {
        finish()
    }
}

func finish() {
    // Exercise complete - view will dismiss
}
```

**Remove**:
- `clearInputs()` method
- `validateWeight()` method
- `validateReps()` method

**✅ Checkpoint**: ViewModel compiles, automatic recording logic in place

---

### Step 2.2: Enhance RestTimerViewModel

**File**: `BumbumNaNuca/ViewModels/Execute/RestTimerViewModel.swift`

**Add imports**:
```swift
import UserNotifications
import AudioToolbox
```

**Add properties**:
```swift
private var backgroundTask: UIBackgroundTaskIdentifier?
```

**Modify `init`**:
```swift
init(duration: TimeInterval? = nil) {
    self.duration = duration ?? 60  // ADD: Default to 60s
    self.remainingTime = self.duration
}
```

**Modify `start()`**:
```swift
func start() {
    isRunning = true
    isCompleted = false
    
    // ADD: Register background task
    backgroundTask = UIApplication.shared.beginBackgroundTask { [weak self] in
        self?.endBackgroundTask()
    }
    
    timer = Timer.publish(every: 1, on: .main, in: .common)
        .autoconnect()
        .sink { [weak self] _ in
            self?.tick()
        }
}
```

**Modify completion logic**:
```swift
private func complete() {
    isRunning = false
    isCompleted = true
    timer?.cancel()
    
    // ADD: Sound/haptic
    AudioServicesPlaySystemSound(1322)
    
    // ADD: Notification if backgrounded
    if UIApplication.shared.applicationState != .active {
        scheduleCompletionNotification()
    }
    
    // ADD: End background task
    endBackgroundTask()
}
```

**Add new methods**:
```swift
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
```

**✅ Checkpoint**: Timer supports background operation and notifications

---

### Step 2.3: Update AddExerciseViewModel

**File**: `BumbumNaNuca/ViewModels/AddExerciseViewModel.swift`

**Add property**:
```swift
var loadText: String = ""
```

**Add to `validateInputs()`**:
```swift
// Validate load
if !loadText.isEmpty {
    if let load = Double(loadText.replacingOccurrences(of: ",", with: ".")), load > 0 {
        loadError = nil
    } else {
        loadError = "Carga deve ser um número maior que 0"
    }
} else {
    loadError = nil  // Optional field
}
```

**Modify `saveExercise()`**:
```swift
func saveExercise() throws -> Exercise {
    validateInputs()
    guard isFormValid else { throw ValidationError.invalidForm }
    
    let parsedSets = Int(defaultSets) ?? 3
    let parsedReps = Int(defaultReps) ?? 12
    let parsedRest = Int(defaultRestTime) ?? 60
    
    // ADD: Parse optional load
    let parsedLoad: Double? = loadText.isEmpty ? nil : 
        Double(loadText.replacingOccurrences(of: ",", with: "."))
    
    let exercise = Exercise(
        name: name,
        muscleGroup: selectedMuscleGroup,
        defaultSets: parsedSets,
        defaultReps: parsedReps,
        defaultRestTime: parsedRest,
        order: workoutPlan.exercises.count,
        load: parsedLoad  // ADD THIS
    )
    
    exercise.workoutPlan = workoutPlan
    modelContext.insert(exercise)
    
    return exercise
}
```

**✅ Checkpoint**: Load field supported in exercise creation

---

### Step 2.4: Update WorkoutSessionViewModel (Minor)

**File**: `BumbumNaNuca/ViewModels/Execute/WorkoutSessionViewModel.swift`

**No changes needed** - existing `finalizeSession()` already sets `session.endDate`

**✅ Checkpoint**: Session finalization unchanged

---

## Phase 3: Views & Components (2-3 hours)

### Step 3.1: Create ExerciseInfoHeader Component

**File**: `BumbumNaNuca/Views/Components/ExerciseInfoHeader.swift` (NEW FILE)

```swift
import SwiftUI

struct ExerciseInfoHeader: View {
    let exercise: Exercise
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text(exercise.name)
                .font(.title.bold())
            
            HStack {
                Image(systemName: "figure.strengthtraining.traditional")
                Text(exercise.muscleGroup.displayName)
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
            }
            
            HStack(spacing: 16) {
                InfoPill(icon: "repeat", text: "\(exercise.defaultSets) séries")
                InfoPill(icon: "arrow.up.arrow.down", text: "\(exercise.defaultReps) reps")
                
                if let load = exercise.load {
                    InfoPill(icon: "scalemass", text: String(format: "%.1f kg", load))
                }
                
                InfoPill(icon: "timer", text: "\(exercise.defaultRestTime)s")
            }
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding()
        .background(Color(.systemGray6))
        .cornerRadius(12)
    }
}

struct InfoPill: View {
    let icon: String
    let text: String
    
    var body: some View {
        HStack(spacing: 4) {
            Image(systemName: icon)
                .font(.caption)
            Text(text)
                .font(.caption)
        }
        .padding(.horizontal, 8)
        .padding(.vertical, 4)
        .background(Color(.systemBackground))
        .cornerRadius(8)
    }
}

#Preview {
    ExerciseInfoHeader(
        exercise: Exercise(
            name: "Agachamento",
            muscleGroup: .glutes,
            defaultSets: 4,
            defaultReps: 12,
            defaultRestTime: 90,
            load: 50.0
        )
    )
    .padding()
}
```

**✅ Checkpoint**: Preview shows exercise info card

---

### Step 3.2: Create TimerDisplay Component

**File**: `BumbumNaNuca/Views/Components/TimerDisplay.swift` (NEW FILE)

```swift
import SwiftUI

struct TimerDisplay: View {
    @Bindable var viewModel: RestTimerViewModel
    
    var body: some View {
        VStack(spacing: 16) {
            ZStack {
                Circle()
                    .stroke(Color(.systemGray5), lineWidth: 12)
                    .frame(width: 200, height: 200)
                
                Circle()
                    .trim(from: 0, to: viewModel.progress)
                    .stroke(Color.accentColor, style: StrokeStyle(lineWidth: 12, lineCap: .round))
                    .frame(width: 200, height: 200)
                    .rotationEffect(.degrees(-90))
                    .animation(.linear(duration: 1), value: viewModel.progress)
                
                VStack {
                    Text(viewModel.formattedTime)
                        .font(.system(size: 48, weight: .bold, design: .monospaced))
                    
                    Text("Descanso")
                        .font(.caption)
                        .foregroundStyle(.secondary)
                }
            }
            
            if viewModel.isCompleted {
                HStack(spacing: 8) {
                    Image(systemName: "checkmark.circle.fill")
                        .foregroundColor(.green)
                    Text("Descanso concluído!")
                        .font(.subheadline)
                }
            }
        }
    }
}
```

**✅ Checkpoint**: Timer displays circular progress

---

### Step 3.3: Refactor ExecuteExerciseView

**File**: `BumbumNaNuca/Views/Workout/Execute/ExecuteExerciseView.swift`

**Remove all**:
- `SetInputView` components
- `weightText` and `repsText` @State variables
- Form-based layout
- "Registrar Série" button logic

**Replace body with**:
```swift
var body: some View {
    Group {
        if let viewModel = viewModel {
            exerciseContent(viewModel: viewModel)
        } else {
            ProgressView()
                .onAppear {
                    self.viewModel = ExecuteExerciseViewModel(
                        exercise: exercise,
                        session: session,
                        modelContext: modelContext
                    )
                }
        }
    }
}

@ViewBuilder
private func exerciseContent(viewModel: ExecuteExerciseViewModel) -> some View {
    VStack(spacing: 24) {
        // Top: Exercise info
        ExerciseInfoHeader(exercise: exercise)
            .padding(.horizontal)
        
        Spacer()
        
        // Middle: Timer or Progress
        if let timer = timerViewModel, timer.isRunning {
            TimerDisplay(viewModel: timer)
        } else {
            ProgressIndicator(
                current: viewModel.currentSetNumber,
                total: exercise.defaultSets
            )
        }
        
        Spacer()
        
        // Bottom: Action button
        actionButton(viewModel: viewModel)
            .padding(.horizontal)
            .padding(.bottom, 32)
    }
    .navigationTitle("Executar Série")
    .navigationBarTitleDisplayMode(.inline)
    .alert("Finalizar exercício", isPresented: $viewModel.showingEarlyFinishAlert) {
        Button("Cancelar", role: .cancel) {}
        Button("Finalizar") {
            viewModel.finish()
            onComplete()
            dismiss()
        }
    } message: {
        Text("Você completou apenas \(viewModel.currentSetNumber - 1) de \(viewModel.exercise.defaultSets) séries. Deseja finalizar mesmo assim?")
    }
}

@ViewBuilder
private func actionButton(viewModel: ExecuteExerciseViewModel) -> some View {
    if viewModel.isLastSet {
        Button(action: { viewModel.attemptFinish() }) {
            Text("Finalizar Exercício")
                .font(.headline)
                .frame(maxWidth: .infinity)
                .padding()
                .background(Color.green)
                .foregroundColor(.white)
                .cornerRadius(12)
        }
    } else {
        Button(action: startRestPeriod) {
            Text("Começar Descanso")
                .font(.headline)
                .frame(maxWidth: .infinity)
                .padding()
                .background(Color.accentColor)
                .foregroundColor(.white)
                .cornerRadius(12)
        }
    }
}

private func startRestPeriod() {
    do {
        try viewModel?.recordSet()
        
        let restTime = exercise.defaultRestTime > 0 ? exercise.defaultRestTime : 60
        timerViewModel = RestTimerViewModel(duration: TimeInterval(restTime))
        timerViewModel?.start()
    } catch {
        Logger.shared.error("Failed to record set: \(error)")
    }
}
```

**Add ProgressIndicator** (inline or separate file):
```swift
struct ProgressIndicator: View {
    let current: Int
    let total: Int
    
    var body: some View {
        VStack(spacing: 12) {
            Text("Série \(current) de \(total)")
                .font(.title2.bold())
            
            ProgressView(value: Double(current - 1), total: Double(total))
                .frame(width: 200)
        }
    }
}
```

**✅ Checkpoint**: ExecuteExerciseView has no input forms, shows timer inline

---

### Step 3.4: Update AddExerciseView

**File**: `BumbumNaNuca/Views/Workout/AddExerciseView.swift`

**Add to Form** (in "Configuração" section):
```swift
Section("Configuração") {
    // ... existing fields ...
    
    // ADD THIS:
    HStack {
        TextField("Carga (kg)", text: $viewModel.loadText)
            .keyboardType(.decimalPad)
        
        Text("kg")
            .foregroundStyle(.secondary)
    }
    
    if let error = viewModel.loadError {
        Text(error)
            .font(.caption)
            .foregroundColor(.red)
    }
    
    Text("Deixe em branco para exercícios sem carga")
        .font(.caption)
        .foregroundStyle(.secondary)
}
```

**Add onChange**:
```swift
.onChange(of: viewModel.loadText) { _, _ in
    viewModel.validateInputs()
}
```

**✅ Checkpoint**: Load field appears in exercise creation

---

### Step 3.5: Fix Navigation in ExecuteWorkoutView

**File**: `BumbumNaNuca/Views/Workout/Execute/ExecuteWorkoutView.swift`

**Add onChange handler**:
```swift
.onChange(of: viewModel?.session.endDate) { _, newValue in
    if newValue != nil {
        // Session completed, dismiss to Home after summary closes
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
            dismiss()
        }
    }
}
```

**✅ Checkpoint**: Completing workout navigates to Home

---

### Step 3.6: Update WorkoutSummaryView (No Code Changes)

**File**: `BumbumNaNuca/Views/Workout/Execute/WorkoutSummaryView.swift`

**Verification only**: Ensure "Finalizar" button calls `dismiss()`

**✅ Checkpoint**: Navigation cascades properly

---

## Phase 4: Integration & Testing (1 hour)

### Step 4.1: Request Notification Permission

**File**: `BumbumNaNuca/BumbumNaNucaApp.swift`

**Add to app initialization**:
```swift
init() {
    // Request notification permission for timer alerts
    UNUserNotificationCenter.current().requestAuthorization(options: [.alert, .sound]) { granted, error in
        if !granted {
            Logger.shared.info("Notification permission denied")
        }
    }
}
```

**✅ Checkpoint**: Permission requested on app launch

---

### Step 4.2: Manual Testing Checklist

#### Test 1: Automatic Set Recording
1. Start workout
2. Select exercise
3. Press "Começar Descanso"
4. **Expected**: Set recorded automatically with planned reps/load
5. **Expected**: Timer starts immediately
6. **Expected**: Set counter increments (e.g., "Série 2 de 4")

#### Test 2: Background Timer
1. Start rest timer
2. Background app (home button or app switcher)
3. Wait for timer to complete
4. **Expected**: Notification appears
5. **Expected**: Sound plays
6. Return to app
7. **Expected**: Timer shows "Descanso concluído!"

#### Test 3: Last Set Finish
1. Complete all but last set
2. **Expected**: Button shows "Começar Descanso"
3. Complete second-to-last set
4. **Expected**: Button changes to "Finalizar Exercício"
5. Press "Finalizar Exercício"
6. **Expected**: Exercise completes, returns to workout list

#### Test 4: Early Finish
1. Complete 1 set of 4-set exercise
2. Press "Finalizar Exercício" (manually navigate or test)
3. **Expected**: Alert shows "Você completou apenas 1 de 4 séries..."
4. Press "Finalizar"
5. **Expected**: Exercise marked complete with partial data

#### Test 5: Load Field
1. Create new exercise
2. Enter load value (e.g., "50.5")
3. Save exercise
4. Execute workout with that exercise
5. **Expected**: ExerciseInfoHeader shows "50.5 kg"
6. Complete set
7. Check ExerciseSet in data
8. **Expected**: `weight = 50.5`

#### Test 6: Navigation Fix
1. Complete all exercises in workout
2. View summary screen
3. Press "Finalizar"
4. **Expected**: Navigate to Home screen (not back to ExecuteWorkoutView)

#### Test 7: Default Rest Time
1. Create exercise without specifying rest time (or set to 0)
2. Execute exercise
3. Press "Começar Descanso"
4. **Expected**: Timer starts at 60 seconds

#### Test 8: Existing Exercises (Migration)
1. Build with new schema
2. Open app (should migrate automatically)
3. View existing exercises
4. **Expected**: All have `load = nil`, display "Peso não especificado"
5. Edit exercise to add load
6. **Expected**: Load saves correctly

**✅ All tests passed**: Feature complete

---

## Common Issues & Solutions

### Issue: SwiftData migration error
**Solution**: Delete app and reinstall, or use Xcode menu: Product → Clean Build Folder

### Issue: Notification not appearing
**Solution**: Check Settings → [App Name] → Notifications are enabled

### Issue: Timer stops in background
**Solution**: Verify background task registration in `start()` method

### Issue: Navigation doesn't go to Home
**Solution**: Check `.onChange(of: session.endDate)` is in ExecuteWorkoutView, not summary

### Issue: Load validation error persists
**Solution**: Ensure `validateInputs()` called on `.onChange(of: loadText)`

---

## Performance Validation

After implementation, verify:

- [ ] Timer accuracy: ±1 second (test with stopwatch)
- [ ] Background timer: Continues and notifies correctly
- [ ] UI transitions: < 300ms perceived (smooth animations)
- [ ] No memory leaks: Run Instruments (optional)
- [ ] SwiftData auto-save: Sets persist immediately

---

## Deployment Checklist

- [ ] All manual tests passed
- [ ] No compiler warnings
- [ ] SwiftUI previews render correctly
- [ ] Notification permission requested
- [ ] Existing data migrates successfully
- [ ] Home navigation works correctly
- [ ] Load field optional (nil allowed)
- [ ] Default rest time applies (60s)

---

## Rollback Plan

If issues arise:

1. **Model rollback**: Remove `load` field from Exercise model, rebuild
2. **ViewModel rollback**: Restore input forms in ExecuteExerciseViewModel
3. **View rollback**: Restore SetInputView usage in ExecuteExerciseView
4. **Data safety**: SwiftData migration is one-way, but `load = nil` compatible

---

## Next Steps

After implementation:
1. Update [IMPLEMENTATION_STATUS.md](../../../IMPLEMENTATION_STATUS.md)
2. Update [README.md](../../../README.md) with new features
3. Consider future enhancements:
   - Post-workout editing of sets
   - Load progression tracking
   - Exercise history visualization
   - Custom timer sounds

---

## Summary

**Total Time**: 6-8 hours
**Files Modified**: 8
**Files Created**: 3
**Breaking Changes**: None (backward compatible)
**Risk Level**: Low

**Key Accomplishments**:
- Automatic set recording (no manual input)
- Background timer with notifications
- Load tracking for progressive overload
- Fixed workout completion navigation
- Enhanced exercise information display

Feature complete and ready for manual validation.
