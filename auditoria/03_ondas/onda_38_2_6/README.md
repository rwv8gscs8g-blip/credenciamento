---
titulo: Onda 38.2.6 - integridade de impressao
diataxis: onda
hbn-track: safe_track
hbn-status: active
audiencia: ambos
versao-sistema: V12.0.0205
data: 2026-05-31
---

# Onda 38.2.6 - integridade de impressao

## Escopo

Microdelta safe_track vinculado ao readback 0122 para tratar BL-5, BL-6,
BL-7 e FT-7 do parecer 0024.

## Mudancas

- BL-5: `PreencherAvaliacaoOS` deixa de escrever `Format(<texto cru>, "##,#")`
  em `IMP_AVALIA!N27:N36` e passa a usar helper de nota segura limitado a 0..10.
- BL-6: `BE_ImprimeOS_Click` carrega `END_ENTIDADE` diretamente da aba
  `ENTIDADE` antes de chamar `PreencherOS`; o template continua escrevendo
  `EMITE_OS!F18`.
- BL-7: `GarantirDadosPreOSParaImpressao` normaliza o identificador exibido
  como `PROVISORIA - <id>` antes de buscar `PRE_OS`, preservando o texto de
  exibicao em `EMITE_PREOS!L3`.
- FT-7: `NR_Empenho` passa a receber explicitamente `N_Empenho.Value` e o
  template de OS mantem a gravacao em `EMITE_OS!D84`.
- Teste V2 dirigido: `TV2_RunImpressaoIntegridade` cobre o clamp das notas,
  normalizacao de ID de Pre-OS e tokens estruturais de ponte form/template.

## Fora do escopo

- `Auto_Open.bas` nao foi tocado.
- `Mod_Types.bas` nao foi tocado.
- Nao houve propagacao do padrao de Entidades.
- Nao ha declaracao de freeze V206.
