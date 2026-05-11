---
titulo: Fechamento MICRO54 Publicacao V204
diataxis: onda
hbn-track: safe_track
hbn-status: active
audiencia: ambos
versao-sistema: V12.0.0204
data: 2026-05-11
---

# MICRO54 — Fechamento e Publicacao V12.0.0204

## Objetivo

Promover a V12.0.0204 de release candidate para release oficial publica, sem
novo delta funcional, usando como ancora o build final ja validado pelo
operador.

## Base de decisao

| Evidencia | Resultado |
|---|---|
| Importador V3 MICRO53-fix2 | M=2, F=0, err=0, skip=0 |
| Compile manual VBE | OK |
| `?GetBuildImportado` | `f7aa84f+ONDA25.MD25.5-limpar-cad-serv-fix2` |
| Smoke | `TV2_20260511_131824` — OK=34, FALHA=0, MANUAL=4 |
| Teste manual | OK, incluindo Limpar Base e Cadastro de Servico |
| Gate final | `VR_20260511_154433` — APROVADO |

Sintaxe final:

`V1=171/0+V2_Smoke=34/0+V2_Canonica=24/0+E2E_Strikes=76/0+IntegridadeBase=4/0+Onda23Adv=27/0`

## Mudancas MICRO54

- `App_Release.bas` promovido para `APP_RELEASE_ATUAL = "V12.0.0204"`,
  `APP_RELEASE_STATUS = "VALIDADO"`, `APP_RELEASE_CANAL = "OFICIAL"` e
  `APP_RELEASE_TAG = "v12.0.0204"`.
- Release note publica criada em `obsidian-vault/releases/V12.0.0204.md`.
- `STATUS-OFICIAL.md`, README, dashboard, `docs/INDEX.md`, `llms.txt` e
  matriz de testes V204 alinhados ao gate final.
- HBN atualizado com readback/ERP MICRO54 e relay apontando para fechamento.

## Separacao publico/interno

Publico:

- README
- CHANGELOG
- `obsidian-vault/releases/STATUS-OFICIAL.md`
- `obsidian-vault/releases/V12.0.0204.md`
- `docs/reference/testes/06_MATRIZ_RASTREABILIDADE_TESTES_V204.md`
- `auditoria/evidencias/V12.0.0204/`

Interno/auditavel:

- `.hbn/readbacks/0063-onda25-md25-6-publicacao-v204-micro54.json`
- `.hbn/results/0063-exec-onda25-md25-6-publicacao-v204-micro54.json`
- `.hbn/relay/INDEX.md`
- manifestos V3 e RCA dos microdeltas reprovados.

## Debitos aceitos

- V205 deve renomear a taxonomia de "Sexteto" para nomenclatura profissional
  de testes de software.
- MD-24.4 permanece deferido para V205, sem reaproveitar MICRO49.
- O nome do CSV final ainda carrega prefixo historico `V12_0_0203`; o conteudo
  e a pasta estao corretos, e o debito fica registrado para higiene V205.
- Falhas historicas G1/G2/G5 do modo `--strict` ficam fora do gate critico da
  V204; G7/G8 seguem obrigatorios.

## Decisao

APROVAR publicacao da V12.0.0204 e preparar tag `v12.0.0204`.
