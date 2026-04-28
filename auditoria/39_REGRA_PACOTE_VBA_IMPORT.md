---
titulo: Regra de Ouro — pacote vba_import e o motivo da regressao "Mod_Limpeza_Base"
natureza-do-documento: registro do incidente + ata da regra absoluta
versao-oficial-vigente: V12.0.0202
linha-alvo: V12.0.0203
data: 2026-04-28
autor: Claude Opus 4.7 (sessao Cowork) a partir de instrucao do Mauricio
---

# 39. Regra de Ouro — pacote `vba_import/`

## 00. Contexto operacional

Em 28/04/2026, durante a entrega da Onda 5, o assistente entregou o
novo modulo `Mod_Limpeza_Base.bas` em `src/vba/` e instruiu a importacao
manual via VBE a partir desse caminho. **Quebrou a regra do projeto.**

O Mauricio interrompeu a entrega com a observacao:

> "O mod_limpeza_base.bas nao esta na pasta local-ai/vba_import/001-modulo.
> Temos uma regra do sistema que apos as modificacoes TUDO o que for
> importado DEVE obrigatoriamente estar na pasta VBA_import. Ali dentro
> temos a separacao por modulos com nomenclaturas com prefixo em ordem
> alfabetica para garantir que nao exista importacao errada. Nao e
> possivel subir para o sistema enquanto vc nao colocar o modulo no
> local certo."

Esta auditoria registra a regra, o incidente e a correcao.

## 01. A regra absoluta

**Tudo que vai ser importado para o workbook `.xlsm` precisa estar em
`local-ai/vba_import/`, na pasta correspondente ao tipo de componente,
com prefixo alfabetico que define a ordem de import.**

Texto operacional completo: `local-ai/vba_import/000-REGRA-OURO.md`.

## 02. Por que a regra existe (rationale tecnico)

### 02.1 Ordem de import importa

VBA tem dependencias estaticas. Se `Modulo_A` chama `Sub` de `Modulo_B`,
e `Modulo_A` for importado antes de `Modulo_B`, a compilacao falha. O
prefixo alfabetico `AAA-`, `AAB-`, ... `ABJ-` ordena a importacao
deterministicamente.

### 02.2 `Mod_Types.bas` e tabu

Reimportacao manual desse modulo ja gerou regressao estrutural varias
vezes (erro cascata de `TConfig`). O pacote em `vba_import/` mantem
`Mod_Types` em `001-modulo/AAA-Mod_Types.bas` como referencia, mas a
regra operacional e: **nao reimportar em microevolucao**.

### 02.3 `.frx` e binario do designer

Cada `.frm` precisa ter o `.frx` correspondente do mesmo workbook real
(com os controles renomeados pelo gestor). Reimportar `.frm` via
"Import File" sobrescreve `.frx` e perde renomeacoes. Por isso forms
em workbook estabilizado sao atualizados via arquivo `.code-only.txt`
(criado nessa onda como padrao novo).

### 02.4 Automacao futura

O futuro automatizador (substituto do `publicar_vba_import.sh`
descontinuado) consumira `000-MANIFESTO-IMPORTACAO.txt` e
`000-MAPA-PREFIXOS.txt` como contrato. Cada onda precisa atualizar
esses arquivos. Sem isso, a automacao falha silenciosamente.

### 02.5 Auditabilidade

O hash de cada arquivo em `vba_import/` precisa bater com o equivalente
em `src/vba/`. Quando bate, qualquer auditor externo prova que o
workbook reflete o repositorio. Quando nao bate, ha desvio operacional.

## 03. O incidente da Onda 5

### 03.1 O que aconteceu

1. Assistente criou `src/vba/Mod_Limpeza_Base.bas` (novo modulo).
2. Assistente atualizou `src/vba/Preencher.bas`, `App_Release.bas`,
   `Configuracao_Inicial.frm`.
3. Assistente escreveu `auditoria/37` e `auditoria/38` e instruiu o
   import a partir de `src/vba/`.
4. **Assistente NAO copiou nada para `local-ai/vba_import/`.**
5. Mauricio detectou e interrompeu.

### 03.2 O que foi corrigido em 28/04/2026 (apos a interrupcao)

Hash sincronizado entre `src/vba/` e `local-ai/vba_import/`:

| Origem | Destino |
|---|---|
| `src/vba/Mod_Limpeza_Base.bas` | `local-ai/vba_import/001-modulo/ABJ-Mod_Limpeza_Base.bas` |
| `src/vba/Preencher.bas` | `local-ai/vba_import/001-modulo/AAU-Preencher.bas` |
| `src/vba/App_Release.bas` | `local-ai/vba_import/001-modulo/AAX-App_Release.bas` |
| `src/vba/Configuracao_Inicial.frm` | `local-ai/vba_import/002-formularios/AAC-Configuracao_Inicial.frm` |

Manifesto e mapa atualizados:

- `000-MANIFESTO-IMPORTACAO.txt` ganhou linha `M|001-modulo/ABJ-Mod_Limpeza_Base.bas`.
- `000-MAPA-PREFIXOS.txt` ganhou entrada `ABJ-Mod_Limpeza_Base.bas => Mod_Limpeza_Base.bas`.
- `000-BUILD-IMPORTAR-SEMPRE.txt` atualizado para `f7aa84f+ONDA05-em-homologacao`.

Documentacao da regra criada em multiplos pontos para evitar nova
ocorrencia:

- `local-ai/vba_import/000-REGRA-OURO.md` (texto canonico da regra).
- `local-ai/vba_import/README.md` atualizado (script proibido, fluxo
  manual descrito, nota para IA).
- `CLAUDE.md` na raiz do projeto (instrucao para assistentes de IA).
- `auditoria/39_REGRA_PACOTE_VBA_IMPORT.md` (este arquivo).

### 03.3 Bug derivado (erro de compilacao no form)

Como consequencia adicional, o procedimento `auditoria/38` instrucao
02.4 era ambiguo. Ao copiar o conteudo do `.frm` para o editor de
codigo do VBE, o Mauricio incluiu sem perceber as 15 linhas iniciais
de cabecalho (`VERSION 5.00`, `Begin {GUID}...End`, `Attribute VB_*`).
Isso gerou:

> Erro de compilacao: Invalido fora de um procedimento

**Correcao:** criado o arquivo
`local-ai/vba_import/002-formularios/AAC-Configuracao_Inicial.code-only.txt`
contendo apenas o codigo VBA sem o cabecalho FRM, pronto para colar.
A instrucao 02.4 do `auditoria/38` foi reescrita apontando para esse
arquivo e descrevendo recuperacao em caso de erro identico.

A partir desta onda, todo form alterado deve gerar o
`.code-only.txt` correspondente como padrao do pacote.

## 04. Checklist canonico por onda (a partir da Onda 5)

Toda onda que mexe em VBA deve, OBRIGATORIAMENTE, deixar:

- [x] Cada `.bas` modificado em `src/vba/` espelhado em
      `local-ai/vba_import/001-modulo/AAX-Nome.bas` com hash batendo.
- [x] Cada `.frm` modificado em `src/vba/` espelhado em
      `local-ai/vba_import/002-formularios/AAX-Nome.frm` com hash batendo.
- [x] Para forms cujo codigo foi alterado mas o designer nao, gerar o
      `.code-only.txt` correspondente em `002-formularios/`.
- [x] Modulos NOVOS adicionados a `000-MANIFESTO-IMPORTACAO.txt`.
- [x] Modulos NOVOS adicionados a `000-MAPA-PREFIXOS.txt`.
- [x] `000-BUILD-IMPORTAR-SEMPRE.txt` atualizado com novo APP_BUILD.
- [x] `App_Release.bas` (`AAX-App_Release.bas`) atualizado com a nova
      string de build.
- [x] `auditoria/NN_PROCEDIMENTO_IMPORT_MANUAL_SEGURO_ONDA_NN.md` lista
      o caminho com prefixo de cada arquivo a importar.

Para a Onda 5 todos os itens estao verdes apos a correcao do dia
28/04/2026.

## 05. Compromisso

A partir desta data:

1. Toda entrega da esteira (todas as ondas seguintes) sera ENTREGUE
   com `vba_import/` ja sincronizado, sem precisar de intervencao
   manual do operador.
2. Toda entrega que afeta forms entrega tambem o arquivo `.code-only.txt`.
3. O assistente confere hash com `md5sum` ao final de cada onda e
   reporta o resultado.
4. Se o assistente esquecer, qualquer instrucao de import deve ser
   tratada como invalida pelo operador, com mensagem padrao:
   "Bloqueado pela Regra de Ouro — arquivo nao esta em vba_import/."
