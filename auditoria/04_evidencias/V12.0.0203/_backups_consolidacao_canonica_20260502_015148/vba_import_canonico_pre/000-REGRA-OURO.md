# 000 — REGRA DE OURO DA IMPORTACAO VBA

> **Esta regra e absoluta. Toda automacao futura do projeto vai depender dela.
> NAO ha excecao operacional ate que a regra seja explicitamente revisada
> em release oficial.**

## A regra em uma frase

**Tudo o que vai ser importado para o workbook .xlsm precisa estar em
`local-ai/vba_import/`, na pasta correspondente ao tipo de componente,
com prefixo alfabetico que define a ordem de import.**

Nada pode ser importado a partir de `src/vba/`, de `local-ai/incoming/`, de
um anexo de chat, do desktop do operador, ou de qualquer outro lugar.
**Se nao esta em `vba_import/`, nao existe operacionalmente.**

## Por que essa regra existe

1. **Ordem de import importa.** Modulos VBA tem dependencias estaticas
   (um Sub de A pode chamar um Sub de B no momento em que A e
   compilado). O prefixo `AAA-`, `AAB-`, ... `ABJ-` resolve essa ordem
   alfabeticamente, garantindo que a importacao manual ou automatica
   nunca deixe um simbolo nao resolvido pendurado.

2. **`Mod_Types.bas` e tabu.** A reimportacao manual desse modulo ja
   gerou regressao estrutural mais de uma vez no historico do projeto.
   O pacote `vba_import/` mantem `Mod_Types` em `001-modulo/AAA-Mod_Types.bas`
   apenas como fonte de verdade — a regra operacional e NAO reimportar
   esse arquivo em microevolucoes.

3. **`.frx` e binario do designer.** Cada `.frm` precisa ter seu `.frx`
   correspondente do mesmo workbook real (com os controles que o gestor
   renomeou). Se o `.frx` em `vba_import/002-formularios/` divergir do
   estado real do workbook, o reimport quebra controles. O fluxo
   correto e nunca reimportar `.frm` em workbook ja estabilizado —
   substituir apenas o codigo atras (use os arquivos `.code-only.txt`).

4. **Automacao futura precisa de superficie estavel.** O futuro
   automatizador (substituto do `publicar_vba_import.sh` descontinuado)
   vai consumir `000-MANIFESTO-IMPORTACAO.txt` e `000-MAPA-PREFIXOS.txt`
   como contrato. Toda nova entrega precisa atualizar esses dois
   arquivos. Sem isso, a automacao falha silenciosamente.

5. **Auditabilidade.** O hash de cada arquivo em `vba_import/` precisa
   bater com o equivalente em `src/vba/`. Quando bate, qualquer auditor
   externo consegue provar que o que esta no Excel e o que esta no
   repositorio. Quando nao bate, ha desvio operacional.

## Layout obrigatorio

```
local-ai/vba_import/
├── 000-REGRA-OURO.md                    <- este arquivo
├── 000-MANIFESTO-IMPORTACAO.txt         <- lista canonica (M|... ou F|...)
├── 000-MAPA-PREFIXOS.txt                <- prefixo -> nome canonico
├── 000-ORDEM-IMPORTACAO.txt             <- documentacao da ordem
├── 000-BUILD-IMPORTAR-SEMPRE.txt        <- carimbo do build atual
├── README.md
│
├── 001-modulo/                          <- TODOS os .bas oficiais
│   ├── AAA-Mod_Types.bas                <- nao reimportar em microevolucao
│   ├── AAB-Const_Colunas.bas
│   ├── ...
│   ├── ABI-Util_Filtro_Lista.bas
│   └── ABJ-Mod_Limpeza_Base.bas         <- proximo prefixo livre = ABK-
│
├── 002-formularios/                     <- .frm + .frx + .code-only.txt
│   ├── AAA-Fundo_Branco.frm
│   ├── AAA-Fundo_Branco.code-only.txt   <- opcional, para substituir codigo
│   ├── ...
│   ├── AAC-Configuracao_Inicial.frm
│   ├── AAC-Configuracao_Inicial.code-only.txt
│   ├── Configuracao_Inicial.frx          <- binario, sem prefixo
│   └── ...
│
├── 003-objetos/                         <- objetos de planilha (raros)
│
├── Importador_VBA.bas                   <- macro de import automatico
├── Importar_Agora.bas                   <- atalho
│
└── *.bas (raiz)                          <- macros DESCARTAVEIS
                                          (Diag_Imediato, Limpa_Base_Total,
                                           Reset_CNAE_Total, etc. — import,
                                           rodar uma vez, remover)
```

## Tres tipos de arquivos importaveis

### Tipo A — Modulo oficial do projeto (`001-modulo/AAX-Nome.bas`)

- Tem prefixo alfabetico (AAA a ABZ atualmente).
- Esta listado em `000-MANIFESTO-IMPORTACAO.txt` com linha `M|...`.
- Esta listado em `000-MAPA-PREFIXOS.txt`.
- Tem hash identico ao seu equivalente em `src/vba/`.
- Importacao no VBE: substituir conteudo do modulo existente, nao usar
  "Import File" (criaria duplicata `NomeModulo1`).

### Tipo B — Formulario oficial (`002-formularios/AAX-Nome.frm` + `.frx`)

- O `.frm` tem prefixo alfabetico.
- O `.frx` correspondente fica na MESMA pasta SEM prefixo.
- Esta listado em `000-MANIFESTO-IMPORTACAO.txt` com linha `F|...`.
- **Para microevolucao em workbook estabilizado:** usar o arquivo
  `AAX-Nome.code-only.txt` que contem apenas o codigo VBA sem o
  cabecalho FRM. Substituir o codigo atras do form via "Visualizar
  Codigo > Ctrl+A > Delete > Ctrl+V".

### Tipo C — Macro descartavel (`<raiz>/<Nome>.bas`)

- Fica na raiz de `vba_import/`, SEM prefixo, fora das subpastas.
- NAO esta em `MANIFESTO-IMPORTACAO.txt` (nao faz parte do build oficial).
- Padrao: importar via "Import File", rodar a sub `<Nome>_Executar`,
  depois clique direito > Remove sem exportar.
- Exemplos: `Diag_Imediato.bas`, `Limpa_Base_Total.bas`,
  `Reset_CNAE_Total.bas`, `Set_Config_Strikes_Padrao.bas`.

## Checklist por entrega (microevolucao / onda)

Toda onda que mexe em VBA deve, OBRIGATORIAMENTE, deixar:

- [ ] Cada `.bas` modificado em `src/vba/` espelhado em
      `local-ai/vba_import/001-modulo/AAX-Nome.bas` com hash batendo.
- [ ] Cada `.frm` modificado em `src/vba/` espelhado em
      `local-ai/vba_import/002-formularios/AAX-Nome.frm` com hash batendo.
- [ ] Para forms cujo codigo foi alterado mas o designer nao,
      gerar o `.code-only.txt` correspondente em `002-formularios/`.
- [ ] Modulos NOVOS adicionados a `000-MANIFESTO-IMPORTACAO.txt`.
- [ ] Modulos NOVOS adicionados a `000-MAPA-PREFIXOS.txt`.
- [ ] `000-BUILD-IMPORTAR-SEMPRE.txt` atualizado com novo APP_BUILD.
- [ ] `App_Release.bas` (em `001-modulo/AAX-App_Release.bas`) atualizado
      com a nova string de build.
- [ ] `auditoria/NN_PROCEDIMENTO_IMPORT_MANUAL_SEGURO_ONDA_NN.md` lista
      o caminho com prefixo de cada arquivo a importar.

Rodar o script de verificacao (quando existir) ou conferir manualmente:

```bash
md5sum src/vba/Mod_Limpeza_Base.bas \
       local-ai/vba_import/001-modulo/ABJ-Mod_Limpeza_Base.bas
# Os dois hashes devem bater.
```

## Como descobrir o proximo prefixo livre

Olhar em `000-MAPA-PREFIXOS.txt` o ultimo prefixo da secao MODULOS
ou FORMULARIOS e incrementar:

```
... ABI-Util_Filtro_Lista.bas
    ABJ-Mod_Limpeza_Base.bas      <- adicionado em V12.0.0203 ONDA 5
```

Proximo modulo novo recebera prefixo **ABK-**.

A sequencia e alfabetica: AAA..AAZ (26), depois ABA..ABZ (26 mais),
depois ACA..ACZ, etc. Para o ritmo atual de microevolucoes, a
sequencia atual cobre dezenas de novos modulos antes de precisar de
4 letras.

## O que esta proibido

| Acao | Por que |
|---|---|
| Importar `.bas` direto de `src/vba/` no VBE | Hash e ordem nao garantidos. |
| Importar `.bas` direto de `local-ai/incoming/` | Pasta de exports do workbook real, nao do build oficial. |
| Subir um modulo novo sem adicionar entrada no manifesto e no mapa | Quebra a automacao futura. |
| Reimportar `Mod_Types.bas` em microevolucao | Regressao historica documentada. |
| Reimportar `.frm` (Import File) em workbook estabilizado | Sobrescreve `.frx` e perde renomeacoes do designer. **TAMBEM:** pode criar **modulo padrao** com cabecalho FRM como codigo solto, gerando `Erro de compilacao: Invalido fora de um procedimento`. Bug conhecido do VBE — ver `.hbn/knowledge/0005-bug-form-importado-como-modulo.md`. |
| Rodar `local-ai/scripts/publicar_vba_import.sh` | Script descontinuado em 28/04/2026 — manutencao do pacote e MANUAL. |

## Quando esta regra muda

So por release oficial com migration plan documentado. Ate la,
vale exatamente como esta escrita aqui.

---

Versao deste documento: 1.0 (criada em 28/04/2026, durante V12.0.0203 ONDA 5).
