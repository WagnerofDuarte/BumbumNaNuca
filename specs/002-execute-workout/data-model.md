# Data Model: Executar Treino

**Feature**: 002-execute-workout  
**Date**: 2026-01-07  
**Purpose**: Definir estrutura de dados para execução de treinos

## Overview

Esta feature adiciona dois novos modelos SwiftData (`WorkoutSession` e `ExerciseSet`) e estende o modelo existente `Exercise` com configurações de execução.

## Entity Relationship Diagram

```
┌─────────────────┐
│  WorkoutPlan    │ (Existing)
│─────────────────│
│ + id: UUID      │
│ + name: String  │
│ + isActive: Bool│
└────────┬────────┘
         │ 1
         │ has many
         │ n
    ┌────▼─────────┐
    │  Exercise    │ (Existing, Extended)
    │──────────────│
    │ + id: UUID   │
    │ + name: String│
    │ + muscleGroup │
    │ + defaultSets │      NEW ──┐
    │ + defaultReps │      NEW ──┤ Phase 1 additions
    │ + defaultRestTime │   NEW ──┘
    └────┬─────────┘
         │ 1
         │ referenced by
         │ n
    ┌────▼──────────────┐
    │  ExerciseSet      │ (NEW)
    │───────────────────│
    │ + id: UUID        │
    │ + setNumber: Int  │
    │ + weight: Double? │ (nil = bodyweight)
    │ + reps: Int       │
    │ + completedDate   │
    │ + notes: String   │
    └────┬──────────────┘
         │ n
         │ belongs to
         │ 1
    ┌────▼─────────────────┐
    │  WorkoutSession      │ (NEW)
    │──────────────────────│
    │ + id: UUID           │
    │ + startDate: Date    │
    │ + endDate: Date?     │
    │ + isCompleted: Bool  │
    │ + notes: String      │
    └──────┬───────────────┘
           │ n
           │ belongs to
           │ 1
      ┌────▼──────────┐
      │  WorkoutPlan  │
      └───────────────┘
```

## Entity Definitions

### WorkoutSession (NEW)

**Purpose**: Representa uma sessão de treino executada pelo usuário.

**Attributes**:
| Name | Type | Constraints | Description |
|------|------|-------------|-------------|
| id | UUID | Unique, Not null | Identificador único |
| startDate | Date | Not null | Data/hora de início da sessão |
| endDate | Date | Optional | Data/hora de conclusão (nil se não finalizada) |
| isCompleted | Bool | Not null, Default: false | Flag explícito de conclusão |
| notes | String | Default: "" | Observações opcionais da sessão |

**Relationships**:
- **workoutPlan**: Muitos-para-um com WorkoutPlan (opcional se plano deletado)
- **exerciseSets**: Um-para-muitos com ExerciseSet (cascade delete)

**Business Rules**:
1. `startDate` DEVE ser definido na criação
2. `endDate` só é definido quando sessão é marcada como completa
3. `isCompleted = true` implica `endDate != nil`
4. Séries (`exerciseSets`) podem existir mesmo se `isCompleted = false` (sessões parciais)

**Validation**:
```swift
func validate() throws {
    if isCompleted && endDate == nil {
        throw ValidationError.incompleteDateMissing
    }
    if let end = endDate, end < startDate {
        throw ValidationError.endBeforeStart
    }
}
```

**Computed Properties**:
```swift
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
```

---

### ExerciseSet (NEW)

**Purpose**: Representa uma série individual executada durante uma sessão.

**Attributes**:
| Name | Type | Constraints | Description |
|------|------|-------------|-------------|
| id | UUID | Unique, Not null | Identificador único |
| setNumber | Int | Not null, >= 1 | Número da série (1, 2, 3...) |
| weight | Double | Optional, > 0 if present | Peso usado (kg). Nil = peso corporal |
| reps | Int | Not null, > 0 | Número de repetições executadas |
| completedDate | Date | Not null | Data/hora de conclusão da série |
| notes | String | Default: "" | Observações opcionais |

**Relationships**:
- **exercise**: Muitos-para-um com Exercise (opcional para histórico)
- **session**: Muitos-para-um com WorkoutSession (obrigatório, cascade delete)

**Business Rules**:
1. `weight = nil` representa exercício com peso corporal (ex: flexões)
2. `weight` se presente DEVE ser > 0
3. `reps` DEVE ser > 0
4. `setNumber` indica ordem dentro do exercício na sessão

**Validation**:
```swift
func validate() throws {
    guard reps > 0 else {
        throw ValidationError.invalidReps
    }
    if let w = weight, w <= 0 {
        throw ValidationError.invalidWeight
    }
}
```

**Computed Properties**:
```swift
var formattedWeight: String {
    guard let w = weight else { return "Peso corporal" }
    return String(format: "%.1f kg", w)
}

var oneRepMax: Double? {
    guard let w = weight else { return nil }
    // Brzycki formula: weight / (1.0278 - 0.0278 * reps)
    return w / (1.0278 - 0.0278 * Double(reps))
}
```

---

### Exercise (EXTENDED)

**New Attributes for Execution**:
| Name | Type | Constraints | Description |
|------|------|-------------|-------------|
| defaultSets | Int | Not null, Default: 3, Range: 1-10 | Número padrão de séries |
| defaultReps | Int | Not null, Default: 12, Range: 1-50 | Número padrão de repetições |
| defaultRestTime | Int | Not null, Default: 60, Range: 0-300 | Tempo de descanso (segundos) |

**Migration**:
Existing `Exercise` records will receive default values:
- `defaultSets = 3`
- `defaultReps = 12`
- `defaultRestTime = 60`

**Validation**:
```swift
func validate() throws {
    guard (1...10).contains(defaultSets) else {
        throw ValidationError.invalidDefaultSets
    }
    guard (1...50).contains(defaultReps) else {
        throw ValidationError.invalidDefaultReps
    }
    guard (0...300).contains(defaultRestTime) else {
        throw ValidationError.invalidRestTime
    }
}
```

---

## SwiftData Schema Evolution

### Current Schema (v1)
```swift
Schema([
    WorkoutPlan.self,
    Exercise.self,
    MuscleGroup.self
])
```

### New Schema (v2)
```swift
Schema([
    WorkoutPlan.self,
    Exercise.self,
    MuscleGroup.self,
    WorkoutSession.self,  // NEW
    ExerciseSet.self      // NEW
])
```

### Migration Strategy

**Lightweight Migration**: SwiftData auto-migrates when adding new models and properties with defaults.

**Steps**:
1. Add `WorkoutSession` and `ExerciseSet` to schema
2. Add new properties to `Exercise` (all have default values)
3. SwiftData handles migration automatically on app launch

**Rollback Plan**: 
If migration fails, app won't launch. Mitigation: Test migration thoroughly on dev devices before release.

---

## Indexes and Performance

### Recommended Indexes (Future Optimization)

```swift
@Model
class WorkoutSession {
    @Attribute(.unique) var id: UUID
    
    // Index for "find last session of plan" queries
    // Note: SwiftData doesn't expose explicit indexing in current version
    // Relies on automatic optimization
}
```

**Query Patterns to Optimize**:
1. Find last completed session for a plan: `workoutPlan.id + isCompleted + endDate DESC`
2. Find sets for specific exercise in session: `session.id + exercise.id`

**Expected Performance**:
- Typical dataset: 100 sessions, 1000 sets
- Query time: <10ms (tested with CoreData predecessor)

---

## Data Integrity Constraints

### Referential Integrity
- `ExerciseSet.session`: Required (cascade delete with session)
- `ExerciseSet.exercise`: Optional (allow orphaned sets if exercise deleted)
- `WorkoutSession.workoutPlan`: Optional (allow orphaned sessions if plan deleted)

### Business Logic Constraints
1. **Immutability**: Once `isCompleted = true`, session should not be modified
2. **Consistency**: `exerciseSets` should only contain sets from exercises in `workoutPlan`
3. **Timeline**: `completedDate` of sets should be between `startDate` and `endDate` of session

**Enforcement**: Via ViewModel logic, not database constraints (SwiftData limitation).

---

## Sample Data

### Example Workout Session

```swift
// Session
WorkoutSession(
    id: UUID(),
    startDate: Date(),
    endDate: Date().addingTimeInterval(3600), // 1 hour later
    isCompleted: true,
    notes: ""
)

// Sets
ExerciseSet(
    id: UUID(),
    setNumber: 1,
    weight: 80.0,
    reps: 10,
    completedDate: Date(),
    notes: "",
    exercise: benchPressExercise,
    session: workoutSession
)

ExerciseSet(
    id: UUID(),
    setNumber: 2,
    weight: 80.0,
    reps: 8,
    completedDate: Date().addingTimeInterval(90), // 90s later
    notes: "Felt harder than first set",
    exercise: benchPressExercise,
    session: workoutSession
)
```

---

## State Transitions

### WorkoutSession States

```
┌─────────────┐
│   Created   │ (isCompleted = false, endDate = nil)
│ startDate ✓ │
└──────┬──────┘
       │ Add sets
       ▼
┌─────────────┐
│ In Progress │ (isCompleted = false, endDate = nil, sets > 0)
│  Recording  │
└──────┬──────┘
       │ Finalize
       ▼
┌─────────────┐
│  Completed  │ (isCompleted = true, endDate ✓)
│   Finished  │
└─────────────┘

Note: Session can be finalized at any point (partial completion allowed)
```

---

## Privacy and Security

**Data Classification**:
- **Personal**: Workout data (sets, reps, weights) - user-specific performance
- **Sensitive**: No PII, no health data (HealthKit integration is v2.0)
- **Retention**: Indefinite (user can manually delete via future feature)

**Security Measures**:
- SwiftData encryption at rest (iOS default)
- No cloud sync in MVP (local-only)
- No logging of actual workout data (only events like "session started")

---

## Testing Considerations

### Unit Test Scenarios
1. Create session with valid data
2. Add sets to session
3. Calculate duration, totals correctly
4. Validate constraints (reps > 0, weight > 0 if present)
5. Handle nil endDate for incomplete sessions

### Edge Cases to Test
1. Session with zero sets (valid)
2. Session with 100+ sets (performance)
3. Concurrent modifications (SwiftUI previews + tests)
4. Orphaned sets (exercise deleted, set remains)

---

## Summary

**New Models**: 2 (WorkoutSession, ExerciseSet)
**Extended Models**: 1 (Exercise - 3 new properties)
**Relationships**: 4 (2 per new model)
**Migration**: Lightweight, automatic
**Performance**: Expected <10ms queries on typical dataset

All unknowns resolved. Ready for contract definition.
