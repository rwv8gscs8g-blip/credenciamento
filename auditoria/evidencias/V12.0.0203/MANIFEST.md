# Manifesto de Evidencias — V12.0.0203

Status: candidato verde em estabilizacao. Ainda nao e a promocao oficial da
release, porque o build validado foi gerado com arvore local em homologação.

## Build validado

| Campo | Valor |
|---|---|
| Release oficial vigente | `V12.0.0202` |
| Release alvo | `V12.0.0203` |
| Build importado | `20e400b-em-homologacao` |
| Branch | `codex/v12-0-0203-governanca-testes` |
| Pacote gerado em | `2026-04-26 11:50` |
| Resultado consolidado | `APROVADO` |

## CSVs de validacao release

| Arquivo | Linhas | SHA-256 |
|---|---:|---|
| `ValidacaoRelease_V12_0_0203_VR_20260426_105501.csv` | 5 | `39888b27c187ed1950d9dc76d993a1b30952cc8e1635f3e67e9e98322a184265` |
| `ValidacaoRelease_V12_0_0203_VR_20260426_111549.csv` | 5 | `26083a1b42771eed105af42be8cc502c672055dd7a48242c3f4cd0b7c660feba` |

## Leitura objetiva para IA

```text
VALIDACAO_RELEASE=VR_20260426_111549
BUILD=20e400b-em-homologacao
V1_RAPIDA=OK; EXECUCAO=BO-20260426-111549; OK=171; FALHA=0; MANUAL=0
V2_SMOKE=OK; EXECUCAO=TV2_20260426_112130; OK=14; FALHA=0; MANUAL=0
V2_CANONICO=OK; EXECUCAO=TV2_20260426_112250; OK=20; FALHA=0; MANUAL=0
RESULTADO=APROVADO
```

## Condicao para fechamento final

- Commitar a linha candidata.
- Regenerar o pacote de importacao com arvore limpa, com estado `homologado`.
- Reimportar `AAX-App_Release.bas` e os modulos necessarios.
- Rodar novamente o validador consolidado.
- Atualizar este manifesto com o build limpo final.
