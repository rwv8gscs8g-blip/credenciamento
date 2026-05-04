---
titulo: Matriz publico vs CLA-controlado — referencia definitiva
diataxis: reference
audiencia: ambos (humano + IA)
hbn-track: fast_track
versao-sistema: V12.0.0203
data: 2026-04-29
---

# Matriz publico vs CLA-controlado — referencia definitiva

Esta tabela define **definitivamente** o que e publico (auditavel
sem CLA) e o que e controlado por CLA (entregue via release zip apos
aceite rastreavel).

## Categoria 1 — Codigo do produto (PUBLICO)

| Item | Localizacao | Justificativa |
|---|---|---|
| Modulos VBA | `src/vba/*.bas` | parte do produto que roda no `.xlsm` |
| Formularios VBA | `src/vba/*.frm` + `src/vba/*.frx` | parte do produto que roda no `.xlsm` |
| Importador V2 (modulo VBA) | `src/vba/Importador_V2.bas` | codigo do produto, dentro do workbook |

## Categoria 2 — Documentacao tecnica (PUBLICO)

| Item | Localizacao | Justificativa |
|---|---|---|
| Auditoria por tipo | `auditoria/00_status/`, `auditoria/01_regras_e_governanca/`, `auditoria/02_planos/`, `auditoria/03_ondas/`, `auditoria/04_evidencias/` | auditabilidade publica integral |
| Diataxis | `docs/tutorials/`, `docs/how-to/`, `docs/reference/`, `docs/explanation/` | navegacao para humanos |
| Coordenacao HBN | `.hbn/relay/`, `.hbn/knowledge/`, `.hbn/readbacks/`, `.hbn/results/`, `.hbn/reports/` | governanca inter-IA publica |
| Vitrine institucional | `obsidian-vault/00-DASHBOARD.md`, `obsidian-vault/releases/`, `obsidian-vault/metodologia/` | apresentacao publica |

## Categoria 3 — Governanca e licencas (PUBLICO)

| Item | Localizacao | Justificativa |
|---|---|---|
| Licenca | `LICENSE` (TPGL v1.1) | obrigatoriedade legal |
| CLA | `CLA.md` | contribuidor le antes de assinar |
| Codigo de conduta | `CODE_OF_CONDUCT.md` | aplicavel a todos |
| Contribuicao | `CONTRIBUTING.md` | fluxo publico |
| Seguranca | `SECURITY.md` | politica publica |
| Changelog | `CHANGELOG.md` | rastreabilidade publica |
| README | `README.md` | porta de entrada |

## Categoria 4 — Mapas para LLMs (PUBLICO)

| Item | Localizacao | Justificativa |
|---|---|---|
| Entrada para IAs | `AGENTS.md` | padrao agents.md publico |
| Mapa curado LLM | `llms.txt` | padrao llmstxt.org publico |
| Mapa exaustivo LLM | `llms-full.txt` | indexacao publica |
| Instrucoes Claude | `CLAUDE.md` | aponta para `AGENTS.md` |

## Categoria 5 — Manifestos e contratos de formato (PUBLICO)

| Item | Localizacao | Justificativa |
|---|---|---|
| Especificacao do manifesto | `docs/reference/MANIFESTO_FORMAT.md` | contrato publico — implementacao e privada |
| Especificacao do importador | `docs/reference/IMPORTADOR_V2.md` (a criar 9.5) | contrato publico |
| Matriz CMMI/ISO | `docs/reference/COMPLIANCE_CMMI_ISO.md` | aderencia auditavel |
| Governanca de release | `docs/reference/GOVERNANCA_DE_RELEASE_E_EVIDENCIA.md` | processo publico |

## Categoria 6 — CLA-CONTROLADO (entregue via release zip)

| Item | Localizacao | Justificativa de restricao |
|---|---|---|
| Pacote operacional de import | `local-ai/vba_import/` | reconstroi o `.xlsm` — modificacao livre quebra Regra de Ouro |
| Ferramentas Bash/Python | `local-ai/scripts/publicar_vba_import_v2.sh`, `publicar_vba_import_v2.py`, `glasswing-checks.sh`, `install-git-hooks.sh` | sincronizam src/vba <-> vba_import — uso indevido pode corromper |
| Exports do workbook | `local-ai/incoming/` | dados brutos que podem conter PII |
| Backups historicos | `local-ai/historico/` | snapshots de iteracoes antigas — ruido para publico |
| Vault Obsidian privado | `local-ai/obsidian-vault/` | notas internas de operacao |
| Auditorias internas (legacy) | `local-ai/auditoria/` | esforco intermediario antes de virar publico |
| Scripts operacionais one-shot | `local-ai/scripts/onda*-cleanup.sh`, etc | uso unico, manutencao |

## Categoria 7 — Auto-gerenciado por git/sistema (NAO COMMITAR)

| Item | Localizacao | Razao |
|---|---|---|
| Diretorio git interno | `.git/` | gerenciado pelo git |
| Arquivos sistema operacional | `.DS_Store`, `Thumbs.db` | sistema operacional |
| Hooks git locais | `.git/hooks/pre-commit` | local-only |
| Excel binarios | `*.xlsm`, `*.xlsx` | binarios — checksum vai em evidencias |
| Excel temporarios | `~$*.xls*` | sessoes abertas |

## Categoria 8 — Limites do `.gitignore` (CONFIRMACAO)

O `.gitignore` raiz contem:

```
# Versoes historicas
historico/
V12-*/

# Backups
*.bak
backups/
local-ai/
local-only/
.local/

# Excel
*.xlsm
*.xlsx
~$*.xls*

# Sistema
.DS_Store
Thumbs.db

# IDE
.vscode/
.idea/
*.swp
```

A linha `local-ai/` **e a base do modelo de acesso controlado**.
Modificar essa linha sem aprovacao explicita do mantenedor viola o
modelo.

## Como contribuidor identifica em qual categoria algo esta

1. Esta em `src/vba/`? PUBLICO.
2. Esta em `auditoria/`, `docs/`, `.hbn/`, `obsidian-vault/`? PUBLICO.
3. Esta em `local-ai/`? CLA-CONTROLADO.
4. Esta em arquivos canonicos da raiz (`README.md`, `CLA.md`,
   `LICENSE`, etc.)? PUBLICO.
5. E `*.xlsm` ou `*.xlsx`? Auto-gerenciado — nao commitar.

## Glasswing G7 + G8 + G9 (proposto)

A camada de Cybersegurança Preventiva inclui ou incluira:

- **G7** — pacote vba_import sincronizado com src/vba (ja vigente)
- **G8** — Public Type apenas em Mod_Types.bas (ja vigente)
- **G9 (proposto)** — segregacao publico/CLA respeitada (Onda futura)

## Referencias

- [Por que essa divisao existe (explanation)](../explanation/MODELO_DE_ACESSO_CONTROLADO.md)
- [Como obter ferramentas (how-to)](../how-to/COMO_OBTER_FERRAMENTAS_VBA.md)
- [Protocolo HBN-native](../../.hbn/knowledge/0007-acesso-controlado-via-cla.md)
- [CLA.md](../../CLA.md)
- [LICENSE — TPGL v1.1](../../LICENSE)
