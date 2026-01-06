# Implementation Plan: Gerenciamento de Planos de Treino

**Branch**: `001-workout-plan-management` | **Date**: 6 de Janeiro de 2026 | **Spec**: [spec.md](spec.md)
**Input**: Feature specification from `/specs/001-workout-plan-management/spec.md`

**Note**: This template is filled in by the `/speckit.plan` command. See `.specify/templates/commands/plan.md` for the execution workflow.

## Summary

Implementar sistema CRUD completo para gerenciamento de planos de treino em aplicativo iOS nativo. Usuários poderão criar, editar, visualizar, listar e deletar planos de treino contendo exercícios com configurações de séries, repetições e grupos musculares. A solução utilizará SwiftUI para interface e SwiftData para persistência local, seguindo arquitetura de componentes reutilizáveis conforme constitution do projeto.

**Abordagem técnica**: Feature module independente com componentes SwiftUI isolados, view models leves para lógica de apresentação, e models SwiftData com relacionamentos cascade para garantir integridade referencial. Implementação test-first com cobertura de unit tests (view models e validações) e UI tests (fluxos críticos P1).

## Technical Context

**Language/Version**: Swift 5.9+ (iOS SDK)
**Primary Dependencies**: SwiftUI, SwiftData, Combine (timers e reactive)  
**Storage**: SwiftData (persistência local on-device, sem sincronização cloud no MVP)  
**Testing**: XCTest (unit tests), XCTest UI (integration tests para fluxos P1)  
**Target Platform**: iOS 17.0+  
**Project Type**: Mobile (iOS single-target app)  
**Performance Goals**: 60 fps em todas as transições, <1s para carregar lista de 50 planos, <500ms para operações CRUD  
**Constraints**: <100MB uso de memória, offline-first (sem dependência de rede), suporte Dynamic Type e VoiceOver  
**Scale/Scope**: ~10 telas/componentes, suporte a 50+ planos simultaneamente, dezenas de exercícios por plano

## Constitution Check

*GATE: Must pass before Phase 0 research. Re-check after Phase 1 design.*

| Principle | Requirement | Status | Notes |
|-----------|-------------|--------|-------|
| **I. Mobile-First SwiftUI Components** | UI em componentes reutilizáveis, acessíveis, localizados, previewable | ✅ PASS | Feature será implementada como módulo de componentes SwiftUI independentes (WorkoutPlanCard, ExerciseRow, etc.) com previews Xcode |
| **II. Test-First** | Testes automatizados antes de merge, cobertura de view models e fluxos P1 | ✅ PASS | Plan inclui unit tests para validações e view models, UI tests para criar/editar/deletar planos (stories P1) |
| **III. Clean Architecture** | Organização por feature, APIs explícitas, dependências acíclicas | ✅ PASS | Feature isolada em `Views/Workout/` com models em `Models/`, sem dependências circulares |
| **IV. Observability & Privacy** | Logging estruturado, sem dados sensíveis em logs | ✅ PASS | Apenas logs de operações CRUD (nível INFO/ERROR), sem dados pessoais do usuário |
| **V. Versioning & Compatibility** | SemVer, migrações documentadas para breaking changes | ✅ PASS | MVP v1.0.0, SwiftData schema inicial sem migrações necessárias nesta feature |
| **Additional: Dependencies** | Justificar e revisar dependências third-party | ✅ PASS | Zero dependências third-party, apenas frameworks nativos iOS (SwiftUI, SwiftData) |
| **Additional: Security** | Keychain para dados sensíveis, TLS para rede | ✅ N/A | Feature offline sem dados sensíveis ou comunicação de rede |
| **Development Workflow** | Feature branches, PRs com testes, code review, CI | ✅ PASS | Branch `001-workout-plan-management`, PR requirements serão seguidos |

**GATE RESULT**: ✅ **APPROVED** - Todos os princípios atendidos ou não aplicáveis

### Post-Phase 1 Re-validation

**Date**: 6 de Janeiro de 2026  
**Reviewer**: AI Agent

Após completar Phase 0 (research.md) e Phase 1 (data-model.md, quickstart.md):

| Principle | Re-check Status | Evidence |
|-----------|----------------|----------|
| **I. Mobile-First SwiftUI** | ✅ CONFIRMED | Components identificados: WorkoutPlanCard, ExerciseRow, PrimaryButton, EmptyStateView. VoiceOver labels e Dynamic Type documentados no quickstart.md |
| **II. Test-First** | ✅ CONFIRMED | Test strategy em data-model.md: ViewModels >90%, Models >80%, UI tests para P1. Quickstart inclui manual testing checklist |
| **III. Clean Architecture** | ✅ CONFIRMED | Project structure claramente separado: Models/, Views/Workout/, ViewModels/. SwiftData relationships com boundaries claros |
| **IV. Observability** | ✅ CONFIRMED | Research.md define logging mínimo. Nenhum dado pessoal exposto (apenas nomes de exercícios genéricos) |
| **V. Versioning** | ✅ CONFIRMED | data-model.md documenta migration strategy com VersionedSchema para futuras mudanças |

**Final Approval**: ✅ **ALL GATES PASSED** - Ready for Phase 2 (task breakdown)

## Project Structure

### Documentation (this feature)

```text
specs/001-workout-plan-management/
├── spec.md              # Feature specification (completed)
├── plan.md              # This file (/speckit.plan command output)
├── research.md          # Phase 0 output (technology decisions, patterns)
├── data-model.md        # Phase 1 output (entities, relationships, validation rules)
├── quickstart.md        # Phase 1 output (how to run, test, and demo feature)
├── contracts/           # Phase 1 output (not applicable - no API contracts for local-only feature)
├── checklists/          # Quality gates
│   └── requirements.md  # Spec quality checklist (completed)
└── tasks.md             # Phase 2 output (/speckit.tasks command - NOT created by /speckit.plan)
```

### Source Code (repository root)

```text
BumbumNaNuca/
├── App/
│   └── BumbumNaNucaApp.swift           # App entry point, SwiftData container setup
├── Models/
│   ├── WorkoutPlan.swift               # @Model: plano de treino (name, description, isActive, exercises)
│   ├── Exercise.swift                  # @Model: exercício (name, muscleGroup, sets, reps, restTime, order)
│   └── MuscleGroup.swift               # enum: Peito, Costas, Pernas, Ombros, Braços, Abdômen, Cardio
├── Views/
│   ├── ContentView.swift               # TabView principal (Home, Treinos, Progresso, Check-in)
│   ├── Workout/
│   │   ├── WorkoutPlanListView.swift  # Lista de planos (P1)
│   │   ├── WorkoutPlanDetailView.swift # Detalhes do plano (P1)
│   │   ├── CreateWorkoutPlanView.swift # Criar plano (P1)
│   │   ├── EditWorkoutPlanView.swift   # Editar plano (P2)
│   │   └── AddExerciseSheet.swift      # Modal adicionar exercício (P1)
│   └── Components/
│       ├── WorkoutPlanCard.swift       # Card de plano na lista
│       ├── ExerciseRow.swift           # Row de exercício
│       ├── PrimaryButton.swift         # Botão principal reutilizável
│       └── EmptyStateView.swift        # Estado vazio genérico
├── ViewModels/
│   ├── WorkoutPlanListViewModel.swift  # Lógica de listagem e delete
│   ├── WorkoutPlanFormViewModel.swift  # Lógica de criar/editar com validações
│   └── ExerciseFormViewModel.swift     # Lógica de formulário de exercício
└── Utilities/
    ├── Extensions/
    │   └── Date+Extensions.swift       # Helper para formatação de datas
    └── Validators/
        └── WorkoutPlanValidator.swift  # Validação de regras de negócio

BumbumNaNucaTests/
├── Models/
│   ├── WorkoutPlanTests.swift          # Testes do modelo WorkoutPlan
│   └── ExerciseTests.swift             # Testes do modelo Exercise
├── ViewModels/
│   ├── WorkoutPlanFormViewModelTests.swift  # Testes de validação, salvar, cancelar
│   └── WorkoutPlanListViewModelTests.swift  # Testes de delete, marcar ativo
└── Integration/
    └── WorkoutPlanCRUDTests.swift      # UI tests para fluxos P1 completos

BumbumNaNucaUITests/
└── WorkoutPlanFlowTests.swift          # Testes E2E: criar → editar → deletar
```

**Structure Decision**: Mobile iOS app structure seguindo organização por camadas (Models, Views, ViewModels) com sub-organização por feature em Views/. Esta estrutura é padrão para apps SwiftUI de porte médio, facilita navegação no Xcode e alinha com princípio III (Clean Architecture) da constitution ao manter boundaries claros entre UI, lógica de apresentação e models.

## Complexity Tracking

> **Fill ONLY if Constitution Check has violations that must be justified**

✅ **No violations** - All constitution principles are satisfied. This feature introduces appropriate complexity for a mobile CRUD feature (ViewModels for presentation logic, SwiftData relationships for data integrity) without violating simplicity or architecture principles.
