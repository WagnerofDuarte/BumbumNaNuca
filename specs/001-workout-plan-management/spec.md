# Feature Specification: Gerenciamento de Planos de Treino

**Feature Branch**: `001-workout-plan-management`  
**Created**: 6 de Janeiro de 2026  
**Status**: Draft  
**Input**: User description: "Gerenciamento de Planos de Treino - permitir criar, editar, listar e deletar planos de treino manualmente com exercícios"

## Clarifications

### Session 2026-01-06

- Q: Quando o usuário está editando um plano, em que momento as mudanças são salvas? → A: Salvar explícito (botão Salvar/Cancelar no final)
- Q: Quando o usuário deleta um plano que está marcado como "Ativo", o que acontece com o status de ativo? → A: Nenhum plano fica ativo automaticamente (usuário escolhe depois)
- Q: Qual o comportamento quando o usuário tenta criar um plano sem adicionar nenhum exercício? → A: Permitir salvar plano vazio (0 exercícios é válido)
- Q: Quando o usuário está visualizando a lista de exercícios de um plano, o tempo de descanso deve ser exibido? → A: Não exibir na lista, apenas durante execução
- Q: Quando o usuário reordena exercícios com drag & drop durante a edição, mas depois clica em "Cancelar", a nova ordem deve ser descartada? → A: Sim, descartar a nova ordem

## User Scenarios & Testing *(mandatory)*

### User Story 1 - Criar Plano de Treino Manualmente (Priority: P1)

Um usuário que deseja organizar sua rotina de academia precisa criar um novo plano de treino do zero, dando um nome ao plano e adicionando exercícios específicos com suas séries, repetições e grupos musculares.

**Why this priority**: Esta é a funcionalidade central e ponto de entrada obrigatório. Sem a capacidade de criar planos, nenhuma outra funcionalidade pode ser usada. É o primeiro passo essencial para qualquer usuário começar a usar o aplicativo.

**Independent Test**: Pode ser completamente testado criando um novo plano com nome "Treino A", adicionando 3 exercícios (Supino, Agachamento, Rosca), e verificando que o plano é salvo e aparece na lista. Entrega valor imediato ao permitir que o usuário organize seus treinos.

**Acceptance Scenarios**:

1. **Given** o usuário está na tela de listagem de treinos sem nenhum plano criado, **When** toca no botão "+" e preenche o nome "Treino de Peito" e adiciona "Supino Reto" (4 séries x 10 reps, Peito) como exercício, **Then** o plano é salvo e aparece na lista com "1 exercício"

2. **Given** o usuário está criando um novo plano, **When** tenta salvar sem preencher o nome do plano, **Then** o sistema mostra mensagem de erro "Nome do plano é obrigatório" e não permite salvar

3. **Given** o usuário está criando um novo plano "Treino B", **When** adiciona 5 exercícios diferentes com grupos musculares variados, **Then** todos os exercícios são salvos na ordem correta e o plano mostra "5 exercícios"

4. **Given** o usuário está adicionando um exercício ao plano, **When** preenche apenas o nome "Agachamento" e seleciona grupo muscular "Pernas", **Then** o exercício é adicionado com valores padrão de 3 séries x 12 repetições e 60 segundos de descanso

---

### User Story 2 - Visualizar e Listar Planos Existentes (Priority: P1)

Um usuário que já possui planos de treino criados precisa visualizar rapidamente todos os seus planos, identificar qual está ativo, ver quantos exercícios cada plano possui e quando foi o último treino executado.

**Why this priority**: Sem a capacidade de visualizar planos existentes, o usuário não pode acessar seus treinos criados para executá-los ou editá-los. É essencial para a usabilidade básica do app.

**Independent Test**: Após criar 2 ou 3 planos diferentes, navegar para a aba "Treinos" e verificar que todos os planos aparecem com seus nomes, número de exercícios, e badge "Ativo" no plano marcado como ativo. Entrega valor ao permitir organização visual dos treinos.

**Acceptance Scenarios**:

1. **Given** o usuário possui 3 planos salvos ("Treino A", "Treino B", "Treino C"), **When** abre a aba "Treinos", **Then** todos os 3 planos aparecem na lista ordenados pela data de criação (mais recente primeiro)

2. **Given** o usuário não possui nenhum plano criado, **When** abre a aba "Treinos", **Then** vê um estado vazio com ícone e mensagem "Nenhum plano criado" e botão para criar o primeiro plano

3. **Given** o usuário possui um plano marcado como "Ativo", **When** visualiza a lista de planos, **Then** o plano ativo exibe um badge destacado com o texto "Ativo"

4. **Given** o usuário possui um plano que foi executado há 2 dias, **When** visualiza a lista, **Then** o card do plano mostra "Última execução: Há 2 dias"

---

### User Story 3 - Ver Detalhes do Plano com Lista de Exercícios (Priority: P1)

Um usuário que deseja revisar o conteúdo de um plano antes de iniciar o treino precisa ver todos os exercícios incluídos no plano, seus grupos musculares, séries e repetições planejadas.

**Why this priority**: Essencial para o usuário confirmar o conteúdo do plano antes de executar e decidir se precisa fazer ajustes. Também é o caminho para iniciar um treino.

**Independent Test**: Criar um plano com 4 exercícios variados, depois tocar no plano na lista e verificar que todos os 4 exercícios aparecem com seus detalhes corretos (nome, grupo muscular tag colorida, séries x reps). Entrega valor ao dar transparência do conteúdo.

**Acceptance Scenarios**:

1. **Given** o usuário está na lista de planos, **When** toca em um plano chamado "Treino de Pernas", **Then** abre a tela de detalhes mostrando o nome do plano no topo e a lista completa de exercícios abaixo

2. **Given** o usuário está vendo detalhes de um plano com 5 exercícios, **When** visualiza a lista de exercícios, **Then** cada exercício mostra nome, grupo muscular com tag colorida (ex: "Pernas" em azul), e formato "4 x 10" para séries e repetições

3. **Given** o usuário está vendo detalhes de um plano, **When** verifica o toolbar, **Then** vê opções para "Editar" e "Marcar como Ativo/Inativo"

4. **Given** o usuário está vendo detalhes de um plano, **When** toca no botão destacado "Iniciar Treino", **Then** o sistema cria uma nova sessão de treino e navega para a tela de execução

---

### User Story 4 - Editar Plano Existente (Priority: P2)

Um usuário que criou um plano mas percebeu que precisa ajustar exercícios, mudar a ordem ou atualizar séries/repetições, precisa editar o plano sem ter que recriá-lo do zero.

**Why this priority**: Importante para adaptação dos treinos conforme evolução do usuário, mas não bloqueia o uso inicial. O usuário pode começar criando planos novos se necessário.

**Independent Test**: Criar um plano, depois editá-lo mudando o nome, adicionando 2 novos exercícios, removendo 1 exercício existente, e salvando. Verificar que as mudanças persistem. Entrega valor ao permitir refinamento contínuo.

**Acceptance Scenarios**:

1. **Given** o usuário está vendo detalhes de um plano "Treino A", **When** toca no botão "Editar", **Then** abre o formulário de edição com todos os campos preenchidos com os valores atuais

2. **Given** o usuário está editando um plano, **When** adiciona um novo exercício "Desenvolvimento" e remove um exercício existente "Elevação Lateral" via swipe-to-delete, **Then** as mudanças são aplicadas e o plano atualizado mostra a nova lista de exercícios

3. **Given** o usuário está editando um plano com 5 exercícios, **When** reordena os exercícios usando drag & drop (movendo o 3º exercício para ser o 1º), **Then** a nova ordem é salva e persiste ao visualizar o plano novamente

4. **Given** o usuário está editando um plano, **When** muda o nome de "Treino A" para "Treino de Peito Completo", **Then** o novo nome aparece na lista de planos e na tela de detalhes

5. **Given** o usuário está editando um plano, **When** toca em "Cancelar" após fazer mudanças (incluindo reordenação de exercícios), **Then** todas as mudanças são descartadas e o plano permanece com os valores originais

6. **Given** o usuário está editando um plano e fez várias mudanças, **When** toca no botão "Salvar", **Then** todas as mudanças (nome, descrição, exercícios adicionados/removidos/reordenados) são persistidas permanentemente

---

### User Story 5 - Marcar Plano como Ativo (Priority: P2)

Um usuário que está seguindo um plano específico no momento deseja marcá-lo como "Ativo" para identificá-lo rapidamente e destacá-lo na tela inicial.

**Why this priority**: Melhora a experiência ao dar destaque ao plano atual, mas o usuário pode trabalhar sem isso simplesmente lembrando qual plano usar.

**Independent Test**: Criar 3 planos, marcar o "Treino B" como ativo, e verificar que apenas ele mostra o badge "Ativo" na lista e aparece destacado na Home. Entrega valor ao facilitar identificação do treino atual.

**Acceptance Scenarios**:

1. **Given** o usuário possui 3 planos e nenhum está marcado como ativo, **When** marca "Treino B" como ativo, **Then** "Treino B" recebe o badge "Ativo" e aparece no card "Plano Ativo" da Home

2. **Given** o usuário possui um plano já marcado como ativo ("Treino A"), **When** marca outro plano ("Treino C") como ativo, **Then** "Treino A" perde o badge "Ativo" e apenas "Treino C" fica ativo (somente um pode estar ativo por vez)

3. **Given** o usuário está vendo detalhes de um plano não ativo, **When** toca na opção "Marcar como Ativo", **Then** o plano recebe o badge e outros planos perdem o status de ativo

---

### User Story 6 - Deletar Plano (Priority: P3)

Um usuário que não usa mais um plano específico ou criou um plano por engano deseja removê-lo permanentemente da lista.

**Why this priority**: Útil para manutenção e organização, mas não é crítico para a funcionalidade principal. Pode ser adicionado depois se necessário.

**Independent Test**: Criar um plano de teste, depois deletá-lo via swipe-to-delete ou botão, confirmar a exclusão, e verificar que ele desaparece da lista permanentemente. Entrega valor ao manter a lista organizada.

**Acceptance Scenarios**:

1. **Given** o usuário está na lista de planos com 4 planos criados, **When** faz swipe-to-delete em um plano e confirma a exclusão, **Then** o plano é removido permanentemente e a contagem passa para 3 planos

2. **Given** o usuário inicia ação de deletar um plano, **When** o sistema solicita confirmação, **Then** mostra um alerta com mensagem "Tem certeza que deseja deletar este plano? Esta ação não pode ser desfeita" com opções "Cancelar" e "Deletar"

3. **Given** o usuário deleta um plano que possui sessões de treino executadas associadas, **When** confirma a exclusão, **Then** o plano é deletado mas o histórico de treinos executados é preservado

4. **Given** o usuário deleta o único plano marcado como "Ativo", **When** confirma a exclusão, **Then** o plano é deletado e nenhum outro plano fica automaticamente ativo (usuário deve marcar manualmente outro plano se desejar)

---

### Edge Cases

- O que acontece quando o usuário tenta criar um plano com nome vazio ou apenas espaços em branco?
- O que acontece quando o usuário tenta adicionar mais de 50 exercícios a um único plano?
- O que acontece quando o usuário cria um exercício com valores extremos (999 séries ou 999 repetições)?
- Como o sistema lida quando o usuário deleta o único plano marcado como "Ativo"? → **CLARIFICADO**: Nenhum plano fica ativo automaticamente
- O que acontece se o usuário força fechar o app enquanto está editando um plano? → **CLARIFICADO**: Mudanças não salvas são perdidas (salvar explícito)
- Como o sistema se comporta quando não há espaço de armazenamento suficiente para salvar um novo plano?
- O que acontece quando o usuário tenta editar um plano que foi deletado em outro dispositivo (se houver sincronização futura)?
- Como o sistema lida com nomes de plano muito longos (mais de 100 caracteres)?

## Requirements *(mandatory)*

### Functional Requirements

- **FR-001**: O sistema DEVE permitir que usuários criem novos planos de treino fornecendo um nome obrigatório

- **FR-002**: O sistema DEVE validar que o nome do plano possui no mínimo 3 caracteres antes de permitir salvar

- **FR-003**: O sistema DEVE permitir que usuários adicionem uma descrição opcional ao plano (máximo 500 caracteres)

- **FR-004**: O sistema DEVE permitir adicionar entre 0 e 50 exercícios a um plano de treino (planos vazios são válidos)

- **FR-005**: O sistema DEVE exigir que cada exercício tenha nome obrigatório e grupo muscular selecionado

- **FR-006**: O sistema DEVE fornecer 7 opções de grupo muscular: Peito, Costas, Pernas, Ombros, Braços, Abdômen, Cardio

- **FR-007**: O sistema DEVE permitir configurar para cada exercício: número de séries (1-10, padrão 3), número de repetições (1-50, padrão 12), e tempo de descanso (opções: 30s, 60s, 90s, 120s, 180s)

- **FR-008**: O sistema DEVE salvar todos os planos de treino persistentemente usando o mecanismo de armazenamento local

- **FR-009**: O sistema DEVE exibir lista de todos os planos criados ordenados por data de criação (mais recente primeiro)

- **FR-010**: O sistema DEVE exibir para cada plano na lista: nome, número de exercícios, badge "Ativo" (se aplicável), e data da última execução (se houver)

- **FR-011**: O sistema DEVE mostrar um estado vazio informativo quando não há planos criados, com opção clara para criar o primeiro plano

- **FR-012**: O sistema DEVE permitir visualizar detalhes de um plano mostrando lista completa de exercícios com suas configurações

- **FR-013**: O sistema DEVE exibir cada exercício na lista mostrando: nome, grupo muscular (com tag colorida visual), e séries x repetições (tempo de descanso não é exibido na lista, apenas durante execução)

- **FR-014**: O sistema DEVE permitir editar planos existentes modificando nome, descrição, e lista de exercícios

- **FR-015**: O sistema DEVE permitir adicionar novos exercícios a um plano durante edição

- **FR-016**: O sistema DEVE permitir editar exercícios existentes em um plano

- **FR-017**: O sistema DEVE permitir remover exercícios de um plano via swipe-to-delete

- **FR-018**: O sistema DEVE permitir reordenar exercícios dentro de um plano via drag & drop

- **FR-019**: O sistema DEVE fornecer botões explícitos "Salvar" e "Cancelar" durante edição. Mudanças (incluindo reordenação) só são persistidas ao tocar "Salvar". Tocar "Cancelar" descarta todas as mudanças.

- **FR-020**: O sistema DEVE permitir marcar apenas um plano como "Ativo" por vez

- **FR-021**: O sistema DEVE automaticamente desmarcar o plano anteriormente ativo quando outro plano é marcado como ativo

- **FR-022**: O sistema DEVE exibir badge visual "Ativo" apenas no plano marcado como ativo

- **FR-023**: O sistema DEVE permitir deletar planos existentes

- **FR-024**: O sistema DEVE solicitar confirmação antes de deletar um plano

- **FR-025**: O sistema DEVE preservar histórico de treinos executados mesmo após deletar o plano associado

- **FR-026**: O sistema DEVE fornecer botão "Iniciar Treino" nos detalhes do plano que cria nova sessão de treino

- **FR-027**: O sistema DEVE validar que descrição do plano não excede 500 caracteres

- **FR-028**: O sistema DEVE validar que número de séries está entre 1 e 10

- **FR-029**: O sistema DEVE validar que número de repetições está entre 1 e 50

- **FR-030**: O sistema DEVE manter a ordem dos exercícios conforme definida pelo usuário

- **FR-031**: O sistema NÃO DEVE marcar automaticamente outro plano como ativo quando o plano ativo é deletado (usuário deve escolher manualmente)

### Key Entities

- **Plano de Treino**: Representa um programa de treino nomeado. Atributos essenciais: identificador único, nome do plano, descrição opcional, data de criação, indicador se está ativo, lista de exercícios associados, histórico de sessões executadas

- **Exercício**: Representa um exercício individual dentro de um plano. Atributos essenciais: identificador único, nome do exercício, grupo muscular (categoria), número padrão de séries, número padrão de repetições, tempo padrão de descanso em segundos, posição/ordem no plano, relacionamento com plano pai

- **Grupo Muscular**: Categoria de classificação dos exercícios. Valores possíveis: Peito, Costas, Pernas, Ombros, Braços, Abdômen, Cardio. Usado para organização e visualização com tags coloridas

## Success Criteria *(mandatory)*

### Measurable Outcomes

- **SC-001**: Usuários conseguem criar um plano de treino completo com 5 exercícios em menos de 3 minutos

- **SC-002**: O aplicativo suporta armazenamento de pelo menos 50 planos diferentes sem degradação de performance

- **SC-003**: 100% dos planos criados são salvos persistentemente e recuperados corretamente após fechar e reabrir o aplicativo

- **SC-004**: 90% dos usuários conseguem encontrar e acessar um plano existente para ver seus exercícios em menos de 5 segundos

- **SC-005**: A interface de listagem de planos carrega e exibe todos os planos em menos de 1 segundo

- **SC-006**: Usuários conseguem editar um plano existente (adicionar, remover ou reordenar exercícios) em menos de 2 minutos

- **SC-007**: A operação de deletar um plano é concluída em menos de 2 segundos após confirmação

- **SC-008**: 100% das validações de entrada (nome mínimo, limites de séries/reps) funcionam corretamente sem permitir dados inválidos

- **SC-009**: A ação de marcar/desmarcar plano como ativo reflete visualmente na interface em menos de 500ms

- **SC-010**: Usuários conseguem distinguir visualmente o plano ativo dos demais em menos de 2 segundos ao olhar a lista
