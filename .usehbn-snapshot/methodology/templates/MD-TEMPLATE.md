---
titulo: NN - MD-<letra ou número> — <tema>
id-global: AAAAMMDD-NN          # ADR-011 Decisão 1 (linha de nascimento no REGISTRY)
path: <caminho/real/do/arquivo.md>   # ADR-021: caminho REAL — o guard compara
temperatura: quente             # ADR-011 Decisão 3 (quente | frio | ultrapassado)
diataxis: how-to
hbn-track: safe_track
hbn-status: active
audiencia: ambos (humano + IA)
versao-protocolo: useHBN <pre-v1 | X.Y.Z>
data: YYYY-MM-DD
autor: <quem depositou>
escopo: <pré-requisito de ADR-XXX | implementação de ADR-YYY | hardening operacional>
relacionado:
  - <ADRs ou outros MDs>
---

# NN. MD-<letra> — <Tema>

> Tipo de MD: **(plano | spec | execução | hardening | release)**.
> Documento de coordenação para mudança operacional atômica.

## A. Tema

O que muda em uma frase.

## B. Pré-requisito

- ADR-XXX deve estar `ACCEPTED`.
- MD-Y concluído.
- v204 final publicada (se aplicável).
- Hearback humano explícito sobre o escopo.

Se nenhum, declarar: "Sem pré-requisito; pode iniciar imediatamente."

## C. Arquivos permitidos

Lista exaustiva e explícita:

- `caminho/arquivo1.md`
- `caminho/arquivo2.py:linha-faixa` (se for edit cirúrgico em parte do arquivo)
- ...

## D. Arquivos proibidos

Lista exaustiva e explícita do que **não pode** ser tocado mesmo
incidentalmente:

- `caminho/proibido1.md` — razão (ex.: gate de outro MD pendente)
- `caminho/proibido2/` — razão
- ...

## E. Diff planejado

Descrição do que vai mudar em cada arquivo permitido. Para arquivos
de código, citar trechos exatos quando útil.

## F. Gates

Testes ou verificações que **devem passar** antes de declarar o MD
concluído:

- `pytest -q` retorna verde (≥N tests passing).
- `hbn doctor --target <path>` OK.
- `git diff --stat` mostra apenas arquivos da §C.
- Cross-IA review se aplicável (≥1 IA distinta confirma).
- Hearback humano se mudar contrato externo.

## G. Riscos e mitigação

| # | Risco | Mitigação |
|---|---|---|
| R1 | ... | ... |
| R2 | ... | ... |

## H. Rollback

Caminho exato de reversão:

- `git revert <sha>` do commit do MD.
- Ou: `git checkout <tag-de-backup> -- <arquivos>`.
- Ou: passos manuais ordenados se rollback automático não cabe.

## I. Output esperado

O que fica no repo após o MD fechar:

- Arquivo X criado/atualizado.
- Teste novo Y verde.
- ADR-Z destravado (se aplicável).
- Memória atualizada com Z (se aplicável).

## J. Versão

- v1.0 — YYYY-MM-DD — <autor> — depósito inicial.
