# View Contracts: Exercise Execution Refinement

**Feature**: 004-exercise-execution-refinement  
**Date**: 2026-01-10  
**Purpose**: Define View structures and responsibilities for refactored execution UI

## Overview

This feature refactors 4 existing Views:

1. **ExecuteExerciseView** - Remove input forms, display exercise info + timer
2. **RestTimerView** - Add visual polish for background-aware timer
3. **WorkoutSummaryView** - Fix navigation behavior
4. **AddExerciseView** - Add load input field

All Views use SwiftUI with @State for local UI state and @Observable ViewModels for business logic.

---

## ExecuteExerciseView (REFACTOR)

**Responsibility**: Display exercise information and manage set completion without input forms

### Layout Structure

```swift
struct ExecuteExerciseView: View {
    let exercise: Exercise
    let session: WorkoutSession
    let onComplete: () -> Void
    
    @Environment(\.modelContext) private var modelContext
    @Environment(\.dismiss) private var dismiss
    
    @State private var viewModel: ExecuteExerciseViewModel?
    @State private var timerViewModel: RestTimerViewModel?
    
    var body: some View {
        VStack(spacing: 24) {
            // Top: Exercise information header
            ExerciseInfoHeader(exercise: exercise)
                .padding(.horizontal)
            
            Spacer()
            
            // Middle: Timer (when running) or Progress indicator
            if let timer = timerViewModel, timer.isRunning {
                TimerDisplay(viewModel: timer)
            } else {
                ProgressIndicator(
                    current: viewModel?.currentSetNumber ?? 1,
                    total: exercise.defaultSets
                )
            }
            
            Spacer()
            
            // Bottom: Action button
            ActionButton(
                viewModel: viewModel,
                onStartRest: startRestPeriod,
                onFinish: attemptFinish
            )
            .padding(.horizontal)
            .padding(.bottom, 32)
        }
        .navigationTitle("Executar Série")
        .navigationBarTitleDisplayMode(.inline)
        .onAppear {
            if viewModel == nil {
                viewModel = ExecuteExerciseViewModel(
                    exercise: exercise,
                    session: session,
                    modelContext: modelContext
                )
            }
        }
        .alert("Finalizar exercício", isPresented: Binding(
            get: { viewModel?.showingEarlyFinishAlert ?? false },
            set: { viewModel?.showingEarlyFinishAlert = $0 }
        )) {
            Button("Cancelar", role: .cancel) {}
            Button("Finalizar") {
                viewModel?.finish()
                onComplete()
                dismiss()
            }
        } message: {
            if let vm = viewModel {
                Text("Você completou apenas \(vm.currentSetNumber - 1) de \(vm.exercise.defaultSets) séries. Deseja finalizar mesmo assim?")
            }
        }
    }
    
    private func startRestPeriod() {
        // Record set automatically
        do {
            try viewModel?.recordSet()
            
            // Start rest timer
            let restTime = exercise.defaultRestTime > 0 ? exercise.defaultRestTime : 60
            timerViewModel = RestTimerViewModel(duration: TimeInterval(restTime))
            timerViewModel?.start()
        } catch {
            // Handle error (show alert)
        }
    }
    
    private func attemptFinish() {
        viewModel?.attemptFinish()
    }
}
```

### Subcomponents

#### ExerciseInfoHeader (NEW Component)

```swift
struct ExerciseInfoHeader: View {
    let exercise: Exercise
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            // Exercise name
            Text(exercise.name)
                .font(.title.bold())
            
            // Muscle group
            HStack {
                Image(systemName: "figure.strengthtraining.traditional")
                Text(exercise.muscleGroup.displayName)
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
            }
            
            // Configuration details
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
```

#### TimerDisplay (NEW Component)

```swift
struct TimerDisplay: View {
    @Bindable var viewModel: RestTimerViewModel
    
    var body: some View {
        VStack(spacing: 16) {
            // Circular progress
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
            
            // Timer completion indicator
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

#### ActionButton (NEW Component)

```swift
struct ActionButton: View {
    let viewModel: ExecuteExerciseViewModel?
    let onStartRest: () -> Void
    let onFinish: () -> Void
    
    var body: some View {
        if let vm = viewModel {
            if vm.isLastSet {
                Button(action: onFinish) {
                    Text("Finalizar Exercício")
                        .font(.headline)
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(Color.green)
                        .foregroundColor(.white)
                        .cornerRadius(12)
                }
            } else {
                Button(action: onStartRest) {
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
    }
}
```

#### ProgressIndicator (NEW Component)

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

### Changes from Current Implementation

| Aspect | Before | After |
|--------|--------|-------|
| Input forms | TextField for reps/weight + Stepper | No input forms |
| Layout | Form-based with validation | Info header + timer + button |
| Set recording | Explicit "Registrar Série" button | Automatic on "Começar Descanso" |
| Timer | Separate sheet/modal | Inline in same view |
| Exercise info | Minimal header | Complete info header with all details |

---

## RestTimerView (MINOR REFACTOR)

**Responsibility**: Display countdown timer with completion feedback

### Usage Context

RestTimerView is now embedded within ExecuteExerciseView (not a separate sheet), but can still be used standalone if needed.

### Layout (Simplified)

```swift
struct RestTimerView: View {
    @Bindable var viewModel: RestTimerViewModel
    
    var body: some View {
        VStack(spacing: 24) {
            // Circular timer (reuse TimerDisplay component)
            TimerDisplay(viewModel: viewModel)
            
            // Optional: Manual controls (pause/resume/skip)
            if !viewModel.isCompleted {
                HStack(spacing: 16) {
                    Button(viewModel.isRunning ? "Pausar" : "Retomar") {
                        viewModel.isRunning ? viewModel.pause() : viewModel.resume()
                    }
                    .buttonStyle(.bordered)
                    
                    Button("Pular") {
                        viewModel.stop()
                    }
                    .buttonStyle(.bordered)
                }
            }
        }
        .padding()
    }
}
```

### Changes

- Now uses common TimerDisplay component
- Can be embedded or presented as sheet
- Background support handled in ViewModel (transparent to view)

---

## WorkoutSummaryView (MODIFY)

**Responsibility**: Display workout completion summary and navigate to Home

### Layout (Minimal Changes)

```swift
struct WorkoutSummaryView: View {
    let session: WorkoutSession
    
    @Environment(\.dismiss) private var dismiss
    @State private var viewModel: WorkoutSummaryViewModel?
    
    var body: some View {
        Group {
            if let viewModel = viewModel {
                summaryContent
            } else {
                ProgressView()
                    .onAppear {
                        self.viewModel = WorkoutSummaryViewModel(session: session)
                    }
            }
        }
        .navigationBarBackButtonHidden()
    }
    
    @ViewBuilder
    private var summaryContent: some View {
        if let viewModel = viewModel {
            VStack(spacing: 30) {
                // Header (unchanged)
                VStack(spacing: 10) {
                    Image(systemName: "checkmark.circle.fill")
                        .font(.system(size: 60))
                        .foregroundColor(.green)
                    
                    Text("Treino Concluído!")
                        .font(.largeTitle.bold())
                }
                
                // Stats (unchanged)
                VStack(spacing: 16) {
                    StatRow(label: "Duração", value: viewModel.formattedDuration)
                    StatRow(label: "Exercícios", value: "\(viewModel.completedExercisesCount)")
                    StatRow(label: "Séries", value: "\(viewModel.totalSets)")
                    StatRow(label: "Repetições", value: "\(viewModel.totalReps)")
                }
                .padding()
                .background(Color(.systemGray6))
                .cornerRadius(12)
                
                Spacer()
                
                // MODIFIED: Dismiss button
                PrimaryButton("Finalizar") {
                    // Session already finalized
                    // Dismiss to Home
                    dismiss()
                }
                .padding(.horizontal)
            }
            .padding()
        }
    }
}
```

### Changes

| Aspect | Before | After |
|--------|--------|-------|
| Navigation | dismiss() → ExecuteWorkoutView | dismiss() → cascades to Home |
| Session state | Sometimes incomplete | Always finalized before view shown |

**Note**: The navigation fix is primarily in ExecuteWorkoutView's `.onChange` handler, not in this view itself.

---

## AddExerciseView (MODIFY)

**Responsibility**: Exercise creation form with optional load field

### Layout

```swift
struct AddExerciseView: View {
    @Environment(\.modelContext) private var modelContext
    @Environment(\.dismiss) private var dismiss
    
    @State private var viewModel: AddExerciseViewModel
    
    init(workoutPlan: WorkoutPlan) {
        _viewModel = State(wrappedValue: AddExerciseViewModel(
            workoutPlan: workoutPlan,
            modelContext: modelContext
        ))
    }
    
    var body: some View {
        Form {
            Section("Informações Básicas") {
                TextField("Nome do exercício", text: $viewModel.name)
                
                Picker("Grupo Muscular", selection: $viewModel.selectedMuscleGroup) {
                    ForEach(MuscleGroup.allCases) { group in
                        Text(group.displayName).tag(group)
                    }
                }
            }
            
            Section("Configuração") {
                TextField("Séries", text: $viewModel.defaultSets)
                    .keyboardType(.numberPad)
                
                TextField("Repetições", text: $viewModel.defaultReps)
                    .keyboardType(.numberPad)
                
                TextField("Descanso (segundos)", text: $viewModel.defaultRestTime)
                    .keyboardType(.numberPad)
                
                // NEW: Load field
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
        }
        .navigationTitle("Adicionar Exercício")
        .toolbar {
            ToolbarItem(placement: .confirmationAction) {
                Button("Salvar") {
                    saveExercise()
                }
                .disabled(!viewModel.isFormValid)
            }
            
            ToolbarItem(placement: .cancellationAction) {
                Button("Cancelar") {
                    dismiss()
                }
            }
        }
        .onChange(of: viewModel.loadText) { _, _ in
            viewModel.validateInputs()
        }
    }
    
    private func saveExercise() {
        do {
            try viewModel.saveExercise()
            dismiss()
        } catch {
            // Show error alert
        }
    }
}
```

### Changes

| Aspect | Before | After |
|--------|--------|-------|
| Load field | Not present | Optional TextField with kg suffix |
| Validation | Name + numbers only | Name + numbers + optional load |
| Help text | None for load | "Deixe em branco para exercícios sem carga" |

---

## ExecuteWorkoutView (MINIMAL CHANGES)

**Responsibility**: Orchestrate workout session and navigate properly on completion

### Layout (Existing, with onChange addition)

```swift
struct ExecuteWorkoutView: View {
    let workoutPlan: WorkoutPlan
    
    @Environment(\.modelContext) private var modelContext
    @Environment(\.dismiss) private var dismiss
    
    @State private var viewModel: WorkoutSessionViewModel?
    @State private var selectedExercise: Exercise?
    @State private var showingSummary = false
    
    var body: some View {
        // ... existing UI (exercise list, progress header) ...
        
        .sheet(item: $selectedExercise) { exercise in
            NavigationStack {
                ExecuteExerciseView(
                    exercise: exercise,
                    session: viewModel.session,
                    onComplete: {
                        viewModel?.markExerciseComplete(exercise)
                        selectedExercise = nil
                    }
                )
            }
        }
        .sheet(isPresented: $showingSummary) {
            NavigationStack {
                WorkoutSummaryView(session: viewModel.session)
            }
        }
        // NEW: Auto-dismiss when session ends
        .onChange(of: viewModel?.session.endDate) { _, newValue in
            if newValue != nil {
                // Session completed, dismiss to Home
                // Small delay to let summary sheet dismiss first
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
                    dismiss()
                }
            }
        }
    }
}
```

---

## SwiftUI Previews

### ExecuteExerciseView Preview

```swift
#Preview {
    NavigationStack {
        ExecuteExerciseView(
            exercise: Exercise(
                name: "Agachamento",
                muscleGroup: .glutes,
                defaultSets: 4,
                defaultReps: 12,
                defaultRestTime: 90,
                load: 50.0
            ),
            session: WorkoutSession(workoutPlan: WorkoutPlan(name: "Treino A")),
            onComplete: {}
        )
    }
}
```

### ExerciseInfoHeader Preview

```swift
#Preview {
    ExerciseInfoHeader(
        exercise: Exercise(
            name: "Leg Press",
            muscleGroup: .quadriceps,
            defaultSets: 3,
            defaultReps: 15,
            defaultRestTime: 60,
            load: 120.0
        )
    )
    .padding()
}
```

---

## Localization

All user-facing strings in Portuguese (PT-BR):

| String | Context |
|--------|---------|
| "Executar Série" | Navigation title |
| "Começar Descanso" | Primary button text |
| "Finalizar Exercício" | Last set button text |
| "Descanso concluído" | Timer completion text |
| "Você completou apenas X de Y séries..." | Early finish alert |
| "Carga (kg)" | Load input field |
| "Deixe em branco para exercícios sem carga" | Help text |

---

## Accessibility

### Minimum Requirements (Per Constitution: Optional)

Since accessibility is not required per constitution, these are suggestions only:

- Timer countdown: VoiceOver label with remaining time
- Progress indicators: Semantic labels ("Série 2 de 4")
- Action buttons: Clear labels without relying solely on color

---

## Summary

**Views Modified**: 4
- ExecuteExerciseView (complete refactor - no forms, inline timer)
- RestTimerView (minor polish, embedded usage)
- WorkoutSummaryView (minimal - navigation handled by parent)
- AddExerciseView (add load field)

**New Components**: 4
- ExerciseInfoHeader (exercise details display)
- TimerDisplay (circular timer visualization)
- ActionButton (context-aware button)
- ProgressIndicator (set progress display)

**Key Changes**:
- No input forms during execution
- Inline timer display
- Complete exercise information header
- Cascading dismiss on completion
- Optional load field in exercise creation

All view contracts defined. Ready for quickstart guide.
