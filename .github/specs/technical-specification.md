# BumbumNaNuca - Especificação Técnica

## Visão Geral

BumbumNaNuca é um aplicativo iOS nativo desenvolvido em SwiftUI para gerenciamento de planos de treino de academia, permitindo aos usuários importar, criar, acompanhar e executar seus treinos de forma prática e eficiente.

## Arquitetura

### Padrão Arquitetural
- **MVVM** (Model-View-ViewModel)
- **SwiftUI** para interface
- **Combine** para programação reativa
- **SwiftData** para persistência local

### Estrutura de Pastas

```
BumbumNaNuca/
├── App/
│   └── BumbumNaNucaApp.swift
├── Models/
│   ├── WorkoutPlan.swift
│   ├── Exercise.swift
│   ├── WorkoutSession.swift
│   ├── ExerciseSet.swift
│   └── CheckIn.swift
├── ViewModels/
│   ├── WorkoutPlanViewModel.swift
│   ├── ExerciseViewModel.swift
│   ├── WorkoutSessionViewModel.swift
│   └── CheckInViewModel.swift
├── Views/
│   ├── Home/
│   │   ├── HomeView.swift
│   │   └── Components/
│   ├── WorkoutPlan/
│   │   ├── WorkoutPlanListView.swift
│   │   ├── WorkoutPlanDetailView.swift
│   │   ├── CreateWorkoutPlanView.swift
│   │   └── ImportWorkoutPlanView.swift
│   ├── Exercise/
│   │   ├── ExerciseListView.swift
│   │   ├── ExerciseDetailView.swift
│   │   ├── ExecuteExerciseView.swift
│   │   └── VideoPlayerView.swift
│   ├── Progress/
│   │   ├── ProgressView.swift
│   │   ├── ExerciseHistoryView.swift
│   │   └── Charts/
│   ├── CheckIn/
│   │   ├── CheckInView.swift
│   │   └── AttendanceCalendarView.swift
│   └── Components/
│       ├── RestTimerView.swift
│       └── SetTrackerView.swift
├── Services/
│   ├── PDFImportService.swift
│   ├── DataPersistenceService.swift
│   └── NotificationService.swift
└── Utilities/
    ├── Extensions/
    └── Constants/
```

## Modelos de Dados

### WorkoutPlan
```swift
@Model
class WorkoutPlan {
    var id: UUID
    var name: String
    var description: String?
    var createdDate: Date
    var isActive: Bool
    var exercises: [Exercise]
    
    // Relação
    var sessions: [WorkoutSession]
}
```

### Exercise
```swift
@Model
class Exercise {
    var id: UUID
    var name: String
    var description: String?
    var muscleGroup: MuscleGroup
    var videoURL: String?
    var defaultSets: Int
    var defaultReps: Int
    var defaultRestTime: Int // em segundos
    var order: Int
    
    // Relação
    var workoutPlan: WorkoutPlan?
    var sets: [ExerciseSet]
}

enum MuscleGroup: String, Codable {
    case chest = "Peito"
    case back = "Costas"
    case legs = "Pernas"
    case shoulders = "Ombros"
    case arms = "Braços"
    case abs = "Abdômen"
    case cardio = "Cardio"
}
```

### WorkoutSession
```swift
@Model
class WorkoutSession {
    var id: UUID
    var workoutPlan: WorkoutPlan
    var startDate: Date
    var endDate: Date?
    var notes: String?
    var isCompleted: Bool
    
    // Relação
    var exerciseSets: [ExerciseSet]
}
```

### ExerciseSet
```swift
@Model
class ExerciseSet {
    var id: UUID
    var exercise: Exercise
    var session: WorkoutSession
    var setNumber: Int
    var weight: Double?
    var reps: Int
    var completedDate: Date
    var notes: String?
}
```

### CheckIn
```swift
@Model
class CheckIn {
    var id: UUID
    var date: Date
    var workoutSession: WorkoutSession?
    var notes: String?
}
```

## Funcionalidades Principais

### 1. Importação e Gerenciamento de Planos de Treino

#### Importação de PDF
- **Tecnologia**: PDFKit
- **Fluxo**:
  1. Usuário seleciona arquivo PDF
  2. App extrai texto usando PDFKit
  3. Parser analisa estrutura e identifica exercícios
  4. Tela de revisão permite edição antes de salvar
  5. Dados salvos no SwiftData

#### Criação Manual
- Formulário para criar plano de treino
- Adicionar exercícios um por um
- Reordenar exercícios (drag & drop)
- Configurar séries, repetições e tempo de descanso padrão

### 2. Vídeos Instrucionais

#### VideoPlayerView
- **Tecnologia**: AVKit / WebKit para YouTube embarcado
- **Implementação**:
  ```swift
  - Usar WKWebView para carregar vídeo do YouTube
  - Modo embarcado (sem redirecionamento)
  - Controles nativos de play/pause
  - Suporte a picture-in-picture
  ```

### 3. Temporizador de Descanso

#### RestTimerView
- **Funcionalidades**:
  - Countdown visual
  - Progresso circular
  - Botões: Iniciar, Pausar, Reiniciar, Pular
  - Vibração ao término (Haptic Feedback)
  - Notificação sonora
  - Continua funcionando em background

- **Implementação**:
  ```swift
  - Timer do Combine
  - HapticManager para vibração
  - AVAudioPlayer para som
  - Background task para continuar contagem
  ```

### 4. Registro e Acompanhamento de Carga

#### Tracking de Séries
- Registrar para cada série:
  - Peso utilizado
  - Repetições realizadas
  - Data/hora
  - Observações opcionais

#### Visualização de Progresso
- Gráficos de evolução por exercício
- Recordes pessoais (PR - Personal Record)
- Comparação entre sessões
- Filtros por período (semana, mês, ano, total)

#### Tecnologia de Gráficos
- **Swift Charts** (iOS 16+)
- Tipos de gráficos:
  - Linha: evolução de carga ao longo do tempo
  - Barra: volume total por semana/mês
  - Comparativo: melhor série vs média

### 5. Check-in na Academia

#### Sistema de Check-in
- Botão de check-in rápido na tela inicial
- Registro automático da data/hora
- Associação opcional com sessão de treino
- Campo de observações

#### Visualização de Frequência
- Calendário mensal com dias de treino marcados
- Estatísticas:
  - Total de check-ins no mês/ano
  - Sequência atual (streak)
  - Maior sequência
  - Taxa de frequência (%)
  - Gráfico de frequência semanal

## Fluxo de Navegação

### Estrutura Principal
```
TabView:
├── Home
│   ├── Plano Ativo
│   ├── Check-in Rápido
│   └── Último Treino
├── Treinos
│   ├── Lista de Planos
│   ├── Criar/Importar
│   └── Executar Treino
├── Progresso
│   ├── Histórico
│   ├── Gráficos
│   └── Recordes
└── Frequência
    ├── Check-in
    └── Calendário
```

### Fluxo de Execução de Treino

1. **Iniciar Treino**
   - Selecionar plano de treino
   - Criar nova sessão
   - Check-in automático (opcional)

2. **Durante o Treino**
   - Listar exercícios do plano
   - Para cada exercício:
     - Ver vídeo instrucional (opcional)
     - Registrar séries uma por uma
     - Usar temporizador de descanso
     - Adicionar observações

3. **Finalizar Treino**
   - Resumo da sessão
   - Salvar dados
   - Comparar com treino anterior

## Tecnologias e Frameworks

### Core
- **SwiftUI**: Interface de usuário
- **SwiftData**: Persistência de dados
- **Combine**: Programação reativa

### Específicos
- **PDFKit**: Importação de PDFs
- **AVKit**: Reprodução de vídeos
- **WebKit**: Embed de YouTube
- **Swift Charts**: Gráficos e visualizações
- **UserNotifications**: Notificações locais
- **HealthKit** (futuro): Integração com Apple Health

## Persistência de Dados

### SwiftData Schema
```swift
@Model
class DataSchema {
    static var version: Int = 1
    
    static var models: [any PersistentModel.Type] {
        [
            WorkoutPlan.self,
            Exercise.self,
            WorkoutSession.self,
            ExerciseSet.self,
            CheckIn.self
        ]
    }
}
```

### Estratégia de Backup
- Dados armazenados localmente
- iCloud sync (futuro)
- Exportação de dados em JSON/CSV

## UI/UX Guidelines

### Design System
- **Cores**:
  - Primary: Azul (#007AFF) - ações principais
  - Secondary: Laranja (#FF9500) - destaque
  - Success: Verde (#34C759) - conclusões
  - Danger: Vermelho (#FF3B30) - exclusões
  - Background: Sistema (adaptativo claro/escuro)

- **Tipografia**:
  - Títulos: SF Pro Display (Bold)
  - Corpo: SF Pro Text (Regular)
  - Números: SF Mono (para pesos e contadores)

- **Espaçamento**:
  - Grid de 8pt
  - Padding padrão: 16pt
  - Elementos interativos: min 44pt de altura

### Componentes Reutilizáveis

#### SetTrackerView
- Input para peso
- Input para repetições
- Indicador de série atual
- Histórico da última vez

#### WorkoutCardView
- Nome do plano
- Número de exercícios
- Última execução
- Ação rápida de iniciar

#### ExerciseRowView
- Nome do exercício
- Grupo muscular (tag)
- Séries x Repetições
- Ícone de vídeo se disponível

## Requisitos de Sistema

- **iOS**: 17.0+
- **Xcode**: 15.0+
- **Swift**: 5.9+

## Roadmap Futuro

### Versão 1.0 (MVP)
- ✅ Criar e importar planos de treino
- ✅ Executar treinos com timer
- ✅ Registrar séries e progresso
- ✅ Check-in básico
- ✅ Visualizar histórico

### Versão 1.1
- Gráficos avançados de progresso
- Exportar/Importar dados
- Temas personalizáveis
- Apple Watch app

### Versão 2.0
- Integração com HealthKit
- Sincronização iCloud
- Planos de treino pré-definidos
- Comunidade e compartilhamento
- IA para sugestão de progressão

## Considerações de Segurança e Privacidade

- Dados armazenados apenas localmente (inicialmente)
- Nenhum tracking de usuário
- Sem coleta de dados analíticos sem consentimento
- Conformidade com App Store Guidelines
- Privacy Manifest configurado

## Testes

### Estratégia de Testes
- **Unit Tests**: ViewModels e Services
- **UI Tests**: Fluxos principais
- **Integration Tests**: SwiftData operations

### Coverage Mínimo
- ViewModels: 80%
- Services: 90%
- Models: 70%

## Documentação Adicional

- [User Guide](user-guide.md) - Guia do usuário
- [API Documentation](api-docs.md) - Documentação de código
- [Contributing](../CONTRIBUTING.md) - Guia de contribuição
