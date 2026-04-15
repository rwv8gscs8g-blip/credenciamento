# Regras de Governanca do Projeto

Relacionado: [[Compilacao-VBA]], [[Anti-Regressao]], [[Checklist-Pre-Deploy]]

---

## Principios Fundamentais

1. **Um change-set coeso por iteracao.** Cada release deve modificar apenas um conjunto arquiteturalmente coeso e de baixo raio de impacto. Em geral: 1 arquivo funcional principal, 1 arquivo de metadata de release, release note e artefatos gerados de importacao. Mudancas fora desse conjunto exigem justificativa escrita.

2. **Compilacao obrigatoria.** Nenhuma release e publicada sem confirmacao de que Depurar > Compilar VBAProject retorna sucesso.

3. **Backup antes de qualquer mudanca.** Copiar o .xlsm atual para a pasta `historico/` antes de importar modulos modificados.

4. **Release note obrigatoria.** Toda mudanca de codigo gera uma release note em `obsidian-vault/releases/V12.0.XXXX.md` seguindo o template.

5. **Fonte de verdade e vba_export/.** Nunca editar codigo diretamente no VBA Editor sem exportar de volta para vba_export/. O VBA Editor e ambiente de teste, vba_export/ e o repositorio.

6. **Tag final so apos compilacao.** Uma release pode ter multiplos commits locais durante a preparacao, mas a tag final `v12.0.XXXX` so e criada apos `Depurar > Compilar VBAProject` com sucesso.

---

## Regras para IAs

7. **Nunca renomear VB_Name.** O Attribute VB_Name de um modulo nao pode ser alterado sem teste isolado de compilacao. Historico: renomear AppContext para Mod_AppContext causou 3 meses de erro cascata.

8. **Nunca remover funcoes/subs/types Public.** Outros modulos e formularios podem depender deles. Remocao causa erros em cascata em tempo de compilacao.

9. **Manter chamadas qualificadas.** Sempre usar `Modulo.Procedimento` (ex: `Util_Config.GetConfig`). IAs anteriores removeram qualificacao causando ciclo de regressao de 11 iteracoes.

10. **Ler CONTEXTO-IA.md antes de qualquer acao.** Este documento e o ponto de entrada obrigatorio para qualquer IA que assuma o projeto.

11. **Nunca pedir reimportacao sem diagnostico.** Se houver erro de compilacao, primeiro identificar o modulo e a linha exatos, depois corrigir no vba_export/, so entao reimportar.

12. **Modulos de teste sao descartaveis para debug.** Se o core nao compilar, remover temporariamente: Central_Testes, Central_Testes_Relatorio, Teste_Bateria_Oficial, Teste_UI_Guiado, Treinamento_Painel.

---

## Numeracao de Versoes

- Formato: V12.0.XXXX (quatro digitos sequenciais)
- V12.0.0107 = base estavel inaugural do novo ciclo
- Incremento de 1 por iteracao aprovada
- O proximo numero pode existir localmente como candidata, mas so recebe tag final/publicacao apos compilacao bem-sucedida

---

## Pipeline de Release

1. **Candidata**
   - Editar `vba_export/`
   - Rodar checklist local
   - Regenerar `vba_import/`
   - Atualizar release note/documentacao aplicavel
2. **Compilada**
   - Importar no Excel
   - Rodar `Depurar > Compilar VBAProject`
   - Se falhar, corrigir e repetir; nao publicar
3. **Publicada**
   - Commit final da release
   - Tag `v12.0.XXXX`
   - `git push origin main --tags`

---

## Estrutura de Pastas

```
Credenciamento/
├── PlanilhaCredenciamento-Homologacao.xlsm   <- PLANILHA ATIVA
├── vba_export/                                <- FONTE DE VERDADE
├── vba_import/                                <- Pacote de deploy (gerado)
├── scripts/                                   <- Ferramentas
├── obsidian-vault/                            <- TODA documentacao
├── cnae_servicos_normalizado.csv              <- Base CNAE
├── V12-093/                                   <- Backup da base estavel
└── historico/                                 <- Versoes antigas
```
