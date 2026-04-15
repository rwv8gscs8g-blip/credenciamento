# Checklist Pre-Deploy

Relacionado: [[Compilacao-VBA]], [[Governanca]]

Este checklist DEVE ser executado antes de qualquer importacao de modulos no Excel.
Todos os comandos devem retornar VAZIO para que o deploy seja autorizado.

---

## Verificacoes Automatizadas

Executar a partir da raiz do projeto (`Credenciamento/`):

### 1. Colon Patterns (Killer #1)

```bash
grep -rn "Dim .* As .*:.*=" vba_export/*.bas vba_export/*.frm
```
**Esperado:** VAZIO
**Se houver resultado:** Separar `Dim X As T: X = valor` em duas linhas antes de prosseguir.

### 2. Operacoes FileSystem Nativas (Killer #2)

```bash
grep -rn "MkDir\|^\s*Kill \| Dir(" vba_export/*.bas vba_export/*.frm
```
**Esperado:** VAZIO
**Se houver resultado:** Substituir por FSO late-binding (`CreateObject("Scripting.FileSystemObject")`).

### 3. VB_Names Duplicados

```bash
grep -rh "Attribute VB_Name" vba_export/*.bas vba_export/*.frm | sort | uniq -d
```
**Esperado:** VAZIO
**Se houver resultado:** Dois arquivos tem o mesmo nome interno. Corrigir antes de importar.

### 4. Tipos Duplicados

```bash
grep -rn "Public Type" vba_export/*.bas | awk -F: '{print $NF}' | sort | uniq -d
```
**Esperado:** VAZIO
**Se houver resultado:** Existe mais de uma definicao do mesmo tipo. Manter apenas em Mod_Types.bas.

### 5. Encoding e Line Endings

```bash
file vba_export/*.bas vba_export/*.frm | grep -v "CRLF"
```
**Esperado:** Nenhuma linha sem CRLF (os que mostrarem apenas "ASCII text" sem mencao de CRLF podem ser OK se forem ASCII puro sem acentos).
**Critico:** Arquivos com "LF line terminators" (Unix) DEVEM ser convertidos para CRLF.

---

## Verificacoes Manuais

### 6. Backup

- [ ] Copiar .xlsm atual para `historico/` com nome datado

### 7. Release Note

- [ ] Criar release note em `obsidian-vault/releases/V12.0.XXXX.md`

### 8. Git

- [ ] Commit em vba_export/ com mensagem descritiva
- [ ] Tag: `git tag v12.0.XXXX`

---

## Processo de Importacao

1. Fechar Excel completamente
2. Abrir a planilha ativa
3. Alt+F11 para VBA Editor
4. Remover o modulo antigo (botao direito > Remover > NAO exportar)
5. Arquivo > Importar o .bas/.frm atualizado de vba_export/
6. Depurar > Compilar VBAProject
7. Se compilar: Ctrl+S e registrar sucesso
8. Se NAO compilar: fechar SEM salvar, reverter vba_export/ via git, investigar
