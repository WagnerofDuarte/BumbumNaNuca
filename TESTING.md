# Guia de Teste Manual - Gerenciamento de Planos de Treino

## Funcionalidades Implementadas

### ✅ US1 - Criar Plano de Treino
- [x] Botão "+" na lista de planos
- [x] Formulário com nome (obrigatório) e descrição (opcional)
- [x] Validação de nome vazio
- [x] Botões Cancelar/Criar

**Passos para testar:**
1. Abra o app (lista vazia deve mostrar tela de estado vazio)
2. Toque em "Criar Plano" ou no botão "+"
3. Digite um nome (ex: "Treino A")
4. Opcionalmente adicione descrição
5. Toque em "Criar"
6. Verifique se o plano aparece na lista

### ✅ US2 - Listar Planos de Treino
- [x] Lista ordenada por data de criação (mais recente primeiro)
- [x] Busca por nome ou descrição
- [x] Badge "ATIVO" para plano ativo
- [x] Contador de exercícios
- [x] Data relativa de criação ("Há 2 dias", "Hoje")
- [x] Estado vazio com ação "Criar Plano"
- [x] Swipe para deletar

**Passos para testar:**
1. Crie múltiplos planos
2. Verifique ordenação (mais recente no topo)
3. Use a barra de busca para filtrar
4. Toque em um plano para ver detalhes
5. Deslize para deletar um plano

### ✅ US3 - Visualizar Detalhes do Plano
- [x] Nome e descrição do plano
- [x] Badge "ATIVO" se aplicável
- [x] Contador de exercícios
- [x] Data de criação
- [x] Lista de exercícios (vazia inicialmente)
- [x] Botão "+" para adicionar exercício
- [x] Menu "..." com opções Editar e Excluir

**Passos para testar:**
1. Toque em um plano na lista
2. Verifique informações exibidas
3. Toque em "+" para adicionar exercício
4. Toque em "..." para ver menu de opções

### ✅ US4 - Editar Plano de Treino
- [x] Formulário pré-preenchido com dados atuais
- [x] Validação de nome
- [x] Botões Cancelar/Salvar
- [x] Alterações refletidas imediatamente

**Passos para testar:**
1. Na tela de detalhes, toque em "..." → "Editar Plano"
2. Modifique nome ou descrição
3. Toque em "Salvar"
4. Verifique se mudanças aparecem na lista e detalhes

### ✅ US5 - Ativar Plano de Treino
- [x] Botão "Ativar Plano" quando inativo
- [x] Botão "Desativar Plano" quando ativo
- [x] Apenas um plano ativo por vez
- [x] Badge visual "ATIVO"

**Passos para testar:**
1. Crie 2+ planos
2. Na tela de detalhes de um plano, toque em "Ativar Plano"
3. Verifique badge "ATIVO" na lista
4. Ative outro plano
5. Verifique que o anterior foi desativado automaticamente

### ✅ US6 - Excluir Plano de Treino
- [x] Opção no menu "..."
- [x] Alerta de confirmação
- [x] Exclusão em cascata de exercícios
- [x] Swipe to delete na lista

**Passos para testar:**
1. Na tela de detalhes, toque em "..." → "Excluir Plano"
2. Confirme exclusão no alerta
3. Verifique que voltou para lista sem o plano
4. OU: Na lista, deslize um plano para esquerda e toque em "Delete"

### ✅ Adicionar Exercício ao Plano
- [x] Formulário com nome, grupo muscular, séries, reps, descanso
- [x] Validações (nome obrigatório, valores positivos)
- [x] Steppers para séries (1-10), reps (1-50), descanso (15-300s)
- [x] Dica de descanso recomendado
- [x] Exercício aparece na lista do plano

**Passos para testar:**
1. Na tela de detalhes, toque em "+"
2. Preencha nome (ex: "Supino Reto")
3. Selecione grupo muscular (ex: "Peito")
4. Ajuste séries/reps/descanso
5. Toque em "Adicionar"
6. Verifique exercício na lista com ícone colorido

## Checklist de Validação Rápida

- [ ] Lista vazia mostra estado vazio com botão "Criar Plano"
- [ ] Criar plano com nome vazio é bloqueado
- [ ] Busca filtra planos corretamente
- [ ] Navegação entre telas funciona suavemente
- [ ] Ativar plano desativa o anterior automaticamente
- [ ] Deletar plano remove seus exercícios
- [ ] Editar plano atualiza dados em tempo real
- [ ] Exercícios aparecem com ícones coloridos por grupo muscular
- [ ] SwiftData persiste dados (feche e reabra o app)

## Grupos Musculares e Cores

- 🔵 Peito (Azul)
- 🟢 Costas (Verde)
- 🟣 Pernas (Roxo)
- 🟠 Ombros (Laranja)
- 🔴 Braços (Vermelho)
- 🟡 Abdômen (Amarelo)
- 🩷 Cardio (Rosa)

## Casos de Borda Testados

✅ Plano vazio (sem exercícios) é válido
✅ Cancelar edição descarta alterações
✅ Deletar plano ativo não ativa outro automaticamente
✅ Busca vazia mostra "sem resultados"
✅ Nome com espaços em branco é rejeitado

## Próximas Funcionalidades (Não Implementadas)

- [ ] Reordenar exercícios (drag & drop)
- [ ] Editar exercícios existentes
- [ ] Deletar exercícios individuais
- [ ] Botão "Iniciar Treino"
- [ ] Histórico de execuções
- [ ] Filtros por grupo muscular

---

**Status**: MVP completo e funcional ✅
**Data**: 07/01/2026
**Versão**: 1.0.0
