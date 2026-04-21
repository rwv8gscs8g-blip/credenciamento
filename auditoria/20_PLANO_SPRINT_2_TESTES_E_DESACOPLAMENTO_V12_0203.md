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

## Frente B — Ampliação dos cenários já existentes

### B1. Enriquecer `SMK_007`

Hoje o cenário fecha o ciclo principal.

Ampliação desejada:

- validar também contagem de registros em avaliação
- validar rastro mínimo de auditoria
- validar que a empresa não fica suspensa quando a média é suficiente

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

1. A1
2. A2
3. A4
4. B1
5. B3
6. C1
7. A3
8. C2
9. B2
10. C3

## Critério de saída da Sprint 2

A Sprint 2 deve ser considerada concluída quando:

1. pelo menos 4 novos cenários automatizados tiverem sido incorporados
2. pelo menos 3 cenários existentes tiverem sido fortalecidos
3. uma fatia concreta de lógica tiver saído do `Menu_Principal.frm`
4. a Bateria Oficial e a V2 continuarem verdes após a ampliação

## Resultado esperado

Ao final dessa sprint, a linha sucessora da `V12.0.0202` deve:

- resistir melhor a regressões silenciosas
- depender menos de comportamento visual do formulário
- ter cobertura mais rica sobre transições inválidas, auditoria e integridade operacional
- reforçar a reputação pública do repositório como referência de testes confiáveis em VBA
