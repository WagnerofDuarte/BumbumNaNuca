# Documento de Requisitos do Produto (PRD)

## BumbumNaNuca - App de Gerenciamento de Treinos

### Versão: 1.0
### Data: 06 de Janeiro de 2026
### Autor: Equipe BumbumNaNuca

---

## 1. Visão Geral do Produto

### 1.1 Objetivo
Desenvolver um aplicativo iOS nativo que simplifique o gerenciamento de planos de treino de academia, permitindo aos usuários importar, criar, executar e acompanhar seus treinos de forma prática e eficiente.

### 1.2 Problema a Resolver
Usuários de academia frequentemente enfrentam dificuldades para:
- Organizar e seguir planos de treino complexos
- Lembrar pesos e repetições de treinos anteriores
- Manter consistência e frequência na academia
- Executar exercícios corretamente
- Visualizar progresso ao longo do tempo

### 1.3 Público-Alvo
- Praticantes de musculação (iniciantes a avançados)
- Personal trainers que criam planos para clientes
- Pessoas que buscam organização e consistência nos treinos
- Faixa etária: 18-45 anos
- Plataforma: iOS 17.0+

### 1.4 Proposta de Valor
Um aplicativo simples, intuitivo e completo que:
- Elimina a necessidade de papel ou anotações manuais
- Facilita o acompanhamento de progresso
- Ajuda a manter consistência através de check-ins
- Garante execução correta dos exercícios com vídeos
- Otimiza tempo de descanso entre séries

---

## 2. Escopo do Produto

### 2.1 In-Scope (MVP - Versão 1.0)

#### Feature 1: Gerenciamento de Planos de Treino
**User Stories:**
- Como usuário, quero importar meu plano de treino de um PDF para não ter que digitar tudo manualmente
- Como usuário, quero criar um plano de treino do zero adicionando exercícios um por um
- Como usuário, quero editar exercícios importados para corrigir erros ou ajustar informações
- Como usuário, quero visualizar todos os meus planos de treino salvos
- Como usuário, quero ativar/desativar planos para organizar treinos atuais e antigos

**Requisitos Funcionais:**
- RF-001: Sistema deve permitir importação de arquivos PDF
- RF-002: Sistema deve extrair e parsear texto do PDF identificando exercícios
- RF-003: Sistema deve apresentar tela de revisão antes de salvar dados importados
- RF-004: Sistema deve permitir criação manual de planos de treino
- RF-005: Sistema deve permitir adicionar, editar e remover exercícios
- RF-006: Sistema deve permitir reordenar exercícios via drag & drop
- RF-007: Sistema deve permitir marcar um plano como ativo/inativo

**Critérios de Aceitação:**
- ✅ Usuário consegue importar PDF e revisar dados
- ✅ Usuário consegue criar plano manualmente em menos de 2 minutos
- ✅ Usuário consegue editar todos os campos de um exercício
- ✅ Mudanças na ordem são salvas corretamente

#### Feature 2: Vídeos Instrucionais de Exercícios
**User Stories:**
- Como usuário, quero adicionar links de vídeos do YouTube aos exercícios
- Como usuário, quero assistir vídeos dentro do app sem ser redirecionado
- Como usuário, quero pausar e retomar vídeos conforme necessário

**Requisitos Funcionais:**
- RF-008: Sistema deve permitir adicionar URL de vídeo (YouTube) a cada exercício
- RF-009: Sistema deve reproduzir vídeos em player embarcado
- RF-010: Sistema deve manter usuário no app durante reprodução
- RF-011: Sistema deve validar URLs de vídeo antes de salvar

**Critérios de Aceitação:**
- ✅ Vídeos do YouTube tocam dentro do app
- ✅ Controles de play/pause funcionam corretamente
- ✅ Não há redirecionamento para app do YouTube

#### Feature 3: Temporizador de Descanso
**User Stories:**
- Como usuário, quero um timer de descanso entre séries para manter ritmo adequado
- Como usuário, quero ser notificado quando o tempo de descanso terminar
- Como usuário, quero poder pausar ou pular o timer se necessário

**Requisitos Funcionais:**
- RF-012: Sistema deve fornecer timer configurável por exercício
- RF-013: Sistema deve permitir iniciar, pausar, reiniciar e pular timer
- RF-014: Sistema deve vibrar ao término do tempo (haptic feedback)
- RF-015: Sistema deve emitir som ao término do tempo
- RF-016: Sistema deve continuar contagem em background
- RF-017: Sistema deve mostrar progresso visual (circular)

**Critérios de Aceitação:**
- ✅ Timer conta regressivamente de forma precisa
- ✅ Vibração ocorre ao chegar em 00:00
- ✅ Som toca ao chegar em 00:00
- ✅ Timer continua funcionando se app for para background
- ✅ Progresso visual é claro e intuitivo

#### Feature 4: Registro e Acompanhamento de Cargas
**User Stories:**
- Como usuário, quero registrar peso e repetições de cada série realizada
- Como usuário, quero ver o que fiz no treino anterior para referência
- Como usuário, quero visualizar gráficos de evolução por exercício
- Como usuário, quero ver meus recordes pessoais

**Requisitos Funcionais:**
- RF-018: Sistema deve permitir registrar peso e reps para cada série
- RF-019: Sistema deve salvar data/hora de cada registro
- RF-020: Sistema deve permitir adicionar notas a séries individuais
- RF-021: Sistema deve mostrar dados do último treino durante execução
- RF-022: Sistema deve gerar gráficos de evolução de carga
- RF-023: Sistema deve identificar e destacar recordes pessoais (PRs)
- RF-024: Sistema deve permitir filtrar histórico por período

**Critérios de Aceitação:**
- ✅ Dados são salvos imediatamente após registro
- ✅ Último treino é exibido para referência
- ✅ Gráficos carregam em menos de 2 segundos
- ✅ PRs são destacados visualmente
- ✅ Filtros de período funcionam corretamente

#### Feature 5: Check-in na Academia
**User Stories:**
- Como usuário, quero fazer check-in quando chegar na academia
- Como usuário, quero ver quantas vezes fui à academia no mês
- Como usuário, quero visualizar minha frequência em um calendário
- Como usuário, quero ver minha sequência atual de treinos

**Requisitos Funcionais:**
- RF-025: Sistema deve permitir check-in manual
- RF-026: Sistema deve registrar data/hora do check-in
- RF-027: Sistema deve associar check-in a sessão de treino (opcional)
- RF-028: Sistema deve mostrar calendário mensal com dias marcados
- RF-029: Sistema deve calcular estatísticas de frequência
- RF-030: Sistema deve calcular e mostrar sequências (streaks)
- RF-031: Sistema deve mostrar gráficos de frequência semanal/mensal

**Critérios de Aceitação:**
- ✅ Check-in registra data/hora corretamente
- ✅ Calendário mostra dias de treino claramente
- ✅ Estatísticas são calculadas com precisão
- ✅ Sequência atual é exibida na tela inicial

### 2.2 Out-of-Scope (Versão 1.0)

As seguintes funcionalidades NÃO estarão na versão inicial:
- ❌ Sincronização com iCloud
- ❌ Integração com HealthKit/Apple Health
- ❌ Apple Watch companion app
- ❌ Compartilhamento de planos entre usuários
- ❌ Rede social / comunidade
- ❌ Planos de treino pré-definidos
- ❌ Sugestões de progressão por IA
- ❌ Modo offline completo (apenas dados locais)
- ❌ Backup automático
- ❌ Múltiplos perfis de usuário

---

## 3. Requisitos Não-Funcionais

### 3.1 Performance
- NFR-001: App deve iniciar em menos de 2 segundos
- NFR-002: Transições entre telas devem ser fluidas (60fps)
- NFR-003: Gráficos devem carregar em menos de 2 segundos
- NFR-004: Importação de PDF deve processar em menos de 10 segundos
- NFR-005: Timer deve ter precisão de ±100ms

### 3.2 Usabilidade
- NFR-006: Interface deve seguir Human Interface Guidelines da Apple
- NFR-007: App deve suportar modo claro e escuro
- NFR-008: Fontes devem ser legíveis (mínimo 14pt para corpo)
- NFR-009: Elementos interativos devem ter mínimo 44x44pt
- NFR-010: App deve ser utilizável com uma mão

### 3.3 Compatibilidade
- NFR-011: iOS 17.0 ou superior
- NFR-012: iPhone (todos os tamanhos de tela)
- NFR-013: Orientação: Portrait (vertical) apenas

### 3.4 Segurança e Privacidade
- NFR-014: Dados armazenados apenas localmente
- NFR-015: Nenhum tracking sem consentimento
- NFR-016: Privacy Manifest configurado
- NFR-017: Conformidade com App Store Guidelines

### 3.5 Confiabilidade
- NFR-018: App não deve crashar em uso normal
- NFR-019: Dados não devem ser perdidos em caso de crash
- NFR-020: Backup local antes de operações destrutivas

### 3.6 Manutenibilidade
- NFR-021: Código deve seguir Swift Style Guide
- NFR-022: Cobertura de testes mínima de 70%
- NFR-023: Documentação inline para funções complexas
- NFR-024: Arquitetura MVVM bem definida

---

## 4. Wireframes e Fluxos de Usuário

### 4.1 Fluxo Principal: Executar Treino

```
Home Screen
    ↓ [Botão "Iniciar Treino"]
Selecionar Plano
    ↓ [Escolher plano ativo]
Sessão de Treino
    ↓ [Lista de exercícios]
Exercício Individual
    ├─→ [Ver Vídeo] → Video Player
    ├─→ [Registrar Série] → Input Peso/Reps → Timer
    └─→ [Próximo Exercício]
        ↓ [Todos concluídos]
Resumo do Treino
    ↓ [Salvar]
Home Screen (atualizada)
```

### 4.2 Fluxo Secundário: Importar Plano

```
Tela de Planos
    ↓ [Botão "Importar PDF"]
Seletor de Arquivo
    ↓ [Escolher PDF]
Processamento
    ↓ [Parser extrai dados]
Tela de Revisão
    ├─→ [Editar Exercícios]
    └─→ [Confirmar]
        ↓
Plano Salvo
```

### 4.3 Navegação Global

```
TabView (Bottom Navigation)
├── 🏠 Home
│   ├── Plano Ativo (card)
│   ├── Botão Check-in
│   ├── Último Treino (resumo)
│   └── Sequência Atual
│
├── 💪 Treinos
│   ├── Lista de Planos
│   ├── [+] Criar Novo
│   ├── [📄] Importar PDF
│   └── Detalhes do Plano
│       └── Lista de Exercícios
│
├── 📊 Progresso
│   ├── Histórico de Sessões
│   ├── Gráficos por Exercício
│   ├── Recordes Pessoais
│   └── Filtros de Período
│
└── 📅 Frequência
    ├── Botão Check-in
    ├── Calendário Mensal
    └── Estatísticas
        ├── Total mês/ano
        ├── Sequência atual
        ├── Maior sequência
        └── Taxa de frequência
```

---

## 5. Modelos de Dados

### 5.1 Entidades Principais

#### WorkoutPlan
| Campo | Tipo | Obrigatório | Descrição |
|-------|------|-------------|-----------|
| id | UUID | Sim | Identificador único |
| name | String | Sim | Nome do plano |
| description | String | Não | Descrição opcional |
| createdDate | Date | Sim | Data de criação |
| isActive | Bool | Sim | Se está ativo |
| exercises | [Exercise] | Sim | Lista de exercícios |

#### Exercise
| Campo | Tipo | Obrigatório | Descrição |
|-------|------|-------------|-----------|
| id | UUID | Sim | Identificador único |
| name | String | Sim | Nome do exercício |
| description | String | Não | Descrição/instruções |
| muscleGroup | MuscleGroup | Sim | Grupo muscular |
| videoURL | String | Não | Link do vídeo |
| defaultSets | Int | Sim | Séries padrão |
| defaultReps | Int | Sim | Repetições padrão |
| defaultRestTime | Int | Sim | Descanso em segundos |
| order | Int | Sim | Ordem no plano |

#### WorkoutSession
| Campo | Tipo | Obrigatório | Descrição |
|-------|------|-------------|-----------|
| id | UUID | Sim | Identificador único |
| workoutPlan | WorkoutPlan | Sim | Plano executado |
| startDate | Date | Sim | Início da sessão |
| endDate | Date | Não | Fim da sessão |
| notes | String | Não | Observações |
| isCompleted | Bool | Sim | Se foi concluído |

#### ExerciseSet
| Campo | Tipo | Obrigatório | Descrição |
|-------|------|-------------|-----------|
| id | UUID | Sim | Identificador único |
| exercise | Exercise | Sim | Exercício executado |
| session | WorkoutSession | Sim | Sessão do treino |
| setNumber | Int | Sim | Número da série |
| weight | Double | Não | Peso utilizado (kg) |
| reps | Int | Sim | Repetições realizadas |
| completedDate | Date | Sim | Data/hora da série |
| notes | String | Não | Observações |

#### CheckIn
| Campo | Tipo | Obrigatório | Descrição |
|-------|------|-------------|-----------|
| id | UUID | Sim | Identificador único |
| date | Date | Sim | Data do check-in |
| workoutSession | WorkoutSession | Não | Sessão associada |
| notes | String | Não | Observações |

### 5.2 Enumerações

```swift
enum MuscleGroup: String, Codable {
    case chest = "Peito"
    case back = "Costas"
    case legs = "Pernas"
    case shoulders = "Ombros"
    case arms = "Braços"
    case abs = "Abdômen"
    case cardio = "Cardio"
}
```

---

## 6. Priorização de Features

### 6.1 Metodologia MoSCoW

#### Must Have (Essencial para MVP)
1. ✅ Criar plano de treino manualmente
2. ✅ Adicionar exercícios a planos
3. ✅ Executar treino (registrar séries)
4. ✅ Timer de descanso básico
5. ✅ Visualizar histórico de treinos
6. ✅ Check-in básico

#### Should Have (Importante, mas não bloqueante)
1. ✅ Importar plano de PDF
2. ✅ Vídeos instrucionais
3. ✅ Gráficos de progresso
4. ✅ Calendário de frequência
5. ✅ Recordes pessoais

#### Could Have (Desejável se houver tempo)
1. Exportar dados
2. Temas personalizados
3. Widgets iOS
4. Notas por exercício
5. Modo escuro forçado

#### Won't Have (Versão 1.0)
1. Sincronização iCloud
2. Apple Watch
3. HealthKit
4. Compartilhamento social
5. IA/ML features

---

## 7. Métricas de Sucesso

### 7.1 KPIs Técnicos
- Taxa de crash: < 0.5%
- Tempo de inicialização: < 2s
- Rating na App Store: > 4.5 ⭐
- Tempo médio de sessão: > 15 minutos

### 7.2 KPIs de Produto
- Taxa de retenção D7: > 40%
- Taxa de retenção D30: > 20%
- Planos criados por usuário: > 2
- Check-ins por semana: > 3
- Treinos concluídos por semana: > 3

### 7.3 KPIs de Usuário
- NPS (Net Promoter Score): > 50
- Tempo para criar primeiro plano: < 5 minutos
- Tempo para completar primeiro treino: < 20 minutos
- Taxa de adoção de funcionalidades:
  - Timer: > 80%
  - Vídeos: > 40%
  - Check-in: > 60%
  - Gráficos: > 50%

---

## 8. Cronograma e Milestones

### 8.1 Fase 1: Foundation (Semanas 1-2)
- ✅ Setup do projeto
- ✅ Estrutura de pastas
- ✅ Modelos de dados (SwiftData)
- ✅ Navegação básica (TabView)

### 8.2 Fase 2: Core Features (Semanas 3-5)
- Gerenciamento de planos
- Criação manual de exercícios
- Execução básica de treino
- Registro de séries

### 8.3 Fase 3: Enhanced Features (Semanas 6-7)
- Timer de descanso
- Vídeos instrucionais
- Sistema de check-in
- Importação de PDF

### 8.4 Fase 4: Analytics & Polish (Semanas 8-9)
- Gráficos de progresso
- Recordes pessoais
- Calendário de frequência
- UI/UX refinements

### 8.5 Fase 5: Testing & Launch (Semanas 10-11)
- Testes completos
- Bug fixes
- App Store submission
- Marketing materials

### 8.6 Fase 6: Post-Launch (Semana 12+)
- Monitoring
- User feedback
- Iterações
- Planejamento v1.1

---

## 9. Riscos e Mitigações

### 9.1 Riscos Técnicos

| Risco | Probabilidade | Impacto | Mitigação |
|-------|---------------|---------|-----------|
| Parser de PDF impreciso | Alta | Médio | Implementar tela de revisão robusta |
| Performance de gráficos | Média | Médio | Usar Swift Charts, limitar dados exibidos |
| Timer impreciso | Baixa | Alto | Usar Combine Timer, testar extensivamente |
| Consumo de bateria | Média | Baixo | Otimizar background tasks |
| Crash em dispositivos antigos | Média | Médio | Definir iOS 17+ como requisito |

### 9.2 Riscos de Produto

| Risco | Probabilidade | Impacto | Mitigação |
|-------|---------------|---------|-----------|
| Baixa adoção | Média | Alto | Beta testing, ajustar onboarding |
| Complexidade percebida | Alta | Alto | Simplificar UI, melhorar UX |
| Competição com apps existentes | Alta | Médio | Focar em simplicidade e qualidade |
| Falta de funcionalidades esperadas | Média | Médio | Pesquisa de mercado, feedback beta |

### 9.3 Riscos de Negócio

| Risco | Probabilidade | Impacto | Mitigação |
|-------|---------------|---------|-----------|
| Atraso no lançamento | Média | Médio | Priorizar MVP, adiar features nice-to-have |
| Rejeição na App Store | Baixa | Alto | Seguir guidelines rigorosamente |
| Custos de desenvolvimento | Baixa | Baixo | Projeto open-source, sem custos de servidor |

---

## 10. Dependências e Integrações

### 10.1 Dependências Técnicas
- iOS SDK 17.0+
- Xcode 15.0+
- Swift 5.9+
- SwiftUI
- SwiftData
- PDFKit (nativo)
- AVKit (nativo)
- Swift Charts (nativo)

### 10.2 Integrações Externas (V1.0)
- YouTube (embed de vídeos via WebView)

### 10.3 Integrações Futuras
- iCloud (sync)
- HealthKit
- Apple Watch
- Shortcuts

---

## 11. Considerações de Localização

### 11.1 Idiomas (V1.0)
- 🇧🇷 Português (Brasil) - Principal
- 🇺🇸 Inglês - Futuro

### 11.2 Unidades
- Peso: kg (padrão), lb (futuro)
- Distância: km/m (padrão)
- Data: formato local (dd/MM/yyyy para PT-BR)

---

## 12. Suporte e Manutenção

### 12.1 Suporte ao Usuário
- FAQ dentro do app
- Email de contato
- GitHub Issues (para bugs)

### 12.2 Atualizações
- Ciclo de releases: mensal
- Hotfixes: conforme necessário
- Major updates: trimestral

---

## 13. Apêndices

### 13.1 Glossário
- **PR (Personal Record)**: Recorde pessoal
- **Série/Set**: Conjunto de repetições de um exercício
- **Rep/Repetição**: Uma execução completa do movimento
- **Check-in**: Registro de presença na academia
- **Streak**: Sequência consecutiva de treinos

### 13.2 Referências
- [Apple Human Interface Guidelines](https://developer.apple.com/design/human-interface-guidelines/)
- [SwiftData Documentation](https://developer.apple.com/documentation/swiftdata)
- [Swift Charts](https://developer.apple.com/documentation/charts)

### 13.3 Histórico de Versões

| Versão | Data | Autor | Mudanças |
|--------|------|-------|----------|
| 1.0 | 06/01/2026 | Equipe | Documento inicial |

---

**Aprovações:**

| Papel | Nome | Data | Assinatura |
|-------|------|------|------------|
| Product Owner | - | - | - |
| Tech Lead | - | - | - |
| Designer | - | - | - |
