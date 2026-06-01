---
titulo: Auditoria cruzada curta - impressao V206 Onda 38.2.6
diataxis: status
hbn-track: safe_track
hbn-status: active
audiencia: ia
versao-sistema: V12.0.0205
data: 2026-05-31
---

# Auditoria cruzada curta - impressao V206 Onda 38.2.6

## Veredito

Sem bloqueador local para import dirigido da Onda 38.2.6, condicionado a:

- Importador V3 concluir `M=3 | F=1 | err=0`.
- Compile VBAProject passar limpo.
- `TV2_RunImpressaoIntegridade` retornar `OK=6 | FALHA=0 | MANUAL=0`.

## Pontos revisados

- BL-5: notas impressas em `IMP_AVALIA!N27:N36` passam por helper 0..10 antes
  de escrever no template.
- BL-6: fluxo `BE_ImprimeOS_Click` carrega endereco da entidade antes de
  `PreencherOS`.
- BL-7: `PreencherPREOS` preserva `N_OS` de exibicao, mas normaliza o ID antes
  de buscar dados em `PRE_OS`.
- FT-7: empenho da OS e lido de `N_Empenho.Value` e escrito em `EMITE_OS!D84`.

## Residuos

- O gate e dirigido; RVS completo permanece pendente para fase de freeze.
- `git diff --check` ainda reporta CRLF/trailing whitespace em linhas VBA
  adicionadas e em trechos sujos anteriores de `Teste_V2_Roteiros.bas`;
  esta onda preserva o formato importavel e nao higieniza blocos antigos
  para evitar diff fora do microdelta.
