# Data Model: Exercise Execution Refinement

**Feature**: 004-exercise-execution-refinement  
**Date**: 2026-01-10  
**Purpose**: Define model changes for load tracking and automatic set recording

## Overview

This feature requires minimal model changes:
1. **Exercise**: Add optional `load` field for weight tracking
2. **ExerciseSet**: Already supports weight/reps, no changes needed
3. **WorkoutSession**: No changes needed

All models use SwiftData for persistence with automatic schema migration.

---

## Modified Entities

### Exercise (MODIFICATION)

**Purpose**: Represent a workout exercise with configured parameters including optional load

**File**: `BumbumNaNuca/Models/Exercise.swift`

#### Current Schema

```swift
@Model
final class Exercise {
    @Attribute(.unique) var id: UUID
    var name: String
    var muscleGroup: MuscleGroup
    var defaultSets: Int
    var defaultReps: Int
    var defaultRestTime: Int
    var order: Int
    var workoutPlan: WorkoutPlan?
}
```

#### New Schema (with load field)

```swift
@Model
final class Exercise {
    @Attribute(.unique) var id: UUID
    var name: String
    var muscleGroup: MuscleGroup
    var defaultSets: Int
    var defaultReps: Int
    var defaultRestTime: Int
    var order: Int
    
    // NEW: Optional load in kilograms
    var load: Double?
    
    var workoutPlan: WorkoutPlan?
    
    init(
        id: UUID = UUID(),
        name: String,
        muscleGroup: MuscleGroup,
        defaultSets: Int = 3,
        defaultReps: Int = 12,
        defaultRestTime: Int = 60,
        order: Int = 0,
        load: Double? = nil  // NEW parameter
    ) {
        self.id = id
        self.name = name
        self.muscleGroup = muscleGroup
        self.defaultSets = defaultSets
        self.defaultReps = defaultReps
        self.defaultRestTime = defaultRestTime
        self.order = order
        self.load = load  // NEW assignment
    }
}
```

#### Changes Summary

| Field | Type | Change | Purpose |
|-------|------|--------|---------|
| `load` | `Double?` | ADDED | Store configured weight in Kg (nil = bodyweight or not specified) |

#### Migration Strategy

- **Backward Compatible**: YES - Optional field defaults to `nil`
- **SwiftData Migration**: Automatic - no manual migration code needed
- **Existing Data**: All existing Exercise records will have `load = nil` after migration
- **Versioning**: This is a non-breaking additive change

#### Validation Rules

```swift
extension Exercise {
    func validateLoad() throws {
        if let l = load, l <= 0 {
            throw ValidationError.invalidLoad("Load must be greater than 0 kg")
        }
        // Practical upper limit check (optional safety)
        if let l = load, l > 500 {
            throw ValidationError.invalidLoad("Load exceeds practical limit (500 kg)")
        }
    }
}

enum ValidationError: LocalizedError {
    case invalidLoad(String)
    
    var errorDescription: String? {
        switch self {
        case .invalidLoad(let message): return message
        }
    }
}
```

#### Display Formatting

```swift
extension Exercise {
    var formattedLoad: String {
        guard let l = load else { return "Peso não especificado" }
        return String(format: "%.1f kg", l)
    }
}
```

---

### ExerciseSet (NO CHANGES)

**Purpose**: Track actual performance of a single set during workout execution

**File**: `BumbumNaNuca/Models/ExerciseSet.swift`

#### Current Schema (Sufficient)

```swift
@Model
final class ExerciseSet {
    @Attribute(.unique) var id: UUID
    var setNumber: Int
    var weight: Double?          // Already supports load tracking
    var reps: Int                 // Already tracks reps
    var completedDate: Date
    var notes: String
    
    @Relationship(deleteRule: .nullify)
    var exercise: Exercise?
    var session: WorkoutSession?
}
```

#### Why No Changes Needed

- `weight` field already exists for load tracking
- `reps` field already exists for repetition tracking
- Automatic recording will populate these fields from Exercise defaults:
  - `weight = exercise.load ?? 0`
  - `reps = exercise.defaultReps`

---

### WorkoutSession (NO CHANGES)

**Purpose**: Track an active or completed workout session

**File**: `BumbumNaNuca/Models/WorkoutSession.swift`

#### Current Schema (Sufficient)

```swift
@Model
final class WorkoutSession {
    @Attribute(.unique) var id: UUID
    var startDate: Date
    var endDate: Date?
    var notes: String
    
    @Relationship(deleteRule: .cascade)
    var sets: [ExerciseSet]
    var workoutPlan: WorkoutPlan?
}
```

#### Why No Changes Needed

- Session already tracks sets via relationship
- `endDate` already indicates completion
- No additional fields required for navigation fix

---

## Relationships

### Existing Relationships (Unchanged)

```
WorkoutPlan (1) ←→ (many) Exercise
WorkoutSession (1) ←→ (many) ExerciseSet
Exercise (1) ←→ (many) ExerciseSet
```

**Diagram**:
```
┌─────────────┐
│ WorkoutPlan │
└──────┬──────┘
       │ 1:N
       ↓
┌─────────────┐          ┌───────────────┐
│  Exercise   │ 1:N      │ WorkoutSession│
│  + load     │←────────→│               │
└──────┬──────┘          └───────┬───────┘
       │                         │
       │ 1:N                     │ 1:N
       ↓                         ↓
┌──────────────┐          ┌──────────────┐
│ ExerciseSet  │←─────────│ (same)       │
│ - weight     │          └──────────────┘
│ - reps       │
└──────────────┘
```

---

## Data Flow: Automatic Set Recording

### Before (Current - Manual Input)

```
User completes physical set
  ↓
User manually enters reps in TextField
  ↓
User manually enters load in TextField
  ↓
User presses "Registrar Série"
  ↓
ExerciseSet created with manual values
  ↓
ExerciseSet.weight = userInputLoad
ExerciseSet.reps = userInputReps
```

### After (New - Automatic Recording)

```
User completes physical set
  ↓
User presses "Começar Descanso"
  ↓
ViewModel.recordSet() called automatically
  ↓
ExerciseSet created with planned values
  ↓
ExerciseSet.weight = exercise.load
ExerciseSet.reps = exercise.defaultReps
ExerciseSet.setNumber = currentSetNumber
ExerciseSet.completedDate = Date()
  ↓
Timer starts
```

**Code Example**:
```swift
@Observable
class ExecuteExerciseViewModel {
    private let exercise: Exercise
    private let session: WorkoutSession
    private let modelContext: ModelContext
    private(set) var currentSetNumber = 1
    
    func recordSet() throws -> ExerciseSet {
        // Create set with automatic values from exercise config
        let set = ExerciseSet(
            setNumber: currentSetNumber,
            weight: exercise.load,           // Automatic from Exercise.load
            reps: exercise.defaultReps,      // Automatic from Exercise.defaultReps
            completedDate: Date()
        )
        
        set.exercise = exercise
        set.session = session
        
        // Persist
        modelContext.insert(set)
        session.sets.append(set)
        
        // Increment for next set
        currentSetNumber += 1
        
        return set
    }
}
```

---

## SwiftData Schema Versioning

### Current Version

```swift
// Implicit schema version from existing models
// Exercise v1.0: No load field
```

### New Version

```swift
// Exercise v1.1: Added optional load field
// SwiftData handles migration automatically
```

### Migration Code (None Required)

SwiftData's lightweight migration handles additive changes automatically:
- New optional field `load` defaults to `nil` for existing records
- No custom migration logic needed
- No data loss risk

### Testing Migration

```swift
// In manual testing:
1. Run app with old schema (no load field)
2. Create some exercises
3. Update code to new schema (with load field)
4. Run app - SwiftData migrates automatically
5. Verify existing exercises have load = nil
6. Create new exercise with load value
7. Verify new exercise stores load correctly
```

---

## Constraints & Validation

### Exercise Constraints

| Field | Constraint | Validation |
|-------|-----------|------------|
| `name` | Non-empty string | Required on creation |
| `defaultSets` | > 0 | Required on creation |
| `defaultReps` | > 0 | Required on creation |
| `defaultRestTime` | >= 0 | Default 60s if not specified |
| `load` | nil OR > 0 | Optional, validate if present |

### ExerciseSet Constraints

| Field | Constraint | Validation |
|-------|-----------|------------|
| `setNumber` | > 0 | Auto-assigned by ViewModel |
| `reps` | > 0 | Auto-copied from Exercise |
| `weight` | nil OR > 0 | Auto-copied from Exercise.load |
| `completedDate` | Valid date | Auto-assigned on creation |

---

## Edge Cases

### Load Field Edge Cases

1. **Exercise with no load specified (`load = nil`)**:
   - ExerciseSet.weight will be `nil`
   - Display as "Peso corporal" or "Não especificado"

2. **Existing exercises after migration**:
   - All have `load = nil` initially
   - User can edit to add load value
   - Historical ExerciseSets remain unchanged

3. **Zero load**:
   - Not allowed (validation error)
   - nil represents "no load specified"
   - Bodyweight exercises should use `load = nil`

### Set Recording Edge Cases

1. **User finishes exercise early (incomplete sets)**:
   - Confirmation dialog shown (per research.md)
   - If confirmed, remaining sets not recorded
   - Session still valid with partial data

2. **User backgrounds app mid-set**:
   - No set recorded until button press
   - Timer may be running (separate concern)
   - On return, set can still be completed

3. **SwiftData save failure**:
   - Error propagated to ViewModel
   - ViewModel.error published
   - User shown alert with retry option

---

## Performance Considerations

### Write Performance

- **ExerciseSet creation**: O(1) - single insert
- **Session.sets append**: O(1) - array append
- **SwiftData auto-save**: Background thread, non-blocking

### Read Performance

- **Exercise.load**: O(1) - direct property access
- **Session query for history**: Indexed by date, fast
- **Set count calculations**: O(n) where n = sets, typically <100

### Memory

- **Exercise with load**: +8 bytes (Double) per exercise
- **Minimal impact**: ~100 exercises = 800 bytes additional

---

## Summary

| Entity | Change | Migration | Backward Compatible |
|--------|--------|-----------|---------------------|
| Exercise | Add `load: Double?` | Automatic | Yes |
| ExerciseSet | No change | N/A | Yes |
| WorkoutSession | No change | N/A | Yes |

**Total Model Changes**: 1 field added, 0 fields removed, 0 relationships changed

**Risk Level**: **LOW**
- Additive change only
- Optional field (no required data)
- Automatic migration
- No breaking changes

**Ready for**: Implementation contracts (Phase 1)
