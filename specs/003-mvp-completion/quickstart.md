# Quickstart: MVP Completion (Feature 003)

**Feature**: Home Dashboard + Check-in System + Progress Tracking  
**Date**: 08/01/2026  
**Branch**: `003-mvp-completion`

---

## Setup Instructions

### Prerequisites
- Xcode 15.0+ installed
- iOS 17.0+ Simulator or device
- Features 001 and 002 already implemented
- Git repository cloned locally

### Initial Setup

**Step 1**: Checkout feature branch
```bash
cd /Users/wagnerduarte/Documents/Apps/BumbumNaNuca
git checkout 003-mvp-completion
```

**Step 2**: Open project in Xcode
```bash
open BumbumNaNuca.xcodeproj
```

**Step 3**: Build project (⌘B)
- Verify zero errors
- Check SwiftData schema includes CheckIn model

**Step 4**: Run on Simulator (⌘R)
- Select iPhone 15 Pro (iOS 17+)
- Wait for app to launch
- App should open directly in TabView with 4 tabs

---

## Feature Overview

### What's New
- ✅ **TabView Navigation**: 4 tabs (Home, Treinos, Progresso, Check-in)
- ✅ **Home Dashboard**: Cards com plano ativo, último treino, check-in status
- ✅ **Check-in System**: Registro diário com sequências e stats mensais
- ✅ **Progress Tracking**: Histórico de treinos e exercícios com recordes

### File Structure
```
BumbumNaNuca/
├── ContentView.swift (MODIFIED - agora tem TabView)
├── Models/
│   └── CheckIn.swift (NEW)
├── Views/
│   ├── Home/
│   │   └── HomeView.swift (NEW)
│   ├── CheckIn/
│   │   └── CheckInView.swift (NEW)
│   └── Progress/
│       ├── ProgressView.swift (NEW)
│       ├── WorkoutHistoryListView.swift (NEW)
│       ├── SessionDetailView.swift (NEW)
│       ├── ExerciseHistoryListView.swift (NEW)
│       └── ExerciseHistoryView.swift (NEW)
├── ViewModels/
│   ├── HomeViewModel.swift (NEW)
│   ├── CheckInViewModel.swift (NEW)
│   └── ProgressViewModel.swift (NEW)
└── Utilities/Extensions/
    ├── Date+Extensions.swift (EXTENDED - 2 new methods)
    └── Calendar+Extensions.swift (NEW - streak helpers)
```

---

## Manual Testing Checklist

### 🏠 Home Tab

#### TC-H1: Initial State (First Launch)
**Steps**:
1. Launch app fresh (reset simulator if needed)
2. Observe Home tab

**Expected**:
- [ ] Saudação "Olá, Atleta!" aparece
- [ ] Data atual formatada: "Quarta, 8 de Janeiro de 2026"
- [ ] Card "Nenhum plano ativo" com sugestão para criar plano
- [ ] Card de check-in mostra botão "Fazer Check-in"
- [ ] Card de último treino **oculto** (sem treinos ainda)
- [ ] Badge de sequência mostra "🔥 0 dias"

#### TC-H2: Com Plano Ativo
**Pre-condition**: Ter criado e ativado 1 plano (via tab Treinos)

**Steps**:
1. Criar plano "Treino A" via tab Treinos
2. Ativar plano
3. Voltar para Home tab

**Expected**:
- [ ] Card "Plano Ativo" aparece
- [ ] Nome do plano exibido: "Treino A"
- [ ] Botão "Iniciar Treino" em destaque
- [ ] Tocar botão navega para ExecuteWorkoutView (tab Treinos)

#### TC-H3: Check-in Quick Action
**Steps**:
1. Na Home, tocar botão "Fazer Check-in" no card
2. Observar mudança de estado

**Expected**:
- [ ] Check-in é criado
- [ ] Card atualiza para "Check-in realizado ✓"
- [ ] Horário do check-in aparece (ex: "18:30")
- [ ] Botão fica desabilitado
- [ ] Badge de sequência atualiza: "🔥 1 dia"

#### TC-H4: Com Último Treino
**Pre-condition**: Ter completado pelo menos 1 treino (Feature 002)

**Steps**:
1. Executar treino completo via tab Treinos
2. Voltar para Home

**Expected**:
- [ ] Card "Último Treino" aparece
- [ ] Nome do plano exibido
- [ ] Tempo relativo: "Há X minutos" ou "Hoje"
- [ ] Duração formatada: "1h 15min"

#### TC-H5: Performance
**Pre-condition**: Ter 50+ treinos no histórico

**Steps**:
1. Abrir Home tab
2. Cronometrar tempo de carregamento

**Expected**:
- [ ] Dashboard carrega em **< 1 segundo**
- [ ] UI responsiva (60fps)
- [ ] Sem travamentos

---

### ✅ Check-in Tab

#### TC-C1: First Check-in
**Steps**:
1. Abrir tab Check-in (primeira vez)
2. Observar estado inicial
3. Tocar botão "Fazer Check-in"

**Expected**:
- [ ] Card principal mostra botão "Fazer Check-in"
- [ ] Sequência atual: "0 dias"
- [ ] Melhor sequência: "0 dias"
- [ ] Stats mensais: "0/31 (0%)"
- [ ] Lista de check-ins vazia (empty state)
- Após tocar botão:
- [ ] Botão muda para "Check-in feito às [horário]"
- [ ] Botão fica desabilitado
- [ ] Sequência atual: "🔥 1 dia"
- [ ] Melhor sequência: "⭐ 1 dia"
- [ ] Stats mensais: "1/31 (3%)"
- [ ] Check-in aparece na lista: "Hoje, [horário]"

#### TC-C2: Cannot Check-in Twice Same Day
**Pre-condition**: Já fez check-in hoje

**Steps**:
1. Tentar tocar botão de check-in novamente

**Expected**:
- [ ] Botão permanece desabilitado
- [ ] Mensagem "Check-in feito às [horário]" persiste
- [ ] Nenhum novo check-in criado

#### TC-C3: Consecutive Days Streak
**Steps**:
1. Fazer check-in dia 1 (simulador: mudar data)
2. Fazer check-in dia 2
3. Fazer check-in dia 3

**Expected**:
- Dia 1: sequência = 1
- Dia 2: sequência = 2
- Dia 3: sequência = 3
- [ ] Sequência incrementa corretamente
- [ ] Melhor sequência acompanha (sempre >= atual)

#### TC-C4: Streak Reset (Skip Day)
**Steps**:
1. Ter sequência de 5 dias
2. Pular 1 dia (não fazer check-in)
3. Fazer check-in no dia seguinte

**Expected**:
- [ ] Sequência atual reseta para 1
- [ ] Melhor sequência permanece 5
- [ ] Stats mensais contam dias corretos

#### TC-C5: Monthly Stats Accuracy
**Pre-condition**: Estar em Janeiro (31 dias)

**Steps**:
1. Fazer 18 check-ins ao longo do mês
2. Observar stats

**Expected**:
- [ ] Total: "18/31"
- [ ] Percentual: "(58%)" ou similar
- [ ] Cálculo correto para meses com 28/30/31 dias

#### TC-C6: Recent Check-ins List
**Pre-condition**: Ter 30+ check-ins

**Steps**:
1. Scroll lista de check-ins

**Expected**:
- [ ] Últimos 30 check-ins exibidos
- [ ] Ordenados do mais recente para mais antigo
- [ ] Data relativa: "Hoje", "Ontem", "Há 2 dias", etc.
- [ ] Performance: scroll suave (60fps)

---

### 📊 Progress Tab - Treinos

#### TC-P1: Empty State (No Workouts)
**Pre-condition**: Sem treinos completados

**Steps**:
1. Abrir tab Progresso
2. Verificar aba "Treinos" (selecionada por padrão)

**Expected**:
- [ ] Empty state aparece
- [ ] Mensagem: "Nenhum treino realizado"
- [ ] Sugestão: "Inicie seu primeiro treino"
- [ ] Ícone ilustrativo

#### TC-P2: Workout History List
**Pre-condition**: Ter 3-5 treinos completados

**Steps**:
1. Abrir aba "Treinos"
2. Observar lista

**Expected**:
- [ ] Todos treinos completados aparecem
- [ ] Ordenados por data (mais recente primeiro)
- Cada item mostra:
  - [ ] Nome do plano
  - [ ] Data/hora início
  - [ ] Duração: "1h 15min"
  - [ ] Tempo relativo: "Há 2 dias"
  - [ ] Ícone de completude ✓

#### TC-P3: Session Detail Navigation
**Steps**:
1. Tocar em um treino na lista
2. Observar detalhes

**Expected**:
- [ ] Navega para SessionDetailView
- [ ] Header com nome do plano e data
- [ ] Lista de exercícios executados
- Cada exercício mostra:
  - [ ] Nome do exercício
  - [ ] Grupo muscular (badge colorido)
  - [ ] Todas as séries: "80kg × 10", "85kg × 8", etc.
  - [ ] Ordenado conforme execução

#### TC-P4: Performance - Large History
**Pre-condition**: Ter 50+ treinos

**Steps**:
1. Abrir aba "Treinos"
2. Cronometrar carregamento
3. Scroll pela lista

**Expected**:
- [ ] Carregamento inicial **< 1 segundo**
- [ ] Lista mostra primeiros 50 treinos (limit)
- [ ] Scroll suave (LazyVStack lazy loading)
- [ ] Memória **< 50MB**

---

### 📊 Progress Tab - Exercícios

#### TC-P5: Empty State (No Exercises)
**Pre-condition**: Nunca executou exercícios

**Steps**:
1. Abrir tab Progresso
2. Selecionar aba "Exercícios"

**Expected**:
- [ ] Empty state aparece
- [ ] Mensagem: "Nenhum exercício realizado ainda"

#### TC-P6: Exercise Stats List
**Pre-condition**: Ter executado "Supino Reto" em 5 sessões diferentes

**Steps**:
1. Abrir aba "Exercícios"
2. Procurar "Supino Reto" na lista

**Expected**:
- [ ] Exercício aparece na lista
- [ ] Última execução: data/hora relativa
- [ ] Total de vezes: "5 vezes"
- [ ] Badge com grupo muscular

#### TC-P7: Exercise History Detail
**Steps**:
1. Tocar em "Supino Reto"
2. Observar ExerciseHistoryView

**Expected**:
- [ ] Header com nome do exercício
- [ ] Estatísticas:
  - [ ] Recorde pessoal: "100kg × 8"
  - [ ] Última execução: "Há 2 dias"
  - [ ] Total de séries: "15 séries"
- [ ] Lista de todas as séries já executadas
- Cada série mostra:
  - [ ] Data
  - [ ] Peso × Reps: "80kg × 10"
  - [ ] Nome do treino associado

#### TC-P8: Personal Record Accuracy
**Pre-condition**: Executou Supino com: 80kg×10, 90kg×8, 100kg×6, 95kg×8

**Steps**:
1. Verificar recorde pessoal de "Supino Reto"

**Expected**:
- [ ] Recorde = "100kg × 6" (maior peso)
- [ ] Se empate de peso, maior reps (ex: 90kg×8 > 90kg×6)
- [ ] Cálculo correto em 100% dos casos

---

### 🧭 Navigation

#### TC-N1: Tab Switching
**Steps**:
1. Abrir Home
2. Tocar tab Treinos
3. Tocar tab Progresso
4. Tocar tab Check-in
5. Voltar para Home

**Expected**:
- [ ] Cada tab carrega corretamente
- [ ] Transições suaves (60fps)
- [ ] Sem lag ou travamentos

#### TC-N2: Independent Navigation State
**Steps**:
1. Em tab Treinos: navegar Home → Detail → Execute
2. Trocar para tab Home
3. Trocar para tab Progresso
4. Voltar para tab Treinos

**Expected**:
- [ ] Tab Treinos mantém navegação em ExecuteView
- [ ] Estado de navegação preservado
- [ ] Não volta para raiz ao trocar tabs

#### TC-N3: Pop to Root on Re-tap
**Steps**:
1. Em tab Treinos, navegar deep (3 níveis)
2. Tocar tab Treinos novamente (já selecionada)

**Expected**:
- [ ] Navegação volta para raiz (WorkoutPlanListView)
- [ ] Comportamento padrão iOS

#### TC-N4: Cross-Tab Navigation (Home → Execute)
**Pre-condition**: Ter plano ativo

**Steps**:
1. Na Home, tocar botão "Iniciar Treino"

**Expected**:
- [ ] App troca para tab Treinos automaticamente
- [ ] ExecuteWorkoutView abre com plano correto
- [ ] Navegação funciona (não quebra)

---

## Common Issues & Troubleshooting

### Issue 1: Check-in não aparece após criar
**Symptom**: Botão cria check-in mas UI não atualiza

**Solution**:
- Verificar que CheckInViewModel usa @Observable
- Verificar que View usa @Environment(\.modelContext)
- Re-load data após insert

### Issue 2: Sequência calculada errada
**Symptom**: Dias consecutivos não incrementam sequência

**Solution**:
- Verificar implementação de CheckInStreak.calculateStreak()
- Testar edge cases: meia-noite, meses diferentes
- Usar Calendar.startOfDay para normalização

### Issue 3: Home carrega lento (>1s)
**Symptom**: Dashboard demora para aparecer

**Solution**:
- Verificar fetchLimit em queries (deve ser 1 para pontuais)
- Usar FetchDescriptor em vez de @Query para agregações
- Limitar check-ins query a 30 itens

### Issue 4: RecordePersonal incorreto
**Symptom**: Recorde não identifica maior peso

**Solution**:
- Revisar ProgressViewModel.calculatePersonalRecord()
- Testar com dados conhecidos (80, 90, 100kg)
- Verificar tie-breaker (maior reps se mesmo peso)

### Issue 5: TabView não troca
**Symptom**: Tocar tab não navega

**Solution**:
- Verificar @State selectedTab em ContentView
- Verificar que cada tab tem .tag() correto
- Verificar NavigationStack dentro de cada tab

---

## Performance Benchmarks

### Load Times (Expected)
| Screen | Target | Actual | Status |
|--------|--------|--------|--------|
| Home Dashboard | <1s | _measure after development_ | ⏳ |
| Check-in View | <500ms | _measure after development_ | ⏳ |
| Progress - Treinos (50 items) | <1s | _measure after development_ | ⏳ |
| Progress - Exercícios | <800ms | _measure after development_ | ⏳ |

### Memory Usage (Expected)
| Scenario | Target | Actual | Status |
|----------|--------|--------|--------|
| Home + 50 treinos | <50MB | _measure after development_ | ⏳ |
| Check-in + 60 histórico | <50MB | _measure after development_ | ⏳ |
| Progress full history | <60MB | _measure after development_ | ⏳ |

**How to Measure**:
1. Xcode → Product → Profile (⌘I)
2. Select "Time Profiler" ou "Allocations"
3. Run scenarios
4. Record numbers

---

## Accessibility Testing

### VoiceOver
- [ ] Todos botões têm labels descritivos
- [ ] Cards têm accessibility hints
- [ ] Listas anunciam contagem de itens
- [ ] Tab bar items têm labels claros

### Dynamic Type
- [ ] Texto escala com configurações de tamanho
- [ ] Layout não quebra em Extra Large
- [ ] Botões permanecem visíveis e tocáveis

### Color Contrast
- [ ] Badges coloridos têm contraste suficiente
- [ ] Texto secundário legível
- [ ] Estados desabilitados distinguíveis

---

## Data Seeding (Optional)

Para testar com dados realistas:

```swift
// Add to BumbumNaNucaApp.swift (development only)
func seedData(context: ModelContext) {
    // Seed check-ins (últimos 15 dias)
    for dayOffset in 0..<15 {
        let date = Calendar.current.date(byAdding: .day, value: -dayOffset, to: Date())!
        let checkIn = CheckIn(date: date)
        context.insert(checkIn)
    }
    
    // Plano ativo já existe (Feature 001)
    
    // Treinos já existem (Feature 002)
}
```

---

## Next Steps After Testing

1. ✅ Todas checklist items passaram? → Proceed to implementation
2. ❌ Failures encontrados? → Document issues, fix bugs
3. ⚠️ Performance abaixo do target? → Optimize queries, profiling
4. 📝 Update IMPLEMENTATION_STATUS.md com progress

---

## Support & Questions

- **Constitution**: `.specify/memory/constitution.md`
- **Spec**: `specs/003-mvp-completion/spec.md`
- **Plan**: `specs/003-mvp-completion/plan.md`
- **Data Model**: `specs/003-mvp-completion/data-model.md`
- **Research**: `specs/003-mvp-completion/research.md`

---

**Status**: ✅ Quickstart complete. Ready for manual testing and validation.
