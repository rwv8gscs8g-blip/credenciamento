---
titulo: Acesso controlado via CLA — modelo de governanca
data: 2026-04-29
autoria: Claude Opus 4.7 (Cowork) na Onda 9 antecipada apos diretiva explicita do Mauricio
aplica-a: governanca de distribuicao de ferramentas e pacote operacional do projeto
revisar-em: a cada nova categoria de conteudo a ser distribuida
status: vigente
relacionados:
  - 0001-regras-v203-inegociaveis.md (regra 14 propostai sera adicionada)
  - 0002-regra-ouro-vba-import.md
  - CLA.md secao 7
  - CONTRIBUTING.md
fonte-canonica: este arquivo + docs/explanation/MODELO_DE_ACESSO_CONTROLADO.md (Diataxis)
---

# Acesso controlado via CLA — protocolo de governanca

## Por que existe

O projeto Credenciamento e **source-available** sob TPGL v1.1, com
**auto-conversao para Apache 2.0 em 4 anos**. Ate la, parte do
ferramental operacional fica restrito a contribuidores que assinaram o
CLA, com responsabilidades juridicas associadas. Esse modelo:

- mantem **auditoria publica integra** do codigo VBA do produto
- permite que **qualquer pessoa** verifique regras de negocio, evidencias
  de teste, licenciamento, governanca
- **controla acesso a ferramentas de manutencao** que poderiam ser
  usadas para alterar/regenerar o pacote operacional fora do fluxo
  oficial
- **reforca rastreabilidade** de quem tem capacidade de modificar
  estruturalmente o projeto

## Duas categorias de conteudo

### Categoria PUBLICA (auditavel por qualquer pessoa)

Itens versionados no GitHub publico, acessiveis sem CLA:

| Categoria | Localizacao | Por que e publico |
|---|---|---|
| Codigo VBA do produto | `src/vba/*.bas` e `src/vba/*.frm` | parte do produto que roda no `.xlsm` do operador — auditabilidade publica |
| Documentacao tecnica | `auditoria/`, `docs/`, `.hbn/` | quem audita precisa ler |
| Vitrine institucional | `obsidian-vault/` | apresentacao publica do projeto |
| Evidencias de teste | `auditoria/04_evidencias/` | provas publicas de validacao |
| Regras canonicas | `.hbn/knowledge/`, `auditoria/01_regras_e_governanca/` | governanca publica |
| Licencas | `LICENSE`, `CLA.md`, `CODE_OF_CONDUCT.md`, `CONTRIBUTING.md`, `SECURITY.md` | obrigatoriedade legal |
| Mapas para LLMs | `AGENTS.md`, `llms.txt`, `llms-full.txt` | navegacao para IAs e contribuidores |
| Manifestos de contrato | `docs/reference/MANIFESTO_FORMAT.md` (e similares) | contrato publico de formato — implementacao e que e privada |

### Categoria CLA-CONTROLADA (so com CLA assinado e validado)

Itens em `local-ai/` (gitignored), distribuidos por canal controlado:

| Categoria | Localizacao | Por que e controlado |
|---|---|---|
| Pacote operacional de import | `local-ai/vba_import/` | toolkit que reconstroi o `.xlsm` — modificacao livre quebraria a Regra de Ouro |
| Ferramentas Bash/Python | `local-ai/scripts/` | sincronizam src/vba <-> vba_import com normalizacao G6+G8 — uso indevido pode corromper pacote |
| Exports do workbook | `local-ai/incoming/` | dados brutos do workbook em homologacao — podem conter PII operacional |
| Backups historicos | `local-ai/historico/` | snapshots de iteracoes antigas — ruido para publico |
| Vault Obsidian privado | `local-ai/obsidian-vault/` | notas internas de operacao — nao para publico |

## Modelo B — Distribuicao via release zip

**Modelo escolhido:** distribuicao por release zip cifrado, sob
solicitacao apos aceite rastreavel do CLA.

### Fluxo do mantenedor

1. A cada release oficial (V12.0.0203, V12.0.0204, etc.), empacotar:
   ```
   credenciamento-tooling-v12.0.0203.zip
       └── local-ai/
           ├── vba_import/        (pacote operacional)
           ├── scripts/           (ferramentas)
           └── README.md          (instrucoes de uso)
   ```
2. Cifrar o zip com gpg ou senha forte.
3. Calcular sha256 do zip cifrado.
4. Hospedar em local privado controlado (Box, Drive, S3 com auth, etc).
5. Registrar em planilha interna: nome da release, data de geracao,
   sha256, link, lista de contribuidores autorizados.

### Fluxo do contribuidor

1. Ler `LICENSE`, `CLA.md`, `CONTRIBUTING.md` no repo publico.
2. Decidir se quer ser contribuidor (assinar CLA implica responsabilidade).
3. Submeter aceite rastreavel do CLA por uma das vias:
   - PR no repositorio publico com declaracao explicita
   - email com `Signed-off-by: Nome <email>` para o mantenedor
   - aceite eletronico documentado pelo mantenedor
4. Aguardar validacao do enquadramento (mantenedor confirma se voce e
   contribuidor potencial ou municipio usuario).
5. Receber link unico para download do release zip + senha gpg/zip.
6. Verificar sha256 do zip baixado.
7. Descompactar em `<seu-clone>/local-ai/`.
8. Seguir `local-ai/scripts/README.md` para uso operacional.

### Fluxo de atualizacao

A cada nova release, contribuidor com CLA recebe novo link
automaticamente (se ja registrado) ou solicita ao mantenedor.

## Auditabilidade do modelo

Mesmo sendo controlado, o modelo e **auditavel**:

- **Quem tem CLA?** Lista publica em `auditoria/01_regras_e_governanca/`
  (a criar, opcional) ou registro interno do mantenedor.
- **Quais zips foram distribuidos?** Registro interno do mantenedor com
  sha256 + lista de destinatarios.
- **Quais ferramentas distribuidas?** Documentado publicamente em
  `docs/reference/MATRIZ_PUBLICO_VS_CLA.md`.
- **Quem pode auditar?** Qualquer pessoa pode ler regras, codigo,
  evidencias publicas. CLA so e necessario para **modificar** ou rodar
  a sincronizacao operacional.

## Compatibilidade com TPGL v1.1

O modelo e **compativel** com a licenca:

- TPGL v1.1 e source-available, nao OSI-aprovada — admite restricao
  operacional
- A clausula de auto-conversao para Apache 2.0 em 4 anos significa que
  esse modelo de acesso controlado **expira automaticamente** com a
  conversao
- Apos conversao, todo o `local-ai/` torna-se publico junto com o
  resto

## Como verificar (auditoria de cumprimento)

Antes de declarar release pronta:

1. Confirmar que `local-ai/` esta no `.gitignore`.
2. Confirmar que arquivos sensiveis nao foram commitados acidentalmente
   por `git add -f` ou similar.
3. Verificar headers "RESTRITO CLA" em cada arquivo de
   `local-ai/scripts/`.
4. Validar que nenhum codigo do produto (em `src/vba/`) referencia
   diretamente caminhos `local-ai/` em runtime — apenas em codigo de
   manutencao/import.

```bash
# Auditoria
grep -rE "local-ai/" src/vba/   # deve retornar zero (codigo do produto nao depende)
grep -E "^local-ai/" .gitignore  # deve retornar match
git ls-files local-ai/ | wc -l   # deve retornar 0 (nada commitado)
```

## Glasswing G9 (proposto, futuro)

A Onda 9 considera adicionar **G9 — segregacao publico/CLA respeitada**
ao Glasswing como vetor de Cybersegurança Preventiva contra IA:

> G9: Toda IA executora deve confirmar antes de gerar PR ou commit que
> nenhum arquivo CLA-controlado foi promovido a publico, e nenhuma
> dependencia de runtime do produto (`src/vba/`) foi introduzida em
> conteudo CLA-controlado.

Decisao de adicao do G9: Mauricio aprovara em uma onda futura apos
estabilizacao da V12.0.0203.

## Referencias

- [`docs/explanation/MODELO_DE_ACESSO_CONTROLADO.md`](../../docs/explanation/MODELO_DE_ACESSO_CONTROLADO.md) — explicacao Diataxis
- [`docs/how-to/COMO_OBTER_FERRAMENTAS_VBA.md`](../../docs/how-to/COMO_OBTER_FERRAMENTAS_VBA.md) — passo-a-passo do contribuidor
- [`docs/reference/MATRIZ_PUBLICO_VS_CLA.md`](../../docs/reference/MATRIZ_PUBLICO_VS_CLA.md) — matriz de classificacao
- [`CLA.md`](../../CLA.md) secao 7 — clausula formal
- [`CONTRIBUTING.md`](../../CONTRIBUTING.md) — fluxo recomendado
- [`usehbn/docs/INTEGRATION-CLA-CONTROLLED-ACCESS.md`](../../../usehbn/docs/INTEGRATION-CLA-CONTROLLED-ACCESS.md) — vitrine externa
