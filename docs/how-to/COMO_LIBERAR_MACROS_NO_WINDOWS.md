---
titulo: Como Liberar Macros no Windows
diataxis: how-to
hbn-track: safe_track
hbn-status: active
audiencia: humano
versao-sistema: V12.0.0204
data: 2026-05-12
---

# Como Liberar Macros no Windows

Use este guia antes de testar a planilha `.xlsm` baixada do GitHub ou recebida
por canal oficial. Ele cobre o caminho comum do Excel no Windows 10/11.

## Antes de abrir a planilha

1. Salve o arquivo `.xlsm` em uma pasta local, por exemplo `Documentos`.
2. Clique com o botão direito no arquivo.
3. Abra **Propriedades**.
4. Na aba **Geral**, procure a opção **Desbloquear**.
5. Marque **Desbloquear** e clique em **Aplicar**.
6. Feche a janela de propriedades.

Se a opção **Desbloquear** não aparecer, siga para a próxima etapa. Isso
significa que o Windows não marcou o arquivo como baixado da internet ou que a
marcação já foi removida.

## Ao abrir no Excel

1. Abra a planilha no Excel Desktop.
2. Se aparecer a barra amarela **Modo de Exibição Protegido**, clique em
   **Habilitar Edição**.
3. Se aparecer a barra amarela **Aviso de Segurança**, clique em
   **Habilitar Conteúdo**.
4. Aguarde a tela inicial do sistema abrir.
5. Clique em **Sobre** e confirme:
   - `Release oficial: V12.0.0204`
   - `Status oficial: VALIDADO`
   - `Build importado: f7aa84f+ONDA25.MD25.5-limpar-cad-serv-fix2`

## Quando o Excel bloquear macros mesmo assim

Se o Excel exibir mensagem informando que macros foram bloqueadas porque a
origem do arquivo não é confiável, feche a planilha e repita a etapa
**Antes de abrir a planilha**. O desbloqueio precisa ser feito no arquivo
fechado.

Se a organização usa política corporativa que bloqueia macros por GPO, solicite
ao administrador uma pasta confiável para homologação da planilha.

## Opcional para contribuidores: acesso ao modelo de objeto VBA

O testador humano que apenas abre a planilha e roda a bateria de validação não
precisa habilitar esta opção.

Habilite apenas se você for reimportar módulos VBA pelo Importador V3:

1. Excel > **Arquivo** > **Opções**.
2. **Central de Confiabilidade**.
3. **Configurações da Central de Confiabilidade**.
4. **Configurações de Macro**.
5. Marque **Confiar no acesso ao modelo de objeto do projeto VBA**.
6. Confirme e reabra a planilha.

## Confirmação rápida pela interface

Depois que a planilha abrir, clique em **Sobre**. A janela deve mostrar:

```text
Release oficial: V12.0.0204
Status oficial: VALIDADO
f7aa84f+ONDA25.MD25.5-limpar-cad-serv-fix2
```

Se a versão, o status ou o build forem diferentes, interrompa o teste e
registre a divergência.

O testador humano não precisa abrir o Editor VBA nem a Janela Imediata.
