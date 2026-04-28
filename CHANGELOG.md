# Changelog

Este projeto adota o espírito do Keep a Changelog. As mudanças aqui registradas
tratam apenas da linha pública oficial.

## [Unreleased]

### Adicionado (Onda 6 — consolidacao documental + integracao metodologica)

- **`AGENTS.md`** — entrada canonica para qualquer IA (padrao
  [agents.md](https://agents.md/)), substituindo a fragmentacao entre
  `CLAUDE.md`, `.cursorrules`, `.codex/`, etc. `CLAUDE.md` agora aponta
  para `AGENTS.md`.
- **`llms.txt`** — mapa curado para LLMs (padrao
  [llmstxt.org](https://llmstxt.org/)).
- **`llms-full.txt`** — indice exaustivo dos `.md` versionados.
- **`.hbn/`** — coordenacao inter-IA HBN-native:
  `relay/INDEX.md`, `relay/0001-onda06-consolidacao-documental.md`,
  `knowledge/{INDEX,0001-regras-v203-inegociaveis,0002-regra-ouro-vba-import,0003-glasswing-style-preventive-security}.md`,
  `readbacks/0001-onda06.json`, `reports/INDEX.md`, `results/INDEX.md`.
- **`auditoria/01_regras_e_governanca/00_REGRAS_V203_INEGOCIAVEIS.md`** —
  constituicao operacional da V12.0.0203 (10 regras inegociaveis,
  ratificadas por Mauricio em 2026-04-28).
- **`obsidian-vault/metodologia/`** — 4 documentos novos: `00-MAPA-DOCUMENTAL.md`,
  `01-COMO-A-IA-LE-ESTE-REPO.md`, `02-INTEGRACAO-USEHBN.md`,
  `03-PROTOCOLO-GLASSWING.md`. Vault revivido (Opcao A) com cadencia
  obrigatoria de update por onda fechada.
- **`local-ai/scripts/onda06-cleanup.sh`** — script unico para o operador
  rodar localmente (sandbox Cowork bloqueia `rm`/`mv`/`git rm`/`git mv`
  no fuse mount).

### Alterado (Onda 6)

- **`auditoria/` reorganizado por tipo** preservando numeracao
  historica: `00_status/`, `01_regras_e_governanca/`, `02_planos/`,
  `03_ondas/onda_NN_<tema>/`, `04_evidencias/`. `auditoria/40` e o
  novo `auditoria/41` ficam na raiz como sumarios cronologicos.
- **`docs/` reorganizado em quadrantes Diataxis**: `tutorials/`,
  `how-to/`, `reference/`, `explanation/`. Conteudo migrado preservando
  historia git.
- **`CLAUDE.md` refinado**: substitui "proibicao absoluta de
  `Mod_Types.bas`" por "intervencao planejada na Onda 9 com plano
  dedicado e aprovacao previa". Aponta para `AGENTS.md` como fonte
  canonica.
- **`local-ai/vba_import/README.md`** atualizado com referencia
  consolidada a Regra de Ouro e nota sobre macros descartaveis fora do
  pacote oficial.
- **`obsidian-vault/00-DASHBOARD.md`** atualizado para refletir Ondas
  1-5 + Onda 6, com cadencia de update obrigatoria por onda fechada.

### Removido (Onda 6)

- **`auditoria/39_REGRA_PACOTE_VBA_IMPORT.md`** — duplicacao consolidada
  em `auditoria/40` secao 4.1, em `local-ai/vba_import/000-REGRA-OURO.md`,
  e no novo `.hbn/knowledge/0002-regra-ouro-vba-import.md`. Conteudo
  preservado nas tres referencias.
- **5 macros descartaveis da raiz de `local-ai/vba_import/`**:
  `Diag_Imediato.bas`, `Diag_Simples.bas`, `Limpa_Base_Total.bas`,
  `Reset_CNAE_Total.bas`, `Set_Config_Strikes_Padrao.bas`. Movidas
  para `Projetos/backups/credenciamento/macros_descartaveis_v0203/` com
  mapa de retorno. Diag_Imediato sera reintroduzido na Onda 7 como
  cenario `RDZ_DIAG_001` automatizado.
- **~80 MB de backups historicos**: `backup_bateria_oficial/`,
  `V12-202-{L,M,N,O,P}/`, `BKP_forms/`, `backups/` movidos para
  `Projetos/backups/credenciamento/` (fora do repo publico).
  Repositorio publico cai de ~80 MB para alvo de < 10 MB.

### Integracao metodologica (Onda 6 — case study para o usehbn)

O Credenciamento adotou formalmente 4 protocolos externos compostos
com o HBN como base de coordenacao inter-IA:

| Protocolo | Documento | Papel |
|---|---|---|
| [HBN](https://usehbn.org) | `.hbn/`, `AGENTS.md`, readback/hearback | core de coordenacao |
| [Diataxis](https://diataxis.fr/) | `docs/{tutorials,how-to,reference,explanation}/` | docs para humanos |
| [llms.txt](https://llmstxt.org/) | `llms.txt`, `llms-full.txt` | docs para LLMs |
| [agents.md](https://agents.md/) | `AGENTS.md` | contrato unificado de agentes |
| Glasswing-style preventive | `.hbn/knowledge/0003-*.md` + 5 vetores G1-G5 | seguranca preventiva |

O `usehbn` recebeu 6 documentos novos formalizando essas integracoes:
`docs/EVOLUTION-POLICY.md`, `docs/INTEGRATION-{DIATAXIS,LLMS-TXT,AGENTS-MD,GLASSWING}.md`,
`docs/CASE-STUDY-CREDENCIAMENTO.md`. Detalhes em
`auditoria/03_ondas/onda_06_consolidacao_documental/41_TECNICO.md`.

### Importante (Onda 6)

- **Sem alteracao de codigo VBA.** Build do workbook permanece
  `f7aa84f+ONDA05-em-homologacao` — Onda 5 segue em homologacao manual
  do Mauricio.
- **Sem push para origin.** Apenas commit local. Push e decisao do
  Mauricio apos auditoria final.
- **Reversivel** via `git reset --hard pre-onda-06-2026-04-28`.

### Alterado

- **ONDA 5 — Determinismo no formulario de configuracao**: substituida
  a heuristica `CI_BuscarTextBoxPorLabel` (Label adjacente) pela leitura
  e gravacao DIRETA dos textboxes `TxtNotaCorte`, `TxtMaxStrikes`,
  `TxtDiasSuspensao` em `Configuracao_Inicial.frm`. Em conformidade com
  a regra V203 ("eliminar toda heuristica"). As 3 funcoes
  `CI_TextoTextBoxPorLabel`, `CI_DefinirTextoTextBoxPorLabel` e
  `CI_BuscarTextBoxPorLabel` foram REMOVIDAS do form. `On Error Resume
  Next` curto preserva compatibilidade com workbooks antigos
- **ONDA 5 — Limpa Base operacional robusta**: `Preencher.Limpa_Base`
  agora delega para o novo modulo `Mod_Limpeza_Base.LimpaBaseTotalReset`,
  que (a) detecta cabecalho corrompido e reescreve o cabecalho canonico,
  (b) usa `MAX(End(xlUp))` em colunas A..AT para evitar UsedRange
  "vazado", (c) limpa tambem `EMPRESAS_INATIVAS`, `ENTIDADE_INATIVOS`,
  `AUDIT_LOG` e `RELATORIO`. Preserva: `ATIVIDADES`, `CAD_SERV`,
  `CONFIG`. O caminho da interface (Configuracoes Iniciais > Limpar
  Base, com senha) agora garante limpeza idempotente — substitui o uso
  da macro descartavel `local-ai/vba_import/Limpa_Base_Total.bas`
- build atualizado para `f7aa84f+ONDA05-em-homologacao`

### Adicionado

- novo modulo `src/vba/Mod_Limpeza_Base.bas` com a funcao publica
  `LimpaBaseTotalReset(Optional ByRef relatorioOut As String) As Boolean`
  e helpers internos para detectar cabecalho corrompido e reescrever
  cabecalho canonico por aba; cria `RPT_LIMPEZA_TOTAL` com o resumo da
  operacao
- wire-up dos 3 campos novos em `Configuracao_Inicial.frm` (ONDA 4 da
  esteira Opus): tela ja exibida com Labels "Se a empresa receber XX
  avaliacoes menores que YY sera inabilitada por ZZ dias" agora le e
  grava em `CONFIG` as colunas `COL_CFG_NOTA_MINIMA` (K),
  `COL_CFG_MAX_STRIKES` (L) e `COL_CFG_DIAS_SUSPENSAO_STRIKE` (M);
  validacao defensiva: campos vazios ou fora da faixa permitida nao
  zeram a configuracao em vigor
- helper publico `Diag_RodizioStatus(ATIV_ID)` em `Svc_Rodizio.bas`
  que produz aba `RPT_DIAG_RODIZIO` com fotografia auditavel da fila:
  posicao, EMP_ID, STATUS_CRED, STATUS_GLOBAL, DT_FIM_SUSP, OS aberta,
  Pre-OS pendente e decisao prevista (`APTA`, `FILTRO_A..E`,
  `SEM_EMPRESA`); util para diagnosticar "sem empresas disponiveis"
  em testes manuais
- nova opcao `[16] Diag rodizio` na Central V2 (entrada interativa
  via `Diag_RodizioStatusInteractive`)
- nova suite `TV2_RunCfg` com 2 cenarios `CFG_001..002` validando ida
  e volta dos parametros de strikes via getters publicos em
  `Util_Config`
- nova opcao `[17] Configuracao de strikes: ida e volta` na Central V2
- dedup automatico de duplicatas em `ATIVIDADES` apos cada reset CNAE
  (ONDA 3 da esteira Opus): pares `(CNAE, DESCRICAO)` repetidos sao
  removidos preservando a primeira ocorrencia, e a contagem entra em
  `AUDIT_LOG` no campo `DUPLICATAS_REMOVIDAS`. Decisao do operador:
  duplicatas eram erro de import remanescente e nao devem persistir
- housekeeping de snapshots `CAD_SERV_SNAPSHOT_*`: o reset CNAE agora
  pergunta antes de podar snapshots antigos, mantendo os 5 mais
  recentes por default; auditoria registra `SNAPSHOTS_PODADOS=N`
- novas funcoes publicas em `Preencher.bas`:
  `CnaeRemoverDuplicatasAtividades()`,
  `CnaePodarSnapshots(manterUltimos)`,
  `CnaeConfirmarPodaSnapshots(manterUltimos)`
- `LimparAbaOperacional` exposta como `Public` em `Preencher.bas`
  (sem alteracao de comportamento) para permitir cobertura de
  regressao em `CNAE_006`
- 3 cenarios novos `CNAE_004..006` na suite `TV2_RunCnae` cobrindo
  dedup automatico, poda de snapshots com preservacao dos N recentes
  e regressao de `Limpa_Base` (ATIVIDADES e CAD_SERV intactos)
- snapshot automatico de `CAD_SERV` antes de cada reset CNAE (ONDA 2
  da esteira Opus): a aba `CAD_SERV_SNAPSHOT_<timestamp>` preserva o
  estado anterior das vinculacoes servico-atividade para reaproveitamento
  manual quando necessario; snapshots ficam protegidos com a senha
  padrao para evitar edicao acidental
- validacao automatica de duplicidade em `ATIVIDADES` apos cada reset
  CNAE: o reset agora reporta a quantidade de pares
  `(CNAE, DESCRICAO)` duplicados e registra esse numero em
  `AUDIT_LOG` via `EVT_TRANSACAO`, permitindo deteccao precoce de
  CSV mal formatado
- novas funcoes publicas em `Preencher.bas`:
  `CnaeSnapshotCadServ(qtdLinhasOut)`,
  `CnaeContarDuplicatasAtividades()`,
  `CnaeListarSnapshots()`
- nova constante `SHEET_PREFIX_CAD_SERV_SNAP` em `Const_Colunas.bas`
  para padronizar o prefixo das abas-snapshot
- nova suite `TV2_RunCnae` com 3 cenarios `CNAE_001..003` cobrindo
  criacao do snapshot, deteccao de duplicata via injecao controlada
  e coexistencia ordenada de multiplos snapshots
- nova entrada `[15] CNAE: snapshot e dedup` na Central V2
  (`Central_Testes_V2.CT2_ExecutarCnae`)
- regra de suspensao por strikes na avaliacao (ONDA 1 da esteira Opus):
  cada avaliacao com `MEDIA < NOTA_MINIMA` conta 1 strike; empresa e
  suspensa quando strikes acumulados atingem `MAX_STRIKES`; punicao
  passa a usar `DIAS_SUSPENSAO_STRIKE` em dias como prazo absoluto;
  defaults `NOTA_MINIMA=5.0`, `MAX_STRIKES=3`, `DIAS_SUSPENSAO_STRIKE=90`;
  retro-compatibilidade garantida: `MAX_STRIKES=1` reproduz a regra
  antiga (suspende na primeira nota baixa)
- novas colunas `COL_CFG_MAX_STRIKES` (L) e `COL_CFG_DIAS_SUSPENSAO_STRIKE`
  (M) na aba `CONFIG`; getters publicos `Util_Config.GetMaxStrikes`,
  `Util_Config.GetDiasSuspensaoStrike`
- helper `Repo_Avaliacao.ContarStrikesPorEmpresa(EMP_ID, notaCorte)`
  que conta on-the-fly avaliacoes ruins concluidas
- novo parametro opcional `diasSuspensao` em `Svc_Rodizio.Suspender`
  (default 0 mantem fallback em meses); auditoria de suspensao agora
  registra `BASE=DIAS|MESES`, `DIAS=N|MESES=N` e `MOTIVO=` quando
  informado
- nova suite `TV2_RunStrikes` com 7 cenarios `CS_AVAL_001..007` cobrindo
  acumulacao, nao-zeramento por avaliacao boa, suspensao em dias,
  retro-compatibilidade com MAX=1 e reativacao automatica
- nova entrada `[14] Strikes na avaliacao` na Central V2
  (`Central_Testes_V2.CT2_ExecutarStrikes`)
- contrato explícito de release com tag, diretório de evidência e chave pública de teste em `src/vba/App_Release.bas`
- camada de versionamento seguro com `release oficial`, `canal ativo`, `próxima release alvo` e `assinatura do build`
- rastreabilidade visual do pacote importado com `build importado`, `origem do build` e `pacote gerado em`
- novo cenário V2 `EXP_001` para validar expiração de Pre-OS com punição e retomada correta da fila
- proposta canônica `CS_*` para a Sprint 2 incorporada ao índice público e ao plano executável
- primeiro lote canônico `CS_00..CS_08` automatizado na V2
- cenário canônico `CS_22` automatizado para validar associação estável entre atividade e serviço em emissões repetidas
- cenários canônicos `CS_11` e `CS_13` automatizados para validar suspensão manual e reativação automática por prazo vencido
- cenários canônicos `CS_14`, `CS_16` e `CS_20` automatizados para validar suspensão por nota, retorno ordenado após prazo vencido e filtro cadastral de empresa inativa
- cenário canônico `CS_17` automatizado para validar giro longo `A,B,C,A,B,C,A` sem travamento e com integridade da fila
- cenário canônico `CS_18` automatizado para validar transições inválidas de OS concluída com rejeição auditável
- cenário canônico `CS_21` automatizado para validar completude mínima das famílias críticas do `AUDIT_LOG`
- cenários canônicos `CS_23` e `CS_24` automatizados para validar ida e volta de empresa e entidade entre cadastros ativos/inativos sem duplicidade semântica
- cenário `SMK_007` reforçado para validar auditoria mínima de fechamento e ausência de suspensão indevida em avaliação satisfatória
- cenário `ATM_001` reforçado para validar rollback multi-aba sem mutação residual em `EMPRESAS` e `CREDENCIADOS`, com mensagem legível de rollback
- cenário `STR_001` reforçado para validar IDs canônicos `001,002,003`, ausência de duplicidade semântica no item e quantidade final estável de credenciamentos
- extração inicial da montagem do payload de avaliação para `Svc_Avaliacao.bas`, reduzindo acoplamento no `Menu_Principal.frm`
- primeira extração da orquestração de emissão para `Svc_PreOS.bas` e `Svc_OS.bas`, reduzindo parsing e defaults locais no `Menu_Principal.frm`
- defaults da avaliação carregados diretamente da `CAD_OS`, com justificativa obrigatória quando houver edição de empenho, data, quantidade ou valor pré-preenchidos
- consistência da média da avaliação entre confirmação, persistência e impressão, usando um único cálculo canônico com duas casas decimais
- relatório imprimível da última execução V2 em `RPT_TESTES_V2`, com impressão opcional
- área documental `docs/testes/` para padronizar a narrativa humana das baterias de teste
- trilha cumulativa da suíte V2 em `TESTE_TRILHA` e `AUDIT_TESTES`
- limpeza opcional dos artefatos anteriores da V1 antes da nova execução
- fluxo da V1 unificado para um único ponto de impressão e sem exportação lateral no relatório
- limpeza opcional ampliada para remover artefatos V1/V2 e snapshots `SNAPV2_*`
- workflow de governança ampliado para verificar coerência entre versão, status oficial, tag, changelog e pacote de evidências
- documentação pública da esteira de release e evidência em `docs/GOVERNANCA_DE_RELEASE_E_EVIDENCIA.md`
- plano executável da Sprint 2 para fortalecimento incremental dos testes e redução de dependência da interface
- primeira fatia de `C3` incorporada: relatórios simples do `Menu_Principal` agora reutilizam helper comum de configuração de página
- padronização inicial dos relatórios com título acentuado, nome do relatório no rodapé e referência auditável automática para impressão
- validador consolidado de release encadeando V1 rápida, V2 Smoke e V2 Canônica em uma evidência copiável para IA
- manifesto candidato de evidências da `V12.0.0203` em `auditoria/evidencias/V12.0.0203/`

### Alterado

- endurecimento do `verify-docs.yml` para a linha pública pós-lançamento da `V12.0.0202`
- tela `Sobre` do sistema para diferenciar visualmente a release oficial `V12.0.0202` da próxima release alvo `V12.0.0203`
- tela `Sobre` reduzida para evitar truncamento do `MsgBox` do VBA e exibir o commit exato do pacote importado
- bateria oficial V1 passa a exportar CSV automático apenas quando houver falhas
- modo de execução da V1 renomeado na interface para distinguir `RÁPIDA` de `ASSISTIDA`, mantendo a mesma bateria com diferença apenas de pausa visual
- V1 automatizada deixa de sincronizar `CHECKLIST_136` ao vivo e passa a usar apenas `RESULTADO_QA` como saída automática
- `CHECKLIST_136` passa a ser tratada como planilha manual opcional, desacoplada da bateria automatizada
- modo `ASSISTIDA` da V1 com delay reduzido e rolagem reposicionada para manter a linha atual mais abaixo na tela
- mensagens finais e relatório da V1 deixam de destacar `MANUAL` quando a execução é 100% automática
- `Audit_Log` ganha a família `Validacao Rejeitada`
- `Audit_Log` passa a diferenciar inativação e reativação de empresa vs entidade na descrição legível do evento
- `Svc_Avaliacao` passa a registrar `Avaliacao Registrada` de forma explícita e sempre auditável
- backlog explícito para revisão futura da UX dos testes assistidos antes do fechamento da versão
- pacote local de importação passa a destacar `AAX-App_Release.bas` como obrigatório em toda microevolução parcial com rastreabilidade visual

### Validado

- build `20e400b-em-homologacao` importado em workbook de homologação, com `Sobre` exibindo commit, branch e data de geração do pacote
- compilação limpa confirmada por operador humano no build `20e400b-em-homologacao`
- Bateria Oficial V1 rápida validada em 2026-04-26 com `OK=171` e `FALHA=0`
- V2 Smoke validado em 2026-04-26 com `OK=14`, `FALHA=0` e sem CSV de falhas
- V2 Canônica validada em 2026-04-26 com `OK=20`, `FALHA=0` e sem CSV de falhas
- validador consolidado `VR_20260426_111549` aprovado com V1 rápida, V2 Smoke e V2 Canônica verdes

### Adiado

- promoção de `APP_RELEASE_ATUAL` para `V12.0.0203` até o fechamento formal da release
- desacoplamento total tela a tela da interface operacional
- reescrita do importador automático e revisão estrutural de `Mod_Types.bas`
- redesign visual completo dos testes assistidos e padronização visual profunda dos relatórios

## [V12.0.0202] - 2026-04-19

### Corrigido

- estabilização da chamada `AvaliarOS(...)` em workbooks restritivos
- consolidação da compilação após a linha de hotfixes da série `0194-0202`
- neutralização final do helper público de proteção de abas na árvore publicada

### Validado

- compilação limpa por operador humano
- bateria oficial recente sem falhas bloqueantes
- evidência pública da bateria oficial publicada em `auditoria/evidencias/V12.0.0202/`
- evidência fresca da V2 validada por operador humano e publicada no mesmo diretório
- auditoria positiva de pontos fortes consolidada em `auditoria/19_AUDITORIA_PONTOS_FORTES_V12_0202.md`

### Observações

- linha oficial registrada em [obsidian-vault/releases/STATUS-OFICIAL.md](obsidian-vault/releases/STATUS-OFICIAL.md)
- linha pública oficial promovida no `main`
- fechamento residual concentrado em homologação jurídica humana e automação adicional de governança
