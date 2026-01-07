# Implementation Plan: Executar Treino

**Branch**: `002-execute-workout` | **Date**: 2026-01-07 | **Spec**: [spec.md](./spec.md)
**Input**: Feature specification from `/specs/002-execute-workout/spec.md`

## Summary

Implementar funcionalidade completa de execução de treinos, permitindo aos usuários iniciar sessões a partir de planos salvos, registrar peso e repetições para cada série, usar timer automático de descanso entre séries com feedback haptico/sonoro, visualizar dados do treino anterior para comparação, e finalizar com resumo detalhado. A implementação deve garantir persistência incremental de dados, validação em tempo real de inputs, e suporte a sessões parcialmente completadas.

## Technical Context

**Language/Version**: Swift 5.9+  
**Primary Dependencies**: SwiftUI, SwiftData, AVFoundation, Combine  
**Storage**: SwiftData (local persistence), modelos: WorkoutSession, ExerciseSet  
**Testing**: XCTest (unit tests para ViewModels e lógica de negócio), XCTest UI (fluxos P1)  
**Target Platform**: iOS 17.0+  
**Project Type**: Mobile (iOS nativo)  
**Performance Goals**: 60 fps UI, timer precisão ±2s, registro de série <30s, persistência <100ms  
**Constraints**: Offline-first, timer background 3min, zero perda de dados, validação em tempo real  
**Scale/Scope**: ~6 novas Views, 5 ViewModels, 2 modelos SwiftData, ~15 testes unitários, ~5 UI tests

## Constitution Check

*GATE: Must pass before Phase 0 research. Re-check after Phase 1 design.*

### Principle I: Mobile-First SwiftUI Components
- [ ] **GATE**: All UI features implemented as small, reusable SwiftUI views? 
  - Views: ExecuteWorkoutView, ExecuteExerciseView, RestTimerView, WorkoutSummaryView, ExerciseRowView (execute), ProgressIndicatorView
  - All marked for Preview and independent testing
- [ ] **GATE**: Views accessible (VoiceOver labels, dynamic type, contrast)?
  - Timer deve ter labels acessíveis
  - Inputs numéricos devem suportar VoiceOver
  - Progresso visual deve ter alternativa textual
- [ ] **GATE**: Localized user-facing strings?
  - Textos de UI em Localizable.strings
  - Números formatados com locale correto
- [ ] **GATE**: Components independently previewable?
  - SwiftUI Previews para todas as Views
  - ViewModels testáveis isoladamente

### Principle II: Test-First (NON-NEGOTIABLE)
- [ ] **GATE**: Automated tests for new features before implementation complete?
  - Unit tests: ViewModels (WorkoutSessionViewModel, ExerciseSetViewModel, RestTimerViewModel)
  - UI tests: P1 flow (iniciar → registrar → timer → finalizar)
- [ ] **GATE**: XCTest coverage for view models and business logic?
  - Validação de inputs (peso/reps)
  - Cálculos de resumo (duração, totais)
  - Lógica de timer
  - Detecção de sessões existentes
- [ ] **GATE**: UI tests for primary user flows (P1 stories)?
  - Fluxo completo de treino básico
  - Timer automático entre séries
- [ ] **GATE**: Tests run by CI on every PR and pass before merge?
  - Configurar CI para executar testes

### Principle III: Clean Architecture & Module Boundaries
- [ ] **GATE**: Code organized by feature (not technical role only)?
  - Estrutura: BumbumNaNuca/Views/Workout/Execute/*
  - Models: WorkoutSession, ExerciseSet em BumbumNaNuca/Models/
  - ViewModels: BumbumNaNuca/ViewModels/Execute/*
- [ ] **GATE**: Public APIs between features explicit and minimal?
  - Interfaces entre Execute e Workout Plan
  - Compartilhamento de modelos via SwiftData
- [ ] **GATE**: Dependencies acyclic?
  - Execute depende de Models (WorkoutPlan, Exercise)
  - Não circular
- [ ] **GATE**: Small protocols for dependency inversion?
  - Não necessário para MVP (acoplamento via SwiftData é aceitável)

### Principle IV: Observability & Privacy
- [ ] **GATE**: Structured logging for features?
  - Logger para início/fim de sessões
  - Erros de validação
  - Timer events
- [ ] **GATE**: Crash reporting integrated?
  - Não necessário para MVP (testar localmente)
- [ ] **GATE**: Telemetry reviewed for user data?
  - Nenhum dado sensível (pesos/reps) deve ser logado
  - Apenas eventos agregados (sessão iniciada, finalizada)
- [ ] **GATE**: Privacy rules followed, user opt-out respected?
  - Dados apenas locais, sem analytics externo no MVP

### Principle V: Versioning & Backwards Compatibility
- [ ] **GATE**: SwiftData migrations planned for new models?
  - WorkoutSession e ExerciseSet são novos
  - Migração planejada para adicionar ao schema
- [ ] **GATE**: Breaking changes documented with migration plan?
  - Adição de novos modelos não é breaking
  - Documentar schema evolution

### Additional Constraints
- [ ] **GATE**: iOS 17.0+ minimum deployment target confirmed?
  - Verificar Xcode project settings
- [ ] **GATE**: Swift stable version used?
  - Swift 5.9+ (verificar toolchain)
- [ ] **GATE**: Third-party libraries justified?
  - Nenhuma dependência externa (apenas frameworks Apple)
- [ ] **GATE**: Secure storage for sensitive data?
  - SwiftData com criptografia padrão
  - Sem dados sensíveis além de workout data

### Development Workflow
- [ ] **GATE**: Work on feature branch with PR?
  - Branch 002-execute-workout já criada
- [ ] **GATE**: PR includes: description, linked spec, tests, screenshots, constitution checklist?
  - Template de PR deve incluir seção Constitution Compliance
- [ ] **GATE**: At least one code review approval?
  - Sim
- [ ] **GATE**: CI passes (tests, linting, formatting)?
  - Configurar SwiftLint se não existir

**EVALUATION**: ⚠️ CONDITIONAL PASS - Pending items to address:
- CI configuration for automated tests (can be done in parallel with implementation)
- SwiftLint configuration (optional for MVP, recommended)
- All other gates are clear or can be satisfied during implementation

**Violations Requiring Justification**: None

## Project Structure

### Documentation (this feature)

```text
specs/[###-feature]/
├── plan.md              # This file (/speckit.plan command output)
├── research.md          # Phase 0 output (/speckit.plan command)
├── data-model.md        # Phase 1 output (/speckit.plan command)
├── quickstart.md        # Phase 1 output (/speckit.plan command)
├── contracts/           # Phase 1 output (/speckit.plan command)
└── tasks.md             # Phase 2 output (/speckit.tasks command - NOT created by /speckit.plan)
```

### Source Code (repository root)

```text
BumbumNaNuca/
├── Models/
│   ├── WorkoutPlan.swift          # Existing
│   ├── Exercise.swift              # Existing
│   ├── MuscleGroup.swift           # Existing
│   ├── WorkoutSession.swift        # NEW - Phase 1
│   └── ExerciseSet.swift           # NEW - Phase 1
├── ViewModels/
│   ├── Execute/                    # NEW folder
│   │   ├── WorkoutSessionViewModel.swift      # NEW
│   │   ├── ExecuteExerciseViewModel.swift     # NEW
│   │   ├── RestTimerViewModel.swift           # NEW
│   │   └── WorkoutSummaryViewModel.swift      # NEW
│   └── [existing ViewModels...]
├── Views/
│   ├── Workout/
│   │   ├── Execute/                # NEW folder
│   │   │   ├── ExecuteWorkoutView.swift       # NEW - lista exercícios
│   │   │   ├── ExecuteExerciseView.swift      # NEW - registrar séries
│   │   │   ├── RestTimerView.swift            # NEW - timer descanso
│   │   │   ├── WorkoutSummaryView.swift       # NEW - resumo final
│   │   │   └── Components/        # NEW folder
│   │   │       ├── ExerciseExecutionRow.swift # NEW
│   │   │       ├── SetInputView.swift         # NEW - inputs peso/reps
│   │   │       ├── ProgressRing.swift         # NEW - timer visual
│   │   │       └── ValidationFeedback.swift   # NEW - feedback inline
│   │   └── [existing Workout views...]
│   └── [other view folders...]
├── Utilities/
│   ├── Helpers/
│   │   └── ExecuteLogger.swift     # NEW - logging para feature Execute (optional)
│   └── Extensions/
│       └── Date+Extensions.swift   # Existing, pode adicionar helpers
└── BumbumNaNucaApp.swift           # Atualizar schema SwiftData

Note: Timer background e haptic feedback são gerenciados diretamente em RestTimerViewModel
(ver contracts/viewmodels.md) - sem necessidade de helpers separados.

BumbumNaNucaTests/
└── Execute/                        # NEW folder
    ├── WorkoutSessionViewModelTests.swift
    ├── ExecuteExerciseViewModelTests.swift
    ├── RestTimerViewModelTests.swift
    ├── ValidationTests.swift
    └── MockData.swift              # Mocks para testes

BumbumNaNucaUITests/
└── ExecuteWorkoutUITests.swift     # NEW - P1 flow tests
```

**Structure Decision**: Mobile app with feature-based organization. Execute workout é uma nova sub-feature dentro de Workout, com seus próprios ViewModels e Views organizados em subpastas dedicadas. Modelos SwiftData ficam centralizados em Models/. Testes espelham a estrutura de produção.

## Complexity Tracking

> **This section is intentionally left empty**

**Justification**: No violations of constitution principles detected. All complexity is justified by feature requirements and follows established patterns in the codebase (SwiftUI + SwiftData architecture).
