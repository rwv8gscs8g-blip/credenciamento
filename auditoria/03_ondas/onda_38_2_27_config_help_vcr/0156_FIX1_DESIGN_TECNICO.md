---
titulo: Onda 38.2.27-fix1 - layout corrigido no designer
diataxis: onda
hbn-track: safe_track
hbn-status: active
audiencia: ambos
versao-sistema: V12.0.0205
data: 2026-06-06
---

# Onda 38.2.27-fix1 - layout corrigido no designer

## Origem

A 0154 foi importada, compilou e `TV2_RunTelaConfiguracoesIniciais` passou com
`OK=3 | FALHA=0 | MANUAL=0`. Na verificacao visual, Mauricio identificou que o
label `suspender por` estava fisicamente sobreposto ao campo numerico de dias
por recusa/prazo, tornando o clique no campo irregular.

A proposta 0155 tentava resolver por runtime com largura minima, ZOrder e
TabIndex. Antes de importar, o diagnostico correto ficou claro: o defeito era de
layout. A 0155 foi suspensa e substituida por esta 0156.

## Decisao

Quando uma falha de UserForm for geometrica e houver acesso ao designer, a
correcao preferencial e no proprio design, com reexportacao do `.frm/.frx`.
Isso reduz comportamento escondido em runtime e prepara melhor a V207.

## Alteracoes

| Arquivo | Alteracao |
|---|---|
| `src/vba/Configuracao_Inicial.frm` | Incorpora o formulario exportado do `incoming`, removendo os helpers runtime de layout da 0155 e preservando a Ajuda HBN e a regra de dias da 0154. |
| `src/vba/Configuracao_Inicial.frx` | Incorpora o layout corrigido no designer para que o label nao cubra o campo de dias por recusa/prazo. |
| `src/vba/Teste_V2_Roteiros.bas` | Mantem `TV2_RunTelaConfiguracoesIniciais` com 3 asserts, mas o primeiro agora verifica editabilidade e ausencia de sobreposicao de label sobre o campo. |
| `src/vba/App_Release.bas` | Atualiza build para `293e44c+ONDA38.2.27-CONFIG-LAYOUT-fix1`. |

## Pacote de Importacao

Manifesto:

`local-ai/vba_import/000-MANIFESTO-V3-DELTA-ONDA38_2_27_CONFIG_LAYOUT_FIX1.txt`

Comando:

```text
ImportarPacoteV3_Delta "ONDA38_2_27_CONFIG_LAYOUT_FIX1", "293e44c+ONDA38.2.27-CONFIG-LAYOUT-fix1"
```

Esperado:

- Importador V3: `M=2 | F=1 | err=0 | skip=0`.
- Compile VBE limpo.
- Janela Imediata: `TV2_RunTelaConfiguracoesIniciais`.
- Esperado: `OK=3 | FALHA=0 | MANUAL=0`.

## Validacao Manual

Abrir **Configuracoes Iniciais** e confirmar:

1. o label `suspender por` nao cobre o campo numerico;
2. clicar no campo `30` posiciona o cursor no campo;
3. o valor pode ser apagado e digitado novamente;
4. salvar parametros persiste o valor em dias.

## Resultado do Gate

Mauricio reportou:

- Importador V3 OK: `M=2 | F=1 | err=0 | skip=0`;
- compile VBE limpo;
- `TV2_20260606_231033` com `OK=3 | FALHA=0 | MANUAL=0`;
- sem CSV de falhas.

Mauricio confirmou em seguida que o campo aceita clique, edicao e salvamento.
Com isso, a etapa 0156 foi fechada.

## Licao

Solucoes simples, diretas e visiveis devem prevalecer. Layout deve ser corrigido
no layout; regra de negocio deve ser corrigida no codigo; teste deve cobrir o
contrato observavel sem inventar comportamento operacional novo.
