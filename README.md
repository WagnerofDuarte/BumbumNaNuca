# BumbumNaNuca - Gerenciamento de Planos de Treino

## 📱 Visão Geral

App iOS nativo para gerenciar planos de treino personalizados com exercícios organizados por grupo muscular.

## ✨ Funcionalidades Implementadas

### Gerenciamento de Planos
- ✅ Criar plano com nome e descrição
- ✅ Listar todos os planos (ordenado por data)
- ✅ Visualizar detalhes do plano
- ✅ Editar plano existente
- ✅ Ativar/desativar plano (único ativo)
- ✅ Excluir plano (com confirmação)
- ✅ Buscar planos por nome/descrição

### Gerenciamento de Exercícios
- ✅ Adicionar exercício ao plano
- ✅ Definir séries, repetições e descanso
- ✅ Categorizar por 7 grupos musculares
- ✅ Visualização com ícones coloridos

### Execução de Treinos 🆕
- ✅ Iniciar sessão de treino a partir de um plano
- ✅ Registrar séries com peso e repetições
- ✅ Validação em tempo real de dados
- ✅ Timer de descanso automático entre séries
  - Feedback haptic e sonoro ao completar
  - Controles pause/resume/skip
  - Funciona em background por até 3 minutos
- ✅ Visualizar dados do último treino
  - Peso e reps da última sessão completa
  - Formatação localizada de números
- ✅ Acompanhar progresso durante sessão
  - Badges de status (pendente/em andamento/completo)
  - Barra de progresso visual
  - Contador de exercícios completados
- ✅ Gerenciar sessões incompletas
  - Detectar sessão existente ao iniciar
  - Retomar treino anterior
  - Abandonar e iniciar nova sessão
- ✅ Resumo final do treino
  - Duração total da sessão
  - Total de séries e repetições
  - Lista de exercícios completados

## 🏗️ Arquitetura

### Stack Tecnológica
- **Swift 5.9+** / **iOS 17.0+**
- **SwiftUI** - Interface declarativa
- **SwiftData** - Persistência local (SQLite)
- **MVVM** - Separação de responsabilidades

### Estrutura de Pastas
```
BumbumNaNuca/
├── Models/                    # Entidades SwiftData
│   ├── WorkoutPlan.swift      # Plano de treino
│   ├── Exercise.swift         # Exercício individual
│   ├── WorkoutSession.swift   # Sessão de treino
│   ├── ExerciseSet.swift      # Série executada
│   └── MuscleGroup.swift      # Enum de grupos musculares
├── Views/
│   ├── Workout/               # Telas relacionadas a planos
│   │   ├── WorkoutPlanListView.swift
│   │   ├── WorkoutPlanDetailView.swift
│   │   ├── WorkoutPlanRowView.swift
│   │   ├── CreateWorkoutPlanView.swift
│   │   ├── EditWorkoutPlanView.swift
│   │   ├── AddExerciseView.swift
│   │   └── Execute/           # 🆕 Telas de execução
│   │       ├── ExecuteWorkoutView.swift
│   │       ├── ExecuteExerciseView.swift
│   │       ├── ExerciseExecutionRow.swift
│   │       ├── WorkoutSummaryView.swift
│   │       └── RestTimerView.swift
│   └── Components/            # Componentes reutilizáveis
│       ├── PrimaryButton.swift
│       ├── EmptyStateView.swift
│       ├── ExerciseRowView.swift
│       ├── ProgressHeader.swift
│       ├── SetInputView.swift
│       ├── ValidationFeedback.swift
│       └── CircularProgressView.swift
├── ViewModels/                # Lógica de negócio
│   ├── WorkoutPlanListViewModel.swift
│   ├── WorkoutPlanDetailViewModel.swift
│   ├── CreateWorkoutPlanViewModel.swift
│   ├── EditWorkoutPlanViewModel.swift
│   ├── AddExerciseViewModel.swift
│   └── Execute/               # 🆕 ViewModels de execução
│       ├── WorkoutSessionViewModel.swift
│       ├── ExecuteExerciseViewModel.swift
│       ├── WorkoutSummaryViewModel.swift
│       └── RestTimerViewModel.swift
└── Utilities/
    └── Extensions/
        └── Date+Extensions.swift  # Formatação de datas
```

## 🎨 Características de UI

### Design
- Componentes nativos iOS (SwiftUI)
- Dark Mode suporte automático
- Acessibilidade built-in
- ContentUnavailableView para estados vazios
- SF Symbols para ícones

### Navegação
- NavigationStack (iOS 16+)
- Sheets para criação/edição
- Alerts para confirmações destrutivas
- Swipe-to-delete em listas

## 💾 Modelo de Dados

### WorkoutPlan
```swift
- id: UUID (unique)
- n

### WorkoutSession 🆕
```swift
- id: UUID (unique)
- startDate: Date
- endDate: Date?
- isCompleted: Bool
- completedExercises: Set<UUID>
- workoutPlan: WorkoutPlan?
- exerciseSets: [ExerciseSet]
```🚀 Como Usar a Feature de Execução de Treinos

### Iniciar Treino
1. Na lista de planos, toque em um plano
2. Toque no botão "Iniciar Treino" (ícone de play)
3. Se houver uma sessão incompleta, escolha:
   - **Retomar**: continua de onde parou
   - **Abandonar e Iniciar Nova**: salva a atual e começa nova

### Durante o Treino
1. **Lista de Exercícios**: veja todos os exercícios com status
   - ⚪ Círculo vazio: pendente
   - 🔵 Círculo preenchido: em andamento
   - ✅ Check verde: completo

2. **Executar Exercício**: toque em um exercício
   - Veja dados do último treino (se houver)
   - Digite peso (opcional para peso corporal)
   - Digite número de repetições
   - Toque em "Concluir Série"

3. **Timer de Descanso** (automático após série)
   - Veja tempo restante em um círculo visual
   - **Pausar**: congela o timer
   - **Retomar**: continua de onde parou
   - **Pular**: cancela e volta para registro

4. **Completar Exercício**
   - Faça quantas séries quiser (não obrigatório seguir defaultSets)
   - Indicador verde aparece ao atingir meta de séries
   - Toque "Concluir Exercício" quando terminar

### Finalizar Treino
1. Toque em "Finalizar" no canto superior direito
2. Veja resumo completo:
   - Duração total
   - Total de séries e repetições
   - Lista de exercícios com detalhes

## 

### ExerciseSet 🆕
```swift
- id: UUID (unique)
- setNumber: Int
- weight: Double?
- reps: Int
- completedDate: Date
- exercise: Exercise?
- session: WorkoutSession?
```ame: String
- description: String
- createdDate: Date
- isActive: Bool
- exercises: [Exercise] (cascade delete)
```

### Exercise
```swift
- id: UUID (unique)
- name: String
- muscleGroup: MuscleGroup
- defaultSets: Int (1-10)
- defaultReps: Int (1-50)
- defaHistórico de treinos completo
- [ ] Gráficos de progresso
- [ ] Filtros por grupo muscular
- [ ] Duplicar plano existente
- [ ] Importar/Exportar planos (JSON)
- [ ] Notas por série/exercício
- [ ] Templates de planos populares
### MuscleGroup (Enum)
- Peito 🔵 (blue, dumbbell)
- Costas 🟢 (green, figure.walk)
- Pernas 🟣 (purple, figure.run)
- Ombros 🟠 (orange, figure.arms.open)
- Braços 🔴 (red, figure.strengthtraining.traditional)
- Abdômen 🟡 (yellow, figure.core.training)
- Cardio 🩷 (pink, heart.fill)

## 🧪 Testes

### Manual Testing
Ver [TESTING.md](TESTING.md) para guia completo, Combine
**Status**: ✅ Feature "Executar Treino" Completa
### Casos de Teste Cobertos
- ✅ Criar plano vazio (sem exercícios)
- ✅ Validação de nome obrigatório
- ✅ Ativação única (desativa outros automaticamente)
- ✅ Exclusão em cascata (plano → exercícios)
- ✅ Busca com filtro em tempo real
- ✅ Edição com cancelamento

## 📋 Checklist de Conformidade

### Requisitos Funcionais
- ✅ FR-001 a FR-009: Criar plano (nome, descrição, validação)
- ✅ FR-010 a FR-015: Listar planos (ordenação, busca, navegação)
- ✅ FR-016 a FR-020: Detalhes do plano (info, exercícios, contador)
- ✅ FR-021 a FR-024: Editar plano (formulário, validação, cancelar)
- ✅ FR-025 a FR-028: Ativar plano (toggle, único ativo, badge)
- ✅ FR-029 a FR-031: Excluir plano (confirmação, cascade, swipe)

### Requisitos Não-Funcionais
- ✅ RNF-001: iOS 17.0+ com SwiftUI
- ✅ RNF-002: SwiftData para persistência offline
- ✅ RNF-003: Zero dependências externas
- ✅ RNF-004: MVVM com ViewModels @Observable
- ✅ RNF-005: Navegação nativa (NavigationStack)
- ✅ RNF-006: Componentes reutilizáveis (PrimaryButton, EmptyStateView)
- ✅ RNF-007: Acessibilidade (SF Symbols, Labels)
- ✅ RNF-008: Dark Mode suporte
- ✅ RNF-009: Performance (SwiftData otimizado)
- ✅ RNF-010: Código limpo (separação de responsabilidades)

## 🚀 Como Executar

1. Abra `BumbumNaNuca.xcodeproj` no Xcode 15.0+
2. Selecione simulador iOS 17.0+ ou dispositivo físico
3. Build & Run (⌘R)

## 📝 Próximos Passos (Backlog)

### 🚧 Feature 003: MVP Completion (Em Planejamento)

**Documentação**: [specs/003-mvp-completion/](specs/003-mvp-completion/)  
**Status**: 📋 Planejamento Completo - Pronto para Implementação

Próxima feature que completa o MVP com:
1. **Home Dashboard** - Visão geral com plano ativo, último treino, check-in do dia
2. **Sistema de Check-in** - Registro diário com gamificação (sequências de dias) e estatísticas mensais
3. **Histórico de Progresso** - Treinos executados e evolução por exercício com recordes pessoais

**Componentes Principais**:
- TabView com 4 tabs (Home, Treinos, Progresso, Check-in)
- 3 novos ViewModels (Home, CheckIn, Progress)
- 7 novas Views principais
- 1 novo modelo SwiftData (CheckIn)
- 42 test cases manuais documentados

**Estratégia de Implementação**: Ver [IMPLEMENTATION_STATUS.md](IMPLEMENTATION_STATUS.md) para detalhes completos da abordagem faseada.

---

### Outras Funcionalidades Planejadas
- [ ] Reordenar exercícios (drag & drop)
- [ ] Editar exercícios existentes
- [ ] Deletar exercícios individuais
- [ ] Filtros por grupo muscular
- [ ] Duplicar plano existente
- [ ] Importar/Exportar planos (JSON)
- [ ] Notas por série/exercício
- [ ] Templates de planos populares

### Melhorias Técnicas
- [ ] Unit tests (XCTest)
- [ ] UI tests (XCUITest)
- [ ] Snapshot tests
- [ ] SwiftLint configuração
- [ ] CI/CD pipeline

## 📄 Licença

Projeto educacional - Uso livre.

---

**Desenvolvido com**: Swift, SwiftUI, SwiftData  
**Status**: ✅ Features 001-002 Completas | 🚧 Feature 003 Em Planejamento  
**Última Atualização**: 09/01/2026
