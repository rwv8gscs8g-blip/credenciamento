# Contributor License Agreement (CLA)

Este repositório aceita contribuições públicas somente com aceite expresso
deste CLA.

## 1. Finalidade

O objetivo deste documento é permitir que correções, testes, documentação e
melhorias sejam incorporados ao projeto com segurança jurídica e rastreabilidade.

## 2. O que o contribuinte declara

Ao submeter uma contribuição, você declara que:

- é autor da contribuição, ou possui autorização suficiente para submetê-la
- a contribuição pode ser licenciada nos termos da [TPGL v1.1](LICENSE)
- a contribuição não viola direitos autorais, patente, segredo industrial,
  obrigação contratual ou dados sigilosos de terceiros
- a contribuição não inclui dados reais de municípios, empresas ou cidadãos sem
  autorização adequada

## 3. Direitos patrimoniais concedidos

No limite permitido pela Lei 9.610/98, o contribuinte concede ao licenciante,
de forma gratuita, não exclusiva, mundial, irretratável e por prazo legal de
proteção:

- direito de usar, copiar, modificar, adaptar, traduzir, combinar, distribuir,
  sublicenciar e relicenciar a contribuição
- direito de incorporar a contribuição a versões presentes e futuras do projeto
- direito de aplicar à contribuição a política de conversão automática da TPGL
  para Apache License 2.0 após a Data de Conversão de cada release

## 4. Direitos morais

Os direitos morais do autor permanecem preservados, inclusive atribuição e
integridade, na forma da legislação brasileira.

## 5. Licença de patente

Se a contribuição contiver matéria potencialmente patenteável, o contribuinte
concede licença gratuita, não exclusiva, mundial e irrevogável para uso da
contribuição nos termos do projeto, cessando apenas no caso de litigância
patentária ofensiva contra o próprio projeto.

## 6. Forma de aceite

O aceite deste CLA pode ocorrer por qualquer um dos meios abaixo, desde que
rastreáveis:

- envio de pull request com declaração expressa de aceite
- commit com linha `Signed-off-by: Nome Sobrenome <email>`
- aceite eletrônico documentado pelo mantenedor

Contribuições sem aceite rastreável poderão ser recusadas ou removidas do
histórico público.

## 7. Contribuições institucionais

Quando a contribuição vier de empresa, órgão público ou terceiro contratado,
o mantenedor poderá exigir instrumento complementar assinado pelo representante
legal da instituição. Modelo de instrumento em
[`docs/reference/legal/CLA_INSTITUCIONAL_TEMPLATE.md`](docs/reference/legal/CLA_INSTITUCIONAL_TEMPLATE.md).

## 8. Acesso a ferramentas operacionais (CLA-controlado)

Materiais operacionais complementares — incluindo o pacote de import
`local-ai/vba_import/`, ferramentas de sincronização e auditoria
`local-ai/scripts/` (publicar_vba_import_v2, glasswing-checks,
Importador V2 e instaladores), guia detalhado de importação do código-fonte,
exports do workbook e vídeo tutorial de incorporação — são fornecidos
por **canal controlado** após:

- aceite rastreável deste CLA conforme seção 6
- validação do enquadramento do solicitante como contribuinte ativo,
  município usuário, ou parceiro institucional autorizado pelo mantenedor

### 8.1 Modelo de distribuição vigente

A distribuição segue o **modelo B — release zip** (decidido em 29/04/2026
durante a Onda 9 antecipada da V12.0.0203):

- a cada release oficial, o mantenedor empacota `local-ai/` em arquivo
  zip cifrado
- o sha256 do zip é registrado internamente
- o link de download e a senha de descriptografia são enviados por
  canais separados ao solicitante CLA-validado

Detalhes do fluxo operacional em
[`docs/how-to/COMO_OBTER_FERRAMENTAS_VBA.md`](docs/how-to/COMO_OBTER_FERRAMENTAS_VBA.md).

### 8.2 Responsabilidades adicionais

Ao receber acesso ao ferramental CLA-controlado, o contribuinte
adicionalmente declara que:

- não republicará o pacote, scripts ou conteúdo recebido para terceiros
  sem CLA validado
- não modificará `local-ai/vba_import/` para gerar versão alternativa
  do produto distribuída como oficial
- não promoverá conteúdo CLA-controlado para áreas públicas do
  repositório (`git add -f` ou similar) sem aprovação explícita do
  mantenedor
- comunicará ao mantenedor caso identifique violação dessas regras por
  outros contribuintes

A violação destas obrigações pode resultar em revogação do acesso a
futuras releases, sem prejuízo de medidas legais cabíveis.

### 8.3 Auto-conversão TPGL → Apache 2.0

A restrição operacional desta seção 8 segue o calendário de
auto-conversão da [TPGL v1.1](LICENSE). Após a Data de Conversão de
cada release, todo o conteúdo da release torna-se publicado sob
Apache 2.0 sem restrições adicionais — incluindo o ferramental aqui
descrito.

A restrição operacional **expira automaticamente** com a conversão.

## 9. Lei aplicável

Este CLA segue a legislação brasileira e deve ser lido em conjunto com a
[TPGL v1.1](LICENSE).
