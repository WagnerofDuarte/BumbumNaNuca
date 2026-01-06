# Research: Gerenciamento de Planos de Treino

**Phase**: 0 - Outline & Research  
**Date**: 6 de Janeiro de 2026  
**Feature**: [spec.md](spec.md)

## Purpose

Resolver decisões técnicas críticas identificadas durante preenchimento do Technical Context e estabelecer patterns de implementação para a feature de gerenciamento de planos de treino.

## Research Tasks & Findings

### 1. SwiftData Relationships & Cascade Delete

**Question**: Como configurar relacionamentos entre WorkoutPlan → Exercise e garantir cascade delete quando plano é deletado?

**Decision**: Usar `@Relationship(deleteRule: .cascade)` no array de exercises

**Rationale**: 
- SwiftData oferece `deleteRule` nativo que replica comportamento Core Data
- `.cascade` garante que ao deletar WorkoutPlan, todos exercises associados são deletados automaticamente
- Evita exercícios órfãos no banco de dados
- Mais simples que implementar cleanup manual

**Alternatives Considered**:
- Manual cleanup em `modelContext.delete()`: Requer código extra, propenso a bugs
- `.nullify`: Deixaria exercícios órfãos (inaceitável para nosso caso de uso)
- `.deny`: Impediria deletar plano com exercícios (UX ruim)

**Implementation**:
```swift
@Model
class WorkoutPlan {
    @Relationship(deleteRule: .cascade)
    var exercises: [Exercise] = []
}
```

---

### 2. Validação de Formulários em SwiftUI

**Question**: Onde implementar validações de formulário (nome mínimo 3 chars, séries 1-10, etc.)?

**Decision**: ViewModel dedicado (`WorkoutPlanFormViewModel`) com validação síncrona

**Rationale**:
- Separa lógica de validação da View (princípio I - componentes leves)
- Facilita unit testing de regras de negócio (princípio II - test-first)
- Permite feedback imediato ao usuário (melhor UX)
- ViewModel pode ser `@Observable` (Swift 5.9+) para reatividade nativa

**Alternatives Considered**:
- Validação inline na View: Polui código SwiftUI, dificulta testes
- Validação apenas no Model: Tarde demais (dados já no banco), ruim para UX
- Library third-party (ValidatedPropertyKit): Viola princípio de zero dependências

**Implementation**:
```swift
@Observable
class WorkoutPlanFormViewModel {
    var name: String = ""
    var nameError: String?
    
    func validateName() -> Bool {
        guard !name.trimmingCharacters(in: .whitespaces).isEmpty else {
            nameError = "Nome é obrigatório"
            return false
        }
        guard name.count >= 3 else {
            nameError = "Nome deve ter no mínimo 3 caracteres"
            return false
        }
        nameError = nil
        return true
    }
}
```

---

### 3. SwiftUI List Performance com Muitos Exercícios

**Question**: Como garantir 60fps em lista de exercícios quando plano tem 50 exercícios?

**Decision**: Usar `List` nativo SwiftUI com `id: \.id` para identificação única

**Rationale**:
- SwiftUI List já faz lazy loading e cell reuse automaticamente
- Performance é excelente até ~100 items sem otimização adicional
- Identificador único (`id: \.id` com UUID) evita bugs de rendering
- Não precisa de otimização prematura para 50 items

**Alternatives Considered**:
- `LazyVStack` em ScrollView: Mais verboso, sem benefício para nosso caso
- Custom cell prefetching: Premature optimization
- Virtualization manual: Complexidade desnecessária para escala do MVP

**Performance Target**: Lista com 50 exercícios deve carregar em <100ms e scroll a 60fps

---

### 4. Padrão de Navegação para Criar/Editar

**Question**: Usar sheet modal ou NavigationLink push para criar/editar planos?

**Decision**: NavigationLink push para editar, sheet modal para criar

**Rationale**:
- **Editar (push)**: Contexto já existe (usuário clicou no plano), hierarquia clara
- **Criar (sheet)**: Ação de criação é modal conceptualmente (commit ou cancel)
- Alinhado com HIG (Human Interface Guidelines) da Apple
- Sheet para criar permite apresentação sem perder contexto da lista

**Alternatives Considered**:
- Ambos sheet: Editar em sheet perde contexto de navegação
- Ambos push: Criar como push é menos óbvio que é nova entidade
- Fullscreen cover: Pesado demais para formulário simples

**Implementation**:
```swift
// Lista
.sheet(isPresented: $showingCreate) {
    CreateWorkoutPlanView()
}

// Detalhes
NavigationLink("Editar") {
    EditWorkoutPlanView(plan: plan)
}
```

---

### 5. Estratégia de Testes

**Question**: Quais testes priorizar para cobertura P1 com orçamento limitado de tempo?

**Decision**: 
1. **Unit tests** (alta prioridade): ViewModels (validações, lógica de save/cancel)
2. **Integration tests** (média prioridade): SwiftData CRUD operations
3. **UI tests** (P1 apenas): Criar plano → Adicionar exercício → Salvar → Ver na lista

**Rationale**:
- ViewModels concentram lógica de negócio → maior ROI de testes
- SwiftData é framework Apple (menos bugs), mas relacionamentos custom precisam validação
- UI tests E2E custam caro (tempo execução), focar em happy path P1
- Constitution exige testes antes de merge (princípio II)

**Coverage Targets**:
- ViewModels: 90%+ code coverage
- Models (SwiftData): Teste de relacionamentos e validações
- UI: 3-4 fluxos críticos (criar, editar, deletar, marcar ativo)

**Test Tools**:
- XCTest para unit e integration
- XCTest UI para testes E2E
- Xcode Test Plans para organizar suites

---

### 6. Acessibilidade e Localização

**Question**: Como garantir VoiceOver e Dynamic Type desde início (princípio I)?

**Decision**: 
- Todos textos usando `Text()` SwiftUI (Dynamic Type automático)
- Labels explícitos via `.accessibilityLabel()` em botões icon-only
- Testar com VoiceOver e Accessibility Inspector desde PR inicial

**Rationale**:
- SwiftUI tem Dynamic Type habilitado por default se usar `Text()`
- VoiceOver precisa labels descritivos (não apenas ícones)
- Constitution exige accessibility (princípio I)
- Custo baixo se feito desde início, caro se deixar para depois

**Implementation Checklist**:
- [ ] Todos `Image` buttons têm `.accessibilityLabel()`
- [ ] Testar com Text Size: Large e Extra Large
- [ ] Run VoiceOver em simulator antes de merge

---

### 7. Estado Vazio (Empty State)

**Question**: Como implementar empty state quando não há planos criados?

**Decision**: Usar `ContentUnavailableView` (iOS 17+)

**Rationale**:
- Component nativo iOS 17+ com design system Apple
- Zero código custom para layout
- Suporta título, descrição, ícone SF Symbol e action button
- Acessível por default

**Alternatives Considered**:
- Custom VStack com Text e Button: Mais trabalho, inconsistente com iOS
- Third-party component: Viola zero dependencies

**Implementation**:
```swift
if plans.isEmpty {
    ContentUnavailableView(
        "Nenhum plano criado",
        systemImage: "dumbbell",
        description: Text("Crie seu primeiro plano de treino")
    )
}
```

---

## Technology Stack Summary

| Component | Technology | Version | Justification |
|-----------|-----------|---------|---------------|
| **Language** | Swift | 5.9+ | Requisito iOS, `@Observable` macro disponível |
| **UI Framework** | SwiftUI | iOS 17+ | Declarativo, reutilizável, acessível por default |
| **Data Persistence** | SwiftData | iOS 17+ | ORM nativo, type-safe, relationships sem boilerplate |
| **Reactive** | Observation (Swift 5.9) | Built-in | Substitui Combine para ViewModels, menos complexo |
| **Testing** | XCTest | Built-in | Framework nativo, integração perfeita com Xcode |
| **Navigation** | NavigationStack | SwiftUI | Padrão iOS 16+, type-safe routing |

**External Dependencies**: ✅ **ZERO** - 100% frameworks nativos Apple

---

## Risks & Mitigations

| Risk | Probability | Impact | Mitigation |
|------|-------------|--------|------------|
| SwiftData bugs em relacionamentos complexos | Médio | Alto | Testes integration cobrindo cascade delete e referential integrity |
| Performance ruim com 50+ planos | Baixo | Médio | List nativo SwiftUI otimiza automaticamente, profiling se necessário |
| Complexidade de validação crescer | Médio | Baixo | ViewModel pattern permite refactoring para Validator classes se crescer |
| Testes UI lentos e flaky | Alto | Médio | Priorizar unit tests, UI tests apenas para P1, usar test plans |

---

## Open Questions

- ❓ **RESOLVED**: Todas as questões técnicas foram resolvidas durante research
- ✅ SwiftData relationships: `.cascade` deleteRule
- ✅ Validações: ViewModel síncrono com feedback imediato
- ✅ Performance: List nativo suficiente para escala MVP
- ✅ Navegação: Push para editar, sheet para criar
- ✅ Testes: Priorizar ViewModels e integration
- ✅ Accessibility: VoiceOver labels + Dynamic Type padrão
- ✅ Empty state: `ContentUnavailableView` nativo

---

## Next Steps

Prosseguir para **Phase 1: Design** para criar:
1. `data-model.md` - Schema detalhado SwiftData
2. `quickstart.md` - Como rodar e testar feature
3. Atualizar agent context file

Nenhuma clarificação adicional necessária - todas decisões técnicas foram tomadas.
