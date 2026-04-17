# 05. Análise Comparativa V1 × V2 — Bateria de Testes

## 1. Contexto

A V12.0.0182 introduziu a bateria V2 como alternativa paralela à legada (V1). O objetivo declarado foi obter uma bateria **mais semântica, mais rastreável e mais amigável a operação humana assistida**, preparando terreno para automação futura e eventual migração para SaaS.

A V12.0.0189 consolidou a V2 em dois cadastros automáticos (smoke + stress) e dois cadastros assistidos (smoke assistido + stress assistido), mais o roteiro manual `ROTEIRO_ASSISTIDO_V2`. A V1 (`Teste_Bateria_Oficial.bas`) permanece em shadow mode.

Este documento compara as duas em oito dimensões e conclui com recomendação operacional.

---

## 2. Comparação por dimensão

### 2.1 Arquitetura

| Dimensão | V1 | V2 | Vencedor |
|----------|----|----|----------|
| Separação em módulos | Monolítico (`Teste_Bateria_Oficial.bas`) | 3 módulos (`Central_Testes_V2`, `Teste_V2_Engine`, `Teste_V2_Roteiros`) | **V2** |
| Acoplamento com `Menu_Principal` | Médio | Baixo (descarrega a instância antes de rodar) | **V2** |
| Reuso de utilitários (`Util_Planilha`, `IdsIguais`) | Alto | Alto | empate |

### 2.2 Contagem de linhas

| Estratégia | V1 | V2 |
|------------|----|----|
| Como conta | `CountA(ws.Range(primeiraLinha:Rows.Count, colunaChave))` na coluna-chave real da aba | `UltimaLinhaAba(nomeAba) - primeira + 1`, olhando apenas coluna A |
| Imunidade a resíduo em coluna A | Alta (se coluna-chave ≠ A) | **Baixa** |
| Imunidade a resíduo em coluna fora do range limpo | Alta | Alta |
| Custo computacional | O(linhas_aba) | O(1) |
| Correção semântica | Alta | Média |

**Vencedor:** V1 por larga margem. A V2 ganha em performance, mas paga em robustez. O custo de performance é irrelevante para abas com <1000 linhas (caso real).

### 2.3 Reset operacional

| Aspecto | V1 | V2 |
|---------|----|----|
| Quando roda | Sob comando do operador, com `MsgBox vbYesNo` de confirmação | Automático a cada `CT2_Executar*` |
| Confirmação humana | Sim | Não |
| Tratamento de `ListObjects` | Não manipula diretamente | Manipula com `On Error Resume Next` (risco 02§2) |
| Tratamento de proteção | Protect/unprotect por chamada via `Util_PrepararAbaParaEscrita` | Idem |
| Risco de perda de dados operacionais | **Baixo** | **Alto** |

**Vencedor:** V1 em segurança operacional; V2 em velocidade.

### 2.4 Cenários cobertos

| Categoria | V1 | V2 |
|-----------|-----|-----|
| Rodízio básico | Sim | Sim (`SMK_001..007`) |
| Recusa e suspensão | Sim | Sim (`SMK_004`, `SMK_005`) |
| Stress (N iterações) | Sim | Sim (`STR_001`) |
| Migração UI→SVC | — | Cenários `MIG_001/002/003` como `LogManual` |
| Roteiro humano assistido | Não | Sim (`ROTEIRO_ASSISTIDO_V2`) |
| Smoke assistido | Não | Sim |
| Stress assistido | Não | Sim |

**Vencedor:** V2 em cobertura conceitual. Porém, vários cenários V2 hoje estão bloqueados pela falha estrutural da baseline.

### 2.5 Diagnóstico e rastreabilidade

| Aspecto | V1 | V2 |
|---------|----|----|
| Relatório | `RPT_BATERIA` (markdown legível) | `RESULTADO_QA_V2` + CSV de falhas |
| Exportação de CSV | Sob comando | Automática apenas quando há falhas (desde V187) |
| Mensagem de falha | Genérica (`Falha em <cenário>`) | Semântica (`Cenario triplo V2 inconsistente: EMPRESAS=4 \| ...`) |
| Catálogo de cenários | Embutido no código | Externalizado em `CATALOGO_CENARIOS_V2` |

**Vencedor:** V2. A mensagem de falha estruturada é o que tornou possível diagnosticar a falha atual em minutos ao invés de horas.

### 2.6 Operação humana assistida

| Aspecto | V1 | V2 |
|---------|----|----|
| Pausas para observação | Implícitas (operador decide) | Explícitas (roteiro passo-a-passo) |
| Instruções no momento | Ausentes | Presentes em `Teste_V2_Roteiros.bas` |
| Decisões registradas | Não | Parciais (`CATALOGO_CENARIOS_V2`) |

**Vencedor:** V2.

### 2.7 Estabilidade atual (abril/2026)

| Aspecto | V1 | V2 |
|---------|----|----|
| Roda hoje sem bloqueio? | **Sim** (com ressalvas pontuais) | **Não** (fatal na baseline) |
| Promove release hoje? | Sim | Não |
| Cobre todos os casos? | Quase | Em teoria sim; na prática bloqueada |

**Vencedor:** V1. Por isso ela segue em shadow mode e a V2 ainda não substitui.

### 2.8 Custo de manutenção

| Aspecto | V1 | V2 |
|---------|----|----|
| Linhas de código | Menor | Maior |
| Abas de suporte | 2 (`RESULTADO_QA`, `RPT_BATERIA`) | 3 (`RESULTADO_QA_V2`, `CATALOGO_CENARIOS_V2`, `ROTEIRO_ASSISTIDO_V2`) |
| Curva de aprendizado para novo auditor | Alta (monolito) | Média (módulos claros) |

**Vencedor:** V2 a médio prazo; V1 a curto prazo (já dominada).

---

## 3. Matriz de decisão

| Pergunta | Resposta |
|----------|----------|
| Hoje, quem é confiável para promoção? | **V1**. |
| Para onde o projeto deve ir? | **V2**, depois das correções B1+B2+B3. |
| Em que horizonte? | 3 a 5 sprints de shadow mode paralelo. |
| V1 deve ser mantida permanentemente? | Não. Decommissiona após V2 cobrir paridade + MIG_001/002/003 migrados. |
| V1 e V2 devem rodar juntas? | **Sim, até a decisão final**. É o único jeito de detectar regressão silenciosa na V2. |

---

## 4. Protocolo de shadow mode

**Objetivo:** validar que V2 cobre V1 antes de decommissionar V1.

**Procedimento proposto:**

1. A cada release em `EM_VALIDACAO`, o revisor (Maurício) executa V1 seguida de V2 no mesmo estado inicial.
2. Um script externo compara `RPT_BATERIA` (V1) com `RESULTADO_QA_V2` extraindo: quantos cenários rodaram, quantos falharam, nomes dos cenários falhos.
3. Divergências são registradas em `obsidian-vault/shadow/V12.0.0XXX.md` com explicação.
4. **Critério de decomissionamento da V1:** 5 releases consecutivas com divergência = 0 e todos os `MIG_*` como `PASS` (não `LogManual`).

**Ferramentas sugeridas:**

- Script Python em `ferramentas/compara_baterias.py` para o diff automático.
- Gatilho por arquivo: se `RPT_BATERIA` e `RESULTADO_QA_V2` forem atualizados na mesma sessão do `.xlsm`, gerar o diff automaticamente.

---

## 5. Recomendação executiva

**Curto prazo (antes da próxima release):** corrigir B1 (contagem semântica V2) e B2 (assert pós-reset). Isso destrava a V2 para rodar.

**Médio prazo (3 a 5 sprints):** migrar MIG_001/002/003 e rodar shadow mode.

**Longo prazo (pós-decommissionamento V1):** transformar V2 em bateria canônica, renomear para `Central_Testes`, mover `Teste_Bateria_Oficial.bas` para `backups/legado/`.

---

## 6. Riscos da migração V1 → V2

| Risco | Probabilidade | Impacto | Mitigação |
|-------|---------------|---------|-----------|
| V2 cobre menos que V1 em canto desconhecido | Média | Alto | shadow mode com diff automatizado |
| V2 falha em planilha com histórico (residual estrutural) | **Alta** | **Alto** | B1+B2 (documento 07) |
| Perda de familiaridade operacional com V1 | Baixa | Médio | manter documentação da V1 em `backups/legado/` |
| Dependência dos `MIG_*` ficar eterna | Média | Alto | prazo duro: sprint N+3 ou reverter decisão |
