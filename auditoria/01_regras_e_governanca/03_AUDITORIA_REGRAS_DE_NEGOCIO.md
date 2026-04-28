# AUDITORIA DE REGRAS DE NEGOCIO — LINHA PUBLICA

Objetivo: consolidar, de forma objetiva, as regras de negocio efetivamente tratadas pela versao oficial `V12.0.0202`.

## 1. Fluxo de negocio validado

1. cadastro de empresas, entidades, atividades e servicos
2. credenciamento por atividade
3. selecao por rodizio
4. emissao de Pre-OS
5. conversao para OS
6. avaliacao do servico executado
7. punicoes, reativacoes e auditoria dos eventos criticos

## 2. Regras centrais cobertas

### Rodizio

- fila por atividade com ordenacao por `POSICAO_FILA`
- filtro por credenciamento ativo
- filtro por suspensao global com reativacao automatica quando vencida
- filtro por inatividade global
- filtro por OS aberta na mesma atividade
- filtro por Pre-OS pendente na mesma atividade
- avanco de fila com ou sem punicao, conforme o evento

### Pre-OS

- emissao condicionada a entidade valida e ativa
- controle de aceite, recusa e expiracao
- bloqueio de transicoes invalidas

### OS

- emissao condicionada a Pre-OS valida
- validacao de previsao de termino
- persistencia do fluxo de execucao

### Avaliacao

- avaliacao com 10 notas
- calculo de media
- validacao de quantidade executada
- exigencia de justificativa quando houver divergencia relevante
- possibilidade de usar observacao como suporte da justificativa
- suspensao automatica quando os strikes acumulados (avaliacoes com
  media abaixo da nota minima) atingem o limite configurado (regra
  ampliada na V12.0.0203 — ver R-60..R-62 abaixo)

### Strikes na avaliacao (V12.0.0203 — ONDA 1)

- **R-60 Contagem de strikes**: cada avaliacao com `MEDIA < NOTA_MINIMA`
  conta 1 strike para a empresa. A nota minima e parametro
  (`COL_CFG_NOTA_MINIMA`, default 5.0). Strikes sao recontados
  on-the-fly pela funcao `Repo_Avaliacao.ContarStrikesPorEmpresa`,
  varrendo `SHEET_CAD_OS` filtrado por `STATUS_OS = CONCLUIDA` e
  `COL_OS_MEDIA < notaCorte`.
- **R-61 Limite de strikes para suspensao**: quando os strikes
  acumulados atingem `MAX_STRIKES` (`COL_CFG_MAX_STRIKES`, default 3),
  a empresa e suspensa pelo helper `Svc_Rodizio.Suspender`. O caso
  `MAX_STRIKES = 1` reproduz a regra antiga (suspende na primeira nota
  baixa) e e usado como teste de retro-compatibilidade (`CS_AVAL_005`).
- **R-62 Punicao em dias**: a suspensao por strikes usa
  `DIAS_SUSPENSAO_STRIKE` (`COL_CFG_DIAS_SUSPENSAO_STRIKE`, default 90)
  como prazo absoluto em dias. Quando o valor for `0`, o helper cai no
  fallback historico em meses (`PERIODO_SUSPENSAO_MESES`), preservando
  compatibilidade com a regra de suspensao por excesso de recusas
  (R-09). A reativacao automatica continua valendo: empresa volta
  quando `DT_FIM_SUSP <= hoje`, via `Svc_Rodizio.SelecionarEmpresa`.

### Auditoria e seguranca operacional

- eventos criticos registrados em `AUDIT_LOG`
- senha de protecao centralizada sem exposicao literal no repositorio publico
- verificacoes de regressao por bateria oficial e V2

## 3. Estado atual das dependencias de regra

| Area | Estado |
|------|--------|
| Guardas criticas UI -> servico | Fechadas no nucleo principal |
| Baseline deterministica da V2 | Fechada |
| Atomicidade minima em recusa/avanco | Fechada em nivel minimo |
| Transacao ampla em todos os fluxos | Parcial |
| Shadow mode V1 x V2 | Aberto |
| Hardening total de edge cases | Aberto |

## 4. Conclusao

A `V12.0.0202` atende o conjunto central de regras de negocio exigido para uma linha oficial estabilizada. O que resta nao e um problema de fluxo funcional principal, e sim de maturidade adicional:

- mais evidencia automatizada da V2
- testes incrementais mais fortes
- comparadores entre suites
- formalizacao de governanca e compliance em nivel de publicacao aberta
