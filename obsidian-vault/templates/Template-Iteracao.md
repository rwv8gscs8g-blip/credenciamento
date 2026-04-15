# Template de Iteracao

Copiar este template para iniciar uma nova iteracao de desenvolvimento.

---

## Iteracao: V12.0.XXXX

**Data:** DD/MM/AAAA
**IA responsavel:** [Claude Opus / Sonnet / Codex / outro]
**Arquivo modificado:** [nome_do_arquivo.bas ou .frm]
**Tipo:** [NOVO modulo | MODIFICACAO | BUG FIX | REFATORACAO]

### Objetivo

[Descrever em 1-2 frases o que esta iteracao faz]

### Pre-Requisitos

- [ ] Lido 01-CONTEXTO-IA.md
- [ ] Lido regras/Compilacao-VBA.md
- [ ] Backup do .xlsm feito
- [ ] Release anterior compila (V12.0.XXXX-1)

### Modificacoes Realizadas

[Listar exatamente o que mudou, com numeros de linha se possivel]

### Checklist Pre-Deploy

- [ ] `grep "Dim .* As .*:.*=" vba_export/*.bas` = VAZIO
- [ ] `grep "MkDir\|Kill\|Dir(" vba_export/*.bas` = VAZIO
- [ ] `grep -rh "Attribute VB_Name" vba_export/*.bas | sort | uniq -d` = VAZIO
- [ ] `grep -rn "Public Type" vba_export/*.bas | awk -F: '{print $NF}' | sort | uniq -d` = VAZIO

### Resultado da Compilacao

- [ ] Depurar > Compilar VBAProject = SUCESSO
- [ ] Teste basico funcional = SUCESSO

### Git

```bash
git add vba_export/[arquivo_modificado]
git commit -m "feat(vXX.X.XXXX): [descricao]"
git tag v12.0.XXXX
```

### Notas para proxima iteracao

[O que a proxima IA precisa saber]
