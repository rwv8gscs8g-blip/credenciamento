# Impressao e Formatacao de Relatorios

Status: BACKLOG
Releases: V12.0.0116+
Relacionado: [[Fluxos-de-Negocio]], [[Formularios]]

---

## Objetivo

Formatar as abas de relatorio (RELATORIO, RPT_ROTEIRO, RPT_BATERIA) para impressao profissional com cabecalho institucional, logo do municipio e layout adequado para A4.

## Abas de Relatorio

- RELATORIO: relatorio principal por empresa/entidade/servico
- RPT_ROTEIRO: relatorio do roteiro rapido de testes
- RPT_BATERIA: relatorio da bateria oficial de testes

## Requisitos

1. Cabecalho com logo do municipio (campo CAM_LOGO da aba CONFIG)
2. Nome do gestor e municipio
3. Data de emissao
4. Formatacao para impressao A4 paisagem
5. Auto-filtro mantido para interatividade
6. Quebra de pagina logica

## Recurso Disponivel

O prompt de formatacao esta em `ai-context/PROMPT_CLAUDE_OPUS_EXCEL_RELATORIOS_V12.md` — pode ser usado diretamente no Claude Opus in Excel para aplicar formatacao visual sem modificar codigo VBA.

## Risco

BAIXO — formatacao de abas nao afeta compilacao VBA. Pode ser feita em paralelo com outras iteracoes se necessario.
