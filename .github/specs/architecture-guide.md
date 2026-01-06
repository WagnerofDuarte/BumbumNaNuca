# Guia de Arquitetura - BumbumNaNuca

## Visão Geral

Este documento descreve a arquitetura do aplicativo BumbumNaNuca, detalhando padrões, princípios e estrutura organizacional do código.

---

## 1. Padrão Arquitetural

### 1.1 MVVM (Model-View-ViewModel)

O aplicativo segue o padrão **MVVM** adaptado para SwiftUI:

```
┌─────────────────────────────────────────────┐
│                   View                       │
│         (SwiftUI Views)                      │
│  - Apresentação                              │
│  - User interactions                         │
│  - Navegação                                 │
└──────────────┬──────────────────────────────┘
               │ @ObservedObject
               │ @StateObject
               ↓
┌─────────────────────────────────────────────┐
│                ViewModel                     │
│         (ObservableObject)                   │
│  - Lógica de apresentação                   │
│  - Estado da UI                              │
│  - Comandos do usuário                       │
│  - Formatação de dados                       │
└──────────────┬──────────────────────────────┘
               │
               │ usa Services
               ↓
┌─────────────────────────────────────────────┐
│                Services                      │
│  - Lógica de negócio                        │
│  - Comunicação com Model                     │
│  - Operações complexas                       │
└──────────────┬──────────────────────────────┘
               │
               │ opera sobre
               ↓
┌─────────────────────────────────────────────┐
│                 Model                        │
│          (SwiftData Models)                  │
│  - Estrutura de dados                        │
│  - Persistência                              │
│  - Relacionamentos                           │
└─────────────────────────────────────────────┘
```

### 1.2 Responsabilidades

#### View (SwiftUI)
- ✅ Renderizar interface
- ✅ Capturar ações do usuário
- ✅ Navegar entre telas
- ❌ Não contém lógica de negócio
- ❌ Não acessa Model diretamente

#### ViewModel
- ✅ Gerenciar estado da view
- ✅ Processar inputs do usuário
- ✅ Formatar dados para exibição
- ✅ Expor métodos para a view
- ❌ Não importa SwiftUI (exceto Combine)
- ❌ Não contém código de UI

#### Service
- ✅ Implementar lógica de negócio
- ✅ Gerenciar persistência
- ✅ Coordenar operações complexas
- ❌ Não conhece Views ou ViewModels

#### Model
- ✅ Definir estrutura de dados
- ✅ Relacionamentos entre entidades
- ✅ Regras de validação básicas
- ❌ Não contém lógica de negócio

---

## 2. Estrutura de Pastas Detalhada

```
BumbumNaNuca/
│
├── App/
│   ├── BumbumNaNucaApp.swift          # Entry point do app
│   ├── AppDelegate.swift               # Lifecycle hooks (se necessário)
│   └── Configuration/
│       ├── AppConfiguration.swift      # Configurações globais
│       └── Environment.swift           # Variáveis de ambiente
│
├── Models/                             # SwiftData Models
│   ├── WorkoutPlan.swift
│   ├── Exercise.swift
│   ├── WorkoutSession.swift
│   ├── ExerciseSet.swift
│   ├── CheckIn.swift
│   └── Enums/
│       ├── MuscleGroup.swift
│       └── ExerciseType.swift
│
├── ViewModels/                         # ViewModels (ObservableObject)
│   ├── Home/
│   │   └── HomeViewModel.swift
│   ├── WorkoutPlan/
│   │   ├── WorkoutPlanListViewModel.swift
│   │   ├── WorkoutPlanDetailViewModel.swift
│   │   └── CreateWorkoutPlanViewModel.swift
│   ├── Exercise/
│   │   ├── ExerciseListViewModel.swift
│   │   └── ExecuteExerciseViewModel.swift
│   ├── Progress/
│   │   └── ProgressViewModel.swift
│   └── CheckIn/
│       └── CheckInViewModel.swift
│
├── Views/                              # SwiftUI Views
│   ├── Home/
│   │   ├── HomeView.swift
│   │   └── Components/
│   │       ├── ActivePlanCard.swift
│   │       ├── QuickCheckInButton.swift
│   │       └── LastWorkoutSummary.swift
│   │
│   ├── WorkoutPlan/
│   │   ├── WorkoutPlanListView.swift
│   │   ├── WorkoutPlanDetailView.swift
│   │   ├── CreateWorkoutPlanView.swift
│   │   ├── EditWorkoutPlanView.swift
│   │   ├── ImportWorkoutPlanView.swift
│   │   └── Components/
│   │       ├── WorkoutPlanCard.swift
│   │       └── PlanImportReviewView.swift
│   │
│   ├── Exercise/
│   │   ├── ExerciseListView.swift
│   │   ├── ExerciseDetailView.swift
│   │   ├── ExecuteWorkoutView.swift
│   │   ├── ExecuteExerciseView.swift
│   │   └── Components/
│   │       ├── ExerciseRow.swift
│   │       ├── VideoPlayerView.swift
│   │       ├── SetTrackerView.swift
│   │       └── SetHistoryView.swift
│   │
│   ├── Progress/
│   │   ├── ProgressView.swift
│   │   ├── ExerciseHistoryView.swift
│   │   ├── PersonalRecordsView.swift
│   │   └── Charts/
│   │       ├── LoadProgressChart.swift
│   │       ├── VolumeChart.swift
│   │       └── FrequencyChart.swift
│   │
│   ├── CheckIn/
│   │   ├── CheckInView.swift
│   │   ├── AttendanceCalendarView.swift
│   │   └── Components/
│   │       ├── CheckInButton.swift
│   │       ├── StreakDisplay.swift
│   │       └── StatsCard.swift
│   │
│   └── Components/                     # Componentes reutilizáveis
│       ├── RestTimerView.swift
│       ├── CustomButton.swift
│       ├── EmptyStateView.swift
│       ├── LoadingView.swift
│       └── ErrorView.swift
│
├── Services/                           # Camada de serviços
│   ├── DataPersistenceService.swift    # CRUD operations
│   ├── PDFImportService.swift          # Importação de PDF
│   ├── NotificationService.swift       # Notificações locais
│   ├── HapticService.swift             # Feedback háptico
│   └── AnalyticsService.swift          # Analytics e estatísticas
│
├── Utilities/                          # Utilities e helpers
│   ├── Extensions/
│   │   ├── Date+Extensions.swift
│   │   ├── View+Extensions.swift
│   │   ├── Color+Extensions.swift
│   │   └── String+Extensions.swift
│   ├── Helpers/
│   │   ├── DateFormatter+Helpers.swift
│   │   ├── NumberFormatter+Helpers.swift
│   │   └── ValidationHelpers.swift
│   └── Constants/
│       ├── AppConstants.swift
│       ├── ColorScheme.swift
│       └── Typography.swift
│
├── Resources/                          # Recursos
│   ├── Assets.xcassets/
│   ├── Localizable.strings
│   └── Sounds/
│       └── timer-complete.mp3
│
└── Tests/                              # Testes
    ├── UnitTests/
    │   ├── ViewModels/
    │   ├── Services/
    │   └── Models/
    └── UITests/
        └── Flows/
```

---

## 3. Fluxo de Dados

### 3.1 Leitura de Dados (Query)

```
View
  ↓ aciona
ViewModel
  ↓ chama
Service.fetch()
  ↓ consulta
SwiftData Model
  ↓ retorna
Service
  ↓ processa/formata
ViewModel
  ↓ @Published atualiza
View (re-renderiza)
```

### 3.2 Escrita de Dados (Command)

```
View (user action)
  ↓ chama método
ViewModel.save()
  ↓ valida e chama
Service.save()
  ↓ persiste em
SwiftData Model
  ↓ confirma
Service
  ↓ atualiza estado
ViewModel
  ↓ @Published notifica
View (re-renderiza com sucesso/erro)
```

### 3.3 Exemplo Prático: Criar Plano de Treino

```swift
// 1. View captura input
CreateWorkoutPlanView
  ↓ usuário clica "Salvar"

// 2. ViewModel processa
CreateWorkoutPlanViewModel.savePlan()
  ↓ valida dados
  ↓ formata objetos

// 3. Service persiste
DataPersistenceService.save(workoutPlan)
  ↓ cria contexto SwiftData
  ↓ insere modelo

// 4. Retorno
  ↓ sucesso/erro
ViewModel atualiza @Published var
  ↓ notifica
View mostra feedback e navega
```

---

## 4. Gerenciamento de Estado

### 4.1 State Management

```swift
// View local state (não compartilhado)
@State private var isExpanded = false

// ViewModel observado pela view
@StateObject private var viewModel = WorkoutPlanViewModel()

// Objeto observado compartilhado
@ObservedObject var sharedViewModel: SharedViewModel

// Environment object (injetado na hierarquia)
@EnvironmentObject var appState: AppState

// SwiftData queries
@Query private var workoutPlans: [WorkoutPlan]
```

### 4.2 Hierarquia de Estado

```
App Level (EnvironmentObject)
  ├─ AppState
  │   ├─ currentUser
  │   ├─ activeWorkoutPlan
  │   └─ settings
  │
Screen Level (StateObject/ObservedObject)
  ├─ HomeViewModel
  ├─ WorkoutPlanViewModel
  └─ ProgressViewModel
  │
Component Level (@State)
  ├─ isExpanded
  ├─ selectedTab
  └─ showingSheet
```

---

## 5. Navegação

### 5.1 Estrutura de Navegação

```swift
ContentView
  ├─ TabView
      ├─ NavigationStack (Home)
      │   ├─ HomeView
      │   └─ WorkoutSessionView
      │
      ├─ NavigationStack (Treinos)
      │   ├─ WorkoutPlanListView
      │   ├─ WorkoutPlanDetailView
      │   └─ ExecuteWorkoutView
      │
      ├─ NavigationStack (Progresso)
      │   ├─ ProgressView
      │   └─ ExerciseHistoryView
      │
      └─ NavigationStack (Frequência)
          ├─ CheckInView
          └─ AttendanceCalendarView
```

### 5.2 Padrões de Navegação

#### NavigationStack (iOS 16+)
```swift
NavigationStack(path: $navigationPath) {
    HomeView()
        .navigationDestination(for: WorkoutPlan.self) { plan in
            WorkoutPlanDetailView(plan: plan)
        }
}
```

#### Sheet (Modal)
```swift
.sheet(item: $selectedPlan) { plan in
    EditWorkoutPlanView(plan: plan)
}
```

#### FullScreenCover (Fullscreen)
```swift
.fullScreenCover(isPresented: $isExecutingWorkout) {
    ExecuteWorkoutView()
}
```

---

## 6. Persistência de Dados

### 6.1 SwiftData Setup

```swift
@main
struct BumbumNaNucaApp: App {
    var sharedModelContainer: ModelContainer = {
        let schema = Schema([
            WorkoutPlan.self,
            Exercise.self,
            WorkoutSession.self,
            ExerciseSet.self,
            CheckIn.self
        ])
        
        let modelConfiguration = ModelConfiguration(
            schema: schema,
            isStoredInMemoryOnly: false
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

### 6.2 CRUD Operations via Service

```swift
class DataPersistenceService {
    private let modelContext: ModelContext
    
    init(modelContext: ModelContext) {
        self.modelContext = modelContext
    }
    
    // Create
    func save<T: PersistentModel>(_ item: T) throws {
        modelContext.insert(item)
        try modelContext.save()
    }
    
    // Read
    func fetch<T: PersistentModel>(_ type: T.Type, 
                                    predicate: Predicate<T>? = nil) throws -> [T] {
        let descriptor = FetchDescriptor<T>(predicate: predicate)
        return try modelContext.fetch(descriptor)
    }
    
    // Update (automático com SwiftData)
    func update() throws {
        try modelContext.save()
    }
    
    // Delete
    func delete<T: PersistentModel>(_ item: T) throws {
        modelContext.delete(item)
        try modelContext.save()
    }
}
```

---

## 7. Dependency Injection

### 7.1 Environment-based DI

```swift
// Definir chave de environment
private struct DataServiceKey: EnvironmentKey {
    static let defaultValue: DataPersistenceService? = nil
}

extension EnvironmentValues {
    var dataService: DataPersistenceService? {
        get { self[DataServiceKey.self] }
        set { self[DataServiceKey.self] = newValue }
    }
}

// Injetar no root
ContentView()
    .environment(\.dataService, dataService)

// Usar nas views
@Environment(\.dataService) private var dataService
```

### 7.2 Protocol-based DI (para testes)

```swift
protocol DataServiceProtocol {
    func save<T: PersistentModel>(_ item: T) throws
    func fetch<T: PersistentModel>(_ type: T.Type) throws -> [T]
}

class WorkoutPlanViewModel: ObservableObject {
    private let dataService: DataServiceProtocol
    
    init(dataService: DataServiceProtocol = DataPersistenceService.shared) {
        self.dataService = dataService
    }
}

// Em testes
class MockDataService: DataServiceProtocol { ... }
let viewModel = WorkoutPlanViewModel(dataService: MockDataService())
```

---

## 8. Comunicação Entre Camadas

### 8.1 View → ViewModel

```swift
// Via métodos públicos
Button("Salvar") {
    viewModel.savePlan()
}

// Via bindings
TextField("Nome", text: $viewModel.planName)
```

### 8.2 ViewModel → View

```swift
class WorkoutPlanViewModel: ObservableObject {
    @Published var plans: [WorkoutPlan] = []
    @Published var isLoading = false
    @Published var errorMessage: String?
}

// View reage automaticamente a mudanças
if viewModel.isLoading {
    ProgressView()
} else {
    List(viewModel.plans) { plan in
        Text(plan.name)
    }
}
```

### 8.3 ViewModel → Service

```swift
class WorkoutPlanViewModel: ObservableObject {
    private let dataService: DataPersistenceService
    
    func loadPlans() async {
        do {
            plans = try await dataService.fetchWorkoutPlans()
        } catch {
            errorMessage = error.localizedDescription
        }
    }
}
```

---

## 9. Tratamento de Erros

### 9.1 Custom Error Types

```swift
enum AppError: LocalizedError {
    case dataFetchFailed
    case invalidInput(String)
    case networkError(Error)
    case pdfImportFailed(String)
    
    var errorDescription: String? {
        switch self {
        case .dataFetchFailed:
            return "Não foi possível carregar os dados"
        case .invalidInput(let field):
            return "Campo inválido: \(field)"
        case .networkError(let error):
            return "Erro de rede: \(error.localizedDescription)"
        case .pdfImportFailed(let reason):
            return "Falha ao importar PDF: \(reason)"
        }
    }
}
```

### 9.2 Error Handling Pattern

```swift
class WorkoutPlanViewModel: ObservableObject {
    @Published var errorMessage: String?
    @Published var showError = false
    
    func savePlan() async {
        do {
            try await dataService.save(workoutPlan)
            // Sucesso
        } catch {
            errorMessage = error.localizedDescription
            showError = true
        }
    }
}

// Na view
.alert("Erro", isPresented: $viewModel.showError) {
    Button("OK") {
        viewModel.showError = false
    }
} message: {
    Text(viewModel.errorMessage ?? "Erro desconhecido")
}
```

---

## 10. Concorrência

### 10.1 Async/Await

```swift
class WorkoutPlanViewModel: ObservableObject {
    @Published var plans: [WorkoutPlan] = []
    
    @MainActor
    func loadPlans() async {
        plans = await dataService.fetchPlans()
    }
}

// Na view
.task {
    await viewModel.loadPlans()
}
```

### 10.2 Actor para Thread-Safety

```swift
actor WorkoutSessionManager {
    private var activeSessions: [UUID: WorkoutSession] = [:]
    
    func startSession(_ session: WorkoutSession) {
        activeSessions[session.id] = session
    }
    
    func endSession(_ id: UUID) -> WorkoutSession? {
        activeSessions.removeValue(forKey: id)
    }
}
```

---

## 11. Performance

### 11.1 Lazy Loading

```swift
// Carregar apenas quando necessário
@Query(sort: \WorkoutPlan.createdDate, order: .reverse)
private var workoutPlans: [WorkoutPlan]

// Limitar resultados
@Query(
    filter: #Predicate<WorkoutPlan> { $0.isActive },
    sort: \WorkoutPlan.createdDate,
    order: .reverse
)
private var activePlans: [WorkoutPlan]
```

### 11.2 Debouncing de Inputs

```swift
class SearchViewModel: ObservableObject {
    @Published var searchText = ""
    @Published var results: [Exercise] = []
    
    private var cancellables = Set<AnyCancellable>()
    
    init() {
        $searchText
            .debounce(for: 0.3, scheduler: DispatchQueue.main)
            .sink { [weak self] text in
                self?.performSearch(text)
            }
            .store(in: &cancellables)
    }
}
```

### 11.3 Caching

```swift
class DataCache {
    private var cache: [String: Any] = [:]
    
    func get<T>(_ key: String) -> T? {
        cache[key] as? T
    }
    
    func set<T>(_ key: String, value: T) {
        cache[key] = value
    }
    
    func clear() {
        cache.removeAll()
    }
}
```

---

## 12. Testabilidade

### 12.1 Arquitetura Testável

```swift
// Protocol para abstrair dependências
protocol WorkoutPlanServiceProtocol {
    func fetchPlans() async throws -> [WorkoutPlan]
    func save(_ plan: WorkoutPlan) async throws
}

// ViewModel aceita protocolo
class WorkoutPlanViewModel: ObservableObject {
    private let service: WorkoutPlanServiceProtocol
    
    init(service: WorkoutPlanServiceProtocol) {
        self.service = service
    }
}

// Mock para testes
class MockWorkoutPlanService: WorkoutPlanServiceProtocol {
    var mockPlans: [WorkoutPlan] = []
    
    func fetchPlans() async throws -> [WorkoutPlan] {
        mockPlans
    }
    
    func save(_ plan: WorkoutPlan) async throws {
        mockPlans.append(plan)
    }
}
```

### 12.2 Exemplo de Teste

```swift
@Test
func testLoadPlans() async throws {
    // Arrange
    let mockService = MockWorkoutPlanService()
    mockService.mockPlans = [
        WorkoutPlan(name: "Plano A"),
        WorkoutPlan(name: "Plano B")
    ]
    let viewModel = WorkoutPlanViewModel(service: mockService)
    
    // Act
    await viewModel.loadPlans()
    
    // Assert
    #expect(viewModel.plans.count == 2)
    #expect(viewModel.plans[0].name == "Plano A")
}
```

---

## 13. Princípios de Design

### 13.1 SOLID

#### Single Responsibility
- Cada classe tem uma única responsabilidade
- ViewModels não acessam Model diretamente
- Services encapsulam lógica específica

#### Open/Closed
- Extensível via protocols
- Novas features não modificam código existente

#### Liskov Substitution
- Mocks implementam mesmos protocolos
- Substituíveis sem quebrar funcionalidade

#### Interface Segregation
- Protocolos pequenos e focados
- Clients não dependem de métodos não usados

#### Dependency Inversion
- Dependência de abstrações (protocols)
- Não de implementações concretas

### 13.2 Clean Code

```swift
// ✅ BOM - Nome claro, responsabilidade única
class PDFImportService {
    func importWorkoutPlan(from url: URL) async throws -> WorkoutPlan {
        let pdfData = try extractText(from: url)
        let exercises = try parseExercises(from: pdfData)
        return WorkoutPlan(exercises: exercises)
    }
}

// ❌ RUIM - Nome genérico, faz muitas coisas
class Manager {
    func doStuff(data: Any) -> Any {
        // ...
    }
}
```

---

## 14. Convenções de Código

### 14.1 Naming

```swift
// Classes/Structs: PascalCase
class WorkoutPlanViewModel { }
struct Exercise { }

// Properties/Methods: camelCase
var workoutPlans: [WorkoutPlan]
func savePlan() { }

// Constants: camelCase ou UPPER_CASE
let maxExercisesPerPlan = 20
let DEFAULT_REST_TIME = 60

// Protocols: PascalCase, sufixo -able ou -Protocol
protocol Saveable { }
protocol DataServiceProtocol { }

// Enums: PascalCase (tipo), camelCase (cases)
enum MuscleGroup {
    case chest
    case back
}
```

### 14.2 File Organization

```swift
// MARK: - Properties
// MARK: - Initialization
// MARK: - Public Methods
// MARK: - Private Methods
// MARK: - Computed Properties

class WorkoutPlanViewModel: ObservableObject {
    
    // MARK: - Properties
    @Published var plans: [WorkoutPlan] = []
    private let dataService: DataServiceProtocol
    
    // MARK: - Initialization
    init(dataService: DataServiceProtocol) {
        self.dataService = dataService
    }
    
    // MARK: - Public Methods
    func loadPlans() async {
        // ...
    }
    
    // MARK: - Private Methods
    private func validatePlan(_ plan: WorkoutPlan) -> Bool {
        // ...
    }
}
```

---

## 15. Diagrama de Arquitetura Completo

```
┌───────────────────────────────────────────────────────────┐
│                        App Layer                          │
│  ┌─────────────────────────────────────────────────────┐ │
│  │            BumbumNaNucaApp.swift                     │ │
│  │  - ModelContainer setup                              │ │
│  │  - Environment injection                             │ │
│  └─────────────────────────────────────────────────────┘ │
└───────────────────────────────────────────────────────────┘
                           ↓
┌───────────────────────────────────────────────────────────┐
│                      View Layer                           │
│  ┌──────────┐  ┌──────────┐  ┌──────────┐  ┌──────────┐ │
│  │   Home   │  │ Workouts │  │ Progress │  │ Check-in │ │
│  │  Views   │  │  Views   │  │  Views   │  │  Views   │ │
│  └──────────┘  └──────────┘  └──────────┘  └──────────┘ │
│         ↓             ↓             ↓             ↓       │
└───────────────────────────────────────────────────────────┘
                           ↓
┌───────────────────────────────────────────────────────────┐
│                   ViewModel Layer                         │
│  ┌──────────────────────────────────────────────────────┐│
│  │         ObservableObject ViewModels                   ││
│  │  - State management                                   ││
│  │  - User action handling                               ││
│  │  - Data formatting                                    ││
│  └──────────────────────────────────────────────────────┘│
└───────────────────────────────────────────────────────────┘
                           ↓
┌───────────────────────────────────────────────────────────┐
│                    Service Layer                          │
│  ┌──────────┐  ┌──────────┐  ┌──────────┐  ┌──────────┐ │
│  │   Data   │  │   PDF    │  │  Notif.  │  │  Haptic  │ │
│  │ Service  │  │ Service  │  │ Service  │  │ Service  │ │
│  └──────────┘  └──────────┘  └──────────┘  └──────────┘ │
└───────────────────────────────────────────────────────────┘
                           ↓
┌───────────────────────────────────────────────────────────┐
│                     Model Layer                           │
│  ┌──────────────────────────────────────────────────────┐│
│  │              SwiftData Models                         ││
│  │  - WorkoutPlan                                        ││
│  │  - Exercise                                           ││
│  │  - WorkoutSession                                     ││
│  │  - ExerciseSet                                        ││
│  │  - CheckIn                                            ││
│  └──────────────────────────────────────────────────────┘│
└───────────────────────────────────────────────────────────┘
                           ↓
┌───────────────────────────────────────────────────────────┐
│                  Persistence Layer                        │
│  ┌──────────────────────────────────────────────────────┐│
│  │                  SwiftData Store                      ││
│  │              (Local SQLite Database)                  ││
│  └──────────────────────────────────────────────────────┘│
└───────────────────────────────────────────────────────────┘
```

---

## Conclusão

Esta arquitetura foi projetada para ser:
- ✅ **Escalável**: Fácil adicionar novas features
- ✅ **Testável**: Camadas desacopladas via protocols
- ✅ **Manutenível**: Código organizado e responsabilidades claras
- ✅ **Performática**: SwiftData + async/await
- ✅ **SwiftUI-first**: Aproveita capacidades nativas do framework

Seguir este guia garante consistência e qualidade do código ao longo do desenvolvimento.
