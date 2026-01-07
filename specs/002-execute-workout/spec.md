# Feature Specification: Executar Treino

**Feature Branch**: `002-execute-workout`  
**Created**: 2026-01-07  
**Status**: Draft  
**Input**: User description: "Executar Treino - Permitir que usuários iniciem e executem sessões de treino, registrando pesos e repetições para cada série, usando timer de descanso entre séries, e finalizando com resumo do treino"

## Clarifications

### Session 2026-01-07

- Q: Quando o usuário está executando séries de um exercício, como o sistema deve determinar que um exercício está "completo"? → A: Baseado no número de séries configurado, mas usuário pode marcar exercício como completo a qualquer momento
- Q: Quando o usuário visualiza dados do último treino para um exercício, o sistema deve mostrar dados de qual sessão anterior? → A: Última sessão completa do mesmo plano de treino
- Q: Quando o usuário tenta iniciar uma nova sessão de treino mas já existe uma sessão em andamento (não finalizada), qual deve ser o comportamento do sistema? → A: Avisar e oferecer retomar sessão existente ou abandoná-la para iniciar nova
- Q: Quando o timer de descanso está ativo e o usuário decide registrar a próxima série antes do timer terminar, o que deve acontecer com o timer? → A: Cancelar automaticamente o timer
- Q: Quando o usuário registra valores inválidos (ex: peso negativo ou zero repetições), como o sistema deve comunicar o erro? → A: Validar em tempo real ao digitar com feedback visual inline

## User Scenarios & Testing *(mandatory)*

### User Story 1 - Iniciar e Completar Sessão de Treino Básica (Priority: P1)

Um usuário quer executar seu plano de treino, registrando o peso e repetições de cada série dos exercícios planejados.

**Why this priority**: Este é o fluxo principal da funcionalidade e representa o valor essencial - sem isso, não há execução de treino. É a jornada mínima viável que entrega valor ao usuário.

**Independent Test**: Pode ser totalmente testado criando um plano com 1-2 exercícios, iniciando a sessão, registrando séries para cada exercício, e finalizando o treino. Entrega o valor fundamental de rastreamento de treino.

**Acceptance Scenarios**:

1. **Given** um usuário tem um plano de treino salvo com exercícios, **When** ele toca "Iniciar Treino" no plano, **Then** uma nova sessão de treino é criada e ele vê a lista de exercícios para executar
2. **Given** uma sessão de treino está em andamento, **When** o usuário seleciona um exercício, **Then** ele vê a interface para registrar séries com campos para peso e repetições
3. **Given** o usuário está registrando uma série, **When** ele insere peso (ou deixa vazio para peso corporal) e número de repetições válidos e confirma, **Then** a série é salva e aparece no histórico da sessão
4. **Given** o usuário completou todas as séries de todos os exercícios, **When** ele finaliza o treino, **Then** a sessão é marcada como completa e ele vê um resumo com duração, total de exercícios, séries e repetições

---

### User Story 2 - Timer de Descanso entre Séries (Priority: P2)

Um usuário quer usar um timer automático entre séries para manter intervalos de descanso consistentes sem precisar olhar o relógio.

**Why this priority**: Melhora significativamente a experiência de treino ao automatizar o controle de descanso, mas o treino ainda pode ser completado sem isso (usuário pode usar timer externo ou contar mentalmente).

**Independent Test**: Pode ser testado independentemente configurando um exercício com tempo de descanso padrão, completando uma série, e verificando se o timer inicia automaticamente e notifica ao término.

**Acceptance Scenarios**:

1. **Given** o usuário completou uma série e não é a última série do exercício, **When** a série é confirmada, **Then** um timer de descanso inicia automaticamente com a duração configurada para aquele exercício
2. **Given** o timer de descanso está ativo, **When** ele alcança zero, **Then** o sistema vibra e emite som breve (respeitando modo silencioso) para notificar o usuário
3. **Given** o timer de descanso está em andamento, **When** o usuário decide pular ou pausar, **Then** o sistema permite pausar/retomar ou pular o descanso imediatamente
4. **Given** o timer de descanso está ativo, **When** o usuário minimiza o app, **Then** o timer continua funcionando em background por até 3 minutos

---

### User Story 3 - Visualizar Dados do Último Treino (Priority: P2)

Um usuário quer ver os dados (peso e repetições) do mesmo exercício do último treino para saber o que fazer na sessão atual.

**Why this priority**: Essencial para progressão - usuários precisam saber o que fizeram antes para aumentar gradualmente a carga. Sem isso, eles precisariam lembrar de memória ou consultar histórico separadamente.

**Independent Test**: Pode ser testado executando um treino com valores específicos, depois iniciando uma nova sessão do mesmo plano e verificando se os valores anteriores aparecem como referência.

**Acceptance Scenarios**:

1. **Given** o usuário executou o mesmo exercício em uma sessão anterior, **When** ele abre a tela de registro de série, **Then** ele vê os dados da última execução (ex: "Último: 80kg × 10 reps")
2. **Given** é a primeira vez executando o exercício, **When** o usuário abre a tela de registro, **Then** nenhum dado anterior é mostrado
3. **Given** o usuário está vendo dados do último treino, **When** ele registra uma nova série, **Then** os campos são independentes e não preenchidos automaticamente (usuário decide se aumenta/mantém)

---

### User Story 4 - Acompanhar Progresso Durante Sessão (Priority: P3)

Um usuário quer ver claramente quais exercícios já completou e quais faltam durante a sessão de treino.

**Why this priority**: Melhora orientação e motivação, mas não é crítico - usuário ainda pode completar o treino percorrendo a lista sequencialmente.

**Independent Test**: Pode ser testado iniciando um treino com múltiplos exercícios e verificando se a interface mostra claramente status (completo/em andamento/pendente) e progresso geral.

**Acceptance Scenarios**:

1. **Given** uma sessão de treino está ativa, **When** o usuário visualiza a lista de exercícios, **Then** ele vê indicadores visuais distintos para exercícios completos, em andamento e pendentes
2. **Given** o usuário está executando um treino, **When** ele completa um exercício, **Then** um contador de progresso é atualizado (ex: "3/8 exercícios completos")
3. **Given** o usuário está registrando séries de um exercício, **When** ele visualiza a tela do exercício, **Then** ele vê indicador da série atual (ex: "Série 2 de 4")

---

### User Story 5 - Gerenciar Sessão Incompleta (Priority: P3)

Um usuário precisa interromper o treino antes de completar todos os exercícios (por falta de tempo, equipamento ocupado, etc.) e quer que o progresso parcial seja salvo.

**Why this priority**: Situação real mas não frequente. Melhor ter a opção, mas não é crítico para MVP - dados já estão sendo salvos incrementalmente.

**Independent Test**: Pode ser testado iniciando um treino, completando apenas alguns exercícios/séries, e saindo do app ou cancelando a sessão, depois verificando se os dados parciais foram preservados.

**Acceptance Scenarios**:

1. **Given** o usuário está no meio de uma sessão de treino, **When** ele sai da tela de execução sem finalizar, **Then** todas as séries já registradas são salvas
2. **Given** o usuário tem uma sessão incompleta, **When** ele finaliza a sessão mesmo sem completar todos os exercícios, **Then** a sessão é marcada como completa com os dados registrados até aquele momento
3. **Given** o usuário completou apenas 2 de 4 séries de um exercício, **When** ele move para o próximo exercício ou finaliza, **Then** as 2 séries são salvas e contabilizadas no resumo

---

### Edge Cases

- Como o sistema lida se o usuário deixa uma sessão aberta por horas ou dias sem finalizar?
- Como o sistema se comporta se o usuário força o fechamento do app durante uma sessão ativa?
- O que acontece se o timer de descanso está ativo e o dispositivo fica sem bateria?
- Como o sistema lida com exercícios que não têm tempo de descanso configurado?
- O que acontece se o usuário tentar registrar uma série sem inserir peso nem repetições?

## Requirements *(mandatory)*

### Functional Requirements

- **FR-001**: Sistema DEVE permitir iniciar uma sessão de treino a partir de um plano de treino existente
- **FR-002**: Sistema DEVE criar um registro de sessão com data/hora de início quando o treino é iniciado
- **FR-003**: Usuários DEVEM poder visualizar todos os exercícios do plano durante a execução
- **FR-004**: Sistema DEVE permitir registrar peso e número de repetições para cada série de cada exercício
- **FR-005**: Sistema DEVE aceitar valores de peso como número decimal positivo ou vazio (para peso corporal)
- **FR-006**: Sistema DEVE aceitar apenas números inteiros positivos maiores que zero para repetições
- **FR-007**: Sistema DEVE salvar cada série imediatamente após confirmação (persistência incremental)
- **FR-008**: Sistema DEVE mostrar dados da última sessão completa do mesmo plano de treino para o exercício sendo executado quando disponível
- **FR-009**: Sistema DEVE iniciar timer de descanso automaticamente após completar uma série (exceto última série do exercício)
- **FR-010**: Timer de descanso DEVE usar a duração configurada no exercício (padrão: 60 segundos)
- **FR-011**: Timer DEVE emitir feedback haptico (vibração) ao atingir zero
- **FR-012**: Timer DEVE emitir som breve ao atingir zero (respeitando modo silencioso do dispositivo)
- **FR-013**: Sistema DEVE permitir pausar, retomar e pular o timer de descanso a qualquer momento
- **FR-014**: Timer DEVE continuar executando em background por até 3 minutos após app minimizado
- **FR-015**: Sistema DEVE cancelar automaticamente o timer de descanso se o usuário iniciar registro de nova série antes do timer terminar
- **FR-016**: Sistema DEVE permitir finalizar a sessão a qualquer momento, mesmo com treino incompleto
- **FR-017**: Sistema DEVE calcular e exibir resumo da sessão ao finalizar: duração total, exercícios completados, total de séries, total de repetições
- **FR-018**: Sistema DEVE marcar sessão como completa e registrar data/hora de término ao finalizar
- **FR-019**: Sistema DEVE mostrar indicadores visuais de status para cada exercício (completo/em andamento/pendente)
- **FR-020**: Sistema DEVE exibir contador de progresso geral da sessão (ex: "3/8 exercícios completos")
- **FR-021**: Sistema DEVE exibir indicador da série atual durante registro (ex: "Série 2 de 4")
- **FR-022**: Sistema DEVE validar inputs numéricos em tempo real enquanto usuário digita
- **FR-023**: Sistema DEVE exibir feedback visual inline (ex: borda vermelha, mensagem abaixo do campo) quando valores inválidos são detectados
- **FR-024**: Sistema DEVE impedir salvamento de séries com valores inválidos (peso negativo, zero ou menos repetições)
- **FR-025**: Sistema DEVE detectar quando já existe uma sessão não finalizada ao tentar iniciar nova sessão do mesmo plano
- **FR-026**: Sistema DEVE exibir aviso ao usuário quando detectar sessão existente, oferecendo opções: retomar sessão existente ou abandoná-la e iniciar nova
- **FR-027**: Sistema DEVE preservar dados de séries registradas mesmo se sessão não for finalizada formalmente
- **FR-028**: Sistema DEVE permitir ao usuário marcar um exercício como completo a qualquer momento, independente do número de séries registradas versus séries configuradas
- **FR-029**: Sistema DEVE indicar visualmente quando o usuário atingiu o número de séries configuradas para o exercício, mas permitir continuar adicionando mais séries se desejado

### Key Entities

- **WorkoutSession**: Representa uma sessão de treino executada, contendo data/hora de início, data/hora de término (opcional), status de conclusão, e referência ao plano de treino usado. Relaciona-se com múltiplas séries (ExerciseSet).

- **ExerciseSet**: Representa uma série individual executada, contendo número da série, peso usado (opcional para peso corporal), número de repetições, data/hora de conclusão, e observações opcionais. Relaciona-se com um exercício específico e uma sessão de treino.

- **Exercise**: (Entidade existente) Fornece configurações padrão para execução: número padrão de séries, repetições, e tempo de descanso entre séries.

## Dependencies & Assumptions

### Dependencies

- **DEP-001**: Feature "Gerenciamento de Planos de Treino" deve estar implementada (usuários precisam ter planos criados para executar)
- **DEP-002**: Modelos de dados WorkoutPlan, Exercise devem existir e estar persistindo corretamente
- **DEP-003**: Dispositivo deve suportar feedback haptico e áudio para notificações do timer

### Assumptions

- **ASM-001**: Usuários executam treinos em ambientes com boa conectividade (dados salvam localmente, sem necessidade de sincronização em nuvem)
- **ASM-002**: Tempo médio de descanso entre séries varia de 30 a 180 segundos conforme padrões de academia
- **ASM-003**: Usuários podem querer usar peso corporal (sem adicionar peso externo) para alguns exercícios
- **ASM-004**: Sessões de treino típicas duram entre 30 minutos e 2 horas
- **ASM-005**: Usuários querem comparação com treino anterior para saber se estão progredindo
- **ASM-006**: Timer em background é suficiente até 3 minutos (tempo máximo de descanso razoável)
- **ASM-007**: Usuários podem precisar abandonar treino parcialmente por razões válidas (equipamento ocupado, emergências)

## Success Criteria *(mandatory)*

### Measurable Outcomes

- **SC-001**: Usuários conseguem completar um treino completo (iniciar, registrar todas as séries, finalizar) em menos de 45 minutos para um treino típico de 8 exercícios
- **SC-002**: 95% das séries são registradas com sucesso na primeira tentativa sem erros de validação
- **SC-003**: Timer de descanso possui precisão de ±2 segundos em relação ao tempo configurado
- **SC-004**: 90% dos usuários conseguem visualizar dados do último treino sem confusão ou necessidade de ajuda
- **SC-005**: Sistema preserva 100% dos dados de séries registradas mesmo em caso de fechamento inesperado do app
- **SC-006**: Feedback haptico e sonoro do timer são percebidos por 95% dos usuários em ambiente de academia típico
- **SC-007**: Interface de execução permite registrar uma série completa (selecionar exercício, inserir dados, confirmar) em menos de 30 segundos
- **SC-008**: Resumo final de treino apresenta dados precisos (0% de discrepância) em relação às séries registradas
