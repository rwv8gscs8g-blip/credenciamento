# Importador VBA — Manual Operacional

**Arquivo-fonte**: `vba_export/Importador_VBA.bas`
**Publicacao no pacote**: `vba_import/Importador_VBA.bas` (gerado por `scripts/publicar_vba_import.sh`)
**Objetivo**: importacao determinista e auditavel do projeto VBA, com backup automatico.

---

## 1. Pre-requisito: habilitar acesso ao VBOM

O importador manipula o VBA Project via `Application.VBE`. Por padrao, o Excel bloqueia esse acesso. Habilite uma vez:

1. Excel > **Arquivo > Opcoes**
2. **Centro de Confiabilidade > Configuracoes do Centro de Confiabilidade**
3. **Configuracoes de Macro**
4. Marque **"Confiar no acesso ao modelo de objeto do projeto VBA"**
5. OK / reinicie o Excel

Sem isso, qualquer chamada ao importador aborta com erro 1004 ou "acesso negado ao Project".

---

## 2. Comandos publicos

Todos ficam no modulo `Importador_VBA` (apos importar o `.bas` uma unica vez):

| Macro | O que faz |
|---|---|
| `ImportarPacoteCompleto` | Importa TODOS os itens do manifesto, com `Mod_Types` primeiro e purge de fantasmas. |
| `ImportarPacoteCredenciamentoV12` | Alias retrocompativel para `ImportarPacoteCompleto`. |
| `ImportarIncremental "Preencher, Menu_Principal"` | Importa somente a lista informada. Aceita VB_Name, caminho relativo ou absoluto. |
| `ImportarIncremental_Prompt` | Abre um InputBox para colar a lista (util quando nao se tem argumento). |
| `AAA_ImportarIncremental_Entidade` | Atalho: importa `Util_Planilha, Preencher, Reativa_Entidade, Menu_Principal, App_Release` (area Entidade + helpers em `Util_Planilha`). |
| `BackupVBAProject_Completo` | Exporta todos os componentes para `backups/vba/<timestamp>-FULL/`. Nao remove nada. |
| `Verificar_SemDuplicidade` | Checa: nomes duplicados, fantasmas com sufixo 1-9, `Public Type` em 2 modulos. |
| `Diagnostico_TConfig` | Lista todos os componentes e procura `Public Type TConfig` em qualquer deles. |

---

## 3. Como rodar importacao COMPLETA

Quando usar: primeira carga em planilha limpa, ou quando varios modulos mudaram e o seguro e republicar o pacote inteiro.

1. `bash scripts/publicar_vba_import.sh` (sincroniza `vba_import/` com `vba_export/`).
2. Abra o `.xlsm` alvo.
3. Se o modulo `Importador_VBA` ainda nao existir, importe-o manualmente uma vez:
   - Alt+F11 > clique direito no Project > **Import File...** > selecione `vba_import/Importador_VBA.bas`.
4. No Immediate Window (`Ctrl+G`), ou no menu **Executar > Macros**, rode:
   ```vba
   Call ImportarPacoteCompleto
   ```
5. Escolha a pasta `vba_import` quando solicitado.
6. Apos terminar, execute:
   ```vba
   Call Verificar_SemDuplicidade
   ```
7. **Depurar > Compilar VBAProject** — deve passar sem mensagens.
8. Salve o `.xlsm`.

O que acontece por baixo:

- Purge de legados (lista curada: `AAA_Types`, `Mod_Types1`, `AppContext1`, `Mod_AppContext`, `Util_CNAE`, etc.).
- Purge de "fantasmas": componentes cujo nome termina em `1..9` e cuja raiz (mesmo nome sem o digito) tambem existe no projeto.
- `Mod_Types` e reimportado primeiro (regra de ouro anti-cascata).
- Cada item do manifesto, na ordem: backup + remocao + import.
- Componentes `Document` (ThisWorkbook, Sheets) nunca sao removidos.

---

## 4. Como rodar importacao INCREMENTAL

Quando usar: microevolucao (1 ou 2 modulos alterados). Nao toca no resto do projeto.

Exemplo direto (com argumento):

```vba
Call ImportarIncremental("Preencher, Menu_Principal")
```

Ou por caminhos do pacote:

```vba
Call ImportarIncremental("001-modulo/AAT-Preencher.bas, 002-formularios/AAM-Menu_Principal.frm")
```

Ou por InputBox:

```vba
Call ImportarIncremental_Prompt
```

Separadores aceitos na lista: `,`, `;`, `|`, TAB, nova linha.

O importador:

1. Resolve cada item para um arquivo real dentro do pacote (`vba_import`).
2. Se `Mod_Types` estiver na lista, sempre e o primeiro a ser importado.
3. Para cada item: exporta o componente atual para o backup, remove, importa o novo.
4. Se algum item colidir com um fantasma (ex.: `Preencher1`), o fantasma e removido (com backup) antes.
5. Ao final, grava `importador.log` na pasta do backup.

### 4.1 Pacote sugerido: iteracao Entidade / Reativa / filtros

Equivalente ao atalho `AAA_ImportarIncremental_Entidade`:

```vba
Call ImportarIncremental("Util_Planilha, Preencher, Reativa_Entidade, Menu_Principal, App_Release")
```

Ou simplesmente:

```vba
Call AAA_ImportarIncremental_Entidade
```

### 4.2 Apos qualquer importacao incremental (checklist no Excel)

1. Selecionar a pasta `vba_import` quando o dialogo pedir.
2. **Depurar > Compilar VBAProject** (deve concluir sem erro).
3. Opcional e recomendado: `Verificar_SemDuplicidade` e `Diagnostico_TConfig`.
4. **Salvar** o `.xlsm`.

---

## 5. Backups automaticos

Caminho padrao:

```
<pasta do .xlsm>\backups\vba\<YYYYMMDD-HHMM>-<TAG>\
    Importador_VBA.bas
    Mod_Types.bas
    <...cada componente que foi trocado>
    importador.log
```

`<TAG>` varia por operacao: `COMPLETO`, `INCREMENTAL`, `FULL`, `DIAG`.

Se o workbook ainda nao tem caminho salvo (ex.: arquivo recem-criado sem `Salvar como`), o backup vai para `%TEMP%\backups\vba\...`.

---

## 6. Como restaurar a partir do backup

Cenario: algo deu errado apos uma importacao (regressao funcional, compilacao quebrada).

Opcao A — Incremental reverso pelos proprios arquivos exportados:

1. Abra a pasta do backup mais recente: `backups/vba/<timestamp>-INCREMENTAL/`.
2. Rode:
   ```vba
   Call ImportarIncremental("C:\caminho\backups\vba\<timestamp>-INCREMENTAL\Preencher.bas")
   ```
   O importador aceita caminhos absolutos, nao precisa mover os arquivos.

Opcao B — Reverter o repositorio e republicar:

1. Descarte as mudancas em `vba_export/` via `git restore` ou `git checkout`.
2. Republique: `bash scripts/publicar_vba_import.sh`.
3. Rode `Call ImportarIncremental(<nomes-afetados>)`.

Opcao C — Rollback completo:

1. Use o backup `FULL` (gerado via `BackupVBAProject_Completo`) se existir. Os `.bas`/`.frm` la podem ser reimportados um a um via `ImportarIncremental`.

---

## 7. Diagnostico: erro "Nome repetido: TConfig"

Checklist na ordem:

1. `Call Diagnostico_TConfig` — confirma que `Public Type TConfig` aparece em um unico modulo (`Mod_Types`).
2. `Call Verificar_SemDuplicidade` — deve dizer OK. Se apontar "Fantasma: X1 (convive com raiz X)", rode `Call ImportarIncremental("X")` para reimpor a versao do pacote (o importador purge o fantasma antes).
3. Se o diagnostico 1 e 2 estao OK mas a compilacao ainda acusa `TConfig`, trata-se de p-code corrompido. Nesse caso:
   - Salve o `.xlsm`, feche o Excel.
   - Abra o Excel em **planilha nova limpa** (Ctrl+N).
   - Importe `Importador_VBA.bas` e rode `Call ImportarPacoteCompleto`.
   - Compile. Funcionou -> salve a nova planilha. O binario antigo deve ser arquivado.
4. Procure colon patterns em qualquer arquivo recem-alterado:
   ```bash
   grep -nE 'Dim.*:.*=' vba_export/*.bas vba_export/*.frm
   ```

---

## 8. Regras do importador (nao violar)

- **Mod_Types sempre primeiro.**
- **Document nunca e removido.**
- **Backup antes de remover** (o log registra `[BAK] exportado+removido: <nome>`).
- **Nenhuma chamada a MkDir/Kill/Dir nativo** — so FSO (conforme `Compilacao-VBA.md`).
- **Nenhum colon pattern** no codigo do importador (validar com `grep -nE 'Dim.*:.*=' vba_export/Importador_VBA.bas`).
- **CRLF + linha em branco final** no `.bas` — `publicar_vba_import.sh` cuida disso.
- **VB_Name do importador permanece `Importador_VBA`** (nunca renomear).

---

## 9. Referencias

- `vba_export/Importador_VBA.bas` — codigo-fonte.
- `scripts/publicar_vba_import.sh` — gerador do pacote `vba_import/` (ja copia o importador).
- [[regras/Compilacao-VBA]] — regras absolutas (colon patterns, encoding, etc.).
- [[historico/Bug-Nome-Repetido-TConfig]] — post-mortem do bug TConfig.

Ultima atualizacao: 2026-04-17
