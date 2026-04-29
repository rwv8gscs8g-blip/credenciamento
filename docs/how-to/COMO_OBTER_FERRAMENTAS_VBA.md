---
titulo: Como obter as ferramentas avancadas de import VBA (CLA-controlado)
diataxis: how-to
audiencia: contribuidor potencial ou municipio usuario
hbn-track: fast_track
versao-sistema: V12.0.0203
data: 2026-04-29
---

# Como obter as ferramentas avancadas de import VBA

> **Pre-requisito:** voce precisa ter assinado o
> [CLA.md](../../CLA.md). Sem CLA assinado e validado, este fluxo nao
> se aplica — voce ainda pode auditar o codigo publico, mas nao tem
> acesso ao ferramental operacional.

## Quando voce precisa deste fluxo

- Voce e desenvolvedor que vai contribuir com codigo VBA do projeto
- Voce e integrador municipal que vai aplicar updates oficiais
- Voce e mantenedor parceiro que precisa rodar a bateria oficial
- Voce ja audita o codigo publico mas precisa rodar testes localmente

## Quando voce **nao** precisa deste fluxo

- Voce so quer **usar** o sistema de credenciamento — pegue o `.xlsm`
  oficial direto da prefeitura usuaria, nao do GitHub
- Voce so quer **auditar** o codigo — clone o repo publico, esta tudo
  visivel em `src/vba/`, `auditoria/`, `docs/`, `obsidian-vault/`
- Voce e contribuidor de docs/textos apenas — abra PR direto no
  GitHub, sem precisar das ferramentas

## Passo 1 — Aceitar o CLA

Escolha uma das 3 vias rastreaveis (ver
[`CLA.md`](../../CLA.md) secao 6):

| Via | Como fazer | Para quem |
|---|---|---|
| Pull request com declaracao | abra PR no GitHub publico com texto "Aceito o CLA do Credenciamento conforme `CLA.md`" + assinatura | contribuidor publico individual |
| `Signed-off-by` em commit | use `git commit -s` ou inclua manualmente `Signed-off-by: Nome <email>` em cada commit | contribuidor com fluxo git formal |
| Aceite eletronico ao mantenedor | envie email para Mauricio Zanin com declaracao + identificacao | contribuidor institucional ou municipio |

Para **contribuicao institucional** (empresa, orgao publico, terceiro
contratado), o mantenedor pode exigir instrumento complementar
assinado pelo representante legal — ver
[`docs/reference/legal/CLA_INSTITUCIONAL_TEMPLATE.md`](../reference/legal/CLA_INSTITUCIONAL_TEMPLATE.md).

## Passo 2 — Solicitar acesso ao ferramental

Apos aceite rastreavel registrado, solicite ao mantenedor acesso ao
release zip mais recente. Inclua:

- nome completo
- email rastreavel
- referencia ao CLA (numero do PR, sha do commit com Signed-off-by, ou
  data do email de aceite)
- versao desejada (default: ultima release oficial, ex: V12.0.0203)
- finalidade pratica (contribuicao especifica, integracao municipal,
  auditoria avancada, etc.)

O mantenedor valida o enquadramento e envia:

- link unico para download do `credenciamento-tooling-v<versao>.zip`
  cifrado
- senha de descriptografia (canal separado)
- sha256 esperado do zip

## Passo 3 — Verificar integridade do zip

Apos baixar o zip, **antes de descompactar**:

```
shasum -a 256 credenciamento-tooling-v12.0.0203.zip
```

Compare com o sha256 informado pelo mantenedor. Se nao bater, **NAO
descompacte** — relate ao mantenedor.

## Passo 4 — Descompactar em local-ai/

Voce ja tem clone do repo publico:

```
git clone https://github.com/<...>/Credenciamento.git
cd Credenciamento
```

Descompacte o zip em `local-ai/` (que esta no `.gitignore`):

```
unzip -P "<senha>" credenciamento-tooling-v12.0.0203.zip -d ./
```

Apos descompactar, voce deve ter:

```
local-ai/
├── vba_import/        # pacote operacional de import
├── scripts/           # ferramentas Bash/Python
└── README.md          # instrucoes operacionais
```

## Passo 5 — Validar instalacao

Rode a auditoria Glasswing:

```
bash local-ai/scripts/glasswing-checks.sh
```

Esperado: tabela com 8 vetores G1-G8 mostrando OK/WARN/MANUAL/VIOLATED.
Se qualquer VIOLATED aparecer no estado clean, contate o mantenedor.

Rode a sincronizacao em modo check:

```
bash local-ai/scripts/publicar_vba_import_v2.sh --check
```

Esperado: "Glasswing G7 — vba_import sincronizado: OK".

## Passo 6 — Instalar git pre-commit hook (opcional, recomendado)

Para evitar regressao da Regra de Ouro:

```
bash local-ai/scripts/install-git-hooks.sh
```

A partir daqui, todo `git commit` valida G7 + G8 antes de aceitar.

## Passo 7 — Importar o pacote VBA no workbook

Abra o `.xlsm` em homologacao no Excel + Alt+F11 para o VBE:

1. Importe `local-ai/scripts/Importador_V2.bas` (uma vez por workbook).
2. No Immediate (`Ctrl+G`), execute:
   ```
   Call ImportarPacoteV2_DryRun
   ```
   Confirma o que seria importado sem alterar.
3. Se OK, execute:
   ```
   Call ImportarPacoteV2
   ```
   Importa o pacote completo + valida compilacao por grupo.
4. Salve workbook + rode trio minimo (`CT_ValidarRelease_TrioMinimo`).

Detalhes em
[`docs/reference/MANIFESTO_FORMAT.md`](../reference/MANIFESTO_FORMAT.md)
e em `local-ai/scripts/README.md` (vem no zip).

## Atualizar para uma nova release

Quando V12.0.0204 (ou superior) for liberada:

1. Solicite ao mantenedor o novo zip (mesmo procedimento do passo 2).
2. Apague `local-ai/` antigo.
3. Descompacte o novo zip.
4. Repita validacao (passo 5).
5. Reimporte pacote (passo 7).

## Encerrar acesso

Voce pode renunciar ao acesso a qualquer momento simplesmente apagando
`local-ai/` localmente. Isso nao revoga seu CLA — ele continua
valido. Para revogar acesso a futuras releases, contate o mantenedor.

## O que voce nao deve fazer

| Acao proibida | Por que |
|---|---|
| Republicar o zip cifrado para terceiros sem CLA | viola o CLA — risco juridico |
| Modificar `local-ai/vba_import/` e distribuir como se fosse oficial | quebra Regra de Ouro do pacote |
| Commitar arquivos de `local-ai/` no git publico (`git add -f`) | quebra modelo de acesso controlado |
| Usar as ferramentas para gerar pacote alternativo do produto | viola integridade operacional |

## Referencias

- [`CLA.md`](../../CLA.md) — texto formal completo
- [`CONTRIBUTING.md`](../../CONTRIBUTING.md) — fluxo recomendado
- [Por que existe esse modelo (explanation)](../explanation/MODELO_DE_ACESSO_CONTROLADO.md)
- [Matriz publico vs CLA (reference)](../reference/MATRIZ_PUBLICO_VS_CLA.md)
- [Protocolo HBN-native (.hbn/knowledge/0007)](../../.hbn/knowledge/0007-acesso-controlado-via-cla.md)
- Email do mantenedor: ver `obsidian-vault/00-DASHBOARD.md` ou abra issue publica
