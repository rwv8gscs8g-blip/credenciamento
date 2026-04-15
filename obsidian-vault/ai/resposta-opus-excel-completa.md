Execute as alteracoes abaixo na planilha. Sao ajustes diretos em celulas e formatacao de abas de impressao (IMP_AVALIA, EMITE_PREOS, EMITE_OS). Nenhuma destas abas e recriada por VBA, portanto as mudancas sao permanentes.

---

## PARTE A — Correcoes diretas na planilha

### A1. IMP_AVALIA — Nota Total (N37)
Adicione a formula `=IFERROR(AVERAGE(N27:N36),"")` em IMP_AVALIA!N37.
Formate a celula como `#,##0.0` (uma casa decimal).

### A2. IMP_AVALIA — Segunda assinatura (H47)
Altere IMP_AVALIA!H47 de "ASSINATURA DO DEMANDANTE" para "ASSINATURA DO PRESTADOR DE SERVICOS".

### A3. IMP_AVALIA — Empenho (D37)
Verifique se D37 aceita texto. Se estiver com formato numerico, altere para formato Texto (@).

### A4. EMITE_PREOS — Data (N4)
Formate EMITE_PREOS!N4 como `DD/MM/YYYY`. Se o valor atual for um serial (ex: 44531), a formatacao vai resolver.

### A5. EMITE_PREOS — Bordas nos campos vazios
Adicione bordas finas (bottom border, cinza claro) nas celulas de resposta dos campos: Empresa, Endereco, Telefone, e-mail. Assim mesmo vazias, as linhas ficam visiveis no PDF.

### A6. EMITE_OS — Verificar formula da media (N84)
Confirme que EMITE_OS!N84 tem `=IFERROR(AVERAGE(N74:N83),"")`. Se ja existe, OK. Se nao, adicione.

---

## PARTE B — INFORMATIVA (ja resolvida no VBA V12.0.0148)

Nao precisa alterar nada aqui. Estas correcoes ja foram aplicadas nos modulos VBA:

1. **Svc_Avaliacao.bas** — `AvancarFila` apos avaliacao concluida (corrige rodizio travado)
2. **Menu_Principal.frm** — `media = mediaLocal` (corrige Nota Total vazia no relatorio)
3. **Menu_Principal.frm** — `ChrW(211)` em vez de `Chr(211)` (corrige mojibake PROVISORIA)
4. **Central_Testes_Relatorio.bas** — `ChrW(8212)` em vez de `Chr(8212)` (corrige Erro 5)
5. **Teste_Bateria_Oficial.bas** — Dashboard RESULTADO_QA com cabecalho, botoes, contadores congelados, coloracao por status, AutoFilter e resumo no rodape

---

## ORDEM DE EXECUCAO

1. Execute os itens A1 a A6 na ordem
2. Salve a planilha
3. Informe quais itens foram aplicados e se houve alguma observacao
