---
titulo: Onda 38.2.33 — Disponibilidade operacional em relatorios
diataxis: onda
hbn-track: safe_track
hbn-status: active
audiencia: ambos
versao-sistema: V12.0.0206
data: 2026-06-08
---

# 0164 — Disponibilidade operacional em relatorios

## Contexto

A revisao tela a tela de relatorios mostrou que os PDFs ja exibiam status,
suspensao e strikes, mas ainda confundiam dois conceitos:

- **status cadastral/global**: empresa ativa, suspensa ou inativa;
- **disponibilidade operacional na atividade**: empresa pode ou nao receber
  nova Pre-OS agora.

O caso manual validado pelo operador foi correto: a empresa estava ativa, mas
tinha Pre-OS aberta na atividade. O motor do rodizio deve bloquear nova
indicacao enquanto a Pre-OS estiver pendente. A falha estava na mensagem e nos
relatorios, que ainda podiam exibir `SIM - APTA` por olharem apenas status
global/credenciamento.

## Classificacao HBN

| Item | Classificacao |
|---|---|
| Tipo | regra de negocio exposta em relatorio/mensagem |
| Designer | nao alterado |
| `.frx` | nao requerido |
| Motor do rodizio | preservado |
| Teste | V2 dirigido por tokens |

## Acoes implementadas

- `Rel_Rodizio_Status.bas` ganhou `RRS_DisponibilidadeOperacionalEmpresa`,
  que avalia credenciamento, suspensao, inatividade, OS em execucao e Pre-OS
  pendente na atividade.
- `Rel_Rodizio_Status.bas` ganhou `RRS_StatusEmpresaNaData`, usado como frase
  padrao em impressos.
- `RRS_DiagnosticoOperacionalEmpresa` deixou de repetir "rodizio" e passou a
  resumir status, disponibilidade, suspensao e strikes.
- `Menu_Principal.frm` passou a mostrar mensagem de Pre-OS com diagnostico
  detalhado: credenciamentos inativos, suspensas, inativas, OS em execucao,
  Pre-OS pendentes e vinculos sem empresa.
- Relatorios do menu principal trocaram `PARTICIPA RODIZIO` por
  `DISPONIBILIDADE ATUAL` e `DIAGNOSTICO SISTEMA` por `RESUMO OPERACIONAL`.
- `Rel_Emp_Serv.frm` passou a usar a atividade do relatorio para mostrar
  `PRE-OS PENDENTE`, `OS EM EXECUCAO`, `SUSPENSA ATE ...` ou `DISPONIVEL`.
- `Rel_OSEmpresa.frm` passou a exibir disponibilidade atual no resumo superior.
- `Preencher.bas` passou a imprimir `Status da empresa nesta data: ...` e a
  anexar essa frase ao campo de observacoes da avaliacao.
- `Teste_V2_Roteiros.bas` corrigiu falso negativo do VCR: o texto
  `Gate de Validacao de Release (RVS)` pertence a `Central_Testes_V2.bas`, nao
  a `Teste_Validacao_Release.bas`.
- `TV2_RunRelatoriosSuspensoesStrikesReset` e `TV2_RunTelaRelatorios` foram
  atualizados para validar os novos rotulos e helpers.

## Consequencias operacionais

- Empresa ativa, mas com Pre-OS pendente na atividade, aparece como
  `PRE-OS PENDENTE`.
- Empresa ativa, mas com OS em execucao na atividade, aparece como
  `OS EM EXECUCAO`.
- Empresa suspensa continua aparecendo como suspensa ate a data prevista.
- Empresa com prazo de suspensao vencido aparece como `REATIVAVEL - PRAZO
  VENCIDO`; o motor do rodizio reativa automaticamente ao selecionar.
- Os documentos impressos carregam a frase padrao `Status da empresa nesta
  data`, com status, disponibilidade, suspensao e strikes.

## Suspensao e retorno

Hoje uma empresa deixa de ficar suspensa por dois caminhos:

1. **Retorno automatico no rodizio**: quando `DT_FIM_SUSP <= Date`, a rotina
   `SelecionarEmpresa` chama a reativacao antes de selecionar nova empresa.
2. **Fluxo manual existente de reativacao**: quando usado pelo operador, grava
   a empresa como ativa e atualiza a ultima reativacao.

Nao foi criada nesta onda uma nova interface de "anistia anual". Essa decisao
exige desenho proprio porque zerar strikes e reativar empresa suspensa nao sao
a mesma coisa.

## Proposta futura: checkboxes no Novo Periodo

Para uma onda futura, a logica recomendada e separar tres decisoes:

| Checkbox futuro | Efeito recomendado |
|---|---|
| Zerar strikes por recusa/prazo | zera os contadores de recusa/prazo usados na punicao por Pre-OS |
| Zerar strikes por nota baixa | cria marco auditavel para ignorar avaliacoes antigas na contagem futura |
| Reativar empresas suspensas no novo periodo | opcional separado; nao deve ser efeito implicito dos dois resets acima |

Separar essas opcoes evita anistia involuntaria. Uma prefeitura pode querer
zerar contadores para o novo exercicio, mas manter empresas suspensas ate a
data de retorno ja comunicada.

## Teste esperado

```vb
TV2_RunRelatoriosSuspensoesStrikesReset
```

Esperado: `OK=10 | FALHA=0 | MANUAL=0`.

Regressao recomendada:

```vb
TV2_RunTelaRelatorios
```

Esperado: `OK=10 | FALHA=0 | MANUAL=0`.
