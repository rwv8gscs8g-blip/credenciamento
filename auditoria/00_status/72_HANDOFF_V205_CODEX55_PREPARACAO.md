---
titulo: Handoff V205 para Codex 5.5
diataxis: status
hbn-track: safe_track
hbn-status: active
audiencia: ia
versao-sistema: V12.0.0205
data: 2026-05-12
---

# Handoff V205 para Codex 5.5

Este documento prepara a abertura de um chat novo para especificação funcional
da V12.0.0205, partindo da V12.0.0204 fechada e validada.

## Recomendação de raciocínio

Use **raciocínio altíssimo** no primeiro ciclo da V205.

Motivo: a abertura da V205 combina saneamento de dívida técnica, desenho de
arquitetura de geração automática de PDF, proposta de testes por interface,
revisão de código e preservação da linha pública V204. A decisão inicial exige
mais análise e menos pressa. Depois que o roadmap V205 estiver fatiado em
microdeltas, os microdeltas simples podem rodar com raciocínio alto.

## Prompt de abertura recomendado

```text
✅ HBN ACTIVE — Codex 5.5 assumindo Frente 1 Credenciamento V12.0.0205 em /Users/macbookpro/Projetos/Credenciamento.

Você é Codex 5.5 em novo chat, assumindo a continuidade da Frente 1
Credenciamento após fechamento documental da V12.0.0204.

Use raciocínio altíssimo neste primeiro ciclo.

Objetivo da sessão:
abrir a especificação funcional, técnica e de testes da V12.0.0205, sem editar
código inicialmente, preservando a V12.0.0204 como release pública validada.

Estado de partida:
- Release oficial vigente: V12.0.0204.
- Build final validado: f7aa84f+ONDA25.MD25.5-limpar-cad-serv-fix2.
- Gate final aprovado: VR_20260511_175849.
- Sintaxe: V1=171/0+V2_Smoke=34/0+V2_Canonica=24/0+E2E_Strikes=76/0+IntegridadeBase=4/0+Onda23Adv=27/0.
- Protocolo de homologação humana V204 aprovado e incorporado em:
  docs/tutorials/PROTOCOLO_HOMOLOGACAO_HUMANA_V12_0_0204.docx
- V204 está fechada para publicação/teste humano. Não reabrir V204 salvo bug P0/P1 comprovado pelos testadores humanos.

Leia antes de qualquer ação:
1. AGENTS.md
2. .hbn/relay/INDEX.md
3. .hbn/knowledge/0001-regras-v203-inegociaveis.md
4. .hbn/knowledge/0002-regra-ouro-vba-import.md
5. .hbn/knowledge/0003-glasswing-style-preventive-security.md
6. .hbn/knowledge/0010-regra-funcionalidade-nova-exige-teste.md
7. .hbn/knowledge/0011-regra-higiene-documental-recorrente.md
8. README.md
9. CHANGELOG.md
10. obsidian-vault/releases/STATUS-OFICIAL.md
11. obsidian-vault/releases/V12.0.0204.md
12. docs/reference/regras/REGRAS_DE_NEGOCIO_V204.md
13. docs/reference/testes/06_MATRIZ_RASTREABILIDADE_TESTES_V204.md
14. docs/tutorials/PROTOCOLO_HOMOLOGACAO_HUMANA_V12_0_0204.docx
15. auditoria/00_status/72_HANDOFF_V205_CODEX55_PREPARACAO.md
16. auditoria/evidencias/V12.0.0204/INDEX.md
17. .hbn/results/0067-exec-onda25-md25-9-vitrine-publica-v204-micro58.json

Contexto operacional:
A V204 fechou com uma mudança importante de qualidade: o teste automático
Sexteto não é mais tratado como substituto da homologação humana. O pacote
humano aprovado exige que um testador valide regras de negócio pela interface,
com evidências e tabelas preenchíveis.

Diretrizes da V205:
1. Não começar por código.
2. Primeiro produzir um readback/diagnóstico de escopo V205.
3. Separar claramente dívida técnica, funcionalidade nova, melhoria de teste,
   documentação e publicação.
4. Toda funcionalidade nova exige teste novo ou justificativa explícita.
5. Toda alteração em VBA deve manter `src/vba/` como fonte de verdade e
   `local-ai/vba_import/` como espelho.
6. CRLF preservado em VBA.
7. Não tocar em `Credenciamento/usehbn/` salvo instrução explícita futura.
8. Não alterar `.hbn/knowledge/` sem readback/hearback específico.

Eixos desejados para V12.0.0205:

EIXO A — Eliminação de débitos técnicos anteriores
- Revisar e classificar os débitos V205 herdados:
  - D-MICRO50-CSV-FILENAME: prefixo histórico V12_0_0203 nos CSVs da V204.
  - D-V205-MD24-4: documentar side-effects de SelecionarEmpresa sem reaproveitar MICRO49.
  - D-STRICT-G1-G2-G5: lapidar `glasswing-checks.sh --strict`.
  - Renomear taxonomia pública de testes: Sexteto/Quinteto/Quarteto para nomes profissionais.
  - Melhorar ordem e mensageria da Central de Testes.
  - Unificar arquitetura de evidências e docs públicos sem quebrar histórico.
- Entregar uma matriz: débito -> risco -> prioridade -> teste necessário -> microdelta sugerido.

EIXO B — Automação de PDFs e impressão auditável
- Especificar geração automática de PDFs a partir da planilha.
- Identificar quais relatórios/documentos devem virar PDF:
  - validação de release;
  - resultado do teste automático;
  - protocolo/resumo de homologação;
  - relatórios de auditoria;
  - documentos operacionais de Pré-OS/OS, se aplicável.
- Definir como imprimir/gerar PDF de forma automatizada, auditável e repetível.
- Definir evidência de conteúdo impresso:
  - nome do arquivo;
  - timestamp;
  - build;
  - validação_id;
  - hash, se viável;
  - aba/origem;
  - status de aprovação;
  - caminho salvo.
- Propor testes automatizados para garantir que o PDF não está vazio, contém
  textos obrigatórios, build correto e dados mínimos.
- Propor testes manuais quando a validação visual ainda não puder ser
  automatizada.

EIXO C — Testes que simulam passos via interface
- Mapear a Central de Testes atual:
  - Tela inicial;
  - botão Central de Testes;
  - janela de transição;
  - Central V2;
  - opção [1] Sexteto Mínimo.
- Propor uma camada de teste que simule o caminho humano pela interface, sem
  depender da Janela Imediata.
- Avaliar alternativas:
  - testes VBA acionados por botões;
  - wrappers públicos de teste por UI;
  - automação externa;
  - logs de eventos de UI;
  - asserts sobre formulários e controles.
- Separar o que pode ser implementado em V205 do que deve ficar para V206+.
- Manter a regra: teste por interface não pode corromper base de produção; deve
  operar em modo treinamento/homologação.

EIXO D — Code review e sanity check
- Fazer revisão orientada por risco, não refatoração ampla.
- Priorizar:
  - duplicação;
  - `On Error Resume Next`;
  - funções públicas sem ErrorBoundary;
  - mutações sem Audit_Log;
  - inconsistência entre serviço e UI;
  - nomes confusos;
  - testes frágeis;
  - pontos de crash de compile.
- Produzir relatório de achados P0/P1/P2/P3.
- Não abrir refatoração sem teste correspondente.

Entrega esperada neste primeiro ciclo:
1. Parecer de abertura V205.
2. Lista consolidada de débitos herdados.
3. Proposta de roadmap V205 em ondas/microdeltas.
4. Matriz de prioridade com esforço/risco.
5. Especificação inicial dos PDFs automáticos.
6. Especificação inicial de testes por interface.
7. Plano de code review/sanity check.
8. Lacunas de informação que precisam de decisão humana.
9. Recomendação do primeiro microdelta V205.

Formato de resposta:
- Comece com `✅ HBN ACTIVE`.
- Não edite código.
- Se houver proposta de edição, descreva o readback e pare para hearback.
- Termine com uma seção:
  `🔵 HBN HANDOFF READY — aguardando aprovação do roadmap V205`.
```

## Pontos de confirmação antes da abertura V205

1. V204 permanece como release oficial validada.
2. O protocolo humano Word V204 foi incorporado à vitrine.
3. Testadores humanos podem usar o DOCX como material principal.
4. A próxima IA deve abrir V205 por planejamento, não por patch.
5. O primeiro ciclo da V205 deve usar raciocínio altíssimo.
6. O foco inicial será:
   - dívidas técnicas;
   - PDFs automáticos auditáveis;
   - testes por interface;
   - code review/sanity check.
7. Nenhuma alteração VBA deve ser feita antes de readback/hearback da V205.

## Pendências estruturais conhecidas

- A V204 ainda depende do retorno dos testadores humanos externos.
- A nomenclatura pública “Sexteto” permanece histórica e deve ser tratada na V205.
- O pacote MD-24.4 deve ser reavaliado do zero, sem reaproveitar MICRO49.
- Os checks strict G1/G2/G5 seguem como dívida técnica.
- A automação de PDF ainda é especificação, não implementação.
- O teste de interface clicável ainda não existe como camada automatizada.
