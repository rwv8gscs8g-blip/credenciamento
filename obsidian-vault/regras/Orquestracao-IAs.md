# Orquestracao de IAs no Projeto

Relacionado: [[Anti-Regressao]], [[Governanca]], [[01-CONTEXTO-IA]]

---

## Modelo Operacional

O projeto e desenvolvido por multiplas IAs em sessoes independentes. Cada IA:

1. **Le** 01-CONTEXTO-IA.md como primeiro ato (OBRIGATORIO)
2. **Executa** no maximo 1 iteracao (1 arquivo modificado)
3. **Documenta** a mudanca em release note
4. **Commita** no Git com tag
5. **Atualiza** o DASHBOARD e CONTEXTO-IA se necessario

---

## IAs e Seus Papeis

### Claude Opus (Cowork / Desktop)
- **Papel:** Arquitetura, documentacao, analise profunda, planejamento
- **Forte em:** Contexto longo, analise de dependencias, documentacao
- **Handoff:** obsidian-vault/handoff/Prompt-Opus.md

### Claude Sonnet (API / Cowork)
- **Papel:** Implementacao de features, modificacao de codigo VBA
- **Forte em:** Codigo, rapidez, iteracoes curtas
- **Handoff:** obsidian-vault/handoff/Prompt-Sonnet.md

### OpenAI Codex
- **Papel:** Modificacoes cirurgicas de codigo, scripts utilitarios
- **Forte em:** Edicoes precisas, seguir instrucoes literais
- **Handoff:** obsidian-vault/handoff/Prompt-Codex.md

### Outras IAs (Gemini, GPT, Cursor)
- **Papel:** Tarefas especificas com escopo limitado
- **Handoff:** obsidian-vault/handoff/Prompt-Generico.md

---

## Protocolo de Handoff

### Ao INICIAR uma sessao com qualquer IA

Fornecer na ordem:
1. Conteudo de `01-CONTEXTO-IA.md`
2. Conteudo de `regras/Compilacao-VBA.md`
3. Qual iteracao sera executada (numero da release + descricao)
4. O arquivo .bas ou .frm especifico a ser modificado

### Ao FINALIZAR uma sessao

A IA deve entregar:
1. Arquivo modificado em vba_export/
2. Release note em obsidian-vault/releases/
3. Resultado do checklist pre-deploy
4. Git commit com tag (se possivel)

---

## Manutencao de Contexto via GitHub

O repositorio Git e o mecanismo de contexto entre sessoes:

```
git log --oneline -10          # Ver ultimas mudancas
git diff v12.0.0107..HEAD      # Ver tudo que mudou desde a base
git show v12.0.0108:vba_export/Util_CNAE.bas  # Ver arquivo em versao especifica
```

Cada IA pode reconstruir o contexto completo lendo:
1. O vault Obsidian (documentacao)
2. O git log (historico de mudancas)
3. Os release notes (o que cada iteracao fez)

---

## Economia de Tokens

Para minimizar uso de tokens em sessoes curtas:

1. **Prompt minimo:** Usar Prompt-Codex.md (mais conciso)
2. **Escopo limitado:** "Modifique APENAS o arquivo X conforme especificacao Y"
3. **Sem exploracao:** Nao pedir para a IA "analisar o projeto inteiro" — fornecer contexto pronto
4. **Checklist como script:** Rodar o checklist pre-deploy como bash script, nao pedir para a IA verificar manualmente

---

## Regra de Ouro

**Nenhuma IA deve confiar em seu proprio contexto sobre o projeto.** O contexto autoritativo esta SEMPRE no vault Obsidian e no Git. Se houver conflito entre o que a IA "lembra" e o que esta documentado, o documento prevalece.
