---
titulo: Onda 38.2.7 - leitura e exibicao
diataxis: onda
hbn-track: safe_track
hbn-status: active
audiencia: ambos
versao-sistema: V12.0.0205
data: 2026-05-31
---

# Onda 38.2.7 - leitura e exibicao

## Escopo confirmado

Readback: `.hbn/readbacks/0123-rb-onda-38-2-7-leitura-exibicao.json`
Hearback: `.hbn/hearbacks/0123-rb-onda-38-2-7-leitura-exibicao-confirmed.json`

Objetivo: fechar FT-1, FT-5, FT-6 e FT-8 do parecer 0024 com delta curto,
sem alterar regra de negocio, `Svc_*`, `Repo_*`, `.frx`, `Auto_Open.bas`,
`Mod_Types.bas` ou `Importador_V3.bas`.

## Alteracoes entregues

- `Menu_Principal.C_Lista_Click` passa a preencher os campos visiveis da
  entidade com a mesma matriz de colunas usada no duplo clique para edicao:
  CNPJ, nome, telefones, email, endereco, bairro, municipio, CEP, UF,
  contatos 1..3, funcoes, telefones e informacoes adicionais.
- As listas de entidade e empresa passam a exibir ID operacional antes do CNPJ,
  preservando CNPJ, nome/razao e contato/telefone nas colunas visiveis.
- `PreencherPreencheOS` passa a aceitar filtro opcional e aplica esse filtro
  ao texto consolidado de Pre-OS, entidade, servico, empresa, data, quantidade
  e valor.
- O dispatcher `Preencher_FiltrarPorBoxEstatico` passa o termo do `TextBox19`
  para o contexto `os`.
- `TV2_RunLeituraExibicao` cobre cinco verificacoes estaticas/dirigidas:
  largura ID visivel, paridade de campos da `C_Lista`, dados usados no rodizio,
  filtro OS e ID antes de CNPJ nas listas.

## Pacote V3

Manifesto:
`local-ai/vba_import/000-MANIFESTO-V3-DELTA-ONDA38_2_7_LEITURA_EXIBICAO.txt`

Comando:

```vb
ImportarPacoteV3_Delta "ONDA38_2_7_LEITURA_EXIBICAO", "fd45a5d+ONDA38.2.7-LEITURA-EXIBICAO"
```

Pos-import esperado:

1. Importador V3: `M=3 | F=1 | err=0`.
2. VBE > Depurar > Compilar VBAProject: limpo.
3. Janela Imediata: `TV2_RunLeituraExibicao`.
4. Resultado esperado: `OK=5 | FALHA=0 | MANUAL=0`.

## Auditoria dos PDFs anexos

Anexos lidos: `/Users/macbookpro/Downloads/001.pdf`,
`/Users/macbookpro/Downloads/002.pdf`, `/Users/macbookpro/Downloads/003.pdf`.
As paginas foram renderizadas em `/private/tmp/cred-pdf-0123/` apenas como
rascunho descartavel de inspecao visual.

Achados:

- Pre-OS (`001.pdf`): cabecalho e corpo estao legiveis, mas ha bordas com pesos
  diferentes, linhas externas muito fortes e artefato de linha vertical no
  rodape esquerdo. O cabecalho tambem mostra `Municipio de Testes V2`.
- OS (`002.pdf`): os problemas de bordas se repetem. Na pagina 2, o campo
  `Nº do Empenho` esta estreito demais e corta o valor exibido.
- Avaliacao (`003.pdf`): o campo `Demandante` aparece vazio, o empenho quebra em
  duas linhas (`EMP-20260531-` / `000001`) e invade a regiao de borda; ha pesos
  de borda irregulares nas faixas verticais e na tabela de avaliacao.

Conclusao: sao problemas reais de template/layout de impressao, mas nao foram
corrigidos nesta onda porque exigem mexer em templates/formatacao de planilhas
ou possivelmente `.frx`, fora do escopo 0123. Devem entrar em readback proprio
de layout de impressao.

## Persistencia do municipio

O caminho de persistencia operacional esta correto: `Configuracao_Inicial` grava
`COL_CFG_MUNICIPIO` na aba `CONFIG`, e `Preencher.CarregarCabecalhoConfig` le
essa coluna antes de preencher Pre-OS, OS e avaliacao impressas.

O risco encontrado esta no baseline de testes V2:

- `src/vba/Teste_V2_Engine.bas:727` chama `TV2_PrepararBaselineCanonica`.
- `src/vba/Teste_V2_Engine.bas:753` chama `TV2_SetConfigCanonica`.
- `src/vba/Teste_V2_Engine.bas:763` grava `Gestor Testes V2`.
- `src/vba/Teste_V2_Engine.bas:765` grava `Municipio de Testes V2`.
- `TV2_RestaurarConfigBaseline` nao restaura gestor/municipio.

Portanto, quando o workbook volta para `Municipio de Testes V2`, a causa mais
provavel nao e falha do formulario de configuracao, mas execucao de baseline V2
que sobrescreve a aba `CONFIG`. A correcao adequada e uma onda FT-11/CONFIG:
salvar e restaurar municipio/gestor no baseline V2, ou isolar dados canonicos
em uma CONFIG temporaria de teste.

## Fora do escopo preservado

- `Auto_Open.bas` nao foi tocado.
- `Mod_Types.bas` nao foi tocado.
- `Importador_V3.bas` nao foi tocado.
- `Svc_*` e `Repo_*` nao foram alterados.
- `Menu_Principal.frx` nao foi tocado.
- Nao houve propagacao do padrao de Entidades.
- Nao foi declarado freeze V206.
