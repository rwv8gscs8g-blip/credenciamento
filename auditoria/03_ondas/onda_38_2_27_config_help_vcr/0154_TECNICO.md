---
titulo: Onda 38.2.27 - Configuracoes Iniciais, Ajuda HBN e VCR
diataxis: onda
hbn-track: safe_track
hbn-status: active
audiencia: ambos
versao-sistema: V12.0.0205
data: 2026-06-06
---

# Onda 38.2.27 - Configuracoes Iniciais, Ajuda HBN e VCR

## Objetivo

Iniciar a validacao tela a tela pela tela **Configuracoes Iniciais**, corrigir
o campo de dias por recusa/prazo que podia aparecer travado, documentar a tela
em ajuda HBN simples e padronizar o nome operacional do gate completo como
**Validacao Completa da Release (VCR)**.

## Decisoes

- VCR passa a ser o nome operacional da validacao completa.
- `.csv` permanece apenas como formato de arquivo de evidencia.
- Macros antigas como `CT_ValidarRelease_SextetoMinimo` ficam preservadas por
  compatibilidade ate uma refatoracao controlada.
- A Central de Testes chama o novo alias `CT_ValidarRelease_Completa`.
- O campo tecnico legado `TxtMesesSuspensao` continua no `.frx`, mas a
  semantica oficial e dias de suspensao por recusa/prazo.
- O botao Ajuda da tela abre `docs/help/hbn/configuracoes-iniciais.html`.

## Alteracoes de Codigo

| Arquivo | Alteracao |
|---|---|
| `src/vba/Configuracao_Inicial.frm` | Forca o campo de dias por recusa/prazo para editavel em runtime; adiciona abertura da ajuda HBN pelo botao Ajuda. |
| `src/vba/Teste_V2_Roteiros.bas` | Adiciona `TV2_RunTelaConfiguracoesIniciais` com 3 asserts: editabilidade, persistencia e ajuda disponivel. |
| `src/vba/Teste_Validacao_Release.bas` | Troca mensagens publicas para VCR; exporta evidencia `ValidacaoReleaseVCR_*.csv`; adiciona aliases VCR. |
| `src/vba/Central_Testes.bas` | Mostra VCR como validacao oficial e chama `CT_ValidarRelease_Completa`. |
| `src/vba/App_Release.bas` | Atualiza build para `293e44c+ONDA38.2.27-CONFIG-HELP-VCR`. |

## Documentacao

| Arquivo | Funcao |
|---|---|
| `docs/reference/testes/GUIA_DE_TESTES_E_VALIDACAO.md` | Padroniza nomes profissionais dos testes e cadencia incremental. |
| `docs/tutorials/MANUAL_OPERACIONAL_TELA_A_TELA.md` | Inicia manual operacional pela tela Configuracoes Iniciais. |
| `docs/help/hbn/index.html` | Entrada simples da ajuda HBN. |
| `docs/help/hbn/configuracoes-iniciais.html` | Ajuda HTML da tela Configuracoes Iniciais. |

## Pacote de Importacao

Manifesto:

`local-ai/vba_import/000-MANIFESTO-V3-DELTA-ONDA38_2_27_CONFIG_HELP_VCR.txt`

Comando:

```text
ImportarPacoteV3_Delta "ONDA38_2_27_CONFIG_HELP_VCR", "293e44c+ONDA38.2.27-CONFIG-HELP-VCR"
```

Esperado:

- Importador V3: `M=4 | F=1 | err=0 | skip=0`.
- Compile VBE limpo.
- `TV2_RunTelaConfiguracoesIniciais`: `OK=3 | FALHA=0 | MANUAL=0`.

## Observacao Sobre Cadencia de Testes

A VCR completa passou a demorar mais de uma hora no fluxo observado. Para a
validacao tela a tela, a cadencia correta e:

1. importar;
2. compilar;
3. executar teste dirigido da tela;
4. executar smoke quando a mudanca tocar codigo compartilhado;
5. reservar VCR para checkpoint forte.

Isso reduz tempo de iteracao sem abrir mao da validacao completa antes de
mudanca de fase.
