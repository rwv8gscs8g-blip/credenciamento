---
titulo: Onda 38.2.28 - Configuracoes Iniciais botoes e menus
diataxis: onda
hbn-track: safe_track
hbn-status: active
audiencia: ambos
versao-sistema: V12.0.0205
data: 2026-06-07
---

# Onda 38.2.28 - Configuracoes Iniciais botoes e menus

## Origem

A 0156 fechou o problema visual do campo `suspender por 30 dia(s)`: importou,
compilou, passou `TV2_RunTelaConfiguracoesIniciais` e Mauricio confirmou clique,
edicao e salvamento. A 0157 transferiu o bastao para continuar a validacao tela a
tela cobrindo botoes, menus, submenus, entrada, saida e fechamento.

## Classificacao

Nao foi identificado novo defeito geometrico nesta onda. A lacuna era de
cobertura de comportamento e contrato: a tela tinha campos validados, mas os
botoes e rotas ligados a ela ainda nao estavam inventariados no teste dirigido.

Por isso, a 0158 e **test-only + build label**:

- sem alteracao em `Configuracao_Inicial.frm`;
- sem alteracao em `Configuracao_Inicial.frx`;
- sem alteracao em `Menu_Principal.frm`;
- sem execucao automatica de fluxos destrutivos.

## Inventario de Cobertura

| Controle ou fluxo | Classe | Acao esperada | Cobertura 0158 |
|---|---|---|---|
| Ajuda | codigo/evento | abrir HTML HBN da tela | controle existe, HTML existe e handler chama `CI_AbrirAjudaHBN` |
| Salvar Parametros | persistencia | validar e gravar CONFIG | round-trip automatizado em `CI_TestarPersistenciaPainel` |
| Iniciar Novo Periodo | fluxo administrativo destrutivo | backup, confirmacao e limpeza de PRE_OS/CAD_OS | contrato estatico de confirmacoes e `SaveCopyAs`; nao executado automaticamente |
| Limpar Base | fluxo administrativo destrutivo | abrir formulario proprio ou fallback com confirmacao | contrato estatico; fallback global tambem exige confirmacao |
| Menu inicial > Configuracoes Iniciais | codigo/evento | abrir `Configuracao_Inicial` modal | handler `B_Config_Inicial_Click` validado estaticamente |
| Menu inicial > Central de Testes | codigo/evento | abrir Central de Testes apos confirmacao aplicavel | handlers nomeados e legado `CommandButton15` validados |
| Menu inicial > Sobre | codigo/evento | mostrar dados de release e autoria | handler nomeado e legado `CommandButton13` validados |
| Menu inicial > GitHub | codigo/evento | abrir URL oficial ou mostrar fallback | handler nomeado e legado `CommandButton14` validados |
| Menu lateral | navegacao | preservar rotas principais do sistema | handlers principais validados estaticamente |
| X da janela | fechamento | permitir fechamento sem trava customizada | ausencia de `UserForm_QueryClose`/`Cancel=True` na tela |

## Alteracoes

| Arquivo | Alteracao |
|---|---|
| `src/vba/Teste_V2_Roteiros.bas` | Amplia `TV2_RunTelaConfiguracoesIniciais` de 3 para 9 asserts, cobrindo botoes, fluxos administrativos guardados, atalhos do menu inicial, rotas laterais e fechamento pelo X. |
| `src/vba/App_Release.bas` | Atualiza build para `293e44c+ONDA38.2.28-CONFIG-BOTOES-MENUS`. |
| `docs/tutorials/MANUAL_OPERACIONAL_TELA_A_TELA.md` | Documenta entradas, saidas, menus e criterios de aprovacao ampliados. |
| `docs/reference/testes/GUIA_DE_TESTES_E_VALIDACAO.md` | Atualiza escopo da suite dirigida de Configuracoes Iniciais. |
| `CHANGELOG.md` e `auditoria/INDEX.md` | Registram a onda 38.2.28. |

## Pacote de Importacao

Manifesto:

`local-ai/vba_import/000-MANIFESTO-V3-DELTA-ONDA38_2_28_CONFIG_BOTOES_MENUS.txt`

Comando:

```text
ImportarPacoteV3_Delta "ONDA38_2_28_CONFIG_BOTOES_MENUS", "293e44c+ONDA38.2.28-CONFIG-BOTOES-MENUS"
```

Esperado:

- Importador V3: `M=2 | F=0 | err=0 | skip=0`.
- Compile VBE limpo.
- Janela Imediata: `TV2_RunTelaConfiguracoesIniciais`.
- Esperado: `OK=9 | FALHA=0 | MANUAL=0`.

## Validacao Manual Segura

Depois do teste dirigido, o operador pode abrir **Configuracoes Iniciais** e
conferir visualmente:

1. Ajuda abre a pagina HBN;
2. Salvar Parametros mantem o comportamento ja validado;
3. Iniciar Novo Periodo apresenta confirmacoes antes de alterar base;
4. Limpar Base apresenta formulario/confirmacao antes de alterar base;
5. X fecha a tela.

Nao executar VCR neste microdelta. A VCR permanece reservada para checkpoint
forte.

## Resultado do Gate

Mauricio reportou em 2026-06-07:

- Importador V3 OK: `modo=Estabilizado | dryRun=Falso | M=2 | F=0 | err=0 | skip=0`;
- backup V3: `20260607_005702-V3-FULL`;
- compile VBE limpo;
- `TV2_20260607_005745` com `OK=9 | FALHA=0 | MANUAL=0`;
- CSV de falhas nao exportado porque nao houve falhas.

Com isso, a etapa 0158 fica fechada por import, compile e teste dirigido.
