---
titulo: Hearback 0158 - Configuracoes Iniciais botoes e menus
diataxis: status
hbn-track: safe_track
hbn-status: active
audiencia: ambos
versao-sistema: V12.0.0206
data: 2026-06-07
---

# Hearback 0158 - Configuracoes Iniciais botoes e menus

Mauricio confirmou o readback 0158 e autorizou o Codex a iniciar a validacao
tela a tela de **Configuracoes Iniciais** para botoes, menus, submenus, entrada,
saida e fechamento.

## Condicoes confirmadas

- Respeitar o escopo HBN do readback 0158.
- Nao executar VCR neste microdelta.
- Nao restaurar a 0155.
- Nao tocar nos arquivos proibidos.
- Tratar fluxos destrutivos por validacao segura ou manual.

## Consequencia operacional

A escrita da onda 0158 esta autorizada dentro do escopo confirmado. Qualquer
defeito geometrico de UserForm deve ser classificado antes e preferir
designer/export; regra, persistencia, validacao ou evento deve ter teste V2
dirigido.
