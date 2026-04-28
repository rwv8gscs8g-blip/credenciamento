---
titulo: Protocolo Glasswing aplicado ao Credenciamento
ultima-atualizacao: 2026-04-28
diataxis: explanation
hbn-track: fast_track
audiencia: ambos
versao-sistema: V12.0.0203
referencias:
  - https://www.anthropic.com/glasswing
  - https://red.anthropic.com/2026/mythos-preview/
---

# Protocolo Glasswing aplicado ao Credenciamento

> Camada de seguranca preventiva que estende HBN com checks
> domain-specific. Inspirada no Project Glasswing (Anthropic, abril
> 2026).

## Por que existe

Em abril de 2026, a Anthropic publicou o Project Glasswing e revelou
que **Claude Mythos Preview encontrou milhares de zero-days em todos
os principais sistemas operacionais e navegadores em poucas semanas**.

Para o Credenciamento — repositorio publico com macros VBA que
manipulam dados de empresas e operacao real de prefeituras — isso
muda o calculo de risco. Nao basta confiar que IAs assistentes nao
introduzam vulnerabilidades acidentais. E preciso assumir que **uma IA
hostil clonando o repo vai procurar falhas exploraveis em minutos**.

A camada Glasswing do Credenciamento adiciona 5 vetores preventivos
que, somados ao HBN existente, reduzem a superficie exploravel.

## Os 5 vetores cobertos

### G1 — Macros nao confiaveis fora do pacote oficial

**Problema:** macros descartaveis (Diag_*, Limpa_*, Reset_*) ficavam
na raiz de `local-ai/vba_import/` e podiam ser importadas e executadas
por qualquer operador, sem cenario de teste, sem trilha de auditoria.

**Mitigacao (Onda 6):** macros descartaveis foram removidas do
repositorio publico e movidas para
`Projetos/backups/credenciamento/macros_descartaveis_v0203/`. Volta
condicionada a cenario `IDM_*` ou `RDZ_*` automatizado em
`Teste_V2_Roteiros.bas`.

**Verificar:**

```bash
ls Credenciamento/local-ai/vba_import/*.bas | \
  grep -v -E "(Importador_VBA|Importar_Agora)\.bas$"
# Deve retornar vazio.
```

### G2 — Configuracao validada antes de virar privilegio

**Problema:** valores em `CONFIG` (nota minima, max strikes, dias
suspensao) influenciam comportamento operacional. Valor invalido podia
zerar a config em vigor ou substituir silenciosamente por padrao.

**Mitigacao (Ondas 4+5):** toda leitura passa por
`Util_Config.GetX()` com clausula de validacao tipo + faixa. Valor
invalido nao zera a config — gera evento `CONFIG_REJEITADA` em
`AUDIT_LOG`. Valor valido continua valendo.

**Verificar:**

```bash
grep -n "Function Get.*Config" Credenciamento/src/vba/Util_Config.bas | \
  head -10
# Conferir que cada Get*() retorna padrao apenas se vazio,
# nunca substitui valor existente sem evento.
```

### G3 — Formulas privilegiadas isoladas

**Problema:** `=HYPERLINK("=macro()...")`, `=WEBSERVICE`,
`=INDIRECT(arg_dinamico)` em abas operacionais permitem injecao por
edicao manual de planilha.

**Mitigacao:** formulas privilegiadas so podem aparecer em abas com
prefixo `RPT_*` ou `DIAG_*`, com data de expiracao no cabecalho. Abas
operacionais (`EMPRESAS`, `ATIVIDADES`, `CAD_OS`, `CONFIG`) nao
contem formulas dinamicas.

**Verificar:** rotina diagnostica `DIAG_FORMULAS_PRIVILEGIADAS` (a ser
implementada na Onda 7) que varre o workbook e flag qualquer ocorrencia
fora de abas RPT_* / DIAG_*.

### G4 — `AUDIT_LOG` append-only

**Problema:** se `AUDIT_LOG` puder ser editada por codigo VBA arbitrario
(`Range.Delete`, `Range.Clear`), a trilha de auditoria fica
falsificavel.

**Mitigacao:** o append-only e garantido por contrato. Nenhum codigo em
`src/vba/` faz `Delete` ou `Clear` em `AUDIT_LOG` ou `AUDIT_TESTES`,
exceto dentro de `Mod_Limpeza_Base.LimpaBaseTotalReset` (caminho
autenticado por senha).

**Verificar:**

```bash
grep -nE "(AUDIT_LOG|AUDIT_TESTES)\b" Credenciamento/src/vba/*.bas | \
  grep -E "(Delete|Clear|EntireRow)"
# Deve retornar apenas referencias dentro de LimpaBaseTotalReset.
```

### G5 — Claims sem evidencia bloqueados

**Problema:** documentacao de ondas pre-Glasswing continha frases como
"100% testado", "sem risco", "totalmente seguro". Essas afirmacoes nao
tinham evidencia e poluiam a auditabilidade.

**Mitigacao:** Truth Barrier do HBN flag esses claims. Substituir por:

- "trio minimo verde no checkpoint `<CSV>`"
- "risco residual: `<especificar>`"
- "validado em Excel 2019/2021/365 conforme `obsidian-vault/00-DASHBOARD.md`"

**Verificar:**

```bash
grep -rE "(100%|zero risco|sem risco|totalmente seguro|garantido)" \
  Credenciamento/auditoria/03_ondas/ \
  Credenciamento/docs/ \
  Credenciamento/README.md \
  Credenciamento/CHANGELOG.md
# Deve retornar zero ocorrencias.
```

## Integracao com HBN

A camada Glasswing **nao substitui** HBN — ela e uma extensao de Truth
Barrier (G5) e Guardian (G1-G4). Toda violacao gera entrada em
`.hbn/results/` com `outcome: rejected`.

Em readbacks, a IA executora declara explicitamente:

```json
{
  "glasswing_checks": {
    "G1_macro_nao_confiavel": "ok",
    "G2_config_validada": "ok",
    "G3_formulas_privilegiadas": "ok",
    "G4_audit_log_append_only": "ok",
    "G5_claims_proporcionais": "ok"
  }
}
```

Hearback `confirmed` e condicional a todos os 5 estarem `ok` ou
`not_applicable`.

## Operacao em pipeline

A Onda 7 deve entregar
`Credenciamento/local-ai/scripts/glasswing-checks.sh` com:

```bash
#!/bin/bash
# Glasswing-style preventive checks for Credenciamento V12.0.0203
# Uso: bash local-ai/scripts/glasswing-checks.sh
# Saida: OK G1..G5 (sucesso) ou VIOLATED Gn (falha bloqueante)

# G1: macros descartaveis nao na raiz
G1=$(ls local-ai/vba_import/*.bas 2>/dev/null | \
     grep -v -E "(Importador_VBA|Importar_Agora)\.bas$" | wc -l)
[[ $G1 -eq 0 ]] && echo "OK G1" || echo "VIOLATED G1: $G1 macros na raiz"

# G2..G5: cobertos por inspecao automatica de codigo (a implementar)
echo "OK G2 (manual ate Onda 7)"
echo "OK G3 (manual ate Onda 7)"
echo "OK G4 (manual ate Onda 7)"

# G5: claims sem evidencia
G5=$(grep -rE "(100%|zero risco|sem risco|totalmente seguro)" \
     auditoria/03_ondas/ docs/ 2>/dev/null | wc -l)
[[ $G5 -eq 0 ]] && echo "OK G5" || echo "VIOLATED G5: $G5 claims"
```

Este script roda obrigatoriamente antes de declarar onda fechada (a
partir da Onda 7).

## Limitacoes honestas (Truth Barrier auto-aplicado)

Esta camada NAO:

- Detecta zero-days desconhecidos. Glasswing real (Anthropic) usa Mythos
  Preview, que nao temos acesso.
- Substitui revisao humana de codigo.
- Garante que o `.xlsm` publicado nao tem vulnerabilidade.

Esta camada SIM:

- Reduz superficie atacavel via 5 vetores conhecidos especificos do
  dominio VBA/Excel/credenciamento publico.
- Forca rigor documental (G5).
- Compoe com HBN sem sobrescrever protocolo.

## Reference

- Project Glasswing: https://www.anthropic.com/glasswing
- Claude Mythos Preview: https://red.anthropic.com/2026/mythos-preview/
- Camada operacional para IA: `.hbn/knowledge/0003-glasswing-style-preventive-security.md`
- Integracao no usehbn: `usehbn/docs/INTEGRATION-GLASSWING.md`
