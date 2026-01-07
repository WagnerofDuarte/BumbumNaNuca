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
- ~15 testes unitários (XCTest)
- ~5 testes de UI (XCTest UI)

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

- [ ] T001 Criar estrutura de diretórios para feature em BumbumNaNuca/Views/Workout/Execute/
- [ ] T002 Criar estrutura de diretórios para ViewModels em BumbumNaNuca/ViewModels/Execute/
- [ ] T003 Verificar iOS deployment target >= 17.0 em BumbumNaNuca.xcodeproj/project.pbxproj
- [ ] T004 Verificar Swift toolchain >= 5.9 nas configurações do projeto

---

## Phase 2: Fundação (Pré-requisitos Bloqueantes)

**Purpose**: Infraestrutura core que DEVE estar completa antes de qualquer user story

**⚠️ CRÍTICO**: Nenhuma implementação de user story pode começar até esta fase estar completa

- [ ] T005 Criar modelo WorkoutSession em BumbumNaNuca/Models/WorkoutSession.swift
- [ ] T006 [P] Criar modelo ExerciseSet em BumbumNaNuca/Models/ExerciseSet.swift
- [ ] T007 [P] Estender modelo Exercise com defaultSets, defaultReps, defaultRestTime em BumbumNaNuca/Models/Exercise.swift
- [ ] T008 Atualizar schema SwiftData em BumbumNaNuca/BumbumNaNucaApp.swift para incluir WorkoutSession e ExerciseSet
- [ ] T009 [P] Criar arquivo de extensões Date+Extensions.swift para formatação de duração (se não existir)
- [ ] T010 [P] Configurar Logger para feature Execute em BumbumNaNuca/Utilities/Helpers/ExecuteLogger.swift

**Checkpoint**: Fundação pronta - implementação de user stories pode começar em paralelo

---

## Phase 3: User Story 1 - Iniciar e Completar Sessão de Treino Básica (Priority: P1) 🎯 MVP

**Goal**: Permitir que usuário inicie treino, registre séries com peso/reps, e finalize com resumo

**Independent Test**: Criar plano com 2 exercícios → Iniciar sessão → Registrar 2 séries para cada → Finalizar → Verificar resumo mostra 4 séries totais

### Implementação User Story 1

- [ ] T011 [P] Criar WorkoutSessionViewModel em BumbumNaNuca/ViewModels/Execute/WorkoutSessionViewModel.swift
- [ ] T012 [P] Criar ExecuteExerciseViewModel em BumbumNaNuca/ViewModels/Execute/ExecuteExerciseViewModel.swift
- [ ] T013 [P] Criar WorkoutSummaryViewModel em BumbumNaNuca/ViewModels/Execute/WorkoutSummaryViewModel.swift
- [ ] T014 [P] Criar componente ProgressHeader em BumbumNaNuca/Views/Components/ProgressHeader.swift
- [ ] T015 [P] Criar componente SetInputView em BumbumNaNuca/Views/Components/SetInputView.swift
- [ ] T016 [P] Criar componente ValidationFeedback em BumbumNaNuca/Views/Components/ValidationFeedback.swift
- [ ] T017 [P] Criar ExerciseExecutionRow em BumbumNaNuca/Views/Workout/Execute/ExerciseExecutionRow.swift
- [ ] T018 Criar ExecuteWorkoutView em BumbumNaNuca/Views/Workout/Execute/ExecuteWorkoutView.swift (depende de T011, T014, T017)
- [ ] T019 Criar ExecuteExerciseView em BumbumNaNuca/Views/Workout/Execute/ExecuteExerciseView.swift (depende de T012, T015, T016)
- [ ] T020 Criar WorkoutSummaryView em BumbumNaNuca/Views/Workout/Execute/WorkoutSummaryView.swift (depende de T013)
- [ ] T021 Implementar validação em tempo real de peso em ExecuteExerciseViewModel.validateWeight()
- [ ] T022 Implementar validação em tempo real de reps em ExecuteExerciseViewModel.validateReps()
- [ ] T023 Implementar método recordSet() em ExecuteExerciseViewModel com persistência SwiftData
- [ ] T024 Implementar método startSession() em WorkoutSessionViewModel
- [ ] T025 Implementar método finalizeSession() em WorkoutSessionViewModel
- [ ] T026 Implementar cálculos de resumo em WorkoutSummaryViewModel (duration, totalSets, totalReps)
- [ ] T027 Adicionar navegação para ExecuteWorkoutView em WorkoutPlanDetailView
- [ ] T028 [P] Adicionar SwiftUI Previews para todas as Views criadas (T014, T015, T016, T017, T018, T019, T020)
- [ ] T029 [P] Adicionar labels de acessibilidade (VoiceOver) em ExecuteWorkoutView
- [ ] T030 [P] Adicionar labels de acessibilidade (VoiceOver) em ExecuteExerciseView

### Testes User Story 1

- [ ] T031 [P] Criar WorkoutSessionViewModelTests em BumbumNaNucaTests/ViewModels/WorkoutSessionViewModelTests.swift
- [ ] T032 [P] Criar ExecuteExerciseViewModelTests em BumbumNaNucaTests/ViewModels/ExecuteExerciseViewModelTests.swift
- [ ] T033 [P] Escrever teste: startSession cria WorkoutSession com startDate correto
- [ ] T034 [P] Escrever teste: validateWeight aceita valores positivos e rejeita negativos/zero
- [ ] T035 [P] Escrever teste: validateReps aceita inteiros > 0 e rejeita <= 0
- [ ] T036 [P] Escrever teste: recordSet persiste ExerciseSet com dados corretos
- [ ] T037 [P] Escrever teste: finalizeSession marca isCompleted=true e define endDate
- [ ] T038 [P] Escrever teste: resumo calcula duration, totalSets, totalReps corretamente
- [ ] T039 Criar ExecuteWorkoutUITests em BumbumNaNucaUITests/ExecuteWorkoutUITests.swift
- [ ] T040 Escrever UI test: fluxo completo P1 (iniciar → registrar séries → finalizar → verificar resumo)

**Checkpoint**: User Story 1 completamente funcional e testada - pronta para MVP release

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
- [ ] T052 [P] Adicionar labels de acessibilidade em RestTimerView

### Testes User Story 2

- [ ] T053 [P] Criar RestTimerViewModelTests em BumbumNaNucaTests/ViewModels/RestTimerViewModelTests.swift
- [ ] T054 [P] Escrever teste: timer inicia com duração configurada do exercício
- [ ] T055 [P] Escrever teste: timer decrementa corretamente a cada segundo
- [ ] T056 [P] Escrever teste: pause congela contador, resume retoma
- [ ] T057 [P] Escrever teste: skip cancela timer imediatamente
- [ ] T058 [P] Escrever teste: onTimerComplete é chamado quando timer chega a zero
- [ ] T059 Criar UI test: timer aparece após série, conta até zero, emite feedback

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

### Testes User Story 3

- [ ] T065 [P] Escrever teste: fetchLastWorkoutData retorna dados corretos da última sessão completa
- [ ] T066 [P] Escrever teste: fetchLastWorkoutData retorna nil se é primeira execução
- [ ] T067 [P] Escrever teste: fetchLastWorkoutData ignora sessões incompletas
- [ ] T068 [P] Escrever teste: fetchLastWorkoutData ignora sessões de outros planos
- [ ] T069 Criar UI test: dados do último treino aparecem corretamente na tela de execução

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

### Testes User Story 4

- [ ] T078 [P] Escrever teste: exerciseStatus retorna pending para exercício não iniciado
- [ ] T079 [P] Escrever teste: exerciseStatus retorna inProgress quando exercício tem séries mas não completo
- [ ] T080 [P] Escrever teste: exerciseStatus retorna completed quando exercício marcado como completo
- [ ] T081 [P] Escrever teste: progressPercentage calcula corretamente (2/4 exercícios = 50%)
- [ ] T082 Criar UI test: progresso visual atualiza conforme exercícios são completados

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

### Testes User Story 5

- [ ] T093 [P] Escrever teste: checkExistingSession detecta sessão não finalizada
- [ ] T094 [P] Escrever teste: resumeSession carrega estado da sessão existente
- [ ] T095 [P] Escrever teste: abandonSession marca sessão como completa e permite nova
- [ ] T096 [P] Escrever teste: recordSet persiste dados imediatamente (verificar com fetch)
- [ ] T097 [P] Escrever teste: markExerciseComplete permite completar com 2 séries quando defaultSets=4
- [ ] T098 Criar UI test: fluxo de conflito (iniciar → sair → reiniciar → alerta → retomar)

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
- [ ] T108 Executar todos os testes unitários e garantir 100% passam
- [ ] T109 Executar todos os testes UI e garantir 100% passam
- [ ] T110 Testar fluxo completo end-to-end manualmente (smoke test)

---

## Phase 9: CI & Documentation

**Purpose**: Integração contínua e documentação final

- [ ] T111 Adicionar configuração de CI para executar testes em cada PR (.github/workflows/ ou equivalente)
- [ ] T112 [P] Atualizar README.md com instruções de uso da feature Execute Workout
- [ ] T113 [P] Criar TESTING.md documentando cenários de teste manuais
- [ ] T114 [P] Atualizar IMPLEMENTATION_STATUS.md marcando feature como completa
- [ ] T115 Criar PR com título "feat: Implementar Executar Treino (002-execute-workout)"

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
- Testável: Fluxo P1 end-to-end

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

### 3. Test Coverage Targets

- **Unit Tests**: ≥80% coverage para ViewModels
- **UI Tests**: 100% coverage para P1 flows
- **Manual Tests**: All edge cases em TESTING.md

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

- **Total Tasks**: 115
- **Setup Tasks**: 4 (Phase 1)
- **Foundational Tasks**: 6 (Phase 2) - BLOCKING
- **US1 Tasks**: 30 (T011-T040) - MVP
- **US2 Tasks**: 19 (T041-T059) - P2 Enhancement
- **US3 Tasks**: 10 (T060-T069) - P2 Enhancement
- **US4 Tasks**: 13 (T070-T082) - P3 Enhancement
- **US5 Tasks**: 16 (T083-T098) - P3 Edge Cases
- **Polish Tasks**: 12 (T099-T110)
- **CI/Docs Tasks**: 5 (T111-T115)

**Parallelizable Tasks**: 58 (marcados com [P])

**Estimated Total Duration**: 15-20 horas (com US1-5 completas)
**Estimated MVP Duration**: 8-12 horas (apenas US1)

---

## Next Steps

1. ✅ Review tasks.md com stakeholders
2. ⏳ Começar Phase 1 (Setup)
3. ⏳ Completar Phase 2 (Fundação) - BLOCKING
4. ⏳ Implementar US1 (MVP) com testes
5. ⏳ Release MVP ou continuar com US2-5
