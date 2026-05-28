---
titulo: Hearback 0114 AT-3 Svc_PreOS / Repo_PreOS
diataxis: status
hbn-track: safe_track
hbn-status: active
audiencia: ambos
versao-sistema: V12.0.0206
data: 2026-05-27
---

# Hearback confirmado — 0114 AT-3 Svc_PreOS / Repo_PreOS

Mauricio confirmou em chat:

> confirmado — abrir readback AT-3 incorporando os FORTES do 0019 como restrições de escopo

Interpretação operacional:

- GATE-A2 fica aprovado pelas auditorias cruzadas 0017/0018 e pela reauditoria 0019.
- Codex pode abrir e executar AT-3 em `Svc_PreOS.bas` e `Repo_PreOS.bas`.
- Os FORTES do 0019 entram como restrições do escopo:
  - write-side em `Svc_PreOS.EmitirPreOS` é o fix primário;
  - `Repo_PreOS.Inserir` deve ser blindado como gêmeo dormente;
  - dados legados `PRE_OS` já gravados como `1` não terão backfill agora.
- Mauricio confirmou que os dados atuais do workbook são base de testes e podem ser descartados.
- Sobre IDs acima de 999, a decisão técnica recomendada é tratar `000` como largura mínima de exibição/persistência, não como largura máxima. Portanto `1000` deve permanecer `1000`, nunca ser truncado para `000`.
