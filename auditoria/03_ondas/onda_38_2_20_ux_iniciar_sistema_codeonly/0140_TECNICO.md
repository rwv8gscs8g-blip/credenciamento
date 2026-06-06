---
titulo: Onda 38.2.20 - UX IniciarSistema code-only
diataxis: onda
hbn-track: safe_track
hbn-status: active
audiencia: ambos
versao-sistema: V12.0.0206
data: 2026-06-02
---

# Onda 38.2.20 - UX IniciarSistema code-only

## Contexto

A 38.2.16-fix1 confirmou que `IniciarSistema` cria o marcador persistente
necessario para a protecao de abertura. Mauricio pediu uma forma visual na
planilha para acionar esse ponto de entrada quando o workbook estiver aberto e
o usuario estiver apenas olhando os dados.

Como a 38.2.17 mostrou risco alto em reimportar UserForm completo, esta onda
mantem uma fatia code-only: modulo padrao novo, teste V2 isolado e
`App_Release`.

## Decisao Tecnica

Foi criado `UX_IniciarSistema.bas` com:

- `UX_IniciarSistema_Instalar`: instala ou atualiza um shape
  `UX_BTN_INICIAR_SISTEMA`;
- `UX_IniciarSistema_Remover`: remove o shape para rollback/teste;
- `UX_InstalarAtalhoIniciarSistema`: macro humana para deixar o botao visivel;
- `UX_RemoverAtalhoIniciarSistema`: macro humana de remocao;
- validacao para evitar instalar shape em abas criticas de dados.

O shape usa:

- texto: `Iniciar Sistema`;
- `OnAction`: `IniciarSistema`;
- posicao padrao: ancora `J1` da aba operacional;
- idempotencia por nome estavel.

Nenhum evento de abertura foi alterado. `Auto_Open.bas`, `ThisWorkbook`,
UserForms, `.frx`, `Svc_Avaliacao.bas`, `Preencher.bas`, `Mod_Types.bas`,
`Importador_V3.bas`, `Teste_V2_Engine.bas` e `Teste_V2_Roteiros.bas`
permanecem fora do pacote.

## Teste V2

Foi criado `Teste_V2_UX_IniciarSistema.bas` com:

```vb
TV2_RunUXIniciarSistemaCodeOnly
```

A suite cobre 5 asserts:

1. instala o atalho visual em aba operacional;
2. valida `OnAction="IniciarSistema"`;
3. reexecuta o instalador e confirma que nao duplica shapes;
4. confirma que celulas sentinela `Z1/Z2` nao mudam;
5. remove/restaura o estado final conforme havia ou nao shape antes do teste.

O teste nao deixa o botao persistido quando ele nao existia antes. Para deixar
o botao visivel depois do gate verde, executar:

```vb
UX_InstalarAtalhoIniciarSistema
```

## Pacote V3

Manifesto:

`local-ai/vba_import/000-MANIFESTO-V3-DELTA-ONDA38_2_20_UX_INICIAR_SISTEMA_CODEONLY.txt`

Comando:

```vb
ImportarPacoteV3_Delta "ONDA38_2_20_UX_INICIAR_SISTEMA_CODEONLY", "e157221+ONDA38.2.20-UX-INICIAR-CODE"
```

Itens:

- `M|001-modulo/AAX-App_Release.bas`;
- `M|001-modulo/AAZ-UX_IniciarSistema.bas`;
- `M|001-modulo/ABR-Teste_V2_UX_IniciarSistema.bas`.

Resultado esperado do importador:

`M=3 | F=0 | err=0 | skip=0`

## Gate Humano

Depois do import:

1. VBE > Depurar > Compilar VBAProject.
2. Janela Imediata:

```vb
TV2_RunUXIniciarSistemaCodeOnly
```

Resultado esperado:

`OK=5 | FALHA=0 | MANUAL=0`

Se verde, executar:

```vb
UX_InstalarAtalhoIniciarSistema
```

Isso instala o botao visual na aba operacional resolvida pelo modulo. A onda
ainda nao esta validada no workbook: compile e teste dependem da importacao
manual por Mauricio.

## Veredito Local

Pacote V3 pronto para gate humano. Freeze V206 segue nao declarado.

## Resultado Humano

Mauricio reportou em 2026-06-02:

- importacao executada;
- compile limpo no VBE;
- `TV2_RunUXIniciarSistemaCodeOnly`: `TV2_20260602_205320` com
  `OK=5 | FALHA=0 | MANUAL=0`;
- CSV de falhas: `NAO_EXPORTADO`.

Veredito: 38.2.20 validada por V2 dirigido. O teste confirmou criacao,
`OnAction`, idempotencia, preservacao de celulas sentinela e limpeza/restauro
do atalho visual. O teste nao deixa o botao persistido quando ele nao existia
antes; para instalar o botao na aba operacional, executar:

```vb
UX_InstalarAtalhoIniciarSistema
```

Freeze V206 segue nao declarado.

## Observacao Pos-Instalacao

Mauricio executou a macro de instalacao e a Janela Imediata confirmou:

```text
UX_IniciarSistema_ResolverAba().Name = RESULTADO_QA_V2
UX_IniciarSistema_ContarAtalhos() = 1
UX_IniciarSistema_OnActionAtual() = IniciarSistema
```

Portanto o atalho foi instalado e aponta para a macro correta. Em seguida,
Mauricio localizou o botao no `J1` e confirmou que o clique funcionou. A
dificuldade inicial era apenas localizacao/viewport, nao falha do delta.
