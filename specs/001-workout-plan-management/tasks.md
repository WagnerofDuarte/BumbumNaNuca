# Tasks: Gerenciamento de Planos de Treino

**Input**: Design documents from `/specs/001-workout-plan-management/`
**Prerequisites**: plan.md, spec.md, research.md, data-model.md, quickstart.md

**Tests**: Tests are NOT explicitly requested in specification, focusing on implementation tasks only. Test strategy is documented in data-model.md and quickstart.md for reference.

**Organization**: Tasks are grouped by user story to enable independent implementation and testing of each story.

## Format: `[ID] [P?] [Story] Description`

- **[P]**: Can run in parallel (different files, no dependencies)
- **[Story]**: Which user story this task belongs to (e.g., US1, US2, US3)
- Include exact file paths in descriptions

## Path Conventions

Mobile iOS app structure:
- Models: `BumbumNaNuca/Models/`
- Views: `BumbumNaNuca/Views/`
- ViewModels: `BumbumNaNuca/ViewModels/`
- Tests: `BumbumNaNucaTests/`

---

## Phase 1: Setup (Shared Infrastructure)

**Purpose**: Verificar estrutura existente e configurar SwiftData container

- [ ] T001 Verificar que estrutura de pastas existe: BumbumNaNuca/{Models,Views,ViewModels,Utilities}
- [ ] T002 Configurar SwiftData ModelContainer em BumbumNaNuca/App/BumbumNaNucaApp.swift com schema inicial
- [ ] T003 [P] Criar extensões de Date em BumbumNaNuca/Utilities/Extensions/Date+Extensions.swift (formatação de datas)

---

## Phase 2: Foundational (Blocking Prerequisites)

**Purpose**: Models SwiftData e enums que TODAS as user stories dependem

**⚠️ CRITICAL**: Nenhuma user story pode começar até esta fase estar completa

- [ ] T004 [P] Criar enum MuscleGroup em BumbumNaNuca/Models/MuscleGroup.swift com 7 categorias, rawValues português, e UI helpers (cores, ícones)
- [ ] T005 [P] Criar @Model Exercise em BumbumNaNuca/Models/Exercise.swift com atributos (id, name, muscleGroup, defaultSets, defaultReps, defaultRestTime, order) e relationships
- [ ] T006 Criar @Model WorkoutPlan em BumbumNaNuca/Models/WorkoutPlan.swift com atributos (id, name, description, createdDate, isActive) e relationship cascade para exercises
- [ ] T007 [P] Criar componentes reutilizáveis base: PrimaryButton em BumbumNaNuca/Views/Components/PrimaryButton.swift
- [ ] T008 [P] Criar EmptyStateView wrapper para ContentUnavailableView em BumbumNaNuca/Views/Components/EmptyStateView.swift

**Checkpoint**: Foundation ready - user story implementation can now begin in parallel

---

## Phase 3: User Story 1 - Criar Plano de Treino Manualmente (Priority: P1) 🎯 MVP

**Goal**: Permitir usuário criar novo plano do zero com nome, descrição e exercícios. Salvar persistentemente e mostrar na lista.

**Independent Test**: Criar plano "Treino A" com 3 exercícios (Supino/Peito, Agachamento/Pernas, Rosca/Braços), salvar, verificar que aparece na lista com "3 exercícios".

### Implementation for User Story 1

- [ ] T009 [P] [US1] Criar WorkoutPlanFormViewModel em BumbumNaNuca/ViewModels/WorkoutPlanFormViewModel.swift com validações (nome 3-100 chars, descrição max 500 chars)
- [ ] T010 [P] [US1] Criar ExerciseFormViewModel em BumbumNaNuca/ViewModels/ExerciseFormViewModel.swift com validações (séries 1-10, reps 1-50)
- [ ] T011 [US1] Implementar CreateWorkoutPlanView em BumbumNaNuca/Views/Workout/CreateWorkoutPlanView.swift com formulário (nome, descrição, lista exercícios, botões Salvar/Cancelar)
- [ ] T012 [US1] Implementar AddExerciseSheet em BumbumNaNuca/Views/Workout/AddExerciseSheet.swift com formulário (nome, muscleGroup picker, sets/reps steppers, restTime picker)
- [ ] T013 [US1] Integrar WorkoutPlanFormViewModel.save() para criar WorkoutPlan + Exercise entries no modelContext
- [ ] T014 [US1] Adicionar accessibility labels em botões e VoiceOver support em CreateWorkoutPlanView
- [ ] T015 [US1] Adicionar validação visual (erro inline) para campos obrigatórios em CreateWorkoutPlanView

**Checkpoint**: At this point, User Story 1 should be fully functional - user can create and save plans

---

## Phase 4: User Story 2 - Visualizar e Listar Planos Existentes (Priority: P1) 🎯 MVP

**Goal**: Mostrar todos os planos criados em lista ordenada por data, com número de exercícios, badge "Ativo", e última execução.

**Independent Test**: Após criar 3 planos diferentes, abrir aba Treinos e verificar que todos aparecem ordenados (mais recente primeiro) com informações corretas. Empty state se sem planos.

### Implementation for User Story 2

- [ ] T016 [P] [US2] Criar WorkoutPlanCard component em BumbumNaNuca/Views/Components/WorkoutPlanCard.swift mostrando nome, número exercícios, badge ativo, última execução
- [ ] T017 [P] [US2] Criar WorkoutPlanListViewModel em BumbumNaNuca/ViewModels/WorkoutPlanListViewModel.swift com @Query ordenado por createdDate reverse
- [ ] T018 [US2] Implementar WorkoutPlanListView em BumbumNaNuca/Views/Workout/WorkoutPlanListView.swift com List de plans usando WorkoutPlanCard
- [ ] T019 [US2] Adicionar empty state em WorkoutPlanListView usando ContentUnavailableView quando plans.isEmpty
- [ ] T020 [US2] Adicionar botão "+" no toolbar de WorkoutPlanListView que apresenta CreateWorkoutPlanView em sheet
- [ ] T021 [US2] Implementar NavigationLink em WorkoutPlanCard para navegar para detalhes (preparação para US3)
- [ ] T022 [US2] Adicionar Dynamic Type support e testar com text sizes Large e Extra Large

**Checkpoint**: At this point, User Stories 1 AND 2 should both work independently - create and see plans in list

---

## Phase 5: User Story 3 - Ver Detalhes do Plano com Lista de Exercícios (Priority: P1) 🎯 MVP

**Goal**: Visualizar todos os exercícios de um plano específico com grupos musculares em tags coloridas e séries×reps.

**Independent Test**: Criar plano com 4 exercícios variados, tocar no plano, verificar que todos exercícios aparecem com nome, grupo muscular tag colorida correta, e formato "4 × 10".

### Implementation for User Story 3

- [ ] T023 [P] [US3] Criar ExerciseRow component em BumbumNaNuca/Views/Components/ExerciseRow.swift mostrando nome, tag muscleGroup colorida, "sets × reps" (sem tempo de descanso conforme clarification)
- [ ] T024 [US3] Implementar WorkoutPlanDetailView em BumbumNaNuca/Views/Workout/WorkoutPlanDetailView.swift com header (nome do plano) e List de exercises ordenados por order
- [ ] T025 [US3] Adicionar botão "Iniciar Treino" destacado no topo de WorkoutPlanDetailView (placeholder - funcionalidade futura)
- [ ] T026 [US3] Adicionar toolbar em WorkoutPlanDetailView com botões "Editar" e "Marcar como Ativo/Inativo" (preparação para US4 e US5)
- [ ] T027 [US3] Aplicar cores do MuscleGroup.tagColor nas tags de grupo muscular em ExerciseRow
- [ ] T028 [US3] Adicionar VoiceOver labels descritivos em ExerciseRow e WorkoutPlanDetailView

**Checkpoint**: All P1 user stories MVP complete - create, list, and view plan details working independently

---

## Phase 6: User Story 4 - Editar Plano Existente (Priority: P2)

**Goal**: Modificar plano existente: mudar nome/descrição, adicionar/remover exercícios, reordenar exercícios. Salvar explícito com botão Salvar/Cancelar.

**Independent Test**: Criar plano, editá-lo mudando nome, adicionando 2 exercícios, removendo 1 existente, salvando. Verificar mudanças persistem. Testar Cancelar descarta mudanças.

### Implementation for User Story 4

- [ ] T029 [US4] Implementar EditWorkoutPlanView em BumbumNaNuca/Views/Workout/EditWorkoutPlanView.swift reutilizando WorkoutPlanFormViewModel com plano existente
- [ ] T030 [US4] Adicionar funcionalidade swipe-to-delete em lista de exercícios em EditWorkoutPlanView para remover exercícios
- [ ] T031 [US4] Implementar drag & drop reordering em lista de exercícios em EditWorkoutPlanView (atualizar Exercise.order)
- [ ] T032 [US4] Implementar botão "Adicionar Exercício" em EditWorkoutPlanView reutilizando AddExerciseSheet
- [ ] T033 [US4] Implementar lógica Salvar explícito em WorkoutPlanFormViewModel.save() que persiste mudanças apenas ao tocar botão Salvar
- [ ] T034 [US4] Implementar lógica Cancelar em WorkoutPlanFormViewModel que descarta mudanças (incluindo reordenação conforme clarification) e fecha view
- [ ] T035 [US4] Conectar botão "Editar" do toolbar em WorkoutPlanDetailView para apresentar EditWorkoutPlanView via NavigationLink

**Checkpoint**: User Story 4 complete - can edit existing plans with explicit save/cancel

---

## Phase 7: User Story 5 - Marcar Plano como Ativo (Priority: P2)

**Goal**: Marcar um plano específico como "Ativo" para destacá-lo. Apenas um plano pode ser ativo por vez.

**Independent Test**: Criar 3 planos, marcar "Treino B" como ativo, verificar apenas ele mostra badge "Ativo" na lista e aparece destacado na Home (futura).

### Implementation for User Story 5

- [ ] T036 [US5] Adicionar método toggleActive(plan:) em WorkoutPlanListViewModel que marca plano como ativo e desmarca outros
- [ ] T037 [US5] Conectar botão "Marcar como Ativo/Inativo" no toolbar de WorkoutPlanDetailView com toggleActive()
- [ ] T038 [US5] Atualizar WorkoutPlanCard para exibir badge "Ativo" condicionalmente quando plan.isActive == true
- [ ] T039 [US5] Garantir que apenas um plano tem isActive=true (lógica em WorkoutPlanListViewModel.toggleActive)
- [ ] T040 [US5] Adicionar feedback visual (animação) quando badge "Ativo" aparece/desaparece em WorkoutPlanCard

**Checkpoint**: User Story 5 complete - can mark one plan as active with visual feedback

---

## Phase 8: User Story 6 - Deletar Plano (Priority: P3)

**Goal**: Remover plano permanentemente da lista com confirmação. Preservar histórico de treinos executados (sessions) conforme clarification.

**Independent Test**: Criar plano teste, deletá-lo via swipe-to-delete, confirmar exclusão, verificar desaparece da lista permanentemente.

### Implementation for User Story 6

- [ ] T041 [US6] Adicionar swipe-to-delete action em WorkoutPlanListView usando .swipeActions modifier
- [ ] T042 [US6] Implementar método delete(plan:) em WorkoutPlanListViewModel que remove do modelContext
- [ ] T043 [US6] Adicionar confirmação alert antes de deletar plano com mensagem "Tem certeza? Esta ação não pode ser desfeita"
- [ ] T044 [US6] Garantir que deletar plano com isActive=true não marca automaticamente outro plano (conforme clarification - nenhum fica ativo)
- [ ] T045 [US6] Verificar cascade delete funciona corretamente (exercises deletados, sessions preservados conforme @Relationship deleteRule)
- [ ] T046 [US6] Adicionar accessibility announcement quando plano é deletado (VoiceOver feedback)

**Checkpoint**: All user stories should now be independently functional - full CRUD complete

---

## Phase 9: Polish & Cross-Cutting Concerns

**Purpose**: Melhorias que afetam múltiplas user stories e refinamentos finais

- [ ] T047 [P] Criar PreviewContainer helper em BumbumNaNuca/Utilities/Helpers/PreviewContainer.swift com dados seed para Xcode Previews
- [ ] T048 [P] Adicionar Xcode Previews (#Preview) em todos os componentes (WorkoutPlanCard, ExerciseRow, PrimaryButton, EmptyStateView)
- [ ] T049 [P] Adicionar Xcode Previews em todas as Views (WorkoutPlanListView, WorkoutPlanDetailView, CreateWorkoutPlanView, EditWorkoutPlanView)
- [ ] T050 Validar quickstart.md manual testing checklist completo (todos cenários happy path + error cases)
- [ ] T051 [P] Adicionar comments/documentation em ViewModels explicando validations e business logic
- [ ] T052 [P] Revisar acessibilidade: todos Image buttons têm .accessibilityLabel(), testar com VoiceOver no simulator
- [ ] T053 Otimizar performance: verificar lista com 50 planos carrega em <1 segundo, scroll a 60fps (usar Instruments se necessário)
- [ ] T054 [P] Adicionar tratamento de erro quando SwiftData save falha (ex: disco cheio) com alert amigável ao usuário
- [ ] T055 Final code review: verificar todos princípios da constitution (componentes reutilizáveis, accessible, organized by feature)

---

## Dependencies & Execution Order

### Phase Dependencies

- **Setup (Phase 1)**: No dependencies - can start immediately
- **Foundational (Phase 2)**: Depends on Setup (T002 ModelContainer) - BLOCKS all user stories
- **User Stories P1 (Phases 3-5)**: All depend on Foundational phase completion
  - US1 (Criar): Can start after Phase 2
  - US2 (Listar): Can start after Phase 2, integrates with US1 output
  - US3 (Detalhes): Can start after Phase 2, navigates from US2
- **User Stories P2 (Phases 6-7)**: Depend on Foundational, integrate with P1 stories
  - US4 (Editar): Navigates from US3, reuses US1 components
  - US5 (Ativo): Modifies US2 display, triggered from US3
- **User Stories P3 (Phase 8)**: Depend on Foundational, triggered from US2
  - US6 (Deletar): Removes from US2 list, follows clarifications
- **Polish (Phase 9)**: Depends on all desired user stories being complete

### User Story Dependencies

- **User Story 1 (P1 - Criar)**: Independent - Can start after Foundational ✅
- **User Story 2 (P1 - Listar)**: Independent - Can start after Foundational, displays US1 output ✅
- **User Story 3 (P1 - Detalhes)**: Independent - Can start after Foundational, accesses data from US1, navigates from US2 ✅
- **User Story 4 (P2 - Editar)**: Integrates with US1 (reuses forms) and US3 (launched from details) ⚠️
- **User Story 5 (P2 - Ativo)**: Integrates with US2 (updates card display) and US3 (toggle button) ⚠️
- **User Story 6 (P3 - Deletar)**: Integrates with US2 (swipe action in list) ⚠️

### Within Each User Story

**General Pattern**:
1. ViewModels before Views (business logic first)
2. Components before complex Views (building blocks first)
3. Core implementation before integration
4. Accessibility/polish after functionality works

**Specific Story Order**:
- **US1**: FormViewModel → AddExerciseSheet → CreateWorkoutPlanView → Integration/Validation
- **US2**: ListViewModel → WorkoutPlanCard → WorkoutPlanListView → Empty state → Toolbar
- **US3**: ExerciseRow → WorkoutPlanDetailView → Colors/Tags → Accessibility
- **US4**: EditView (reuse FormViewModel) → Swipe delete → Drag & drop → Save/Cancel logic
- **US5**: ViewModel method → Toolbar button → Badge display → Validation
- **US6**: Swipe action → Delete method → Confirmation → Cascade validation

### Parallel Opportunities

**Within Phases** (same phase, different files):
- Phase 1: T001 ✓, T003 [P] can run parallel
- Phase 2: T004 [P] MuscleGroup, T005 [P] Exercise, T007 [P] Button, T008 [P] EmptyState all parallel
- Phase 9: Most polish tasks marked [P] can run parallel

**Across User Stories** (if multiple developers):
- After Foundational complete:
  - Developer A: US1 (Criar) - T009-T015
  - Developer B: US2 (Listar) - T016-T022
  - Developer C: US3 (Detalhes) - T023-T028
  - Merge and test integration

**Within User Stories**:
- US1: T009 FormViewModel [P] + T010 ExerciseFormViewModel [P] parallel
- US2: T016 Card [P] + T017 ListViewModel [P] parallel
- US3: T023 ExerciseRow [P] parallel with T024 DetailView planning

---

## Parallel Example: User Story 1

```bash
# Launch ViewModels in parallel (different files):
T009: "Create WorkoutPlanFormViewModel.swift"
T010: "Create ExerciseFormViewModel.swift"

# Then Views can be built in parallel:
T011: "Implement CreateWorkoutPlanView.swift" (uses T009)
T012: "Implement AddExerciseSheet.swift" (uses T010)

# Final integration and polish sequential:
T013: "Integrate save() logic"
T014: "Add accessibility labels"
T015: "Add validation visual feedback"
```

---

## Parallel Example: Phase 2 Foundational

```bash
# All these can launch simultaneously (different model files):
T004: "Create MuscleGroup.swift enum"
T005: "Create Exercise.swift @Model"
T007: "Create PrimaryButton.swift component"
T008: "Create EmptyStateView.swift component"

# Then T006 depends on T004 and T005:
T006: "Create WorkoutPlan.swift @Model" (uses MuscleGroup from T004, relates to Exercise from T005)
```

---

## Implementation Strategy

### MVP First (P1 Stories Only)

1. ✅ Complete Phase 1: Setup (T001-T003)
2. ✅ Complete Phase 2: Foundational (T004-T008) - **CRITICAL GATE**
3. ✅ Complete Phase 3: User Story 1 - Criar (T009-T015)
4. ✅ Complete Phase 4: User Story 2 - Listar (T016-T022)
5. ✅ Complete Phase 5: User Story 3 - Detalhes (T023-T028)
6. **STOP and VALIDATE**: Test P1 stories independently using quickstart.md checklist
7. Deploy/demo if ready - **MVP COMPLETE** 🎯

**MVP Scope**: Apenas US1+US2+US3 = Criar, Listar, Ver planos ✅

### Incremental Delivery (Add P2 Stories)

1. Foundation + P1 Stories deployed ✅
2. Add Phase 6: User Story 4 - Editar (T029-T035) → Test → Deploy
3. Add Phase 7: User Story 5 - Ativo (T036-T040) → Test → Deploy
4. Each P2 story adds value without breaking P1 functionality

### Full Feature (Add P3 Stories)

1. Foundation + P1 + P2 deployed ✅
2. Add Phase 8: User Story 6 - Deletar (T041-T046) → Test → Deploy
3. Add Phase 9: Polish (T047-T055) → Final validation → Deploy
4. **FEATURE COMPLETE** 🎉

### Parallel Team Strategy

With 3 developers available (after Phase 2 complete):

**Week 1** - P1 Stories (MVP):
- Developer A: US1 Criar (T009-T015) - 3 days
- Developer B: US2 Listar (T016-T022) - 3 days
- Developer C: US3 Detalhes (T023-T028) - 3 days
- Integration & Testing: 2 days
- **Total: 5 days to MVP** ⚡

**Week 2** - P2 Stories:
- Developer A: US4 Editar (T029-T035)
- Developer B: US5 Ativo (T036-T040)
- Developer C: Start Polish (T047-T049 Previews)

**Week 3** - P3 + Polish:
- Developer A: US6 Deletar (T041-T046)
- Developer B+C: Complete Polish (T050-T055)
- Final testing and refinement

**Total Project: ~3 weeks with parallel team** 🚀

### Sequential Strategy (Solo Developer)

**Week 1**: Setup + Foundational + US1 (T001-T015)
**Week 2**: US2 + US3 - MVP complete (T016-T028)
**Week 3**: US4 + US5 (T029-T040)
**Week 4**: US6 + Polish (T041-T055)

**Total Project: ~4 weeks solo** 🐢

---

## Notes

- **Tests**: Not included as tasks per specification. Test strategy documented in data-model.md (ViewModels >90%, Models >80%, UI tests for P1)
- **[P] tasks**: Different files, can run in parallel with proper coordination
- **[Story] labels**: Map tasks to user stories for independent delivery
- **MVP = P1 only**: US1+US2+US3 delivers core value (create, list, view plans)
- **Incremental**: Each story adds value without breaking previous ones
- **Clarifications integrated**: Salvar explícito (US4), plano vazio válido (US1), sem auto-ativo ao deletar (US6), sem tempo descanso em lista (US3)
- **Constitution compliance**: All tasks follow mobile-first SwiftUI, clean architecture, zero dependencies principles
- **Accessibility**: Built-in from start (T014, T022, T028, T046, T052)
- **Performance**: Validated in polish phase (T053)

---

## Task Count Summary

- **Total Tasks**: 55
- **Phase 1 (Setup)**: 3 tasks
- **Phase 2 (Foundational)**: 5 tasks - CRITICAL GATE
- **Phase 3 (US1 - Criar P1)**: 7 tasks 🎯
- **Phase 4 (US2 - Listar P1)**: 7 tasks 🎯
- **Phase 5 (US3 - Detalhes P1)**: 6 tasks 🎯
- **Phase 6 (US4 - Editar P2)**: 7 tasks
- **Phase 7 (US5 - Ativo P2)**: 5 tasks
- **Phase 8 (US6 - Deletar P3)**: 6 tasks
- **Phase 9 (Polish)**: 9 tasks

**MVP Scope (P1)**: 28 tasks (Setup + Foundational + US1 + US2 + US3)
**Full Feature**: 55 tasks

---

**Status**: ✅ Tasks ready for implementation  
**Next Step**: Start with Phase 1 (T001-T003), then Phase 2 (T004-T008 CRITICAL), then pick MVP-first or parallel strategy
