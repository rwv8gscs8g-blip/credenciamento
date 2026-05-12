---
titulo: Auditoria Externa e UX Documental V12.0.0204
diataxis: reference
hbn-track: safe_track
hbn-status: active
audiencia: ambos
versao-sistema: V12.0.0204
data: 2026-05-12
---

# Auditoria Independente: Vitrine Pública e Testes Humanos V12.0.0204

Auditoria externa focada em legibilidade, governança, segurança e experiência do testador humano ("first-time user experience") no repositório público da V12.0.0204.

## 1. Veredito

**APROVADO COM RESSALVAS (P2 - Ruído Documental e Fricção de UX)**.

O repositório é tecnicamente seguro, as evidências V204 estão presentes e a interface da planilha permite validação autônoma (Sexteto Mínimo rodando limpo). No entanto, a vitrine pública no GitHub apresenta alta carga cognitiva ("ruído documental"). A presença de documentos históricos marcados como atuais (V202/V203), a confusão entre pastas `doc/` e `docs/`, a ausência de um índice claro para as evidências CSV e a falta de acentuação PT-BR reduzem a credibilidade pública e confundem o testador humano.

## 2. Achados e Avaliação do Escopo

| Ref | Critério Avaliado | Avaliação e Achado | Severidade |
|---|---|---|---|
| **1** | Página inicial (GitHub) | **✅ OK, mas com ruído**. O `README.md` aponta para `docs/INDEX.md` corretamente. Mas o texto cita `doc` (dados estruturais) e `docs/` lado a lado, o que confunde o visitante. | P3 |
| **2** | Confusão `doc/` vs `docs/` | **❌ FALHA**. Um testador procurando documentação fatalmente entrará em `doc/` e achará CSVs brutos do IBGE, perdendo o foco. | P2 |
| **3** | Documentos históricos como atuais | **❌ FALHA**. A pasta `auditoria/01_regras_e_governanca/` mistura `00_REGRAS_V203...` com arquivos V202. Na pasta `docs/explanation/`, há propostas de testes antigas soltas. | P2 |
| **4** | Execução de macros pela UI | **✅ OK**. O teste pode ser feito via *Central de Testes > Modo Treinamento > Central V2 > Sexteto Mínimo*. A cobertura é de altíssima precisão nas regras mapeadas (E2E Strikes, IntegridadeBase), com abordagem determinística. Falta exibir na interface o detalhe do que cada suíte faz. | OK |
| **5** | Gate V204 sem Janela Imediata | **✅ OK**. O novo `GUIA_TESTES_HUMANOS_V204.md` orienta o uso exclusivo da interface do Excel. | OK |
| **6** | Regras de Negócio explícitas | **⚠️ RESSALVA**. A rastreabilidade existe na matriz `06_MATRIZ_RASTREABILIDADE_TESTES_V204.md`, mas falta um documento canônico consolidado e legível de `REGRAS_DE_NEGOCIO_V204.md`. | P2 |
| **7** | Árvore de evidências compreensível | **⚠️ RESSALVA**. A pasta `auditoria/evidencias/V12.0.0204/` contém 4 CSVs nomeados de forma similar e uma pasta `intermediarios/`. Sem um `INDEX.md`, o testador não sabe qual é a prova canônica. | P2 |
| **8** | Segurança e exposição indevida | **✅ OK**. Nenhuma credencial, path sensível local ou backdoor VBA identificados. Proteção Glasswing garante governança. Instruções de coordenação IA (HBN) são públicas por design (transparência), não são risco de segurança. | OK |
| **9** | Falta material Word/PDF | **❌ FALHA**. Testadores governamentais (auditores, corregedores, procuradores) esperam um pacote fechado com um manual legível (Word/PDF). O repositório só tem Markdown. | P2 |
| **10**| Legibilidade e usabilidade | **❌ FALHA**. Muitos documentos carecem de acentuação (PT-BR) devido às limitações históricas de editores/scripts, prejudicando a leitura e a credibilidade institucional. | P3 |

## 3. Mapa de Testes Humanos por Interface (Status Atual vs Proposta)

### Abordagem e Cobertura
A V204 garante que o mantenedor não exige do testador o uso do VBA. A cobertura alcança 100% dos fluxos críticos de rodízio, penalização e emissão de OS, porém o acionamento via "Sexteto Mínimo" não diz *o que* está sendo testado de forma explícita para o humano.

### O que cada teste faz
1. **V1 Rápida:** Regressão clássica massiva (171 asserts funcionais básicos).
2. **V2 Smoke:** Teste de fumaça focado em crash rápido e integridade (Limpar Base e CNAE).
3. **V2 Canônica:** Validação de fluxos de sucesso (Happy path) determinísticos.
4. **E2E Strikes:** Cenário de fim a fim verificando acúmulo de notas, penalidade, reativação e janela punitiva.
5. **IntegridadeBase:** Varredura passiva de banco de dados (resíduos, datas inválidas, órfãs).
6. **Onda23Adv (Adversarial):** Robustez de botões, validação de transações interrompidas (commit/rollback) e data mining em bordas (bissexto, finais de semana).

### Propostas de Testes Complementares (Próxima Versão / V205)
* **Suíte de Mutação UI:** Usar ferramenta externa ou macro que injete digitações erradas nos formulários ativamente (Fuzzing).
* **Teste Concorrente de Lock:** Simular arquivo travado por outro usuário (read-only mode) e confirmar que o Excel não quebra ao tentar salvar histórico.
* **Auto-Descrição na Interface:** Ao invés de exibir apenas "Sexteto", a interface deve listar `[ Executar Bateria Completa (Rodízio, Penais, Relatórios e Dados) ]` para maior clareza humana.

## 4. Recomendação: Microdelta Documental Proposto Após Auditorias

Para sanar as ressalvas e elevar a vitrine para um padrão de excelência governamental/institucional, recomendo a imediata execução do seguinte microdelta:

1. **Acentuação PT-BR**: Corrigir acentuação em todos os documentos públicos V204 (especialmente Guias e README).
2. **README e `doc/` vs `docs/`**: 
   - No `README.md`, destacar que `docs/INDEX.md` é a entrada principal de documentação.
   - Esclarecer que `doc/` armazena apenas "dados estruturais e CNAE" usados pela planilha.
3. **Limpeza Histórica (`docs/explanation/*` e `auditoria/*`)**:
   - Mover ou renomear arquivos de ondas/explicações antigas para pastas `historico/` ou adicionar cabeçalhos claros de descontinuação.
4. **Regras de Negócio**:
   - Criar o arquivo canônico e limpo: `docs/reference/regras/REGRAS_DE_NEGOCIO_V204.md`.
5. **Matriz Pública Consolidada**:
   - Criar/Atualizar a tabela consolidada no formato: “Regra de negócio → teste que garante → evidência canônica vinculada”.
6. **Índice de Evidências**:
   - Criar `auditoria/evidencias/V12.0.0204/INDEX.md` listando a evidência canônica aprovada (`VR_20260511_154433.csv`), as intermediárias, e documentando os débitos aceitos (como o prefixo V12_0_0203 no filename).
7. **Exportação de Guia Humano (.docx)**:
   - Gerar e versionar o guia Word completo: `docs/tutorials/GUIA_TESTES_HUMANOS_V204.docx`, mantendo a versão Markdown como código-fonte lado a lado, permitindo que o mantenedor anexe o docx ao enviar a planilha para as prefeituras.

## 5. Checklist de Publicação Pública

- [x] Código-fonte limpo e build travado.
- [x] Baterias automatizadas verdes rodando via UI.
- [x] Evidências extraídas e hashadas no repositório.
- [ ] Guias formatados com acentuação, fáceis de ler.
- [ ] Índice de Evidências explica qual CSV usar para validar o gate.
- [ ] Manual `.docx` disponível para download por operadores corporativos.
- [ ] Ruído histórico isolado (arquivamento de documentos de planejamento antigos).
