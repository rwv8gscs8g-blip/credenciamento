---
titulo: Pipeline de Iteracao
ultima-atualizacao: 2026-04-12
autor-ultima-alteracao: Claude Opus 4.6
tags: [vivo, regra]
versao-sistema: V12.0.0145
---

# Pipeline de Iteracao

> Cada IA que pega o bastao deve seguir este ciclo para cada mudanca no codigo.

## Ciclo Completo

```
1. LER contexto
   ├── 00-DASHBOARD.md (ponto de entrada)
   ├── ai/REGRAS.md (regras inviolaveis)
   ├── ai/ESTADO-ATUAL.md (versao e status)
   └── ai/handoffs/Seu-Handoff.md (instrucoes especificas)

2. PLANEJAR mudanca
   ├── Criar documento no bastao: NNNN-YYYY-MM-DD-Assunto.md
   └── Descrever o que vai fazer e por que

3. AUDITAR codigo existente
   ├── grep killers (colon patterns, FileSystem nativo)
   ├── grep VB_Names duplicados
   └── Resultado deve ser VAZIO

4. EDITAR em vba_export/
   ├── Fazer a mudanca
   └── Todas Dim no topo da funcao, sem colon patterns

5. COPIAR para vba_import/
   └── Usar publicar_vba_import.sh ou copiar manualmente

6. VERSIONAR
   ├── Bump APP_RELEASE_ATUAL em App_Release.bas
   └── Criar release note em obsidian-vault/releases/

7. INSTRUIR usuario
   ├── No VBE: Deletar modulo antigo > Importar novo
   ├── Debug > Compilar VBAProject
   └── Teste funcional

8. DOCUMENTAR resultado
   ├── Atualizar documento no bastao com resultado
   ├── Atualizar ESTADO-ATUAL.md se houve mudanca de status
   └── Atualizar GOVERNANCA.md
```

## Regras do Pipeline

- NUNCA pular o passo de auditoria (passo 3)
- NUNCA pedir reimportacao sem auditoria completa
- Um problema = uma reimportacao (nao acumular)
- Se a reimportacao falhar: diagnosticar ANTES de tentar de novo
- O usuario valida manualmente no Excel a cada passo

## Checklist Pre-Commit

```bash
# 1. Colon patterns (deve retornar vazio)
grep -rn "Dim .* As .*:.*=" vba_export/*.bas vba_export/*.frm

# 2. FileSystem nativo (deve retornar vazio)
grep -rn "MkDir\|^\s*Kill \| Dir(" vba_export/*.bas vba_export/*.frm

# 3. VB_Names duplicados (deve retornar vazio)
grep -rh "Attribute VB_Name" vba_export/*.bas vba_export/*.frm | sort | uniq -d

# 4. Versao atualizada
grep "APP_RELEASE_ATUAL" vba_export/App_Release.bas
```

## Documentos Relacionados

- [[REGRAS]] — Regras inviolaveis
- [[ESTADO-ATUAL]] — Versao e status correntes
- [[GOVERNANCA]] — Rastreabilidade
