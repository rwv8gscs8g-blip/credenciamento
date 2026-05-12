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
V12.0.0204 apenas pela interface do Excel. O testador nao precisa abrir o
Editor VBA, a Janela Imediata, o codigo-fonte ou qualquer ferramenta de
desenvolvimento.

## 1. O que sera testado

O ciclo humano da V12.0.0204 tem duas partes:

1. Teste automatico pela interface: o testador abre a planilha, clica em
   **Central de Testes** e executa a bateria oficial da release.
2. Teste manual orientado: o testador usa os botoes do sistema para validar
   cadastros, servicos, rodizio, Pre-OS, OS, avaliacao, strikes, reativacao e
   Limpar Base.

## 2. O que nao sera exigido do testador

O testador humano nao deve:

1. abrir o Editor VBA;
2. usar a Janela Imediata;
3. importar modulos;
4. editar macros;
5. alterar codigo;
6. executar comandos de desenvolvedor.

Se algum roteiro publico pedir essas acoes como caminho principal, considere o
roteiro desatualizado para a V12.0.0204.

## 3. Material recebido pelo testador

O pacote ideal de homologacao contem:

1. arquivo `.xlsm` final compilado;
2. este guia;
3. roteiro manual V204;
4. planilha ou documento simples para registrar resultados;
5. pasta para salvar prints e CSVs de evidencia.

O arquivo `.xlsm` deve ser recebido ja preparado pelo mantenedor. A protecao do
projeto VBA deve impedir alteracao casual de macros pelo testador.

## 4. Preparacao do arquivo final pelo mantenedor

Antes de enviar o arquivo ao testador, o mantenedor deve:

1. abrir o workbook final;
2. compilar o projeto VBA;
3. confirmar o botao **Sobre** com:
   - `Release oficial: V12.0.0204`;
   - `Status oficial: VALIDADO`;
   - `Build importado: f7aa84f+ONDA25.MD25.5-limpar-cad-serv-fix2`;
4. proteger o projeto VBA:
   - abrir Editor VBA;
   - menu **Ferramentas > Propriedades de VBAProject**;
   - aba **Protecao**;
   - marcar **Bloquear projeto para exibicao**;
   - definir senha;
5. salvar como `.xlsm`;
6. fechar e reabrir o arquivo;
7. validar que o sistema abre e que a Central de Testes funciona pela interface.

Essa protecao reduz edicao acidental ou casual por testador. Ela nao deve ser
tratada como criptografia forte ou garantia absoluta contra engenharia reversa.

## 5. Liberar macros no Windows

Antes de abrir a planilha, siga:

- [Como Liberar Macros no Windows](../how-to/COMO_LIBERAR_MACROS_NO_WINDOWS.md)

Resumo:

1. salve o `.xlsm` em uma pasta local;
2. se o Windows mostrar **Desbloquear** nas propriedades do arquivo, marque essa
   opcao;
3. abra no Excel Desktop;
4. clique em **Habilitar Edicao**, se aparecer;
5. clique em **Habilitar Conteudo**, se aparecer.

## 6. Confirmar que o arquivo correto abriu

Na tela inicial do sistema:

1. clique em **Sobre**;
2. confirme `Release oficial: V12.0.0204`;
3. confirme `Status oficial: VALIDADO`;
4. confirme `Build importado: f7aa84f+ONDA25.MD25.5-limpar-cad-serv-fix2`;
5. feche a janela em **OK**.

Se a versao ou o build forem diferentes, pare o teste e avise o responsavel.

## 7. Entender os tipos de teste

| Tipo | O que prova | Quando usar |
|---|---|---|
| V1 - Bateria Oficial | Regressao historica ampla do sistema | Sempre no gate completo |
| V2 Smoke | Sanidade rapida dos fluxos principais | Antes de homologar e apos correcao |
| V2 Canonica | Regras principais de negocio em cenarios deterministas | Gate completo |
| E2E Strikes | Rodizio, avaliacao, strikes, suspensao e reativacao | Gate completo |
| IntegridadeBase | Referencias, residuos e consistencia estrutural da base | Gate completo |
| Onda23Adv | Robustez de UI, transacoes interrompidas e bordas de data | Gate completo |
| Roteiro Manual | Experiencia real pelos botoes e formularios | Apos gate automatico verde |

Na V12.0.0204, a bateria completa ainda aparece no sistema com o nome historico
**Sexteto Minimo**. Na V12.0.0205 esse nome deve ser substituido por uma
nomenclatura mais profissional.

## 8. Rodar o teste automatico pela interface

Use apenas a interface da planilha:

1. Na tela inicial, clique em **Central de Testes**.
2. Se aparecer a mensagem **Modo Treinamento**, clique em **Sim**.
3. Se aparecer a janela **Central de Testes V12 / Transicao**, escolha a opcao
   **[2] Central de Testes V2**.
4. Na janela **Central de Testes V2**, escolha **[1] Sexteto Minimo**.
5. Aguarde a execucao terminar.
6. No final, confira a mensagem de conclusao e a aba `VALIDACAO_RELEASE`.

Observacao importante para a V12.0.0204: a janela intermediaria ainda menciona
**Quarteto Direto** como gate antigo. Para a release final, use a Central V2 e
rode **[1] Sexteto Minimo**.

## 9. Resultado automatico esperado

O resultado esperado da V12.0.0204 e:

```text
V1=171/0+V2_Smoke=34/0+V2_Canonica=24/0+E2E_Strikes=76/0+IntegridadeBase=4/0+Onda23Adv=27/0
```

O campo `RESULTADO_GERAL` deve mostrar `APROVADO`.

Evidencias oficiais ja aprovadas:

| Evidencia | Papel |
|---|---|
| `VR_20260511_154433` | Gate usado na publicacao V12.0.0204 |
| `VR_20260511_175849` | Gate adicional apos ajuste final de App_Release |

## 10. Se o teste automatico falhar

Registre:

1. print da mensagem de erro;
2. print da aba `VALIDACAO_RELEASE`;
3. nome do CSV de falha, se for gerado;
4. versao exibida no botao **Sobre**;
5. qual opcao foi escolhida na Central de Testes.

Classifique como:

| Severidade | Quando usar |
|---|---|
| P0 | Excel fecha, arquivo corrompe, dados somem, sistema nao abre |
| P1 | regra de negocio falha, teste automatico reprova, erro VBA em fluxo principal |
| P2 | mensagem confusa, evidencias incompletas, navegacao pouco clara |
| P3 | texto, visual, ergonomia menor |

## 11. Rodar o roteiro manual

Depois do teste automatico aprovado, siga:

- [Roteiro de Teste Manual V204](../reference/testes/07_ROTEIRO_TESTE_MANUAL_V204.md)

Execute pelo menos estes blocos:

1. conferir **Sobre**;
2. cadastrar entidade;
3. cadastrar empresa;
4. abrir e cadastrar servico;
5. credenciar empresa;
6. indicar empresa para servico;
7. emitir solicitacao;
8. aceitar Pre-OS e gerar OS;
9. avaliar prestador;
10. validar strikes e suspensao;
11. reativar empresa;
12. rodar **Limpar Base**;
13. confirmar que CNAE foi preservado;
14. confirmar que `CAD_SERV` foi zerado;
15. cadastrar novo servico apos limpeza.

## 12. Contrato de Limpar Base

Na V12.0.0204, **Limpar Base** deve preparar a planilha para outro municipio.

Resultado esperado:

| Item | Deve acontecer |
|---|---|
| CNAE / `ATIVIDADES` | Preservado |
| `CONFIG` | Preservado |
| `CAD_SERV` | Zerado, com cabecalho preservado |
| Empresas, entidades, credenciamentos, Pre-OS e OS | Zerados |
| Cadastro de Servico | Abre sem erro e permite novo servico |

Esse ponto e obrigatorio porque a planilha precisa ser reutilizavel em outro
municipio sem lixo operacional acumulado.

## 13. Checklist final do testador

| Item | Resultado |
|---|---|
| Macros liberadas |  |
| Sobre mostra V12.0.0204 VALIDADO |  |
| Central de Testes abriu |  |
| Sexteto Minimo rodou pela interface |  |
| Resultado geral aprovado |  |
| CSV ou print de evidencia salvo |  |
| Roteiro manual executado |  |
| Limpar Base validado |  |
| Anomalias registradas |  |
| Decisao final do testador |  |

## 14. Modelo de bug report

Use este formato:

```text
ID:
Data/hora:
Testador:
Arquivo testado:
Tela/botao:
Passo executado:
Resultado esperado:
Resultado obtido:
Severidade: P0 / P1 / P2 / P3
Print anexado: sim / nao
CSV anexado: sim / nao / nao gerado
Observacoes:
```

## 15. Debitos de experiencia para V12.0.0205

Estes pontos ficam registrados para a proxima versao:

1. renomear "Sexteto", "Quinteto" e "Quarteto" para nomes profissionais;
2. tornar a primeira tela da Central de Testes orientada ao teste completo de
   release;
3. remover ou rebaixar a opcao antiga de Quarteto como gate;
4. simplificar a mensagem de Modo Treinamento;
5. exibir na propria interface o que cada bateria faz;
6. gerar orientacao de evidencia em linguagem de testador humano.
