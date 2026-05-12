---
titulo: MICRO57 — Guia Humano por Interface V204
diataxis: onda
hbn-track: safe_track
hbn-status: active
audiencia: ambos
versao-sistema: V12.0.0204
data: 2026-05-12
---

# MICRO57 — Guia Humano por Interface V204

## Objetivo

Corrigir a comunicacao publica da V12.0.0204 para testadores humanos externos.
A pessoa que recebe a planilha deve validar usando apenas a interface do Excel:
botao **Sobre**, botao **Central de Testes**, opcoes de menu e roteiro manual.

## Problema corrigido

MICRO56 criou guias V204, mas ainda deixava o caminho principal com referencias
a VBE, Janela Imediata e documentos V203/rc4. Isso era adequado para mantenedor,
mas inadequado para homologacao humana externa.

## Decisao

MICRO57 nao altera codigo. A V12.0.0204 permanece tecnicamente fechada. A
correcao e exclusivamente documental:

- caminho principal: interface;
- caminho de desenvolvedor: apenas historico ou material controlado;
- V203/rc4: arquivado;
- melhorias de Central de Testes: debito V205.

## Debito V205 registrado

A Central de Testes deve ser redesenhada para:

1. oferecer a validacao completa de release na primeira tela;
2. substituir "Sexteto/Quinteto/Quarteto" por nomes profissionais;
3. explicar cada bateria em linguagem humana;
4. remover conflito com "Gate oficial: Quarteto" na tela intermediaria;
5. orientar evidencias sem exigir Janela Imediata.
