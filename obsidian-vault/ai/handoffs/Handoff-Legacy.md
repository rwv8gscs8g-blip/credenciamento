# HANDOFF — Estado Atual do Projeto

**Data:** 10/04/2026
**Versao:** V12.0.0106 (retomada da V12-093)
**Status:** ESTAVEL — Compilada, funcional, pronta para producao

## O que aconteceu (V12.0.0094-V12.0.0105)

Tentativa de adicionar Util_CNAE.bas e renomear AppContext→Mod_AppContext gerou erro "Nome repetido: TConfig" impossivel de resolver por reimportacao. Apos 20+ ciclos de reimportacao e 3 meses de investigacao (encoding, ghost types, CRLF, CP1252), a causa raiz permanece nao confirmada — provavelmente um erro cascata falso do compilador VBA. Decisao: retornar a V12-093 como base e evoluir por microiteracoes.

## Planilha Ativa

`PlanilhaCredenciamento-Homologacao.xlsm` (raiz do projeto) — copia identica da V12-093

## Documentacao Obrigatoria (leia antes de modificar qualquer coisa)

1. `ESTRATEGIA-V12-106.md` — Plano completo de retomada e microdesenvolvimento
2. `ai-context/REGRAS_COMPILACAO_VBA.md` — Killer patterns que DESTROEM compilacao
3. `ai-context/architecture.md` — Arquitetura tecnica

## Fonte de Verdade

- `vba_export/` — Codigo fonte. EDITAR SEMPRE AQUI.
- `V12-093/vba_export_bkp/` — Backup da base estavel (referencia).
- `vba_import/` — Pacote de deploy gerado por `scripts/publicar_vba_import.sh`

## Regras Absolutas

1. 1 arquivo por iteracao
2. Compilacao obrigatoria apos cada mudanca
3. NUNCA renomear VB_Name sem testar
4. NUNCA usar colon patterns (Dim x As T: x = v)
5. NUNCA usar MkDir/Kill/Dir nativo
6. SEMPRE rode checklist pre-deploy
7. SEMPRE crie release note
8. SEMPRE faca backup do .xlsm antes
