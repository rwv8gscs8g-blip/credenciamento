---
titulo: Guia de Testes Humanos V204
diataxis: tutorial
hbn-track: safe_track
hbn-status: active
audiencia: humano
versao-sistema: V12.0.0204
data: 2026-05-12
---

# Guia de Testes Humanos V204

Este guia orienta uma pessoa externa ao desenvolvimento a validar a
V12.0.0204 apenas pela interface do Excel. O testador não precisa abrir o
Editor VBA, a Janela Imediata, o código-fonte ou qualquer ferramenta de
desenvolvimento.

## 1. Objetivo da homologação

A homologação humana confirma três coisas:

1. a planilha abre corretamente em uma máquina Windows com Excel Desktop;
2. a bateria automática oficial roda pela interface e retorna `APROVADO`;
3. os fluxos manuais críticos funcionam pelos botões da planilha, com
   evidências suficientes para uma decisão de liberação.

O testador humano não aprova código. Ele aprova o comportamento observável do
arquivo `.xlsm` recebido.

## 2. O que será testado

O ciclo humano da V12.0.0204 tem duas partes:

1. **Teste automático pela interface:** o testador abre a planilha, clica em
   **Central de Testes** e executa a bateria oficial da release.
2. **Teste manual orientado:** o testador usa os botões do sistema para validar
   cadastros, serviços, rodízio, Pré-OS, OS, avaliação, strikes, reativação e
   Limpar Base.

## 3. O que não será exigido do testador

O testador humano não deve:

1. abrir o Editor VBA;
2. usar a Janela Imediata;
3. importar módulos;
4. editar macros;
5. alterar código;
6. executar comandos de desenvolvedor.

Se algum roteiro público pedir essas ações como caminho principal, considere o
roteiro desatualizado para a V12.0.0204.

## 4. Material recebido pelo testador

O pacote ideal de homologação contém:

1. arquivo `.xlsm` final compilado;
2. este guia;
3. roteiro manual V204;
4. documento simples para registrar resultados;
5. pasta para salvar prints e CSVs de evidência.

O arquivo `.xlsm` deve ser recebido já preparado pelo mantenedor. A proteção do
projeto VBA deve impedir alteração casual de macros pelo testador.

## 5. Preparação do arquivo final pelo mantenedor

Antes de enviar o arquivo ao testador, o mantenedor deve:

1. abrir o workbook final;
2. compilar o projeto VBA;
3. confirmar o botão **Sobre** com:
   - `Release oficial: V12.0.0204`;
   - `Status oficial: VALIDADO`;
   - `Build importado: f7aa84f+ONDA25.MD25.5-limpar-cad-serv-fix2`;
4. proteger o projeto VBA:
   - abrir Editor VBA;
   - menu **Ferramentas > Propriedades de VBAProject**;
   - aba **Proteção**;
   - marcar **Bloquear projeto para exibição**;
   - definir senha;
5. salvar como `.xlsm`;
6. fechar e reabrir o arquivo;
7. validar que o sistema abre e que a Central de Testes funciona pela interface.

Essa proteção reduz edição acidental ou casual por testador. Ela não deve ser
tratada como criptografia forte ou garantia absoluta contra engenharia reversa.

O testador deve recusar arquivo cujo projeto VBA esteja deliberadamente aberto
para edição casual, salvo quando o objetivo formal do teste for auditar o
código-fonte.

## 6. Liberar macros no Windows

Antes de abrir a planilha, siga:

- [Como Liberar Macros no Windows](../how-to/COMO_LIBERAR_MACROS_NO_WINDOWS.md)

Resumo:

1. salve o `.xlsm` em uma pasta local;
2. se o Windows mostrar **Desbloquear** nas propriedades do arquivo, marque essa
   opção;
3. abra no Excel Desktop;
4. clique em **Habilitar Edição**, se aparecer;
5. clique em **Habilitar Conteúdo**, se aparecer.

## 7. Confirmar que o arquivo correto abriu

Na tela inicial do sistema:

1. clique em **Sobre**;
2. confirme `Release oficial: V12.0.0204`;
3. confirme `Status oficial: VALIDADO`;
4. confirme `Build importado: f7aa84f+ONDA25.MD25.5-limpar-cad-serv-fix2`;
5. feche a janela em **OK**.

Se a versão ou o build forem diferentes, pare o teste e avise o responsável.

## 8. Entender os tipos de teste

| Tipo | O que prova | Quando usar |
|---|---|---|
| V1 - Bateria Oficial | Regressão histórica ampla do sistema | Sempre no gate completo |
| V2 Smoke | Sanidade rápida dos fluxos principais | Antes de homologar e após correção |
| V2 Canônica | Regras principais de negócio em cenários determinísticos | Gate completo |
| E2E Strikes | Rodízio, avaliação, strikes, suspensão e reativação | Gate completo |
| IntegridadeBase | Referências, resíduos e consistência estrutural da base | Gate completo |
| Onda23Adv | Robustez de UI, transações interrompidas e bordas de data | Gate completo |
| Roteiro Manual | Experiência real pelos botões e formulários | Após gate automático verde |

Na V12.0.0204, a bateria completa ainda aparece no sistema com o nome histórico
**Sexteto Mínimo**. Na V12.0.0205 esse nome deve ser substituído por uma
nomenclatura mais profissional.

## 9. Rodar o teste automático pela interface

Use apenas a interface da planilha:

1. Na tela inicial, clique em **Central de Testes**.
2. Se aparecer a mensagem **Modo Treinamento**, clique em **Sim**.
3. Se aparecer a janela **Central de Testes V12 / Transição**, escolha a opção
   **[2] Central de Testes V2**.
4. Na janela **Central de Testes V2**, escolha **[1] Sexteto Mínimo**.
5. Aguarde a execução terminar.
6. No final, confira a mensagem de conclusão e a aba `VALIDACAO_RELEASE`.

Observação importante para a V12.0.0204: a janela intermediária ainda menciona
**Quarteto Direto** como gate antigo. Para a release final, use a Central V2 e
rode **[1] Sexteto Mínimo**.

## 10. Resultado automático esperado

O resultado esperado da V12.0.0204 é:

```text
V1=171/0+V2_Smoke=34/0+V2_Canonica=24/0+E2E_Strikes=76/0+IntegridadeBase=4/0+Onda23Adv=27/0
```

O campo `RESULTADO_GERAL` deve mostrar `APROVADO`.

Evidências oficiais já aprovadas:

| Evidência | Papel |
|---|---|
| `VR_20260511_154433` | Gate usado na publicação V12.0.0204 |
| `VR_20260511_175849` | Gate adicional após ajuste final de App_Release |

## 11. Se o teste automático falhar

Registre:

1. print da mensagem de erro;
2. print da aba `VALIDACAO_RELEASE`;
3. nome do CSV de falha, se for gerado;
4. versão exibida no botão **Sobre**;
5. qual opção foi escolhida na Central de Testes.

Classifique como:

| Severidade | Quando usar |
|---|---|
| P0 | Excel fecha, arquivo corrompe, dados somem, sistema não abre |
| P1 | regra de negócio falha, teste automático reprova, erro VBA em fluxo principal |
| P2 | mensagem confusa, evidências incompletas, navegação pouco clara |
| P3 | texto, visual, ergonomia menor |

## 12. Rodar o roteiro manual

Depois do teste automático aprovado, siga:

- [Roteiro de Teste Manual V204](../reference/testes/07_ROTEIRO_TESTE_MANUAL_V204.md)

Execute pelo menos estes blocos:

1. conferir **Sobre**;
2. cadastrar entidade;
3. cadastrar empresa;
4. abrir e cadastrar serviço;
5. credenciar empresa;
6. indicar empresa para serviço;
7. emitir solicitação;
8. aceitar Pré-OS e gerar OS;
9. avaliar prestador;
10. validar strikes e suspensão;
11. reativar empresa;
12. rodar **Limpar Base**;
13. confirmar que CNAE foi preservado;
14. confirmar que `CAD_SERV` foi zerado;
15. cadastrar novo serviço após limpeza.

## 13. Regras de negócio que não podem ser violadas

O documento canônico é:

- [Regras de Negócio V204](../reference/regras/REGRAS_DE_NEGOCIO_V204.md)

Resumo das regras críticas:

| Regra | Como o teste garante |
|---|---|
| Rodízio escolhe empresa apta e pula impedidas | V2 Canônica, E2E Strikes e roteiro M-07 |
| Pre-OS pendente e OS aberta bloqueiam nova indicação | V2 Canônica e E2E Strikes |
| Recusa avança fila de forma auditável | E2E Strikes |
| Avaliação negativa registra strike | E2E Strikes e roteiro M-09 |
| Três strikes suspendem conforme configuração | E2E Strikes e Smoke `MIG_008` |
| Reativação preserva histórico e reinicia janela punitiva | E2E Strikes, Boundary Dates e roteiro M-11 |
| Limpar Base preserva CNAE e zera `CAD_SERV` | Smoke `MIG_009` e roteiro M-12 a M-14 |

## 14. Contrato de Limpar Base

Na V12.0.0204, **Limpar Base** deve preparar a planilha para outro município.

Resultado esperado:

| Item | Deve acontecer |
|---|---|
| CNAE / `ATIVIDADES` | Preservado |
| `CONFIG` | Preservado |
| `CAD_SERV` | Zerado, com cabeçalho preservado |
| Empresas, entidades, credenciamentos, Pré-OS e OS | Zerados |
| Cadastro de Serviço | Abre sem erro e permite novo serviço |

Esse ponto é obrigatório porque a planilha precisa ser reutilizável em outro
município sem lixo operacional acumulado.

## 15. Checklist final do testador

| Item | Resultado |
|---|---|
| Macros liberadas |  |
| Sobre mostra V12.0.0204 VALIDADO |  |
| Central de Testes abriu |  |
| Sexteto Mínimo rodou pela interface |  |
| Resultado geral aprovado |  |
| CSV ou print de evidência salvo |  |
| Roteiro manual executado |  |
| Limpar Base validado |  |
| Anomalias registradas |  |
| Decisão final do testador |  |

## 16. Modelo de bug report

Use este formato:

```text
ID:
Data/hora:
Testador:
Arquivo testado:
Tela/botão:
Passo executado:
Resultado esperado:
Resultado obtido:
Severidade: P0 / P1 / P2 / P3
Print anexado: sim / não
CSV anexado: sim / não / não gerado
Observações:
```

## 17. Débitos de experiência para V12.0.0205

Estes pontos ficam registrados para a próxima versão:

1. renomear "Sexteto", "Quinteto" e "Quarteto" para nomes profissionais;
2. tornar a primeira tela da Central de Testes orientada ao teste completo de
   release;
3. remover ou rebaixar a opção antiga de Quarteto como gate;
4. simplificar a mensagem de Modo Treinamento;
5. exibir na própria interface o que cada bateria faz;
6. gerar orientação de evidência em linguagem de testador humano.
