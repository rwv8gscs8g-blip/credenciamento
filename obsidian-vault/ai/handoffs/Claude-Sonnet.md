# Prompt para Claude Sonnet

Copiar TODO o conteudo abaixo e colar como prompt no Claude Sonnet (via API, Cowork ou chat).

---

## IDENTIDADE DO PROJETO

Voce esta assumindo o desenvolvimento de um Sistema de Gestao de Credenciamento de Pequenos Reparos para Prefeituras, implementado em Excel VBA (.xlsm). O sistema gerencia rodizio de empresas pre-qualificadas para execucao de reparos em instalacoes publicas.

**Versao:** V12.0.0111 (estavel, compilada, homologada em producao)
**Repositorio:** git@github.com:rwv8gscs8g-blip/credenciamento.git
**Documentacao completa:** pasta `obsidian-vault/` no repositorio

## LEITURA OBRIGATORIA

Antes de qualquer acao, leia estes arquivos na ordem:
1. `obsidian-vault/01-CONTEXTO-IA.md` — contexto completo do projeto
2. `obsidian-vault/regras/Compilacao-VBA.md` — regras que matam a compilacao
3. `obsidian-vault/regras/Governanca.md` — regras de processo

## ARQUITETURA EM 4 CAMADAS

```
Camada 0: Tipos + Constantes (Mod_Types, Const_Colunas)
Camada 1: Utilitarios (Util_Config, Util_Planilha, Util_Conversao, Funcoes, ErrorBoundary)
Camada 2: Repositorios (Repo_Credenciamento, Repo_PreOS, Repo_OS, Repo_Avaliacao, Repo_Empresa)
Camada 3: Servicos (Svc_Rodizio, Svc_PreOS, Svc_OS, Svc_Avaliacao)
Camada 4: Interface (Preencher, Classificar, Auto_Open + 13 UserForms)
```

## REGRAS CRITICAS (historico de 3 meses de regressao)

**Killer Pattern #1 — Colon:** `Dim x As T: x = valor` corrompe o indice do modulo e causa erro cascata "Nome repetido encontrado: TConfig" em OUTRO modulo. SEMPRE separar em duas linhas.

**Killer Pattern #2 — FileSystem:** MkDir, Kill, Dir() nativos tornam o modulo invisivel para o compilador. SEMPRE usar FSO late-binding.

**Mais regras:**
- 1 arquivo modificado por iteracao (MAXIMO)
- NUNCA renomear VB_Name (causou 3 meses de bug)
- NUNCA remover funcoes Public existentes
- SEMPRE chamadas qualificadas: `Util_Config.GetConfig`, nao apenas `GetConfig`
- SEMPRE rodar checklist pre-deploy antes de entregar

## CHECKLIST PRE-DEPLOY

```bash
grep -rn "Dim .* As .*:.*=" vba_export/*.bas vba_export/*.frm     # VAZIO
grep -rn "MkDir\|^\s*Kill \| Dir(" vba_export/*.bas vba_export/*.frm  # VAZIO
grep -rh "Attribute VB_Name" vba_export/*.bas vba_export/*.frm | sort | uniq -d  # VAZIO
grep -rn "Public Type" vba_export/*.bas | awk -F: '{print $NF}' | sort | uniq -d  # VAZIO
```

## INTEGRACAO COM SAAS

O projeto tem um irmao SaaS (Next.js + NeonDB) em desenvolvimento. A planilha e open-source, o SaaS e pago. Os dados sao 100% compativeis: cada aba Excel mapeia para uma tabela Postgres. Detalhes em `obsidian-vault/arquitetura/SaaS-Roadmap.md`.

## COMO TRABALHAR

1. Receba a tarefa especifica (ex: "adicionar Util_CNAE.bas")
2. Leia o arquivo atual de `vba_export/` se for modificacao
3. Leia a especificacao em `obsidian-vault/backlog/` se existir
4. Faca a modificacao respeitando TODAS as regras
5. Rode o checklist
6. Entregue: arquivo modificado + release note + resultado do checklist
7. Se possivel, faca git commit com tag

## BACKLOG ATUAL

| Release | Tarefa | Arquivo |
|---------|--------|---------|
| V12.0.0108 | Adicionar modulo CNAE | Util_CNAE.bas (NOVO) |
| V12.0.0109 | Integrar CNAE no Auto_Open | Auto_Open.bas |
| V12.0.0110 | Filtro busca Reativa_Empresa | Reativa_Empresa.frm |
| V12.0.0111 | Filtro busca Reativa_Entidade | Reativa_Entidade.frm |
| V12.0.0112 | Filtro busca Cadastro_Servico | Cadastro_Servico.frm |

## TAREFA

[INSERIR AQUI A TAREFA ESPECIFICA]
