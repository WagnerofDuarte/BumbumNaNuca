# Research: Executar Treino

**Feature**: 002-execute-workout  
**Date**: 2026-01-07  
**Purpose**: Consolidar decisões técnicas e patterns para implementação

## Research Tasks Completed

### 1. SwiftData Timer Background Execution

**Decision**: Usar Combine Timer com Background Task API

**Rationale**: 
- Timer precisa continuar por até 3 minutos em background (FR-014)
- SwiftUI não garante execução de Timer em background por padrão
- Background Task API permite solicitar tempo adicional ao iOS

**Implementation Approach**:
```swift
// RestTimerViewModel
import Combine

class RestTimerViewModel: ObservableObject {
    @Published var remainingTime: TimeInterval
    private var timerCancellable: AnyCancellable?
    private var backgroundTask: UIBackgroundTaskIdentifier = .invalid
    
    func startTimer() {
        // Request background time
        backgroundTask = UIApplication.shared.beginBackgroundTask {
            self.stopTimer()
        }
        
        timerCancellable = Timer.publish(every: 1, on: .main, in: .common)
            .autoconnect()
            .sink { [weak self] _ in
                self?.tick()
            }
    }
}
```

**Alternatives Considered**:
- AVAudioPlayer silent audio: Hacky, pode ser rejeitado pela App Review
- Local notifications: Não permite controle granular do timer visual
- Combine Timer apenas: Não garante 3min em background

**References**:
- Apple Docs: Background Execution
- HIG: Background Tasks

---

### 2. Haptic Feedback Patterns

**Decision**: Usar UINotificationFeedbackGenerator com .success type

**Rationale**:
- Timer completion é um evento positivo
- .success fornece feedback distintivo sem ser intrusivo
- Respeita configurações do sistema automaticamente

**Implementation**:
```swift
class HapticFeedback {
    static let shared = HapticFeedback()
    private let notificationGenerator = UINotificationFeedbackGenerator()
    
    func timerCompleted() {
        notificationGenerator.notificationOccurred(.success)
    }
}
```

**Alternatives Considered**:
- UIImpactFeedbackGenerator: Menos específico semanticamente
- Custom vibration pattern: Desnecessariamente complexo

---

### 3. Real-time Input Validation Pattern

**Decision**: SwiftUI @FocusState + computed validation state

**Rationale**:
- Validação em tempo real sem rerender excessivo
- Feedback visual inline com SwiftUI native styling
- Não bloqueia digitação, apenas indica erro

**Implementation**:
```swift
struct SetInputView: View {
    @State private var weightText = ""
    @State private var repsText = ""
    
    private var isWeightValid: Bool {
        weightText.isEmpty || (Double(weightText) ?? -1) > 0
    }
    
    private var isRepsValid: Bool {
        guard let reps = Int(repsText) else { return false }
        return reps > 0
    }
    
    var body: some View {
        TextField("Peso (kg)", text: $weightText)
            .keyboardType(.decimalPad)
            .border(isWeightValid ? .clear : .red, width: 2)
        
        if !isWeightValid {
            Text("Peso deve ser positivo")
                .font(.caption)
                .foregroundColor(.red)
        }
    }
}
```

**Alternatives Considered**:
- OnSubmit validation only: Não atende FR-022 (tempo real)
- Custom Combine publisher: Over-engineering para caso de uso simples

---

### 4. SwiftData Query Patterns for "Last Workout"

**Decision**: SwiftData @Query com Predicate + sort

**Rationale**:
- Buscar última sessão completa do mesmo plano (clarificação #2)
- SwiftData permite predicates expressivos
- Sort por endDate descendente + limit 1

**Implementation**:
```swift
// In ExecuteExerciseViewModel
@Query(
    filter: #Predicate<WorkoutSession> { session in
        session.workoutPlan?.id == workoutPlanId &&
        session.isCompleted == true
    },
    sort: \WorkoutSession.endDate,
    order: .reverse
) 
private var previousSessions: [WorkoutSession]

var lastWorkoutData: String? {
    guard let lastSession = previousSessions.first,
          let sets = lastSession.exerciseSets.filter({ $0.exercise?.id == currentExerciseId }) else {
        return nil
    }
    
    // Return formatted string, e.g., "Último: 80kg × 10 reps"
}
```

**Alternatives Considered**:
- Fetch all sessions then filter in memory: Menos eficiente
- Store "last workout" on Exercise model: Denormalized, harder to maintain

---

### 5. Session State Management

**Decision**: SwiftData auto-save + explicit isCompleted flag

**Rationale**:
- FR-007: Persistência incremental (cada série salva imediatamente)
- FR-027: Preservar dados mesmo sem finalização formal
- SwiftData auto-save garante persistência sem código extra

**Implementation**:
```swift
@Model
class WorkoutSession {
    var startDate: Date
    var endDate: Date?
    var isCompleted: Bool = false  // Explicit completion marker
    // ...
    
    @Relationship(deleteRule: .cascade)
    var exerciseSets: [ExerciseSet] = []
}

// In ViewModel
func saveSet(weight: Double?, reps: Int) {
    let set = ExerciseSet(...)
    session.exerciseSets.append(set)
    // SwiftData auto-saves via modelContext
}
```

**Abandoned Sessions Handling**:
- Edge case: Sessão aberta por dias
- Solution: Não adicionar auto-cleanup no MVP (low priority edge case)
- Future: Add background task to mark old incomplete sessions

---

### 6. Audio Playback for Timer

**Decision**: AVFoundation system sounds (AudioServicesPlaySystemSound)

**Rationale**:
- Respeita Silent Mode automaticamente (FR-012)
- Som breve e não-intrusivo
- Não requer audio session management

**Implementation**:
```swift
import AVFoundation

class AudioFeedback {
    static func playTimerComplete() {
        AudioServicesPlaySystemSound(1057) // SMS Received tone
    }
}
```

**Alternatives Considered**:
- AVAudioPlayer with custom sound: Mais controle, mas over-engineering
- Local notification sound: Não sincroniza com timer visual

---

## Technology Stack Decisions

### Primary Frameworks
- **SwiftUI**: All UI components (constitution principle I)
- **SwiftData**: Persistence layer (existing choice)
- **Combine**: Timer management
- **AVFoundation**: Audio feedback
- **UIKit (limited)**: Haptic feedback, background tasks

### No Third-Party Dependencies
Following constitution constraint: avoid external libraries unless necessary. All requirements can be met with Apple frameworks.

---

## Pattern Decisions

### MVVM Architecture
- **View**: Pure SwiftUI, minimal logic
- **ViewModel**: @Observable, business logic, validation, data fetching
- **Model**: SwiftData models (WorkoutSession, ExerciseSet)

### Data Flow
1. User action in View
2. ViewModel updates @Published state
3. SwiftData modelContext auto-saves
4. View reactively updates via @Query or @Published

### Testing Strategy
- **Unit Tests**: ViewModels (validation, calculations, timer logic)
- **UI Tests**: P1 flow end-to-end
- **Mocking**: Protocol-based for dependencies (e.g., TimerProtocol for testing)

---

## Performance Considerations

### Identified Bottlenecks
1. **SwiftData queries**: Last workout lookup per exercise
   - **Mitigation**: Cache result in ViewModel during session
   
2. **Timer updates**: Every 1 second
   - **Mitigation**: Use Combine debounce if needed, but 1Hz is negligible
   
3. **Real-time validation**: On every keystroke
   - **Mitigation**: Computed properties are cheap for simple number validation

### Memory Budget
- Active session: ~50KB (worst case: 50 exercises × 10 sets)
- Timer: Negligible
- Target: <5MB total for Execute feature

---

## Accessibility Considerations

### VoiceOver
- Timer countdown: Announce every 30s + at 10s
- Exercise progress: "Exercise 3 of 8, Bench Press"
- Set inputs: "Weight in kilograms, Repetitions"

### Dynamic Type
- All text uses `.body`, `.caption`, etc. (scales automatically)
- Minimum touch targets: 44×44pt

### Contrast
- Error states: System red (.red) meets WCAG AA
- Timer progress ring: High contrast colors

---

## Open Questions / Deferred Decisions

### Low-Priority Edge Cases (Not Blocking MVP)
1. **Sessões abertas por dias**: Sem auto-cleanup no MVP
2. **Fechamento forçado do app**: SwiftData auto-save should handle, verify in tests
3. **Timer e bateria esgotada**: iOS handles, timer resumes on reopen if <3min
4. **Exercícios sem tempo de descanso**: Default to 60s or skip timer (implement skip logic)
5. **Série sem peso nem reps**: Block save button (validation prevents this)

### Future Enhancements (Post-MVP)
- Gráficos de progresso (v1.2 per MVP spec)
- Apple Watch integration (v2.0)
- HealthKit integration (v2.0)

---

## Edge Cases Resolution

**Source**: spec.md Edge Cases section - 5 scenarios requiring technical decisions

### Edge Case 1: Sessão aberta por horas/dias sem finalizar

**Scenario**: Usuário inicia sessão às 08:00, não finaliza, retorna 3 dias depois.

**Solution**:
- Detecção: `checkExistingSession()` encontra sessão com `isCompleted = false`
- UX: Alert oferece "Retomar" ou "Abandonar e Iniciar Nova"
- Se abandonar: marca sessão antiga como `isCompleted = true` com `endDate = now`, preserva séries registradas
- Se retomar: carrega estado da sessão antiga, permite continuar adicionando séries
- **Implementação**: WorkoutSessionViewModel.checkExistingSession() (Task T083-T084)
- **Teste**: ExecuteWorkoutUITests (Task T098)

**Data Integrity**: Séries antigas mantêm `completedDate` original, novas séries têm timestamp atual.

### Edge Case 2: Fechamento forçado do app durante sessão ativa

**Scenario**: Usuário registra 2 séries, iOS força fechamento do app (memory pressure).

**Solution**:
- SwiftData auto-save: Cada série é salva imediatamente via `recordSet()` (FR-007)
- Persistência incremental: Não depende de `finalizeSession()` para salvar dados
- Reabertura: `checkExistingSession()` detecta sessão não finalizada
- Usuário pode retomar ou finalizar com dados parciais
- **Implementação**: ExecuteExerciseViewModel.recordSet() com immediate save (Task T023)
- **Teste**: Unit test verifica persistência após recordSet (Task T036, T096)

**Garantia**: 100% das séries registradas são preservadas (SC-005).

### Edge Case 3: Timer de descanso ativo quando dispositivo fica sem bateria

**Scenario**: Timer em 00:45, dispositivo desliga por bateria esgotada.

**Solution**:
- iOS suspende background task quando bateria crítica
- Timer state: `isPaused = true`, `remainingTime` salvo
- Reabertura: Timer não retoma automaticamente
- UX: RestTimerView dismiss automaticamente, usuário pode iniciar nova série manualmente
- **Implementação**: RestTimerViewModel.enterBackground() salva estado (Task T044)
- **Teste**: Simulação de backgrounding em RestTimerViewModelTests (Task T056)

**Alternativa MVP**: Timer cancela em background > 3min, usuário perde progresso mas pode pular manualmente.

### Edge Case 4: Exercícios sem tempo de descanso configurado

**Scenario**: Exercício com `defaultRestTime = 0` (usuário não quer descanso).

**Solution**:
- Validação: Exercise.validate() aceita `defaultRestTime = 0` (range 0-300)
- Lógica: ExecuteExerciseView verifica `if exercise.defaultRestTime > 0` antes de mostrar RestTimerView
- Se `= 0`: Pula timer, retorna direto para input de próxima série
- **Implementação**: Condicional em ExecuteExerciseView.recordSet() (Task T019)
- **Teste**: Unit test com defaultRestTime = 0 (Task T055)

**Data Model**: defaultRestTime migration define 60s, mas usuário pode editar para 0 (feature futura).

### Edge Case 5: Registrar série sem inserir peso nem repetições

**Scenario**: Usuário toca "Concluir Série" com campos vazios.

**Solution**:
- Validação tempo real: `isFormValid` computed property verifica `!repsText.isEmpty` e `repsError == nil`
- Button disabled: `Button("Concluir Série").disabled(!viewModel.isFormValid)`
- Peso vazio: VÁLIDO (= peso corporal, FR-005)
- Reps vazio: INVÁLIDO, button disabled
- **Implementação**: ExecuteExerciseViewModel.isFormValid (Task T021-T022)
- **Teste**: ValidationTests (Task T034-T035)

**UX**: Feedback inline com ValidationFeedback component mostra "Repetições devem ser maior que zero".

---

## Summary

All technical uncertainties resolved. Ready for Phase 1 (data model and contracts design).

**Key Decisions**:
- Combine Timer + Background Task for 3min background execution
- UINotificationFeedbackGenerator for haptics
- SwiftUI native validation with computed properties
- SwiftData @Query with Predicate for last workout lookup
- System sounds for audio feedback
- No third-party dependencies

**Risks Mitigated**:
- Timer background execution: Tested approach with Background Task API
- Performance: Validation and queries are cheap operations
- Accessibility: VoiceOver labels and dynamic type planned from start
