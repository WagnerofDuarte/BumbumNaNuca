# BumbumNaNuca - Documentação de Especificações

## 📋 Visão Geral

Esta pasta contém toda a documentação de especificações do aplicativo BumbumNaNuca, um gerenciador de treinos de academia para iOS.

## 📚 Documentos Disponíveis

### 1. [Requisitos do Produto (PRD)](./product-requirements.md)
**O que é:** Documento completo de requisitos de produto  
**Para quem:** Product Owners, Stakeholders, Equipe de desenvolvimento  
**Conteúdo:**
- Visão geral e objetivos do produto
- User stories e casos de uso
- Requisitos funcionais e não-funcionais
- Escopo do MVP (in/out of scope)
- Métricas de sucesso (KPIs)
- Cronograma e milestones
- Riscos e mitigações

### 2. [Especificação Técnica](./technical-specification.md)
**O que é:** Visão técnica de alto nível do projeto  
**Para quem:** Desenvolvedores, Arquitetos de Software  
**Conteúdo:**
- Padrão arquitetural (MVVM)
- Tecnologias e frameworks utilizados
- Modelos de dados (SwiftData)
- Estrutura de pastas do projeto
- Estratégias de persistência
- Roadmap de versões futuras

### 3. [Guia de Arquitetura](./architecture-guide.md)
**O que é:** Documento detalhado de arquitetura e padrões  
**Para quem:** Desenvolvedores implementando features  
**Conteúdo:**
- Explicação do padrão MVVM adaptado para SwiftUI
- Responsabilidades de cada camada
- Fluxo de dados (leitura e escrita)
- Gerenciamento de estado
- Dependency Injection
- Tratamento de erros
- Concorrência (async/await)
- Princípios SOLID
- Convenções de código

### 4. [Guia de Componentes UI](./ui-components-guide.md)
**O que é:** Catálogo completo de componentes de interface  
**Para quem:** Designers, Desenvolvedores Frontend  
**Conteúdo:**
- Design System (cores, tipografia, espaçamento)
- Componentes base (buttons, cards, badges)
- Componentes específicos (timer, exercícios, gráficos)
- View modifiers customizados
- Animações e transições
- Diretrizes de acessibilidade
- Código de exemplo para cada componente

### 5. [Guia de Fluxos de Usuário](./user-flows-guide.md)
**O que é:** Mapeamento de todos os fluxos de interação  
**Para quem:** UX Designers, Desenvolvedores, QA  
**Conteúdo:**
- Estrutura de navegação global
- Fluxo de onboarding
- Fluxo principal (executar treino)
- Fluxos secundários (criar plano, importar PDF)
- Fluxos de progresso e check-in
- Gestão de estado durante fluxos
- Fluxos de erro e recuperação
- Diagramas Mermaid ilustrativos

## 🎯 Como Usar Esta Documentação

### Para Novos Desenvolvedores
1. Comece pelo [PRD](./product-requirements.md) para entender o produto
2. Leia a [Especificação Técnica](./technical-specification.md) para visão geral
3. Estude o [Guia de Arquitetura](./architecture-guide.md) antes de codificar
4. Consulte [Componentes UI](./ui-components-guide.md) ao criar interfaces
5. Refira-se aos [Fluxos de Usuário](./user-flows-guide.md) ao implementar navegação

### Para Product Owners
- [PRD](./product-requirements.md) → Requisitos e escopo
- [Fluxos de Usuário](./user-flows-guide.md) → Experiência do usuário

### Para Designers
- [Componentes UI](./ui-components-guide.md) → Design system
- [Fluxos de Usuário](./user-flows-guide.md) → Jornada do usuário

### Para QA/Testers
- [PRD](./product-requirements.md) → Critérios de aceitação
- [Fluxos de Usuário](./user-flows-guide.md) → Casos de teste

## 📝 Convenções

### Nomenclatura de Arquivos
- Usar kebab-case: `product-requirements.md`
- Sufixo `-guide` para guias técnicos
- Manter em inglês (exceto conteúdo interno)

### Estrutura de Documentos
Todos os documentos seguem estrutura similar:
1. Título e Visão Geral
2. Índice (para docs longos)
3. Seções numeradas
4. Exemplos de código quando aplicável
5. Conclusão/Resumo

### Código de Exemplo
```swift
// Sempre incluir comentários explicativos
class ExampleViewModel: ObservableObject {
    @Published var data: [Model] = []
    
    // Métodos públicos documentados
    func fetchData() async {
        // Implementation
    }
}
```

### Diagramas
- Usar Mermaid para fluxogramas
- Usar ASCII art para layouts de UI simples
- Screenshots/mockups na pasta `../assets/` (futuro)

## 🔄 Manutenção

### Quando Atualizar
- ✅ Nova feature planejada → Atualizar PRD e Specs
- ✅ Mudança arquitetural → Atualizar Architecture Guide
- ✅ Novo componente UI → Adicionar ao UI Components Guide
- ✅ Novo fluxo → Adicionar ao User Flows Guide

### Processo de Atualização
1. Criar branch de documentação
2. Atualizar documento(s) relevante(s)
3. Adicionar nota de versão no histórico
4. Review por tech lead
5. Merge para main

### Histórico de Versões
Cada documento mantém tabela de histórico no final:

| Versão | Data | Autor | Mudanças |
|--------|------|-------|----------|
| 1.0 | 06/01/2026 | Equipe | Documento inicial |

## 🔗 Relacionamentos Entre Documentos

```
PRD (Product Requirements)
  ├─> Define WHAT (O QUE construir)
  └─> Alimenta
       ↓
Technical Specification
  ├─> Define HOW (COMO construir tecnicamente)
  └─> Expande em
       ↓
Architecture Guide
  ├─> Define PATTERNS (Padrões de implementação)
  │
UI Components Guide
  ├─> Define UI/UX (Interface e experiência)
  │
User Flows Guide
  └─> Define INTERACTION (Como usuário interage)
```

## 📌 Próximos Passos

### Fase de Planejamento ✅
- [x] PRD completo
- [x] Especificação técnica
- [x] Guia de arquitetura
- [x] Guia de componentes UI
- [x] Guia de fluxos de usuário

### Fase de Design 🔄
- [ ] Wireframes de alta fidelidade
- [ ] Protótipo interativo (Figma)
- [ ] Assets de design (ícones, ilustrações)
- [ ] Guia de estilo visual

### Fase de Desenvolvimento 📋
- [ ] Setup do projeto Xcode
- [ ] Implementação de modelos SwiftData
- [ ] Componentes base do design system
- [ ] Telas principais
- [ ] Integração de features
- [ ] Testes

## 📧 Contato

Para dúvidas ou sugestões sobre esta documentação:
- Abrir issue no GitHub
- Contatar tech lead do projeto

---

**Última atualização:** 06 de Janeiro de 2026  
**Versão da documentação:** 1.0  
**Status do projeto:** Fase de Especificação
