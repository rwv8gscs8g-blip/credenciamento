---
titulo: Procedimento de importacao 0158 - Configuracoes Iniciais botoes e menus
diataxis: how-to
hbn-track: safe_track
hbn-status: active
audiencia: humano
versao-sistema: V12.0.0205
data: 2026-06-07
---

# Procedimento de importacao 0158 - Configuracoes Iniciais botoes e menus

## Pre-condicoes

- Workbook aberto no caminho `\\Mac\Home\Projetos\Credenciamento`.
- VBE com acesso ao projeto VBA.
- Nao importar a 0155.
- Nao executar VCR neste microdelta.

## Comando

Na Janela Imediata do VBE:

```vb
ImportarPacoteV3_Delta "ONDA38_2_28_CONFIG_BOTOES_MENUS", "293e44c+ONDA38.2.28-CONFIG-BOTOES-MENUS"
```

## Resultado esperado do Importador V3

```text
M=2 | F=0 | err=0 | skip=0
```

## Ordem de validacao

1. Importar o delta V3.
2. Compilar: `Depurar > Compilar VBAProject`.
3. Rodar na Janela Imediata:

```vb
TV2_RunTelaConfiguracoesIniciais
```

4. Esperado:

```text
OK=9 | FALHA=0 | MANUAL=0
```

5. Se houver falha, anexar o CSV de falhas e nao rodar VCR.

## Validacao humana opcional e segura

Abrir **Configuracoes Iniciais** e conferir:

- Ajuda abre a pagina HBN.
- Salvar Parametros continua salvando.
- Iniciar Novo Periodo pede confirmacao antes de alterar base.
- Limpar Base pede confirmacao ou abre formulario proprio antes de alterar base.
- X fecha a tela.

Nao confirmar fluxos destrutivos durante esta checagem se o objetivo for apenas
validar a presenca das protecoes.
