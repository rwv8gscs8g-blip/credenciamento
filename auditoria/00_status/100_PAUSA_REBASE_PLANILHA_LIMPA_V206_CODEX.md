---
titulo: Pausa MD33 e Rebase em Planilha Limpa V206 — Codex
diataxis: status
hbn-track: safe_track
hbn-status: active
audiencia: ambos
versao-sistema: V12.0.0206
data: 2026-05-24
autor: Codex
---

# Pausa MD33 e Rebase em Planilha Limpa V206

## Veredito

As tentativas `MICRO62-V206-MD33-0`, `MICRO62-V206-MD33-0-fix1` e
`MICRO62-V206-MD33-0-fix2` ficam reprovadas para homologacao.

O Importador V3 funcionou nas tres tentativas e criou backups na pasta correta,
mas o Excel fechou durante o compile manual. Portanto, o workbook usado nas
tentativas nao deve mais ser usado como base de desenvolvimento.

## Correcao de protocolo

O operador esta correto: nenhum procedimento operacional deve orientar importar
codigo a partir de `backups/vba`. Os backups do V3 sao evidencia e material de
diagnostico, nao fonte de importacao.

Fonte operacional para o Excel:

```text
\\Mac\Home\Projetos\Credenciamento\local-ai\vba_import
```

Qualquer codigo que va para o workbook precisa estar em `local-ai/vba_import/`
e passar pelo manifesto correspondente.

O `Importador_V3.bas` tambem foi ajustado para nao orientar restauracao a partir
de `backups/vba`. A mensagem final agora informa que o backup e somente
evidencia/diagnostico e que nova importacao operacional deve vir de
`local-ai/vba_import`.

## Nova ancora humana

Usar a planilha limpa indicada pelo operador:

```text
/Users/macbookpro/Projetos/Credenciamento/V12-0206-Preparaçao/24_05_2026 12_18_54PlanilhaCredenciamento-Homologacao-V4.xlsm
```

Antes de qualquer import:

1. Fechar a planilha contaminada e descartar recuperacoes automaticas do Excel.
2. Copiar a planilha limpa para a raiz canonica do projeto.
3. Abrir a copia na raiz, nao a planilha dentro da subpasta.
4. Conferir na Janela Imediata:

```vb
?ThisWorkbook.Path
ImportarPacoteV3_Status
```

O caminho precisa retornar:

```text
\\Mac\Home\Projetos\Credenciamento
```

Se retornar `...\V12-0206-Preparacao`, o Importador V3 procurara o pacote no
lugar errado.

## Export canonico recomendado

Se a planilha limpa compilar antes de qualquer import, exportar todos os
modulos e formularios para:

```text
/Users/macbookpro/Projetos/Credenciamento/local-ai/incoming/V206_BASE_LIMPA_20260524/
```

Nao exportar direto para `local-ai/vba_import/`. O fluxo correto e:

1. `local-ai/incoming/` recebe o export bruto do workbook limpo.
2. Codex compara export bruto contra `src/vba/`.
3. Codex atualiza `src/vba/` somente com decisao humana.
4. Codex publica o espelho com `publicar_vba_import_v2.sh --apply`.
5. O operador importa apenas de `local-ai/vba_import/`.

## Estado do Git

O codigo VBA foi devolvido ao padrao estavel anterior ao MD33 funcional. As
tentativas reprovadas permanecem documentadas para auditoria, mas deixam de ser
proxima acao.

A unica mudanca VBA mantida neste ciclo e textual/operacional no
`Importador_V3.bas`: remocao da orientacao incorreta de restaurar/importar a
partir de backup.

## Evolucao PDF depois do rebase

So depois de compile limpo da planilha limpa:

1. Criar `Util_PDF.bas` como modulo novo e isolado.
2. Implementar somente resolucao de pastas, nomeacao e validacao de arquivo.
3. Usar raiz ao lado da planilha:
   `Documentos_Gerados/Pre-OS`, `OS`, `Avaliacoes`, `Relatorios`,
   `Validacao`, `Testes_UI/<RUN_ID>`.
4. Nome canonico:
   `<TIPO>_<NUMERO_DOCUMENTO>_CNPJ_<CNPJ_LIMPO>_<AAAAMMDD_HHNNSS>.pdf`.
5. Validar existencia, tamanho e assinatura `%PDF-`.
6. Registrar `RPT_PDFs_EMITIDOS.csv`.
7. Integrar por etapas em Pre-OS, OS, Avaliacao e Relatorios, sempre com teste
   isolado fora do RVS.

Onda 34 permanece bloqueada ate a nova ancora compilar limpa.
