---
titulo: Jornada de Validação Humana V205
diataxis: tutorial
hbn-track: safe_track
hbn-status: active
audiencia: humano
versao-sistema: V12.0.0205
data: 2026-05-21
---

# Jornada de Validação Humana — V12.0.0205

Este tutorial guia um operador ou auditor pela validação da planilha sem usar o
Visual Basic Editor.

## 1. Preparar o Ambiente

1. Feche outras instâncias do Excel.
2. Abra `PlanilhaCredenciamento-Homologacao-V4.xlsm`.
3. Habilite macros quando o Excel solicitar.
4. Confirme que está usando o pacote da V12.0.0205.

## 2. Confirmar a Identidade da Versão

Na tela principal, abra a janela **Sobre** e confirme:

- versão `V12.0.0205`;
- status `VALIDADO`;
- build e tag compatíveis com o dossiê da release.

## 3. Executar o Gate RVS

1. Abra a **Central de Testes**.
2. Escolha `[1] Gate de Validação de Release (RVS)`.
3. Aguarde a conclusão da execução.
4. Não interrompa a planilha durante o teste.

## 4. Ler o Resultado

O resultado aprovado deve conter:

```text
V1=171/0+V2_Smoke=34/0+V2_Canonica=24/0+E2E_Strikes=76/0+IntegridadeBase=4/0+Onda23Adv=27/0
```

Se houver falha, capture print, registre a mensagem e classifique o incidente
como P0/P1/P2/P3.

## 5. Coletar Evidências

- CSV automático em `auditoria/evidencias/V12.0.0205/csv/`.
- Print da tela/aba `VALIDACAO_RELEASE` em `auditoria/evidencias/V12.0.0205/prints/`.
- PDF manual da aba `VALIDACAO_RELEASE` em `auditoria/evidencias/V12.0.0205/pdf/`.

## 6. Gerar PDF Manual

1. Abra a aba `VALIDACAO_RELEASE`.
2. Use `Arquivo > Exportar > Criar PDF/XPS`.
3. Salve em `auditoria/evidencias/V12.0.0205/pdf/`.
4. Abra o PDF e confirme que não há corte visual.
5. Gere e registre o `sha256`.

## 7. Checklist de Aceite

- [ ] Versão e build conferidos na janela Sobre.
- [ ] RVS executado e aprovado.
- [ ] Sintaxe funcional idêntica à V204.
- [ ] CSV V205 gerado.
- [ ] PDF manual gerado e legível.
- [ ] Print salvo.
- [ ] Manifesto atualizado com hashes.
- [ ] Veredito humano preenchido.
