---
titulo: Prompts para auditoria cruzada e handoff Codex
diataxis: onda
hbn-track: fast_track
hbn-status: active
audiencia: humano
versao-sistema: V12.0.0205
data: 2026-06-01
---

# Prompts para auditoria cruzada e handoff Codex

## Prompt 1 - Auditoria cruzada Opus

Voce e auditor independente do Sistema de Credenciamento V12.0.0206.
Raiz canonica: `/Users/macbookpro/Projetos/Credenciamento`.
Branch: `codex/v12-0-0206-planejamento`.
HEAD esperado: `e157221` (`feat: estabilizar performance ux 38.2.12`).

Objetivo: auditar de forma adversarial e objetiva as ondas `38.2.4` a
`38.2.12`, confrontando o que foi implementado contra o parecer arbitro
`.hbn/proposals/0024-Opus3-4-MAX-auditoria-gate-a4-l43-v206.md`.

Primeiro valide:

```bash
pwd
git rev-parse --show-toplevel
git status --short --branch
git worktree list
git log --oneline -5
```

Leia, nesta ordem:

1. `AGENTS.md`
2. `.hbn/relay/INDEX.md`
3. `.hbn/proposals/0024-Opus3-4-MAX-auditoria-gate-a4-l43-v206.md`
4. `.hbn/results/0120-exec-onda-38-2-4-integridade-estado.json`
5. `.hbn/results/0121-exec-onda-38-2-5-ui-regras-negocio.json`
6. `.hbn/results/0122-exec-onda-38-2-6-integridade-impressao.json`
7. `.hbn/results/0123-exec-onda-38-2-7-leitura-exibicao.json`
8. `.hbn/results/0124-exec-onda-38-2-8-config-baseline-v2.json`
9. `.hbn/results/0125-exec-onda-38-2-9-config-snapshot-v2.json`
10. `.hbn/results/0126-exec-onda-38-2-10-higiene-repositorio.json`
11. `.hbn/results/0127-exec-onda-38-2-11-sync-hbn-pos-commit.json`
12. `.hbn/results/0128-exec-onda-38-2-12-performance-ux-basica.json`
13. `CHANGELOG.md`
14. `auditoria/03_ondas/onda_38_2_12/0128_TECNICO.md`

Escopo da auditoria:

- Verificar quais itens do parecer 0024 estao resolvidos, parcialmente
  resolvidos, pendentes ou regressivos.
- Conferir especialmente: BL-1..BL-7, FT-1..FT-11, MG-1 e criterios C1..C6.
- Conferir se `Auto_Open.bas`, `Mod_Types.bas`, `Importador_V3.bas`,
  `Credencia_Empresa.frm` e `.frx` foram preservados quando declarados fora
  de escopo.
- Conferir se os testes V2 adicionados sao suficientes ou apenas estaticos.
- Conferir se ha risco de falso positivo no gate humano reportado por Mauricio.
- Nao implementar nada. Nao editar arquivos.

Formato da resposta:

1. Veredito: `APROVAR`, `APROVAR COM RESSALVAS` ou `BLOQUEAR`.
2. Tabela de achados por severidade: `BLOQUEADOR`, `FORTE`, `MARGINAL`.
3. Mapa 0024: item por item, com status `resolvido`, `parcial`, `pendente`,
   `nao auditado` ou `regressao`.
4. Lista das proximas ondas recomendadas, em ordem.
5. Decisao explicita: pode abrir FT-4/credenciamento em lote agora ou deve
   corrigir outro bloqueador antes?
6. Diga claramente que o freeze V206 continua bloqueado, salvo se voce
   encontrar evidencia contraria muito forte.

## Prompt 2 - Auditoria cruzada Antigravity/Gemini

Voce e auditor sistemico independente do Sistema de Credenciamento V12.0.0206.
Raiz canonica: `/Users/macbookpro/Projetos/Credenciamento`.
Branch: `codex/v12-0-0206-planejamento`.
HEAD esperado: `e157221` (`feat: estabilizar performance ux 38.2.12`).

Objetivo: fazer auditoria cruzada tecnica, com foco em risco sistemico,
regressao, cobertura de testes e integridade do protocolo HBN apos as ondas
`38.2.4` a `38.2.12`.

Primeiro valide:

```bash
pwd
git rev-parse --show-toplevel
git status --short --branch
git worktree list
git log --oneline --decorate -8
```

Leia:

1. `AGENTS.md`
2. `.hbn/relay/INDEX.md`
3. `.hbn/proposals/0024-Opus3-4-MAX-auditoria-gate-a4-l43-v206.md`
4. Todos os ERPs `.hbn/results/0120-*.json` ate `.hbn/results/0128-*.json`
5. Os readbacks correspondentes `.hbn/readbacks/0120-*.json` ate
   `.hbn/readbacks/0128-*.json`
6. `auditoria/03_ondas/onda_38_2_12/0128_TECNICO.md`
7. `CHANGELOG.md`

Analise obrigatoria:

- Execute apenas leitura/comandos de auditoria; nao altere arquivos.
- Use `git show --stat 882cd2b`, `git show --stat d2d7ac5` e
  `git show --stat e157221`.
- Verifique se os commits respeitam os escopos dos readbacks.
- Verifique se `local-ai/vba_import/` esta sincronizado com `src/vba/` pelo
  publicador, sem exigir import manual.
- Verifique se a sequencia de testes V2 cobre os riscos do 0024 ou deixa
  buracos relevantes.
- Dê atencao especial a FT-4, FT-9, FT-10, FT-11 e criterios C1/C5/C6.

Formato da resposta:

1. Sumario executivo em ate 10 linhas.
2. Tabela: `item 0024`, `evidencia`, `status`, `risco residual`.
3. Achados ordenados por severidade.
4. Lista curta de comandos/testes que Mauricio deve rodar antes do proximo
   freeze candidate.
5. Recomendacao: continuar no mesmo Codex, abrir novo handoff, ou abrir
   auditoria adicional.
6. Nao declarar freeze V206.

## Prompt 3 - Handoff para nova janela Codex

Voce e Codex implementador do Sistema de Credenciamento V12.0.0206.
Raiz: `/Users/macbookpro/Projetos/Credenciamento`.
Branch: `codex/v12-0-0206-planejamento`.
HEAD esperado: `e157221` (`feat: estabilizar performance ux 38.2.12`).

Contexto curto:

- V12.0.0205 permanece release oficial.
- V12.0.0206 esta em validacao iterativa; nao ha freeze declarado.
- O parecer arbitro `0024` bloqueou freeze e organizou as ondas.
- Ja foram entregues e testadas por Mauricio:
  - `38.2.4` integridade de estado;
  - `38.2.5` UI de regras de negocio;
  - `38.2.6` integridade de impressao;
  - `38.2.7` leitura/exibicao;
  - `38.2.8` CONFIG baseline;
  - `38.2.9` CONFIG snapshot V2;
  - `38.2.10` higiene/commit;
  - `38.2.11` sync HBN;
  - `38.2.12` performance/UX basica, commit `e157221`.
- Ultimo gate humano: `TV2_RunPerformanceUXBasica` retornou
  `OK=5 | FALHA=0 | MANUAL=0`, execucao `TV2_20260601_004135`.
- Worktree estava limpo apos o commit `e157221`.

Diretrizes obrigatorias:

- Antes de ler ou editar: validar `pwd`, `git rev-parse --show-toplevel`,
  `git status --short --branch`, `git worktree list`.
- Nao tocar `Auto_Open.bas` sem excecao explicita.
- Nao tocar `Mod_Types.bas` ou `Importador_V3.bas`.
- Nao propagar o padrao de Entidades para outros fluxos sem readback proprio.
- Nao declarar freeze V206.
- Preservar a cautela sobre espacos finais em VBA; nao rodar limpeza generica.
- Toda nova implementacao exige readback safe_track, hearback confirmado,
  pacote V3, teste V2 dirigido e ERP.

Leia, nesta ordem:

1. `AGENTS.md`
2. `.hbn/relay/INDEX.md`
3. `.hbn/proposals/0024-Opus3-4-MAX-auditoria-gate-a4-l43-v206.md`
4. `.hbn/results/0128-exec-onda-38-2-12-performance-ux-basica.json`
5. `auditoria/03_ondas/onda_38_2_13_auditoria_cruzada/0129_PROMPTS_AUDITORIA_HANDOFF.md`

Objetivo imediato recomendado:

Abrir Onda `38.2.13` de auditoria cruzada consolidada, sem implementar codigo,
para consolidar o que ficou resolvido/parcial/pendente contra o parecer 0024.
Depois da auditoria cruzada, decidir se a proxima onda de implementacao deve
ser FT-4 credenciamento em lote ou designer residual FT-9/FT-10.

Se Mauricio preferir implementar imediatamente:

- Abra readback safe_track especifico.
- Escopo mais provavel: FT-4 credenciamento em lote.
- Nao implemente antes do hearback.
- Propor teste V2 que valide sequencia `CRED_ID`/AR1 e tempo de execucao.
