---
titulo: Como Liberar Macros no Windows
diataxis: how-to
hbn-track: safe_track
hbn-status: active
audiencia: humano
versao-sistema: V12.0.0204
data: 2026-05-11
---

# Como Liberar Macros no Windows

Use este guia antes de testar a planilha `.xlsm` baixada do GitHub ou recebida
por canal oficial. Ele cobre o caminho comum do Excel no Windows 10/11.

## Antes de abrir a planilha

1. Salve o arquivo `.xlsm` em uma pasta local, por exemplo `Documentos`.
2. Clique com o botao direito no arquivo.
3. Abra **Propriedades**.
4. Na aba **Geral**, procure a opcao **Desbloquear**.
5. Marque **Desbloquear** e clique em **Aplicar**.
6. Feche a janela de propriedades.

Se a opcao **Desbloquear** nao aparecer, siga para a proxima etapa. Isso
significa que o Windows nao marcou o arquivo como baixado da internet ou que a
marcacao ja foi removida.

## Ao abrir no Excel

1. Abra a planilha no Excel Desktop.
2. Se aparecer a barra amarela **Modo de Exibicao Protegido**, clique em
   **Habilitar Edicao**.
3. Se aparecer a barra amarela **Aviso de Seguranca**, clique em
   **Habilitar Conteudo**.
4. Aguarde a tela inicial do sistema abrir.
5. Clique em **Sobre** e confirme:
   - `Release oficial: V12.0.0204`
   - `Status oficial: VALIDADO`
   - `Build importado: f7aa84f+ONDA25.MD25.5-limpar-cad-serv-fix2`

## Quando o Excel bloquear macros mesmo assim

Se o Excel exibir mensagem informando que macros foram bloqueadas porque a
origem do arquivo nao e confiavel, feche a planilha e repita a etapa
**Antes de abrir a planilha**. O desbloqueio precisa ser feito no arquivo
fechado.

Se a organizacao usa politica corporativa que bloqueia macros por GPO, solicite
ao administrador uma pasta confiavel para homologacao da planilha.

## Opcional para contribuidores: acesso ao modelo de objeto VBA

O testador humano que apenas abre a planilha e roda a bateria de validacao nao
precisa habilitar esta opcao.

Habilite apenas se voce for reimportar modulos VBA pelo Importador V3:

1. Excel > **Arquivo** > **Opcoes**.
2. **Central de Confiabilidade**.
3. **Configuracoes da Central de Confiabilidade**.
4. **Configuracoes de Macro**.
5. Marque **Confiar no acesso ao modelo de objeto do projeto VBA**.
6. Confirme e reabra a planilha.

## Confirmacao rapida pela interface

Depois que a planilha abrir, clique em **Sobre**. A janela deve mostrar:

```text
Release oficial: V12.0.0204
Status oficial: VALIDADO
f7aa84f+ONDA25.MD25.5-limpar-cad-serv-fix2
```

Se a versao, o status ou o build forem diferentes, interrompa o teste e
registre a divergencia.

O testador humano nao precisa abrir o Editor VBA nem a Janela Imediata.
