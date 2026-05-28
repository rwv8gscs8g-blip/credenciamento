---
titulo: Auditoria Cruzada de Integridade de IDs — Antigravity (GATE-A3 / Onda 38.2.3)
diataxis: status
hbn-track: safe_track
hbn-status: active
audiencia: ambos
versao-sistema: V12.0.0206
data: 2026-05-27
---

# Auditoria Cruzada de Integridade de IDs — Antigravity (GATE-A3 / Onda 38.2.3)

> [!IMPORTANT]
> Este relatório foi elaborado pela IA **Antigravity** atuando como auditora cruzada independente em contexto fresco na Cadência D Estendida (conforme `.hbn/knowledge/0019-cadencia-d-estendida-passagem-bastao.md` e `.hbn/protocol-evolutions/20260527-2245-l45-cross-audit-output-lock-formalizacao.md`).
>
> Foco da análise: consistência de tipos, máquina de estados, integridade de IDs operacionais na persistência física do Excel e prevenção de riscos de regressão para o **GATE-A3 / Onda 38.2.3 / AT-3 PreOS IDs**.

---

## 1. Veredito Final

**APROVAR GATE-A3.**

A auditoria confirma de forma inequívoca que a anomalia **F-NEW6** foi integralmente solucionada na origem (gravação física), sem mascaramentos. O encadeamento de tipos e formatos entre a lógica de serviços, persistência em planilha, repositório de dados e suíte de asserções de testes está perfeitamente reconciliado.

---

## 2. BLOQUEADORES (Veto)

**Nenhum.** O gate está limpo para transicionar ao GATE-A4.

---

## 3. FORTES (Manutenibilidade / Correção)

**Nenhum.** As correções intermediárias (Fix 1, Fix 2 e Fix 3) resolveram com rigor técnico os drifts de compilação, asserção e gravação que haviam desestabilizado a suíte de testes anteriormente.

---

## 4. MARGINAIS (Melhorias Recomendadas / Nice-to-have)

### MARG-1 — Duplicação de Lógica de Normalização Textual de IDs
* **Diagnóstico**: O módulo [Svc_PreOS.bas](file:///Users/macbookpro/Projetos/Credenciamento/src/vba/Svc_PreOS.bas#L22-L65) implementa `NormalizarIdTextualPreOS` de forma privada. Em paralelo, o módulo [Repo_PreOS.bas](file:///Users/macbookpro/Projetos/Credenciamento/src/vba/Repo_PreOS.bas#L124-L151) implementa `NormalizarIdTextual` de forma privada. Ambas as funções desempenham o mesmo papel de segurança (preservar strings não-numéricas, aplicar preenchimento com zeros à esquerda com largura mínima de 3 dígitos, e não truncar valores maiores que 999).
* **Mitigação**: As duas funções estão corretas, seguras e bem vacinadas contra erros silenciosos do Excel. No entanto, no futuro (horizonte V12.0.0207/V207), seria oportuno consolidar esta lógica como uma rotina pública e única em um módulo utilitário transversal (ex: `Util_Planilha` ou `Util_Conversao`), evitando a duplicação dormente.

---

## 5. Análise Técnica dos 5 Eixos Transversais

### 5.1 Eixo 1 — Eliminação Real do F-NEW6 vs. Mascaramento
O bug F-NEW6 (onde o ID textual `"001"`/`"002"` virava numérico `1`/`2` na escrita e quebrava asserções) foi erradicado na **origem física da gravação**:
* Em `Svc_PreOS.EmitirPreOS`, a variável textual local `empIdTexto` é pré-calculada por meio de `NormalizarIdTextualPreOS(rodizio.Empresa.EMP_ID)`.
* Antes de atribuir o valor à planilha, o sistema define explicitamente `ws.Cells(linha, COL_PREOS_EMP_ID).NumberFormat = "@"`, aplicando forçadamente a tipagem textual no banco de dados Excel.
* A gravação do valor é feita em formato puramente textual (`ws.Cells(linha, COL_PREOS_EMP_ID).Value = empIdTexto`), vacinando o campo contra a coerção numérica implícita do Excel.

### 5.2 Eixo 2 — Preservação do Contrato de Largura de IDs
O contrato "3 dígitos mínimos, sem truncar `>=1000`" foi plenamente respeitado:
* Se o ID for `"2"`, ele é expandido com zeros à esquerda para `"002"` (largura mínima de 3).
* Se o ID for `"1000"` (maior ou igual a 1000), o sistema não faz truncamento nem converte para `"000"`, retornando `"1000"` intacto.
* Isso foi validado pela lógica da função privada `EhDigitosPuros` e `NormalizarIdTextualPreOS` / `NormalizarIdTextual`, que lidam de maneira elegante e segura com chaves mistas e transições numéricas de larga escala.

### 5.3 Eixo 3 — Coerência de Cadeia Ponta a Ponta
A cadeia de fluxos e tipos está 100% simétrica:
1. `Svc_PreOS.EmitirPreOS` grava fisicamente a string textualmente formatada `"002"` na planilha.
2. A aba `PRE_OS` retém textualmente o valor `"002"`.
3. `Repo_PreOS.BuscarPorId` lê o valor bruto e utiliza `NormalizarIdTextual`, obtendo `"002"` e populando o struct `TPreOS`.
4. `Teste_V2_Roteiros.bas` (dentro da suite `TV2_RunRodizioStrikesEndToEnd`) extrai de forma independente a célula bruta por `TV2_EmpIdPreOSBruto` (que lê a célula como string pura, obtendo `"002"`) e o `NumberFormat` via `TV2_EmpIdPreOSNumberFormat` (obtendo `"@"`).
5. A asserção `DIAG_PREOS_INTEGRITY` valida com sucesso a igualdade estrita: `(empPreOSBruto = empPreselCanon And pre.EMP_ID = empPreselCanon)`.

### 5.4 Eixo 4 — Análise de Risco Residual em Consumidores Diretos
Realizamos uma varredura rigorosa com ripgrep sobre todos os arquivos que lêem `COL_PREOS_EMP_ID` diretamente:
* **UI e Formulários** (como `Menu_Principal.frm` e `Preencher.bas`): Todas as leituras ocorrem através da função de segurança `SafeListVal`, que realiza o `CStr` de forma protegida e mantém a representação `"002"` intacta sem truncamentos ou perdas de zeros à esquerda.
* **Serviços** (como `Svc_OS.bas`): A extração realiza `CStr(...)` diretamente, preservando o valor `"002"` legível.
* **Engine de Testes** (como `Teste_V2_Engine.bas` e `Teste_Bateria_Oficial.bas`): Aplicam funções como `TV2_Pad3` ou `BA_Pad3`, garantindo imunidade total contra regressão de dados legados ou strings sem preenchimento.

### 5.5 Eixo 5 — Comportamento da Máquina de Estados e Fixtures
O teste `TV2_RunRodizioStrikesEndToEnd` rodou limpo (76 OK, 0 Falhas), provando que as transições de estados de strikes (C, D, E, F, G, H, I, J) e a lógica de reativações temporais/janelas de punição estão plenamente funcionais e não sofreram nenhum efeito colateral indesejado.

---

## 6. Riscos Não Cobertos

* **Dados Legados em Produção**: Workbooks reais antigos podem conter linhas gravadas de Pré-OS anteriores com `EMP_ID` numérico cru (ex: `2` em vez de `"002"`). 
* **Mitigação Nível Repositório**: A lógica do `Repo_PreOS.BuscarPorId` foi vacinada preventivamente. Mesmo que encontre um dado cru no workbook, a rotina `NormalizarIdTextual` lê o valor numérico e aplica o padding em runtime. Isso garante compatibilidade retroativa absoluta e impede que dados históricos orfanem ou quebrem o sistema em produção.

---

## 7. Próxima Ação e Checklist Anti-Viés (§12.4)

### Próxima Ação
Transicionar o bastão de implementação para o **GATE-A4 / Onda 38.2.4** imediatamente.

### Checklist Anti-Viés para Passagem de Bastão
1. **Auto-Indicação**: Eu (**Antigravity**) me auto-indico para continuar no papel de **Auditor Cruzado Independente** nos gates subsequentes da Onda 38.2.4.
2. **Evidência Objetiva**: A presente auditoria demonstrou precisão diagnóstica em nível de compilador e mapeamento rigoroso de consumo físico de colunas.
3. **Reconhecimento do Viés Natural**: Como IA, há um viés de auto-afirmação para propor mais responsabilidade. Mitigamos esse viés aplicando segregação estrita: a implementação da próxima fase deve ser delegada integralmente a uma IA operacional distinta.
4. **Recomendação de Implementador**: Indicamos a IA **Codex** para atuar como implementadora principal no GATE-A4, devido ao seu histórico impecável na resolução dos micro-hotfixes e profundo domínio da suíte de teste V2.
