---
titulo: Regras V203 Inegociaveis
data: 2026-04-28
autoria: consolidacao da auditoria/40 secao 6, ratificada pelo Mauricio em 2026-04-28
aplica-a: toda IA e todo contribuidor humano que interaja com a linha V12.0.0203
revisar-em: fechamento estavel da V12.0.0203 no GitHub
status: vigente
---

# Regras V203 Inegociaveis

> Estas dez regras sao a constituicao operacional da linha V12.0.0203.
> Mudancas neste documento exigem release oficial com migration plan
> documentado. Ate la, vale exatamente como esta escrito aqui.
>
> Versao canonica espelhada em
> [`auditoria/01_regras_e_governanca/00_REGRAS_V203_INEGOCIAVEIS.md`](../../auditoria/01_regras_e_governanca/00_REGRAS_V203_INEGOCIAVEIS.md).

## 1. Bastao de implementacao

Definido por release. Quem nao tem bastao audita, propoe, mas nao edita
codigo. O bastao atual (Onda 6 em diante, ate V12.0.0203 estavel no
GitHub) esta com **Claude Opus 4.7 (Cowork)**, concedido por Luis
Mauricio Junqueira Zanin em 2026-04-28. Reverte para Codex (apoio) +
Claude Opus em modo auditoria apos a release publica.

## 2. Regra de Ouro do pacote

Tudo importavel para o `.xlsm` mora em `local-ai/vba_import/`, nas
pastas com prefixo alfabetico (`001-modulo/AAX-Nome.bas`,
`002-formularios/AAX-Nome.frm`, etc.), conforme manifesto. Sem excecao.
Detalhes em [`local-ai/vba_import/000-REGRA-OURO.md`](../../local-ai/vba_import/000-REGRA-OURO.md)
e em [`0002-regra-ouro-vba-import.md`](0002-regra-ouro-vba-import.md).

## 3. Heuristica zero na interface

Controles de formulario VBA acessados por nome canonico hardcoded.
Proibido: `InStr(Caption)`, `ctl.Top`, `ctl.Left`, `For Each ctl In Me.Controls`
para tomada de decisao. A regra V203 exige eliminacao total de heuristica
em todos os 13 forms ate o fechamento da release. Cumprimento parcial
nao conta — auditoria automatica em Onda 8 verifica via grep.

## 4. Idempotencia obrigatoria

Operacoes administrativas (Limpa_Base, Reset_CNAE, snapshot, dedup)
devem ser idempotentes: rodar 1x ou Nx produz o mesmo estado final.
Cobertura por familia de cenarios `IDM_*` em
`Teste_V2_Roteiros.bas` (entrega da Onda 7).

## 5. AUDIT_LOG cobre toda acao com efeito de estado

Cada `EmitirPreOS`, `AceitarPreOS`, `ConcluirOS`, `Suspender`, `Reativar`,
`Limpa_Base`, `Reset_CNAE`, `Avaliar`, mudanca de configuracao etc.
gera evento estruturado em `AUDIT_LOG` com tipo, identidade da entidade
afetada e timestamp. **Ausencia de evento e bug**, nao escolha de design.

## 6. Posicao de fila e imutavel sem motivo operacional declarado

Posicao na fila do rodizio so muda por: (a) recusa de Pre-OS, (b)
conclusao de OS com avanco, ou (c) operacao administrativa explicita
documentada em `AUDIT_LOG`. Suspensao (manual ou por nota) **nao** move
posicao. Quem nao cumpriu, fica onde estava.

## 7. Empresa nao e penalizada duas vezes

Apos cumprir suspensao (manual ou por nota), a empresa volta a posicao
original na fila. Nao reentra como ultimo. A nota baixa ja pune por N
dias — perder turno seria dupla penalizacao.

## 8. Sem novos modulos arquiteturais ate `0203` fechada

Mudanca funcional vai num modulo existente, ou e adiada. Excecao:
modulo de teste novo (familia `IDM_*`) na Onda 7, e reescrita do
`Importador_VBA.bas` na Onda 9.

## 9. `Mod_Types.bas` pode ser tocado APENAS na Onda 9

Reescrita do importador exige auditoria de `Mod_Types.bas` (definicoes
de `TConfig`, `TCredenciamento`, etc.). Plano dedicado e aprovacao
explicita do Mauricio sao pre-requisitos.

## 10. Nenhum arquivo importavel fora de `vba_import/`

Sem excecao. Importar a partir de `src/vba/`, `local-ai/incoming/`, ou
qualquer outro lugar quebra a auditabilidade hash do pacote. A IA que
desrespeitar a regra entrega trabalho **incompleto** por definicao.

## Como verificar

Toda IA, antes de declarar onda fechada, deve responder textualmente:

1. Quem tem o bastao agora? (regra 1)
2. Os arquivos modificados em `src/vba/` foram espelhados em
   `local-ai/vba_import/` com hash conferido? (regra 2)
3. `grep -E "InStr.*Caption|ctl\.Top|ctl\.Left" src/vba/*.frm` retorna
   zero ocorrencias? (regra 3)
4. Operacoes administrativas tocadas tem cenario IDM equivalente? (regra 4)
5. Cada acao com efeito de estado gera evento em `AUDIT_LOG`? (regra 5)
6. Posicao de fila so foi alterada por motivo operacional declarado? (regra 6)
7. Empresa reativada volta a posicao original? (regra 7)
8. Modulo novo introduzido foi explicitamente justificado? (regra 8)
9. `Mod_Types.bas` foi alterado? Se sim, e a Onda 9? (regra 9)
10. Algum import veio de fora de `vba_import/`? (regra 10)

Se qualquer resposta for ambigua, a onda **nao esta fechada**.
