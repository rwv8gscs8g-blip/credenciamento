---
titulo: Regras Inviolaveis do Projeto
ultima-atualizacao: 2026-04-12
autor-ultima-alteracao: Claude Opus 4.6
tags: [vivo, regra]
versao-sistema: V12.0.0145
---

# Regras Inviolaveis do Projeto Credenciamento

> Leitura obrigatoria para qualquer IA que assuma este projeto.
> Estas regras foram aprendidas com meses de erros. Ignora-las causa loops destrutivos.

## 1. Fonte de Verdade

- `vba_export/` e SEMPRE a fonte de verdade do codigo VBA
- `vba_import/` e artefato de deploy gerado a partir de `vba_export/`
- Nunca editar `vba_import/` sem espelhar em `vba_export/`
- A versao oficial e definida em `vba_export/App_Release.bas`

## 2. Killer Patterns (causam modulo invisivel no VBE)

### Killer #1 — Colon Pattern

```vba
' NUNCA:
Dim r As Long: r = 4

' SEMPRE:
Dim r As Long
r = 4
```

O compilador background do VBA corrompe o indice de membros publicos com este padrao.
Historico: 34 colon patterns causaram 4+ reimportacoes completas.

### Killer #2 — FileSystem Nativo

```vba
' NUNCA: MkDir, Kill, Dir()
' SEMPRE: CreateObject("Scripting.FileSystemObject")
```

### Verificacao obrigatoria antes de qualquer commit

```bash
grep -rn "Dim .* As .*:.*=" vba_export/*.bas vba_export/*.frm
grep -rn "MkDir\|^\s*Kill \| Dir(" vba_export/*.bas vba_export/*.frm
grep -rh "Attribute VB_Name" vba_export/*.bas vba_export/*.frm | sort | uniq -d
```

Todos devem retornar VAZIO.

## 3. Regras de Negocio

- `ATIVIDADES` = baseline estrutural permanente de CNAEs (formato DDDD-D/DD)
- `CAD_SERV` = associacao operacional manual de servicos aos CNAEs
- `CREDENCIADOS` = credenciamento por atividade (nao por servico)
- Rodizio opera no nivel de ATIVIDADE via `Svc_Rodizio`
- NUNCA auto-gerar servicos ficticios em `CAD_SERV` como clone de `ATIVIDADES`

## 4. Formato CNAE

- Formato padrao: `DDDD-D/DD` (ex: `0162-8/02`)
- Sem pontos. A funcao `FormatarCodigoCNAE` normaliza
- IDs sao texto com zeros a esquerda: "001", "002" (NumberFormat "@")
- Contador de registros em coluna AR (44), linha 1

## 5. Protecao de Abas

- Usar `Util_PrepararAbaParaEscrita` / `Util_RestaurarProtecaoAba`
- Senhas tentadas em ordem: "", "sebrae2024", "SEBRAE2024"
- `ProximoId` faz proprio ciclo protect/unprotect (nao chamar Util_ junto)

## 6. Modulos e Types

- NUNCA modificar, renomear ou remover `Public Type` existentes em `Mod_Types.bas`
- NUNCA renomear modulos (`Attribute VB_Name`)
- NUNCA usar chamadas qualificadas em forms (`Preencher.MyFunc` falha, usar `MyFunc`)

## 7. Processo de Iteracao

Toda iteracao DEVE terminar com:
1. Auditoria (grep de killers)
2. Edicao em `vba_export/`
3. Copia para `vba_import/` (ou `publicar_vba_import.sh`)
4. Bump de versao em `App_Release.bas`
5. Release note em `obsidian-vault/releases/`
6. Compilacao manual no Excel (Debug > Compilar)
7. Teste funcional pelo usuario

## 8. VBE — Importacao de Modulos

- VBE NAO substitui modulos ao importar — cria duplicatas (ex: Preencher1)
- Para reimportar: DELETAR modulo antigo no VBE primeiro (Remover > Nao exportar)
- Modulos de teste sao descartaveis para compilacao do core

## 9. Documentos Relacionados

- [[PIPELINE]] — Ciclo detalhado de iteracao
- [[ESTADO-ATUAL]] — Versao e status correntes
- [[GOVERNANCA]] — Rastreabilidade de autoria IA
- [[known-issues]] — Issues conhecidos
