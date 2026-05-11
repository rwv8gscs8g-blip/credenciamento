---
titulo: Roteiro de Teste Manual V204
diataxis: reference
hbn-track: safe_track
hbn-status: active
audiencia: humano
versao-sistema: V12.0.0204
data: 2026-05-11
---

# Roteiro de Teste Manual V204

Este roteiro orienta a homologacao humana da V12.0.0204 depois do Sexteto
verde. Ele deve ser usado junto com a planilha `.xlsm` validada e com a matriz
de rastreabilidade da V204.

## Cabecalho do ciclo

| Campo | Preencher |
|---|---|
| Testador |  |
| Maquina / Windows / Excel |  |
| Data e hora |  |
| Arquivo testado |  |
| Build retornado por `?GetBuildImportado` |  |
| `VALIDACAO_ID` do Sexteto |  |
| Resultado do Sexteto |  |

## Checklist inicial

1. Liberar macros conforme
   [Como Liberar Macros no Windows](../../how-to/COMO_LIBERAR_MACROS_NO_WINDOWS.md).
2. Abrir a planilha no Excel Desktop.
3. Compilar em **VBE > Depurar > Compilar VBAProject**.
4. Confirmar `?GetBuildImportado`:

```text
f7aa84f+ONDA25.MD25.5-limpar-cad-serv-fix2
```

5. Rodar `CT_ValidarRelease_SextetoMinimo`.
6. Confirmar resultado esperado:

```text
V1=171/0+V2_Smoke=34/0+V2_Canonica=24/0+E2E_Strikes=76/0+IntegridadeBase=4/0+Onda23Adv=27/0
```

## Fluxos manuais obrigatorios

| ID | Fluxo | Acao | Resultado esperado |
|---|---|---|---|
| M-01 | Sobre | Abrir botao **Sobre** | Mostra V12.0.0204, status VALIDADO e build final homologado |
| M-02 | Entidade | Cadastrar entidade municipal de teste | Entidade aparece nas listas sem duplicidade |
| M-03 | Empresa | Cadastrar empresa de teste | Empresa aparece em `EMPRESAS` como apta ao credenciamento |
| M-04 | Servico | Abrir **Cadastra e Altera Servico** | Tela abre sem erro "O objeto e obrigatorio" |
| M-05 | Servico | Cadastrar um servico novo para uma atividade CNAE existente | Servico aparece na lista e pode ser usado em credenciamento |
| M-06 | Credenciamento | Vincular empresa ao servico/atividade | Credenciamento fica pesquisavel e elegivel |
| M-07 | Rodizio | Indicar empresa para servico | Sistema escolhe empresa apta e registra Pre-OS |
| M-08 | Pre-OS | Emitir solicitacao e simular aceite | Pre-OS converte de forma auditavel em OS |
| M-09 | Avaliacao | Registrar avaliacao negativa com justificativa | Strike e auditoria sao registrados |
| M-10 | Suspensao | Acumular condicao de suspensao | Empresa suspensa nao e escolhida no rodizio |
| M-11 | Reativacao | Reativar empresa suspensa | Status volta a ativo e historico total permanece auditavel |
| M-12 | Limpar Base | Rodar **Configuracoes Iniciais > Limpar Base** | Base operacional e limpa, `ATIVIDADES`/CNAE e `CONFIG` preservadas, `CAD_SERV` zerado |
| M-13 | Idempotencia | Repetir **Limpar Base** e abrir Cadastro de Servico | Nao ocorre erro VBA; tela abre vazia e pronta para novo municipio |
| M-14 | Reuso municipal | Cadastrar servico novo apos limpeza | Planilha aceita novo catalogo de servicos sem lixo acumulado |

## Contrato final de Limpar Base

O comportamento esperado da V12.0.0204 e:

| Aba / dado | Resultado esperado |
|---|---|
| `ATIVIDADES` | Preservada; base CNAE continua disponivel |
| `CONFIG` | Preservada; parametros permanecem configuraveis |
| `CAD_SERV` | Limpa com cabecalho canonico preservado |
| `EMPRESAS`, `ENTIDADE`, `CREDENCIADOS`, `PRE_OS`, `CAD_OS`, `AUDIT_LOG` | Dados operacionais removidos conforme relatorio |
| `RPT_LIMPEZA_TOTAL` | Relatorio registra o que foi limpo e preservado |

Falha nesse contrato bloqueia a liberacao publica, porque impede reutilizar a
planilha em outro municipio com uma base limpa de servicos.

## Registro de anomalia

Para cada anomalia, registre:

1. fluxo e passo;
2. dado usado;
3. resultado esperado;
4. resultado obtido;
5. print da tela;
6. mensagem VBA, se houver;
7. build retornado por `?GetBuildImportado`;
8. se o problema se repete apos fechar e reabrir a planilha.

## Criterios de severidade

| Severidade | Criterio |
|---|---|
| P0 | perda/corrupcao de dados, falha de compilacao, fechamento inesperado do Excel |
| P1 | regra de negocio errada, rodizio incorreto, Limpar Base descumpre contrato, erro VBA em fluxo principal |
| P2 | mensagem confusa, evidencia ausente, comportamento correto mas pouco claro |
| P3 | texto, alinhamento visual, ergonomia menor |

## Encerramento

O teste manual termina com:

1. decisao humana: aprovado, aprovado com ressalva ou reprovado;
2. lista de P0/P1/P2/P3;
3. prints principais;
4. CSV do Sexteto;
5. recomendacao para publicacao ou para correcao.
