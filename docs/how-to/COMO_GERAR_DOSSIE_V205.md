---
titulo: Como Gerar o Dossiê V205
diataxis: how-to
hbn-track: safe_track
hbn-status: active
audiencia: ia
versao-sistema: V12.0.0205
data: 2026-05-21
---

# Como Gerar o Dossiê V12.0.0205

## Fonte

```text
docs/tutorials/DOSSIE_RELEASE_V12_0_0205.md
```

## DOCX

```bash
pandoc docs/tutorials/DOSSIE_RELEASE_V12_0_0205.md \
  --from markdown+reflink_references+pipe_tables \
  --to docx \
  --output docs/tutorials/DOSSIE_RELEASE_V12_0_0205.docx \
  --toc
```

## Hash

```bash
shasum -a 256 docs/tutorials/DOSSIE_RELEASE_V12_0_0205.docx
```

O hash deve ser registrado no YAML do Markdown fonte antes do fechamento da
release. O DOCX não deve ser editado manualmente.
