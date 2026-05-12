---
titulo: Como Rodar o Sexteto de Validação da Release
diataxis: how-to
hbn-track: safe_track
hbn-status: active
audiencia: humano
versao-sistema: V12.0.0204
data: 2026-05-12
---

# Como Rodar o Sexteto de Validação da Release

Este é o procedimento canônico da V12.0.0204 para reproduzir o gate
automatizado da release em uma máquina Windows com Excel Desktop, usando apenas
a interface da planilha.

## Pré-requisitos

1. A planilha `.xlsm` está salva localmente.
2. As macros foram liberadas conforme
   [Como Liberar Macros no Windows](COMO_LIBERAR_MACROS_NO_WINDOWS.md).
3. A tela inicial do sistema abre normalmente.
4. O botão **Sobre** confirma V12.0.0204, status VALIDADO e build final
   homologado.

## Caminho pela interface

1. Na tela inicial, clique em **Central de Testes**.
2. Se aparecer a mensagem **Modo Treinamento**, clique em **Sim**.
3. Se aparecer a janela **Central de Testes V12 / Transição**, escolha:

```text
[2] Central de Testes V2
```

4. Na janela **Central de Testes V2**, escolha:

```text
[1] Sexteto Mínimo
```

5. Aguarde a execução terminar.
6. Ao final, confira a mensagem de conclusão e a aba `VALIDACAO_RELEASE`.

O Excel deve preencher a aba `VALIDACAO_RELEASE`, exibir uma mensagem de
conclusão e gerar um CSV de resumo em:

```text
auditoria/evidencias/V12.0.0204/
```

## Resultado esperado

Para a V12.0.0204 validada, a sintaxe aprovada é:

```text
V1=171/0+V2_Smoke=34/0+V2_Canonica=24/0+E2E_Strikes=76/0+IntegridadeBase=4/0+Onda23Adv=27/0
```

O resultado geral deve ser `APROVADO`.

## Observação sobre a tela intermediária

Na V12.0.0204, a primeira janela da Central ainda pode exibir **Quarteto
Direto** como gate histórico. Para validar a release final, use a Central V2 e
rode **[1] Sexteto Mínimo**.

Esse ajuste de mensageria e ordem da Central de Testes está registrado como
débito da V12.0.0205.

## Evidências oficiais da V204

| Evidência | Papel |
|---|---|
| `VR_20260511_154433` | Gate final usado para publicação da V12.0.0204 |
| `VR_20260511_175849` | Gate adicional após MICRO55 App_Release final |

Ambas estão em `auditoria/evidencias/V12.0.0204/`.

## Regra de decisão

| Situação | Decisão |
|---|---|
| Planilha não abre ou macros ficam bloqueadas | Reprovar e registrar a mensagem |
| Botão **Sobre** mostra versão/build diferente | Reprovar e registrar o valor exibido |
| Qualquer suíte com falha maior que zero | Reprovar e anexar CSV de falhas |
| `MANUAL` diferente do esperado sem justificativa | Registrar como anomalia P2 |
| Sintaxe igual ao esperado e resultado `APROVADO` | Gate automatizado aprovado |

## Depois do Sexteto

Execute o roteiro humano da V204:

- [Roteiro de Teste Manual V204](../reference/testes/07_ROTEIRO_TESTE_MANUAL_V204.md)

O roteiro manual cobre o uso real da planilha, incluindo Limpar Base, cadastro
de serviços, credenciamento, rodízio, OS, avaliação, strikes e reativação.
