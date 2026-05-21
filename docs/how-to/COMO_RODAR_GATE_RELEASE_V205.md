---
titulo: Como Rodar o Gate de Release V205
diataxis: how-to
hbn-track: safe_track
hbn-status: active
audiencia: humano
versao-sistema: V12.0.0205
data: 2026-05-21
---

# Como Rodar o Gate de Validação de Release (RVS)

## Procedimento

1. Abra a planilha V12.0.0205 no Excel Desktop.
2. Habilite macros.
3. Abra a **Central de Testes**.
4. Execute `[1] Gate de Validação de Release (RVS)`.
5. Aguarde o resultado.
6. Confirme a sintaxe:

```text
V1=171/0+V2_Smoke=34/0+V2_Canonica=24/0+E2E_Strikes=76/0+IntegridadeBase=4/0+Onda23Adv=27/0
```

## Falha

Se o resultado for diferente, não aprove a release. Registre:

- print da mensagem;
- CSV gerado;
- horário;
- build;
- descrição do desvio.
