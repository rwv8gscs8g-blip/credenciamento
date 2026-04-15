# Filtros de Busca nos Formularios

Status: BACKLOG
Releases: V12.0.0110, V12.0.0111, V12.0.0112
Relacionado: [[Formularios]], [[CNAE-Import]]

---

## Objetivo

Adicionar campos de busca incremental (TextBox com filtro em tempo real) nos formularios que possuem listas longas, permitindo que o usuario encontre rapidamente empresas, entidades e servicos.

## Estado Atual

O Menu_Principal ja possui campos de busca para empresa (M_Lista) e entidade (C_Lista) desde a V12-093. Os formularios abaixo ainda NAO possuem:

## Plano de Implementacao

### V12.0.0110 — Reativa_Empresa.frm
- Adicionar TextBox `txtBusca` acima da ListBox de empresas inativas
- Evento `txtBusca_Change`: filtrar ListBox em tempo real
- Criterio: busca por razao social (case-insensitive, contem)
- Risco: BAIXO — alteracao isolada em 1 form

### V12.0.0111 — Reativa_Entidade.frm
- Mesma logica de Reativa_Empresa
- Filtrar entidades inativas por nome
- Risco: BAIXO

### V12.0.0112 — Cadastro_Servico.frm
- Filtrar lista de servicos por descricao
- Pode incluir filtro por atividade/CNAE se disponivel
- Risco: BAIXO

## Notas Tecnicas

- O codigo de filtro ja existia na V12-105 (que nao compilava). Os .frm modificados estao preservados em `historico/vba_export_broken_v104/` como referencia.
- A implementacao deve copiar APENAS a logica de filtro, sem outras modificacoes.
- Compilar apos CADA form modificado, nao acumular.
