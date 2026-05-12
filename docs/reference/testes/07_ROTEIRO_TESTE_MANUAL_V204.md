---
titulo: Roteiro de Teste Manual V204
diataxis: reference
hbn-track: safe_track
hbn-status: active
audiencia: humano
versao-sistema: V12.0.0204
data: 2026-05-12
---

# Roteiro de Teste Manual V204

Este roteiro orienta a homologação humana da V12.0.0204 depois do Sexteto
verde. Ele deve ser usado junto com a planilha `.xlsm` validada, o
[Guia de Testes Humanos V204](../../tutorials/GUIA_TESTES_HUMANOS_V204.md)
e a matriz de rastreabilidade da V204.

O roteiro é escrito para uma pessoa que vai operar a planilha pela interface do
Excel, sem abrir Editor VBA, Janela Imediata ou código-fonte.

## Cabeçalho do ciclo

| Campo | Preencher |
|---|---|
| Testador |  |
| Máquina / Windows / Excel |  |
| Data e hora |  |
| Arquivo testado |  |
| Build exibido no botão **Sobre** |  |
| `VALIDACAO_ID` do Sexteto |  |
| Resultado do Sexteto |  |

## Checklist inicial

1. Liberar macros conforme
   [Como Liberar Macros no Windows](../../how-to/COMO_LIBERAR_MACROS_NO_WINDOWS.md).
2. Abrir a planilha no Excel Desktop.
3. Clicar em **Sobre** e confirmar:

```text
Release oficial: V12.0.0204
Status oficial: VALIDADO
f7aa84f+ONDA25.MD25.5-limpar-cad-serv-fix2
```

4. Clicar em **Central de Testes**.
5. Confirmar **Modo Treinamento** com **Sim**, se a mensagem aparecer.
6. Na tela intermediária, escolher **[2] Central de Testes V2**, se essa tela
   aparecer.
7. Na Central V2, escolher **[1] Sexteto Mínimo**.
8. Confirmar resultado esperado:

```text
V1=171/0+V2_Smoke=34/0+V2_Canonica=24/0+E2E_Strikes=76/0+IntegridadeBase=4/0+Onda23Adv=27/0
```

## Dados fictícios sugeridos

Use dados fictícios e identificáveis como teste. Não use dados reais de
municípios, empresas ou pessoas.

| Tipo | Valor sugerido |
|---|---|
| Entidade | Secretaria Municipal de Teste V204 |
| Empresa A | Empresa Teste Alfa Ltda. |
| Empresa B | Empresa Teste Beta Ltda. |
| Empresa C | Empresa Teste Gama Ltda. |
| CNPJ fictício | `11.111.111/0001-11`, `22.222.222/0001-22`, `33.333.333/0001-33` |
| CNAE de exemplo | escolher uma atividade existente na lista CNAE da planilha |
| Serviço de exemplo | Serviço de manutenção predial V204 |
| Valor de exemplo | `100,00` |

## Fluxo narrativo recomendado

Execute os blocos na ordem abaixo. A tabela seguinte resume os critérios de
aceite; a narrativa ajuda o testador a entender por que cada passo existe.

1. **Identidade da release:** confirme que o arquivo recebido é realmente a
   V12.0.0204 validada.
2. **Cadastros básicos:** cadastre entidade, empresa e serviço para provar que
   a planilha aceita uma base municipal nova.
3. **Credenciamento e rodízio:** vincule empresa ao serviço e peça uma
   indicação. O sistema deve escolher uma empresa apta e registrar Pré-OS.
4. **Ciclo operacional:** aceite a Pré-OS, gere OS, conclua e avalie.
5. **Penalidade e recuperação:** registre avaliação negativa, observe strike,
   suspensão e reativação.
6. **Reuso municipal:** execute Limpar Base e confirme que a base fica pronta
   para outro município, preservando CNAE e limpando `CAD_SERV`.

## Fluxos manuais obrigatórios

| ID | Fluxo | Ação | Resultado esperado |
|---|---|---|---|
| M-01 | Sobre | Abrir botão **Sobre** | Mostra V12.0.0204, status VALIDADO e build final homologado |
| M-02 | Entidade | Cadastrar entidade municipal de teste | Entidade aparece nas listas sem duplicidade |
| M-03 | Empresa | Cadastrar empresa de teste | Empresa aparece em `EMPRESAS` como apta ao credenciamento |
| M-04 | Serviço | Abrir **Cadastra e Altera Serviço** | Tela abre sem erro "O objeto é obrigatório" |
| M-05 | Serviço | Cadastrar um serviço novo para uma atividade CNAE existente | Serviço aparece na lista e pode ser usado em credenciamento |
| M-06 | Credenciamento | Vincular empresa ao serviço/atividade | Credenciamento fica pesquisável e elegível |
| M-07 | Rodízio | Indicar empresa para serviço | Sistema escolhe empresa apta e registra Pré-OS |
| M-08 | Pré-OS | Emitir solicitação e simular aceite | Pré-OS converte de forma auditável em OS |
| M-09 | Avaliação | Registrar avaliação negativa com justificativa | Strike e auditoria são registrados |
| M-10 | Suspensão | Acumular condição de suspensão | Empresa suspensa não é escolhida no rodízio |
| M-11 | Reativação | Reativar empresa suspensa | Status volta a ativo e histórico total permanece auditável |
| M-12 | Limpar Base | Rodar **Configurações Iniciais > Limpar Base** | Base operacional é limpa, `ATIVIDADES`/CNAE e `CONFIG` preservadas, `CAD_SERV` zerado |
| M-13 | Idempotência | Repetir **Limpar Base** e abrir Cadastro de Serviço | Não ocorre erro VBA; tela abre vazia e pronta para novo município |
| M-14 | Reuso municipal | Cadastrar serviço novo após limpeza | Planilha aceita novo catálogo de serviços sem lixo acumulado |

## Contrato final de Limpar Base

O comportamento esperado da V12.0.0204 é:

| Aba / dado | Resultado esperado |
|---|---|
| `ATIVIDADES` | Preservada; base CNAE continua disponível |
| `CONFIG` | Preservada; parâmetros permanecem configuráveis |
| `CAD_SERV` | Limpa com cabeçalho canônico preservado |
| `EMPRESAS`, `ENTIDADE`, `CREDENCIADOS`, `PRE_OS`, `CAD_OS`, `AUDIT_LOG` | Dados operacionais removidos conforme relatório |
| `RPT_LIMPEZA_TOTAL` | Relatório registra o que foi limpo e preservado |

Falha nesse contrato bloqueia a liberação pública, porque impede reutilizar a
planilha em outro município com uma base limpa de serviços.

## Registro de anomalia

Para cada anomalia, registre:

1. fluxo e passo;
2. dado usado;
3. resultado esperado;
4. resultado obtido;
5. print da tela;
6. mensagem VBA, se houver;
7. build exibido no botão **Sobre**;
8. se o problema se repete após fechar e reabrir a planilha.

## Critérios de severidade

| Severidade | Critério |
|---|---|
| P0 | perda/corrupção de dados, falha de compilação, fechamento inesperado do Excel |
| P1 | regra de negócio errada, rodízio incorreto, Limpar Base descumpre contrato, erro VBA em fluxo principal |
| P2 | mensagem confusa, evidência ausente, comportamento correto mas pouco claro |
| P3 | texto, alinhamento visual, ergonomia menor |

## Encerramento

O teste manual termina com:

1. decisão humana: aprovado, aprovado com ressalva ou reprovado;
2. lista de P0/P1/P2/P3;
3. prints principais;
4. CSV do Sexteto;
5. recomendação para publicação ou para correção.
