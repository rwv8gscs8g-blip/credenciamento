# 17. Parecer Técnico-Jurídico — Licença TPGL v1.1

**Objeto:** Análise crítica da TPGL v1.0 e proposição da TPGL v1.1 como licença customizada inspirada na Business Source License 1.1 (BSL), aplicável ao Sistema de Credenciamento e Rodízio (V12.0.0202).
**Natureza:** insumo técnico-jurídico preliminar para homologação humana.
**Data:** 2026-04-19.
**Disclaimer:** Este documento não constitui aconselhamento jurídico formal. A versão final da licença deve ser homologada por advogado(a) brasileiro(a) com prática em propriedade intelectual antes de uso institucional.

---

## Sumário

1. Escopo e metodologia
2. Análise crítica cláusula a cláusula da TPGL v1.0
3. Compatibilidade com o ordenamento jurídico brasileiro
4. Comparativo com MIT, Apache 2.0, GPL/AGPL, BSL 1.1, SSPL
5. Análise dos pontos críticos solicitados
6. Riscos práticos
7. Recomendações objetivas
8. Versão final proposta — TPGL v1.1 (texto integral)
9. Justificativa técnica e jurídica
10. Próximos passos e roteiro de homologação

---

## 1. Escopo e metodologia

A análise foi conduzida em quatro eixos:

(i) **Coerência interna do texto.** Avaliação cláusula a cláusula: precisão das definições, hierarquia entre permissões e restrições, presença de gatilhos vagos passíveis de litígio.

(ii) **Conformidade com o direito brasileiro.** Confronto com Lei 9.609/98 (Lei de Software), Lei 9.610/98 (Direitos Autorais), Lei 12.527/11 (LAI), Lei 13.709/18 (LGPD), Lei 14.133/21 (Nova Lei de Licitações), e princípios constitucionais de publicidade e moralidade aplicáveis ao setor público.

(iii) **Comparação com modelos consagrados.** MIT, Apache 2.0, GPL v3, AGPL v3, BSL 1.1, SSPL.

(iv) **Adequação ao caso de uso GovTech.** Equilíbrio entre transparência exigida por órgãos de controle, sustentabilidade econômica do mantenedor e prevenção de exploração indevida.

A premissa do parecer é de que o objetivo do mantenedor é legítimo: viabilizar SaaS comercial sustentável sobre núcleo aberto à auditoria pública, sem permitir clones competitivos diretos. A TPGL v1.0 expressa essa intenção, mas com debilidades materiais que comprometem a robustez jurídica e a aceitação por entes públicos.

---

## 2. Análise crítica cláusula a cláusula da TPGL v1.0

### 2.1 Visão geral

A TPGL v1.0 tem o **conceito correto** (modelo BSL com Change Date e Change License) mas sofre de cinco classes de problema:

1. **Definições amplas e subjetivas** (especialmente "Uso Comercial", "Uso Concorrente", "vantagem econômica indireta") — cada uma destas expressões é um vetor de litígio.
2. **Ausência do mecanismo central da BSL** ("Additional Use Grant") — a BSL 1.1 funciona porque define **o que É permitido em produção**; a TPGL v1.0 lista o que é proibido sem esclarecer o positivo.
3. **Inconsistência com a publicação concreta do projeto** — o repositório público (`README.md` declara "código-fonte aberto e auditável no GitHub"), enquanto a cláusula 5 prevê "repositório privado" e "acesso controlado". Os dois discursos colidem.
4. **Lacunas técnicas obrigatórias** — falta concessão de patente, falta versionamento por release, falta período de cura na rescisão, falta foro, falta tratamento de marca de forma operacional, falta disposição sobre dados pessoais (LGPD).
5. **Change Date de 10 anos** — desproporcional ao padrão BSL (4 anos como teto recomendado pelo próprio mantenedor da BSL). Compromete adesão e narrativa de "abertura futura".

### 2.2 Análise detalhada por cláusula

#### Cabeçalho e nome

- **Problema:** O nome "Public Governance License" sugere licença pública/aberta. A licença, contudo, **não é open source** (a própria cláusula 6 reconhece isto). O nome induz a erro o leitor.
- **Risco:** Falsa apresentação pode (a) atrair críticas reputacionais quando a comunidade open source perceber a divergência; (b) gerar confusão em servidores públicos que assumem licença aberta sem ler.
- **Correção sugerida:** manter apenas TPGL, com subtítulo explícito "source-available, not open source", em destaque no preâmbulo.

#### Cláusula 1 — Definições

| Termo | Problema | Risco | Correção |
|---|---|---|---|
| "Software" | Inclui "estruturas de dados" e "documentação". Até aqui ok. Mas não distingue versão. | A BSL aplica-se **por release**; a TPGL aplica-se ao "sistema" abstratamente. Cada release deve ter sua própria Change Date. | Definir "Software" como o código-fonte e artefatos da release X identificada por SHA do commit, com Change Date contado a partir da publicação da release. |
| "Uso" | "copiar, modificar, executar, distribuir ou acessar" | "Acessar" é ambíguo — leitura de código no GitHub é "acesso"? | Distinguir entre `Acesso para Inspeção`, `Uso Interno`, `Uso em Produção`, `Distribuição`. |
| "Uso Comercial" | Inclui "vantagem econômica direta ou indireta" | Vantagem indireta é expressão caça-níquel. Município que ganha eficiência administrativa tem "vantagem econômica indireta" — isso poderia ser argumento para excluir o caso de uso central. | Definir Uso Comercial como **prestação paga a terceiros** com base no Software; permitir explicitamente uso interno do município mesmo que gere economia indireta. |
| "Uso Concorrente" | "reproduza funcionalidades principais", "concorra direta ou indiretamente" | Subjetivo. Demanda peritagem em caso de litígio. | Adotar a técnica BSL: definir uma lista positiva de "Usos Permitidos em Produção" (Additional Use Grant) e tratar tudo o que excede esse Grant como Uso Restrito. Evita o termo "concorrente". |
| "Órgãos Autorizados" | "Outros órgãos públicos formalmente reconhecidos" | "Formalmente reconhecidos" por quem? Pelo Licenciante? Vira veto unilateral. | Especificar critérios objetivos: órgãos da administração pública direta ou indireta, nos três níveis federativos, no exercício de competência legal relacionada a contratações/credenciamento. |
| "Data de Conversão" | 10 anos | Padrão BSL é 4 anos (teto recomendado pelo próprio MariaDB, criador da BSL). 10 anos pode ser visto como desproporcional. | Reduzir para 4 anos (alinhado à BSL) ou no máximo 5 anos. Justificar a escolha no preâmbulo. |

#### Cláusula 2 — Concessão de direitos

- **Problema 1:** Diz "revogável". Licença **revogável a qualquer tempo, *ad nutum***, é juridicamente frágil. No direito brasileiro, contratos com traços de adesão e desequilíbrio de poder podem ser questionados quando preveem revogação unilateral sem justa causa (CC art. 421, art. 422 — boa-fé objetiva).
- **Problema 2:** Item (e) "executar em ambiente interno, desde que sem exploração comercial" — mas item (f) permite "compartilhar exclusivamente com Órgãos Autorizados". Não esclarece se o Órgão Autorizado precisa aceitar a TPGL para usar o código recebido (cadeia de aceite).
- **Problema 3:** Não distingue entre "uso para auditoria" (read-only) e "uso operacional".
- **Correção:** Substituir "revogável" por "rescindível mediante violação com período de cura"; tornar concessão perpétua para usos permitidos; deixar claro que cada subdistribuição a Órgão Autorizado opera sob a mesma TPGL (inheritance da licença, ao estilo Apache 2.0).

#### Cláusula 3 — Uso permitido em produção

- **Problema central:** Item (b) "Não houver cobrança direta ou indireta pelo uso do Software". Municípios cobram **taxas de fiscalização** e **emolumentos** ligados a serviços públicos; o sistema participa da cadeia. Cobrança direta talvez não; indireta certamente sim, dependendo da interpretação. **Esta cláusula, lida literalmente, inviabiliza o caso de uso central.**
- **Risco:** TCE pode apontar incompatibilidade entre o sistema e a cobrança administrativa que ele suporta. Município pode preferir não adotar para evitar discussão.
- **Correção:** Substituir por "não houver cobrança pelo Software como produto" — o município pode cobrar pelo serviço público que o Software ajuda a operar, mas não pode cobrar terceiros pelo Software em si. Esta é a distinção clássica BSL entre "use for your business" (permitido) e "offer as a service" (restrito).

#### Cláusula 4 — Restrições (cláusula que o Licenciante pediu para preservar)

Esta é a cláusula central de defesa do modelo de negócio. Será **preservada em essência** na v1.1, mas com três ajustes obrigatórios:

| Item | Problema | Ajuste |
|---|---|---|
| (a) "criar, operar ou oferecer serviço concorrente" | "Concorrente" indefinido | Trocar por: "oferecer a terceiros, mediante pagamento ou contrapartida econômica, serviço que tenha o Software como componente material" |
| (b) "oferecer como SaaS, PaaS ou similar" | OK conceitualmente | Acrescentar "ou qualquer modelo `as-a-Service`, hospedado ou não" |
| (c) "Comercializar, sublicenciar ou revender" | OK | Manter |
| (d) "Utilizar como base para produto concorrente" | "Concorrente" novamente vago | Trocar por: "Utilizar para criar produto que substitua, total ou parcialmente, o Software ou suas funcionalidades nucleares, com finalidade comercial" |
| (e) "Distribuir o Software para terceiros não autorizados" | OK, mas precisa definir o que torna alguém autorizado | Cross-ref a Órgãos Autorizados redefinidos |
| (f) "Remover avisos de copyright ou licença" | OK | Manter |
| (g) "Utilizar para prestação de serviços comerciais a terceiros" | Redunda com (a) | Consolidar com (a) para evitar interpretações conflitantes |

**Adição obrigatória:** cláusula 4-bis com "Additional Use Grant" positivo — define o que **é** permitido em produção mesmo dentro do escopo restritivo. Sem isso, a cláusula 4 isolada gera insegurança máxima.

#### Cláusula 5 — Acesso ao código-fonte

- **Inconsistência material com a realidade do projeto:** o repositório já está público no GitHub (vide auditoria/16). A cláusula 5(a) prevê "repositório privado". As duas situações são incompatíveis. Se o código já foi publicado, o "fechamento" retroativo não impede que cópias circulem (o "cat já saiu do saco").
- **Decisão estratégica necessária:** ou (i) o projeto continua público no GitHub, e a cláusula 5 é reescrita para refletir isso; ou (ii) o projeto migra para repositório privado e a publicação atual é arquivada com aviso de licença aplicável a cada SHA.
- **Recomendação:** Manter público, alinhado com a missão GovTech e a auditabilidade. Reescrever cláusula 5 como "Disponibilizado publicamente em repositório identificável, sob esta TPGL, sem necessidade de identificação para inspeção, mas com Aceite necessário para Uso (instalação, modificação, execução)."
- **Risco da cláusula original:** Acesso "condicionado à identificação" pode conflitar com Lei de Acesso à Informação (Lei 12.527/11) **quando o software opera função pública** — cidadãos podem invocar LAI para auditar código de sistema usado pelo município em serviço público.

#### Cláusula 6 — Auditoria e transparência

- **Item (c)** "Acesso controlado para fins de fiscalização" — controlado por quem? Pelo Licenciante, presumidamente. Conflito potencial com LAI: quando o software apoia atividade administrativa, fiscalização por órgão de controle não depende de autorização do Licenciante.
- **Frase final** "Este modelo não caracteriza software open source" — **correta e necessária**. Manter. Reforçar visualmente no preâmbulo da v1.1.
- **Falta:** explicitar o direito de qualquer cidadão de inspecionar o código (read-only) quando o Software for usado em função pública, em alinhamento com a LAI.

#### Cláusula 7 — Licença comercial

- Curta e correta em princípio.
- **Falta:** menção a canal/forma de obter licença comercial (email, processo). Sem isso, a oferta de licença comercial é meramente nominal e pode ser interpretada como recusa indireta de licença.
- **Correção:** acrescentar canal e prazo razoável de resposta (ex.: licenciamento@<domínio>, resposta em 15 dias úteis).

#### Cláusula 8 — Contribuições (CLA)

- **Problema 1:** Lei 9.610/98 art. 49 exige cessão de direitos patrimoniais **por escrito**, interpretada restritivamente, com menção expressa às modalidades de uso. Um CLA "deve ser acompanhado de aceite" é genérico demais. Precisa ser instrumento formal.
- **Problema 2:** Item (b) "direito irrestrito de uso, modificação e relicenciamento" — relicenciamento amplo é legítimo, mas a expressão "irrestrito" é áspera e pode ser interpretada de forma restritiva pelo juiz.
- **Problema 3:** Não prevê concessão expressa de patente do contribuinte ao Licenciante (lacuna que Apache 2.0 resolve com cláusula própria).
- **Correção:** referenciar um documento `CLA.md` (ou `DCO.md`) anexo, com texto formal de cessão no estilo "Apache iCLA" ou "DCO" do Linux Foundation, em português, contendo: cessão de direitos patrimoniais (Lei 9.610 art. 49), garantia de autoria, concessão expressa de patente quando aplicável, e aceite eletrônico rastreável (commit signed-off-by ou aceite em PR).

#### Cláusula 9 — Propriedade intelectual

- Item (a) sobre marca: ok, mas prática corrente exige também mencionar **trade dress** e **identidade de produto**.
- Item (b) "metodologia associada" — ambíguo; metodologia ou é patenteável (e aí requer registro INPI) ou é know-how (tutelável por sigilo). A cláusula não agrega proteção real, apenas declara intenção.
- Item (c) "modelos de negócio" — modelos de negócio não são protegidos por direito autoral no Brasil. A cláusula não tem efeito jurídico imediato.
- **Correção:** substituir por cláusula que (i) reserva expressamente marca, logo, trade dress; (ii) faz reserva de eventuais segredos comerciais; (iii) não tenta declarar propriedade sobre o que a lei não protege.

#### Cláusula 10 — Data de Conversão (Change Date)

- **Problema central — 10 anos:** A BSL 1.1 oficial (mantida pelo MariaDB) tem como **teto recomendado 4 anos**, e o site oficial (`mariadb.com/bsl11`) registra: "BSL conversion date should be no later than four years after the official release date". 10 anos:
   - Sinaliza falta de compromisso com abertura futura.
   - Reduz aceitação por órgãos públicos que valorizam open source.
   - Pode ser caracterizado como artifício anti-OSS em comunidades técnicas.
   - Aumenta risco de **fork hostil** com narrativa "o autor nunca vai liberar".
- **Recomendação:** **4 anos**, exatamente alinhado à BSL 1.1. Justificar no preâmbulo.
- **Lacuna técnica adicional:** falta declarar que a Change Date opera **por release** (cada versão tem sua própria Change Date relativa à sua própria publicação). Sem isso, o gatilho fica indefinido.

#### Cláusula 11 — Rescisão

- **Problema:** Rescisão automática e imediata por qualquer violação é desproporcional. Apache 2.0 e BSL 1.1 preveem **período de cura** (a Apache 2.0 não tem cure period explícito mas opera com termination apenas para patent litigation; a BSL 1.1 prevê "must immediately stop using the Licensed Work in violation"). Doutrina brasileira favorece **período de cura razoável** sob princípio de boa-fé (CC art. 422).
- **Correção:** Acrescentar "Período de cura de 30 dias contados da notificação escrita do Licenciante. Caso a violação seja sanada no prazo, a licença permanece em vigor."
- **Falta:** previsão de "qualified self-cure" — usuário que descobre estar em violação e cessa o uso voluntariamente não precisa esperar notificação.

#### Cláusula 12 — Isenção de garantia

- Padrão internacional ok.
- **Falta:** limitação de responsabilidade explícita ("LIMITATION OF LIABILITY"). MIT/Apache trazem ambas separadamente. Sem limitação de responsabilidade, em caso de dano por defeito, o Licenciante pode responder integralmente sob CC art. 927 e seguintes.
- **Correção:** acrescentar parágrafo separado de limitação de responsabilidade.

#### Cláusula 13 — Legislação aplicável

- OK em princípio.
- **Falta:** **foro de eleição**. Em contratos com partes em diferentes municípios/estados, foro de eleição é essencial. Sugestão: comarca da sede do Licenciante.
- **Cuidado:** se o contraparte for ente público, foro de eleição pode ser nulo (ente público tem foro privilegiado). Ressalvar.

#### Cláusula 14 — Disposições finais

- "Acordo integral" — ok.
- "Severability" — ok.
- **Falta:** cláusula de notificação (forma e endereço), idioma prevalente, e cláusula de arbitragem opcional (útil para conflitos com partes privadas).

---

## 3. Compatibilidade com o ordenamento jurídico brasileiro

### 3.1 Lei 9.609/98 (Lei do Software)

| Dispositivo | Implicação para a TPGL | Status |
|---|---|---|
| Art. 2 | Software é protegido por regime semelhante ao de obras literárias | OK — TPGL invoca |
| Art. 4 | Programa desenvolvido em vínculo de serviço pertence ao empregador, salvo acordo | Sem impacto direto se autor é pessoa física titular |
| Art. 9 | "Uso de programa de computador no País será objeto de contrato de licença" | TPGL atende; reforçar com aceite eletrônico (clickwrap ou signed commit) |
| Art. 10 | Nos casos de comercialização, é obrigatório o **contrato de licença** | Importante: o contrato deve ser efetivamente apresentado ao usuário antes do uso, não apenas existir |
| Art. 11 | Tutela 50 anos a partir de 1 jan do ano seguinte à publicação | OK — compatível com Change Date de 4 anos |
| Art. 12 | Violação com pena de 6 meses a 2 anos + multa | Suporte criminal à cláusula 11 (rescisão por violação) |
| Art. 14 | Proibições específicas (decompilação etc.) com exceções (interoperabilidade) | A TPGL deve não restringir além do que a lei permite — em particular, decompilação para interoperabilidade é direito legal mesmo se a licença proibir |

### 3.2 Lei 9.610/98 (Direitos Autorais)

| Dispositivo | Implicação | Status na TPGL v1.0 |
|---|---|---|
| Art. 49 | Cessão de direitos patrimoniais é por escrito, interpretada restritivamente, menção expressa às modalidades | Cláusula 8 (CLA) é débil; precisa documento formal |
| Art. 50 | Cessão total e definitiva exige instrumento público ou particular registrado | Para CLA com cessão total, registrar Cartório de Títulos e Documentos é boa prática para grandes contribuintes |
| Art. 28-29 | Direitos patrimoniais exclusivos do autor | Base jurídica para a TPGL ser válida — autor pode condicionar uso |
| Art. 24 | Direitos morais (autoria, integridade) são **inalienáveis e irrenunciáveis** | Importante: nem mesmo o CLA pode renunciar autoria moral; manter atribuição |
| Art. 49, V | Cessão para modalidades **não previstas** na data é nula | CLA precisa ser elástico mas não pode ser indeterminado; cobrir explicitamente "todas as modalidades conhecidas, presentes e futuras análogas às conhecidas, no máximo permitido por lei" |

### 3.3 Lei 12.527/11 (Lei de Acesso à Informação — LAI)

- **Art. 8** estabelece dever de transparência ativa.
- Quando o Software opera função pública em município (gestão de credenciamento, OS), pode haver argumento de que **código-fonte é dado de interesse público**, pelo menos para auditoria.
- A cláusula 5 da TPGL v1.0, prevendo "acesso controlado", é **potencialmente conflitante com a LAI** quando aplicada a uso municipal.
- **Mitigação na v1.1:** explicitar que, quando usado em função pública, o código permanece auditável publicamente (read-only). Isso reforça, não prejudica, o modelo do mantenedor.

### 3.4 Lei 13.709/18 (LGPD)

- Software de credenciamento processa dados pessoais (CNPJ sócios, dados de prestadores, dados de OS).
- A TPGL não é contrato de tratamento de dados; mas deve haver **cláusula de delimitação**: o Software, em si, não trata dados — quem trata é o controlador (município). O Licenciante é desenvolvedor de produto, não operador.
- **Recomendação v1.1:** cláusula declarando que (i) o Licenciante não acessa dados processados pelos usuários; (ii) cada usuário é responsável pela conformidade LGPD do uso que faz; (iii) o Licenciante coopera em relatório de impacto se requisitado mediante condições razoáveis.

### 3.5 Lei 14.133/21 (Nova Lei de Licitações)

- Aquisição/uso de software por administração pública obedece à Lei 14.133/21. Para softwares gratuitos doados, o procedimento é mais leve (dispensa, doação), mas a licença precisa ser **clara, perpétua para o uso autorizado, e sem cláusulas leoninas**.
- Pontos sensíveis:
   - **Revogabilidade *ad nutum*** (cláusula 2 da TPGL v1.0) é problemática em contrato com administração pública — administração precisa de segurança jurídica para sustentar continuidade.
   - **Acesso controlado pelo Licenciante** (cláusula 5) pode ser visto como vinculação indevida do ente público ao mantenedor.
- **Mitigação v1.1:** licença perpétua e irrevogável para usos permitidos (uso interno por órgãos públicos), com rescisão apenas por violação e período de cura.

### 3.6 Princípios constitucionais aplicáveis

- **Publicidade (CF art. 37):** atos administrativos são públicos. Código de software usado em ato administrativo tende a ser auditável.
- **Moralidade:** licenças leoninas em software adotado por município podem ser questionadas.
- **Eficiência:** restrições excessivas que dificultem operação podem ser questionadas.

---

## 4. Comparativo com modelos consagrados

### 4.1 Quadro comparativo

| Atributo | MIT | Apache 2.0 | GPL v3 | AGPL v3 | BSL 1.1 | SSPL | TPGL v1.0 | TPGL v1.1 (proposta) |
|---|---|---|---|---|---|---|---|---|
| Fonte aberta? | Sim | Sim | Sim | Sim | Source-available | Source-available | Source-available | Source-available |
| OSI-aprovada? | Sim | Sim | Sim | Sim | Não | Não | Não | Não |
| Concessão de patente | Implícita fraca | Explícita | Explícita | Explícita | Implícita | Explícita | Ausente | Explícita (acrescentada) |
| Permite SaaS comercial por terceiros | Sim | Sim | Sim | Só se aberto | Não (default) | Não (força abertura total) | Não | Não |
| Permite uso interno por organização | Sim | Sim | Sim | Sim | Sim | Sim | Sim, com ressalvas | Sim, claramente |
| Período de conversão | N/A | N/A | N/A | N/A | <= 4 anos (recomendado) | N/A | 10 anos | 4 anos |
| Licença de conversão | N/A | N/A | N/A | N/A | Apache 2.0 ou similar | N/A | Apache 2.0 | Apache 2.0 |
| Cure period em rescisão | N/A | Limitado | 30/60 dias | 30/60 dias | Imediato | Imediato | Imediato | 30 dias |
| Compatibilidade GovTech | Alta | Alta | Média | Baixa | Alta | Baixa | Média | Alta |
| Risco de fork concorrente | Alto | Alto | Alto | Médio | Baixo | Muito baixo | Baixo | Baixo |
| Risco de litígio interpretativo | Baixo | Baixo | Médio | Médio | Baixo | Alto | Alto | Médio |

### 4.2 Discussão por opção

**MIT.** Máxima permissividade. Excelente para adoção. Inadequada ao objetivo do mantenedor de prevenir SaaS concorrente. Descartada.

**Apache 2.0.** Permissiva com proteções (patente, indenização). Excelente para adoção corporativa. Inadequada como licença primária (mesmas razões do MIT), **mas perfeita como Change License** (licença de conversão após 4 anos). **Recomendada para o slot de Change License na TPGL v1.1.**

**GPL v3.** Copyleft forte. Força derivados a continuarem GPL. **Não impede SaaS competitivo** porque GPL não se estende ao uso em servidor — alguém pode pegar o código, modificar, oferecer SaaS, e não precisa redistribuir as modificações. Inadequada ao objetivo.

**AGPL v3.** Resolve o "loophole SaaS" da GPL: quem oferecer serviço web com código AGPL precisa abrir as modificações. Mais alinhada que GPL, mas: (i) ainda permite competidor que aceite também ser AGPL; (ii) tem reputação de ser hostil em ambientes corporativos, o que prejudica adoção por municípios e SEBRAE/MGI; (iii) não tem mecanismo de Change Date.

**BSL 1.1.** Modelo conceitual da TPGL. Funciona porque tem três componentes acoplados: (a) Licensed Work, (b) Additional Use Grant (positivo, define o que **pode** ser feito em produção), (c) Change Date + Change License. A TPGL v1.0 herdou (a) e (c) mas omitiu (b) — sem Additional Use Grant, a estrutura BSL não opera com a clareza que a torna defensável. **A v1.1 deve incluir o Additional Use Grant.**

**SSPL.** Reação agressiva da MongoDB ao "free riding" de provedores cloud. Força quem oferece o software como serviço a abrir também todo o "service stack" (orquestração, monitoramento etc.). Rejeitada pela OSI. Excessiva para o caso em análise: não precisa fechar tanto.

### 4.3 Decisão

Para o caso em análise, a **estrutura BSL 1.1 com adaptações brasileiras** é o melhor encaixe. A TPGL v1.1 deve:

- Manter o espírito BSL.
- Ajustar o vocabulário às definições brasileiras.
- Adicionar Additional Use Grant claro.
- Reduzir Change Date a 4 anos.
- Incorporar concessão de patente.
- Incluir cure period.
- Resolver inconsistências com a publicação real do projeto.
- Tratar LAI/LGPD/Lei 14.133/21 explicitamente.

---

## 5. Análise dos pontos críticos solicitados

### 5.1 A restrição de uso comercial concorrente é juridicamente sustentável?

**Sim, em princípio.** O autor de software tem direitos patrimoniais exclusivos (Lei 9.610 art. 28-29) e pode condicionar o uso. Restrições contra uso comercial concorrente são válidas no Brasil, desde que:

- A licença seja efetivamente aceita pelo usuário antes do uso (não basta existir; deve haver clickwrap, signed commit, contrato físico, etc.).
- As cláusulas sejam **claras e não ambíguas** — cláusulas vagas tendem a ser interpretadas restritivamente em favor do aderente (CC art. 423, princípio *in dubio contra stipulatorem*).
- Não haja desproporção manifesta (CC art. 478, lesão).
- Não confronte normas cogentes (LAI quando aplicável, direitos morais do autor, etc.).

A TPGL v1.0 **falha no requisito de clareza** em vários pontos (vide seção 2). A TPGL v1.1 corrige.

### 5.2 A limitação de acesso ao código (acesso controlado) é compatível com o modelo proposto?

**Parcialmente.** Três situações diferentes:

| Cenário | Compatibilidade | Observação |
|---|---|---|
| Acesso público para inspeção + aceite necessário para Uso | Compatível | Modelo recomendado para v1.1 |
| Acesso restrito a Órgãos Autorizados, sem publicação | Compatível se nunca publicado | **Não se aplica ao caso em análise** porque o código já está público |
| Acesso restrito retroativamente a código já publicado | Inútil | Cópias já circulam; restringir agora não recupera o passado |

**Recomendação:** TPGL v1.1 trata o código como **publicamente acessível para inspeção** (alinhado à missão GovTech), com aceite necessário para Uso conforme definido. O "acesso controlado" da v1.0 é abandonado por inadequado ao estado de fato.

### 5.3 O modelo "auditoria aberta, mas não pública" é juridicamente consistente?

**Conceitualmente consistente, na prática problemático.** Em GovTech:

- "Auditoria aberta" usualmente significa "auditável por órgãos de controle".
- "Não pública" significaria "não acessível ao cidadão comum".
- A LAI (art. 5, art. 7) garante ao cidadão acesso a informações de interesse público produzidas por entes públicos.

Quando o software opera atividade pública:

- O cidadão pode pedir, via LAI, acesso ao código? Há precedente em discussões acadêmicas (TCU, controlado), não firmado em jurisprudência clara, mas o risco existe.
- A jurisprudência tende a entender que **o código do produto pertence ao mantenedor** (Lei 9.609 art. 4), mas que **o uso público cria interesse público em verificar a integridade do que é usado**.

**Solução da v1.1:** acesso público para **inspeção** (read-only, qualquer pessoa pode ler), aceite necessário para **Uso** (qualquer instalação, modificação, execução) sob a TPGL. Isto resolve LAI sem comprometer o modelo de negócio.

### 5.4 Existe risco de caracterização como cláusula abusiva ou inválida?

**Risco existente, concentrado em quatro pontos da v1.0:**

1. **Revogabilidade *ad nutum*** (cláusula 2): pode ser interpretada como leonina e ser declarada nula em caso específico.
2. **"Vantagem econômica indireta"** (cláusula 1, definição de Uso Comercial): aberta ao argumento de que captura mais do que o titular pode legitimamente reservar.
3. **Acesso controlado pelo Licenciante a código usado em função pública** (cláusula 5-6): potencial conflito com LAI.
4. **Rescisão automática imediata sem cura** (cláusula 11): desproporcional, viola boa-fé objetiva.

A v1.1 corrige todos os quatro.

---

## 6. Riscos práticos

### 6.1 Risco de fork concorrente

- **Ambiente atual (público no GitHub, sem licença clara):** Risco **alto** de fork — sem licença formal, paradoxalmente, qualquer cópia está em zona cinzenta, mas a percepção pública de "código aberto" facilita forks despreocupados. Disputas posteriores seriam custosas.
- **Sob TPGL v1.0:** Risco **médio** — cláusulas vagas dificultam comprovação de violação em juízo. Litígio caro.
- **Sob TPGL v1.1:** Risco **baixo a médio** — cláusulas precisas, com Additional Use Grant claro, tornam violação identificável. Mantém porém o risco residual de interpretação judicial em primeiro caso brasileiro (jurisprudência não testada).

### 6.2 Risco de judicialização

- Custo médio de litígio civil para defesa de licença de software no Brasil: dezenas a centenas de milhares de reais, com 3-7 anos de duração. Para o mantenedor, isso é **risco material**.
- Estratégia v1.1: licença clara reduz probabilidade; reservar foro reduz custo logístico; ofertar canal de licença comercial reduz argumento de "recusa de licenciamento".
- **Recomendação adicional:** considerar inclusão de cláusula de **mediação prévia** obrigatória (CC art. 411 e seguintes; Lei 13.140/15) antes de litígio. Reduz custo médio.

### 6.3 Risco de rejeição por órgãos públicos

- Órgãos públicos têm aversão crescente a licenças não-OSI. SEBRAE/MGI em particular costumam preferir licenças reconhecidas.
- TPGL v1.0 tem nome enganoso ("public") mas conteúdo restritivo; rejeição provável após análise jurídica.
- TPGL v1.1, com narrativa transparente ("source-available, becomes Apache 2.0 in 4 years, public audit allowed"), tem aceitação mais provável mas ainda não garantida.
- **Mitigação adicional:** preparar **memorando jurídico oficial** (parecer de advogado humano, com base neste documento) para entregar a órgãos públicos junto com a licença. Reduz tempo de aprovação e dúvidas.

### 6.4 Risco reputacional na comunidade open source

- A comunidade open source tem reações hostis a licenças anti-competitivas mascaradas de "abertas".
- Risco **alto** se o nome continuar implicando "Public" sem ressalva.
- Risco **médio** com nome ajustado e narrativa transparente.

### 6.5 Risco de obsolescência do gatilho de Change Date

- Se a TPGL v1.0 (com 10 anos) for mantida, o gatilho é tão distante que ninguém se prepara. Valor "anti-fork" do compromisso futuro é descontado.
- Com 4 anos (v1.1), o compromisso é palpável e gera credibilidade reputacional.

---

## 7. Recomendações objetivas

### 7.1 Ações imediatas (P0)

| # | Ação | Razão |
|---|---|---|
| R-01 | Adotar TPGL v1.1 (texto na seção 8) substituindo a v1.0 | Corrige todas as falhas materiais identificadas |
| R-02 | Reduzir Change Date para 4 anos | Alinhamento BSL e credibilidade |
| R-03 | Adicionar Additional Use Grant explícito | Mecanismo central BSL ausente na v1.0 |
| R-04 | Adicionar concessão de patente | Lacuna crítica |
| R-05 | Incluir cure period de 30 dias | Boa-fé objetiva, redução de risco de nulidade |
| R-06 | Especificar foro e idioma prevalente | Higiene contratual básica |
| R-07 | Anexar `CLA.md` formal | Lei 9.610 art. 49 |
| R-08 | Renomear ou adicionar subtítulo desambiguador | Evita induzir erro |
| R-09 | Reescrever cláusula 5 (acesso público para inspeção + aceite para Uso) | Compatibilidade com publicação real e LAI |
| R-10 | Acrescentar cláusula LGPD | Higiene LGPD |

### 7.2 Ações seguintes (P1)

| # | Ação | Razão |
|---|---|---|
| R-11 | Submeter v1.1 à homologação por advogado(a) brasileiro(a) | Indispensável antes de uso institucional |
| R-12 | Preparar memorando jurídico para apresentar a órgãos públicos | Acelera aceitação em municípios |
| R-13 | Configurar processo de aceite eletrônico (clickwrap ou signed-off-by) | Lei 9.609 art. 9 |
| R-14 | Registrar a TPGL v1.1 no INPI ou em cartório (opcional, fortalece prova) | Dataprova de existência da licença em data certa |
| R-15 | Manter `LICENSE` na raiz do repositório com texto integral da TPGL v1.1 | Compatibilidade com convenções GitHub e ferramentas |
| R-16 | Atualizar `README.md` e badges para refletir TPGL v1.1 (substitui o badge MIT da auditoria 16) | Consistência documental |

### 7.3 Ações recomendadas (P2)

| # | Ação | Razão |
|---|---|---|
| R-17 | Publicar FAQ explicando o modelo TPGL para municípios e empresas | Reduz dúvidas, acelera adoção |
| R-18 | Criar processo formal de oferta de licença comercial (template de proposta, tabela de preços) | Operacionaliza cláusula 7 |
| R-19 | Estabelecer política de Change Date por release (cada release tem sua própria janela de 4 anos) | Operacionaliza o gatilho corretamente |
| R-20 | Considerar mediação prévia obrigatória (Lei 13.140/15) | Reduz custo de litígio |

---

## 8. Versão final proposta — TPGL v1.1 (texto integral)

> Texto pronto para colar em `LICENSE` após homologação por advogado(a) brasileiro(a). Idioma prevalente: português. Versão em inglês deve ser preparada subsequentemente para uso internacional, com nota de prevalência da versão em português.

---

```text
LICENÇA TPGL v1.1
Versão 1.1 — 2026-04-19

Source-available license for public-interest software.
This is NOT an open source license per OSI definition.
This license converts to Apache License 2.0 four years
after each release date.

Copyright (C) 2026 Luís Maurício Junqueira Zanin e contribuintes.
Todos os direitos reservados.

PREAMBULO

Esta licenca foi desenhada para um sistema de interesse publico,
voltado a municipios brasileiros, com tres compromissos
simultaneos:

(i) Transparencia e auditabilidade publica do codigo, em
    alinhamento com a Lei 12.527/11 (Lei de Acesso a Informacao);
(ii) Sustentabilidade economica do mantenedor, mediante reserva
     de uso comercial competitivo;
(iii) Conversao automatica para Apache License 2.0 quatro anos
      apos cada publicacao de versao, garantindo abertura futura.

Esta licenca e inspirada na Business Source License 1.1
(MariaDB), adaptada ao ordenamento juridico brasileiro,
notadamente a Lei 9.609/98 (Lei de Software) e a Lei 9.610/98
(Direitos Autorais).

1. DEFINICOES

1.1 "Licenciante" significa o titular dos direitos patrimoniais
    sobre o Software, conforme identificado no aviso de copyright.

1.2 "Software" ou "Obra Licenciada" significa o codigo-fonte,
    documentacao, planilhas, esquemas de dados e demais artefatos
    tecnicos identificados pelo identificador de versao
    (`APP_RELEASE_VERSION`) e respectivo hash de commit
    publicado pelo Licenciante. A presente licenca aplica-se a
    cada versao isoladamente, com sua propria Data de Conversao.

1.3 "Uso" significa qualquer ato de instalacao, execucao, copia,
    modificacao, traducao, adaptacao, derivacao, distribuicao
    ou disponibilizacao a terceiros do Software.

1.4 "Inspecao" significa o ato de leitura, analise estatica ou
    dinamica nao executada, e auditoria de conformidade do
    Software, sem instalacao, execucao ou distribuicao.
    Inspecao nao depende de aceite desta licenca.

1.5 "Uso Interno" significa o Uso do Software pelo Licenciado
    ou por orgao publico, dentro de sua propria estrutura
    organizacional, para gestao de suas proprias atividades.

1.6 "Uso em Producao" significa o Uso Interno em ambiente
    operacional, processando dados reais.

1.7 "Uso Comercial" significa o Uso do Software no qual o
    Licenciado, de forma direta, oferece, comercializa, licencia
    a terceiros, ou presta servicos a terceiros tendo o Software
    como componente material da oferta. Para evitar duvidas,
    nao se considera Uso Comercial:
    (a) o Uso Interno por orgao publico, ainda que este orgao
        cobre taxas, emolumentos ou prestacoes administrativas
        pelos servicos publicos prestados a terceiros, desde
        que o Software em si nao seja a oferta cobrada;
    (b) o Uso por organizacao privada para gestao interna de
        suas proprias atividades.

1.8 "Uso Restrito" significa qualquer Uso fora do escopo
    expressamente concedido por esta licenca, incluindo
    notadamente o Uso Comercial e o Uso Concorrente.

1.9 "Uso Concorrente" significa qualquer dos seguintes:
    (a) oferecer a terceiros, mediante pagamento ou
        contrapartida economica, servico (incluindo SaaS, PaaS,
        hosting, ASP ou qualquer modelo `as-a-Service`,
        hospedado ou nao) que tenha o Software como componente
        material;
    (b) revender, sublicenciar ou distribuir o Software a
        terceiros mediante remuneracao;
    (c) utilizar o Software como base para criar, oferecer ou
        operar produto que substitua, total ou parcialmente, o
        Software ou suas funcionalidades nucleares (selecao de
        prestadores por rodizio, gestao de credenciamento,
        emissao de pre-ordens e ordens de servico, e avaliacao
        de prestadores), com finalidade comercial.

1.10 "Orgaos Autorizados" significa os entes da administracao
     publica direta ou indireta, nos tres niveis federativos,
     no exercicio de competencia legal relacionada a
     contratacoes, credenciamento, ou fiscalizacao, incluindo
     notadamente municipios, Tribunais de Contas, Controladorias,
     Ministerio Publico, Ministerio da Gestao e Inovacao em
     Servicos Publicos (MGI), e o Servico Brasileiro de Apoio as
     Micro e Pequenas Empresas (SEBRAE).

1.11 "Data de Conversao" significa a data correspondente a
     quatro (4) anos apos a publicacao oficial de cada versao
     do Software pelo Licenciante.

1.12 "Licenca de Conversao" significa a Apache License,
     versao 2.0, conforme publicada pela Apache Software
     Foundation (https://www.apache.org/licenses/LICENSE-2.0).

2. CONCESSAO DE DIREITOS

2.1 O Licenciante concede ao Licenciado, sujeito ao cumprimento
    integral desta licenca, uma licenca **mundial,
    nao-exclusiva, nao-transferivel, gratuita, irrevogavel
    enquanto cumpridas as condicoes** desta licenca, para:

    (a) Inspecionar o Software publicamente, sem necessidade de
        aceite formal;
    (b) Acessar o codigo-fonte completo;
    (c) Realizar auditoria tecnica, de seguranca e de
        conformidade;
    (d) Executar o Software para Uso Interno;
    (e) Modificar o Software para Uso Interno;
    (f) Distribuir o Software, modificado ou nao, a Orgaos
        Autorizados, desde que cada destinatario aceite os
        termos desta licenca.

2.2 A presente licenca opera por inheritance: cada distribuicao
    do Software a terceiro autorizado se da sob esta mesma
    TPGL, sem possibilidade de relicenciamento sob termos
    diferentes pelo Licenciado, ate a Data de Conversao.

2.3 Concessao de Patente. O Licenciante concede ao Licenciado
    uma licenca perpetua, mundial, nao-exclusiva, gratuita e
    irrevogavel (exceto na forma do item 11.2) sobre todas as
    reivindicacoes patentarias do Licenciante necessariamente
    infringidas pelo Software em sua forma distribuida pelo
    Licenciante, exclusivamente para Uso permitido por esta
    licenca. Esta concessao de patente e cessada
    automaticamente caso o Licenciado inicie acao judicial
    alegando que o Software, isoladamente ou em combinacao,
    infringe patente do Licenciado.

3. ADDITIONAL USE GRANT

3.1 Para fins de evitar qualquer duvida sobre o escopo permitido
    em Uso em Producao, o Licenciante concede expressamente o
    direito de:

    (a) Uso em Producao por orgaos publicos, no exercicio de
        suas atividades administrativas, ainda que estes orgaos
        cobrem taxas administrativas dos administrados pelos
        servicos publicos prestados;
    (b) Uso em Producao por organizacao privada exclusivamente
        para gestao interna de suas proprias atividades, sem
        oferta a terceiros;
    (c) Uso para fins academicos, de pesquisa, de ensino e de
        avaliacao tecnica, ainda que em ambiente de producao
        controlado;
    (d) Distribuicao gratuita do Software, modificado ou nao,
        entre Orgaos Autorizados.

3.2 Qualquer Uso fora do escopo do item 3.1 constitui Uso
    Restrito e exige licenca comercial especifica conforme
    clausula 7.

4. RESTRICOES

4.1 E expressamente vedado, sem licenca comercial especifica:

    (a) Uso Concorrente, conforme definido no item 1.9;
    (b) Oferecer o Software como SaaS, PaaS ou qualquer modelo
        `as-a-Service`, hospedado ou nao, a terceiros;
    (c) Comercializar, sublicenciar ou revender o Software;
    (d) Utilizar o Software como base para produto que
        substitua, total ou parcialmente, suas funcionalidades
        nucleares com finalidade comercial;
    (e) Distribuir o Software a terceiros nao autorizados;
    (f) Remover, alterar ou ocultar avisos de copyright,
        notas de licenca, atribuicao de autoria, ou
        identificadores de versao;
    (g) Utilizar marcas, logos, nomes ou identidade visual do
        Licenciante sem autorizacao formal e por escrito.

4.2 As proibicoes do item 4.1 nao se aplicam a usos
    expressamente permitidos pelo Additional Use Grant
    (clausula 3) nem a usos para os quais foi obtida licenca
    comercial especifica (clausula 7).

4.3 Esta licenca nao restringe direitos garantidos por norma
    cogente brasileira, incluindo notadamente os direitos de
    decompilacao para fins de interoperabilidade previstos no
    art. 6, I, da Lei 9.609/98.

5. ACESSO AO CODIGO-FONTE E TRANSPARENCIA

5.1 O Licenciante mantem o Software publicamente disponivel
    em repositorio identificado, com codigo-fonte integral
    acessivel para Inspecao por qualquer pessoa, sem
    necessidade de identificacao previa nem aceite formal
    desta licenca para o ato de leitura.

5.2 O aceite desta licenca e necessario para qualquer Uso
    (instalacao, execucao, modificacao, distribuicao). O aceite
    se da por: (a) clonagem ou download do repositorio para uso
    operacional; (b) execucao do Software; (c) submissao formal
    de aceite eletronico; ou (d) atos inequivocos de uso.

5.3 Auditoria por Orgaos Autorizados e por cidadaos no
    exercicio do direito previsto na Lei 12.527/11 e expressamente
    permitida e nao depende de autorizacao previa do
    Licenciante.

6. CONTRIBUICOES

6.1 Toda contribuicao ao Software, incluindo correcoes, novas
    funcionalidades, documentacao e testes, e submetida sob os
    termos do Contributor License Agreement (CLA) anexo
    (`CLA.md`), o qual estabelece, no maximo permitido pela Lei
    9.610/98 art. 49: (a) cessao das modalidades patrimoniais
    do contribuinte ao Licenciante para todas as modalidades
    conhecidas de uso; (b) garantia de autoria e originalidade;
    (c) concessao expressa de licenca de patente do contribuinte
    ao Licenciante e usuarios da TPGL.

6.2 Direitos morais do contribuinte (autoria, integridade) sao
    inalienaveis e expressamente preservados (Lei 9.610 art. 24).

6.3 Contribuicoes sem CLA aceito por meio rastreavel
    (signed-off-by no commit, ou aceite eletronico em pull
    request) nao serao incorporadas ao Software.

7. LICENCA COMERCIAL

7.1 Qualquer uso fora do escopo desta licenca, incluindo Uso
    Concorrente e Uso Comercial, requer licenca comercial
    especifica e expressa do Licenciante.

7.2 Solicitacoes de licenca comercial devem ser enviadas para
    canal institucional privado de licenciamento, com resposta do Licenciante em
    ate quinze (15) dias uteis. A nao-resposta no prazo nao
    constitui aceite tacito.

7.3 O Licenciante reserva-se o direito de definir condicoes
    comerciais (tabela de precos, escopo de uso permitido,
    duracao) em cada caso.

8. PROPRIEDADE INTELECTUAL E MARCAS

8.1 Esta licenca **nao concede** ao Licenciado:
    (a) qualquer direito sobre marcas, logos, identidade visual
        ou trade dress associados ao Software ou ao Licenciante;
    (b) qualquer direito sobre segredos comerciais ou
        know-how nao publicado;
    (c) qualquer direito de uso do nome do Licenciante para
        fins de endosso ou promocao.

8.2 O uso da marca ou identidade visual do Software e do
    Licenciante depende de autorizacao formal e por escrito.

9. AUSENCIA DE TRATAMENTO DE DADOS PESSOAIS PELO LICENCIANTE

9.1 O Software, na sua forma distribuida, nao envia dados ao
    Licenciante. O Licenciante nao opera nem controla, em
    razao desta licenca, qualquer tratamento de dados pessoais
    realizado pelos Licenciados.

9.2 Cada Licenciado e o controlador (ou operador, conforme o
    caso) dos dados pessoais que tratar com o Software, sendo
    responsavel pelo cumprimento integral da Lei 13.709/18 (LGPD)
    em sua operacao.

9.3 O Licenciante coopera com o Licenciado no atendimento de
    relatorios de impacto a protecao de dados (RIPD) e
    requisitos analogos, nas condicoes razoaveis a serem
    acordadas.

10. DATA DE CONVERSAO E LICENCA DE CONVERSAO

10.1 A partir da Data de Conversao de cada versao do Software
     (4 anos apos a respectiva publicacao oficial pelo
     Licenciante), aquela versao especifica sera
     automaticamente disponibilizada sob a Licenca de
     Conversao (Apache License 2.0).

10.2 A partir da Data de Conversao de uma versao:
     (a) todas as restricoes desta TPGL deixam de se aplicar a
         essa versao;
     (b) a versao passa a ser open source nos termos da Apache
         License 2.0;
     (c) versoes posteriores ainda sob TPGL nao sao afetadas.

10.3 O Licenciante mantem registro publico das datas de
     publicacao de cada versao, para fins de calculo da Data
     de Conversao.

11. RESCISAO E CURA

11.1 Em caso de violacao desta licenca pelo Licenciado, o
     Licenciante notificara por escrito a violacao identificada.

11.2 O Licenciado tera prazo de **trinta (30) dias** corridos,
     contados do recebimento da notificacao, para sanar a
     violacao ou apresentar justificativa fundamentada.

11.3 Saneada a violacao no prazo, a licenca permanece em vigor.

11.4 Nao saneada a violacao no prazo, esta licenca e
     automaticamente rescindida em relacao ao Licenciado
     infrator, cessando todos os direitos concedidos, sem
     prejuizo da reparacao civil cabivel.

11.5 O Licenciado que, antes de qualquer notificacao,
     identificar uso em violacao e cessar voluntariamente o
     uso violador, nao sera considerado em violacao para fins
     desta clausula.

12. ISENCAO DE GARANTIA E LIMITACAO DE RESPONSABILIDADE

12.1 O Software e fornecido "NO ESTADO EM QUE SE ENCONTRA",
     sem garantias de qualquer tipo, expressas ou implicitas,
     incluindo, sem limitacao, garantias de comerciabilidade,
     adequacao a finalidade especifica, e nao infracao.

12.2 Em nenhuma hipotese, o Licenciante respondera por danos
     indiretos, incidentais, consequenciais, especiais ou
     punitivos decorrentes do Uso ou impossibilidade de Uso do
     Software, ainda que avisado da possibilidade de tais
     danos.

12.3 A presente clausula e aplicavel no maximo permitido pelo
     direito brasileiro.

13. LEGISLACAO APLICAVEL E FORO

13.1 Esta licenca e regida pelas leis da Republica Federativa
     do Brasil, em especial pelas Leis 9.609/98, 9.610/98,
     12.527/11 e 13.709/18.

13.2 As partes elegem o foro da comarca do domicilio do
     Licenciante para dirimir quaisquer controversias
     decorrentes desta licenca, ressalvada a competencia
     constitucional ou legal de outro foro quando o Licenciado
     for ente publico.

13.3 As partes podem, antes de propor acao judicial, submeter
     a controversia a mediacao nos termos da Lei 13.140/15.

14. DISPOSICOES FINAIS

14.1 Esta licenca, juntamente com o CLA anexo, constitui o
     acordo integral entre as partes quanto ao licenciamento
     do Software.

14.2 Caso qualquer clausula desta licenca seja declarada
     invalida ou inexequivel, as demais permanecem em vigor.

14.3 Em caso de divergencia entre versoes em diferentes idiomas,
     prevalece esta versao em portugues.

14.4 O Licenciante pode publicar versoes futuras desta licenca
     com numeracao crescente. Versoes ja publicadas do Software
     permanecem regidas pela versao da licenca vigente na sua
     data de publicacao.

14.5 Esta licenca **nao caracteriza software open source** sob
     a definicao da Open Source Initiative (OSI), embora se
     converta em open source (Apache License 2.0) na Data de
     Conversao de cada versao.

— FIM DA TPGL v1.1 —
```

---

## 9. Justificativa técnica e jurídica

### 9.1 Por que este modelo é adequado para GovTech brasileira

**Equilíbrio de três compromissos.** O setor público brasileiro tem demanda crescente por software auditável e tem aversão a vendor lock-in. Ao mesmo tempo, mantenedores de produtos GovTech precisam de modelo de negócio sustentável para não sucumbirem à falta de financiamento e abandonarem o produto a meio caminho. A TPGL v1.1 entrega:

(i) **Auditabilidade pública imediata** — código aberto à inspeção por qualquer pessoa (órgãos de controle e cidadãos), atendendo LAI e princípios de transparência.

(ii) **Reserva comercial competitiva** — terceiros não podem oferecer SaaS competitivo nem revender, preservando o espaço econômico do mantenedor para sustentar o produto.

(iii) **Compromisso crível de abertura** — após 4 anos de cada release, a versão se torna Apache 2.0. Isto cria garantia de que, se o mantenedor sumir, o código não morre fechado. Reduz risco de adoção por órgãos públicos avessos a vendor lock-in.

### 9.2 Por que 4 anos (e não 10)

- **Padrão BSL.** O próprio MariaDB (criador da BSL) recomenda no máximo 4 anos. A prática corrente em projetos BSL (Sentry, CockroachDB, MariaDB enterprise extensions) usa 4 anos.
- **Credibilidade.** 10 anos sinaliza que o compromisso de abertura é meramente nominal. 4 anos é palpável.
- **Aceitação pública.** Órgãos públicos com receio de vendor lock-in aceitam mais facilmente um horizonte de 4 anos. Em 10 anos, qualquer software pode estar obsoleto, anulando o valor da abertura.
- **Modelo de negócio.** 4 anos são suficientes para o mantenedor capturar o valor das funcionalidades novas via SaaS comercial. Funcionalidades de 4 anos atrás já foram amortizadas; liberá-las não destrói o modelo.

### 9.3 Por que o Additional Use Grant é indispensável

O modelo BSL funciona porque tem **assimetria explícita**: define **o que é permitido em produção** (Additional Use Grant, positivo, específico), e trata **tudo o mais como restrito**. A v1.0 inverteu isso: listou restrições amplas sem definir o positivo. O resultado é máximo de insegurança jurídica para o usuário potencial — cada município precisaria de parecer jurídico para entender se sua operação específica está permitida. A v1.1 explicita o Additional Use Grant: órgão público pode usar internamente, ainda que cobre taxas administrativas; organização privada pode usar para gestão própria; uso acadêmico/pesquisa permitido. Isto torna a adoção decidível sem advogado para cada caso, requisito prático para escalar adoção por municípios pequenos.

### 9.4 Por que a Apache 2.0 como Change License (e não MIT ou GPL)

- **MIT** como Change License seria mais permissivo, mas perderia a proteção de patente que a Apache traz.
- **GPL** como Change License seria copyleft, o que evitaria que terceiros fechassem o código após 4 anos, mas seria interpretado como hostil por mercado corporativo.
- **Apache 2.0** combina permissividade adoção + proteção de patente + indemnification de marca. É o padrão de mercado para Change License em projetos BSL (MariaDB, Sentry, CockroachDB usam Apache 2.0 como Change License).

### 9.5 Por que mantemos cláusula 4 (restrições) em essência

A cláusula 4 é o coração do modelo de negócio do mantenedor. O parecer **preserva-a integralmente** em substância e refina apenas a redação para reduzir vagueza. Isso atende ao pedido explícito do mantenedor de manter a cláusula 4 e ao mesmo tempo aumenta a defensabilidade jurídica.

### 9.6 Como esta licença aproxima o projeto de práticas CMMI/ISO

A previsibilidade contratual é requisito implícito de vários PA's CMMI nível 3 (CM — Configuration Management; SAM — Supplier Agreement Management; OPF — Organizational Process Focus) e de controles ISO/IEC 27001 (A.5 políticas; A.15 supplier relationships). Uma licença clara, versionada, com período de cura explícito e canal formal de licenciamento comercial, sustenta estes requisitos. A TPGL v1.0, com cláusulas vagas e revogabilidade *ad nutum*, falha aqui. A v1.1 atende.

---

## 10. Próximos passos e roteiro de homologação

### 10.1 Passos imediatos pelo mantenedor

1. Substituir a TPGL v1.0 pela v1.1 em rascunho.
2. Confirmar o canal institucional privado de licenciamento e a política jurídica aplicável do Licenciante.
3. Anexar `CLA.md` com texto formal de cessão (modelo a desenvolver em sprint subsequente).
4. Levar a v1.1 a advogado(a) brasileiro(a) com prática em PI/software para homologação formal.
5. Após homologação, salvar como `LICENSE` na raiz do repositório.
6. Atualizar `README.md` para refletir a TPGL v1.1 (substituir badge `MIT` da auditoria 16 por badge `TPGL v1.1`).
7. Atualizar `auditoria/16` (este eixo de licença passa de "MIT recomendada" para "TPGL v1.1 adotada", com cross-ref a este parecer 17).
8. Documentar em `SECURITY.md` que vulnerabilidades de licença também podem ser reportadas pelo mesmo canal.

### 10.2 Roteiro para homologação por advogado humano

Entregar ao(à) advogado(a):

(a) este parecer integral (`auditoria/17_PARECER_LICENCIAMENTO_TPGL_v1_1.md`);
(b) o texto da TPGL v1.1 (seção 8 deste parecer);
(c) o texto da TPGL v1.0 original do mantenedor;
(d) a auditoria 16 com a estrutura pública do projeto;
(e) breve descrição do modelo de negócio pretendido (SaaS comercial sobre núcleo source-available);
(f) lista de órgãos públicos prioritários para adoção.

Pedir ao(à) advogado(a):

(a) revisão de redação para conformidade com prática brasileira;
(b) confirmação de validade do CLA proposto sob Lei 9.610 art. 49;
(c) recomendação sobre necessidade de registro em Cartório de Títulos e Documentos para conferir data certa;
(d) parecer sobre necessidade de registro INPI;
(e) sugestão de foro e mediação prévia;
(f) preparação de memorando jurídico anexo, a ser fornecido a órgãos públicos junto com a licença, explicando em linguagem jurídico-administrativa por que a TPGL é compatível com Lei 14.133/21 e LAI.

### 10.3 Roteiro para apresentação a órgãos públicos

Pacote a entregar a um município interessado em adotar:

1. `LICENSE` (TPGL v1.1).
2. Memorando jurídico do advogado humano homologador.
3. `docs/COMPLIANCE_CMMI_ISO.md` (a ser produzido em sprint S5 da auditoria 16).
4. Atestado de auditabilidade pública: link para repositório + hash da release.
5. FAQ de adoção para órgão público (a ser produzida em R-17).

---

Fim do parecer.
