# Onda 38.2.1-AR1 — Saneamento contadores AR1 (técnico)

**Versão alvo:** V12.0.0206
**Branch:** `codex/v12-0-0206-planejamento`
**Build label:** `e9bcf42+ONDA38.2.1-AR1-sanear-contadores`
**Agente:** Claude Opus 4.7 (bastão Codex → Opus em 2026-05-26)
**Readback:** `.hbn/readbacks/0106-onda38-2-1-ar1-sanear-contadores.json`
**ERP:** `.hbn/results/0106-exec-onda38-2-1-ar1-sanear-contadores.json`
**Predecessor:** Onda 38.2.1 (ERP 0105, `human_gate_passed_with_findings`)

---

## 1. Motivação

A Onda 38.2.1 entregou o revert do Menu_Principal e RVS APROVADO, mas o
gate humano revelou que o problema do **cadastro de empresa retornando
ID 001** NÃO era regressão do 38.2 — é estado de dados.

`Util_Planilha.ProximoId` ([src/vba/Util_Planilha.bas:533](src/vba/Util_Planilha.bas#L533)):

```vba
atual = CLng(Val(ws.Cells(1, COL_CONTADOR_AR).Value))  ' AR1
atual = atual + 1
ws.Cells(1, COL_CONTADOR_AR).Value = atual
ProximoId = Format$(atual, "000")
```

`COL_CONTADOR_AR = 44` (coluna AR). Se a célula `AR1` está zerada/vazia,
`Val("") = 0`, próximo ID = 1 = `"001"`.

O workbook foi restaurado de backup pré-38.2 e veio com vários `AR1`
dessincronizados do `max(ID)` real das linhas de dados.

### Impacto crítico no rodízio

`Svc_Rodizio.SelecionarEmpresa` lê `cred.EMP_ID` e chama
`LerEmpresa(EMP_ID, linhaEmp)`. Com IDs duplicados, `LerEmpresa` retorna
a primeira encontrada — a empresa nova fica invisível para o rodízio.

---

## 2. Escopo

### Arquivos tocados

| Path | Operação |
|---|---|
| `src/vba/Util_Sanear_Contadores.bas` | criado (módulo novo) |
| `src/vba/App_Release.bas` | apenas build label + timestamp |
| `local-ai/vba_import/001-modulo/ABN-Util_Sanear_Contadores.bas` | gerado por publicar_vba_import_v2.sh |
| `local-ai/vba_import/001-modulo/AAX-App_Release.bas` | sync |
| `local-ai/vba_import/000-MANIFESTO-V3-DELTA-ONDA38-2-1-AR1-SANEAR-CONTADORES.txt` | criado |
| `local-ai/vba_import/000-MAPA-PREFIXOS.txt` | adicionada entrada `ABN-Util_Sanear_Contadores.bas` |
| `.hbn/readbacks/0106-onda38-2-1-ar1-sanear-contadores.json` | criado (confirmed) |
| `.hbn/results/0106-exec-onda38-2-1-ar1-sanear-contadores.json` | criado |
| `.hbn/results/0105-exec-onda38-2-1-revert-filtros-menu.json` | fechado `human_gate_passed_with_findings` |
| `.hbn/relay/INDEX.md` | atualizado (38.2.1 ENTREGUE + 38.2.1-AR1 ATIVA) |
| `CHANGELOG.md` | entrada Onda 38.2.1-AR1 |

### Não tocados (invariantes)

- `Util_Planilha.ProximoId` (refatoração V207)
- `Repo_Empresa`, `Repo_Credenciamento`, `Repo_OS`, `Repo_PreOS`
- `Svc_Rodizio`, `Svc_Avaliacao`, `Svc_OS`, `Svc_PreOS`
- `Mod_Types`, `Importador_V3`
- `Auto_Open` (chamada automática fica para decisão explícita futura)
- Nenhum `.frm` / `.frx`
- Nenhum dado de empresa/entidade/atividade/etc.

---

## 3. Arquitetura do módulo

`src/vba/Util_Sanear_Contadores.bas` — 3 funções:

### `Public Sub SanearContadoresAR1()`

Ponto de entrada. Chama 7 vezes — uma por aba alvo — e log `INICIO`/`FIM`.

### `Private Function SanearAR1EmAbaPareada(targetAba, sources)`

Caso geral. `sources` é `Variant` contendo lista de abas a considerar
para `max(ID)`. Apenas a `targetAba` recebe o `AR1` atualizado.

Implementa o padrão de blindagem que `ProximoId` já usa:
`Util_PrepararAbaParaEscrita` → escreve → `Util_RestaurarProtecaoAba`.
Tratamento de erro per-aba garante que falha em uma não impede as outras.

### `Private Function MaxIdNaColunaA(nomeAba)`

Itera `LINHA_DADOS..UltimaLinhaAba` lendo coluna A
(COL_*_ID = 1 para todas as abas alvo). Retorna `max(CLng(Val(...)))`.
Aba inexistente é tratada como `max=0` sem fatal.

### Mapeamento target → sources

| Target (escrita AR1) | Sources (leitura max) |
|---|---|
| EMPRESAS | EMPRESAS, **EMPRESAS_INATIVAS** |
| ENTIDADE | ENTIDADE, **ENTIDADE_INATIVOS** |
| ATIVIDADES | ATIVIDADES |
| CAD_SERV | CAD_SERV |
| PRE_OS | PRE_OS |
| CAD_OS | CAD_OS |
| CREDENCIADOS | CREDENCIADOS |

**Inativas como sources** — decisão tomada por preocupação levantada
por Mauricio em chat 2026-05-26: se a empresa/entidade de maior ID
for inabilitada (movida para a aba INATIVA), `max(aba_ativa)` cai e o
próximo cadastro duplica o ID da inabilitada. Incluir a aba inativa
como source do `max(ID)` blinda contra esse caminho. Custo marginal
nulo (não escreve nas inativas, só lê).

`AUDIT_LOG` deliberadamente excluído — tem padrão próprio de ID, não
usa `ProximoId`, não participa de rodízio.

---

## 4. Idempotência

Rodar `SanearContadoresAR1` várias vezes seguidas produz o mesmo
estado: `max(ID)` é determinístico, AR1 só recebe esse valor. Sem
side effects fora das 7 células `<aba>!AR1`.

---

## 5. Gates humanos pendentes

1. `ImportarPacoteV3_Delta` retorna `M=2 | F=0 | err=0 | skip=0`
2. `Depurar > Compilar VBAProject` passa limpo
3. **Imediato**: `SanearContadoresAR1` executa, loga `INICIO`, 7 linhas
   `<aba>!AR1 X -> Y (sources: ...)`, e `FIM ok=7 falhas=0`. Cole o log para mim.
4. **Cadastrar empresa nova** → ID = sequencial correto (`004` se já
   havia 3 empresas; **não 001**)
5. **Cadastrar entidade nova** → aparece no FIM da lista; se persistir
   no topo, abre Onda 38.2.1-AR2 para investigar lógica de
   ordenação.
6. `CT_ValidarRelease_TrioMinimo` retorna APROVADO com
   `V1=171/0+V2_Smoke=34/0+V2_Canonica=24/0` (contadores preservados)

---

## 6. Plano de rollback

| Cenário | Ação |
|---|---|
| `publicar_vba_import_v2.sh --check` falhar | `--apply` até sync 100% |
| `hbn-guards-runner` reprovar | ajustar scope ou refazer staging |
| `ImportarPacoteV3_Delta` falhar | Mauricio **não salva** workbook; cola mensagem |
| Compile VBE falhar | restaurar do backup do Importador V3 |
| `SanearContadoresAR1` falhar em alguma aba | função reporta `falhas=N`; abrir Onda 38.2.1-AR1-fix para a(s) aba(s) que falharam |
| ID 001 persistir após `SanearContadoresAR1` | abrir Onda 38.2.1-AR1-DEEP — pode haver outro path de geração de ID |
| F2 (entidade no topo) persistir após AR1 OK | abrir Onda 38.2.1-AR2 — bug de ordenação na lista, não no contador |
| RVS falhar | parar; investigar regressão antes de 38.2.2 |

**Âncora**: commit `e9bcf42` (Onda 38.2.1 + RVS aprovado).

---

## 7. Próxima onda

**Condicional:**

- **38.2.1-AR2** — abre só se F2 (entidade no topo) persistir após o
  saneamento. Investigaria a lógica de preenchimento da lista de
  entidades no `Cadastro_Entidade.frm` ou rotina em `Preencher.bas`.

**Sequencial:**

- **38.2.2** — implementar filtros nativos do Menu_Principal pela
  arquitetura segura (handlers `TextBoxNN_Change` estáticos + função
  filtro PURA stateless), conforme aprovado em chat 2026-05-26.
  Pré-trabalho: deep-dive PHAGOCYTOSIS-VBA-PATTERNS (M9, L22-L24,
  M15-M17 leitura completa).

---

## 8. Nota de débito — verificação adicional pedida por Mauricio

Mauricio pediu em chat 2026-05-26: *"No próximo ciclo verifique se
inabilitar empresa e inabilitar entidade não sofre do mesmo problema
nos contadores ou na coluna de registro."*

Atendido **já nesta onda** ao incluir `EMPRESAS_INATIVAS` e
`ENTIDADE_INATIVOS` como sources do cálculo de `max(ID)`. Resta
verificar formalmente no gate humano:

- **F-NEW1**: Inabilitar uma empresa (a de maior ID), depois rodar
  `SanearContadoresAR1` de novo, depois cadastrar empresa nova. Se o
  ID gerado for igual ao da inabilitada, há regressão. Esperado: ID
  novo = ID da inabilitada (porque está em EMPRESAS_INATIVAS e participa
  do max).
- **F-NEW2**: Mesmo teste para entidade.

Esses dois testes ficam como **gate humano OPCIONAL** desta onda
(robustez), não bloqueiam aprovação. Se você quiser, registramos em
ERP. Se persistir bug nesse caminho, abre Onda 38.2.1-AR1-INATIVOS.
