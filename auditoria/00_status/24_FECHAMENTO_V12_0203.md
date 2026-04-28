---
titulo: Fechamento Candidato da V12.0.0203
natureza-do-documento: consolidacao operacional de estabilizacao
versao-oficial-vigente: V12.0.0202
linha-alvo: V12.0.0203
branch: codex/v12-0-0203-governanca-testes
build-candidato: 20e400b-em-homologacao
data: 2026-04-26
status: candidato verde, aguardando build limpo final
---

# 24. Fechamento Candidato da V12.0.0203

Este documento consolida o estado atual da linha `V12.0.0203`. Ele nao
promove a release como oficial e nao substitui a decisao humana final. A
funcao dele e deixar claro o que ja esta feito, o que segue pendente e o
que foi deliberadamente adiado para evitar regressao.

## 01. Resultado do candidato atual

| Item | Resultado |
|---|---|
| Build importado | `20e400b-em-homologacao` |
| Tela Sobre | build, branch e pacote gerado exibidos corretamente |
| V1 rapida | `OK=171`, `FALHA=0`, `MANUAL=0` |
| V2 Smoke | `OK=14`, `FALHA=0`, `MANUAL=0` |
| V2 Canonica | `OK=20`, `FALHA=0`, `MANUAL=0` |
| Validador consolidado | `VR_20260426_111549`, `APROVADO` |
| Evidencia | `auditoria/evidencias/V12.0.0203/` |

Interpretacao: o candidato esta verde para continuidade de estabilizacao.
Ainda nao e build final de release porque o estado `em homologação` indica
que a arvore local tinha alteracoes nao commitadas quando o pacote foi gerado.

## 02. Feito

- Governanca de release com separacao entre release oficial, release alvo,
  canal ativo e build importado.
- Tela `Sobre` exibe build importado, branch e data do pacote.
- V1 rapida, V2 Smoke e V2 Canonica verdes no validador consolidado.
- CSV de validacao release criado para evidenciar o trio minimo sem depender
  de prints.
- V2 Canonica ampliada para cobrir cenarios `CS_00..CS_24` relevantes da
  Sprint 2, incluindo bloqueios, suspensoes, transicoes invalidas,
  inativacao/reativacao e auditoria minima.
- V2 Smoke reforcado para cobrir expiração de Pre-OS, migracoes, mutacao
  rejeitada e atomicidade minima.
- V1 ajustada para reduzir duplicidade de mensagens, exportar CSV apenas em
  falha e limpar artefatos antigos quando solicitado.
- Primeiras fatias de desacoplamento da interface incorporadas sem tocar em
  `Mod_Types.bas`.
- Pacote local passou a destacar que `AAX-App_Release.bas` deve ser sempre
  importado em microevolucoes parciais.

## 03. Pendente antes da promocao oficial

- Fechar as alteracoes atuais em commit.
- Regenerar pacote com arvore limpa, com estado `homologado`.
- Reimportar `AAX-App_Release.bas` carimbado no workbook de homologacao.
- Rodar novamente o validador consolidado de release.
- Atualizar `App_Release.bas` para promocao oficial apenas no fechamento:
  `V12.0.0203`, `VALIDADO`, `OFICIAL`.
- Atualizar `CHANGELOG.md`, `STATUS-OFICIAL.md` e release note da `0203`.
- Criar tag `v12.0.0203` somente apos confirmacao humana final.

## 04. Adiado de proposito

- Desacoplamento total tela a tela da interface.
- Reescrita do importador automatico.
- Revisao estrutural de `Mod_Types.bas`.
- Unificacao fisica de V1 e V2; a unificacao atual permanece semantica.
- Redesign completo da UX dos testes assistidos.
- Padronizacao visual profunda dos relatorios e exportacao automatica de PDF.
- Documentacao narrada completa de todos os testes.

## 05. Proxima acao recomendada

Manter a esteira em microevolucoes pequenas. A proxima alteracao funcional
deve ser escolhida apenas se for necessaria para fechamento da `0203`. Caso
contrario, o foco deve ser consolidar commit limpo, regenerar pacote e repetir
o validador consolidado.

## 06. Bastao

IA com o bastao de implementacao: Codex.

Claude Opus permanece como apoio de auditoria e documentacao, sem editar
codigo e sem propor refatoracao ampla enquanto a `0203` nao for fechada.
