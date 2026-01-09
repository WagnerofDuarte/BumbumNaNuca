# Feature Specification: MVP Completion

**Feature Branch**: `003-mvp-completion`  
**Created**: 08/01/2026  
**Status**: Draft  
**Input**: User description: "Implementar features restantes do MVP: Home Dashboard com plano ativo e último treino, Progress Tracking com histórico de treinos e exercícios, e Check-in com sequências e frequência mensal"

## User Scenarios & Testing *(mandatory)*

### User Story 1 - Dashboard Principal (Priority: P1)

O usuário abre o app e visualiza imediatamente um dashboard com suas informações mais importantes: status de check-in do dia, plano de treino ativo com botão para iniciar, e resumo do último treino realizado.

**Why this priority**: Esta é a tela principal do app (Home). É a primeira impressão do usuário e o ponto de partida para todas as ações principais. Sem ela, o app não tem uma navegação central coesa.

**Independent Test**: Pode ser totalmente testado abrindo o app e verificando se mostra: (1) data atual, (2) card de check-in, (3) plano ativo com botão "Iniciar Treino", (4) resumo do último treino com duração. Entrega valor mostrando status atual e ações rápidas.

**Acceptance Scenarios**:

1. **Given** usuário abre o app pela primeira vez, **When** navega para tab Home, **Then** vê saudação "Olá, Atleta!", data atual, e mensagem indicando que não há plano ativo
2. **Given** usuário tem um plano ativo, **When** abre tab Home, **Then** vê card do plano ativo com nome do plano e botão "Iniciar Treino" em destaque
3. **Given** usuário completou um treino há 2 dias, **When** visualiza Home, **Then** vê card "Último Treino" mostrando nome do plano, texto "Há 2 dias" e duração total
4. **Given** usuário NÃO fez check-in hoje, **When** visualiza Home, **Then** vê card de check-in com botão "Fazer Check-in"
5. **Given** usuário JÁ fez check-in hoje, **When** visualiza Home, **Then** vê card de check-in com ícone ✓, texto "Check-in realizado!" e horário
6. **Given** usuário toca botão "Iniciar Treino" no card do plano ativo, **When** confirma ação, **Then** navega para ExecuteWorkoutView com o plano ativo

---

### User Story 2 - Check-in na Academia (Priority: P2)

O usuário registra sua presença na academia diariamente, acompanha sua sequência de dias consecutivos e visualiza estatísticas de frequência mensal.

**Why this priority**: Motivação é fundamental para manter usuários engajados. Gamificação via sequências de check-ins aumenta retenção e cria hábito de uso regular. É uma feature "quick win" para engajamento.

**Independent Test**: Pode ser testado fazendo check-in, verificando que só permite 1 por dia, observando cálculo de sequência (dias consecutivos) e visualizando estatísticas mensais. Entrega valor motivacional independentemente das outras features.

**Acceptance Scenarios**:

1. **Given** usuário não fez check-in hoje, **When** abre tab Check-in e toca botão "Fazer Check-in", **Then** sistema salva CheckIn com data/hora atual e mostra ✓ "Check-in realizado!"
2. **Given** usuário já fez check-in hoje, **When** tenta fazer novo check-in, **Then** botão está desabilitado e mostra mensagem "Você já fez check-in hoje às [horário]"
3. **Given** usuário fez check-in nos últimos 5 dias consecutivos, **When** visualiza tab Check-in, **Then** vê card "🔥 Sequência Atual: 5 dias"
4. **Given** usuário teve sequência de 14 dias (melhor sequência) mas pulou ontem, **When** faz check-in hoje, **Then** sequência atual reinicia para 1 dia, mas "⭐ Melhor Sequência: 14 dias" permanece
5. **Given** usuário está no mês de janeiro, **When** visualiza estatísticas mensais, **Then** vê "Check-ins: 18/31 (58%)" e lista dos últimos 30 check-ins
6. **Given** usuário fez check-in, **When** navega para Home, **Then** card de check-in em Home reflete status atualizado

---

### User Story 3 - Histórico de Treinos (Priority: P2)

O usuário visualiza todos os treinos que executou anteriormente, com detalhes de data, duração, plano usado e pode acessar detalhes completos de cada sessão.

**Why this priority**: Transparência e accountability. Usuários querem ver seu histórico de trabalho. Também permite revisar sessões anteriores para referência futura. Essencial para senso de progresso.

**Independent Test**: Pode ser testado completando 3+ treinos e verificando que lista mostra todas as sessões ordenadas por data, com informações corretas. Tocar em uma sessão deve mostrar exercícios e séries executadas. Entrega valor de "diário de treino".

**Acceptance Scenarios**:

1. **Given** usuário completou 3 treinos nos últimos 7 dias, **When** abre tab Progresso e seleciona aba "Treinos", **Then** vê lista de 3 WorkoutSessions ordenadas da mais recente para mais antiga
2. **Given** usuário visualiza lista de treinos, **When** observa cada item, **Then** cada treino mostra: data/hora de início, nome do plano, duração total, ícone de completude
3. **Given** usuário toca em um treino específico na lista, **When** abre detalhes da sessão, **Then** vê lista completa de exercícios executados com todas as séries (peso × reps) registradas
4. **Given** usuário nunca completou nenhum treino, **When** abre aba "Treinos", **Then** vê empty state: "Nenhum treino realizado" com sugestão para iniciar primeiro treino
5. **Given** usuário completou treino há 3 horas, **When** visualiza histórico, **Then** vê texto de tempo relativo "Há 3 horas" (usando Date+Extensions)

---

### User Story 4 - Histórico por Exercício (Priority: P3)

O usuário visualiza evolução de exercícios específicos, identifica recorde pessoal de cada exercício e vê todas as séries já executadas para aquele movimento.

**Why this priority**: Acompanhamento de progresso individualizado por exercício é valioso mas não crítico para o MVP funcionar. Pode ser desenvolvido após features P1/P2 estarem estáveis.

**Independent Test**: Pode ser testado executando mesmo exercício em múltiplas sessões com pesos diferentes, depois acessando aba "Exercícios" e verificando que mostra recorde pessoal correto e histórico completo. Entrega valor de tracking detalhado por movimento.

**Acceptance Scenarios**:

1. **Given** usuário executou exercício "Supino Reto" em 5 sessões diferentes, **When** abre tab Progresso e seleciona aba "Exercícios", **Then** vê "Supino Reto" listado com última execução e total de vezes executado
2. **Given** usuário toca em "Supino Reto" na lista de exercícios, **When** abre ExerciseHistoryView, **Then** vê estatísticas: recorde pessoal (ex: "100kg × 8"), última execução (data), total de séries registradas
3. **Given** usuário executou Supino com pesos: 80kg, 90kg, 100kg, 95kg em diferentes sessões, **When** visualiza histórico do exercício, **Then** recorde pessoal identifica corretamente "100kg × [reps]" como maior peso
4. **Given** usuário visualiza histórico de exercício, **When** rola a lista de séries, **Then** vê todas as séries já executadas com data, peso, reps e nome do treino associado
5. **Given** usuário nunca executou nenhum exercício, **When** abre aba "Exercícios", **Then** vê empty state: "Nenhum exercício realizado ainda"

---

### User Story 5 - Navegação por Tabs (Priority: P1)

O usuário navega facilmente entre as principais seções do app usando TabView na parte inferior da tela.

**Why this priority**: Fundamental para arquitetura do app. Sem TabView, não há como acessar as diferentes telas de forma nativa e intuitiva no iOS. É infraestrutura básica.

**Independent Test**: Pode ser testado tocando em cada tab e verificando que troca de tela corretamente. Entrega estrutura de navegação completa.

**Acceptance Scenarios**:

1. **Given** usuário abre o app, **When** visualiza parte inferior da tela, **Then** vê TabView com 4 tabs: "Home" (ícone house), "Treinos" (ícone dumbbell), "Progresso" (ícone chart.bar), "Check-in" (ícone calendar)
2. **Given** usuário está na tab Home, **When** toca tab "Treinos", **Then** navega para WorkoutPlanListView
3. **Given** usuário está em qualquer tab, **When** toca tab "Progresso", **Then** navega para ProgressView mostrando aba "Treinos" por padrão
4. **Given** usuário está em qualquer tab, **When** toca tab "Check-in", **Then** navega para CheckInView
5. **Given** usuário está navegando dentro de uma tela (ex: detalhes de treino), **When** toca outra tab, **Then** volta para raiz da nova tab selecionada

---

### Edge Cases

- O que acontece quando usuário faz check-in exatamente à meia-noite (00:00)? Sistema deve considerar como check-in do novo dia.
- Como sistema calcula sequência se usuário fez check-in às 23:59 de um dia e 00:01 do próximo? Devem ser considerados dias consecutivos.
- O que acontece se usuário nunca marcou plano como ativo? Home deve mostrar mensagem clara "Nenhum plano ativo" com sugestão de ativar um plano.
- Como sistema lida com treino que durou mais de 3 horas? Deve mostrar duração correta (ex: "3h 25min").
- O que acontece se usuário abandonou treino (não completou)? Histórico deve mostrar sessões incompletas com indicador visual diferente.
- Como sistema mostra último treino se usuário nunca completou nenhum? Card deve estar oculto ou mostrar empty state.
- O que acontece se lista de check-ins tem mais de 100 registros? Implementar paginação ou limite de exibição (últimos 50).
- Como sistema calcula recorde pessoal se exercício tem múltiplas séries com mesmo peso máximo mas reps diferentes? Deve considerar maior peso × maior reps naquele peso.
- O que acontece se usuário deleta plano que tem sessões associadas? Sessões devem manter referência ao plano (deleteRule: .nullify já implementado).

## Requirements *(mandatory)*

### Functional Requirements

**Home Dashboard:**
- **FR-001**: Sistema DEVE exibir saudação "Olá, Atleta!" e data atual formatada (ex: "Segunda, 8 de Janeiro de 2026")
- **FR-002**: Sistema DEVE mostrar card de check-in indicando se usuário já fez check-in hoje (com horário) ou botão para fazer check-in
- **FR-003**: Sistema DEVE exibir card do plano ativo com nome do plano e botão "Iniciar Treino" em destaque
- **FR-004**: Sistema DEVE mostrar card do último treino com nome do plano, tempo decorrido desde execução (ex: "Há 2 dias") e duração total
- **FR-005**: Sistema DEVE ocultar card do plano ativo se nenhum plano estiver marcado como ativo, mostrando mensagem "Nenhum plano ativo"
- **FR-006**: Sistema DEVE ocultar card do último treino se usuário nunca completou nenhum treino
- **FR-007**: Botão "Fazer Check-in" no card de Home DEVE executar mesma ação que botão na tab Check-in

**Check-in:**
- **FR-008**: Sistema DEVE permitir apenas 1 check-in por dia (00:00 a 23:59)
- **FR-009**: Sistema DEVE salvar CheckIn com data e hora exata (timestamp completo)
- **FR-010**: Sistema DEVE calcular sequência atual baseado em check-ins consecutivos (sem pular dias)
- **FR-011**: Sistema DEVE resetar sequência para 0 se usuário pular 1 ou mais dias
- **FR-012**: Sistema DEVE manter registro da melhor sequência (maior número de dias consecutivos já alcançado)
- **FR-013**: Sistema DEVE exibir estatísticas do mês atual: total de check-ins, dias de treino / total de dias no mês, percentual
- **FR-014**: Sistema DEVE listar últimos 30 check-ins com data relativa (Hoje, Ontem, Há X dias)
- **FR-015**: Botão de check-in DEVE ficar desabilitado após fazer check-in do dia
- **FR-016**: Check-in PODE ter campo opcional de notes (não obrigatório para MVP)

**Histórico de Treinos:**
- **FR-017**: Sistema DEVE exibir lista de todas as WorkoutSessions completadas (isCompleted = true)
- **FR-018**: Sistema DEVE ordenar treinos por startDate descendente (mais recente primeiro)
- **FR-019**: Sistema DEVE mostrar para cada treino: data/hora de início, nome do plano, duração total, status de completude
- **FR-020**: Sistema DEVE calcular duração total como endDate - startDate em formato legível (ex: "1h 15min")
- **FR-021**: Sistema DEVE permitir tocar em treino para ver detalhes completos da sessão
- **FR-022**: Detalhes da sessão DEVEM mostrar lista de exercícios executados com todas as séries (peso × reps) de cada exercício
- **FR-023**: Sistema DEVE exibir empty state "Nenhum treino realizado" se lista estiver vazia
- **FR-024**: Sistema DEVE limitar exibição a últimos 50 treinos (performance)

**Histórico por Exercício:**
- **FR-025**: Sistema DEVE listar todos os exercícios que já foram executados pelo menos uma vez
- **FR-026**: Sistema DEVE mostrar para cada exercício: nome, última execução (data), total de vezes executado
- **FR-027**: Sistema DEVE permitir tocar em exercício para ver ExerciseHistoryView com detalhes
- **FR-028**: ExerciseHistoryView DEVE calcular e exibir recorde pessoal (maior peso × reps para aquele exercício)
- **FR-029**: Sistema DEVE listar todas as séries já executadas daquele exercício com: data, peso, reps, nome do treino
- **FR-030**: Sistema DEVE ordenar séries por data descendente (mais recente primeiro)
- **FR-031**: Sistema DEVE exibir empty state "Nenhum exercício realizado ainda" se lista estiver vazia

**Navegação:**
- **FR-032**: Sistema DEVE implementar TabView com 4 tabs: Home, Treinos, Progresso, Check-in
- **FR-033**: Cada tab DEVE ter ícone SF Symbol apropriado e label descritivo
- **FR-034**: Sistema DEVE manter estado de navegação de cada tab independentemente
- **FR-035**: Tocar em tab já selecionada DEVE voltar para raiz daquela navegação (pop to root)

### Key Entities

- **CheckIn**: Representa um registro de presença na academia
  - id: identificador único
  - date: data e hora do check-in (timestamp completo)
  - notes: observações opcionais (String)
  - workoutSession: relacionamento opcional com WorkoutSession (se fez treino após check-in)

- **HomeViewModel** (se necessário): Agrega dados de múltiplas fontes
  - Plano ativo (WorkoutPlan com isActive = true)
  - Último treino completado (WorkoutSession mais recente)
  - Status de check-in do dia
  - Sequência atual de check-ins

- **CheckInViewModel**: Gerencia lógica de check-ins
  - Cálculo de sequência atual
  - Cálculo de melhor sequência
  - Estatísticas mensais
  - Validação de check-in único por dia

- **ProgressViewModel**: Gerencia histórico de treinos e exercícios
  - Lista de WorkoutSessions
  - Lista de exercícios executados
  - Cálculo de recordes pessoais
  - Agregação de estatísticas

## Success Criteria *(mandatory)*

### Measurable Outcomes

- **SC-001**: Usuário consegue fazer check-in completo em menos de 3 segundos (abrir tab + tocar botão)
- **SC-002**: Sistema calcula sequência de check-ins corretamente em 100% dos casos testados (dias consecutivos vs. dias pulados)
- **SC-003**: Home Dashboard carrega todas as informações em menos de 1 segundo, mesmo com 50+ treinos no histórico
- **SC-004**: Usuário consegue navegar entre as 4 tabs sem lag ou travamento (60fps)
- **SC-005**: Histórico de treinos exibe corretamente todos os treinos completados nos últimos 6 meses
- **SC-006**: Recorde pessoal de exercício é identificado corretamente em 100% dos casos (maior peso)
- **SC-007**: Sistema consome menos de 50MB de memória ao exibir histórico completo de 50 treinos
- **SC-008**: Usuário encontra última sessão de treino específico em menos de 5 segundos navegando por histórico
- **SC-009**: 90% dos usuários completam fluxo de check-in na primeira tentativa sem confusão
- **SC-010**: Estatísticas mensais (dias de treino, percentual) são calculadas corretamente para meses com 28, 30 e 31 dias
- **SC-011**: Empty states são informativos e sugerem próxima ação em 100% dos casos onde não há dados
- **SC-012**: App mantém responsividade ao carregar listas de histórico com 100+ registros (não travar UI)

## Scope & Boundaries

### In Scope
- Home Dashboard com cards informativos
- Check-in diário com gamificação (sequências)
- Histórico completo de treinos executados
- Histórico individualizado por exercício
- Navegação por TabView
- Cálculos de estatísticas básicas (sequência, frequência mensal, recordes)
- Empty states para todas as telas

### Out of Scope (futuras versões)
- Gráficos visuais de progresso (v1.1+)
- Notificações push para lembrar de fazer check-in (v1.2+)
- Exportar histórico (CSV, PDF) (v1.2+)
- Comparar treinos lado a lado (v1.3+)
- Metas personalizadas de check-ins (v1.2+)
- Integração com HealthKit (v2.0+)
- Widgets iOS para Home Screen (v1.3+)
- Suporte a iPad (v1.2+)

## Assumptions

1. Usuário já tem WorkoutPlans e WorkoutSessions criados via features 001 e 002
2. SwiftData está configurado e funcionando corretamente
3. Date+Extensions já existe com métodos de formatação relativa (implementado em 001)
4. Usuário usa apenas 1 dispositivo (sem sincronização iCloud no MVP)
5. Check-in não requer localização GPS (apenas timestamp)
6. Sequência de check-ins considera apenas dias consecutivos (não conta treinos, apenas presença)
7. "Melhor sequência" persiste mesmo após resets de sequência atual
8. Histórico considera apenas sessões com isCompleted = true
9. Recorde pessoal é baseado em peso máximo (não volume total ou 1RM calculado)
10. App funciona offline 100% (sem necessidade de conexão)
11. Estatísticas mensais usam mês calendário (1º a último dia do mês)
12. Tempo relativo usa convenções: "Há X horas", "Ontem", "Há X dias"

## Dependencies

### Internal Dependencies
- Feature 001 (Workout Plan Management): Precisa de WorkoutPlan model com isActive
- Feature 002 (Execute Workout): Precisa de WorkoutSession e ExerciseSet models
- Date+Extensions: Métodos de formatação relativa já implementados
- MuscleGroup enum: Para exibir ícones coloridos no histórico de exercícios

### External Dependencies
- SwiftUI framework (iOS 17.0+)
- SwiftData framework
- Foundation (Date, Calendar para cálculos de data)

### Technical Constraints
- iOS 17.0+ (SwiftData requer iOS 17)
- Zero dependências de terceiros
- Funcionar completamente offline

## Non-Functional Requirements

- **Performance**: Listas de histórico devem carregar em < 1 segundo para 50+ registros
- **Usabilidade**: Todas as ações principais (check-in, navegar tabs, ver histórico) devem ser acessíveis em 2 toques ou menos
- **Acessibilidade**: Todos os elementos interativos devem ter labels descritivos para VoiceOver
- **Design**: Seguir Human Interface Guidelines da Apple, usar componentes nativos SwiftUI
- **Consistência**: Manter padrão visual estabelecido em features 001 e 002

## Open Questions

Nenhuma. Especificação está completa e pronta para planejamento.
