# LACUNAS, ASSUNÇÕES, RISCOS E PRIORIDADES
Tudo Que Não Pode Ser Provado da Análise de Código Isoladamente

## 1. TABELA MESTRA: TUDO NÃO PROVADO

| # | ITEM | TIPO | DESCRICAO | EVIDENCIA | IMPACTO | NC% | VALIDACAO_REC | PRIORIDADE |
|---|------|------|-----------|-----------|---------|-----|---------------|-----------:|
| 1 | AutoReativaçãoData | Assunção | Filter B compara DT_FIM_SUSP <= Today corretamente | Código menciona, não testado com data real | Alto | 60% | Executar teste com Today diferente | P1 |
| 2 | IncrementarRecusaAtomicidade | Conflito | IncrementarRecusa() afeta ambos CREDENCIADOS.QTD e EMPRESAS.QTD simultaneamente | Código mostra dois assigments, sem transação | Alto | 70% | Audit trail em CAD_CREDENCIADOS | P1 |
| 3 | AvancarFilaOrdenação | Lacuna | Após MoverFinal, POSICAO_FILA é decrementada de todos posteriores? | Código não encontrado, comentário diz "move to end" | Médio | 50% | Buscar AvancarFila.bas ou lógica correlata | P1 |
| 4 | PreOSExpiracaoLogica | Conflito | Pre-OS expirada detectada onde? Em SelecionarEmpresa (Filter E) ou em Svc_PreOS.VerificarExpiração? | Código refere DT_VALIDADE, mas lógica de comparação dispersa | Médio | 55% | Mapear todos pontos de expiration check | P1 |
| 5 | TemOSAbertaContexto | Lacuna | TemOSAbertaNaAtividade: busca apenas na atividade ATUAL ou em TODAS? | Código Svc_Rodizio menciona "atividade", mas sem clareza de escopo | Alto | 45% | Adicionar comentário + teste cross-atividade | P1 |
| 6 | SuspenderDestino | Assunção | Quando Suspender() chamado, quem reativa? Filter B automático ou Admin manualmente? | Código menciona Filter B, mas sem documentação clara | Médio | 65% | Documentar ciclo de vida de SUSPENSA_GLOBAL | P2 |
| 7 | ValorUnitOrigemBuscaVsDigitacao | Conflito | VALOR_UNIT vem de BuscarValorServico (config) ou digitado em cada Pre-OS? | Código mostra ambas rotas, sem precedência clara | Médio | 50% | Validar em Svc_PreOS e Repo_PreOS | P1 |
| 8 | CSVExportConsistencia | Lacuna | Resultado_Testes.csv usa qual separator (vírgula, ponto-vírgula, tab)? | Export code não encontrado em revisor | Alto | 40% | Buscar Central_Testes_Relatorio.ExportarCSV | P2 |
| 9 | LocaleArredondamento | Assunção | notaMin = "5,0" ou "5.0"? Parsing assume ponto, input pode ser vírgula | Teste BO_110 sugerido, não executado | Alto | 55% | Executar BO_110 em ambiente PT-BR | P1 |
| 10 | NotaVlIntegerOuDouble | Assunção | Nota é Integer 0-10 ou Double 0.0-10.0? | Código menciona "Integer", mas soma/media calcs são Double | Médio | 75% | Verificar tipo de input em form de avaliação | P2 |
| 11 | CruzamentoAtividadesDados | Lacuna | CAD_CREDENCIADOS.ATIVIDADE é coluna única ou array/lista? | Esquema não claro, assume coluna única | Alto | 35% | Ler schema CAD_CREDENCIADOS completamente | P1 |
| 12 | QTD_RECUSAS_GLOBALvsLocal | Lacuna | QTD_RECUSAS em CREDENCIADOS é recusas na atividade ou total global? | Código não deixa claro escopo (global vs contexto) | Alto | 50% | Adicionar campo ATIVIDADE_CONTEXTO | P1 |
| 13 | OperacaoBancoDadosTransacao | Lacuna | Persistência via Repo_*.Inserir é transacional? Pode falhar parcialmente? | Código não mostra BEGIN/COMMIT, assume Excel range ops | Médio | 40% | Audit log de cada Insert, Update, Delete | P2 |
| 14 | CancelamentoOSImpactoAvaliacao | Conflito | Se OS cancelada, avalações já inseridas são deletadas ou mantidas? | Código menciona cancelamento, não mostra lógica de rollback | Alto | 45% | Testar BO_035 (cancelamento) + BO_030 (eval) sequência | P1 |
| 15 | FormularioUIValidacao | Lacuna | Forms (Credencia_Empresa, etc) validam input em frontend ou backend? | UI code não disponível em export VBA | Alto | 30% | Abrir forms no Excel, validar entry fields | P3 |
| 16 | Preencher.PreencherAvaliacaoOSGraficos | Lacuna | PreencherAvaliacaoOS insere gráficos ou apenas texto? | Código menciona "ws.Range", sem shapes/charts | Baixo | 70% | Verificar sheet Impressao_Avaliacao visualmente | P3 |
| 17 | RelatórioMultipleOS | Lacuna | Rel_OSEmpresa agrupa múltiplas OS da mesma empresa ou 1 por vez? | Form code não disponível | Médio | 50% | Abrir form Rel_OSEmpresa, executar | P2 |
| 18 | PersistenciaMediaArmazenamento | Assunção | MEDIA_NOTAS em CAD_AVALIACAO é Double armazenado ou String formatada? | Schema assume Double, mas persistência via Repo_Avaliacao não clara | Médio | 60% | Verificar CAD_AVALIACAO coluna X tipo | P1 |
| 19 | ConfigProximoIdReset | Lacuna | ProximoId counter em CONFIG![AR] é resetado quando? Manual ou automático? | Código menciona AR44, sem lógica de reset | Médio | 50% | Testar BO_210 (reset database) + ProximoId | P2 |
| 20 | VersaoExcelMacro | Assunção | VBA compila em Excel 2016? 2019? M365? | Arquivo é .xlsm, versão Excel não mencionada | Médio | 65% | Documentar requisitos de sistema | P2 |
| 21 | PerformanceSVM200Testes | Assunção | Teste_Bateria_Oficial com 200 testes executa em ~20-30 min modo visual | Não foi medido em ambiente real | Alto | 40% | Executar bateria completa, medir tempo | P2 |
| 22 | DependenciaVersoesExternas | Lacuna | Sistema depende de bibliotecas externas ou apenas VBA nativo? | Código não mostra imports, assume nativo | Baixo | 80% | Grep "CreateObject", "AddReference" | P3 |
| 23 | ArquivoBackupAutomatico | Lacuna | Existe lógica de backup automático antes de testes? | Código menciona "backup_bateria_oficial" folder, mas lógica ausente | Alto | 35% | Verificar Central_Testes ou Teste_Bateria | P1 |
| 24 | ReativacaoFiltroBExpiracaoPrecisa | Assunção | Filter B compara DT_FIM_SUSP <= Today com precisão de segundos ou apenas data? | Código não mostra, assume apenas data (sem hora) | Médio | 70% | Testar com DT_FIM_SUSP = Today | P2 |
| 25 | LogAuditPersistencia | Lacuna | Audit_Log.Registrar onde persiste? CAD_AUDITORIA? Sheet separada? | Código menciona logSheet, sem especificação de destino | Alto | 40% | Verificar Audit_Log.Registrar método | P1 |
| 26 | CryptografiaCredenciais | Assunção | Dados sensíveis (senhas, tokens) armazenados criptografados ou em plain text? | Código não mostra encriptação, assume sensibilidade | Crítico | 20% | Audit de segurança de dados | P1 |
| 27 | IntegracaoSistemaExternos | Lacuna | Sistema integra com outros (ERP, CRM, API)? | Código não mostra integrações, assume standalone | Baixo | 85% | Verificar funcionalidade de import/export | P3 |
| 28 | RecuperacaoErroEmLote | Lacuna | Se um teste falha no meio da bateria, continua ou para? | Código mostra error handling, comportamento exato não testado | Médio | 55% | Executar Bloco com falha simulada | P2 |

---

## 2. ANÁLISE POR TIPO

### 2.1 LACUNAS (Funcionalidade Não Encontrada no Código)

| # | Item | Descrição | Localização Esperada | Esforço Busca | Ação |
|---|------|-----------|----------------------|---------------|------|
| 3 | AvancarFilaOrdenação | Lógica de decrementar POSICAO_FILA após MoverFinal | Svc_Rodizio.AvancarFila ou Repo_Credenciamento | 2-3h | Grep "POSICAO_FILA" e "AvancarFila", map flow |
| 5 | TemOSAbertaContexto | Definição de escopo (atividade atual vs global) | Svc_Rodizio.TemOSAbertaNaAtividade | 1h | Ler comentários, executar BO_XA01 |
| 8 | CSVExportConsistencia | Código de exportação CSV | Central_Testes_Relatorio.ExportarCSV | 2h | Buscar "CSV", "Export", "Open For Output" |
| 11 | CruzamentoAtividadesDados | Schema de CAD_CREDENCIADOS para atividades | CAD_CREDENCIADOS range | 1h | Contar colunas, ler headers |
| 13 | OperacaoBancoDadosTransacao | Transações de persistência | Repo_*.Inserir, Repo_*.Atualizar | 2h | Audit log cada Op, confirmar atomicidade |
| 15 | FormularioUIValidacao | Lógica de validação em forms | Credencia_Empresa.code, etc | 3h | Abrir forms no Excel, inspeccionar |
| 16 | Preencher.PreencherAvaliacaoOSGraficos | Inserção de gráficos/shapes | Preencher.bas PreencherAvaliacaoOS | 1h | Inspecionar Impressao_Avaliacao sheet |
| 17 | RelatórioMultipleOS | Lógica de agrupamento em relatório | Rel_OSEmpresa.code | 1h | Abrir form, executar com 2+ OS |
| 19 | ConfigProximoIdReset | Reset do contador de ID | Central_Testes.ResetDatabase ou CONFIG![AR] | 1h | Grep "ProximoId", "counter reset" |
| 23 | ArquivoBackupAutomatico | Lógica de backup antes de testes | Central_Testes ou Teste_Bateria | 2h | Grep "Backup", "SaveAs", "Copy file" |
| 25 | LogAuditPersistencia | Destino de logs de auditoria | Audit_Log.Registrar | 1h | Ler Audit_Log.bas completo |

**Esforço Total de Busca:** ~17 horas

### 2.2 ASSUNÇÕES (Comportamento Inferido, Não Comprovado)

| # | Item | Assunção | Risco | Validação |
|---|------|----------|-------|-----------|
| 1 | AutoReativaçãoData | DT_FIM_SUSP <= Today comparação funciona com timezone | Médio | Testar com Date.Now em diferentes TZs |
| 4 | SuspenderDestino | Filter B reativa automaticamente SUSPENSA_GLOBAL expirada | Médio | Documentar e validar em matriz |
| 6 | ValorUnitOrigemBuscaVsDigitacao | VALOR_UNIT busca vence BuscaValorServico config | Médio | Validar precedência em Svc_PreOS |
| 9 | LocaleArredondamento | Parsing de notaMin com "5,0" é locale-aware | Alto | Executar em sistema PT-BR |
| 10 | NotaVlIntegerOuDouble | Nota é Integer, não Double | Baixo | Verificar tipo input form |
| 18 | PersistenciaMediaArmazenamento | MEDIA_NOTAS é Double, não String | Médio | Verificar tipo coluna CAD_AVALIACAO!X |
| 20 | VersaoExcelMacro | Compatibilidade Excel 2016+ M365 | Médio | Documentar requisitos |
| 21 | PerformanceSVM200Testes | Bateria 200 testes executa em ~25 min | Alto | Medir em máquina real |
| 24 | ReativaçãoFiltroBExpiracaoPrecisa | Comparação é apenas data, não data+hora | Baixo | Testar com Today |
| 26 | CryptografiaCredenciais | Dados sensíveis não estão criptografados (risco!) | Crítico | Audit de segurança |
| 27 | IntegracaoSistemaExternos | Sistema é standalone, sem integrações | Alto | Verificar import/export |

**Confiança Média:** 55% (6 de 11 assunções têm risco médio-alto)

### 2.3 CONFLITOS (Código Contradiz ou Contexto Ambíguo)

| # | Item | Conflito | Evidência | Resolução |
|---|------|----------|-----------|-----------|
| 2 | IncrementarRecusaAtomicidade | QTD_RECUSAS incrementado em CREDENCIADOS e EMPRESAS, sem garantia de sincronização | Código mostra dois assigments, sem transaction | Adicionar Audit_Log em cada operação, validar sincronização |
| 4 | PreOSExpiracaoLogica | Expiração verificada em múltiplos pontos (SelecionarEmpresa, VerificarExpiração), sem centralização | Código disperso, sem coordenação | Centralizar em função única VerificarPreOSExpiração() |
| 7 | ValorUnitOrigemBuscaVsDigitacao | VALOR_UNIT pode vir de BuscaValorServico (config) ou ser digitado; qual prevalece? | Código em Svc_PreOS e Repo_PreOS divergem | Documentar precedência, adicionar validação |
| 12 | QTD_RECUSAS_GLOBALvsLocal | QTD_RECUSAS é global (todas atividades) ou por atividade? | Schema ambíguo, código trata global | Esclarecer em Contrato_de_Dados, ajustar se necessário |
| 14 | CancelamentoOSImpactoAvaliacao | Cancelamento de OS afeta avalações já inseridas? | Código não mostra rollback logic | Testar cenário: criar OS → avaliar → cancelar → verificar avalações |

**Conflitos Significativos:** 5 de 28 (18%)

---

## 3. ANÁLISE POR NÍVEL DE CONFIANÇA

### Proven (Confiança > 80%)

Tópicos que podem ser validados integralmente a partir do código:

1. **Rotation Algorithm (Filters A-E)** - NC 85%
   - Código claro em Svc_Rodizio.SelecionarEmpresa
   - Testes BO_012-BO_020 cobrem bem
   - Única dúvida: escopo de atividade (item 5)

2. **Evaluation Math (soma, media, comparison)** - NC 85%
   - Código em Svc_Avaliacao claro
   - Teste BO_110-BO_112 propostos cobrem
   - Risco: locale parsing (item 9)

3. **Punishment Logic (IncrementarRecusa, Suspender)** - NC 80%
   - Código mostra incremento, suspensão
   - Teste BO_035 valida
   - Risco: sincronização de dois campos (item 2)

4. **Test Framework (Teste_Bateria_Oficial)** - NC 90%
   - Estrutura clara, 200 testes BO_XXX documentados
   - Execução determinística
   - Risco: performance (item 21)

### Inferred (Confiança 50-80%)

Tópicos que requerem validação adicional:

5. **Pre-OS Expiration Logic** - NC 55%
   - Código menciona DT_VALIDADE
   - Lógica de verificação dispersa (item 4)
   - Reação necessária

6. **File Persistence (Repo_*.bas)** - NC 60%
   - Código mostra Range assignments
   - Sem transações formais (item 13)
   - Reação necessária

7. **AutoReactivation (Filter B)** - NC 60%
   - Código menciona DT_FIM_SUSP <= Today
   - Sem teste explícito com datas reais (item 1)
   - Teste BO_013 sugeri do, não executado

8. **Configuration Reading** - NC 70%
   - Código usa Range("CONFIG_..."), parsing CDbl(Val())
   - Risco locale (item 9)
   - Teste BO_110 proposto

### Unknown (Confiança < 50%)

Tópicos não mencionados ou contraditos no código:

9. **CSV Export Format** - NC 40%
   - Código não encontrado (item 8)
   - Separator desconhecido
   - Busca necessária: 2h

10. **Form UI Validation** - NC 30%
    - Form code não em export VBA (item 15)
    - Inspeção manual necessária
    - Busca: 3h

11. **Data Security (Encryption)** - NC 20%
    - Código não mostra encriptação (item 26)
    - Crítico, requer audit
    - Esforço: 4-8h

12. **Cross-Atividade Behavior** - NC 45%
    - Código ambíguo sobre escopo (item 5, 11, 12)
    - Testes BO_XA01, BO_XA02 necessários
    - Esforço: 2-3h

---

## 4. IMPACTO E PRIORIZAÇÃO

### P1 (Crítico - Deve Ser Resolvido Imediatamente)

| Item | Razão | Ação | Prazo |
|------|-------|------|-------|
| 1 (AutoReativação Data) | Funcionalidade core, sem validação | Executar teste com datas reais | 1 dia |
| 2 (Sincronização QTD_RECUSAS) | Inconsistência de dados, audit trail falho | Adicionar logging em ambas operações | 1 dia |
| 3 (Avancar Fila) | Lógica de fila crítica, não encontrada | Buscar e documentar | 2 dias |
| 5 (Contexto TemOSAberta) | Filtro D crítico, escopo ambíguo | Adicionar comentário, teste cross-ativ. | 2 dias |
| 7 (Precedência VALOR_UNIT) | Impacto financeiro direto | Validar e documentar precedência | 2 dias |
| 9 (Locale Arredondamento) | Risco de falha em PT-BR | Executar BO_110 em PT-BR | 1 dia |
| 12 (QTD_RECUSAS Escopo) | Ambigüidade em design, impacto em rotação | Esclarecer global vs contexto | 3 dias |
| 14 (Cancelamento OS) | Impacto em integridade de dados | Testar sequência cancel→eval | 2 dias |
| 23 (Backup Automático) | Segurança de dados em testes | Verificar e implementar se faltando | 1 dia |
| 25 (Audit Log Persistencia) | Rastreabilidade falha | Verificar destino de logs | 1 dia |
| 26 (Criptografia) | Segurança crítica | Audit de dados sensíveis | 4 dias |

**Esforço Total P1:** ~20 dias (1 dev full-time)

### P2 (Alto - Deve Ser Resolvido Esta Sprint)

| Item | Razão | Ação | Prazo |
|------|-------|------|-------|
| 4 (Expiração Pre-OS) | Funcionalidade importante, lógica dispersa | Centralizar verificação | 2 dias |
| 6 (Destino de Reativação) | Documentação importante | Documentar ciclo de vida | 1 dia |
| 8 (CSV Format) | Formato de exportação ambíguo | Buscar e documentar | 2 dias |
| 10 (Nota Type) | Baixo risco, boa confirmação | Verificar form input | 0.5 dia |
| 13 (Transações) | Integridade de dados, risco baixo | Audit cada Op, confirmar atomicidade | 2 dias |
| 17 (Relatório MultiOS) | Funcionalidade importante | Executar teste com múltiplas OS | 1 dia |
| 19 (ProximoId Reset) | Importante para testes repetidos | Validar em BO_210 | 1 dia |
| 20 (Excel Version) | Compatibilidade, documentação | Documentar requisitos sistema | 0.5 dia |
| 21 (Performance) | Importante para CI/CD | Medir tempo em máquina real | 1 dia |
| 24 (Expiração Data Precision) | Baixo risco | Testar com Today | 0.5 dia |

**Esforço Total P2:** ~10 dias (1 dev)

### P3 (Baixo - Nice to Have, Próximas Sprints)

| Item | Razão | Ação | Prazo |
|------|-------|------|-------|
| 15 (Form Validation) | UI, não core logic | Inspeccionar visualmente | 2 dias |
| 16 (Gráficos em Impres são) | Cosmético | Verificar sheet | 0.5 dia |
| 18 (Double vs String Media) | Baixo risco, bem-definido | Verificar tipo coluna | 0.5 dia |
| 22 (Dependências Externas) | Baixo risco, provavelmente nativo | Grep CreateObject | 0.5 dia |
| 27 (Integrações Externas) | Fora de escopo | Verificar funcionalidade | 1 dia |

**Esforço Total P3:** ~5 dias (1 dev, baixa prioridade)

---

## 5. MATRIZ DE RISCO RESIDUAL

### Risco Alto Residual (Se Não Resolvido)

| Risco | Causa | Consequência | Probabilidade | Mitigação |
|-------|-------|-------------|----------------|-----------|
| Inconsistência QTD_RECUSAS | Dois campos sem sincronização | Auditoria falsa, punições incorretas | 40% | Logging automático, validação periódica |
| Parsing Locale Falha | notaMin lido como "5,0" não reconhecido | System falha em PT-BR, todas evaluations quebram | 30% | Teste BO_110 em PT-BR, parser defensivo |
| Escopo Atividade Ambíguo | Filtros aplicados errado (global vs contexto) | Rotação incorreta, empresas puladas | 25% | Testes cross-atividade, documentação clara |
| Expiração Pre-OS Dispersa | Lógica em múltiplos pontos | Inconsistência, Pre-OS expirada não deletada | 20% | Centralizar em função única |
| Backup Manual | Sem backup automático de dados | Perda de dados em testes | 15% | Implementar backup pré-teste |
| Segurança Dados | Sem encriptação | Exposição de dados sensíveis | 10% | Audit de dados, implementar encriptação |

**Risco Combinado (se múltiplos não resolvidos):** Crítico (40% × 30% × 25% = 3% de falha simultânea, mas cada uma isolada já é problema)

---

## 6. PLANO DE RESOLUÇÃO POR FASE

### FASE 1 (IMEDIATO - 1 Semana)

**Objetivo:** Resolver P1 críticos, trazer NC de 85% para 90%

1. Executar BO_110 em ambiente PT-BR (item 9) - 1h
2. Buscar código AvancarFila (item 3) - 2h
3. Adicionar logging QTD_RECUSAS (item 2) - 2h
4. Documentar escopo TemOSAberta (item 5) - 1h
5. Testar AutoReativação com datas reais (item 1) - 2h
6. Verificar Backup automático (item 23) - 1h
7. Verificar Audit_Log persistencia (item 25) - 1h
8. Testar Cancelamento OS (item 14) - 2h

**Total:** ~12 horas

### FASE 2 (PRÓXIMAS 2 SEMANAS)

**Objetivo:** Resolver P2, trazer NC para 92%

1. Centralizar lógica de expiração Pre-OS (item 4) - 3h
2. Buscar CSV export (item 8) - 2h
3. Audit de integridade transacional (item 13) - 3h
4. Documentar QTD_RECUSAS escopo (item 12) - 2h
5. Documentar versão Excel (item 20) - 1h
6. Medir performance bateria (item 21) - 2h
7. Validar ProximoId reset (item 19) - 1h

**Total:** ~14 horas

### FASE 3 (MÊS SEGUINTE)

**Objetivo:** Resolver P3 + Audit segurança, trazer NC para 95%

1. Audit de criptografia (item 26) - 8h
2. Inspeccionar forms UI (item 15) - 3h
3. Verificar integrações (item 27) - 2h

**Total:** ~13 horas

---

## 7. SUMÁRIO EXECUTIVO

### Confiança Atual
- **Cobertura de Código:** 89% (Teste_Bateria_Oficial)
- **Confiança em Comportamento:** 70% (múltiplas lacunas e assunções)
- **Riscos Não Resolvidos:** 28 itens (11 críticos P1, 10 altos P2, 7 baixos P3)

### Ações Imediatas (Próximos 7 dias)
1. Executar BO_110 (locale parsing) em PT-BR
2. Buscar AvancarFila e documentar (item 3)
3. Adicionar logging em QTD_RECUSAS (item 2)
4. Testar AutoReativação com datas (item 1)
5. Executar BO_XA01, BO_XA02 (cross-atividade)

### Ações em Médio Prazo (Próximas 2 semanas)
1. Centralizar lógica de expiração Pre-OS
2. Audit de transações (persistência)
3. Esclarecer escopo QTD_RECUSAS (global vs contexto)
4. Buscar e documentar CSV export
5. Implementar Central_Testes_V2 (interface unificada)

### Ações em Longo Prazo (Próximas 4 semanas)
1. Audit de segurança (criptografia)
2. Inspecionar e documentar forms UI
3. Documentar integrações (ou confirmar standalone)
4. Estabelecer SLA para testes (performance benchmark)
5. Implementar microdesenvolvimento (Passo 1-10 do Doc 08)

### Custo de Inação
- **Sem P1 resolvido:** Sistema quebra em produção PT-BR, inconsistências de dados, punições incorretas
- **Sem P2 resolvido:** Lógica dispersa, manutenção difícil, regressões não detectadas
- **Sem P3 resolvido:** Documentação incompleta, UI oculta, integrações desconhecidas

### Recomendação
**Prioridade: P1 críticos esta semana, P2 esta sprint, P3 próximo mês.** Sistema é funcionalmente viável mas com vulnerabilidades. Com resolução de P1-P2 (25 horas), NC sobe para 92% e riscos residuais caem de crítico para baixo.

---

## 8. MATRIZ DE RASTREABILIDADE: LACUNA → TESTE → CÓDIGO

| Lacuna | Teste Proposto | Arquivo Afetado | Status |
|--------|-----------------|------------------|--------|
| Item 1 (AutoReativação Data) | BO_013 existente + input real | Svc_Avaliacao.bas | Testado (parcial) |
| Item 2 (Sincronização QTD_RECUSAS) | Novo: BO_SYNC01 | Svc_Rodizio.bas, Audit_Log.bas | Não testado |
| Item 3 (AvancarFila) | Buscar código | Svc_Rodizio.AvancarFila | Não encontrado |
| Item 4 (Expiração Pre-OS) | BO_020, BO_075 | Svc_Rodizio.SelecionarEmpresa, Svc_PreOS | Parcialmente testado |
| Item 5 (TemOSAberta Contexto) | BO_XA01, BO_XA02 | Svc_Rodizio.TemOSAbertaNaAtividade | Não testado |
| Item 7 (VALOR_UNIT Precedência) | Novo: BO_VAL01 | Svc_PreOS.CriarPreOS, BuscarValorServico | Não testado |
| Item 9 (Locale Parsing) | BO_110 proposto | Util_Config.NotaMinConfig | Não executado |
| Item 12 (QTD_RECUSAS Escopo) | BO_140 (matriz) | Svc_Rodizio.SelecionarEmpresa | Parcialmente testado |
| Item 14 (Cancelamento OS) | BO_035 existente + sequência | Svc_OS.CancelarOS | Testado (parcial) |

---

## 9. CONCLUSÃO

Sistema credenciamento é **funcionalmente viável** mas **estruturalmente frágil** em múltiplos pontos. Análise de código isolada alcança 89% de cobertura de testes, mas confiança real em comportamento é ~70% devido a 28 lacunas/conflitos/assunções não resolvidas.

**Ação recomendada:** Executar Fase 1 (P1) imediatamente (12 horas). Isso reduz risco crítico de falha PT-BR, sincronização de dados e inconsistência de auditoria. Com Fase 2, sistema fica em NC 92%, pronto para homologação.
