---
titulo: Modelo de acesso controlado — por que existe e como funciona
diataxis: explanation
audiencia: humano institucional (gestor publico, integrador, auditor externo, contribuidor potencial)
hbn-track: fast_track
versao-sistema: V12.0.0203
data: 2026-04-29
---

# Modelo de acesso controlado — por que existe e como funciona

## A pergunta

Por que um repositorio publico e auditavel mantem **parte do
ferramental** sob acesso controlado, em vez de tudo aberto?

A resposta envolve **tres realidades distintas** que parecem contraditorias mas sao complementares:

1. **Auditabilidade publica e inegociavel** — qualquer pessoa precisa
   poder verificar codigo, regras, evidencias, licenca.
2. **Manutenibilidade requer protecao operacional** — ferramentas que
   reconstroem o pacote de import nao podem ser alteradas por
   desconhecidos sem que isso comprometa a Regra de Ouro do projeto.
3. **TPGL v1.1 e source-available, nao OSI-aprovada** — admite e
   ate prescreve restricao operacional, com auto-conversao para Apache
   2.0 em 4 anos.

## A solucao: duas categorias

### Categoria publica

Tudo que serve a **auditabilidade**:

- codigo VBA do produto (em `src/vba/`)
- regras canonicas do projeto
- evidencias de teste
- documentacao tecnica
- governanca de release
- vitrine institucional

Qualquer pessoa pode clonar o repositorio e ler tudo isso.
Qualquer IA RAG pode indexar e responder perguntas sobre.

### Categoria CLA-controlada

Tudo que serve a **manutencao operacional**:

- pacote `vba_import/` (que reconstroi o `.xlsm`)
- ferramentas que sincronizam `src/vba/` para `vba_import/`
- exports do workbook em homologacao
- backups historicos

Para acessar isso, voce precisa **assinar o CLA**. Ao assinar, voce
assume responsabilidade juridica formal pela sua contribuicao,
recebe acesso ao ferramental, e pode propor mudancas que vao para
revisao do mantenedor.

## Por que essa divisao protege o projeto

### Cenario sem divisao (tudo publico)

Sem o controle, qualquer pessoa poderia:

- baixar o ferramental
- modificar o pacote `vba_import/` localmente
- gerar uma versao "alternativa" do `.xlsm` com pacote modificado
- distribuir essa versao como se fosse o sistema oficial

Resultado: a **Regra de Ouro do pacote** ficaria comprometida —
a fonte da verdade do que esta no Excel passa a ser ambigua.

### Cenario com divisao (modelo atual)

Com o controle:

- auditoria continua publica
- so quem assinou CLA pode modificar/redistribuir o pacote
- cada CLA assinado e rastreavel
- o mantenedor sabe quem tem acesso e a que versao

Resultado: **integridade operacional preservada**, sem prejuizo a
auditabilidade.

## Por que CLA e nao apenas "pedido formal"

CLA (Contributor License Agreement) cria responsabilidade juridica
formal:

- contribuidor declara autoria/autorizacao
- contribuidor garante que nao viola direitos de terceiros
- contribuidor concede direitos patrimoniais necessarios para o projeto
  incorporar a contribuicao
- contribuidor aceita a politica de auto-conversao TPGL → Apache 2.0

Sem essa formalidade, o projeto nao poderia incorporar contribuicoes
de forma juridicamente segura. O CLA do Credenciamento esta no
[`CLA.md`](../../CLA.md) e segue Lei brasileira 9.610/98.

## Modelo de distribuicao escolhido (B — release zip)

Tres modelos foram avaliados na Onda 9 antecipada:

| Modelo | Quando faz sentido |
|---|---|
| A — Repositorio privado espelho | grandes equipes com 5+ contribuidores ativos |
| **B — Release zip** | **escolhido** — simplicidade + controle granular por liberacao |
| C — Git submodule privado | equipes com 3+ contribuidores com chaves SSH gerenciadas |

A escolha foi pela **simplicidade do modelo B**: a cada release oficial
da V203, V204, etc., o mantenedor empacota o `local-ai/` em zip
cifrado, hospeda em canal privado, e libera link unico apos validar
CLA.

Detalhes operacionais em
[`docs/how-to/COMO_OBTER_FERRAMENTAS_VBA.md`](../how-to/COMO_OBTER_FERRAMENTAS_VBA.md).

## Como isso convive com TPGL v1.1

A licenca TPGL v1.1 do projeto:

1. e **source-available** (nao OSI-aprovada)
2. permite restricao operacional sobre ferramental
3. **auto-converte para Apache 2.0 em 4 anos** — apos a Data de
   Conversao de cada release, todas as restricoes operacionais
   expiram
4. nao restringe **uso** do `.xlsm` final — qualquer prefeitura ou
   municipio pode usar

A categoria CLA-controlada **so existe ate a auto-conversao**.
Apos a Data de Conversao, todo o `local-ai/` se torna publico junto
com o resto sob Apache 2.0.

## Auditoria do proprio modelo de acesso

A propria divisao publico-vs-CLA e auditavel:

- a politica esta documentada **publicamente** (este documento + 4
  outros)
- a matriz definitiva esta em
  [`docs/reference/MATRIZ_PUBLICO_VS_CLA.md`](../reference/MATRIZ_PUBLICO_VS_CLA.md)
- o CLA esta publicamente acessivel
- o `.gitignore` declara explicitamente o que e local-only
- nenhuma dependencia de runtime do **produto** referencia
  `local-ai/` (so codigo de manutencao toca la)

Qualquer auditor externo pode confirmar essas garantias clonando o
repo publico e rodando os checks documentados.

## Quando o modelo expira

3 momentos podem encerrar a divisao:

1. **Auto-conversao TPGL → Apache 2.0** (em 4 anos por release) — todo
   `local-ai/` torna-se publico
2. **Decisao explicita do mantenedor** — Mauricio (ou seu sucessor)
   pode antecipar conversao por release oficial documentada
3. **Migracao para SaaS** — fora do escopo atual; se ocorrer, modelo
   sera reavaliado

Ate la, vale o modelo descrito aqui.

## Vitrine: outros projetos podem adotar

O modelo "publico-auditavel + ferramentas CLA-controladas" vira
referencia para projetos open-source-mas-com-controle. O
[`usehbn`](https://usehbn.org) recebeu um documento de integracao
formal — ver
[`usehbn/docs/INTEGRATION-CLA-CONTROLLED-ACCESS.md`](../../../usehbn/docs/INTEGRATION-CLA-CONTROLLED-ACCESS.md).

## Referencias

- [Especificacao operacional do contribuidor](../how-to/COMO_OBTER_FERRAMENTAS_VBA.md)
- [Matriz publico vs CLA](../reference/MATRIZ_PUBLICO_VS_CLA.md)
- [Protocolo HBN-native do modelo](../../.hbn/knowledge/0007-acesso-controlado-via-cla.md)
- [CLA.md (clausula 7 atualizada)](../../CLA.md)
- [CONTRIBUTING.md (fluxo recomendado)](../../CONTRIBUTING.md)
- [LICENSE — TPGL v1.1](../../LICENSE)
