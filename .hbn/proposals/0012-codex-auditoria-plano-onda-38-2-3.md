---
titulo: Auditoria Codex - plano consolidado Onda 38.2.3 a 38.2.5
diataxis: explanation
hbn-track: fast_track
hbn-status: active
audiencia: ambos
versao-sistema: V12.0.0206
data: 2026-05-27
---

# Auditoria Codex - plano consolidado Onda 38.2.3 a 38.2.5

## 1. Veredito

O plano Opus e tecnicamente bom na direcao geral: Hipotese C, diagnostico empirico de F-NEW5 antes de refatoracao transversal, correcao pontual de `PRE_OS`, helpers em onda separada, auditoria/migracao depois. Eu aprovaria a arquitetura **com ajustes obrigatorios antes do hearback**.

Ha um bloqueio P0 no AT-1: o plano assume que `publicar_vba_import_v2.sh --apply` resolve o drift de `Cadastro_Servico`, mas o gerador atual de `.code-only.txt` nao preserva as declaracoes `Private mIgnorarFiltro` e `Private WithEvents mTxtBuscaTopo` quando encontra a linha `Attribute mTxtBuscaTopo.VB_VarHelpID = -1`. O `code-only` atual esta sem essas declaracoes, embora use as variaveis. Sem corrigir isso, o drift V2_SMOKE pode persistir e o pacote importavel pode continuar incompleto.

Tambem ha um P0 na proposta de usar `Pad3` diretamente sobre valores `Variant`: `Pad3` recebe `Long`. Funciona para `"001"` por coercao implicita, mas falha para `"X"`, `Null`, `Error` e pode aceitar formatos indesejados via `IsNumeric`. O plano precisa de normalizador type-aware antes de aplicar isso em larga escala.

## 2. Validacao de file:line

| Referencia do plano | Confirmacao | Observacao |
|---|---|---|
| `Svc_PreOS.EmitirPreOS:192-205` | Confirmado em `src/vba/Svc_PreOS.bas:192-205` | Escrita direta em `PRE_OS` sem `NumberFormat`. A faixa ampla `189-205` tambem e correta porque inclui `preosId` e `linha`. |
| `Repo_PreOS.Inserir:35-38` | Parcial | `src/vba/Repo_PreOS.bas:35-38` grava `PREOS_ID`, `ENT_ID`, `COD_SERV`, `EMP_ID`. O plano deve incluir tambem `COL_PREOS_ATIV_ID` em `src/vba/Repo_PreOS.bas:41`. |
| `Repo_PreOS.BuscarPorId:78-83` | Confirmado | Usa `IdsIguais` para localizar, mas hidrata `PREOS_ID`, `ENT_ID`, `ATIV_ID`, `SERV_ID`, `EMP_ID` via `CStr`/extração crua. |
| `Funcoes.Pad3:186` | Confirmado | `src/vba/Funcoes.bas:186` tem assinatura `Pad3(ByVal numero As Long) As String`; nao e helper seguro para `Variant` arbitrario. |
| `Util_Planilha.IdsIguais:651` | Confirmado | `src/vba/Util_Planilha.bas:651-667`. Boa comparacao, mas tambem usa `CStr` sem `IsError`. |
| `Util_IniciarBlocoRapido:48` e `Finalizar:67` | Confirmado | `src/vba/Util_Excel_Performance.bas:48-77`. A macro de migracao deve instalar handler antes de iniciar o bloco ou aceitar risco de flags nao restaurados se o start falhar. |
| `TV2_LogAssert:220` | Confirmado | `src/vba/Teste_V2_Engine.bas:220`. |
| `TV2_RunIntegridadeBase:3938` | Confirmado | `src/vba/Teste_V2_Roteiros.bas:3938-3966` executa CS_INT_01..05. |
| `ImportarPacoteV3_Delta:156` | Confirmado | `src/vba/Importador_V3.bas:156`. |
| `Svc_OS.EmitirOS:172` | Confirmado | `src/vba/Svc_OS.bas:171-173` grava `COL_PREOS_STATUS`, `COL_PREOS_OS_ID`, `COL_PREOS_DT_EM_OS`; `OS_ID` sem `NumberFormat`. |

### Incoming rollback

Diretorio `local-ai/incoming/V206-Rollback-a51b191-onda38-2-2-freeze/` existe e contem os modulos/forms exportados. Nos 3 arquivos criticos:

- `Svc_PreOS.bas`: diff contra `src/vba/` e cosmetico em comentarios (`-` vs `—`) e uma linha em branco.
- `Repo_PreOS.bas`: diff cosmetico em comentarios (`-` vs `—`).
- `Cadastro_Servico.frm`: **nao e cosmetico**. O incoming remove as declaracoes de `mIgnorarFiltro` e `mTxtBuscaTopo` no topo, mas o corpo ainda usa essas variaveis. O `src/vba` e o `.frm` importavel atual tem as declaracoes; o `.code-only.txt` atual nao tem.

Esse ultimo ponto invalida a frase "incoming 100% sincronizado funcionalmente" para `Cadastro_Servico.frm`. Pode ser um artefato do export/import de code-only, mas precisa ser tratado como bug de sincronizacao ate prova em compile.

## 3. Onda 38.2.3 - exequibilidade

| AT | Exequibilidade | Riscos e ajustes |
|---|---|---|
| AT-1 resync drift | Parcial | O comando existe (`local-ai/scripts/publicar_vba_import_v2.sh`), mas nao encontrei `validar_paridade_v2.sh`. Mais grave: `publicar_vba_import_v2.py:212-248` para antes das declaracoes quando encontra `Attribute mTxtBuscaTopo...`; rodar `--apply` tende a regenerar `code-only` ainda sem `Private WithEvents`. Ajuste P0: corrigir ou contornar a geracao de code-only antes de depender do AT-1. |
| AT-2 diagnostico F-NEW5 | Implementavel | O criterio e mensuravel, mas o plano precisa especificar captura por linha criada, nao apenas `credIdGravado/novaLinha`, porque `CR_Credenciar_Click` pode credenciar mais de um servico. Tambem precisa usar helper de caminho seguro para salvar CSV no Mac/Parallels e prever remocao/disable no mesmo escopo. |
| AT-3 fix `DIAG_PREOS_INTEGRITY` | Implementavel com ajuste | O `NumberFormat` antes da escrita em `Svc_PreOS` e correto se houver excecao de tabu. A hidratacao nao deve usar `Pad3(...)` cego. Para PRE_OS, aplicar normalizacao type-aware apenas em `PREOS_ID`, `ENT_ID`, `EMP_ID`, `ATIV_ID`, `OS_ID` quando numericos; `COD_SERV` com pipe precisa tratamento proprio. |
| AT-4 import L41 duas fases | Conceitualmente bom | Faltam comandos para gerar manifestos com prefixo/hash/bytes reais. O exemplo de manifesto usa nomes ilustrativos e pode nao bater com o parser V3. Criterio de saida e bom, mas so depois que AT-1 resolver o bug do code-only. |
| AT-5 uso prolongado | Bom, mas minimo | 30 min e coerente como gate local, mas o incidente ocorreu apos cerca de 3h. Eu manteria 30 min para 38.2.3 e exigiria explicitamente 1 semana no gate-freeze, como o proprio plano ja sugere. |

Recomendacao para 38.2.3: manter a ordem, mas abrir a onda com um sub-AT P0 "sanear geracao code-only de declarations WithEvents" ou documentar procedimento manual auditavel que prove que o import V3 recebera as declaracoes.

## 4. Onda 38.2.4 - helpers e repos

`GravarIdTextual` e `LerIdTextual` sao a direcao correta, mas a especificacao atual ainda tem bordas perigosas:

- `IsNumeric` aceita valores que nao sao "digitos puros" em VBA, como notacao cientifica ou decimal. Use teste de string somente com `0-9`.
- `IsError` deve ser checado antes de `CStr`; `Variant/Error` quebra helper.
- `Null` e `Empty` devem sair antes de qualquer conversao.
- IDs `>999` precisam decisao explicita. O `Pad3` atual truncaria `1000` para `"000"` se fosse usado diretamente; o plano diz gravar cru, mas isso precisa virar contrato e teste.
- `bypass:=True` e perigoso como API generica. Para compostos (`COD_SERV`, `COD_ATIV_SERV`) eu prefiro helper separado ou parametro nomeado muito explicito, porque bypass permite gravar ID simples sem normalizacao por engano.

Substituir os 5 Repos e seguro se for feito por dominios e com compile entre fases. Ponto especial: `Repo_Credenciamento.LerCredenciamento` precisa preservar a sentinela `"X"` em `COL_CRED_ATIV_ID`. A regra "normalizar so se digitos puros" resolve isso; `Pad3` direto nao resolve.

A remocao das duplicatas de `IdsIguais` e correta, mas deve entrar depois dos helpers, nao antes. `Menu_Principal.frm`, `Preencher.bas` e `Credencia_Empresa.frm` sao superficies de UI grandes; cada remocao precisa de compile e smoke local.

L40 (`TV2_RunE2E_FluxoNovo`) e necessario, mas o plano ainda nao define se o teste usa UI real, Services ou Repos. Para freeze, o valor esta em dados gerados em runtime; nao necessariamente em automacao visual. O criterio deve ser: IDs criados em runtime, persistencia textual verificada apos cada etapa e cleanup ou isolamento para nao poluir gates repetidos.

## 5. Onda 38.2.5 - integridade e migracao

Criar `TV2_RunIntegridadeBase_Estendida` e melhor do que alterar a assinatura de `TV2_RunIntegridadeBase`, por causa do signature freeze. Mas ha uma consequencia: o RVS atual continuara chamando a base antiga se o runner/central de testes nao for atualizado ou se o operador nao executar a estendida manualmente. O plano deve declarar qual gate chama CS_INT_06..11.

Sobre `Util_Migrar_IDS_Workbook`:

- Excluir `AUDIT_LOG` esta correto. `ID_AFETADO` tem tokens como `"CAD_OS"`/`"CONFIG"` e nao deve ser canonizado cegamente.
- O snippet do plano chama `MigrarColunaTextual("CREDENCIADOS", COL_CRED_COD_ATIV_SERV)` e comenta "composto, sem Pad3", mas a funcao proposta chamaria `GravarIdTextual` sem bypass. Isso e bug de especificacao.
- A lista de colunas deve incluir tambem `EMPRESAS_INATIVAS.COL_EMP_ID`, `ENTIDADE_INATIVOS.COL_ENT_ID`, `CREDENCIADOS.COL_CRED_ULT_OS`, `PRE_OS.COL_PREOS_OS_ID`, todos os FKs de `CAD_OS` (`OS_ID`, `ENT_ID`, `COD_SERV`, `EMP_ID`, `ATIV_ID`, `PREOS_ID`) e os FKs de `CAD_SERV`.
- Antes de migrar, a macro deve snapshotar formulas e abortar se encontrar formula em qualquer celula alvo. Grep no codigo versionado nao mostrou formulas de IDs operacionais, mas o workbook pode ter formulas manuais nao versionadas.
- A macro precisa preparar/restaurar protecao de abas ou rodar sobre abas ja desprotegidas por contrato operacional.
- Se o modulo for descartavel, o plano deve dizer como ele sera removido do workbook importado, nao apenas do git.

## 6. Riscos nao cobertos

| Risco | Achado |
|---|---|
| Eventos versionados | `rg` nao encontrou `Workbook_BeforeClose`, `Worksheet_Change` ou `Worksheet_Before*` em `src/vba`/incoming. Ha apenas `Auto_Open`/`IniciarSistema` e wrappers que desabilitam `Application.EnableEvents`. O plano esta seguro no codigo versionado. |
| Eventos/add-ins externos | `Personal.xlsb`, add-ins COM e eventos de Application nao sao versionados. Nao da para descartar. Antes da migracao, Mauricio deve rodar em instancia limpa do Excel ou listar/desabilitar add-ins. |
| Formulas no workbook | O codigo versionado so mostrou formulas em `Treinamento_Painel.bas`, nao em IDs operacionais. Isso nao prova o workbook real; a migracao deve auditar `HasFormula` nas colunas alvo. |
| Corrupcao apos 30 min | O gate de 30 min e util, mas nao cobre o incidente de ~3h. Manter 1 semana como criterio de freeze real. |
| Code-only incompleto | Risco P0: declaracoes module-level de `Cadastro_Servico` estao ausentes no `.code-only.txt` atual. |

## 7. Recomendacao de bastao

| Onda | Implementador recomendado | Auditor recomendado | Justificativa |
|---|---|---|---|
| 38.2.3 | Codex | Opus | E uma onda cirurgica com file:line, script/import e diagnostico. Codex deve implementar; Opus audita escopo, HBN e decisao de excecao tabu. |
| 38.2.4 | Codex | Opus + revisao pontual Antigravity | Helpers e repos exigem rigor mecanico. Antigravity deve revisar contrato sistemico dos helpers antes do import final. |
| 38.2.5 | Codex | Opus + Mauricio operacional | Auditoria/migracao exige file:line e muita checagem. Mauricio executa workbook; Opus valida evidencias e decide freeze. |

Cadencia D (Codex implementador + Opus auditor) e apropriada para as tres ondas, mas nao como monocultura. Para 38.2.4, uma revisao Antigravity do contrato `GravarIdTextual/LerIdTextual` e barata e reduz risco arquitetural. Opus deve evitar implementar tudo sozinho: o custo de contexto dele ja ficou alto no incidente.

## 8. Ajustes obrigatorios antes do hearback

| Prioridade | Ajuste | Motivo tecnico | Custo |
|---|---|---|---|
| P0 | Corrigir plano AT-1 para o bug de `.code-only.txt` com `Private WithEvents` + `Attribute mTxtBuscaTopo...` | `--apply` sozinho nao garante paridade; o drift nao e so trailing whitespace. | Medio |
| P0 | Proibir `Pad3` direto sobre `Variant` em AT-3/38.2.4 | `Pad3(ByVal Long)` falha para sentinelas/Null/Error e pode truncar >999 se mal usado. | Baixo/medio |
| P0 | Completar lista de colunas da migracao e tratar compostos com helper separado/bypass explicito | Evita corromper `COD_ATIV_SERV`, `COD_SERV`, inativas e referencias OS/PreOS. | Medio |
| P1 | Declarar como CS_INT_06..11 entram no gate RVS | Wrapper estendido sem chamada no gate vira teste esquecido. | Baixo |
| P1 | Especificar geracao/validacao dos manifestos L41 com formato real do Importador V3 | O exemplo atual e ilustrativo demais para uma IA executar sem conhecimento tacito. | Medio |
| P1 | AT-2 deve registrar uma linha por credenciamento novo e caminho CSV canonico | Evita diagnostico ambivalente quando ha multiplos servicos. | Baixo |
| P2 | Preflight de formulas/add-ins antes da migracao | Cobre workbook real e ambiente Excel nao versionado. | Baixo |
| P2 | Aumentar gate operacional final para 1 semana vinculante antes de tag | Ja previsto no plano; deve virar criterio nao negociavel do freeze. | Operacional |

## 9. Conclusao

Eu recomendo aprovar a Hipotese C, mas nao aprovar o plano "como esta". O plano deve incorporar os ajustes P0 acima antes do hearback `confirmed`. O ponto mais concreto e imediato e `Cadastro_Servico`: o plano classificou o drift como benigno/cosmetico, mas a evidencia local mostra diferenca de declaracoes module-level que afeta `WithEvents` e `Option Explicit`. Isso precisa ser resolvido antes de qualquer novo import ou RVS.
