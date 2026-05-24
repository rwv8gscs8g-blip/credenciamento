---
titulo: Prompt de Auditoria PDF/UI V206 — Claude Opus
diataxis: status
hbn-track: safe_track
hbn-status: active
audiencia: ia
versao-sistema: V12.0.0206
data: 2026-05-24
autor: Codex
saida-prevista: auditoria/00_status/95_AUDITORIA_PDF_UI_V206_CLAUDE_OPUS.md
---

# Prompt de Auditoria PDF/UI V206 — Claude Opus

Você é Claude Opus atuando como auditor estratégico e revisor de jornada humana
da V12.0.0206 do Sistema de Credenciamento e Rodízio de Pequenos Reparos.

## Contexto Obrigatório

- A V12.0.0205 está congelada em `v12.0.0205`, commit `f24e535`.
- Evidência final V205: `VR_20260523_215637`.
- Assinatura funcional de não regressão:

```text
V1=171/0+V2_Smoke=34/0+V2_Canonica=24/0+E2E_Strikes=76/0+IntegridadeBase=4/0+Onda23Adv=27/0
```

- A V12.0.0206 deve ser incremental.
- RN-01 a RN-17 não podem ser alteradas.
- O teste de PDF deve ser isolado e não pode entrar nas seis baterias do RVS.
- `doc/` não pode ser movido nem reorganizado.
- Não tocar `Svc_Rodizio.bas`, `Svc_Avaliacao.bas`, `Svc_OS.bas` ou
  `Svc_PreOS.bas` salvo P0 explícito e hearback humano.
- Não renomear símbolos internos VBA.

## Decisão Humana Já Aprovada

O operador aprovou a estrutura de PDFs:

```text
Documentos_Gerados/
  Pre-OS/
  OS/
  Avaliacoes/
  Relatorios/
  Validacao/
  Testes_UI/<RUN_ID>/
```

Nome recomendado e aprovado:

```text
<TIPO>_<NUMERO_DOCUMENTO>_CNPJ_<CNPJ_LIMPO>_<AAAAMMDD_HHNNSS>.pdf
```

Exemplos:

```text
PREOS_000123_CNPJ_12345678000199_20260524_1530.pdf
OS_000456_CNPJ_12345678000199_20260524_1540.pdf
AVALIACAO_OS_000456_CNPJ_12345678000199_20260524_1600.pdf
REL_OS_POR_EMPRESA_CNPJ_12345678000199_20260524_1610.pdf
```

## Documentos e Arquivos Para Ler

Leia, no mínimo:

- `AGENTS.md`
- `.hbn/relay/INDEX.md`
- `auditoria/02_planos/32_ROADMAP_V206_CONSOLIDADO.md`
- `auditoria/03_ondas/onda_31_v206_higiene_documental/01_TECNICO_ONDA31_HIGIENE_DOCUMENTAL.md`
- `docs/reference/testes/ESPEC_PDF_AUTOMATICO_V205.md`
- `auditoria/00_status/35_SPEC_DT5_PDFs_V12_0204.md`
- `auditoria/02_planos/25_PLANO_HARDENING_POS_0203.md`
- `src/vba/Preencher.bas`
- `src/vba/Menu_Principal.frm`
- `src/vba/Rel_Emp_Serv.frm`
- `src/vba/Rel_OSEmpresa.frm`
- `src/vba/Util_Config.bas`

## Perguntas Para Responder

1. A estrutura `Documentos_Gerados/<tipo>/` atende bem à jornada humana de
   operador, auditor e testador?
2. O padrão de nome com tipo + número + CNPJ é suficiente para acompanhar a
   evolução de Pré-OS, OS, avaliação e relatórios no Finder/Gerenciador de
   Arquivos?
3. Há ajustes de nomenclatura que preservem clareza humana sem criar nomes
   longos demais?
4. O motor PDF deve ser centralizado em novo `Util_PDF.bas` ou incorporado em
   `Util_Config.bas` junto dos helpers de relatório existentes?
5. O log `RPT_PDFs_EMITIDOS` deve ser obrigatório desde o primeiro microdelta
   de PDF ou pode entrar em microdelta separado?
6. Os dois relatórios citados pelo operador devem ser corrigidos antes do motor
   PDF ou junto com ele?
7. Como desenhar a implementação para simplificar a futura bateria por
   simulação de cliques na interface?
8. A camada de testes por simulação deve começar por uma camada VBA
   determinística, por automação externa de clique real, ou por ambas em fases
   separadas?

## Achados Técnicos Já Levantados Pelo Codex

Auditoria read-only do Codex identificou um provável padrão de falha nos dois
relatórios citados:

- `Menu_Principal.frm` chama `PreenchimentoRelatorioOSEmpresa` antes de criar e
  exibir a instância `Rel_OSEmpresa`.
- `Menu_Principal.frm` chama `PreenchimentoRel_EmpXServ` antes de criar e
  exibir a instância `Rel_Emp_Serv`.
- Esse mesmo tipo de bug já foi corrigido antes em `Credencia_Empresa`, onde o
  comentário local informa que preencher uma instância e exibir outra deixava a
  lista vazia.

Revise esse achado e indique se a correção deve ser:

1. criar a instância primeiro e passar/popular a instância exibida;
2. alterar `PreenchimentoRel_*` para receber instância opcional;
3. migrar geração do relatório para rotina independente de form;
4. outro desenho mais simples.

## Saída Esperada

Crie o arquivo:

```text
auditoria/00_status/95_AUDITORIA_PDF_UI_V206_CLAUDE_OPUS.md
```

Com frontmatter:

```yaml
---
titulo: Auditoria PDF/UI V206 — Claude Opus
diataxis: status
hbn-track: safe_track
hbn-status: active
audiencia: ambos
versao-sistema: V12.0.0206
data: 2026-05-24
autor: Claude Opus
---
```

Estrutura mínima:

1. Veredito executivo.
2. Avaliação da nomenclatura de PDFs.
3. Avaliação da estrutura de pastas.
4. Recomendação de arquitetura do motor PDF.
5. Recomendação para correção dos dois relatórios.
6. Recomendação para testes por simulação de cliques.
7. Riscos e mitigação.
8. Cadência sugerida de ondas 32 a 37.

Classifique achados em P0/P1/P2/P3. Não proponha alteração de RN-01 a RN-17.
