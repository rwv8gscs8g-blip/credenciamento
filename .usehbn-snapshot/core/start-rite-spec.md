---
titulo: Start-rite spec — `usehbn start` como rito declarativo de elenco
diataxis: reference
status: accepted
temperatura: quente
id-global: 20260610-202410-fable-5-spec-start-rite
path: core/start-rite-spec.md
versao: 0.1.1   # FIX cross-audit 0030/0031: rito ≠ comando CLI (§1); token exato (§5.1); data serial (§5.2)
data: 2026-06-10
autoria: claude-fable-5 (consolidação ADR-024)
hearback-status: confirmed
relacionado: [ADR-024 (Decisões 1 e 5), ADR-015, ADR-018, ADR-020, core/roles-assignment-spec.md, guards/assert-role-family.sh]
---

# Start-rite spec

## §1 Natureza: declara, não executa

**`usehbn start` é o NOME do rito — não é um comando de `src/usehbn/cli.py`
e nenhuma implementação CLI existe ou está prevista nesta onda** (Truth
Barrier; cross-audit 0031 F-04). Quem conduz o rito é o orquestrador
conversacional (o modelo, no chat), lendo perfis do disco e imprimindo.

O rito é a cerimônia de entrada de um ciclo de ondas — fast_track
de LEITURA + impressão de 1 bloco proposed. Ele **não** dispara IAs, não
atribui ondas, não escreve no STATE, não comita, não ativa guard.
Orquestração por CLI permanece FUTURA por decisão expressa
(roles-assignment-spec §5). O start termina IMPRIMINDO; o humano comita.

## §2 O rito, em 5 passos

1. **Elenco**: lê `.hbn/models/*.json` e lista apelidos com `fornecedor` e
   `papeis_aptos` (ADR-015). Perfil ilegível/ausente = fora do elenco.
2. **Atribuição recebida**: orquestrador/conversacional, implementador(es),
   auditor(es). Só aceita apelido COM perfil e papel CONSTANTE em
   `papeis_aptos`; fora disso exige `hearback_ref`.
3. **Validação anti-groupthink**: aplica a MESMA lógica de
   `guards/assert-role-family.sh` (ADR-018 Decisão 2 + dereferência
   ADR-020) em modo informativo — o start NÃO edita nem substitui o guard
   (knowledge 0021: sandbox informa, Terminal conclui). Família(auditor) ≠
   família(implementador) é BLOQUEADOR; auditores homogêneos entre si é
   AVISO.
4. **Impressão**: bloco `atribuicao` pronto (YAML, roles-assignment-spec
   §2) + elenco + a linha `chapeu_atual: conversacional-orquestrador`
   quando aplicável. Se o ciclo declara escrita PARALELA, imprime também a
   lista dos escritores paralelos (insumo do G-NUM, §5).
5. **Adoção**: o humano revisa e comita o STATE com o bloco. A atribuição
   só VIGE commitada (ADR-023; rito do relay-spec: quem fecha atualiza o
   STATE no mesmo commit).

**Bypass de liveness** (fornecedor fora do ar): a violação de família só
passa com `hearback_ref` dereferenciável — arquivo existente, `status:
confirmed`, exceção exata em `excecoes_cobertas` (ADR-020). String não é
bypass.

**IA nova (ex.: Jules)**: apelido sem perfil → o start RECUSA e imprime o
esqueleto de `.hbn/models/<apelido>.json` com campos `null` +
`nao_verificado` preenchido. Entrar no elenco é mudança T2 (ADR-015):
evidência citável + hearback. Memória de modelo não é evidência. Perfil
`fornecedor: Google` (etc.) já nasce habilitado, pelo invariante, como
auditor de implementadores de outras famílias.

## §3 Saída-modelo (forma, não elenco recomendado)

```yaml
atribuicao:
  chapeu_atual: conversacional-orquestrador
  orquestrador: <apelido>
  implementador: <apelido>
  auditores: [<apelido>, <apelido>]
  escrita_paralela: [<apelido>, <apelido>]   # vazio ⇒ ciclo serial (G-NUM)
  gravada_em: "<ISO8601 com offset>"
  hearback_ref: null
```

## §4 Guard G-STR (`assert-start-cast`) — spec, FORA do runner

Invocação sob demanda: `bash guards/assert-start-cast.sh <atribuicao.json>`.

1. DELEGA a validação família/aptidão/hearback ao
   `assert-role-family.sh` (chamada direta — uma lógica, um lugar; nunca
   cópia da regra).
2. BLOQUEADOR adicional: campo `orquestrador` presente sem
   `conversacional-orquestrador` (ou equivalente) em `papeis_aptos` do
   perfil, sem exceção coberta.
3. BLOQUEADOR adicional: `escrita_paralela` contém apelido fora do elenco
   da própria atribuição.

Casos de teste (estilo `guards/tests/run-guard-tests.sh`; fixtures reusam
`fixtures/models` e `fixtures/atribuicoes`):

```
check "str: elenco cruzado válido, ciclo serial"          pass   good-cast-serial.json
check "str: groupthink sem hearback (delegação G-FAM)"    block  bad-groupthink.json        # reusa fixture existente
check "str: orquestrador sem papel apto e sem exceção"    block  bad-orq-sem-aptidao.json
check "str: escrita_paralela com apelido fora do elenco"  block  bad-paralelo-forasteiro.json
check "str: bypass liveness com hearback confirmado"      pass   good-hearback-cobre.json   # reusa fixture existente
```

## §5 Guard G-NUM (`assert-parallel-id`) — spec, FORA do runner (ADR-024 Decisão 5)

Gatilho: diff staged (HEAD em CI; `--diff-filter=AR` — mesmo padrão
G-SLF/G-REG pós staged-skew) com artefato novo em pasta de série
não-local enquanto o STATE declarar `escrita_paralela` não-vazia.

1. BLOQUEADOR: artefato de escritor paralelo cujo nome não casa
   `^[0-9]{8}-[0-9]{6}-<agente>-[a-z0-9-]+\.` com `<agente>` ∈
   `escrita_paralela` (apelidos de perfis ADR-015). O `<agente>` é
   capturado por **TOKEN EXATO** — o apelido conhecido MAIS LONGO
   (atribuicao do STATE staged + perfis `.hbn/models/`) que casa após o
   carimbo, comparado por igualdade, nunca por prefixo: `alpha-1` NÃO
   passa como `alpha` + slug `1-…` (cross-audit 0030 F-01 / 0031 F-05).
2. BLOQUEADOR: linha nova do REGISTRY (staged — `git show :REGISTRY.md`)
   sem coluna `created_at` ISO8601 com offset, ou com HHMMSS do id
   divergente do `created_at` da mesma linha. Em id SERIAL
   (`AAAAMMDD-NN`), a data YYYYMMDD do id também deve coincidir com a
   data do `created_at` (cross-audit 0031 F-01).
3. BLOQUEADOR: dois artefatos novos com id idêntico no mesmo diff.
4. Fora de ciclo paralelo (campo vazio/ausente): guard não opina sobre o
   nome (serial mantém `AAAAMMDD-NN`, ADR-011) mas a regra 2 (created_at em
   linha nova do bloco de 6 colunas) permanece.

Casos de teste:

```
check "num: paralelo com HHMMSS-agente válido + created_at"  pass
check "num: paralelo com AAAAMMDD-NN antigo (colisão 0001×0001)" block
check "num: agente do nome fora de escrita_paralela"          block
check "num: linha REGISTRY nova sem created_at"               block
check "num: created_at diverge do HHMMSS do id"               block
check "num: serial AAAAMMDD-NN segue passando fora de ciclo paralelo" pass
check "num: REGISTRY staged sem linha; working tree com (skew)" block   # herda E-FECH-02
check "num: prefixo de apelido (alpha-1 vs alpha) NÃO passa como slug" block  # 0030 F-01 / 0031 F-05
check "num: id serial com data ≠ created_at" block                      # 0031 F-01
```

Compatibilidade G-REG (risco R5 do ADR-024): as linhas novas preservam as
5 primeiras colunas; caso de teste dedicado na metade 2 prova que o grep do
G-REG continua casando.
