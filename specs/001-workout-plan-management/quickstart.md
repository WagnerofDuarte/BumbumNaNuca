# Quickstart: Gerenciamento de Planos de Treino

**Phase**: 1 - Design  
**Date**: 6 de Janeiro de 2026  
**Feature**: [spec.md](spec.md) | [data-model.md](data-model.md)

## Purpose

Guia rápido para desenvolvedores trabalhando nesta feature: como rodar, testar e demonstrar a funcionalidade de gerenciamento de planos de treino.

---

## Prerequisites

- **Xcode**: 15.0+ (iOS 17 SDK)
- **macOS**: Sonoma 14.0+ (para rodar Xcode 15)
- **Device/Simulator**: iPhone rodando iOS 17.0+
- **Git**: Para trabalhar na branch `001-workout-plan-management`

---

## Setup

### 1. Clone e Branch
```bash
# Se ainda não clonou
git clone <repo-url>
cd BumbumNaNuca

# Checkout da feature branch
git checkout 001-workout-plan-management
```

### 2. Abrir Projeto
```bash
# Abrir no Xcode
open BumbumNaNuca.xcodeproj
```

### 3. Configurar Simulator
1. Xcode → Product → Destination → Choose **iPhone 15 Pro** (ou similar iOS 17+)
2. Verificar que Deployment Target = iOS 17.0 em projeto settings

---

## Building

### Primeira Build
```bash
# Via Xcode
⌘ + B (Command + B)

# Ou via terminal
xcodebuild \
  -project BumbumNaNuca.xcodeproj \
  -scheme BumbumNaNuca \
  -destination 'platform=iOS Simulator,name=iPhone 15 Pro' \
  build
```

**Tempo esperado**: 15-30 segundos (primeira build)

---

## Running

### Rodar App
```bash
# Via Xcode
⌘ + R (Command + R)

# App abrirá no simulator
```

### Navegar para Feature
1. App abre na tab **Home**
2. Tocar na tab **Treinos** (ícone dumbbell)
3. Ver lista de planos (empty state se primeira vez)

---

## Testing

### Unit Tests

**Rodar todos os testes**:
```bash
# Via Xcode
⌘ + U (Command + U)

# Ou via terminal
xcodebuild test \
  -project BumbumNaNuca.xcodeproj \
  -scheme BumbumNaNuca \
  -destination 'platform=iOS Simulator,name=iPhone 15 Pro'
```

**Rodar testes específicos**:
```bash
# Apenas ViewModels
xcodebuild test -only-testing:BumbumNaNucaTests/WorkoutPlanFormViewModelTests

# Apenas Models
xcodebuild test -only-testing:BumbumNaNucaTests/WorkoutPlanTests
```

**Coverage esperada**:
- ViewModels: >90%
- Models: >80%
- Overall feature: >85%

### UI Tests

```bash
# Rodar UI tests (mais lento)
xcodebuild test \
  -project BumbumNaNuca.xcodeproj \
  -scheme BumbumNaNuca \
  -destination 'platform=iOS Simulator,name=iPhone 15 Pro' \
  -only-testing:BumbumNaNucaUITests/WorkoutPlanFlowTests
```

**Tempo esperado**: ~2-3 minutos para suite completa

### Test em Device Real

1. Xcode → Destination → Seu iPhone
2. Conectar iPhone via USB
3. Confiar no computador se primeira vez
4. ⌘ + R para rodar

---

## Manual Testing Checklist

### Happy Path (P1)

**Criar Plano**:
- [ ] 1. Abrir tab Treinos
- [ ] 2. Tocar botão "+"
- [ ] 3. Preencher nome "Treino A"
- [ ] 4. Tocar "Adicionar Exercício"
- [ ] 5. Preencher: nome "Supino", grupo "Peito", 4 séries, 10 reps
- [ ] 6. Salvar exercício
- [ ] 7. Salvar plano
- [ ] 8. **Verificar**: Plano aparece na lista com "1 exercício"

**Visualizar Plano**:
- [ ] 1. Tocar no plano criado
- [ ] 2. **Verificar**: Mostra nome do plano
- [ ] 3. **Verificar**: Exercício "Supino" aparece com tag azul "Peito" e "4 × 10"

**Editar Plano**:
- [ ] 1. Na tela de detalhes, tocar "Editar"
- [ ] 2. Adicionar exercício "Agachamento" (Pernas, 3×12)
- [ ] 3. Tocar "Salvar"
- [ ] 4. **Verificar**: Plano agora mostra "2 exercícios"

**Marcar como Ativo**:
- [ ] 1. Na lista, criar segundo plano "Treino B"
- [ ] 2. Tocar em "Treino A" → Detalhes
- [ ] 3. Tocar "Marcar como Ativo"
- [ ] 4. Voltar para lista
- [ ] 5. **Verificar**: Apenas "Treino A" tem badge "Ativo"

**Deletar Plano**:
- [ ] 1. Na lista, swipe left em "Treino B"
- [ ] 2. Tocar "Delete"
- [ ] 3. Confirmar no alert
- [ ] 4. **Verificar**: "Treino B" desaparece da lista

### Error Cases

**Validação de Nome**:
- [ ] 1. Criar plano sem preencher nome
- [ ] 2. Tocar "Salvar"
- [ ] 3. **Verificar**: Erro "Nome é obrigatório"

**Validação de Séries**:
- [ ] 1. Adicionar exercício com 15 séries
- [ ] 2. **Verificar**: Erro "Séries devem estar entre 1 e 10"

**Plano Vazio**:
- [ ] 1. Criar plano "Teste" sem exercícios
- [ ] 2. Salvar
- [ ] 3. **Verificar**: Plano salvo com "0 exercícios" (válido conforme clarification)

---

## Demo Script (para apresentação)

### Scenario: Criando Primeiro Plano de Treino

```
DEMONSTRAÇÃO (2 minutos):

1. "Vou criar meu plano de treino de peito e tríceps"
   → Abrir app, tab Treinos
   
2. "Ainda não tenho planos, vou criar o primeiro"
   → Tocar "+" (mostrar empty state primeiro)
   
3. "Vou chamar de 'Treino A - Peito e Tríceps'"
   → Preencher nome
   
4. "Adicionar Supino Reto como primeiro exercício"
   → Tocar "Adicionar Exercício"
   → Nome: "Supino Reto"
   → Grupo: "Peito"
   → 4 séries × 10 repetições
   → Descanso 90 segundos
   → Salvar
   
5. "Adicionar mais dois exercícios rapidamente"
   → Crossover (Peito, 3×12, 60s)
   → Tríceps Testa (Braços, 3×15, 60s)
   
6. "Salvar o plano completo"
   → Tocar "Salvar"
   
7. "Agora posso ver meu plano na lista com 3 exercícios"
   → Mostrar card na lista
   
8. "E visualizar os detalhes de cada exercício"
   → Tocar no plano
   → Scroll pela lista de exercícios
   → Apontar tags coloridas de grupo muscular

RESULTADO: Plano criado, salvo e visível ✅
```

---

## Debugging

### SwiftData Inspector

```swift
// Em qualquer View com @Environment(\.modelContext)
Button("Debug: Print Plans") {
    let descriptor = FetchDescriptor<WorkoutPlan>()
    let plans = try? modelContext.fetch(descriptor)
    print("📊 Total plans: \(plans?.count ?? 0)")
    plans?.forEach { plan in
        print("  - \(plan.name): \(plan.exercises.count) exercises")
    }
}
```

### Resetar Dados (Limpar SwiftData)

**Opção 1 - Via Simulator**:
```bash
# Deletar app do simulator
# Dados SwiftData serão apagados

# Ou resetar simulator completamente
xcrun simctl erase all
```

**Opção 2 - Via Debug Button** (em desenvolvimento):
```swift
// Adicionar botão temporário em SettingsView
Button("⚠️ Reset All Data") {
    let plans = try? modelContext.fetch(FetchDescriptor<WorkoutPlan>())
    plans?.forEach { modelContext.delete($0) }
}
```

### Common Issues

**Issue**: "App crashes ao abrir lista de treinos"
- **Causa**: ModelContainer não inicializado
- **Fix**: Verificar `BumbumNaNucaApp.swift` tem `.modelContainer(sharedModelContainer)`

**Issue**: "Exercícios não aparecem ao abrir plano"
- **Causa**: Relationship não carregado
- **Fix**: Usar `plan.exercises.sorted { $0.order < $1.order }` diretamente na View

**Issue**: "Testes falham com 'No such table: WorkoutPlan'"
- **Causa**: In-memory container não configurado em test
- **Fix**: Criar ModelContainer in-memory no `setUp()` do test

---

## Performance Profiling

### Instruments

```bash
# Abrir Instruments para profiling
⌘ + I (Command + I)

# Escolher template:
- Time Profiler: Para encontrar código lento
- Allocations: Para leak de memória
```

**Targets de Performance**:
- Lista de 50 planos: <100ms para carregar
- Scroll 60fps: Sem drops
- Criar plano: <500ms para salvar

### SwiftUI Preview Performance

```bash
# Em cada View.swift
#Preview {
    WorkoutPlanListView()
        .modelContainer(PreviewContainer.shared)
}

// PreviewContainer com dados de exemplo
class PreviewContainer {
    static let shared: ModelContainer = {
        let schema = Schema([WorkoutPlan.self, Exercise.self])
        let config = ModelConfiguration(isStoredInMemoryOnly: true)
        let container = try! ModelContainer(for: schema, configurations: [config])
        
        // Seed data
        let plan = WorkoutPlan(name: "Preview Plan")
        container.mainContext.insert(plan)
        
        return container
    }()
}
```

---

## Accessibility Testing

### VoiceOver

1. Simulator → Features → Accessibility Inspector
2. Ou iPhone físico → Settings → Accessibility → VoiceOver → ON
3. **Verificar**:
   - [ ] Botão "+" lê "Criar novo plano"
   - [ ] Cards de plano leem nome + número de exercícios
   - [ ] Botão delete lê "Deletar plano [nome]"

### Dynamic Type

```swift
// Testar em Simulator
Settings → Accessibility → Display & Text Size → Larger Text
Arrastar slider para "Accessibility Extra Large"

// Voltar ao app e verificar textos expandem sem quebrar layout
```

---

## CI/CD Integration (Future)

```yaml
# .github/workflows/tests.yml (exemplo)
name: Tests

on: [pull_request]

jobs:
  test:
    runs-on: macos-14
    steps:
      - uses: actions/checkout@v4
      
      - name: Select Xcode
        run: sudo xcode-select -s /Applications/Xcode_15.0.app
      
      - name: Run tests
        run: |
          xcodebuild test \
            -project BumbumNaNuca.xcodeproj \
            -scheme BumbumNaNuca \
            -destination 'platform=iOS Simulator,name=iPhone 15 Pro' \
            -resultBundlePath TestResults
      
      - name: Upload coverage
        uses: codecov/codecov-action@v3
```

---

## Useful Commands

```bash
# Limpar build folder
rm -rf ~/Library/Developer/Xcode/DerivedData

# Listar devices disponíveis
xcrun simctl list devices

# Boot simulator específico
xcrun simctl boot "iPhone 15 Pro"

# Screenshot do simulator
xcrun simctl io booted screenshot ~/Desktop/screenshot.png

# Gravar vídeo
xcrun simctl io booted recordVideo ~/Desktop/demo.mp4
# (Ctrl+C para parar gravação)
```

---

## Next Steps

Após rodar e testar manualmente:

1. ✅ Verificar todos os items do Manual Testing Checklist
2. ✅ Rodar suite de testes automatizados (⌘+U)
3. ✅ Testar com VoiceOver e Dynamic Type
4. ✅ Fazer demo script completo sem erros
5. → Prosseguir para `/speckit.tasks` para task breakdown

**Status**: ✅ Feature pronta para implementação detalhada
