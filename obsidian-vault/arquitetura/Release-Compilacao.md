# Arquitetura de Release e Compilacao

Data: 2026-04-10
Autores: Claude Opus 4.6 + Codex (revisao e adaptacao)
Status: APROVADA PARA IMPLEMENTACAO

---

## 1. Diagnostico consolidado

### 1.1 Versao hardcoded em `Menu_Principal.frm`

O menu principal exibia release, iteracao e URLs via `Private Const`. Isso criava tres problemas:

- cada bump de versao exigia tocar no formulario mais sensivel do sistema
- a versao visual podia divergir do pacote real de importacao
- o `Menu_Principal` continuava carregando 2 ocorrencias do killer pattern `Dim ... : ... =`

### 1.2 A versao precisa ficar em codigo versionado

A proposta de usar `CONFIG!G2` foi descartada. O projeto precisa manter a release dentro de `vba_export/` para:

- acompanhar o Git
- refletir exatamente o estado do codigo importado
- evitar drift entre `.xlsm` e repositorio
- reduzir impacto em `TConfig` e `Util_Config`

### 1.3 O drift real estava no pacote de importacao

`scripts/publicar_vba_import.sh` ja rodava, mas o texto gerado em `vba_import/000-ORDEM-IMPORTACAO.txt` estava defasado em relacao ao pacote real:

- citava `024-Util_CNAE.bas`, que nao existe em `vba_export/`
- citava `023-Auto_Open.bas`, enquanto o pacote real usa `025-Auto_Open.bas`
- informava contagem de modulos incorreta

### 1.4 Faltava pipeline explicito de release

O projeto precisava formalizar a separacao entre:

1. candidata local
2. compilada no Excel
3. publicada no GitHub

---

## 2. Arquitetura escolhida

### 2.1 Fonte unica de metadata: `App_Release.bas`

Foi adotado um modulo dedicado em `vba_export/App_Release.bas`, com:

- `GetReleaseAtual()`
- `GetReleaseStatus()`
- `GetIteracaoAtual()`
- `GetGitHubRepoUrl()`
- `GetGitHubReleaseNotesUrl()`

Esse modulo passa a ser a fonte unica de verdade para o que o `Menu_Principal` mostra ao usuario.

### 2.2 Papel do `Menu_Principal.frm`

O `Menu_Principal` nao define mais versao nem URLs. Ele apenas consome `App_Release.*`.

Ao tocar no form, a iteracao de estabilizacao tambem corrige obrigatoriamente:

- `Menu_Principal.frm:1862`
- `Menu_Principal.frm:1863`

Essas linhas deixaram de usar `Dim ... : ... =`.

### 2.3 Papel do `vba_import/`

`vba_import/` passa a ser tratado explicitamente como artefato gerado. O fluxo correto e:

1. editar `vba_export/`
2. rodar `bash scripts/publicar_vba_import.sh`
3. importar no Excel
4. compilar

---

## 3. Regra operacional atual

### 3.1 Change-set coeso

A regra antiga "1 arquivo por iteracao" foi substituida por:

**1 change-set coeso por iteracao**

Pacote padrao permitido:

1. arquivo funcional principal
2. `App_Release.bas`, quando houver bump de versao ou ajuste de metadata
3. release note/documentacao operacional
4. artefatos gerados em `vba_import/`

### 3.2 Pipeline de release

#### Etapa 1: Candidata

- editar `vba_export/`
- rodar checklist local
- regenerar `vba_import/`
- atualizar documentacao aplicavel

#### Etapa 2: Compilada

- importar no Excel
- rodar `Depurar > Compilar VBAProject`
- se falhar, corrigir no repositorio e repetir

#### Etapa 3: Publicada

- commit final da release
- tag `v12.0.XXXX`
- `git push origin main --tags`

---

## 4. Ordem de implementacao aprovada

### Pacote de estabilizacao atual

1. criar `vba_export/App_Release.bas`
2. atualizar `vba_export/Menu_Principal.frm`
3. corrigir `scripts/publicar_vba_import.sh`
4. regenerar `vba_import/`
5. atualizar documentos de governanca e handoff
6. importar no Excel e compilar

### Evolucoes funcionais depois da compilacao

Somente depois do pacote acima compilar no Excel:

1. `Reativa_Entidade.frm`
2. `Cadastro_Servico.frm`
3. proximas features de negocio

---

## 5. Criterios de aceite

- [ ] `App_Release.bas` existe e centraliza a metadata da release
- [ ] `Menu_Principal.frm` nao tem mais `Private Const` de versao/URLs
- [ ] `Menu_Principal.frm` nao tem mais `Dim ... : ... =`
- [ ] `bash scripts/publicar_vba_import.sh` roda sem erro
- [ ] `vba_import/000-ORDEM-IMPORTACAO.txt` reflete o pacote real
- [ ] o pacote importa no Excel
- [ ] `Depurar > Compilar VBAProject` conclui sem erro

---

## 6. Decisao de arquitetura

| Criterio | CONFIG (aba) | App_Release.bas |
|----------|--------------|-----------------|
| Fonte de verdade no Git | NAO | SIM |
| Risco no core config | MEDIO | BAIXO |
| Drift entre `.xlsm` e repo | MAIOR | MENOR |
| Acoplamento ao Menu | indireto | direto e simples |
| Dependencia extra em runtime | `Util_Config` + `TConfig` | modulo isolado |

**Decisao final:** `App_Release.bas`

