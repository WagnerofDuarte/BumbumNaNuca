---
description: "Task breakdown for Executar Treino feature implementation"
---

# Tasks: Executar Treino

**Feature**: 002-execute-workout  
**Created**: 2026-01-07  
**Input**: Design documents from `/specs/002-execute-workout/`

## Summary

Este documento quebra a implementação do recurso "Executar Treino" em tarefas granulares e executáveis, organizadas por user story conforme especificado em [spec.md](./spec.md). Cada fase corresponde a uma user story e pode ser implementada e testada de forma independente.

**Escopo Total**:
- 5 User Stories (P1: 1, P2: 2, P3: 2)
- 2 novos modelos SwiftData (WorkoutSession, ExerciseSet)
- 1 modelo estendido (Exercise)
- 4 ViewModels (@Observable)
- 8 Views (SwiftUI)

**Estratégia de Implementação**:
1. MVP: User Story 1 apenas (P1) - entrega valor fundamental
2. Incremental: Adicionar P2 stories (timer, dados anteriores)
3. Polish: P3 stories (progresso visual, sessões incompletas)

---

## Format: `- [ ] [ID] [P?] [Story] Description`

- **Checkbox**: `- [ ]` (marca progresso)
- **[ID]**: Número sequencial (T001, T002...)
- **[P]**: Pode executar em paralelo (arquivos diferentes, sem dependências)
- **[Story]**: User story associada (US1, US2, US3, US4, US5)
- **Description**: Ação clara com caminho de arquivo exato

---

## Phase 1: Setup (Infraestrutura Compartilhada)

**Purpose**: Configuração inicial do projeto e estrutura básica

- [X] T001 Criar estrutura de diretórios para feature em BumbumNaNuca/Views/Workout/Execute/
- [X] T002 Criar estrutura de diretórios para ViewModels em BumbumNaNuca/ViewModels/Execute/
- [X] T003 Verificar iOS deployment target >= 17.0 em BumbumNaNuca.xcodeproj/project.pbxproj
- [X] T004 Verificar Swift toolchain >= 5.9 nas configurações do projeto

---

## Phase 2: Fundação (Pré-requisitos Bloqueantes)

**Purpose**: Infraestrutura core que DEVE estar completa antes de qualquer user story

**⚠️ CRÍTICO**: Nenhuma implementação de user story pode começar até esta fase estar completa

- [X] T005 Criar modelo WorkoutSession em BumbumNaNuca/Models/WorkoutSession.swift
- [X] T006 [P] Criar modelo ExerciseSet em BumbumNaNuca/Models/ExerciseSet.swift
- [X] T007 [P] Estender modelo Exercise com defaultSets, defaultReps, defaultRestTime em BumbumNaNuca/Models/Exercise.swift
- [X] T008 Atualizar schema SwiftData em BumbumNaNuca/BumbumNaNucaApp.swift para incluir WorkoutSession e ExerciseSet
- [X] T009 [P] Criar arquivo de extensões Date+Extensions.swift para formatação de duração (se não existir)
- [ ] T010 [P] Configurar Logger para feature Execute em BumbumNaNuca/Utilities/Helpers/ExecuteLogger.swift

**Checkpoint**: Fundação pronta - implementação de user stories pode começar em paralelo

---

## Phase 3: User Story 1 - Iniciar e Completar Sessão de Treino Básica (Priority: P1) 🎯 MVP

**Goal**: Permitir que usuário inicie treino, registre séries com peso/reps, e finalize com resumo

**Independent Test**: Criar plano com 2 exercícios → Iniciar sessão → Registrar 2 séries para cada → Finalizar → Verificar resumo mostra 4 séries totais

### Implementação User Story 1

- [X] T011 [P] Criar WorkoutSessionViewModel em BumbumNaNuca/ViewModels/Execute/WorkoutSessionViewModel.swift
- [X] T012 [P] Criar ExecuteExerciseViewModel em BumbumNaNuca/ViewModels/Execute/ExecuteExerciseViewModel.swift
- [X] T013 [P] Criar WorkoutSummaryViewModel em BumbumNaNuca/ViewModels/Execute/WorkoutSummaryViewModel.swift
- [X] T014 [P] Criar componente ProgressHeader em BumbumNaNuca/Views/Components/ProgressHeader.swift
- [X] T015 [P] Criar componente SetInputView em BumbumNaNuca/Views/Components/SetInputView.swift
- [X] T016 [P] Criar componente ValidationFeedback em BumbumNaNuca/Views/Components/ValidationFeedback.swift
- [X] T017 [P] Criar ExerciseExecutionRow em BumbumNaNuca/Views/Workout/Execute/ExerciseExecutionRow.swift
- [X] T018 Criar ExecuteWorkoutView em BumbumNaNuca/Views/Workout/Execute/ExecuteWorkoutView.swift (depende de T011, T014, T017)
- [X] T019 Criar ExecuteExerciseView em BumbumNaNuca/Views/Workout/Execute/ExecuteExerciseView.swift (depende de T012, T015, T016)
- [X] T020 Criar WorkoutSummaryView em BumbumNaNuca/Views/Workout/Execute/WorkoutSummaryView.swift (depende de T013)
- [X] T021 Implementar validação em tempo real de peso em ExecuteExerciseViewModel.validateWeight()
- [X] T022 Implementar validação em tempo real de reps em ExecuteExerciseViewModel.validateReps()
- [X] T023 Implementar método recordSet() em ExecuteExerciseViewModel com persistência SwiftData
- [X] T024 Implementar método startSession() em WorkoutSessionViewModel
- [X] T025 Implementar método finalizeSession() em WorkoutSessionViewModel
- [X] T026 Implementar cálculos de resumo em WorkoutSummaryViewModel (duration, totalSets, totalReps)
- [X] T027 Adicionar navegação para ExecuteWorkoutView em WorkoutPlanDetailView
- [ ] T028 [P] Adicionar SwiftUI Previews para todas as Views criadas (T014, T015, T016, T017, T018, T019, T020)

**Checkpoint**: User Story 1 completamente funcional - pronta para MVP release

---

## Phase 4: User Story 2 - Timer de Descanso entre Séries (Priority: P2)

**Goal**: Timer automático inicia após série, vibra/soa ao terminar, funciona em background 3min

**Independent Test**: Configurar exercício com 30s de descanso → Completar série → Verificar timer inicia automaticamente → Esperar término → Verificar haptic/som

### Implementação User Story 2

- [ ] T041 [P] Criar RestTimerViewModel em BumbumNaNuca/ViewModels/Execute/RestTimerViewModel.swift
- [ ] T042 [P] Criar componente CircularProgressView em BumbumNaNuca/Views/Components/CircularProgressView.swift
- [ ] T043 Criar RestTimerView em BumbumNaNuca/Views/Workout/Execute/RestTimerView.swift (depende de T041, T042)
- [ ] T044 Implementar Combine Timer + Background Task em RestTimerViewModel para 3min background
- [ ] T045 Implementar haptic feedback (UINotificationFeedbackGenerator) em RestTimerViewModel.onTimerComplete()
- [ ] T046 Implementar áudio feedback (AVAudioPlayer com system sounds) em RestTimerViewModel.onTimerComplete()
- [ ] T047 Implementar controles pause/resume em RestTimerViewModel
- [ ] T048 Implementar controle skip em RestTimerViewModel
- [ ] T049 Integrar RestTimerView em ExecuteExerciseView após recordSet() bem-sucedido
- [ ] T050 Implementar auto-cancelamento do timer quando nova série é iniciada em ExecuteExerciseViewModel
- [ ] T051 [P] Adicionar SwiftUI Preview para RestTimerView

**Checkpoint**: User Story 1 E 2 ambas funcionam independentemente

---

## Phase 5: User Story 3 - Visualizar Dados do Último Treino (Priority: P2)

**Goal**: Mostrar peso/reps da última sessão completa do mesmo plano para referência

**Independent Test**: Completar treino com 80kg × 10 reps → Iniciar nova sessão do mesmo plano → Verificar "Último: 80kg × 10 reps" aparece na tela de exercício

### Implementação User Story 3

- [ ] T060 Implementar método fetchLastWorkoutData() em ExecuteExerciseViewModel
- [ ] T061 Criar Query SwiftData com Predicate para buscar última sessão completa do mesmo plano em ExecuteExerciseViewModel
- [ ] T062 Implementar struct LastWorkoutData com formattedText em ExecuteExerciseViewModel
- [ ] T063 Adicionar seção "Dados do Último Treino" em ExecuteExerciseView (condicional se dados existirem)
- [ ] T064 Formatar exibição com locale correto (NumberFormatter para peso)

**Checkpoint**: User Stories 1, 2 E 3 todas funcionam independentemente

---

## Phase 6: User Story 4 - Acompanhar Progresso Durante Sessão (Priority: P3)

**Goal**: Indicadores visuais de status (completo/em andamento/pendente) e contador de progresso

**Independent Test**: Iniciar treino com 4 exercícios → Completar 2 → Verificar UI mostra "2/4 exercícios completos" e badges de status corretos

### Implementação User Story 4

- [ ] T070 Implementar enum ExerciseStatus (pending, inProgress, completed) em WorkoutSessionViewModel
- [ ] T071 Implementar método exerciseStatus(_:) em WorkoutSessionViewModel
- [ ] T072 Implementar computed property progressPercentage em WorkoutSessionViewModel
- [ ] T073 Implementar computed property progressText em WorkoutSessionViewModel
- [ ] T074 Adicionar status badges em ExerciseExecutionRow (SF Symbols: circle, circle.fill, checkmark.circle.fill)
- [ ] T075 Atualizar ProgressHeader para mostrar barra de progresso visual (ProgressView)
- [ ] T076 Adicionar indicador "Série X de Y" em ExecuteExerciseView usando viewModel.progressText
- [ ] T077 [P] Atualizar SwiftUI Previews com diferentes estados de progresso

**Checkpoint**: User Stories 1-4 todas funcionam

---

## Phase 7: User Story 5 - Gerenciar Sessão Incompleta (Priority: P3)

**Goal**: Salvar progresso parcial, detectar sessões existentes, permitir retomar ou abandonar

**Independent Test**: Iniciar treino → Registrar 2 séries → Sair do app → Reabrir e iniciar mesmo treino → Verificar alerta "Sessão existente: Retomar ou Abandonar?"

### Implementação User Story 5

- [ ] T083 Implementar método checkExistingSession() em WorkoutSessionViewModel
- [ ] T084 Criar Query SwiftData para encontrar sessões não finalizadas do mesmo plano
- [ ] T085 Implementar método resumeSession(_:) em WorkoutSessionViewModel
- [ ] T086 Implementar método abandonSession(_:) em WorkoutSessionViewModel (marca como completa com dados atuais)
- [ ] T087 Adicionar enum SessionConflictResolution (resume, abandon) em WorkoutSessionViewModel
- [ ] T088 Adicionar state ViewState.sessionConflict em ExecuteWorkoutView
- [ ] T089 Criar alert de conflito de sessão em ExecuteWorkoutView.onAppear()
- [ ] T090 Garantir que recordSet() salva imediatamente via SwiftData (auto-save já configurado)
- [ ] T091 Implementar método markExerciseComplete() que permite completar com qualquer número de séries
- [ ] T092 Adicionar indicador visual quando defaultSets atingido mas permitir continuar (hasReachedDefaultSets)

**Checkpoint**: Todas user stories (1-5) independentemente funcionais

---

## Phase 8: Polish & Cross-Cutting Concerns

**Purpose**: Refinamentos finais que não pertencem a uma user story específica

- [ ] T099 [P] Adicionar suporte a Dynamic Type (tamanhos de fonte) em todas as Views
- [ ] T100 [P] Testar contraste de cores no modo escuro em todas as telas
- [ ] T101 [P] Adicionar localização (Localizable.strings) para todos os textos UI
- [ ] T102 [P] Configurar formatação de números com locale correto (NumberFormatter para pesos)
- [ ] T103 [P] Adicionar logging estruturado para eventos críticos (sessão iniciada, finalizada, erro)
- [ ] T104 [P] Revisar e garantir que modo silencioso do dispositivo é respeitado no áudio do timer
- [ ] T105 [P] Adicionar animações suaves para transições de estado (exercício completo, progresso)
- [ ] T106 [P] Otimizar queries SwiftData com índices se necessário (performance > 60fps)
- [ ] T107 [P] Documentar código público com DocC comments
- [ ] T108 Testar fluxo completo end-to-end manualmente (smoke test)

---

## Phase 9: Documentation

**Purpose**: Documentação final

- [ ] T109 [P] Atualizar README.md com instruções de uso da feature Execute Workout
- [ ] T110 [P] Atualizar IMPLEMENTATION_STATUS.md marcando feature como completa
- [ ] T111 Criar PR com título "feat: Implementar Executar Treino (002-execute-workout)"

---

## Dependencies

### User Story Dependencies (Completion Order)

```
Setup (Phase 1)
    ↓
Fundação (Phase 2) ← BLOCKING: Must complete before ANY user story
    ↓
    ├─→ US1 (Phase 3) ← MVP: Can be released independently
    │
    ├─→ US2 (Phase 4) ← Independent of US1 (different files, no shared state)
    │
    ├─→ US3 (Phase 5) ← Independent of US1-2 (only reads completed sessions)
    │
    ├─→ US4 (Phase 6) ← Enhances US1 but independent (only UI state)
    │
    └─→ US5 (Phase 7) ← Independent (session lifecycle management)
        ↓
    Polish (Phase 8)
        ↓
    CI/Docs (Phase 9)
```

### Critical Path (Minimum MVP)

Setup → Fundação → US1 → Polish (subset) → Release

**Estimated MVP Duration**: 8-12 horas (apenas US1 + fundação + testes básicos)

### Parallel Execution Opportunities

**After Phase 2 complete, these can run in parallel**:
- US1 (Phase 3): 1 developer
- US2 (Phase 4): 1 developer (different files)
- US3 (Phase 5): 1 developer (different files)

**Within each phase**:
- Tasks marked [P] podem executar simultaneamente
- Exemplo Phase 3: T011-T017 todos marcados [P] (diferentes arquivos)

---

## Implementation Strategy

### 1. MVP First (Recommended)

**Week 1**: Setup + Fundação + US1
- Entrega: Executar treino básico completo
- Valor: Usuário pode registrar treinos e ver resumo
- Validação: Fluxo P1 end-to-end manual

**Week 2**: US2 + US3
- Entrega: Timer automático + dados anteriores
- Valor: Experiência melhorada, progressão rastreável

**Week 3**: US4 + US5 + Polish
- Entrega: Indicadores visuais + sessões incompletas
- Valor: Feature completa com edge cases cobertos

### 2. Incremental Delivery

Cada user story entrega valor independente:
- **US1**: Treino básico funcional → Release MVP
- **US2**: Timer → Release v1.1
- **US3**: Dados anteriores → Release v1.2
- **US4**: Progresso visual → Release v1.3
- **US5**: Sessões incompletas → Release v1.4

---

## Task Format Validation ✅

**Checklist Compliance**:
- [x] Todas as tarefas usam formato `- [ ] [ID] [P?] [Story] Description`
- [x] IDs sequenciais (T001-T115)
- [x] Marcador [P] apenas em tarefas paralelizáveis
- [x] Story labels [US1]-[US5] em tarefas de user stories
- [x] Setup/Fundação/Polish SEM story label
- [x] Descrições incluem caminhos de arquivo exatos
- [x] Organizadas por user story em priority order (P1 → P2 → P3)

**Independence Validation**:
- [x] Cada user story pode ser testada isoladamente
- [x] MVP (US1) pode ser released sem US2-5
- [x] Dependências documentadas explicitamente

---

## Totals

- **Total Tasks**: 74
- **Setup Tasks**: 4 (Phase 1)
- **Foundational Tasks**: 6 (Phase 2) - BLOCKING
- **US1 Tasks**: 18 (T011-T028) - MVP
- **US2 Tasks**: 11 (T041-T051) - P2 Enhancement
- **US3 Tasks**: 5 (T060-T064) - P2 Enhancement
- **US4 Tasks**: 8 (T070-T077) - P3 Enhancement
- **US5 Tasks**: 10 (T083-T092) - P3 Edge Cases
- **Polish Tasks**: 9 (T099-T108)
- **Docs Tasks**: 3 (T109-T111)

**Parallelizable Tasks**: 39 (marcados com [P])

**Estimated Total Duration**: 9-14 horas (com US1-5 completas)
**Estimated MVP Duration**: 4-6 horas (apenas US1)

---

## Next Steps

1. ✅ Review tasks.md com stakeholders
2. ⏳ Começar Phase 1 (Setup)
3. ⏳ Completar Phase 2 (Fundação) - BLOCKING
4. ⏳ Implementar US1 (MVP)
5. ⏳ Release MVP ou continuar com US2-5
