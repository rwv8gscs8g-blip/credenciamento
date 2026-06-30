---
titulo: Pointer spec — Ponteiro HBN de 1 linha, gerado do disco
diataxis: reference
status: accepted
temperatura: quente
id-global: 20260610-202640-fable-5-spec-pointer
path: core/pointer-spec.md
versao: 0.1.1   # FIX cross-audit 0031 F-02: ⟦HBN⟧ em code-fence ignorado pelo G-PTR
data: 2026-06-10
autoria: claude-fable-5 (consolidação ADR-024)
hearback-status: confirmed
relacionado: [ADR-024 (Decisão 3), ADR-021 (path: no front-matter — o G-PTR compara com ele), ADR-022, knowledge 0002]
---

# Pointer spec

## §1 Forma canônica (1 linha)

```markdown
⟦HBN⟧ [<path-relativo-à-raiz>](<href>) · sinal: <sinal HBN> · ação: <gesto esperado, 1 frase>
```

- **Texto do link = path RELATIVO à raiz = a VERDADE.** É a mesma string do
  `path:` do front-matter do destino (ADR-021) — verificável por diff.
- **href = clicabilidade, opcional na semântica**: `file://` absoluto da
  máquina do operador, com `#L<início>-L<fim>` opcional para fragmento.
  Se o href quebrar (outra máquina, container), o texto do link continua
  resolvendo sozinho a partir da raiz do repo.
- `sinal:` = estado operacional (vocabulário de sinais HBN vigente).
- `ação:` = o próximo gesto do leitor (knowledge 0002: instrução única com
  expectativa embutida).

Exemplo:

```markdown
⟦HBN⟧ [methodology/adr/ADR-024-orquestracao-start.md](file:///Users/macbookpro/Projetos/usehbn/methodology/adr/ADR-024-orquestracao-start.md) · sinal: 🔵 HBN HANDOFF READY · ação: ler o mapa de enforcement antes de auditar
```

## §2 Regras de emissão

1. **Gerado do disco, nunca de memória**: o emissor lê o arquivo DEPOIS de
   escrevê-lo e copia o `path:` do front-matter para o texto do link.
2. Ponteiro substitui colagem: artefato inteiro NUNCA viaja colado quando
   um ponteiro alcança o destinatário (colagem trunca; disco não).
3. Ponteiro não carrega conteúdo longo; o resumo de ≤10 linhas, quando
   devido, é do Relato de Estado (state-report-spec) ou do parecer ADR-022.
4. Forma degradada entre máquinas distintas: omitir o href e manter só
   `⟦HBN⟧ <path> · sinal · ação` — o path relativo segue verdadeiro.

## §3 Guard G-PTR (`assert-pointer-honest`) — spec, FORA do runner

Gatilho: arquivos staged (HEAD em CI) contendo linhas `⟦HBN⟧` (handoffs,
relatos, prompts em `.hbn/messages/`, `docs/prompts/`). Linhas dentro de
code-fence markdown (``` ou ~~~) são IGNORADAS: exemplos e templates de
ponteiro não são ponteiros reais (cross-audit 0031 F-02 — evita
falso-positivo/sobre-bloqueio em documentação).

1. BLOQUEADOR: path do texto do link não existe no disco (na revisão
   staged: `git cat-file -e :<path>` — herda a lição staged-skew
   E-FECH-01/02).
2. BLOQUEADOR: destino existe mas declara `path:` ≠ path do ponteiro
   (auto-localização e ponteiro divergem — um dos dois mente; ADR-021).
3. BLOQUEADOR: linha `⟦HBN⟧` sem `ação:` (ponteiro sem gesto transfere o
   custo ao receptor — anti-padrão "leia estes 7 documentos").
4. AVISO: href absoluto cuja cauda não termina no path relativo do texto
   (href apontando para arquivo diferente do declarado).

Casos de teste (estilo `guards/tests/run-guard-tests.sh`, repo git
descartável):

```
check "ptr: ponteiro íntegro (path existe, == front-matter, com ação)"  pass
check "ptr: path inexistente no staged"                                 block
check "ptr: path existe mas front-matter declara outro path:"           block
check "ptr: linha sem ação:"                                            block
check "ptr: href divergente do path relativo"                           pass-com-aviso
check "ptr: exemplo ⟦HBN⟧ em code-fence ignorado"                       pass   # 0031 F-02
check "ptr: destino bom só na working tree, ausente do staged (skew)"   block
```
