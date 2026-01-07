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
│   └── MuscleGroup.swift      # Enum de grupos musculares
├── Views/
│   ├── Workout/               # Telas relacionadas a planos
│   │   ├── WorkoutPlanListView.swift
│   │   ├── WorkoutPlanDetailView.swift
│   │   ├── WorkoutPlanRowView.swift
│   │   ├── CreateWorkoutPlanView.swift
│   │   ├── EditWorkoutPlanView.swift
│   │   └── AddExerciseView.swift
│   └── Components/            # Componentes reutilizáveis
│       ├── PrimaryButton.swift
│       ├── EmptyStateView.swift
│       └── ExerciseRowView.swift
├── ViewModels/                # Lógica de negócio
│   ├── WorkoutPlanListViewModel.swift
│   ├── WorkoutPlanDetailViewModel.swift
│   ├── CreateWorkoutPlanViewModel.swift
│   ├── EditWorkoutPlanViewModel.swift
│   └── AddExerciseViewModel.swift
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
- name: String
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
- defaultRestTime: Int seconds (15-300)
- order: Int (para drag & drop futuro)
- workoutPlan: WorkoutPlan?
```

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
Ver [TESTING.md](TESTING.md) para guia completo de testes manuais.

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

### Funcionalidades Planejadas
- [ ] Reordenar exercícios (drag & drop)
- [ ] Editar exercícios existentes
- [ ] Deletar exercícios individuais
- [ ] Botão "Iniciar Treino" (WorkoutSession)
- [ ] Histórico de execuções
- [ ] Filtros por grupo muscular
- [ ] Duplicar plano existente
- [ ] Importar/Exportar planos (JSON)

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
**Status**: ✅ MVP Completo
**Última Atualização**: 07/01/2026
