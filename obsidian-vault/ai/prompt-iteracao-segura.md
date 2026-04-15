# Prompt de Iteracao Segura — Credenciamento VBA

**Versao**: V12.0.0149+
**Objetivo**: Garantir que cada ciclo de iteracao no sistema VBA seja seguro, rastreavel e livre de regressao.

---

## CONTEXTO DO SISTEMA

Este e um sistema de credenciamento municipal em VBA Excel (.xlsm) que gerencia:
- Cadastro de entidades demandantes e empresas prestadoras
- Rodizio automatico para distribuicao equitativa de servicos
- Ordens de servico (Pre-OS, OS, Avaliacao)
- Relatorios de acompanhamento
- Bateria automatizada de testes (200+ cenarios)

### Arquitetura de Codigo

- `vba_export/` = **fonte de verdade** (codigo-fonte editavel)
- `vba_import/001-modulo/` = **artefato de deploy** (copia para importacao no VBA Editor)
- `obsidian-vault/` = documentacao viva (releases, regras, dashboard, prompts)
- Planilha `.xlsm` = runtime (recebe os modulos via importacao manual)

### Regras Inviolaveis

1. **Evitar reimportar todos manualmente** — importar apenas os que mudaram. Se precisar reimportar TUDO (por exemplo para limpar duplicidade), use o `Importador_VBA.bas` + manifesto para remover e reimportar em ordem segura.
2. **NUNCA editar o .xlsm diretamente** — sempre editar vba_export/ e reimportar
3. **NUNCA usar Chr() com valores > 255** — usar ChrW() para Unicode
4. **NUNCA confiar em variavel publica sem atribuicao explicita** antes do uso
5. **SEMPRE compilar (Debug > Compilar) apos importar** — zero erros e zero warnings
6. **SEMPRE fechar e reabrir o .xlsm apos importar** para limpar cache VBA
7. **NUNCA editar `vba_import/` diretamente** — sempre editar `vba_export/` e copiar para `vba_import/001-modulo/`
8. **NUNCA modificar/renomear/remover `Public Type` em `Mod_Types.bas`** (quebra compatibilidade)
9. **NUNCA renomear modulos** (nao mexer em `Attribute VB_Name`)
10. **NUNCA usar multiplas instrucoes na mesma linha com `:`** (ex.: `Dim x As Long: x = 1`)
11. **NUNCA usar `MkDir`, `Kill`, `Dir()` nativos** — usar FSO (late-binding)
12. **Arquivos `.bas`/`.frm` devem ficar em CRLF e com linha em branco final**

---

## PROCESSO DE ITERACAO SEGURA

### Fase 1: Diagnostico

Antes de qualquer alteracao:
1. Ler o `obsidian-vault/00-DASHBOARD.md` para entender a versao atual
2. Ler o `obsidian-vault/ai/ESTADO-ATUAL.md` para o estado funcional
3. Identificar EXATAMENTE quais modulos serao afetados
4. Verificar se o problema e VBA (codigo) ou planilha (template/formulas)

**Regra critica**: Se o problema e em aba de impressao (IMP_AVALIA, EMITE_PREOS, EMITE_OS) e nao envolve codigo VBA, o Claude Opus in Excel pode resolver. Se envolve codigo VBA, apenas este agente (Claude Code/Cowork) pode resolver.

### Fase 2: Implementacao

1. Editar APENAS os arquivos em `vba_export/`
2. Para cada arquivo editado:
   - Documentar O QUE mudou e POR QUE
   - Verificar que nao quebrou nada adjacente (grep por dependencias)
3. Bumpar a versao em `vba_export/App_Release.bas`
4. Copiar os arquivos editados (incluindo `App_Release.bas`) para `vba_import/001-modulo/`

### Fase 3: Validacao pre-importacao

Antes de pedir ao humano para importar:
1. Verificar que TODAS as correcoes anteriores estao intactas:
   - `Svc_Avaliacao.bas`: AvancarFila apos avaliacao (V147)
   - `Menu_Principal.frm`: media = mediaLocal (V147)
   - `Menu_Principal.frm`: ChrW(211) para PROVISORIA (V147)
   - `Central_Testes_Relatorio.bas`: ChrW(8212) nos 4 titulos (V147)
   - `Teste_Bateria_Oficial.bas`: Dashboard RESULTADO_QA (V148)
   - `Util_Config.bas`: Rel_ConfigurarPagina + helpers (V149)
   - `Menu_Principal.frm`: 5 relatorios com acentos/municipio/timestamp (V149)
2. Listar EXATAMENTE quais modulos o humano precisa importar (apenas os que mudaram)
3. Confirmar que nenhum modulo NAO-ALTERADO esta na lista

### Fase 4: Importacao pelo humano

Instrucoes padrao para o humano:
1. Abrir o VBA Editor (Alt+F11)
2. Para CADA modulo na lista:
   a. Localizar o modulo antigo no painel de projeto
   b. Clicar com botao direito > Remover > NAO exportar
   c. Arquivo > Importar Arquivo > selecionar o novo de `vba_import/001-modulo/`
3. Debug > Compilar (deve dar zero erros)
4. Salvar o .xlsm
5. Fechar e reabrir o .xlsm

### Fase 5: Validacao pos-importacao

1. Verificar versao: Menu Principal deve mostrar V12.0.0XXX
2. Executar bateria de testes (Central de Testes > Modo Rapido)
3. Se 0 FALHA: aprovado
4. Se FALHA > 0: analisar, corrigir, voltar a Fase 2

---

## CHECKLIST ANTI-REGRESSAO

A cada nova versao, verificar que estes itens continuam funcionando:

| # | Item | Como verificar |
|---|------|----------------|
| 1 | Rodizio avanca apos avaliacao | Completar ciclo PreOS > OS > Avaliacao, verificar que empresa volta ao fim da fila |
| 2 | Nota Total no relatorio de avaliacao | Preencher notas e verificar N37 no IMP_AVALIA |
| 3 | PROVISORIA sem mojibake | Emitir Pre-OS e verificar texto na planilha |
| 4 | Relatorio de bateria sem Error 5 | Gerar relatorio da bateria oficial |
| 5 | Dashboard RESULTADO_QA | Executar bateria no modo lento, verificar cabecalho/contadores/freeze |
| 6 | Relatorios de negocio com acentos | Imprimir cada um dos 5 relatorios |
| 7 | Municipio nos cabecalhos | Verificar que aparece no header dos relatorios |
| 8 | Compilacao limpa | Debug > Compilar = zero erros |

---

## DIVISAO DE RESPONSABILIDADES

### Claude Cowork (este agente) pode:
- Editar codigo VBA (vba_export/)
- Criar/editar documentacao (obsidian-vault/)
- Fazer push no GitHub
- Analisar bugs e propor correcoes
- Criar prompts para o Claude Opus in Excel

### Claude Opus in Excel pode:
- Editar celulas, formulas e formatacao diretamente na planilha
- Modificar templates de impressao (IMP_AVALIA, EMITE_PREOS, EMITE_OS)
- Aplicar formatacao condicional
- Ajustar PageSetup de abas existentes
- **NAO pode**: executar VBA, modificar modulos, compilar, criar macros

### Humano deve:
- Importar modulos no VBA Editor
- Compilar (Debug > Compilar)
- Fechar/reabrir o .xlsm
- Executar testes humanos
- Validar relatorios impressos
- Tomar decisoes de negocio (aprovar/reprovar)

---

## TEMPLATE DE RELEASE NOTES

Ao criar uma nova versao, preencher em `obsidian-vault/releases/V12.0.0XXX.md`:

```
# V12.0.0XXX
**Data:** YYYY-MM-DD
**Status:** EM_VALIDACAO

## Resumo
[1-2 frases descrevendo o que mudou]

## Modulos alterados
### NomeModulo.bas
- [Descricao da mudanca 1]
- [Descricao da mudanca 2]

## Modulos para importar (vba_import/001-modulo/)
1. `NNN-NomeModulo.bas`
2. ...

## Checklist anti-regressao
- [ ] Compilou sem erros
- [ ] Bateria automatizada: 0 FALHA
- [ ] Relatorios com acentos e municipio
- [ ] Rodizio funcional
```
