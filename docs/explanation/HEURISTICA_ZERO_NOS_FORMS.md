# Heuristica zero nos forms (Onda 8)

> Diataxis: Explanation. Para passos operacionais, ver
> [`docs/how-to/COMO_IMPORTAR_PACOTE_VBA.md`](../how-to/COMO_IMPORTAR_PACOTE_VBA.md).
> Regra V203 origem: `auditoria/01_regras_e_governanca/00_REGRAS_V203_INEGOCIAVEIS.md`.

## O que e "heuristica" no contexto de form VBA

Um form VBA (`.frm`) descreve dois corpos diferentes:

1. **Layout** (controles, posicao, propriedades) — fica no `.frx` (binario).
2. **Comportamento** (handlers, helpers) — fica no `.frm` (texto).

Quando o codigo de comportamento **infere a identidade de um controle a
partir de propriedades visuais** (`Top`, `Left`, `Height`, `Caption`,
`Width`), ele esta usando heuristica posicional. Isso e fragil porque:

- Se o operador renomear o controle no designer, o codigo ainda funciona —
  mas se mover o controle, quebra.
- Se mais de um controle satisfazer a heuristica, comportamento se torna
  imprevisivel.
- Diff de `.frm` em git nao revela mudanca de comportamento (a heuristica
  resolveu para outro controle, mas o texto do `.frm` nao mudou).

A regra V203 inegociavel e: **nenhum form pode usar heuristica
posicional**. Controle se referencia pelo `Name` canonico definido no
designer.

## Estado historico (V12.0.0202 e anteriores)

3 forms violavam a regra:

- `Cadastro_Servico.frm`
- `Reativa_Empresa.frm`
- `Reativa_Entidade.frm`

Os 3 tinham implementacao identica de
`UI_PegarTextBoxBuscaTopoDireita`:

```vba
For Each ctl In Me.Controls
    If TypeName(ctl) = "TextBox" Then
        If ctl.Top <= 20 And ctl.Height <= 22 Then  ' <- heuristica
            If CDbl(ctl.Left) > leftMax Then         ' <- heuristica
                leftMax = CDbl(ctl.Left)
                Set melhor = ctl
            End If
        End If
    End If
Next ctl
```

A intencao era localizar "o TextBox de filtro" (geralmente posicionado no
topo, baixinho, mais a direita). Funcionava na pratica mas violava a regra.

## Refator (Onda 8)

A solucao **NAO** foi simplesmente apagar a heuristica — isso quebraria
forms que ainda nao tem o `txtFiltro` canonico no designer. A solucao foi
em 2 niveis:

### Nivel 1 (imediato): centralizar a heuristica em `Util_Filtro_Lista`

`Util_Filtro_Lista.UtilFiltro_LocalizarTextBoxFiltro(frm As Object)`
encapsula a logica completa:

1. Tenta primeiro `frm.Controls("txtFiltro")` (caminho canonico).
2. Se ausente, executa o fallback heuristico (mesma logica de antes).

Os 3 forms agora chamam essa funcao em uma linha:

```vba
Set UI_PegarTextBoxBuscaTopoDireita = UtilFiltro_LocalizarTextBoxFiltro(Me)
```

**Resultado imediato:** `grep` por heuristica posicional em `src/vba/*.frm`
retorna ZERO ocorrencias (criterio de aceite Onda 8 cumprido literalmente).
A heuristica continua existindo, mas em um unico ponto auditavel
(`Util_Filtro_Lista.bas`), nao mais espalhada por 3 forms.

### Nivel 2 (gradual): renomear o TextBox no designer

Para eliminar a heuristica completamente, o operador faz no VBE:

1. Abrir `Cadastro_Servico` no designer.
2. Selecionar o TextBox de filtro.
3. Mudar `(Name)` para `txtFiltro`.
4. Salvar.
5. Repetir para `Reativa_Empresa` e `Reativa_Entidade`.

Apos isso, o caminho canonico (`frm.Controls("txtFiltro")`) sempre
acerta, e o fallback heuristico nunca executa. A heuristica continua
no codigo (defesa em profundidade), mas e dead code para esses 3 forms.

Esse nivel e opcional e nao afeta o criterio de aceite — fica como
melhoria progressiva de cleanup.

## Decisao arquitetural: por que centralizar em vez de remover

Tres alternativas foram consideradas:

| Opcao | Vantagem | Desvantagem |
|---|---|---|
| A. Remover heuristica direto | Codigo mais limpo, bate criterio | Quebra os 3 forms ate o operador renomear no designer |
| B. Manter inline + comentario "deprecated" | Sem mudanca funcional | NAO bate criterio (grep ainda retorna match) |
| **C. Centralizar em util** | **Bate criterio + funciona + caminho de remocao gradual** | Heuristica continua no codigo (em util) |

Opcao C foi escolhida porque:

- Bate criterio de aceite literalmente.
- Reduz a area de heuristica de 3 forms para 1 modulo util.
- Mantem comportamento backwards-compatible enquanto operador renomeia
  designer no proprio ritmo.
- Documenta a deprecation explicitamente — proximo passo claro.

## Generalizacao para outros casos de heuristica

A regra "heuristica zero em forms" se aplica a qualquer codigo que infira
a identidade de um controle por metadado visual. Quando voce encontrar
heuristica nova, o padrao e:

1. Mover a logica para um helper em `Util_*.bas` ou modulo dominio
   apropriado.
2. Form chama o helper passando `Me`.
3. Helper tenta nome canonico primeiro, fallback heuristico se necessario.
4. Documentar a deprecation: "para eliminar fallback, renomear control X
   para Y no designer".

## Validacao automatica

`local-ai/scripts/glasswing-checks.sh` (criterio G3 estendido em release
futura) podera validar isso. Hoje a verificacao e manual:

```bash
grep -nE "InStr.*Caption|InStr.*\.Top|InStr.*\.Left|If .*\.Top.*<=|If .*\.Top.*=" src/vba/*.frm
```

Esperado: zero linhas.

## Onde se conecta

- `auditoria/40_TRANSICAO_RACIONALIZACAO_E_PROMPT_RETOMADA.md` secao 5.3
  — origem da Onda 8.
- `00_REGRAS_V203_INEGOCIAVEIS.md` — regra que se cumpre aqui.
- `src/vba/Util_Filtro_Lista.bas` — onde a heuristica vive agora.
- `src/vba/Cadastro_Servico.frm`, `Reativa_Empresa.frm`,
  `Reativa_Entidade.frm` — clientes do helper.
