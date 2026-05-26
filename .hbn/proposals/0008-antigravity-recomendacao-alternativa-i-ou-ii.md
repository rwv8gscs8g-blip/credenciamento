---
titulo: Recomendação Antigravity — Alternativa I ou II (2ª rodada)
diataxis: explanation
hbn-track: fast_track
hbn-status: active
audiencia: ambos
versao-sistema: V12.0.0207
data: 2026-05-26
---

# Recomendação Antigravity — Alternativa I ou II (2ª rodada)

> [!IMPORTANT]
> Este parecer consolida a recomendação técnica formal da IA **Antigravity** sobre a escolha arquitetural para a versão **V12.0.0207** do Sistema de Credenciamento. A avaliação prioriza a integridade sistêmica, a mitigação de fricção operacional sobre o operador humano e a viabilidade prática do cronograma de desenvolvimento na esteira única inter-IA do useHBN.

---

## 1. O Veredito Sistêmico

A **Antigravity** recomenda fortemente a adoção da **Alternativa II (Opção 4 híbrida: Caminho 1 + Caching in-memory cirúrgico)** como o caminho canônico de desenvolvimento para a **V12.0.0207**.

```text
               ┌────────────────────────────────────────────────────────┐
               │    RECOMENDAÇÃO: ALTERNATIVA II (Opção 4 Híbrida)      │
               │  - Estabiliza e isola regras no monolito (Ondas 0-4)   │
               │  - Cache cirúrgico in-memory de ListBoxes (Ondas 5-7)  │
               │  - Velocidade 10-20x imediata em 1 única versão        │
               └────────────────────────────────────────────────────────┘
```

---

## 2. Racional e Justificativa de Engenharia

A escolha pela Alternativa II fundamenta-se em três pilares sistêmicos e operacionais do projeto:

### 2.1 O fator da Fricção Operacional (O Calcanhar de Aquiles da Alternativa I)
A Alternativa I é teoricamente elegante por sua divisão sequencial em duas releases estanques (V207 e V208). Contudo, essa divisão exige um custo logístico invisível inaceitável: entre **12 e 17 ondas de importação manuais**.

Sob o protocolo HBN, o operador (Mauricio) deve rodar o `Importador_V3_Delta` e validar o compile VBE a cada onda.
*   Dividir o projeto em duas releases prolonga o estado transicional e fadiga o operador humano com repetidos ciclos de deploy.
*   **A fadiga humana é o principal catalisador de falhas de compile e drifts de código**. Reduzir as ondas para 7-9 em um único ciclo V207 (Alternativa II) reduz a sobrecarga operacional do operador em quase **50%**.

### 2.2 Entrega de Valor Imediata contra o bottleneck F-NEW4
O finding de performance `F-NEW4` (cadastros lentos em PC antigo) é de severidade média, mas gera atrito diário direto para o gestor municipal.
*   Na Alternativa I, a V207 entregaria apenas a gravação em bloco dos Repositórios, o que melhoraria a velocidade de inserção, mas **não resolveria o gargalo perceptivo da ListBox do Menu Principal**. O usuário continuaria vendo a tela travar após salvar um cadastro porque o reload continuaria cell-a-cell. O ganho real só viria na V208, meses depois.
*   Na Alternativa II, o caching cirúrgico das ListBoxes do Menu Principal resolve o reload cell-a-cell imediatamente. O usuário recebe o ganho de 10-20x de velocidade logo na V207.

### 2.3 Viabilidade de Transição SaaS Preservada
Embora a Alternativa II não desacople toda a persistência de dados em memória (o que a Alternativa I traria na V208), as ondas de 0 a 4 da Alternativa II realizam o **isolamento lógico completo** das regras nos módulos `Svc_Cadastro*`. 

Essa modularização cria o mapa de processos necessário para a futura tradução do código para o SaaS. A persistência em si (`Repo_*`) continuará acoplada a células no Excel, o que é aceitável, visto que o SaaS usará um driver de banco de dados nativo (ex.: PostgreSQL) e reescreverá a camada de repositório de qualquer forma.

---

## 3. Os 3 Guard-rails Sistêmicos Obrigatórios

Para anular o risco de incoerência de dados inerente a qualquer modelo híbrido (células vs cache em memória), a Alternativa II **só pode ser homologada se cumprir três restrições técnicas intransponíveis**:

1.  > [!CAUTION]
    > **Guard-rail 1 — Barreira de Fase (Fase-Lock)**: As ondas de caching de listas (V207.5+) só poderão ser iniciadas após a homologação formal do Gate de Liberação das ondas 0-4. O Git deve ser carimbado com uma tag interna (ex.: `v12.0.0207-base-monolito`) e o RVS com a nova bateria `E2E_CADASTROS` deve estar 100% verde. **Proibido abrir branches ou comitar código de cache em paralelo.**

2.  > [!CAUTION]
    > **Guard-rail 2 — Padrão de Invalidação Stateless**: Para evitar drifts de dados na memória cache, o cache de listas do `Menu_Principal` não deve tentar atualizar "cirurgicamente" um único item alterado em sua coleção local. Em vez disso, qualquer chamada de invalidação de cache (ex.: `Cache_Invalidate("EMPRESAS")`) deve forçar a reconstrução total da coleção em memória lendo dinamicamente da planilha. Isso garante que o cache permaneça idempotente e imune a inconsistências de mutação parcial.

3.  > [!CAUTION]
    > **Guard-rail 3 — Registro Explicito de Callback**: Toda operação de gravação nos repositórios (`Repo_*.bas`) que afete os dados exibidos na tela deve invocar expressamente a rotina de invalidação da UI (ex.: `Menu_Principal.InvalidarCache(tipoAba)`), sob pena de falha mecânica no analisador estático de código.

---

## 4. Comparação e Descarte da Alternativa III (EDRA)

Embora a proposta de Despacho Reativo por Eventos (EDRA) seja elegante e desacople totalmente as camadas, ela é **sistemicamente descartada** para a V207 devido a:
*   **Curva de aprendizado complexa**: Introduz controle assíncrono e listeners em VBA, um paradigma exótico para desenvolvedores tradicionais de planilha.
*   **Custo de depuração alto**: Risco de loops infinitos de eventos difíceis de depurar sem ferramentas de rastreabilidade avançadas.

A Alternativa II resolve a dor real com simplicidade mecânica, mantendo a robustez determinística característica do protocolo HBN.
