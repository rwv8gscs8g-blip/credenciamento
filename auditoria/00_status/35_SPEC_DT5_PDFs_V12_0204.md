---
titulo: 35 - Spec DT-5 (Geracao de PDFs por ciclo de rodizio) — V12.0.0204
diataxis: explanation
hbn-track: safe_track
hbn-status: active
audiencia: ambos
versao-sistema: V12.0.0204 (proxima)
data: 2026-05-02
autor: Claude Opus 4.7 (Cowork) com aprovacao operador
licenca-target: TPGL-v1.1 (Credenciamento)
---

# 35. Spec DT-5 — Geracao de PDFs por ciclo de rodizio (V12.0.0204)

## Status

**APROVADA POR HEARBACK** em 2026-05-02 durante a Onda 11 (V12.0.0203-rc1
closure). Implementacao deslocada para Onda 12+ ou V12.0.0204 inicial.

## Origem

Proposta originalmente do operador Luís Maurício Junqueira Zanin no
fechamento da Onda 10 (DT-5 listado em
`auditoria/03_ondas/onda_10_reincorporacao_onda01/70_FECHAMENTO_ONDA_10.md`).
Reapresentada na Onda 11 como possivel ferramenta de diagnostico
imediato do DT-3, mas a evidencia cirurgica do DT-3 veio antes via
instrumentacao DIAG_* + leitura openpyxl direta de RESULTADO_QA_V2.
PDFs deixaram de ser caminho de diagnostico mas permanecem feature
legitima, cabivel em V12.0.0204.

## Objetivo funcional

Gerar PDF auditavel por ciclo de rodizio, com estado completo das OSes
emitidas, empresas atendidas, notas, medias, suspensoes e auditoria
ainda na Onda corrente. Saida documental persistente, util para:

1. **Auditoria forense** posterior por humanos (Tribunais de Contas,
   Controladoria, MP).
2. **Transparencia publica** alinhada com Lei 12.527/11.
3. **Leitura objetiva por IA** em ciclos posteriores — IAs podem ler
   PDF como evidencia primaria sem precisar abrir o workbook.
4. **Vitrine institucional** do projeto (assinatura digital opcional
   no rodape).

## Requisitos minimos

### Cabecalho (obrigatorio)

- Build label vigente (`APP_BUILD_IMPORTADO`)
- Build branch + data (`APP_BUILD_GERADO_EM`)
- Hash SHA-1 do workbook (calculo no momento da geracao)
- Identificacao do operador + entidade
- Carimbo temporal RFC 3339

### Rodape (obrigatorio)

- Resumo de uma linha do conteudo do PDF — formato canonico:
  `RESUMO: [N OSes] [M strikes] [K suspensoes] [STATUS=...]`
- Esta linha deve ser legivel por IA via OCR ou extracao de texto
  estruturado.
- Linha adicional: hash SHA-1 do conteudo do proprio PDF (auto-validavel).

### Conteudo (corpo)

- Listagem das OSes do ciclo: OS_ID, EMP_ID, STATUS, MEDIA, NOTA_USADA
- Estado das empresas: STATUS_GLOBAL, contagem de strikes, DT_FIM_SUSP
- Eventos do AUDIT_LOG no escopo do ciclo
- Snapshot de CONFIG vigente (MAX_STRIKES, DIAS_SUSPENSAO_STRIKE,
  NOTA_MIN, etc.)

## Arquitetura sugerida

### Modulo novo `Util_PDF.bas`

API publica minima:

- `Util_PDF_GerarRelatorioRodizio(OS_IDs() As String, caminho As String) As TResult`
- `Util_PDF_GerarRelatorioCiclo(execucaoId As String, caminho As String) As TResult`
- `Util_PDF_GerarSummaryFooter(conteudo As String) As String` — gera linha
  RESUMO canonica para o rodape.

### Hooks em servicos existentes

- `Svc_Avaliacao.AvaliarOS` — opcional, gerar PDF apos cada OS avaliada
- `Svc_Rodizio.SelecionarEmpresa` — opcional, gerar PDF de snapshot
  pre-selecao
- `Teste_V2_Roteiros.TV2_RunRodizioStrikesEndToEnd` — gerar PDF final
  com sumario de validacao

### Mecanismo de geracao

VBA tem suporte nativo a PDF via `ExportAsFixedFormat`. Caminho mais
simples:

1. Gerar planilha temporaria com layout do relatorio
2. `ExportAsFixedFormat Type:=xlTypePDF`
3. Limpar planilha temporaria

Alternativa avancada: `Word.Application` automation para layout mais
rico (cabecalho, tabelas formatadas, assinatura visual). Avaliar
custo/beneficio na Onda 12.

### Idempotencia

Cada PDF gerado tem nome unico baseado em
`<execucaoId>_<timestamp>_<hash8>.pdf`. Nunca sobrescreve. Diretorio
alvo: `auditoria/04_evidencias/V12.0.0204/pdfs/`.

## Sprints sugeridas (Onda 12)

- **MD-12.1:** `Util_PDF_GerarSummaryFooter` (helper puro, sem I/O).
  Testavel em isolamento.
- **MD-12.2:** Geracao basica via `ExportAsFixedFormat` com planilha
  temporaria — output OK, sem cabecalho/rodape ainda.
- **MD-12.3:** Cabecalho com metadata + rodape com RESUMO canonico.
- **MD-12.4:** Hooks opcionais em Svc_Avaliacao + opcao na suite e2e.
- **MD-12.5:** Geracao automatica no fim de cada execucao da bateria
  oficial e da V2 Canonica.

## Riscos

- Performance: geracao de PDF em VBA pode ser lenta (> 5s por arquivo).
  Mitigacao: gerar so no fim da execucao, nao por OS.
- Dependencia de libs externas: `ExportAsFixedFormat` e nativo do Excel,
  sem dependencia. Word automation seria adicional.
- Volume de arquivos: cada execucao gera 1+ PDFs; planejar rotacao
  mensal em `auditoria/04_evidencias/`.

## Licenca

Modulo `Util_PDF.bas` e PDFs gerados para o sistema Credenciamento
permanecem sob TPGL v1.1 (copyright Luís Maurício Junqueira Zanin).
Helpers genericos (formatacao de cabecalho/rodape canonico) podem ser
extraidos para o repositorio publico `usehbn` sob AGPLv3 em fase
posterior, apos consentimento.

## Versao

- v1.0 — 2026-05-02 — spec inicial registrada na Onda 11 V12.0.0203-rc1
  closure. Implementacao prevista para Onda 12 ou V12.0.0204.
