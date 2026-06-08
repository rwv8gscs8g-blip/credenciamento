---
titulo: Onda 38.2.27-fix1 - campo dias recusa/prazo acessivel por clique e Tab
diataxis: onda
hbn-track: safe_track
hbn-status: active
audiencia: ambos
versao-sistema: V12.0.0205
data: 2026-06-06
---

# Onda 38.2.27-fix1 - campo dias recusa/prazo acessivel por clique e Tab

## Origem

A 0154 foi importada, compilou e `TV2_RunTelaConfiguracoesIniciais` passou com
`OK=3 | FALHA=0 | MANUAL=0`. No gate humano visual, Mauricio identificou que o
campo da primeira linha, `suspender por 30 dia(s)`, ainda nao estava
editavel/acessivel e que a navegacao por Tab estava irregular.

## Diagnostico

O teste da 0154 verificava apenas propriedades logicas do controle:
`Enabled=True`, `Locked=False` e `TabStop=True`. Isso nao cobria a acessibilidade
real do campo no layout: largura util, prioridade visual sobre labels e ordem de
Tab.

O controle continua com nome tecnico legado `TxtMesesSuspensao` no `.frx`, mas
sua semantica V12.0.0206 e **dias de suspensao por recusa/prazo**.

## Alteracoes

| Arquivo | Alteracao |
|---|---|
| `src/vba/Configuracao_Inicial.frm` | Adiciona preparacao especifica de `TxtMesesSuspensao`: editavel, largura minima, altura minima, tooltip, ZOrder frontal e ajuste do label `dia(s).` adjacente. Define sequencia de Tab explicita para campos e botoes da tela. |
| `src/vba/Teste_V2_Roteiros.bas` | Endurece `CI_TELA_01_DIAS_RECUSA_EDITAVEL`: alem de `Enabled/Locked/TabStop`, exige `Width>=54` e `TabIndex` entre `TP_Valor` e `TxtNotaCorte`. |
| `src/vba/App_Release.bas` | Atualiza build para `293e44c+ONDA38.2.27-CONFIG-HELP-VCR-fix1`. |

## Pacote de Importacao

Manifesto:

`local-ai/vba_import/000-MANIFESTO-V3-DELTA-ONDA38_2_27_CONFIG_HELP_VCR_FIX1.txt`

Comando:

```text
ImportarPacoteV3_Delta "ONDA38_2_27_CONFIG_HELP_VCR_FIX1", "293e44c+ONDA38.2.27-CONFIG-HELP-VCR-fix1"
```

Esperado:

- Importador V3: `M=2 | F=1 | err=0 | skip=0`.
- Compile VBE limpo.
- Janela Imediata: `TV2_RunTelaConfiguracoesIniciais`.
- Esperado: `OK=3 | FALHA=0 | MANUAL=0`.

## Validacao Manual

Abrir **Configuracoes Iniciais** e confirmar:

1. clicar no campo `suspender por 30 dia(s)` posiciona o cursor no campo;
2. o valor pode ser apagado e digitado novamente;
3. a tecla Tab chega ao campo na sequencia da linha de recusa/prazo;
4. `Salvar Parametros` persiste o valor sem alterar a unidade, que permanece em dias.

## Decisao Sobre Tamanho do Campo

Sim, aumentar o tamanho do campo e adequado. Nesta onda o aumento e feito por
VBA em runtime, sem editar `.frx`, para reduzir risco de regressao no designer.
Se o visual ainda ficar apertado apos o fix1, a proxima acao correta sera uma
onda controlada de designer `.frx`.
