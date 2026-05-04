---
titulo: 50 — Débito DT-MD17.1.e-STATUSBAR-HINT (dica visual no Modo Treinamento adiada)
diataxis: explanation
hbn-track: knowledge
hbn-status: active
audiencia: ambos
versao-sistema: V12.0.0203
data: 2026-05-03
autor: Claude Opus 4.7 (Cowork) — Frente 1 Credenciamento — sessão chat 3
licenca-target: TPGL-v1.1
---

# 50. Débito DT-MD17.1.e-STATUSBAR-HINT

## TL;DR

Operador (2026-05-03 chat 3) pediu para adicionar dica
"acompanhe o progresso na barra inferior à esquerda" no
**1º aviso (Modo Treinamento)**. O aviso vive em
[`src/vba/Menu_Principal.frm:628-634`](../../src/vba/Menu_Principal.frm#L628)
(`Private Function Treinamento_ConfirmarUso()`), portanto em
**form** (`.frm`). Tocar form na Onda 17 viola hard constraint C11
(`cap M10 = 0 imports em forms na Onda 17`). Decisão: **adiar para
próxima bateria de funcionalidades** quando C11 relaxar.

## 1. Pedido do operador

```
"3) na Mensagem inicial coloque uma mensagem para que a pessoa
acompanhe a evolução no teste na parte inferior à esquerda no excel"
[...]
"1) opçào 2., en Central V12; 2) Vamos avançar para as próximas
funcionalidades, coloque isso como função da próxima bateria que
vamos implementar. Vamos seguir."
```

## 2. Texto aprovado para a dica

```
Acompanhe o progresso no canto inferior esquerdo da tela
(barra de status com cenario atual / total).
```

## 3. Locais candidatos

| # | Local | Tipo | C11 | Pretendido pelo operador |
|---|---|---|---|---|
| 1 | `Menu_Principal.frm` `Treinamento_ConfirmarUso` (linha 630) | FORM | **viola** | ✅ literal |
| 2 | `Central_Testes.bas` `CT_AbrirCentral` (linha 37+) | módulo | OK | ✅ caminho 2 escolhido |
| 3 | `Central_Testes_V2.bas` `CT2_AbrirCentral` (linha 28+) | módulo | OK | recusado pelo operador (já entregue MD-17.1.e nessa tela) |

## 4. Decisão — adiar

Operador escolheu **adiar** integralmente em vez de aplicar
caminho 2 agora. Justificativa implícita: prefere implementar
no local literal pedido (Modo Treinamento, `.frm`) quando puder
tocar forms com segurança.

## 5. Resolução prevista

| Janela | Ação |
|---|---|
| **Onda 18** ou primeira oportunidade pós-Onda 17 com forms liberados | Editar `Menu_Principal.frm:628-634` adicionando duas linhas no `msg` antes de `Deseja continuar?`. Replicar em `Menu_Principal.code-only.txt` (M9). Validar via L22 (estrutura `.frm` vs `.code-only.txt`) + L24 (γ tolerante). |
| **Validação** | Operador abre form do treinamento, vê o MsgBox novo com a dica, confirma. Quarteto continua APROVADO sintaxe IDÊNTICA. |

## 6. Impacto operacional enquanto não resolvido

**Nenhum.** A status bar (L26+L27 oficial em MD-17.1.d) já
funciona desde a versão `MD1D2`. O usuário acompanha o progresso
SE souber olhar o canto inferior esquerdo. A única coisa que
falta é a **descoberta dirigida** (MsgBox que avisa onde olhar).
Sem a dica, o usuário descobre por exploração.

## 7. Documentos relacionados

- [49 — Transição chat 2 → 3](49_TRANSICAO_CHAT_NOVO_OPUS_47_2026_05_03_pt2.md)
- [`13_PROCEDIMENTO_IMPORT_MD17_1_e.md`](../03_ondas/onda_17_test_first/13_PROCEDIMENTO_IMPORT_MD17_1_e.md)
- [PHAGOCYTOSIS L26 + L27 (status bar oficial)](../../usehbn/docs/PHAGOCYTOSIS-VBA-PATTERNS.md)
- [`.hbn/knowledge/0001-regras-v203-inegociaveis.md`](../../.hbn/knowledge/0001-regras-v203-inegociaveis.md) §C11

## Versão

- v1.0 — 2026-05-03 — registro inicial.
