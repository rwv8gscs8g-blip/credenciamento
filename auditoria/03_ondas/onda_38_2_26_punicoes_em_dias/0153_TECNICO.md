---
titulo: Onda 38.2.26 — Punicoes em dias no rodizio
diataxis: onda
hbn-track: safe_track
hbn-status: active
audiencia: ambos
versao-sistema: V12.0.0205
data: 2026-06-06
---

# Onda 38.2.26 — Punicoes em dias no rodizio

## Contexto

A tela **Configuracoes Iniciais** mostrava a suspensao por nota em dias, mas a
suspensao por recusa/prazo ainda era descrita e parcialmente consumida como
meses. Isso criava uma divergencia grave: a interface podia indicar `0 dias`,
enquanto caminhos de codigo ainda usavam fallback legado em meses.

A decisao humana da 0153 foi padronizar a regra inteira em **dias**:

- nota abaixo do corte gera strike; ao atingir o limite, suspende por N dias;
- recusa explicita e expiracao de prazo compartilham o limite de recusas e
  suspendem por N dias;
- suspensao manual tambem exige N dias explicitos;
- meses ficam apenas como dado legado para migracao idempotente.

## Regra aplicada

`Suspender` agora recebe obrigatoriamente:

- `diasSuspensao`: inteiro entre 1 e 3650;
- `origem`: `STRIKE`, `RECUSA`, `EXPIRACAO` ou `MANUAL`;
- `configSnapshot`: texto com `MAX_RECUSAS`, `DIAS_RECUSA_PRAZO`,
  `NOTA_MIN`, `MAX_STRIKES` e `DIAS_STRIKE`.

O servico nao le mais `COL_CFG_MESES_SUSPENSAO` para calcular data final. A data
e sempre `DateAdd("d", dias, Date)`.

## Migracao

Foi adicionada a coluna `COL_CFG_DIAS_SUSPENSAO_RECUSA_PRAZO` na CONFIG para
separar a regra nova do campo legado.

`Config_MigrarPunicoesDias0153` e idempotente:

- se a nova coluna ja tem valor valido, nao altera;
- se a nova coluna esta vazia/invalida, converte o legado em meses para dias
  usando `meses * 30`, com minimo de 30 e maximo de 3650;
- se `DIAS_SUSPENSAO_STRIKE` esta vazio, zero ou invalido, tambem semeia dias;
- a segunda execucao deve virar `NOOP`, sem multiplicar novamente.

## Interface

`Configuracao_Inicial.frm` passa a persistir recusa/prazo em
`DIAS_SUSPENSAO_RECUSA_PRAZO` e valida ambos os campos de suspensao em
`1..3650`.

O `.frx` exportado pelo operador em `incoming/Configuracao_Inicial.frx` foi
sincronizado para `src/vba/Configuracao_Inicial.frx` e para
`local-ai/vba_import/002-formularios/Configuracao_Inicial.frx`.

Como o Importador V3 em modo estabilizado pode aplicar apenas `code-only` em
formularios existentes, o `UserForm_Initialize` tambem corrige defensivamente
legendas antigas que ainda digam "meses" ou "punicao" para a semantica de dias.
Isso nao altera regra de negocio; apenas impede UI antiga de mentir apos import
code-only.

## Relatorios

Foram incorporadas evidencias claras para aprovacao humana:

- novo `RPT_RODIZIO_STATUS`, gerado por `Rel_Rodizio_Status.bas`, com
  `QTD_CRED`, `QTD_APTAS`, `QTD_SUSPENSAS`, `QTD_INATIVAS`,
  `EMPRESAS_APTAS`, `EMPRESAS_SUSPENSAS`, `PROXIMO_RETORNO` e `ALERTA`;
- `ALERTA=SEM_EMPRESA_APTA` quando um item/servico nao possui empresa apta no
  rodizio;
- `Rel_Emp_Serv.frm` mostra `STATUS_CRED`, `STATUS_GLOBAL`,
  `DIAS_RESTANTES`, `RETORNO_PREVISTO` e `PARTICIPA_RODIZIO`;
- `Rel_OSEmpresa.frm` mostra status real da empresa, dias restantes e retorno
  previsto no cabecalho do relatorio;
- `Central_Testes_Relatorio` inclui resumo do status do rodizio no relatorio
  consolidado.

## Testes

Foi criado `Teste_V2_Punicoes_Dias.bas` com `TV2_RunPunicoesDias`.

Cobertura:

- migracao idempotente;
- rejeicao de zero, vazio e decimal;
- round-trip da UI em dias;
- suspensao manual explicita;
- recusa/prazo com data exata em dias;
- ausencia de novos marcadores `BASE=MESES`, `MESES=` e `FALLBACK_MESES` em
  eventos de suspensao;
- existencia dos campos de relatorio;
- alerta de item sem empresa apta.

O RVS oficial `CT_ValidarRelease_SextetoMinimo` passa a incluir a etapa
`V2_PUNICOES_DIAS`. O resultado esperado do RVS agora inclui
`PunicoesDias=8/0`.

## Pacote

Manifesto:

`local-ai/vba_import/000-MANIFESTO-V3-DELTA-ONDA38_2_26_PUNICOES_EM_DIAS.txt`

## Fix1 pos-import

O primeiro pacote 0153 importou corretamente no workbook do operador em
2026-06-06 18:47, com `M=14 | F=3 | err=0 | skip=0`, mas o compile manual
falhou em `Teste_V2_Roteiros.TV2_RunFT4CredenciamentoLote` porque o modulo
chamava diretamente `Credencia_Empresa.TV2_ExecutarCredenciamentoLote`.

O workbook validado nao tinha esse membro publico no formulario
`Credencia_Empresa`. A correcao `fix1` remove a dependencia em tempo de
compilacao: o teste FT4 agora instancia o formulario como `Object` e chama o
helper por `CallByName` dentro de
`TV2_FT4_ExecutarCredenciamentoLoteCompat`. Se o helper continuar ausente em
uma execucao FT4, isso vira falha de teste rastreavel, sem bloquear o compile.

## Fix2 pos-import

O pacote `fix1` importou, mas o compile manual avancou para outro ponto do
mesmo modulo `Teste_V2_Roteiros`: `TV2_RunBL4ProtecaoPersistente` chamava
diretamente `AutoOpen_UltimaProtecaoMarcadorExecutadaEm` e
`AutoOpen_UltimaProtecaoMarcadorAposUltimoSave`.

Como `Auto_Open.bas` esta fora do escopo e e proibido nesta onda, o `fix2`
nao importa nem altera `Auto_Open.bas`. A correcao substitui as chamadas
diretas por wrappers locais em `Teste_V2_Roteiros` que usam `Application.Run`.
Assim, a ausencia dessas funcoes deixa de bloquear o compile; se o teste BL4
for executado num workbook sem o marcador, ele registra falha auditavel em
runtime.

## Fix3 pos-import

O pacote `fix2` importou, mas o compile manual avancou para a chamada direta a
`Util_VerificarProtecaoPersistenteAposAbertura`, ainda dentro de
`TV2_RunBL4ProtecaoPersistente`.

O `fix3` substitui todas as ocorrencias diretas dessa funcao no modulo
`Teste_V2_Roteiros` por `TV2_BL4_VerificarProtecaoPersistenteCompat`, tambem
baseado em `Application.Run`. Isso cobre a chamada principal, a chamada
pos-reaplicacao e o helper interno `TV2_BL4_PrepararRestaurarCritica`.

Comando:

```vb
ImportarPacoteV3_Delta "ONDA38_2_26_PUNICOES_EM_DIAS_FIX3", "293e44c+ONDA38.2.26-PUNICOES-DIAS-fix3"
```

Gate humano esperado:

1. Restaurar o backup V3 gerado antes do primeiro 0153 se o workbook ainda
   estiver no estado que falhou compile; depois importar o `FIX3`.
2. Importador V3 com `M=14`, `F=3`, `err=0`, `skip=0`.
3. `VBE > Depurar > Compilar VBAProject` limpo.
4. `TV2_RunPunicoesDias` retorna `OK=8 | FALHA=0 | MANUAL=0`.
5. `CT_ValidarRelease_SextetoMinimo` retorna `APROVADO`, com
   `PunicoesDias=8/0`.
6. Relatorios mostram empresas aptas, suspensas, dias restantes, retorno
   previsto e itens sem empresa apta.

## Fix4 pos-import

O pacote `fix3` importou, mas o compile manual avancou para a chamada direta a
`frm.TV2_AvaliacaoDemandanteNaLista`, dentro de
`TV2_RunFormulariosAvaliacaoDemandante`.

Como `Menu_Principal.frm` esta fora do delta 0153, o `fix4` nao importa nem
altera esse formulario. A correcao muda `frm` para `Object` e substitui as
duas chamadas diretas de membros TV2 de `Menu_Principal` por wrappers locais
baseados em `CallByName`:

- `TV2_FormAval_DemandanteNaListaCompat`
- `TV2_FormAval_AplicarDemandanteImpressaoCompat`

Comando:

```vb
ImportarPacoteV3_Delta "ONDA38_2_26_PUNICOES_EM_DIAS_FIX4", "293e44c+ONDA38.2.26-PUNICOES-DIAS-fix4"
```

Gate humano esperado:

1. Restaurar o backup V3 gerado no import do `FIX3` que falhou compile; depois
   importar o `FIX4`.
2. Importador V3 com `M=14`, `F=3`, `err=0`, `skip=0`.
3. `VBE > Depurar > Compilar VBAProject` limpo.
4. `TV2_RunPunicoesDias` retorna `OK=8 | FALHA=0 | MANUAL=0`.
5. `CT_ValidarRelease_SextetoMinimo` retorna `APROVADO`, com
   `PunicoesDias=8/0`.
6. Relatorios mostram empresas aptas, suspensas, dias restantes, retorno
   previsto e itens sem empresa apta.

Resultado humano observado:

- Importador V3 OK: `M=14`, `F=3`, `err=0`, `skip=0`; backup
  `\\Mac\Home\Projetos\Credenciamento\backups\vba\20260606_193609-V3-FULL`.
- Compile manual no VBE passou limpo.
- `TV2_RunPunicoesDias`: `TV2_20260606_193709`, `OK=8`, `FALHA=0`,
  `MANUAL=0`.
- RVS: `VR_20260606_193911`, `APROVADO`, sintaxe
  `V1=171/0+V2_Smoke=34/0+V2_Canonica=24/0+E2E_Strikes=76/0+IntegridadeBase=4/0+Onda23Adv=27/0+ImpressaoResidual=7/0+PunicoesDias=8/0`.
- CSV RVS gerado:
  `auditoria/evidencias/V12.0.0205/csv/ValidacaoReleaseRVS_V12_0_0205_VR_20260606_193911.csv`.
- Observacao: os cenarios de relatorio foram cobertos pelo TV2/RVS; prints
  especificos de cada relatorio nao foram anexados separadamente.

## Nao alterado

- `Mod_Types.bas` nao foi tocado.
- `Importador_V3.bas` nao foi tocado.
- `Auto_Open.bas` e `ThisWorkbook` nao foram tocados.
- V12.0.0205 continua release oficial vigente.
- V12.0.0206 continua em validacao iterativa, sem freeze declarado.
