# Prompt Generico (qualquer IA)

Copiar TODO o conteudo abaixo. Funciona com qualquer modelo de linguagem.

---

Voce vai modificar UM arquivo de codigo VBA em um projeto Excel. O projeto esta na pasta `Credenciamento/` e o codigo-fonte fica em `vba_export/`.

REGRAS QUE VOCE NAO PODE VIOLAR:

1. Modifique APENAS 1 arquivo por vez
2. NUNCA escreva `Dim x As Tipo: x = valor` (tudo na mesma linha). SEMPRE separe em duas linhas:
   ```vba
   Dim x As Tipo
   x = valor
   ```
3. NUNCA use MkDir, Kill ou Dir() — use CreateObject("Scripting.FileSystemObject")
4. NUNCA mude o Attribute VB_Name de nenhum arquivo
5. NUNCA remova funcoes ou tipos Public que ja existem
6. SEMPRE use chamadas qualificadas: `NomeDoModulo.NomeDaFuncao`

ANTES DE ENTREGAR, rode estes comandos e confirme que TODOS retornam vazio:
```bash
grep -rn "Dim .* As .*:.*=" vba_export/*.bas vba_export/*.frm
grep -rn "MkDir\|^\s*Kill \| Dir(" vba_export/*.bas vba_export/*.frm
grep -rh "Attribute VB_Name" vba_export/*.bas vba_export/*.frm | sort | uniq -d
```

TIPOS DISPONIVEIS (ja definidos em Mod_Types.bas, NAO redefinir):
TResult, TConfig, TEmpresa, TEntidade, TCredenciamento, TPreOS, TOS, TAvaliacao, TAtividade, TServico, TRodizioResultado, TAppContext

ENTREGUE:
1. O arquivo .bas ou .frm modificado
2. Uma nota explicando o que mudou
3. O resultado dos comandos de verificacao acima

TAREFA: [INSERIR AQUI]
