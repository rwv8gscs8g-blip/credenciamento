# Política de Segurança

## Escopo

Este repositório publica código-fonte VBA, auditoria, testes e documentação da
linha oficial do sistema. Vulnerabilidades aceitas neste canal incluem:

- falhas de integridade do fluxo de negócio
- exposição indevida de segredos ou parâmetros sensíveis no repositório público
- bypass de validações relevantes em `Svc_*`, `Repo_*` ou formulários
- inconsistências que permitam corrupção de dados entre abas operacionais

Ficam fora do escopo:

- a proteção nativa de planilhas Excel como mecanismo criptográfico
- ambientes locais de terceiros
- fluxos operacionais locais ou automações não publicadas

## Como reportar

O canal preferencial é o mecanismo privado de vulnerabilidades do próprio
GitHub, quando habilitado para este repositório.

Se esse mecanismo não estiver disponível, não publique detalhes técnicos em
issues abertas. Use o canal de contato institucional dos mantenedores indicado
na página principal do repositório ou solicite redirecionamento privado por
meio dos mantenedores.

## SLA

- triagem inicial: até 7 dias corridos
- confirmação de recebimento: até 7 dias corridos
- plano de correção ou mitigação: até 30 dias corridos
- correção ou resposta final: alvo de até 90 dias corridos

Casos críticos podem receber tratamento acelerado.

## Senha de proteção das abas

O projeto utiliza um helper centralizado para preparar e restaurar a proteção
de abas. O valor não deve aparecer em texto literal no repositório público.

Essa proteção existe como barreira operacional e de integridade de uso do
workbook. Ela não deve ser tratada como mecanismo criptográfico ou controle de
segurança forte.

## Divulgação coordenada

Pedimos que vulnerabilidades não sejam divulgadas publicamente antes de:

- confirmação de recebimento pela manutenção
- avaliação do impacto
- publicação de correção ou mitigação acordada
