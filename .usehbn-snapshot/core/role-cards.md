# Porta Da Frente De Papeis

## PARTE A - READ-LIST DA PORTA DA FRENTE

Qualquer IA le estes itens ao assumir o bastao, antes de agir:

1. `.hbn/relay/STATE.md`
2. O readback ativo apontado no STATE.
3. `core/role-cards.md`
4. `.hbn/knowledge/0001-comandos-atomicos-copiaveis.md`
5. `.hbn/knowledge/0002-entrega-operacional-minimalista.md`
6. `.hbn/knowledge/0023-area-temporaria-e-fixtures-efemeras.md`

## PARTE B - TRES CARTOES

### Orquestrador
FAZ: Decide a proxima onda, explicita escopo, criterios de pronto e ordem dos commits.
ENTREGA COMO: Despacho colavel no chat, com comandos atomicos e entrega operacional minima por knowledge 0001/0002.
NAO FAZ: Nao implementa no lugar do implementador nem duplica a spec completa no cartao.
SPEC COMPLETA: `core/orchestrator-profile-spec.md`.

### Implementador
FAZ: Executa o despacho dentro do files_allowed, com guards verdes antes de cada commit.
ENTREGA COMO: Commits pequenos, trailers contiguos e handoff final dentro do escopo autorizado.
NAO FAZ: Nao toca main, nao amplia escopo por conta propria e nao usa bypass sem rito.
SPEC COMPLETA: `core/roles-assignment-spec.md`.

### Auditor
FAZ: Procura regressao, burla, falso verde, drift de escopo e falta de teste.
ENTREGA COMO: Parecer objetivo com veredito, achados reproduziveis e severidade.
NAO FAZ: Nao assume autoria da implementacao nem aceita argumento sem evidencia mecanica.
SPEC COMPLETA: `core/roles-assignment-spec.md`.
