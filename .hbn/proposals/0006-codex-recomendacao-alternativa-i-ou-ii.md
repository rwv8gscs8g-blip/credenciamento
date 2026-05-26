---
titulo: Recomendação Codex — Alternativa I ou II (2ª rodada)
diataxis: explanation
hbn-track: fast_track
hbn-status: active
audiencia: ambos
versao-sistema: V12.0.0207
data: 2026-05-26
---

# Recomendação Codex — Alternativa I ou II (ou III)

## 1. Recomendação

Codex recomenda a **Alternativa II — Opção 4 híbrida**, com uma restrição obrigatória: as ondas V207.5-V207.7 de cache in-memory só podem começar depois de V207.0-V207.4 fecharem com RVS + E2E_CADASTROS verde e aceite humano explícito.

A razão principal é que o gargalo F-NEW4 é perceptual e está concentrado no reload/filtro de ListBoxes grandes, não apenas na escrita de `Repo_Empresa`. A Alternativa I é mais limpa no papel, mas entrega o ganho forte só em V208 e exige 12-17 ciclos. A Alternativa II entrega o ganho onde o usuário sente, em uma única release, preservando rollback para o estado V207.4 sem cache.

## 2. Justificativa detalhada

### Por que Alternativa II

- Ataca o gargalo certo: `EMP_Lista`, `C_Lista`, `C_ListaRodizio`, `A_Lista`, `H_Lista`, `CR_Lista` e, se a medição confirmar, `OS_Lista`/`AV_Lista`.
- Mantém a planilha como fonte de verdade: cache é derivado da planilha e pode ser desligado.
- Reduz fadiga de Mauricio: 7-9 ondas em vez de 12-17.
- Preserva o investimento da Alternativa I: V207.0-V207.4 são iguais ao Caminho 1 e viram base para V208 se necessário.
- Obriga teste E2E antes de otimização: F-NEW4-DT vira gate, não dívida adiada.

### Por que não Alternativa I como escolha primária

A Alternativa I é a melhor se o critério dominante for pureza arquitetural e risco mínimo por onda. O problema é que ela deixa a correção mais perceptível de F-NEW4 para V208. A V207 entregaria serviços, escrita em bloco e lazy reload, mas o usuário ainda poderia sentir travamento se as listas continuarem reconstruindo da planilha em cada cadastro.

Também há custo operacional alto: duas releases, dois freezes, duas rodadas de documentação e 12-17 ciclos de importação/validação. Em um projeto sem CI nativo e com importação VBE manual, essa fricção é risco técnico real.

### Por que não Alternativa III como escolha primária

A III-G, gate de bifurcação controlada, é aceitável se Mauricio quiser adiar a decisão até medir V207.4. Eu não a recomendo como caminho principal porque o diagnóstico já aponta o reload de ListBox como bottleneck central. Adiar a decisão tende a criar mais uma rodada de governança sem reduzir muito o risco.

Uma terceira arquitetura real, como dispatcher/eventos em VBA ou backend/API já na V207, não é recomendável agora. Eventos introduzem depuração difícil em UserForms; backend/API desloca o projeto para distribuição, suporte e segurança antes de estabilizar cadastros.

### Fatores decisivos

- F-NEW4 é experiência de uso, não só microperformance de repositório.
- O workbook precisa continuar soberano e exportável.
- `E2E_CADASTROS` deve nascer antes do cache, para impedir regressão silenciosa.
- O custo humano de importação VBE pesa tanto quanto o custo de código.
- Cache parcial read-only com fallback é menos arriscado que ORM completo na mesma release.

### Premissas assumidas

- V207.0-V207.4 conseguem remover mutações principais dos forms sem abrir refatoração total.
- As listas grandes do `Menu_Principal` são, de fato, o principal gargalo remanescente em PC antigo.
- O tamanho das bases municipais cabe em cache por domínio usando arrays/dicionários late-bound.
- Mauricio aceita que V207.5-V207.7 sejam bloqueadas se V207.4 não estiver completamente verde.
- A meta de SaaS é preparação progressiva, não migração obrigatória em V207.

Se a premissa sobre memória em PCs antigos estiver errada, a recomendação muda para Alternativa I. Se a premissa sobre gargalo de ListBox estiver errada, a recomendação muda para III-G: medir primeiro e só então escolher.

## 3. Plano de execução da alternativa escolhida

Sequência proposta para Alternativa II:

| Onda | Readback/slug proposto | Responsável principal | Papel de apoio | Gate humano |
|---|---|---|---|---|
| V207.0 | `0120-rb-v207-0-foundation-idperf` | Opus define readback; Codex executa | Antigravity audita se houver divergência | Mauricio importa, roda IDs/wrapper smoke |
| V207.1 | `0121-rb-v207-1-e2e-cadastros` | Opus define bateria; Codex implementa | Mauricio valida roteiro humano | E2E_CADASTROS existe e falha/passa de forma auditável |
| V207.2 | `0122-rb-v207-2-svc-empresa` | Codex executor | Opus revisa contrato | Cadastro empresa real + lista + RVS subset |
| V207.3 | `0123-rb-v207-3-svc-entidade-fnew3` | Codex executor | Opus revisa F-NEW3 | Entidade com ID textual `005`, listas coerentes |
| V207.4 | `0124-rb-v207-4-servico-cred-preencher` | Codex executor | Opus arquiteta cortes | RVS Trio + E2E_CADASTROS completo + medição F-NEW4 |
| Gate fase-lock | `0125-rb-v207-gate-cache` | Opus consolida | Codex/Antigravity opinam | Mauricio decide abrir cache ou congelar V207.4 |
| V207.5 | `0126-rb-v207-5-cache-readonly-listas` | Codex executor | Opus valida fronteira read-only | Equivalência de listas + fallback por flag |
| V207.6 | `0127-rb-v207-6-cache-invalidation-dirty` | Codex executor | Opus valida contratos | Invalidação por domínio e dirty checking leve verdes |
| V207.7 | `0128-rb-v207-7-tx-minima-cache` | Opus arquiteta; Codex executa | Antigravity audita risco sistêmico | `TX_PENDING`/rollback/recovery aprovados |
| V207.8 | `0129-rb-v207-8-freeze-hibrido` | Opus fecha release | Codex prepara evidências | RVS + E2E + PC antigo + docs |

Estimativa total: 45-70 homem-hora-IA, 9-13 sessões Opus+Codex, 7-9 gates humanos. Sem prazo calendário rígido; a duração real depende da importação no workbook e do tempo de RVS.

Divisão de papéis recomendada:

- Opus: arquitetura de contratos, readbacks safe_track, decisão de fase-lock, validação de risco antes de `Mod_Types`/`Importador_V3`.
- Codex: execução futura das ondas de código, auditoria local, testes e docs técnicos.
- Antigravity: auditoria sistêmica em V207.4 e V207.7, especialmente cache/invalidação.
- Mauricio: hearback, importação VBE, validação humana de workbook e decisão de abrir cache.

## 4. Sinalização de risco

### Se Mauricio escolher Alternativa I

Menor risco aceitável: manter V207 em no máximo 6 ondas, exigir medição de F-NEW4 em V207.5 e não abrir V208 se a experiência ainda estiver ruim sem uma decisão explícita. A V208 deve começar por leitura em memória e dirty checking antes de qualquer transação de escrita.

### Se Mauricio escolher Alternativa II

Menor risco aceitável: aplicar fase-lock real. V207.5 deve ser cache read-only com flag de fallback; V207.6 só invalidação/rebuild; V207.7 só escreve a partir de estado em memória se `TX_PENDING` persistente e snapshot estiverem testados. Se qualquer gate falhar, congelar V207.4 e voltar ao plano da Alternativa I.

### Se Mauricio escolher Alternativa III

Menor risco aceitável: tratar III como gate de bifurcação, não como nova arquitetura. Executar V207.0-V207.4, medir, e só então decidir. Não recomendo dispatcher/eventos nem backend/API na V207; se forem escolhidos, devem entrar como protótipo isolado, sem substituir a rota oficial do workbook.

Recomendação final: **Alternativa II**, com cache parcial, read-only primeiro, fallback explícito e decisão humana obrigatória entre V207.4 e V207.5.
