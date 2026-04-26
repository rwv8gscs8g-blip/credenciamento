# Manifesto de Evidencias — V12.0.0203

Status: candidato verde em estabilizacao. Ainda nao e a promocao oficial da
release, porque o build validado foi gerado com arvore local `dirty`.

## Build validado

| Campo | Valor |
|---|---|
| Release oficial vigente | `V12.0.0202` |
| Release alvo | `V12.0.0203` |
| Build importado | `20e400b-dirty` |
| Branch | `codex/v12-0-0203-governanca-testes` |
| Pacote gerado em | `2026-04-26 11:50` |
| Resultado consolidado | `APROVADO` |

## CSVs de validacao release

| Arquivo | Linhas | SHA-256 |
|---|---:|---|
| `ValidacaoRelease_V12_0_0203_VR_20260426_105501.csv` | 5 | `473e2ac5849d863761d6051c10abbe3f8f0359a5a318356f788a5a82f40a38cb` |
| `ValidacaoRelease_V12_0_0203_VR_20260426_111549.csv` | 5 | `5883538404c9dd6aeacda10053431a91a634c13655715d82e886e5bcf9fc3975` |

## Leitura objetiva para IA

```text
VALIDACAO_RELEASE=VR_20260426_111549
BUILD=20e400b-dirty
V1_RAPIDA=OK; EXECUCAO=BO-20260426-111549; OK=171; FALHA=0; MANUAL=0
V2_SMOKE=OK; EXECUCAO=TV2_20260426_112130; OK=14; FALHA=0; MANUAL=0
V2_CANONICO=OK; EXECUCAO=TV2_20260426_112250; OK=20; FALHA=0; MANUAL=0
RESULTADO=APROVADO
```

## Condicao para fechamento final

- Commitar a linha candidata.
- Regenerar o pacote de importacao com arvore limpa, sem `-dirty`.
- Reimportar `AAX-App_Release.bas` e os modulos necessarios.
- Rodar novamente o validador consolidado.
- Atualizar este manifesto com o build limpo final.
