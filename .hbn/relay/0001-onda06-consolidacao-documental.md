---
titulo: Onda 6 — consolidacao documental + cleanup + integracao metodologica
ciclo: 0001
track: safe_track
status: ENCERRADO
agente: Claude Opus 4.7 (Cowork)
hearback: confirmed (Mauricio, 2026-04-28)
data-inicio: 2026-04-28
data-encerramento: 2026-04-28
escopo: doc-only — sem alteracao de codigo VBA
erp: ../results/0001-exec-onda06.json
summary: ../reports/0001-onda06-summary.md
commits: ["85d7459", "7e64622"]
---

> **CICLO ENCERRADO.** Este arquivo continua aqui ate a abertura do
> proximo ciclo (Onda 7 ou homologacao residual da Onda 5), quando sera
> movido para `.hbn/relay-archive/0001-onda06-consolidacao-documental.md`
> conforme contrato HBN.

# Onda 6 — consolidacao documental + cleanup

## Objetivo

Zerar a divida documental antes de qualquer codigo novo. Estabelecer a
metodologia hibrida HBN-core + Diataxis + llms.txt + AGENTS.md como base
permanente do projeto. Tornar Credenciamento a primeira vitrine real do
`usehbn` em producao.

## Mandato do Mauricio (2026-04-28)

1. Aprovou Proposta D (hibrido) com ajuste: o `usehbn` se torna a propria
   solucao mista, incorporando os melhores protocolos abertos.
2. Concedeu bastao de implementacao a Claude Opus ate V12.0.0203 estavel
   no GitHub.
3. Autorizou modo maximo de tokens.
4. Determinou aplicacao de protocolos preventivos de seguranca no estilo
   Project Glasswing / Claude Mythos (Anthropic, 2026-04).
5. Onda 5 ainda em homologacao — Onda 6 vem ANTES do retorno ao codigo.
6. Aprovou as 7 duvidas operacionais (todas as 7 respondidas).
7. Aprovou protocolo de execucao de 12 passos.

## Entregaveis

### Em Credenciamento

- [ ] `.hbn/` populado (relay, knowledge, reports, readbacks)
- [ ] `auditoria/39` apagado (duplicacao)
- [ ] backups historicos movidos para `Projetos/backups/credenciamento/`
- [ ] macros descartaveis movidas para `Projetos/backups/credenciamento/macros_descartaveis_v0203/`
- [ ] `auditoria/` reorganizado por tipo preservando numeracao
- [ ] `AGENTS.md`, `llms.txt`, `llms-full.txt` criados
- [ ] `docs/` reorganizado em quadrantes Diataxis (tutorials, how-to, reference, explanation)
- [ ] `CLAUDE.md` refinado (Mod_Types como Onda 9, link AGENTS.md)
- [ ] `CHANGELOG.md`, `README.md`, `docs/INDEX.md`, `local-ai/vba_import/README.md` atualizados
- [ ] Vault Obsidian revivido (Opcao A) com metodologia
- [ ] `auditoria/01_regras_e_governanca/00_REGRAS_V203_INEGOCIAVEIS.md` criado
- [ ] `auditoria/03_ondas/onda_06_consolidacao_documental/41_TECNICO.md` criado (UM doc)

### Em usehbn (paralelo)

- [ ] `docs/INTEGRATION-DIATAXIS.md`
- [ ] `docs/INTEGRATION-LLMS-TXT.md`
- [ ] `docs/INTEGRATION-AGENTS-MD.md`
- [ ] `docs/INTEGRATION-GLASSWING.md` (camada de seguranca preventiva)
- [ ] `docs/CASE-STUDY-CREDENCIAMENTO.md` (vitrine real)
- [ ] `docs/EVOLUTION-POLICY.md` (diretriz de incorporacao aberta)
- [ ] `README.md` atualizado com "Adopted External Protocols"
- [ ] `CHANGELOG.md` Unreleased: integracao 4-em-1

## Invariantes (NAO MUDAM nesta onda)

- Codigo VBA em `src/vba/` — Onda 6 nao toca
- `Mod_Types.bas` — intocado
- Build do workbook permanece `f7aa84f+ONDA05-em-homologacao` ate Onda 5
  ser homologada
- Trio minimo continua valido (V1=171/0, V2 Smoke=14/0, V2 Canonica=20/0)
- Regras V203 declaradas explicitamente em `00_REGRAS_V203_INEGOCIAVEIS.md`

## Out-of-scope

- Codigo VBA novo
- Cenarios de teste novos
- Cobertura de bugs em homologacao da Onda 5
- Push para origin (apenas commit local; push e decisao do Mauricio)

## Riscos residuais

- `git mv` em larga escala pode quebrar links cruzados nao detectados.
  Mitigacao: grep amplo antes + verificacao final.
- Mudancas em `docs/` podem afetar `docs/testes/` que tem links proprios.
  Mitigacao: leitura previa do `docs/testes/INDEX.md`.
- Diataxis aplicado parcialmente pode confundir. Mitigacao: fazer migracao
  COMPLETA dos arquivos existentes para os 4 quadrantes nesta onda.
- `usehbn` e meu repositorio paralelo — conflito potencial com trabalho de
  outro autor. Mitigacao: branch separado ou commits claramente marcados
  como "credenciamento case study".

## Plano de validacao final

1. `md5sum` entre `src/vba/` e `local-ai/vba_import/` em todos os modulos
2. `grep -r "auditoria/39"` em todo o repo deve retornar zero
3. `grep -r "auditoria/2[0-9]_"` em todo o repo deve apontar para a nova
   estrutura ou serem links absolutos preservados
4. `git status --short | grep -v "^M src/vba/"` deve mostrar apenas
   adicoes/movimentacoes da Onda 6 (sem residuos)
5. Trio minimo nao roda nesta onda (e responsabilidade do operador no
   workbook, e Onda 6 e doc-only)
