---
titulo: Prompts para auditoria cruzada do plano Onda 38.2.3+38.2.4+38.2.5 (Codex + Gemini 3.5)
data: 2026-05-27
predecessor: 117_ANALISE_AUDITORIA_INTEGRIDADE_IDEMPOTENCIA.md + plano em ~/.claude/plans/1-tivemos-um-travamento-whimsical-tide.md
contexto: Opus 4.7 montou plano detalhado integrando recomendações Codex (0009) + Antigravity (0010). Antes de abrir readback 0112 e iniciar Onda 38.2.3, Mauricio quer 2ª rodada de auditoria cruzada — Codex e Gemini 3.5 comentando o plano e recomendando a quem passar o bastão até GATE-FREEZE V206.
audiencia: Mauricio (operador) — copia/cola nos chats das outras IAs
output-esperado:
  - codex: .hbn/proposals/0012-codex-auditoria-plano-onda-38-2-3.md
  - gemini: .hbn/proposals/0011-gemini-auditoria-cruzada-codex-antigravity-opus.md
---

# Como usar este documento

Você (Mauricio) precisa abrir 2 sessões separadas — uma do Codex CLI (no terminal, no diretório do projeto) e uma do Gemini 3.5 (chat web).

**Sequência sugerida**:

1. Iniciar Codex CLI primeiro (ele tem acesso direto ao repo via filesystem). Copiar/colar o **PROMPT 1** abaixo. Ele lerá os arquivos sozinho.
2. Em paralelo (mesma janela do navegador, outra aba), abrir Gemini 3.5 com **extended thinking** ativado. Anexar os 4 arquivos listados em PROMPT 2 (paths absolutos do seu Mac) ao chat e colar **PROMPT 2**.
3. Os outputs ficarão em `.hbn/proposals/`. O Codex commita sozinho; para Gemini, você salva o output manualmente.
4. Trazer os 2 outputs para Opus 4.7 (este chat ou um novo) para compilar e refinar o plano.

**Diretiva geral**: estabilização e coerência técnica são MAIS IMPORTANTES que velocidade. Ative modo extended thinking / raciocínio altíssimo em ambas as IAs. Sem economia de tokens.

---

## PROMPT 1 — Codex CLI (auditoria técnica do plano)

> **Para colar no Codex CLI** (aberto em `/Users/macbookpro/Projetos/Credenciamento`).
> Output esperado: `.hbn/proposals/0012-codex-auditoria-plano-onda-38-2-3.md`

```
Você é o Codex em sessão dedicada de AUDITORIA TÉCNICA do plano de estabilização V12.0.0206. Você já entregou a auditoria 0009 (integridade + idempotência); agora a tarefa é AUDITAR o PLANO consolidado pelo Opus 4.7 que integra suas recomendações + as do Antigravity.

ATIVE EXTENDED THINKING / MODO RACIOCÍNIO ALTÍSSIMO. Estabilização técnica > velocidade. Sem economia de tokens.

REPOSITÓRIO: /Users/macbookpro/Projetos/Credenciamento
BRANCH: codex/v12-0-0206-planejamento
HEAD: 8fbdf26

ARQUIVOS A LER (na ordem, antes de auditar):

1. /Users/macbookpro/.claude/plans/1-tivemos-um-travamento-whimsical-tide.md — PLANO COMPLETO Opus (vai estar fora do repo; abra com Read)
2. auditoria/00_status/117_ANALISE_AUDITORIA_INTEGRIDADE_IDEMPOTENCIA.md — análise consolidada Opus
3. .hbn/proposals/0010-antigravity-auditoria-integridade-idempotencia-v206.md — auditoria sistêmica Antigravity
4. .hbn/proposals/0009-codex-auditoria-integridade-idempotencia-v206.md — sua auditoria original (releitura)
5. auditoria/00_status/116_PROMPT_RETOMADA_SESSAO_OPUS.md — contexto do incidente corrupção
6. .hbn/protocol-evolutions/20260527-0930-onda-38-2-2-final-proposals.md — lições L41/L42/L43/M-L
7. Estado atual src/vba/Svc_PreOS.bas linhas 189-220 + Repo_PreOS.bas linhas 25-90 + Util_Planilha.bas linhas 600-700 + Funcoes.bas linhas 180-200 + Util_Excel_Performance.bas linhas 1-90 + Teste_V2_Roteiros.bas linhas 3930-3960 (validação empírica dos pontos referenciados no plano)
8. local-ai/incoming/V206-Rollback-a51b191-onda38-2-2-freeze/ — listar diretório + diff em 3 arquivos críticos vs src/vba/

TAREFA — produzir relatório em .hbn/proposals/0012-codex-auditoria-plano-onda-38-2-3.md cobrindo:

1. VALIDAÇÃO DOS file:line do plano: o Opus referenciou Svc_PreOS:192-205, Repo_PreOS.Inserir:35-38 e BuscarPorId:78-83, Funcoes.Pad3:186, Util_Planilha.IdsIguais:651, TV2_RunIntegridadeBase:3938 entre outros. Confirmar empiricamente cada linha. Reportar discrepâncias.

2. EXEQUIBILIDADE OPERACIONAL — para cada AT da Onda 38.2.3 (AT-1..AT-5), avaliar:
   - O passo está implementável textualmente seguindo o plano?
   - Há comandos faltando ou ordem incorreta?
   - O critério de saída é mensurável?
   - Quais riscos operacionais não cobertos no plano?

3. EXEQUIBILIDADE OPERACIONAL ONDA 38.2.4 — idem para Camada 1+2 + L40:
   - GravarIdTextual/LerIdTextual conforme proposto é seguro? Há casos de borda perdidos? (ID com letra como "X", IDs >3 dígitos, valores Empty/Null, Variant Error)
   - Substituição em 5 Repos preserva semântica? Especial atenção a Repo_Credenciamento sentinela "X"
   - Pad3 com assinatura Long aceita Variant String "001"? Validar comportamento empírico do cast implícito

4. EXEQUIBILIDADE OPERACIONAL ONDA 38.2.5 — idem para CS_INT_06..11 + Util_Migracao_V206:
   - Extensão de TV2_RunIntegridadeBase via TV2_RunIntegridadeBase_Estendida é melhor que modificar a função existente? (signature freeze L34)
   - Util_Migrar_IDS_Workbook é seguro? AUDIT_LOG excluído corretamente?
   - Há colunas de ID textual operacional que o plano esqueceu de migrar?

5. RISCOS NÃO COBERTOS:
   - Há eventos Workbook_BeforeClose / Worksheet_Change versionados que podem ser disparados durante migração?
   - Há fórmulas em outras abas que referenciam COL_*_ID como número? Migração as quebraria
   - Personal.xlsb / complementos COM podem mascarar comportamento de testes?

6. RECOMENDAÇÃO DE BASTÃO — considerando seu próprio perfil (rigor file:line, mas custo de contexto Opus alto), Antigravity (visão sistêmica, propõe padrões) e Opus (consolidador):
   - Quem deve IMPLEMENTAR cada onda (38.2.3, 38.2.4, 38.2.5)?
   - Quem deve AUDITAR cada onda?
   - Cadência D (Codex implementador + Opus auditor) é apropriada para todas as 3?
   - Justificativa técnica.

7. AJUSTES PROPOSTOS — lista priorizada de mudanças que o plano deve incorporar antes de Mauricio aprovar via hearback. Cada ajuste com (motivo técnico, criticidade, custo de incorporação).

FORMATO:
- Markdown técnico em português
- Tabelas onde útil
- file:line ao referenciar código
- Sub 5000 palavras
- Salvar em .hbn/proposals/0012-codex-auditoria-plano-onda-38-2-3.md

RESTRIÇÕES:
- Sem implementação (sem diff)
- Sem decisões V207
- Respeitar tabus declarados no plano
- Se discordar de qualquer ponto do Opus, EXPLICITE com argumentação técnica
- Veracidade > diplomacia

Ao final, commit com mensagem:
audit(v206): codex - auditoria do plano consolidado onda 38.2.3+38.2.4+38.2.5

Use [bypass-hbn-guards] se necessário (readback 0111 ainda ativo). NÃO PUSH.
```

---

## PROMPT 2 — Gemini 3.5 (auditoria cruzada terceira + árbitro de bastão)

> **Para colar em chat Gemini 3.5 com extended thinking ativado**.
> Anexar 4 arquivos antes (paths absolutos).
> Output esperado: você salva manualmente como `.hbn/proposals/0011-gemini-auditoria-cruzada-codex-antigravity-opus.md`

**ARQUIVOS A ANEXAR no chat Gemini (clicar no botão de upload)**:

1. `/Users/macbookpro/Projetos/Credenciamento/.hbn/proposals/0009-codex-auditoria-integridade-idempotencia-v206.md`
2. `/Users/macbookpro/Projetos/Credenciamento/.hbn/proposals/0010-antigravity-auditoria-integridade-idempotencia-v206.md`
3. `/Users/macbookpro/Projetos/Credenciamento/auditoria/00_status/117_ANALISE_AUDITORIA_INTEGRIDADE_IDEMPOTENCIA.md`
4. `/Users/macbookpro/.claude/plans/1-tivemos-um-travamento-whimsical-tide.md`

**PROMPT (após anexar os 4 arquivos)**:

```
Você é o Gemini 3.5 atuando como ÁRBITRO TÉCNICO TERCEIRO em uma auditoria cruzada do Sistema de Credenciamento V12.0.0206, um aplicativo Excel/VBA em ciclo final de estabilização antes de release pública no GitHub.

ATIVE EXTENDED THINKING / MODO DE RACIOCÍNIO PROFUNDO. Estabilização e coerência técnica são MAIS IMPORTANTES que velocidade. Sem economia de tokens.

CONTEXTO COMPRIMIDO

Branch: codex/v12-0-0206-planejamento. HEAD: 8fbdf26.
Incidente 2026-05-27: workbook V206 com Onda 38.2.2 importada CORROMPEU durante uso operacional ~3h pós-import; reaberto via cópia anterior. Mauricio exportou os forms/módulos do workbook atual para local-ai/incoming/V206-Rollback-a51b191-onda38-2-2-freeze/ como ponto de referência. Exploração confirmou que incoming/ está 100% sincronizado com src/vba/ (54 módulos idênticos, divergências apenas cosméticas).

Duas auditorias IA cruzadas foram entregues (anexos 1 e 2):
- CODEX (0009): foco técnico file:line, mapa exaustivo de gravações/leituras de IDs, classificação de idempotência rigorosa, plano em 4 camadas. Em F-NEW5, DISCORDA de Antigravity — argumenta que F-NEW6 não explica integralmente STATUS_CRED vazio.
- ANTIGRAVITY (0010): foco sistêmico, máquina de estados, invariantes lógicas, anti-padrões cross-cutting, propõe Util_Planilha.GravarIdTextual/LerIdTextual e teste E2E não-fixture (L40 meta-validação). Em F-NEW5, propõe explicação via efeito cascata de F-NEW6 + ListBox parsing.

OPUS 4.7 consolidou em análise 117 (anexo 3): recomendou Hipótese C (híbrida — preservar git + refresh workbook em 2 fases L41 + GATE-USO-PROLONGADO L43 + diagnóstico empírico F-NEW5 antes de refatoração transversal), alinhou com Codex no diagnóstico de F-NEW5 e na ordem de execução das ondas.

PLANO ATUAL (anexo 4): Onda 38.2.3 (AT-1..AT-5) → Onda 38.2.4 (helpers transversais Camada 1+2 + L40) → Onda 38.2.5 (auditoria CS_INT_06..11 + migração legado) → GATE-FREEZE V206. Pelo menos 4 semanas de execução até release pública.

CADÊNCIA atual: Opus 4.7 arquiteto-mestre + executor único; Codex em esteira paralela mas trabalhando V204; Antigravity desktop com multi-projetos. Knowledge base interna sugere Cadência D: Codex implementador + Opus auditor para MDs grandes.

PEDIDO DE AUDITORIA

1. AUDITORIA DAS 2 AUDITORIAS (anexos 1 e 2):
   - Você concorda com o veredito Opus em 117 (anexo 3) que F-NEW6 NÃO foi provado como causa de F-NEW5? Argumente.
   - Há gaps nas duas auditorias que ambas perderam? (ex: análise de Workbook_Open, Personal.xlsb, complementos COM, eventos de aplicação)
   - A classificação de idempotência da Codex (mais rigorosa, com "Parcial" para Repo_Empresa.Atualizar pelo DT_ULT_ALT) ou da Antigravity (mais funcional, "Nula") é a correta para gates técnicos pré-freeze?
   - Antigravity propôs Util_Auditoria_Integridade.bas como módulo novo; Opus mostrou que TV2_RunIntegridadeBase já existe em Teste_V2_Roteiros.bas:3938. Você concorda com a decisão de estender em vez de criar?

2. AUDITORIA DO PLANO OPUS (anexo 4):
   - O plano é executável por uma IA não-Opus seguindo as instruções textualmente? Aponte trechos que assumem conhecimento tácito.
   - Há etapas faltando entre AT-4 (re-import) e AT-5 (uso prolongado)?
   - O wrapper "GravarIdTextual" proposto é seguro? Especialmente o caso onde célula existente já tem Long e o helper sobrescreve com texto: há regressão de fórmulas que referenciam essa célula como número?
   - LerIdTextual com Pad3 só para "Len 1..3 numérico" cobre todos os casos? IDs maiores (>999) ou COD_ATIV_SERV composto de 6 dígitos?
   - O critério de saída de cada onda é suficiente para hearback confirmed?
   - Riscos não cobertos?

3. AUDITORIA DA CADÊNCIA — A QUEM PASSAR O BASTÃO:
   - Considerando que Opus está fadigado (60% contexto em sessão de 5h por incidente), Codex demonstrou rigor técnico em 0009 (mapa file:line exaustivo), e Antigravity demonstrou visão sistêmica em 0010 (máquina de estados, invariantes, propõe padrões novos):
     A QUEM você passaria o bastão para EXECUTAR as Ondas 38.2.3, 38.2.4 e 38.2.5? Especifique para CADA onda quem é melhor implementador e quem é melhor auditor.
   - Considere também Gemini 3.5 (você mesmo) como possível executor — seria apropriado em algum cenário?
   - Justificativa técnica (não política).
   - Sugira modelo de divisão de trabalho mais eficiente. Considere que Opus tem custo de contexto alto e Codex/Antigravity/Gemini podem trabalhar em paralelo sem se prejudicar.

4. DECISÃO RECOMENDADA Mauricio:
   - Aceitar Hipótese C (recomendação Opus)? sim/não/modificada
   - Aceitar plano detalhado das 3 ondas como está? sim/não/quais ajustes
   - Sua recomendação de cadência de execução
   - Riscos críticos que Mauricio precisa atender antes de aprovar

FORMATO

- Markdown técnico em português
- Tabelas onde útil
- file:line ao referenciar código (você pode citar baseando-se nos anexos)
- Sub 4500 palavras
- Output destinado a salvar em .hbn/proposals/0011-gemini-auditoria-cruzada-codex-antigravity-opus.md (Mauricio salva manualmente após sua resposta)

RESTRIÇÕES

- Sem implementação (sem diff)
- Sem decisões V207 (cache in-memory, ORM, Svc_Cadastro*)
- Respeitar tabus declarados no plano (Mod_Types.bas, Importador_V3.bas entry, Auto_Open.bas, 10 forms blindados, fixtures de teste)
- Se discordar do veredito Opus em qualquer ponto, EXPLICITE com argumentação técnica
- Sua veracidade > diplomacia; preferimos crítica clara a consenso superficial

Após sua entrega, Mauricio decidirá:
(a) seguir Hipótese C / plano atual; ou
(b) ajustar conforme suas observações; ou
(c) refatorar plano antes da Onda 38.2.3 iniciar

Comece pela auditoria das 2 auditorias (pedido 1) e progrida sequencial. Você tem permissão total para discordar de TODAS as 3 IAs anteriores se sua análise técnica indicar caminho diferente.
```

---

## Após receber os 2 outputs

Você (Mauricio) volta para este chat Opus (ou novo chat se contexto > 50%) trazendo:

- `.hbn/proposals/0012-codex-auditoria-plano-onda-38-2-3.md` — auditoria Codex do plano (commitado pelo Codex)
- Output Gemini salvo manualmente em `.hbn/proposals/0011-gemini-auditoria-cruzada-codex-antigravity-opus.md`

Opus irá:

1. Ler os 2 outputs
2. Identificar convergências/divergências entre Codex (auditoria do plano) + Gemini (árbitro)
3. Decidir se o plano precisa de refator ou se segue como está
4. Aplicar ajustes propostos no plano (criar versão v2 em `.claude/plans/` se mudanças substantivas)
5. Decidir cadência de execução com base nas 3 recomendações de bastão (Codex 0009/0012, Antigravity 0010, Gemini 0011)
6. Abrir readback `0112-rb-onda-38-2-3-<escopo>` com `decisions_preconfirmed` refletindo TUDO o que foi alinhado
7. Aguardar hearback Mauricio final para iniciar AT-1

---

## Atalho de cópia rápida

Se você só quer um único bloco para colar, copie a partir de PROMPT 1 acima (delimitado por ``` ``` ```) — isso vai direto para o Codex CLI.

Para o Gemini, copie o bloco de PROMPT 2 (após anexar os 4 arquivos no chat). Os caminhos absolutos dos anexos estão listados ANTES do bloco PROMPT 2.

---FIM 118---
