---
titulo: Onda 38.2.21 - Formularios residuais code-only
diataxis: onda
hbn-track: safe_track
hbn-status: active
audiencia: ambos
versao-sistema: V12.0.0206
data: 2026-06-02
---

# Onda 38.2.21 - Formularios residuais code-only

## Contexto

A 38.2.19-fix1 deixou verde o fluxo principal de avaliacao por modulos e a
38.2.20 validou o atalho visual `IniciarSistema`. Ainda havia risco residual
em formularios: se algum caminho chamasse `AvaliarOS` diretamente com o
avaliador vazio, o servico podia registrar auditoria sem o nome do demandante,
mesmo com `MontarPayloadAvaliacao` ja corrigido.

Para evitar repetir o crash da 38.2.17, esta onda nao importa UserForms,
`.frx`, `ThisWorkbook`, `Auto_Open`, `Teste_V2_Engine` ou
`Teste_V2_Roteiros`.

## Decisao Tecnica

`Svc_Avaliacao.AvaliarOS` agora calcula `avaliadorEfetivo`:

- se `avaliador` vier preenchido, preserva o valor recebido;
- se vier vazio, resolve `OS_ID -> CAD_OS.ENT_ID -> ENTIDADE.NOME` por
  `ResolverDemandanteAvaliacaoPorOS`;
- se a resolucao falhar, rejeita a avaliacao antes de gravar qualquer dado;
- usa `avaliadorEfetivo` em `TAvaliacao` e nos eventos de auditoria.

Isso cria uma segunda linha de defesa no servico, sem depender do estado global
do formulario (`Desc_entidade`) nem da coluna visivel da lista.

## Teste V2

Foi criado `Teste_V2_Formularios_Residuais.bas` com:

```vb
TV2_RunFormulariosResiduaisCodeOnly
```

A suite cobre 6 asserts:

1. prepara duas OS em execucao com demandantes distintos (`Local 1` e `Local 2`);
2. valida que `AV_Lista` preserva o demandante correto por `OS_ID`;
3. valida que `MontarPayloadAvaliacao` com avaliador vazio resolve a OS correta
   mesmo com `Desc_entidade` obsoleto;
4. valida que `AvaliarOS` direto com avaliador vazio conclui a OS e registra
   `AVALIADOR=Local 2` no `AUDIT_LOG`;
5. valida que `ENT_ID` inexistente rejeita a avaliacao direta e preserva a OS em
   `EM_EXECUCAO`;
6. restaura o `ENT_ID` valido e confirma que o resolver volta a `Local 1`.

## Pacote V3

Manifesto:

`local-ai/vba_import/000-MANIFESTO-V3-DELTA-ONDA38_2_21_FORMULARIOS_RESIDUAIS_CODEONLY.txt`

Comando:

```vb
ImportarPacoteV3_Delta "ONDA38_2_21_FORMULARIOS_RESIDUAIS_CODEONLY", "e157221+ONDA38.2.21-FORM-RES-CODE"
```

Itens:

- `M|001-modulo/AAX-App_Release.bas`;
- `M|001-modulo/AAS-Svc_Avaliacao.bas`;
- `M|001-modulo/ABS-Teste_V2_Formularios_Residuais.bas`.

Resultado esperado do importador:

`M=3 | F=0 | err=0 | skip=0`

## Gate Humano

Depois do import:

1. VBE > Depurar > Compilar VBAProject.
2. Janela Imediata:

```vb
TV2_RunFormulariosResiduaisCodeOnly
```

Resultado esperado:

`OK=6 | FALHA=0 | MANUAL=0`

Se falhar, anexar o CSV `TesteV2_FORMULARIOS_RESIDUAIS_Falhas_*.csv` e nao
avancar para importacao de UserForms sem novo readback.

Resultado humano observado:

- importacao executada;
- compile limpo;
- `TV2_20260602_234618` retornou `OK=6 | FALHA=0 | MANUAL=0`;
- CSV de falhas: nao exportado.

## Nao Escopo

- Nao alterar `Menu_Principal.frm`, `Credencia_Empresa.frm` ou qualquer
  UserForm.
- Nao alterar `.frx`.
- Nao alterar `Auto_Open.bas`, `ThisWorkbook`, `Mod_Types.bas` ou
  `Importador_V3.bas`.
- Nao importar `Teste_V2_Engine.bas` ou `Teste_V2_Roteiros.bas`.
- Nao declarar freeze V206.
