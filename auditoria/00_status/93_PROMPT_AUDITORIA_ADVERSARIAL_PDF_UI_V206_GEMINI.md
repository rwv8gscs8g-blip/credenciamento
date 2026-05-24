---
titulo: Prompt de Auditoria Adversarial PDF/UI V206 — Gemini
diataxis: status
hbn-track: safe_track
hbn-status: active
audiencia: ia
versao-sistema: V12.0.0206
data: 2026-05-24
autor: Codex
saida-prevista: auditoria/00_status/96_AUDITORIA_ADVERSARIAL_PDF_UI_V206_GEMINI.md
---

# Prompt de Auditoria Adversarial PDF/UI V206 — Gemini

Você é Gemini/Antigravity atuando como auditor adversarial da V12.0.0206. Sua
missão é encontrar riscos, inconsistências, lacunas de teste e armadilhas de
implementação antes de qualquer código VBA ser alterado.

## Contexto Obrigatório

- Release base: V12.0.0205 congelada e publicada em `v12.0.0205`.
- Commit base estável: `f24e535`.
- Evidência final V205: `VR_20260523_215637`.
- Assinatura de não regressão:

```text
V1=171/0+V2_Smoke=34/0+V2_Canonica=24/0+E2E_Strikes=76/0+IntegridadeBase=4/0+Onda23Adv=27/0
```

- A V12.0.0206 não pode alterar RN-01 a RN-17.
- PDF não pode contaminar os contadores RVS.
- Testes de PDF devem ser isolados e complementares.
- `doc/` não pode ser movido nem reorganizado.
- Módulos `Svc_Rodizio.bas`, `Svc_Avaliacao.bas`, `Svc_OS.bas` e
  `Svc_PreOS.bas` estão bloqueados salvo P0 explícito e hearback humano.
- Não renomear símbolos internos VBA.

## Decisão Humana Já Aprovada

Estrutura aprovada:

```text
Documentos_Gerados/
  Pre-OS/
  OS/
  Avaliacoes/
  Relatorios/
  Validacao/
  Testes_UI/<RUN_ID>/
```

Nome aprovado:

```text
<TIPO>_<NUMERO_DOCUMENTO>_CNPJ_<CNPJ_LIMPO>_<AAAAMMDD_HHNNSS>.pdf
```

O CNPJ deve ser normalizado para dígitos, sem pontuação. Se o CNPJ estiver
ausente, avalie fallback seguro como `CNPJ_SEM_CNPJ` ou bloqueio com mensagem
clara, conforme risco operacional.

## Superfícies de Risco Para Auditar

1. Sobrescrita acidental de PDFs.
2. Caracteres inválidos em nomes de arquivo no Windows/macOS.
3. Caminhos longos demais em ambiente Windows.
4. CNPJ ausente, mal formatado, duplicado ou com pontuação.
5. Numeração de Pré-OS/OS vazia, não numérica ou legado sem padding.
6. Geração de PDF em pasta sem permissão de escrita.
7. Workbook salvo em local de rede, OneDrive, iCloud ou caminho com acentos.
8. `ExportAsFixedFormat` falhar silenciosamente ou gerar arquivo zero bytes.
9. PDF gerado, mas com conteúdo cortado ou aba errada.
10. Contaminação do RVS por contador de PDF.
11. Teste de clique frágil que passa sem provar geração real de arquivo.
12. Relatórios limparem `RELATORIO` antes do PDF ser validado.
13. Diálogo de impressora bloquear automação.
14. Interface gerar instância errada do UserForm e lista vazia.
15. Vazamento de dados sensíveis em nomes de arquivos.

## Arquivos Para Ler

Leia, no mínimo:

- `AGENTS.md`
- `.hbn/relay/INDEX.md`
- `auditoria/02_planos/32_ROADMAP_V206_CONSOLIDADO.md`
- `docs/reference/testes/ESPEC_PDF_AUTOMATICO_V205.md`
- `auditoria/00_status/35_SPEC_DT5_PDFs_V12_0204.md`
- `auditoria/02_planos/25_PLANO_HARDENING_POS_0203.md`
- `src/vba/Preencher.bas`
- `src/vba/Menu_Principal.frm`
- `src/vba/Rel_Emp_Serv.frm`
- `src/vba/Rel_OSEmpresa.frm`
- `src/vba/Util_Config.bas`
- `src/vba/Teste_V2_Engine.bas`
- `src/vba/Teste_V2_Roteiros.bas`

## Questões Adversariais

1. Qual é o menor desenho que gera PDFs úteis sem mexer em regras de negócio?
2. O motor PDF deve receber dados explícitos ou depender de variáveis globais
   já usadas pelos templates?
3. Como impedir que o PDF seja declarado gerado quando o arquivo não existe,
   está vazio ou não começa com assinatura `%PDF-`?
4. Como validar que todos os PDFs esperados foram gerados em uma bateria de
   simulação de cliques?
5. Como evitar que `PrintOut` e diálogo de impressora travem a automação?
6. A correção de `Rel_Emp_Serv` e `Rel_OSEmpresa` deve vir antes da exportação
   PDF? Qual risco de deixar para depois?
7. O uso de CNPJ no nome do arquivo cria risco de exposição desnecessária?
   Se sim, qual mitigação sem destruir a capacidade de busca?
8. O padrão de subpastas atende tanto operação real quanto teste automatizado?
9. Que testes mínimos devem ser criados sem alterar os contadores RVS?
10. Quais cenários devem bloquear a Onda 34 ou Onda 36 se falharem?

## Saída Esperada

Crie o arquivo:

```text
auditoria/00_status/96_AUDITORIA_ADVERSARIAL_PDF_UI_V206_GEMINI.md
```

Com frontmatter:

```yaml
---
titulo: Auditoria Adversarial PDF/UI V206 — Gemini
diataxis: status
hbn-track: safe_track
hbn-status: active
audiencia: ambos
versao-sistema: V12.0.0206
data: 2026-05-24
autor: Gemini via Antigravity
---
```

Estrutura mínima:

1. Veredito adversarial.
2. Achados P0/P1/P2/P3.
3. Riscos de nomes/pastas.
4. Riscos do motor PDF.
5. Riscos dos dois relatórios.
6. Riscos de testes por simulação de cliques.
7. Requisitos bloqueantes antes de codificar.
8. Cadência recomendada de ondas 32 a 37.
9. Checklist de aceite adversarial.

Não proponha incorporar PDF ao RVS. Não proponha alteração de RN-01 a RN-17.
