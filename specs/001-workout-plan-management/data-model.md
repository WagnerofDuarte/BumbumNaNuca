# Data Model: Gerenciamento de Planos de Treino

**Phase**: 1 - Design  
**Date**: 6 de Janeiro de 2026  
**Feature**: [spec.md](spec.md) | [research.md](research.md)

## Overview

Schema de dados SwiftData para feature de gerenciamento de planos de treino. Modelo relacional simples com 3 entidades principais e relacionamentos cascade para garantir integridade referencial.

**Technology**: SwiftData (iOS 17+)  
**Storage**: SQLite local (on-device)  
**Sync**: None (MVP offline-only)

---

## Entities

### 1. WorkoutPlan

Representa um plano de treino nomeado criado pelo usuário.

**SwiftData Model**:
```swift
import SwiftData
import Foundation

@Model
final class WorkoutPlan {
    // Identity
    @Attribute(.unique) var id: UUID
    
    // Core attributes
    var name: String
    var description: String
    var createdDate: Date
    var isActive: Bool
    
    // Relationships
    @Relationship(deleteRule: .cascade, inverse: \Exercise.workoutPlan)
    var exercises: [Exercise]
    
    @Relationship(deleteRule: .nullify, inverse: \WorkoutSession.workoutPlan)
    var sessions: [WorkoutSession]
    
    // Initializer
    init(
        id: UUID = UUID(),
        name: String,
        description: String = "",
        createdDate: Date = Date(),
        isActive: Bool = false
    ) {
        self.id = id
        self.name = name
        self.description = description
        self.createdDate = createdDate
        self.isActive = isActive
        self.exercises = []
        self.sessions = []
    }
}
```

**Attributes**:

| Field | Type | Constraints | Description |
|-------|------|-------------|-------------|
| `id` | UUID | Unique, Primary Key | Identificador único imutável |
| `name` | String | Required, 3-100 chars | Nome do plano (validado no ViewModel) |
| `description` | String | Optional, max 500 chars | Descrição opcional do plano |
| `createdDate` | Date | Required, auto-set | Data de criação do plano |
| `isActive` | Bool | Default false | Indica se é o plano ativo atual |

**Relationships**:
- `exercises`: Array de Exercise (1:N, cascade delete)
- `sessions`: Array de WorkoutSession (1:N, nullify on delete - preserva histórico)

**Business Rules**:
- ✅ Nome deve ter mínimo 3 caracteres (validado em `WorkoutPlanFormViewModel`)
- ✅ Descrição limitada a 500 caracteres (validado em `WorkoutPlanFormViewModel`)
- ✅ Apenas 1 plano pode ter `isActive = true` por vez (enforced em `WorkoutPlanListViewModel`)
- ✅ Deletar plano deleta exercises em cascade mas preserva sessions (nullify)

---

### 2. Exercise

Representa um exercício individual dentro de um plano de treino.

**SwiftData Model**:
```swift
import SwiftData
import Foundation

@Model
final class Exercise {
    // Identity
    @Attribute(.unique) var id: UUID
    
    // Core attributes
    var name: String
    var muscleGroup: MuscleGroup
    var defaultSets: Int
    var defaultReps: Int
    var defaultRestTime: Int  // em segundos
    var order: Int  // posição no plano (para drag & drop)
    
    // Relationship
    var workoutPlan: WorkoutPlan?
    
    @Relationship(deleteRule: .nullify, inverse: \ExerciseSet.exercise)
    var sets: [ExerciseSet]
    
    // Initializer
    init(
        id: UUID = UUID(),
        name: String,
        muscleGroup: MuscleGroup,
        defaultSets: Int = 3,
        defaultReps: Int = 12,
        defaultRestTime: Int = 60,
        order: Int = 0
    ) {
        self.id = id
        self.name = name
        self.muscleGroup = muscleGroup
        self.defaultSets = defaultSets
        self.defaultReps = defaultReps
        self.defaultRestTime = defaultRestTime
        self.order = order
        self.sets = []
    }
}
```

**Attributes**:

| Field | Type | Constraints | Description |
|-------|------|-------------|-------------|
| `id` | UUID | Unique, Primary Key | Identificador único imutável |
| `name` | String | Required, 1-100 chars | Nome do exercício |
| `muscleGroup` | MuscleGroup | Required enum | Categoria do exercício |
| `defaultSets` | Int | 1-10, default 3 | Número padrão de séries |
| `defaultReps` | Int | 1-50, default 12 | Número padrão de repetições |
| `defaultRestTime` | Int | 30/60/90/120/180, default 60 | Tempo de descanso em segundos |
| `order` | Int | >= 0 | Posição no plano (0-indexed) |

**Relationships**:
- `workoutPlan`: WorkoutPlan? (N:1, inverse de exercises)
- `sets`: Array de ExerciseSet (1:N, histórico de execuções)

**Business Rules**:
- ✅ Nome é obrigatório (validado em `ExerciseFormViewModel`)
- ✅ Grupo muscular deve ser selecionado
- ✅ Séries: 1-10 (validado em `ExerciseFormViewModel`)
- ✅ Repetições: 1-50 (validado em `ExerciseFormViewModel`)
- ✅ Tempo de descanso: enum [30, 60, 90, 120, 180] segundos
- ✅ Order usado para manter sequência customizada (drag & drop)

---

### 3. MuscleGroup

Enum representando categorias de grupos musculares.

**SwiftData Enum**:
```swift
import Foundation

enum MuscleGroup: String, Codable, CaseIterable {
    case chest = "Peito"
    case back = "Costas"
    case legs = "Pernas"
    case shoulders = "Ombros"
    case arms = "Braços"
    case abs = "Abdômen"
    case cardio = "Cardio"
    
    // UI Helper - cor da tag
    var tagColor: String {
        switch self {
        case .chest: return "blue"
        case .back: return "green"
        case .legs: return "purple"
        case .shoulders: return "orange"
        case .arms: return "red"
        case .abs: return "yellow"
        case .cardio: return "pink"
        }
    }
    
    // UI Helper - ícone SF Symbol
    var iconName: String {
        switch self {
        case .chest: return "figure.strengthtraining.traditional"
        case .back: return "figure.arms.open"
        case .legs: return "figure.walk"
        case .shoulders: return "figure.stand"
        case .arms: return "dumbbell"
        case .abs: return "figure.core.training"
        case .cardio: return "figure.run"
        }
    }
}
```

**Values**:
- `chest` - "Peito" (azul, ícone strengthtraining)
- `back` - "Costas" (verde, ícone arms.open)
- `legs` - "Pernas" (roxo, ícone walk)
- `shoulders` - "Ombros" (laranja, ícone stand)
- `arms` - "Braços" (vermelho, ícone dumbbell)
- `abs` - "Abdômen" (amarelo, ícone core.training)
- `cardio` - "Cardio" (rosa, ícone run)

**Business Rules**:
- ✅ CaseIterable permite usar em Picker SwiftUI
- ✅ Codable permite persistência SwiftData
- ✅ rawValue português para display direto ao usuário
- ✅ Helper properties para UI (cores e ícones consistentes)

---

## Supporting Entities (Fora do escopo desta feature)

Estas entidades são mencionadas nos relacionamentos mas serão implementadas em features futuras:

### WorkoutSession (Feature: Executar Treino)
```swift
@Model
final class WorkoutSession {
    var id: UUID
    var startDate: Date
    var endDate: Date?
    var isCompleted: Bool
    var workoutPlan: WorkoutPlan?
    var exerciseSets: [ExerciseSet]
}
```

### ExerciseSet (Feature: Executar Treino)
```swift
@Model
final class ExerciseSet {
    var id: UUID
    var setNumber: Int
    var weight: Double?
    var reps: Int
    var completedDate: Date
    var exercise: Exercise?
    var session: WorkoutSession?
}
```

---

## Relationships Diagram

```
┌─────────────────┐
│  WorkoutPlan    │
│─────────────────│
│ id: UUID        │
│ name: String    │
│ description     │
│ createdDate     │
│ isActive: Bool  │
└─────────────────┘
        │
        │ 1:N (cascade)
        │
        ▼
┌─────────────────┐
│    Exercise     │
│─────────────────│
│ id: UUID        │
│ name: String    │
│ muscleGroup     │◄───── MuscleGroup enum
│ defaultSets     │
│ defaultReps     │
│ defaultRestTime │
│ order: Int      │
└─────────────────┘
        │
        │ 1:N (nullify)
        │
        ▼
┌─────────────────┐
│  ExerciseSet    │  (Future feature)
│─────────────────│
│ setNumber       │
│ weight, reps    │
└─────────────────┘
```

**Cascade Rules**:
- Deletar WorkoutPlan → deleta todos Exercise associados (cascade)
- Deletar Exercise → mantém ExerciseSet mas referência vira nil (nullify)
- Deletar WorkoutPlan → mantém WorkoutSession mas referência vira nil (nullify)

---

## SwiftData Container Setup

**App Entry Point** (`BumbumNaNucaApp.swift`):
```swift
import SwiftUI
import SwiftData

@main
struct BumbumNaNucaApp: App {
    var sharedModelContainer: ModelContainer = {
        let schema = Schema([
            WorkoutPlan.self,
            Exercise.self,
            WorkoutSession.self,
            ExerciseSet.self,
            CheckIn.self  // Future feature
        ])
        
        let modelConfiguration = ModelConfiguration(
            schema: schema,
            isStoredInMemoryOnly: false  // Persistência em disco
        )
        
        do {
            return try ModelContainer(
                for: schema,
                configurations: [modelConfiguration]
            )
        } catch {
            fatalError("Could not create ModelContainer: \(error)")
        }
    }()
    
    var body: some Scene {
        WindowGroup {
            ContentView()
        }
        .modelContainer(sharedModelContainer)
    }
}
```

---

## Query Patterns

### Listar todos os planos (ordenados por data)
```swift
@Query(sort: \WorkoutPlan.createdDate, order: .reverse)
private var plans: [WorkoutPlan]
```

### Buscar plano ativo
```swift
@Query(filter: #Predicate<WorkoutPlan> { $0.isActive })
private var activePlans: [WorkoutPlan]

var activePlan: WorkoutPlan? {
    activePlans.first
}
```

### Exercícios de um plano (já vem ordenado pelo order)
```swift
// Dentro de WorkoutPlanDetailView
let sortedExercises = plan.exercises.sorted { $0.order < $1.order }
```

---

## Validation Rules

Validações implementadas nos ViewModels (não no Model):

### WorkoutPlanFormViewModel
```swift
func validateName() -> Bool {
    let trimmed = name.trimmingCharacters(in: .whitespaces)
    guard !trimmed.isEmpty else {
        nameError = "Nome é obrigatório"
        return false
    }
    guard trimmed.count >= 3 else {
        nameError = "Nome deve ter no mínimo 3 caracteres"
        return false
    }
    guard trimmed.count <= 100 else {
        nameError = "Nome deve ter no máximo 100 caracteres"
        return false
    }
    nameError = nil
    return true
}

func validateDescription() -> Bool {
    guard description.count <= 500 else {
        descriptionError = "Descrição deve ter no máximo 500 caracteres"
        return false
    }
    descriptionError = nil
    return true
}

func validate() -> Bool {
    return validateName() && validateDescription()
}
```

### ExerciseFormViewModel
```swift
func validateSets() -> Bool {
    guard (1...10).contains(defaultSets) else {
        setsError = "Séries devem estar entre 1 e 10"
        return false
    }
    setsError = nil
    return true
}

func validateReps() -> Bool {
    guard (1...50).contains(defaultReps) else {
        repsError = "Repetições devem estar entre 1 e 50"
        return false
    }
    repsError = nil
    return true
}
```

---

## Migration Strategy

**MVP (v1.0.0)**: Schema inicial, nenhuma migração necessária

**Future Versions**:
- Se adicionar campos: SwiftData faz lightweight migration automático
- Se mudar tipos ou relacionamentos: Implementar `VersionedSchema` e `MigrationPlan`
- Sempre testar migrações com dados reais em pre-release

**Example Future Migration** (quando adicionar campo):
```swift
enum WorkoutPlanSchemaV2: VersionedSchema {
    static var versionIdentifier = Schema.Version(2, 0, 0)
    
    static var models: [any PersistentModel.Type] {
        [WorkoutPlan.self, Exercise.self]
    }
    
    @Model
    final class WorkoutPlan {
        // ... campos existentes
        var lastModifiedDate: Date?  // NOVO campo
    }
}
```

---

## Testing Strategy

### Unit Tests (Models)

**WorkoutPlanTests.swift**:
```swift
import XCTest
@testable import BumbumNaNuca

final class WorkoutPlanTests: XCTestCase {
    func testInitialization() {
        let plan = WorkoutPlan(name: "Test Plan")
        XCTAssertEqual(plan.name, "Test Plan")
        XCTAssertEqual(plan.description, "")
        XCTAssertFalse(plan.isActive)
        XCTAssertTrue(plan.exercises.isEmpty)
    }
    
    func testCascadeDelete() {
        // Test que deletar plano deleta exercises
        // Requer SwiftData in-memory container
    }
}
```

**ExerciseTests.swift**:
```swift
func testDefaultValues() {
    let exercise = Exercise(
        name: "Supino",
        muscleGroup: .chest
    )
    XCTAssertEqual(exercise.defaultSets, 3)
    XCTAssertEqual(exercise.defaultReps, 12)
    XCTAssertEqual(exercise.defaultRestTime, 60)
}

func testMuscleGroupRawValue() {
    XCTAssertEqual(MuscleGroup.chest.rawValue, "Peito")
    XCTAssertEqual(MuscleGroup.cardio.rawValue, "Cardio")
}
```

---

## Performance Considerations

### Indexing
- SwiftData automaticamente indexa `@Attribute(.unique)` fields
- `createdDate` usado em sorting → performance OK para <1000 plans
- Se necessário no futuro: adicionar índice composto

### Fetch Limits
```swift
// Limitar query se lista crescer muito
@Query(
    sort: \WorkoutPlan.createdDate, 
    order: .reverse,
    animation: .default
)
private var plans: [WorkoutPlan]

// No futuro, se passar de 100 planos:
// FetchDescriptor(predicate: ..., fetchLimit: 100)
```

### Memory
- SwiftData faz lazy loading automático de relationships
- `exercises` array só carrega quando acessado
- Para MVP com <50 plans, não há preocupação

---

## Conclusion

Schema SwiftData simples e robusto:
- ✅ 2 entities principais (WorkoutPlan, Exercise) + 1 enum (MuscleGroup)
- ✅ Relationships com cascade delete apropriado
- ✅ Validações no ViewModel (separation of concerns)
- ✅ Zero dependências externas (SwiftData nativo)
- ✅ Preparado para migrações futuras

**Ready for**: Phase 1 continuation (quickstart.md) e Phase 2 (task breakdown)
