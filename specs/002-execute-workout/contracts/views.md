# View Contracts: Executar Treino

**Feature**: 002-execute-workout  
**Date**: 2026-01-07  
**Purpose**: Definir estrutura e responsabilidades das Views SwiftUI

## Overview

Este documento define a hierarquia de Views, suas responsabilidades, props (parâmetros) e estados visuais.

---

## View Hierarchy

```
ExecuteWorkoutView (Root)
├── Header (progress indicator)
├── List of Exercises
│   └── ExerciseExecutionRow (per exercise)
│       ├── Exercise name
│       ├── Status badge
│       └── Set count
└── Toolbar
    ├── Cancel button
    └── Finish button

ExecuteExerciseView (Drill-down)
├── Header (exercise name)
├── Last workout data (if available)
├── Set input form
│   ├── SetInputView
│   │   ├── Weight TextField
│   │   ├── Reps TextField
│   │   └── ValidationFeedback (inline errors)
│   └── Completed sets list
├── Complete Set button
└── Complete Exercise button

RestTimerView (Modal/Sheet)
├── ProgressRing (circular progress)
├── Time remaining (large text)
└── Controls
    ├── Pause/Resume button
    └── Skip button

WorkoutSummaryView (Navigation destination)
├── Title "Treino Concluído!"
├── Summary cards
│   ├── Duration card
│   ├── Exercises card
│   ├── Sets card
│   └── Reps card
└── Finish button
```

---

## ExecuteWorkoutView

**Responsibility**: Orquestrar a execução do treino, mostrando lista de exercícios e progresso

### Props (Inputs)

```swift
struct ExecuteWorkoutView: View {
    let workoutPlan: WorkoutPlan
    @Environment(\.modelContext) private var modelContext
    @Environment(\.dismiss) private var dismiss
    
    @State private var viewModel: WorkoutSessionViewModel
    @State private var selectedExercise: Exercise?
    @State private var showingSummary = false
    @State private var showingCancelAlert = false
}
```

### Visual States

```swift
enum ViewState {
    case loading          // Initial state, checking for existing session
    case sessionConflict  // Existing session detected
    case active           // Normal execution state
    case summarizing      // Finalizing session
}
```

### Layout

```swift
var body: some View {
    NavigationStack {
        VStack {
            // Progress header
            ProgressHeader(
                progress: viewModel.progressPercentage,
                text: viewModel.progressText
            )
            .padding()
            
            // Exercise list
            List(viewModel.exercises) { exercise in
                ExerciseExecutionRow(
                    exercise: exercise,
                    status: viewModel.exerciseStatus(exercise)
                )
                .onTapGesture {
                    selectedExercise = exercise
                }
            }
        }
        .navigationTitle(workoutPlan.name)
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItem(placement: .cancellationAction) {
                Button("Cancelar") {
                    showingCancelAlert = true
                }
            }
            
            ToolbarItem(placement: .primaryAction) {
                Button("Finalizar") {
                    finalizeWorkout()
                }
            }
        }
        .sheet(item: $selectedExercise) { exercise in
            ExecuteExerciseView(
                exercise: exercise,
                session: viewModel.session,
                onComplete: {
                    viewModel.markExerciseComplete(exercise)
                    selectedExercise = nil
                }
            )
        }
        .navigationDestination(isPresented: $showingSummary) {
            WorkoutSummaryView(session: viewModel.session)
        }
        .alert("Cancelar Treino", isPresented: $showingCancelAlert) {
            Button("Continuar Treino", role: .cancel) {}
            Button("Cancelar", role: .destructive) {
                dismiss()
            }
        } message: {
            Text("Suas séries registradas serão salvas")
        }
    }
}
```

### Accessibility

```swift
.accessibilityElement(children: .combine)
.accessibilityLabel("\(workoutPlan.name), \(viewModel.progressText)")
```

### Dark Mode Support

Uses system colors (`.primary`, `.secondary`, `.accentColor`) - automatic dark mode support.

---

## ExecuteExerciseView

**Responsibility**: Registrar séries para um exercício específico

### Props

```swift
struct ExecuteExerciseView: View {
    let exercise: Exercise
    let session: WorkoutSession
    let onComplete: () -> Void
    
    @Environment(\.modelContext) private var modelContext
    @Environment(\.dismiss) private var dismiss
    
    @State private var viewModel: ExecuteExerciseViewModel
    @State private var showingTimer = false
    @State private var justRecordedSet: ExerciseSet?
}
```

### Layout

```swift
var body: some View {
    NavigationStack {
        Form {
            // Last workout reference
            if let lastData = viewModel.lastWorkoutData {
                Section {
                    Label {
                        Text(lastData.formattedText)
                    } icon: {
                        Image(systemName: "clock.arrow.circlepath")
                    }
                }
                .foregroundColor(.secondary)
            }
            
            // Progress indicator
            Section {
                Text(viewModel.progressText)
                    .font(.headline)
                
                if viewModel.hasReachedDefaultSets {
                    Label("Meta de séries atingida", systemImage: "checkmark.circle.fill")
                        .foregroundColor(.green)
                }
            }
            
            // Input section
            Section("Nova Série") {
                SetInputView(
                    weightText: $viewModel.weightText,
                    repsText: $viewModel.repsText,
                    weightError: viewModel.weightError,
                    repsError: viewModel.repsError,
                    onWeightChange: { viewModel.validateWeight() },
                    onRepsChange: { viewModel.validateReps() }
                )
                
                Button("Concluir Série") {
                    recordSet()
                }
                .disabled(!viewModel.isFormValid)
                .buttonStyle(.borderedProminent)
            }
            
            // Completed sets
            if !viewModel.completedSets.isEmpty {
                Section("Séries Completas") {
                    ForEach(viewModel.completedSets) { set in
                        HStack {
                            Text("Série \(set.setNumber)")
                            Spacer()
                            Text(set.formattedWeight)
                            Text("×")
                            Text("\(set.reps) reps")
                        }
                    }
                }
            }
        }
        .navigationTitle(exercise.name)
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItem(placement: .confirmationAction) {
                Button("Concluir Exercício") {
                    completeExercise()
                }
            }
        }
        .sheet(isPresented: $showingTimer) {
            RestTimerView(restTime: exercise.defaultRestTime)
                .onDisappear {
                    viewModel.clearInputs()
                }
        }
    }
}

private func recordSet() {
    guard let set = try? viewModel.recordSet() else { return }
    justRecordedSet = set
    
    // Show timer if not last set
    if !viewModel.hasReachedDefaultSets {
        showingTimer = true
    }
}

private func completeExercise() {
    viewModel.markExerciseComplete()
    onComplete()
}
```

### Accessibility

```swift
TextField("Peso (kg)", text: $viewModel.weightText)
    .accessibilityLabel("Peso em quilogramas")
    .accessibilityHint("Deixe vazio para peso corporal")

TextField("Repetições", text: $viewModel.repsText)
    .accessibilityLabel("Número de repetições")
```

---

## RestTimerView

**Responsibility**: Exibir e controlar timer de descanso

### Props

```swift
struct RestTimerView: View {
    let restTime: Int  // seconds
    
    @Environment(\.dismiss) private var dismiss
    @State private var viewModel: RestTimerViewModel
    
    init(restTime: Int) {
        self.restTime = restTime
        _viewModel = State(wrappedValue: RestTimerViewModel(
            duration: TimeInterval(restTime)
        ))
    }
}
```

### Layout

```swift
var body: some View {
    ZStack {
        Color.black.opacity(0.8)
            .ignoresSafeArea()
        
        VStack(spacing: 40) {
            Text("Descanso")
                .font(.title2)
                .foregroundColor(.white)
            
            // Circular progress ring
            ZStack {
                ProgressRing(progress: viewModel.progress)
                    .frame(width: 200, height: 200)
                
                Text(viewModel.formattedTime)
                    .font(.system(size: 60, weight: .bold, design: .monospaced))
                    .foregroundColor(.white)
                    .accessibilityLabel("Tempo restante: \(viewModel.formattedTime)")
            }
            
            // Controls
            HStack(spacing: 20) {
                Button {
                    viewModel.isPaused ? viewModel.resume() : viewModel.pause()
                } label: {
                    Image(systemName: viewModel.isPaused ? "play.fill" : "pause.fill")
                        .font(.title)
                }
                .buttonStyle(.bordered)
                .tint(.white)
                
                Button {
                    viewModel.skip()
                    dismiss()
                } label: {
                    Text("Pular")
                        .font(.headline)
                }
                .buttonStyle(.borderedProminent)
            }
        }
    }
    .onAppear {
        viewModel.start()
    }
    .onReceive(viewModel.timerCompleted) {
        // Trigger feedback
        HapticFeedback.shared.timerCompleted()
        AudioFeedback.playTimerComplete()
        
        // Auto-dismiss after 1 second
        DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
            dismiss()
        }
    }
    .onReceive(NotificationCenter.default.publisher(for: UIApplication.didEnterBackgroundNotification)) { _ in
        viewModel.enterBackground()
    }
    .onReceive(NotificationCenter.default.publisher(for: UIApplication.willEnterForegroundNotification)) { _ in
        viewModel.enterForeground()
    }
}
```

### Animations

```swift
// Progress ring animation
ProgressRing(progress: viewModel.progress)
    .animation(.linear(duration: 1), value: viewModel.progress)

// Pulsing effect when complete
.scaleEffect(viewModel.isComplete ? 1.1 : 1.0)
.animation(.easeInOut(duration: 0.5).repeatForever(autoreverses: true), value: viewModel.isComplete)
```

---

## WorkoutSummaryView

**Responsibility**: Apresentar resumo da sessão finalizada

### Props

```swift
struct WorkoutSummaryView: View {
    let session: WorkoutSession
    
    @Environment(\.dismiss) private var dismiss
    @State private var viewModel: WorkoutSummaryViewModel
    
    init(session: WorkoutSession) {
        self.session = session
        _viewModel = State(wrappedValue: WorkoutSummaryViewModel(session: session))
    }
}
```

### Layout

```swift
var body: some View {
    VStack(spacing: 30) {
        // Header
        VStack(spacing: 10) {
            Image(systemName: "checkmark.circle.fill")
                .font(.system(size: 60))
                .foregroundColor(.green)
            
            Text("Treino Concluído!")
                .font(.largeTitle.bold())
        }
        .padding(.top, 40)
        
        // Summary cards
        LazyVGrid(columns: [
            GridItem(.flexible()),
            GridItem(.flexible())
        ], spacing: 20) {
            SummaryCard(
                title: "Duração",
                value: viewModel.formattedDuration,
                icon: "clock.fill"
            )
            
            SummaryCard(
                title: "Exercícios",
                value: "\(viewModel.completedExercisesCount)",
                icon: "figure.strengthtraining.traditional"
            )
            
            SummaryCard(
                title: "Séries",
                value: "\(viewModel.totalSets)",
                icon: "square.stack.3d.up.fill"
            )
            
            SummaryCard(
                title: "Repetições",
                value: "\(viewModel.totalReps)",
                icon: "number"
            )
        }
        .padding()
        
        Spacer()
        
        // Action button
        Button {
            dismiss()
        } label: {
            Text("Finalizar")
                .font(.headline)
                .frame(maxWidth: .infinity)
                .padding()
        }
        .buttonStyle(.borderedProminent)
        .padding()
    }
    .navigationBarBackButtonHidden()
}
```

---

## Shared Components

### ExerciseExecutionRow

```swift
struct ExerciseExecutionRow: View {
    let exercise: Exercise
    let status: WorkoutSessionViewModel.ExerciseStatus
    
    var body: some View {
        HStack {
            // Status indicator
            Circle()
                .fill(statusColor)
                .frame(width: 12, height: 12)
            
            VStack(alignment: .leading, spacing: 4) {
                Text(exercise.name)
                    .font(.headline)
                
                Text(exercise.muscleGroup.rawValue)
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
            
            Spacer()
            
            // Badge
            statusBadge
        }
        .padding(.vertical, 8)
    }
    
    private var statusColor: Color {
        switch status {
        case .pending: return .gray
        case .inProgress: return .blue
        case .completed: return .green
        }
    }
    
    @ViewBuilder
    private var statusBadge: some View {
        switch status {
        case .pending:
            EmptyView()
        case .inProgress:
            Image(systemName: "arrow.right.circle.fill")
                .foregroundColor(.blue)
        case .completed:
            Image(systemName: "checkmark.circle.fill")
                .foregroundColor(.green)
        }
    }
}
```

### SetInputView

```swift
struct SetInputView: View {
    @Binding var weightText: String
    @Binding var repsText: String
    let weightError: String?
    let repsError: String?
    let onWeightChange: () -> Void
    let onRepsChange: () -> Void
    
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            // Weight input
            HStack {
                TextField("Peso (kg)", text: $weightText)
                    .keyboardType(.decimalPad)
                    .textFieldStyle(.roundedBorder)
                    .onChange(of: weightText) { _, _ in onWeightChange() }
                    .overlay(
                        RoundedRectangle(cornerRadius: 8)
                            .stroke(weightError != nil ? Color.red : Color.clear, lineWidth: 2)
                    )
                
                Text("kg")
                    .foregroundColor(.secondary)
            }
            
            if let error = weightError {
                ValidationFeedback(message: error)
            }
            
            // Reps input
            HStack {
                TextField("Repetições", text: $repsText)
                    .keyboardType(.numberPad)
                    .textFieldStyle(.roundedBorder)
                    .onChange(of: repsText) { _, _ in onRepsChange() }
                    .overlay(
                        RoundedRectangle(cornerRadius: 8)
                            .stroke(repsError != nil ? Color.red : Color.clear, lineWidth: 2)
                    )
                
                Text("reps")
                    .foregroundColor(.secondary)
            }
            
            if let error = repsError {
                ValidationFeedback(message: error)
            }
        }
    }
}
```

### ValidationFeedback

```swift
struct ValidationFeedback: View {
    let message: String
    
    var body: some View {
        HStack(spacing: 4) {
            Image(systemName: "exclamationmark.triangle.fill")
                .font(.caption)
            
            Text(message)
                .font(.caption)
        }
        .foregroundColor(.red)
    }
}
```

### ProgressRing

```swift
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
                    .stroke(style: StrokeStyle(lineWidth: 15, lineCap: .round, lineJoin: .round))
                    .foregroundColor(.green)
                    .rotationEffect(Angle(degrees: 270))
            )
    }
}
```

### SummaryCard

```swift
struct SummaryCard: View {
    let title: String
    let value: String
    let icon: String
    
    var body: some View {
        VStack(spacing: 12) {
            Image(systemName: icon)
                .font(.title2)
                .foregroundColor(.accentColor)
            
            Text(value)
                .font(.title.bold())
            
            Text(title)
                .font(.caption)
                .foregroundColor(.secondary)
        }
        .frame(maxWidth: .infinity)
        .padding()
        .background(.regularMaterial)
        .cornerRadius(12)
    }
}
```

---

## SwiftUI Previews

All views MUST have previews:

```swift
#Preview("Execute Workout") {
    ExecuteWorkoutView(workoutPlan: SampleData.workoutPlan)
        .modelContainer(for: [WorkoutPlan.self, Exercise.self, WorkoutSession.self, ExerciseSet.self])
}

#Preview("Rest Timer") {
    RestTimerView(restTime: 60)
}

#Preview("Summary") {
    WorkoutSummaryView(session: SampleData.completedSession)
}
```

---

## Localization

All user-facing strings must use String catalogs:

```swift
Text("Treino Concluído!")  // → Localizable.strings

// Pluralization
Text("\(count) exercícios completos")  // → handled by String catalog
```

---

## Summary

**Views Defined**: 8
- ExecuteWorkoutView (root)
- ExecuteExerciseView (detail)
- RestTimerView (modal)
- WorkoutSummaryView (result)
- ExerciseExecutionRow (component)
- SetInputView (component)
- ProgressRing (component)
- SummaryCard (component)

**Key Patterns**:
- NavigationStack for hierarchy
- Sheet for modals (timer, exercise)
- @State for local state
- @Environment for dependencies
- Accessibility labels on all interactive elements
- Dark mode via system colors
- SwiftUI Previews for all views

All view contracts defined. Ready for implementation.
