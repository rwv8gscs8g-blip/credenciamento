# 20. Plano da Sprint 2 — Testes e Desacoplamento da Interface

## Objetivo

Executar a próxima microevolução técnica após a estabilização pública da `V12.0.0202`, com foco em:

- fortalecimento incremental da bateria de testes
- criação de novos cenários automatizados
- ampliação dos cenários já existentes
- redução progressiva de dependência da interface

## Princípio

A Sprint 2 não parte de uma crise de estabilidade. Ela parte de uma base validada e busca elevar maturidade.

Ou seja:

- o alvo não é “fazer voltar a funcionar”
- o alvo é “deixar mais difícil quebrar no futuro”

## Frente A — Novos cenários de teste

### A0. Família V2 canônica `CS_*`

Status atual:

- proposta aprovada e consolidada em [docs/PROPOSTA_TESTES_V2_CENARIO_CANONICO.md](../docs/PROPOSTA_TESTES_V2_CENARIO_CANONICO.md)
- implementação iniciada e primeiro lote já executável na branch `codex/v12-0-0203-governanca-testes`
- lote de suspensão inicial (`CS_11` e `CS_13`) já validado em workbook
- segundo lote (`CS_14`, `CS_16` e `CS_20`) já validado em workbook
- terceiro lote (`CS_17`) já validado como teste de vida do giro longo
- `CS_18` já validado para transições inválidas de OS concluída
- `CS_21` já validado para completude mínima das famílias críticas do `AUDIT_LOG`

Objetivo:

- abrir uma suíte V2 própria para cenários canônicos profundos
- manter `SMK_*` como bateria rápida de saúde
- evitar inflar o smoke com cenários longos e combinatórios
- implementar o primeiro lote obrigatório como base da `0203`

Primeiro lote recomendado:

- `CS_00` a `CS_08`
- `CS_22`

Segundo lote recomendado:

- `CS_11`
- `CS_13`
- `CS_14`
- `CS_16`
- `CS_20`

Terceiro lote recomendado:

- `CS_17`

Critério de aceite:

- suíte `CANONICO` executável pela Central V2
- catálogo e roteiro assistido exibem a família `CS_*`
- setup canônico, fluxo nominal, bloqueio total, retomada e integridade de associação ficam automatizados
- suspensão manual, reativação automática, suspensão por nota, retorno ordenado e filtro cadastral passam a ter cobertura canônica explícita
- o giro longo `A,B,C,A,B,C,A` prova vida útil da fila e ausência de travamento ao voltar ao início
- a suíte roda sem regressão no `SMOKE`

### A1. Expiração de Pre-OS e retomada correta da fila

Status atual:

- `EXP_001` incorporado à V2 na branch `codex/v12-0-0203-governanca-testes`

Criar cenário automatizado para provar:

- Pre-OS expirada não vira OS
- a empresa bloqueada por Pre-OS pendente volta a ser tratada corretamente após expiração
- a fila preserva integridade antes e depois do evento

Critério de aceite:

- novo cenário V2 com assert explícito
- evidência do status final da Pre-OS
- evidência da fila antes e depois

### A2. Transições inválidas de OS concluída

Status atual:

- `CS_18` incorporado e validado em workbook

Criar cenário automatizado para provar:

- OS concluída não pode ser reavaliada
- OS concluída não pode retornar a estado anterior
- tentativa inválida não gera mutação parcial

Critério de aceite:

- novo cenário V2 de transição inválida
- auditoria registra a tentativa sem corromper o estado

### A3. Cobertura de inativação/reativação de empresa e entidade

Criar cenários para proteger os fluxos que já sofreram regressão histórica:

- inativar e reativar empresa
- inativar e reativar entidade
- garantir restauração da linha correta
- impedir reaparição de registro semântico incorreto

Critério de aceite:

- cenários automatizados cobrindo ida e volta
- assert de integridade semântica do cadastro restaurado

### A4. Completude do `AUDIT_LOG`

Status atual:

- `CS_21` incorporado e validado em workbook
- `TESTE_TRILHA` e `AUDIT_TESTES` abertos como trilha cumulativa própria da suíte

Criar cenário para provar que eventos críticos realmente deixam rastro:

- emissão de Pre-OS
- recusa
- conversão em OS
- avaliação
- suspensão
- rollback transacional

Critério de aceite:

- suíte automatizada valida presença mínima de eventos esperados
- comparação por tipo de evento, não apenas por contagem bruta

### A5. Trilha cumulativa própria da suíte

Status atual:

- entregue com as abas `TESTE_TRILHA` e `AUDIT_TESTES`

Objetivo:

- preservar a narrativa cumulativa da execução V2
- congelar, por cenário, o `AUDIT_LOG` operacional antes do reset determinístico
- separar evidência da suíte de auditoria operacional do negócio

Critério de aceite:

- cada assert V2 gera linha sequencial em `TESTE_TRILHA`
- cada cenário capturado gera espelho congelado em `AUDIT_TESTES`
- `RPT_TESTES_V2` consegue explicar a diferença entre `AUDIT_LOG` operacional e trilha de execução

## Frente B — Ampliação dos cenários já existentes

### B1. Enriquecer `SMK_007`

Hoje o cenário fecha o ciclo principal.

Ampliação desejada:

- validar também contagem de registros em avaliação
- validar rastro mínimo de auditoria
- validar que a empresa não fica suspensa quando a média é suficiente

Status atual:

- reforço incorporado ao `SMK_007` na branch `codex/v12-0-0203-governanca-testes`
- agora o cenário também prova `OS Fechada/Avaliada` no `AUDIT_LOG`
- agora o cenário também prova ausência de suspensão indevida e `DT_FIM_SUSP` limpa

### B2. Enriquecer `ATM_001`

Hoje ele prova rollback mínimo.

Ampliação desejada:

- validar também ausência de mutação residual em mais de uma aba operacional
- validar evento de rollback com mensagem legível

### B3. Enriquecer `STR_001`

Hoje ele valida invariantes de fila repetidamente.

Ampliação desejada:

- validar também ausência de duplicidade de IDs
- validar contagem final de itens da fila
- validar que posições continuam estritamente crescentes mesmo após ciclos mistos

## Frente C — Redução progressiva de dependência da interface

### C1. Extrair montagem da avaliação para helper/serviço

O formulário principal ainda concentra montagem de dados da avaliação.

Objetivo:

- reduzir lógica de preparação no `Menu_Principal.frm`
- deixar a interface apenas coletar entrada
- delegar a montagem e normalização a uma função dedicada

### C2. Extrair orquestração de emissão de Pre-OS / OS

Objetivo:

- reduzir regras colaterais no formulário
- centralizar montagem de payload mínimo em helper ou serviço
- facilitar novos testes sem depender de evento visual

### C3. Tornar os relatórios menos dependentes da navegação visual

Objetivo:

- separar melhor geração de dados e renderização visual
- facilitar testes estruturais dos relatórios

## Ordem recomendada

1. A0
2. A1
3. A2
4. A4
5. B1
6. B3
7. C1
8. A3
9. C2
10. B2
11. C3

## Critério de saída da Sprint 2

A Sprint 2 deve ser considerada concluída quando:

1. pelo menos 4 novos cenários automatizados tiverem sido incorporados
2. pelo menos 3 cenários existentes tiverem sido fortalecidos
3. uma fatia concreta de lógica tiver saído do `Menu_Principal.frm`
4. a Bateria Oficial e a V2 continuarem verdes após a ampliação
5. a família `CS_*` já tiver pelo menos um lote executável e determinístico
6. a trilha cumulativa `TESTE_TRILHA` / `AUDIT_TESTES` estiver funcionando sem quebrar o reset determinístico

## Resultado esperado

Ao final dessa sprint, a linha sucessora da `V12.0.0202` deve:

- resistir melhor a regressões silenciosas
- depender menos de comportamento visual do formulário
- ter cobertura mais rica sobre transições inválidas, auditoria e integridade operacional
- reforçar a reputação pública do repositório como referência de testes confiáveis em VBA
