# Data Model: MVP Completion (Feature 003)

**Feature**: Home Dashboard + Check-in System + Progress Tracking  
**Date**: 08/01/2026  
**Branch**: `003-mvp-completion`

---

## Overview

Esta feature adiciona 1 novo modelo SwiftData (`CheckIn`) e 3 novos ViewModels (`HomeViewModel`, `CheckInViewModel`, `ProgressViewModel`) para completar o MVP. Reutiliza modelos existentes das Features 001 e 002.

---

## SwiftData Models

### CheckIn (NEW)

**Purpose**: Registrar presença diária do usuário na academia, usado para cálculo de sequências e estatísticas de frequência.

```swift
import SwiftData
import Foundation

@Model
final class CheckIn {
    /// Identificador único
    @Attribute(.unique) var id: UUID
    
    /// Data e hora completa do check-in (timestamp preciso)
    var date: Date
    
    /// Observações opcionais (não usado no MVP, preparação para futuro)
    var notes: String
    
    /// Relacionamento opcional com treino executado após check-in
    /// deleteRule .nullify: se WorkoutSession for deletada, CheckIn permanece
    @Relationship(deleteRule: .nullify)
    var workoutSession: WorkoutSession?
    
    init(id: UUID = UUID(), date: Date = Date(), notes: String = "") {
        self.id = id
        self.date = date
        self.notes = notes
    }
}
```

**Schema Migration**:
- **From**: Schema v1 (WorkoutPlan, Exercise, WorkoutSession, ExerciseSet)
- **To**: Schema v2 (adiciona CheckIn)
- **Migration Type**: Additive (não-breaking) - SwiftData auto-migration
- **Update**: BumbumNaNucaApp.swift schema registration

```swift
// BumbumNaNucaApp.swift
var sharedModelContainer: ModelContainer = {
    let schema = Schema([
        WorkoutPlan.self,
        Exercise.self,
        WorkoutSession.self,
        ExerciseSet.self,
        CheckIn.self  // 🆕 NEW
    ])
    let modelConfiguration = ModelConfiguration(schema: schema)
    return try! ModelContainer(for: schema, configurations: [modelConfiguration])
}()
```

**Validation Rules** (enforced in ViewModel):
- **Business Rule**: Máximo 1 check-in por dia calendário
- **Validation**: CheckInViewModel verifica existência antes de criar
- **Date Normalization**: Usar `Calendar.startOfDay` para comparações de dia

**Indexes & Performance**:
- `@Attribute(.unique)` em `id` cria índice automático
- Queries por `date` são frequentes - SwiftData usa índice implícito em Date fields
- Para 30-50 check-ins no histórico, performance é adequada sem otimizações adicionais

---

### Existing Models (References)

**WorkoutPlan** (Feature 001):
- `isActive: Bool` - usado em HomeViewModel para buscar plano ativo
- Relacionamento com `exercises: [Exercise]`

**WorkoutSession** (Feature 002):
- `isCompleted: Bool` - filtrar treinos completados em histórico
- `startDate: Date` - ordenar e calcular tempo relativo
- `endDate: Date?` - calcular duração
- Relacionamento com `exerciseSets: [ExerciseSet]`

**ExerciseSet** (Feature 002):
- Usado para cálculos de volume e recordes pessoais
- Relacionamento com `exercise: Exercise`

---

## ViewModels

### HomeViewModel

**Purpose**: Agregar dados de múltiplas fontes para dashboard principal (plano ativo, último treino, check-in do dia).

```swift
import SwiftData
import Foundation
import Observation

@Observable
final class HomeViewModel {
    // MARK: - Properties
    
    /// Plano de treino marcado como ativo (máximo 1)
    var activePlan: WorkoutPlan?
    
    /// Última sessão de treino completada
    var lastCompletedWorkout: WorkoutSession?
    
    /// Check-in de hoje (se existir)
    var todayCheckIn: CheckIn?
    
    /// Sequência atual de check-ins consecutivos
    var currentStreak: Int = 0
    
    /// Estado de carregamento
    var isLoading: Bool = false
    
    // MARK: - Computed Properties
    
    /// Indica se existe plano ativo
    var hasActivePlan: Bool {
        activePlan != nil
    }
    
    /// Indica se já fez check-in hoje
    var hasCheckInToday: Bool {
        todayCheckIn != nil
    }
    
    /// Texto do botão de check-in
    var checkInButtonText: String {
        hasCheckInToday ? "Check-in realizado ✓" : "Fazer Check-in"
    }
    
    /// Horário do check-in de hoje (formatado)
    var checkInTimeText: String? {
        todayCheckIn?.date.toTimeString()
    }
    
    // MARK: - Actions
    
    /// Carrega todos os dados do dashboard
    /// - Parameter context: ModelContext para queries SwiftData
    func loadDashboard(context: ModelContext) {
        isLoading = true
        defer { isLoading = false }
        
        // Buscar plano ativo
        activePlan = fetchActivePlan(context: context)
        
        // Buscar último treino completado
        lastCompletedWorkout = fetchLastCompletedWorkout(context: context)
        
        // Buscar check-in de hoje
        todayCheckIn = fetchTodayCheckIn(context: context)
        
        // Calcular sequência (usa últimos 30 check-ins para performance)
        currentStreak = calculateCurrentStreak(context: context)
    }
    
    /// Executa check-in rápido do dashboard
    /// - Parameter context: ModelContext para insert
    func performQuickCheckIn(context: ModelContext) {
        guard todayCheckIn == nil else { return }
        
        let checkIn = CheckIn(date: Date())
        context.insert(checkIn)
        
        // Atualizar propriedade local
        todayCheckIn = checkIn
        
        // Recalcular sequência
        currentStreak = calculateCurrentStreak(context: context)
    }
    
    // MARK: - Private Helpers
    
    private func fetchActivePlan(context: ModelContext) -> WorkoutPlan? {
        let descriptor = FetchDescriptor<WorkoutPlan>(
            predicate: #Predicate { $0.isActive == true }
        )
        return try? context.fetch(descriptor).first
    }
    
    private func fetchLastCompletedWorkout(context: ModelContext) -> WorkoutSession? {
        var descriptor = FetchDescriptor<WorkoutSession>(
            predicate: #Predicate { $0.isCompleted == true },
            sortBy: [SortDescriptor(\WorkoutSession.startDate, order: .reverse)]
        )
        descriptor.fetchLimit = 1
        return try? context.fetch(descriptor).first
    }
    
    private func fetchTodayCheckIn(context: ModelContext) -> CheckIn? {
        let calendar = Calendar.current
        let startOfDay = calendar.startOfDay(for: Date())
        let endOfDay = calendar.date(byAdding: .day, value: 1, to: startOfDay)!
        
        let descriptor = FetchDescriptor<CheckIn>(
            predicate: #Predicate { checkIn in
                checkIn.date >= startOfDay && checkIn.date < endOfDay
            }
        )
        return try? context.fetch(descriptor).first
    }
    
    private func calculateCurrentStreak(context: ModelContext) -> Int {
        var descriptor = FetchDescriptor<CheckIn>(
            sortBy: [SortDescriptor(\CheckIn.date, order: .reverse)]
        )
        descriptor.fetchLimit = 30  // Performance: limitar busca
        
        guard let checkIns = try? context.fetch(descriptor) else { return 0 }
        
        let dates = checkIns.map { $0.date }
        return CheckInStreak.calculateStreak(from: dates)
    }
}
```

---

### CheckInViewModel

**Purpose**: Gerenciar lógica de check-ins, calcular sequências, estatísticas mensais e listar histórico recente.

```swift
import SwiftData
import Foundation
import Observation

@Observable
final class CheckInViewModel {
    // MARK: - Properties
    
    /// Check-in de hoje (se existir)
    var todayCheckIn: CheckIn?
    
    /// Sequência atual de dias consecutivos
    var currentStreak: Int = 0
    
    /// Melhor sequência já alcançada (recorde pessoal)
    var longestStreak: Int = 0
    
    /// Estatísticas do mês atual
    var monthlyStats: MonthlyStats = MonthlyStats(totalCheckIns: 0, totalDaysInMonth: 0)
    
    /// Últimos 30 check-ins para exibição
    var recentCheckIns: [CheckIn] = []
    
    /// Estado de carregamento
    var isLoading: Bool = false
    
    // MARK: - Computed Properties
    
    /// Pode fazer check-in hoje?
    var canCheckInToday: Bool {
        todayCheckIn == nil
    }
    
    /// Texto do botão de check-in
    var checkInButtonText: String {
        if let checkIn = todayCheckIn {
            return "Check-in feito às \(checkIn.date.toTimeString())"
        }
        return "Fazer Check-in"
    }
    
    // MARK: - Actions
    
    /// Carrega todos os dados da tela de check-in
    func loadCheckInData(context: ModelContext) {
        isLoading = true
        defer { isLoading = false }
        
        // Check-in de hoje
        todayCheckIn = fetchTodayCheckIn(context: context)
        
        // Últimos check-ins (para calcular sequências e stats)
        recentCheckIns = fetchRecentCheckIns(context: context, limit: 60)
        
        // Calcular sequências
        let dates = recentCheckIns.map { $0.date }
        currentStreak = CheckInStreak.calculateStreak(from: dates)
        longestStreak = calculateLongestStreak(from: dates)
        
        // Estatísticas mensais
        monthlyStats = calculateMonthlyStats(from: recentCheckIns)
    }
    
    /// Executa check-in
    /// - Parameter context: ModelContext para insert
    /// - Returns: true se sucesso, false se já fez hoje
    @discardableResult
    func performCheckIn(context: ModelContext) -> Bool {
        guard canCheckInToday else { return false }
        
        let checkIn = CheckIn(date: Date())
        context.insert(checkIn)
        
        // Atualizar estado local
        todayCheckIn = checkIn
        recentCheckIns.insert(checkIn, at: 0)
        
        // Recalcular sequências e stats
        let dates = recentCheckIns.map { $0.date }
        currentStreak = CheckInStreak.calculateStreak(from: dates)
        longestStreak = max(longestStreak, currentStreak)
        monthlyStats = calculateMonthlyStats(from: recentCheckIns)
        
        return true
    }
    
    // MARK: - Private Helpers
    
    private func fetchTodayCheckIn(context: ModelContext) -> CheckIn? {
        let calendar = Calendar.current
        let startOfDay = calendar.startOfDay(for: Date())
        let endOfDay = calendar.date(byAdding: .day, value: 1, to: startOfDay)!
        
        let descriptor = FetchDescriptor<CheckIn>(
            predicate: #Predicate { $0.date >= startOfDay && $0.date < endOfDay }
        )
        return try? context.fetch(descriptor).first
    }
    
    private func fetchRecentCheckIns(context: ModelContext, limit: Int) -> [CheckIn] {
        var descriptor = FetchDescriptor<CheckIn>(
            sortBy: [SortDescriptor(\CheckIn.date, order: .reverse)]
        )
        descriptor.fetchLimit = limit
        return (try? context.fetch(descriptor)) ?? []
    }
    
    private func calculateLongestStreak(from dates: [Date]) -> Int {
        guard !dates.isEmpty else { return 0 }
        
        let calendar = Calendar.current
        let uniqueDays = Set(dates.map { calendar.startOfDay(for: $0) }).sorted(by: >)
        
        var longestStreak = 0
        var currentStreak = 0
        var expectedDate: Date?
        
        for day in uniqueDays {
            if let expected = expectedDate {
                if day == expected {
                    currentStreak += 1
                } else {
                    longestStreak = max(longestStreak, currentStreak)
                    currentStreak = 1
                }
            } else {
                currentStreak = 1
            }
            expectedDate = calendar.date(byAdding: .day, value: -1, to: day)
        }
        
        return max(longestStreak, currentStreak)
    }
    
    private func calculateMonthlyStats(from checkIns: [CheckIn]) -> MonthlyStats {
        let calendar = Calendar.current
        let now = Date()
        
        guard let startOfMonth = calendar.date(from: calendar.dateComponents([.year, .month], from: now)),
              let range = calendar.range(of: .day, in: .month, for: now)
        else {
            return MonthlyStats(totalCheckIns: 0, totalDaysInMonth: 0)
        }
        
        let totalDaysInMonth = range.count
        
        let endOfMonth = calendar.date(byAdding: DateComponents(month: 1, day: -1), to: startOfMonth)!
        
        let monthlyCheckIns = checkIns.filter { checkIn in
            checkIn.date >= startOfMonth && checkIn.date <= endOfMonth
        }
        
        return MonthlyStats(
            totalCheckIns: monthlyCheckIns.count,
            totalDaysInMonth: totalDaysInMonth
        )
    }
}

// MARK: - Supporting Types

struct MonthlyStats {
    let totalCheckIns: Int
    let totalDaysInMonth: Int
    
    var percentage: Double {
        guard totalDaysInMonth > 0 else { return 0 }
        return (Double(totalCheckIns) / Double(totalDaysInMonth)) * 100
    }
    
    var formattedPercentage: String {
        String(format: "%.0f%%", percentage)
    }
}
```

---

### ProgressViewModel

**Purpose**: Gerenciar histórico de treinos executados e histórico por exercício individual (recordes pessoais).

```swift
import SwiftData
import Foundation
import Observation

@Observable
final class ProgressViewModel {
    // MARK: - Types
    
    enum ProgressTab: String, CaseIterable {
        case workouts = "Treinos"
        case exercises = "Exercícios"
    }
    
    // MARK: - Properties
    
    /// Tab selecionada (Treinos ou Exercícios)
    var selectedTab: ProgressTab = .workouts
    
    /// Lista de treinos completados (limit 50 para performance)
    var completedSessions: [WorkoutSession] = []
    
    /// Lista de exercícios já executados com estatísticas
    var executedExercises: [ExerciseStats] = []
    
    /// Estado de carregamento
    var isLoading: Bool = false
    
    // MARK: - Actions
    
    /// Carrega histórico de treinos
    func loadWorkoutHistory(context: ModelContext, limit: Int = 50) {
        isLoading = true
        defer { isLoading = false }
        
        var descriptor = FetchDescriptor<WorkoutSession>(
            predicate: #Predicate { $0.isCompleted == true },
            sortBy: [SortDescriptor(\WorkoutSession.startDate, order: .reverse)]
        )
        descriptor.fetchLimit = limit
        descriptor.relationshipKeyPathsForPrefetching = [\WorkoutSession.exerciseSets]
        
        completedSessions = (try? context.fetch(descriptor)) ?? []
    }
    
    /// Carrega histórico de exercícios com estatísticas
    func loadExerciseHistory(context: ModelContext) {
        isLoading = true
        defer { isLoading = false }
        
        // Buscar todas as séries executadas
        let setsDescriptor = FetchDescriptor<ExerciseSet>(
            sortBy: [SortDescriptor(\ExerciseSet.completedDate, order: .reverse)]
        )
        setsDescriptor.relationshipKeyPathsForPrefetching = [\ExerciseSet.exercise]
        
        guard let allSets = try? context.fetch(setsDescriptor) else {
            executedExercises = []
            return
        }
        
        // Agrupar por exercício
        var exerciseDict: [String: [ExerciseSet]] = [:]
        for set in allSets {
            guard let exerciseName = set.exercise?.name else { continue }
            exerciseDict[exerciseName, default: []].append(set)
        }
        
        // Calcular estatísticas por exercício
        executedExercises = exerciseDict.map { name, sets in
            let sortedSets = sets.sorted { $0.completedDate > $1.completedDate }
            let lastExecution = sortedSets.first?.completedDate ?? Date()
            let personalRecord = calculatePersonalRecord(from: sortedSets)
            
            return ExerciseStats(
                exerciseName: name,
                lastExecutionDate: lastExecution,
                totalSetsExecuted: sortedSets.count,
                personalRecord: personalRecord
            )
        }.sorted { $0.lastExecutionDate > $1.lastExecutionDate }
    }
    
    // MARK: - Private Helpers
    
    private func calculatePersonalRecord(from sets: [ExerciseSet]) -> PersonalRecord? {
        guard !sets.isEmpty else { return nil }
        
        // Encontrar maior peso
        guard let maxWeightSet = sets.max(by: { ($0.weight ?? 0) < ($1.weight ?? 0) }),
              let maxWeight = maxWeightSet.weight
        else { return nil }
        
        // Entre séries com mesmo peso máximo, pegar maior reps
        let maxWeightSets = sets.filter { $0.weight == maxWeight }
        guard let bestSet = maxWeightSets.max(by: { $0.reps < $1.reps }) else {
            return nil
        }
        
        return PersonalRecord(
            weight: maxWeight,
            reps: bestSet.reps,
            date: bestSet.completedDate
        )
    }
}

// MARK: - Supporting Types

struct ExerciseStats: Identifiable {
    let exerciseName: String
    let lastExecutionDate: Date
    let totalSetsExecuted: Int
    let personalRecord: PersonalRecord?
    
    var id: String { exerciseName }
}

struct PersonalRecord {
    let weight: Double
    let reps: Int
    let date: Date
    
    var formattedRecord: String {
        String(format: "%.1fkg × %d", weight, reps)
    }
}
```

---

## Relationships Diagram

```
┌─────────────────┐
│  WorkoutPlan    │
│  (existing)     │◄───────┐
└─────────────────┘        │
        │                  │
        │ has many         │ references
        ▼                  │
┌─────────────────┐        │
│   Exercise      │        │
│   (existing)    │        │
└─────────────────┘        │
        │                  │
        │ used in          │
        ▼                  │
┌─────────────────┐        │
│  ExerciseSet    │        │
│  (existing)     │        │
└─────────────────┘        │
        │                  │
        │ part of          │
        ▼                  │
┌─────────────────┐        │
│ WorkoutSession  │        │
│  (existing)     │────────┘
└─────────────────┘
        ▲
        │ optional
        │ (.nullify)
        │
┌─────────────────┐
│    CheckIn      │◄─── 🆕 NEW
│     (NEW)       │
└─────────────────┘
```

**Key Relationships**:
- CheckIn → WorkoutSession: Optional, .nullify (check-in pode existir sem treino)
- Existing relationships preserved from Features 001/002

---

## Validation Rules

### CheckIn
- **Business Rule BR-001**: Máximo 1 check-in por dia calendário
  - **Enforcement**: CheckInViewModel.canCheckInToday (computed property)
  - **Validation**: Busca existente antes de criar novo
  
- **Data Integrity DI-001**: Date não pode ser futura
  - **Enforcement**: ViewModel usa Date() atual, UI não permite input manual
  
### Sequências
- **Business Rule BR-002**: Sequência considera dias consecutivos (sem pular)
  - **Enforcement**: CheckInStreak.calculateStreak() algorithm
  - **Edge Cases**: Handled in research.md (midnight, timezones, month transitions)

### Recordes Pessoais
- **Business Rule BR-003**: Recorde é maior peso × maior reps naquele peso
  - **Enforcement**: ProgressViewModel.calculatePersonalRecord()
  - **Tie-breaker**: Se mesmo peso, maior reps; se mesmo peso e reps, mais recente

---

## Performance Considerations

### Query Limits
- HomeViewModel: fetchLimit = 1 para queries pontuais
- CheckInViewModel: fetchLimit = 60 (2 meses de dados)
- ProgressViewModel: fetchLimit = 50 treinos

### Prefetching
- WorkoutSession queries prefetch `exerciseSets` para evitar N+1
- ExerciseSet queries prefetch `exercise` para nome

### Computed Properties
- Use computed properties em ViewModels para caching
- Recalcular apenas quando dados mudam (após insert/fetch)

### Memory
- Limite de 50 treinos/60 check-ins mantém <50MB conforme spec
- LazyVStack em Views para lazy loading

---

## Testing Strategy

### Manual Testing (per Constitution II)
- **Scenario 1**: Check-in diário por 7 dias → sequência = 7
- **Scenario 2**: Check-in dia 1,2,3, pula dia 4, check-in dia 5 → sequência = 1
- **Scenario 3**: Executar supino 80kg×10, 90kg×8, 100kg×6 → recorde = 100kg×6
- **Scenario 4**: Home com 50+ treinos carrega <1s
- **Scenario 5**: Edge case: check-in 23:59 + 00:01 → dias consecutivos

### Validation Checklist
- [ ] Apenas 1 check-in por dia permitido
- [ ] Sequência calcula corretamente
- [ ] Melhor sequência persiste após reset
- [ ] Stats mensais corretos para meses 28/30/31 dias
- [ ] Recorde pessoal identifica maior peso
- [ ] Empty states aparecem se sem dados
- [ ] Performance: Home <1s, Progresso <1s

---

## Migration Path

### From Schema v1 to v2

**Step 1**: Update BumbumNaNucaApp.swift schema
```swift
let schema = Schema([
    WorkoutPlan.self,
    Exercise.self,
    WorkoutSession.self,
    ExerciseSet.self,
    CheckIn.self  // Add this line
])
```

**Step 2**: SwiftData auto-migration
- No manual migration needed (additive change)
- Existing data unaffected
- New CheckIn table created automatically

**Step 3**: Verification
- Run app on device with existing data
- Verify existing WorkoutPlans/Sessions intact
- Create test CheckIn to verify new model works

**Rollback**: Remove CheckIn from schema, delete .sqlite files

---

## Future Enhancements (Out of Scope for MVP)

- CheckIn notes field usage (v1.1)
- Linking CheckIn automatically to WorkoutSession (v1.1)
- Export check-in history to CSV (v1.2)
- Notification reminders for check-ins (v1.2)
- Graphs for check-in trends (v1.2)
- Comparison of PRs over time (v1.3)

---

**Status**: ✅ Data model design complete. Ready for quickstart.md and implementation.
