# BumbumNaNuca - Especificação do MVP

## 📋 Resumo Executivo

**Produto:** BumbumNaNuca - Gerenciador de Treinos de Academia para iOS  
**Versão:** 1.0 (MVP)  
**Objetivo:** Lançar um aplicativo funcional e simples para gerenciar treinos de academia, focando nas funcionalidades essenciais  
**Prazo:** 8-10 semanas  
**Plataforma:** iOS 17.0+

---

## 🎯 Visão do MVP

### O Que É
Um aplicativo iOS nativo que permite aos usuários:
1. Criar planos de treino manualmente
2. Executar treinos registrando pesos e repetições
3. Usar timer de descanso entre séries
4. Acompanhar progresso básico
5. Fazer check-in na academia

### O Que NÃO É (Versão 1.0)
- ❌ Importação de PDF (v1.1)
- ❌ Vídeos instrucionais (v1.1)
- ❌ Gráficos avançados (v1.2)
- ❌ Sincronização iCloud (v2.0)
- ❌ Apple Watch (v2.0)
- ❌ HealthKit (v2.0)

---

## ✅ Funcionalidades do MVP

### 1. Gerenciamento de Planos de Treino ⭐ CRÍTICO

#### 1.1 Criar Plano Manualmente
**Descrição:** Usuário pode criar um novo plano de treino do zero

**Fluxo:**
1. Abrir aba "Treinos"
2. Clicar botão "+"
3. Inserir nome do plano (obrigatório)
4. Inserir descrição (opcional)
5. Adicionar exercícios um por um
6. Salvar plano

**Tela: CreateWorkoutPlanView**
```
Campos:
- Nome do Plano: TextField
- Descrição: TextField (multiline, opcional)
- Lista de exercícios: List (vazia inicialmente)
- Botão "Adicionar Exercício"
- Botões: Cancelar | Salvar
```

**Critérios de Aceitação:**
- ✅ Nome do plano é obrigatório (mínimo 3 caracteres)
- ✅ Descrição é opcional (máximo 500 caracteres)
- ✅ Plano pode ter 0 a 50 exercícios
- ✅ Dados são salvos no SwiftData
- ✅ Volta para lista após salvar

#### 1.2 Adicionar Exercícios ao Plano
**Descrição:** Adicionar exercícios individuais ao plano

**Fluxo:**
1. No formulário de criação, clicar "Adicionar Exercício"
2. Sheet abre com formulário
3. Preencher dados do exercício
4. Salvar exercício
5. Exercício aparece na lista do plano

**Tela: AddExerciseSheet**
```
Campos:
- Nome: TextField (obrigatório)
- Grupo Muscular: Picker (obrigatório)
  * Peito, Costas, Pernas, Ombros, Braços, Abdômen, Cardio
- Séries Padrão: Stepper/TextField (1-10, padrão 3)
- Repetições Padrão: Stepper/TextField (1-50, padrão 12)
- Tempo de Descanso: Picker (30s, 60s, 90s, 120s, 180s)
```

**Critérios de Aceitação:**
- ✅ Nome do exercício é obrigatório
- ✅ Grupo muscular deve ser selecionado
- ✅ Valores numéricos têm limites razoáveis
- ✅ Exercício é adicionado à lista imediatamente

#### 1.3 Listar Planos de Treino
**Descrição:** Visualizar todos os planos salvos

**Tela: WorkoutPlanListView**
```
Elementos:
- NavigationBar com título "Treinos"
- Botão "+" no toolbar (criar novo)
- Lista de cards de planos:
  * Nome do plano
  * Número de exercícios
  * Badge "Ativo" (se isActive)
  * Última execução (se houver)
- Empty state: "Nenhum plano criado"
```

**Critérios de Aceitação:**
- ✅ Mostra todos os planos salvos
- ✅ Ordenados por data de criação (mais recente primeiro)
- ✅ Tap abre detalhes do plano
- ✅ Empty state quando não há planos

#### 1.4 Ver Detalhes do Plano
**Descrição:** Visualizar exercícios de um plano

**Tela: WorkoutPlanDetailView**
```
Elementos:
- NavigationBar com nome do plano
- Botão "Iniciar Treino" (destaque)
- Lista de exercícios:
  * Nome
  * Grupo muscular (tag colorida)
  * Séries x Repetições
- Toolbar:
  * Editar
  * Marcar como Ativo/Inativo
```

**Critérios de Aceitação:**
- ✅ Mostra todos os exercícios do plano
- ✅ Botão "Iniciar Treino" cria nova sessão
- ✅ Pode marcar apenas um plano como ativo

#### 1.5 Editar Plano
**Descrição:** Modificar plano existente

**Funcionalidades:**
- Editar nome e descrição
- Adicionar novos exercícios
- Editar exercícios existentes
- Remover exercícios (swipe-to-delete)
- Reordenar exercícios (drag & drop)

**Critérios de Aceitação:**
- ✅ Mudanças são salvas em tempo real
- ✅ Pode desfazer mudanças (botão Cancelar)

---

### 2. Executar Treino ⭐ CRÍTICO

#### 2.1 Iniciar Sessão de Treino
**Descrição:** Começar um novo treino

**Fluxo:**
1. Na HomeView ou WorkoutPlanDetailView, clicar "Iniciar Treino"
2. Cria nova WorkoutSession
3. Navega para ExecuteWorkoutView

**Critérios de Aceitação:**
- ✅ Cria WorkoutSession com startDate
- ✅ Associa sessão ao plano
- ✅ Navega para tela de execução

#### 2.2 Executar Exercícios
**Descrição:** Registrar séries de cada exercício

**Tela: ExecuteWorkoutView**
```
Elementos:
- Header: Nome do plano
- Progresso: "2/8 exercícios completos"
- Lista de exercícios:
  * ✓ Supino Reto (completo)
  * → Supino Inclinado (em andamento)
  * Crossover (pendente)
- Tap no exercício → ExecuteExerciseView
```

**Tela: ExecuteExerciseView**
```
Elementos:
- Nome do exercício (header)
- Indicador: "Série 1 de 4"
- Último treino (se houver):
  * "Último: 80kg × 10 reps"
- Inputs:
  * Peso (kg): TextField numérico
  * Repetições: TextField numérico
- Botão "Concluir Série" (grande, destaque)
- Lista de séries anteriores (nesta sessão)
```

**Fluxo de Série:**
1. Usuário insere peso e reps
2. Clica "Concluir Série"
3. Salva ExerciseSet
4. Se não for última série: Inicia Timer
5. Se for última série: Marca exercício completo
6. Volta para lista de exercícios

**Critérios de Aceitação:**
- ✅ Peso deve ser > 0 ou vazio (peso corporal)
- ✅ Reps deve ser > 0
- ✅ Série é salva imediatamente no SwiftData
- ✅ Mostra dados do último treino (mesmo exercício)
- ✅ Pode completar séries parciais (menos que o padrão)

#### 2.3 Timer de Descanso
**Descrição:** Cronômetro entre séries

**Tela: RestTimerView (Sheet)**
```
Elementos:
- Contador circular (progress ring)
- Tempo restante (grande, monospaced)
- Botões:
  * Play/Pause (toggle)
  * Reiniciar
  * Pular
```

**Comportamento:**
- Inicia automaticamente após concluir série
- Conta regressivamente
- Ao chegar a 00:00:
  * Vibra (haptic feedback)
  * Toca som breve
  * Dismiss automático
- Pode ser pausado/pulado a qualquer momento
- Continua em background (até certo ponto)

**Critérios de Aceitação:**
- ✅ Precisão de ±1 segundo
- ✅ Vibração ao término
- ✅ Som ao término (respeitando silent mode)
- ✅ Pode ser cancelado
- ✅ Funciona em background por até 3 minutos

#### 2.4 Finalizar Treino
**Descrição:** Concluir sessão de treino

**Fluxo:**
1. Após completar todos os exercícios (ou desistir)
2. Mostra WorkoutSummaryView
3. Exibe estatísticas básicas
4. Botão "Finalizar"
5. Salva WorkoutSession (isCompleted = true, endDate = now)
6. Navega para Home

**Tela: WorkoutSummaryView**
```
Elementos:
- Título: "Treino Concluído!" 🎉
- Cards de estatísticas:
  * Duração total
  * Exercícios completados
  * Total de séries
  * Total de repetições
- Botão "Finalizar" (grande)
```

**Critérios de Aceitação:**
- ✅ Calcula duração corretamente (startDate → endDate)
- ✅ Conta exercícios/séries/reps corretos
- ✅ Salva sessão completa
- ✅ Retorna para Home

---

### 3. Acompanhamento de Progresso 📊 IMPORTANTE

#### 3.1 Histórico de Treinos
**Descrição:** Ver treinos anteriores

**Tela: ProgressView (Tab)**
```
Elementos:
- Segmented Control: "Treinos" | "Exercícios"
- Tab "Treinos":
  * Lista de WorkoutSessions
  * Para cada sessão:
    - Data e hora
    - Nome do plano
    - Duração
    - Tap → Detalhes da sessão
```

**Critérios de Aceitação:**
- ✅ Mostra últimas 50 sessões
- ✅ Ordenadas por data (mais recente primeiro)
- ✅ Pode filtrar por plano (futuro)

#### 3.2 Histórico por Exercício
**Descrição:** Ver evolução de um exercício específico

**Tab "Exercícios" em ProgressView:**
```
- Lista de todos os exercícios já executados
- Para cada exercício:
  * Nome
  * Última execução: data
  * Melhor série: 85kg × 8
  * Total de vezes executado
- Tap → ExerciseHistoryView
```

**Tela: ExerciseHistoryView**
```
Elementos:
- Nome do exercício (header)
- Estatísticas:
  * Recorde pessoal (maior peso × reps)
  * Última execução
  * Total de séries registradas
- Lista de séries (todas):
  * Data
  * Peso × Reps
  * Treino associado
```

**Critérios de Aceitação:**
- ✅ Identifica recorde pessoal (peso máximo)
- ✅ Mostra histórico completo
- ✅ Ordenado por data (mais recente primeiro)

---

### 4. Check-in na Academia 📅 IMPORTANTE

#### 4.1 Fazer Check-in
**Descrição:** Registrar presença na academia

**Tela: CheckInView (Tab)**
```
Elementos:
- Card de Check-in:
  * Se não fez hoje:
    - Botão grande "Fazer Check-in"
    - Texto: "Marque sua presença hoje"
  * Se já fez:
    - ✓ "Check-in realizado!"
    - Horário do check-in
    - Estado desabilitado
- Card de Sequência:
  * 🔥 Sequência Atual: 7 dias
  * ⭐ Melhor Sequência: 14 dias
```

**Comportamento:**
- Botão cria CheckIn com data/hora atual
- Só pode fazer 1 check-in por dia
- Reseta às 00:00 do dia seguinte
- Calcula sequência automaticamente

**Critérios de Aceitação:**
- ✅ Apenas 1 check-in por dia
- ✅ Sequência incrementa se check-in diário
- ✅ Sequência reseta se pular 1 dia
- ✅ Melhor sequência é salva

#### 4.2 Visualizar Frequência
**Descrição:** Ver estatísticas de frequência

**Adicional em CheckInView:**
```
- Card "Este Mês":
  * Total de check-ins: 18
  * Dias de treino: 18/30 (60%)
  * Meta: 20 dias
- Lista de check-ins recentes:
  * Hoje
  * Ontem
  * Há 2 dias
  * ...
```

**Critérios de Aceitação:**
- ✅ Conta check-ins do mês corretamente
- ✅ Calcula percentual
- ✅ Mostra histórico dos últimos 30 dias

---

### 5. Tela Inicial (Home) 🏠 IMPORTANTE

#### 5.1 Dashboard
**Descrição:** Overview do estado atual

**Tela: HomeView (Tab)**
```
Elementos:
- Saudação: "Olá, Atleta!"
- Data: Segunda, 6 de Janeiro de 2026
- Card Check-in:
  * Botão rápido de check-in (se não fez)
  * Status (se já fez)
- Card Sequência:
  * Sequência atual
- Card Plano Ativo:
  * Nome do plano
  * Botão "Iniciar Treino"
- Card Último Treino:
  * Nome do plano
  * "Há 2 dias"
  * Duração: 1h 15min
```

**Critérios de Aceitação:**
- ✅ Mostra status de check-in do dia
- ✅ Plano ativo é destacado
- ✅ Último treino mostra dados corretos
- ✅ Botão "Iniciar Treino" funciona

---

## 🗂️ Estrutura de Dados do MVP

### Models

#### WorkoutPlan
```swift
@Model
class WorkoutPlan {
    var id: UUID = UUID()
    var name: String
    var description: String = ""
    var createdDate: Date = Date()
    var isActive: Bool = false
    
    @Relationship(deleteRule: .cascade)
    var exercises: [Exercise] = []
    
    @Relationship(deleteRule: .nullify)
    var sessions: [WorkoutSession] = []
}
```

#### Exercise
```swift
@Model
class Exercise {
    var id: UUID = UUID()
    var name: String
    var muscleGroup: MuscleGroup
    var defaultSets: Int = 3
    var defaultReps: Int = 12
    var defaultRestTime: Int = 60 // segundos
    var order: Int = 0
    
    var workoutPlan: WorkoutPlan?
    
    @Relationship(deleteRule: .cascade)
    var sets: [ExerciseSet] = []
}

enum MuscleGroup: String, Codable, CaseIterable {
    case chest = "Peito"
    case back = "Costas"
    case legs = "Pernas"
    case shoulders = "Ombros"
    case arms = "Braços"
    case abs = "Abdômen"
    case cardio = "Cardio"
}
```

#### WorkoutSession
```swift
@Model
class WorkoutSession {
    var id: UUID = UUID()
    var startDate: Date = Date()
    var endDate: Date?
    var isCompleted: Bool = false
    var notes: String = ""
    
    var workoutPlan: WorkoutPlan?
    
    @Relationship(deleteRule: .cascade)
    var exerciseSets: [ExerciseSet] = []
}
```

#### ExerciseSet
```swift
@Model
class ExerciseSet {
    var id: UUID = UUID()
    var setNumber: Int
    var weight: Double? // nil = peso corporal
    var reps: Int
    var completedDate: Date = Date()
    var notes: String = ""
    
    var exercise: Exercise?
    var session: WorkoutSession?
}
```

#### CheckIn
```swift
@Model
class CheckIn {
    var id: UUID = UUID()
    var date: Date = Date()
    var notes: String = ""
    
    var workoutSession: WorkoutSession?
}
```

---

## 🎨 Design Mínimo

### Cores
```swift
// Usar cores do sistema iOS
- Primary: .blue (ações principais)
- Success: .green (check-in, conclusões)
- Destructive: .red (deletar)
- Text: .primary, .secondary (sistema)
- Background: .systemBackground
- Card: .secondarySystemBackground
```

### Componentes

#### PrimaryButton
```swift
Button("Ação") { }
    .buttonStyle(.borderedProminent)
    .controlSize(.large)
```

#### Card
```swift
VStack { ... }
    .padding()
    .background(.secondarySystemBackground)
    .cornerRadius(12)
```

#### EmptyState
```swift
ContentUnavailableView(
    "Sem planos",
    systemImage: "figure.strengthtraining.traditional",
    description: Text("Crie seu primeiro plano de treino")
)
```

---

## 🏗️ Arquitetura Simplificada

### Estrutura de Pastas
```
BumbumNaNuca/
├── App/
│   └── BumbumNaNucaApp.swift
├── Models/
│   ├── WorkoutPlan.swift
│   ├── Exercise.swift
│   ├── WorkoutSession.swift
│   ├── ExerciseSet.swift
│   └── CheckIn.swift
├── Views/
│   ├── ContentView.swift (TabView)
│   ├── Home/
│   │   └── HomeView.swift
│   ├── Workout/
│   │   ├── WorkoutPlanListView.swift
│   │   ├── WorkoutPlanDetailView.swift
│   │   ├── CreateWorkoutPlanView.swift
│   │   ├── ExecuteWorkoutView.swift
│   │   └── ExecuteExerciseView.swift
│   ├── Progress/
│   │   ├── ProgressView.swift
│   │   └── ExerciseHistoryView.swift
│   ├── CheckIn/
│   │   └── CheckInView.swift
│   └── Components/
│       ├── RestTimerView.swift
│       └── WorkoutSummaryView.swift
└── Utilities/
    ├── Extensions/
    └── Helpers/
```

### Navegação
```swift
struct ContentView: View {
    var body: some View {
        TabView {
            HomeView()
                .tabItem { Label("Home", systemImage: "house") }
            
            WorkoutPlanListView()
                .tabItem { Label("Treinos", systemImage: "dumbbell") }
            
            ProgressView()
                .tabItem { Label("Progresso", systemImage: "chart.bar") }
            
            CheckInView()
                .tabItem { Label("Check-in", systemImage: "calendar") }
        }
    }
}
```

### SwiftData Setup
```swift
@main
struct BumbumNaNucaApp: App {
    var sharedModelContainer: ModelContainer = {
        let schema = Schema([
            WorkoutPlan.self,
            Exercise.self,
            WorkoutSession.self,
            ExerciseSet.self,
            CheckIn.self
        ])
        let modelConfiguration = ModelConfiguration(schema: schema)
        return try! ModelContainer(for: schema, configurations: [modelConfiguration])
    }()
    
    var body: some Scene {
        WindowGroup {
            ContentView()
        }
        .modelContainer(sharedModelContainer)
    }
}
```

---

## ✅ Critérios de Aceite do MVP

### Funcionalidade
- [ ] Criar plano de treino com mínimo 1 exercício
- [ ] Executar treino completo (todas as séries)
- [ ] Timer funciona e vibra ao término
- [ ] Dados são salvos persistentemente (não perder ao fechar app)
- [ ] Check-in funciona e calcula sequência
- [ ] Histórico mostra treinos anteriores
- [ ] Pode editar planos existentes
- [ ] Pode deletar planos (com confirmação)

### Performance
- [ ] App inicia em < 2 segundos
- [ ] Transições são fluidas (60fps)
- [ ] Não trava durante uso normal
- [ ] Usa < 100MB de memória

### Qualidade
- [ ] Zero crashes em teste de 1 hora
- [ ] Funciona em iPhone SE (tela pequena) e iPhone 15 Pro Max
- [ ] Modo claro e escuro funcionam
- [ ] Textos legíveis em todos os tamanhos (Dynamic Type)

### UX
- [ ] Fluxo completo de criar → executar → ver progresso funciona sem confusão
- [ ] Botões têm tamanho mínimo de 44x44pt
- [ ] Estados de erro têm mensagens claras
- [ ] Empty states são informativos

---

## 📅 Roadmap do MVP (8 semanas)

### Semana 1-2: Foundation
- [x] Setup projeto Xcode
- [ ] Configurar SwiftData
- [ ] Implementar Models
- [ ] Estrutura de navegação (TabView)
- [ ] Telas vazias com navegação funcionando

### Semana 3-4: Core Features
- [ ] CreateWorkoutPlanView (criar + editar)
- [ ] AddExerciseSheet
- [ ] WorkoutPlanListView
- [ ] WorkoutPlanDetailView
- [ ] CRUD completo de planos

### Semana 5-6: Execução de Treino
- [ ] ExecuteWorkoutView
- [ ] ExecuteExerciseView
- [ ] SetTrackerView (inputs de peso/reps)
- [ ] RestTimerView
- [ ] WorkoutSummaryView
- [ ] Salvar ExerciseSets e WorkoutSessions

### Semana 7: Progresso e Check-in
- [ ] ProgressView (histórico)
- [ ] ExerciseHistoryView
- [ ] CheckInView
- [ ] Cálculo de sequências

### Semana 8: Polish e Testes
- [ ] HomeView dashboard
- [ ] Refinamento de UI/UX
- [ ] Tratamento de erros
- [ ] Testes manuais completos
- [ ] Correção de bugs
- [ ] Preparação para TestFlight

---

## 🚫 O Que NÃO Fazer no MVP

### Não Implementar (deixar para v1.1+)
- ❌ Importação de PDF
- ❌ Vídeos instrucionais do YouTube
- ❌ Gráficos (Charts)
- ❌ Compartilhamento de treinos
- ❌ Exportação de dados
- ❌ Temas customizados
- ❌ Widgets iOS
- ❌ Notificações push
- ❌ Onboarding elaborado (apenas skip no MVP)

### Não Complicar
- ❌ Múltiplos perfis de usuário
- ❌ Sincronização em nuvem
- ❌ Autenticação/login
- ❌ Comunidade/social
- ❌ IA/ML features
- ❌ Integração com Apple Health (v2.0)
- ❌ Suporte a iPad (focar iPhone no MVP)

---

## 🎯 Métricas de Sucesso do MVP

### Durante Desenvolvimento
- Velocity: 1 feature grande por semana
- Bugs encontrados: < 5 críticos por semana
- Code review: < 24h para aprovar PRs

### Pós-Lançamento (TestFlight)
- Instalações: 50+ beta testers
- Retenção D7: > 30%
- Crash rate: < 1%
- Rating: > 4.0 ⭐
- Feedback qualitativo: > 70% positivo

### Uso
- Planos criados por usuário: > 1
- Treinos completados: > 3 na primeira semana
- Check-ins: > 50% dos dias de uso

---

## 📝 Tarefas Pré-Launch

### Obrigatório
- [ ] Ícone do app (1024x1024)
- [ ] Launch screen
- [ ] Privacy Policy
- [ ] App Store screenshots (iPhone)
- [ ] App Store description
- [ ] TestFlight beta testing (2 semanas)
- [ ] Correção de bugs críticos

### Desejável
- [ ] Demo vídeo (15-30s)
- [ ] Website simples
- [ ] Documentação de ajuda in-app
- [ ] Suporte via email configurado

---

## 🔧 Stack Tecnológica do MVP

### Obrigatório
- **SwiftUI**: Interface
- **SwiftData**: Persistência
- **Combine**: Timers e reactive
- **AVFoundation**: Som do timer

### Bibliotecas Nativas (sem dependências externas)
- PDFKit: ❌ Não usar no MVP
- Charts: ❌ Não usar no MVP
- HealthKit: ❌ Não usar no MVP

### Ferramentas
- Xcode 15.0+
- iOS Simulator
- TestFlight para beta
- GitHub para versionamento

---

## 💡 Princípios do MVP

### 1. Simplicidade Primeiro
> "O melhor código é o que não precisa ser escrito"
- Use componentes nativos do SwiftUI sempre que possível
- Não customizar demais a UI no início
- Aproveite SwiftData query automático

### 2. Funcionalidade > Estética
- Funcionar bem > Parecer bonito
- UX clara > Animações elaboradas
- Dados salvos > UI perfeita

### 3. Iteração Rápida
- Lançar MVP em 8 semanas
- Coletar feedback
- Iterar baseado em dados reais
- v1.1 em 4 semanas após v1.0

### 4. Zero Dependências
- Não adicionar frameworks de terceiros
- Usar apenas o que vem com iOS SDK
- Manter bundle size mínimo
- Facilitar manutenção

---

## 📞 Próximos Passos

### Para Começar HOJE
1. ✅ Ler esta spec completamente
2. [ ] Criar projeto no Xcode
3. [ ] Setup Git repository
4. [ ] Implementar Models (SwiftData)
5. [ ] Criar TabView de navegação
6. [ ] Primeira tela: WorkoutPlanListView com empty state

### Esta Semana
- [ ] CRUD completo de WorkoutPlan
- [ ] Adicionar exercícios a planos
- [ ] Ver lista de exercícios
- [ ] Primeira versão rodando no simulator

### Este Mês
- [ ] Feature completa de criar/editar planos ✅
- [ ] Feature completa de executar treinos ✅
- [ ] Timer funcionando ✅
- [ ] Dados persistindo ✅

---

## 📖 Referências Rápidas

### SwiftData Query
```swift
@Query(sort: \WorkoutPlan.createdDate, order: .reverse)
private var plans: [WorkoutPlan]

@Query(filter: #Predicate<WorkoutPlan> { $0.isActive })
private var activePlans: [WorkoutPlan]
```

### Salvar Dados
```swift
@Environment(\.modelContext) private var modelContext

func savePlan() {
    let plan = WorkoutPlan(name: planName)
    modelContext.insert(plan)
    // Auto-salva
}
```

### Deletar
```swift
modelContext.delete(plan)
// Auto-salva
```

---

## ✨ Conclusão

Este MVP foca no essencial:
1. ✅ Criar planos de treino
2. ✅ Executar treinos
3. ✅ Timer de descanso
4. ✅ Progresso básico
5. ✅ Check-in

**Meta:** App funcional em 8 semanas, pronto para beta testing.

**Próxima versão (v1.1):** Importação PDF, Vídeos, Gráficos

**Lembre-se:** Melhor um MVP simples e funcional que um app complexo e bugado!

---

**Versão:** 1.0  
**Última atualização:** 06/01/2026  
**Status:** ✅ Especificação Completa - Pronto para Desenvolvimento
