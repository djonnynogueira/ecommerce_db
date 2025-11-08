# 🛒 Projeto Lógico de Banco de Dados - E-commerce

## 📋 Descrição do Projeto

Este projeto implementa o modelo lógico de banco de dados para um sistema de e-commerce completo, desenvolvido como parte do desafio de projeto da DIO. O esquema foi construído a partir da modelagem conceitual (modelo EER), aplicando técnicas de mapeamento para o modelo relacional e incorporando refinamentos específicos solicitados.

### 🎯 Objetivo do Desafio

Replicar a modelagem do projeto lógico de banco de dados para o cenário de e-commerce, aplicando:

✅ Definições corretas de chaves primárias e chaves estrangeiras
✅ Constraints para garantir integridade dos dados
✅ Mapeamento de relacionamentos do modelo EER para o modelo relacional
✅ Refinamentos específicos do modelo conceitual
✅ Criação de queries SQL complexas para análise de dados

### 🏗️ Refinamentos Implementados
1. Cliente PF e PJ - Abordagem Single Table Inheritance

Requisito: "Uma conta pode ser PJ ou PF, mas não pode ter as duas informações"

Solução Implementada:
```Sql
CREATE TABLE Cliente (
    idCliente INT AUTO_INCREMENT PRIMARY KEY,
    Nome VARCHAR(100) NOT NULL,
    TipoCliente ENUM('PF', 'PJ') NOT NULL,
    
    -- Campos específicos para Pessoa Física
    CPF CHAR(11) UNIQUE,
    DataNascimento DATE,
    
    -- Campos específicos para Pessoa Jurídica
    CNPJ CHAR(14) UNIQUE,
    RazaoSocial VARCHAR(100),
    InscricaoEstadual VARCHAR(20),
    
    -- Constraint para garantir exclusividade
    CONSTRAINT chk_cliente_pf_pj CHECK (
        (TipoCliente = 'PF' AND CPF IS NOT NULL AND CNPJ IS NULL) OR
        (TipoCliente = 'PJ' AND CNPJ IS NOT NULL AND CPF IS NULL)
    )
);
```

2. Múltiplas Formas de Pagamento

Requisito: "Pode ter cadastrado mais de uma forma de pagamento"

Solução Implementada:

```Sql
-- Tabela de formas de pagamento disponíveis
CREATE TABLE Forma_Pagamento (
    idFormaPagamento INT AUTO_INCREMENT PRIMARY KEY,
    TipoPagamento ENUM('Cartão Crédito', 'Cartão Débito', 'PIX', 'Boleto', 'Transferência'),
    Descricao VARCHAR(100)
);

-- Tabela associativa (N:M) - Um pedido pode ter múltiplas formas de pagamento
CREATE TABLE Pagamento_Pedido (
    idPagamentoPedido INT AUTO_INCREMENT PRIMARY KEY,
    Pedido_idPedido INT NOT NULL,
    FormaPagamento_idFormaPagamento INT NOT NULL,
    ValorPago DECIMAL(10,2) NOT NULL,
    StatusPagamento ENUM('Pendente', 'Aprovado', 'Recusado'),
    FOREIGN KEY (Pedido_idPedido) REFERENCES Pedido(idPedido),
    FOREIGN KEY (FormaPagamento_idFormaPagamento) REFERENCES Forma_Pagamento(idFormaPagamento)
);
```

Benefícios:

- ✅ Permite pagamento parcial em diferentes formas
- ✅ Rastreabilidade de cada transação
- ✅ Flexibilidade para o cliente

3. Entrega com Status e Código de Rastreio

Requisito: "Entrega possui status e código de rastreio"

Solução Implementada:

```Sql
CREATE TABLE Entrega (
    idEntrega INT AUTO_INCREMENT PRIMARY KEY,
    Pedido_idPedido INT NOT NULL UNIQUE,
    StatusEntrega ENUM('Preparando', 'Em Trânsito', 'Saiu para Entrega', 'Entregue', 'Devolvido'),
    CodigoRastreio VARCHAR(50) UNIQUE,
    DataEnvio DATE,
    DataEntregaPrevista DATE,
    DataEntregaRealizada DATE,
    FOREIGN KEY (Pedido_idPedido) REFERENCES Pedido(idPedido)
);
```

### 📊 Modelo Lógico - Entidades e Relacionamentos

Entidades Principais
1. Cliente
Armazena dados de clientes PF e PJ em tabela única
Campos: idCliente, Nome, Endereco, TipoCliente, CPF, DataNascimento, CNPJ, RazaoSocial, InscricaoEstadual
2. Pedido
Registra todos os pedidos do sistema
Campos: idPedido, Cliente_idCliente, StatusPedido, Descricao, Frete, DataPedido
Relacionamento: N:1 com Cliente
3. Produto
Catálogo de produtos disponíveis
Campos: idProduto, Categoria, Descricao, Valor, DataCadastro
4. Relacao_Produto_Pedido
Tabela associativa (N:M) entre Produto e Pedido
Campos: Produto_idProduto, Pedido_idPedido, Quantidade
5. Forma_Pagamento
Tipos de pagamento aceitos
Campos: idFormaPagamento, TipoPagamento, Descricao
6. Pagamento_Pedido
Tabela associativa (N:M) entre Pedido e Forma_Pagamento
Permite múltiplas formas de pagamento por pedido
Campos: idPagamentoPedido, Pedido_idPedido, FormaPagamento_idFormaPagamento, ValorPago, StatusPagamento
7. Entrega
Controle de entregas com rastreamento
Campos: idEntrega, Pedido_idPedido, StatusEntrega, CodigoRastreio, DataEnvio, DataEntregaPrevista, DataEntregaRealizada
Relacionamento: 1:1 com Pedido
8. Estoque
Locais de armazenamento
Campos: idEstoque, Local
9. Produto_has_Estoque
Tabela associativa (N:M) entre Produto e Estoque
Campos: Produto_idProduto, Estoque_idEstoque, Quantidade
10. Fornecedor
Cadastro de fornecedores
Campos: idFornecedor, RazaoSocial, CNPJ
11. Disponibilizando_Produto
Tabela associativa (N:M) entre Fornecedor e Produto
Campos: Fornecedor_idFornecedor, Produto_idProduto
12. Terceiro_Vendedor
Vendedores parceiros (marketplace)
Campos: idTerceiro_Vendedor, RazaoSocial, Local, CNPJ
13. Produtos_por_Vendedor
Tabela associativa (N:M) entre Terceiro_Vendedor e Produto
Campos: Terceiro_Vendedor_idTerceiro_Vendedor, Produto_idProduto, Quantidade

### Diagrama de Relacionamentos

Cliente (1) ----< (N) Pedido

Pedido (N) ----< (M) Produto [via Relacao_Produto_Pedido]

Pedido (N) ----< (M) Forma_Pagamento [via Pagamento_Pedido]

Pedido (1) ----< (1) Entrega

Produto (N) ----< (M) Estoque [via Produto_has_Estoque]

Produto (N) ----< (M) Fornecedor [via Disponibilizando_Produto]

Produto (N) ----< (M) Terceiro_Vendedor [via Produtos_por_Vendedor]

### 🔍 Queries SQL Implementadas

O projeto inclui 18 queries que respondem às seguintes perguntas de negócio:

Análise de Clientes

Q1: Quantos pedidos foram feitos por cada cliente?

Utiliza: SELECT, JOIN, GROUP BY, ORDER BY, CASE (atributo derivado)
Classifica clientes em categorias (Novo, Regular, VIP)

Q2: Qual a comparação entre clientes PF e PJ?

Utiliza: SELECT, GROUP BY, agregações (COUNT, AVG, SUM)
Analisa comportamento de compra por tipo de cliente

Q3: Quais são os TOP 10 clientes por receita?

Utiliza: SELECT, múltiplos JOIN, GROUP BY, ORDER BY, LIMIT
Calcula receita total incluindo frete

Q4: Qual a distribuição de clientes PF por faixa etária?

Utiliza: SELECT, WHERE, CASE, TIMESTAMPDIFF (atributo derivado)
Segmenta clientes por idade
Análise de Produtos e Estoque

Q5: Relação de produtos, fornecedores e estoques

Utiliza: múltiplos INNER JOIN, atributos derivados
Calcula valor total em estoque e status de criticidade

Q6: Quais produtos estão com estoque baixo?

Utiliza: SELECT, WHERE, JOIN, CASE, subquery
Identifica produtos que precisam reposição

Q7: Quais produtos nunca foram vendidos?

Utiliza: LEFT JOIN, WHERE ... IS NULL
Encontra produtos sem vendas

Q8: Qual o valor total em estoque por categoria?

Utiliza: GROUP BY, HAVING, agregações
Análise financeira do estoque

Q9: Quais são os produtos mais vendidos por categoria?

Utiliza: GROUP BY, HAVING, ORDER BY
Ranking de produtos por desempenho
Análise de Fornecedores e Vendedores

Q10: Relação de fornecedores e seus produtos

Utiliza: GROUP_CONCAT, agregações, ORDER BY
Visão consolidada por fornecedor

Q11: Algum vendedor também é fornecedor?

Utiliza: INNER JOIN, UNION, comparação de CNPJ
Identifica sobreposição de papéis

Q12: Quais vendedores terceiros têm mais produtos?

Utiliza: GROUP BY, HAVING, GROUP_CONCAT
Análise de marketplace
Análise de Pedidos e Entregas

Q13: Quais pedidos possuem múltiplas formas de pagamento?

Utiliza: GROUP BY, HAVING, GROUP_CONCAT
Identifica pagamentos parcelados/mistos

Q14: Qual o status das entregas e tempo médio de entrega?

Utiliza: DATEDIFF, CASE, atributos derivados
Análise de performance logística

Q15: Pedidos com valor total e detalhes de entrega

Utiliza: múltiplos JOIN, agregações, CASE
Visão completa do pedido
Análise Financeira

Q16: Quais são as formas de pagamento mais utilizadas?

Utiliza: GROUP BY, HAVING, CASE, agregações
Calcula taxa de aprovação por forma de pagamento

Q17: Análise de receita por categoria

Utiliza: agregações, ORDER BY
Identifica categorias mais lucrativas

Q18: Resumo executivo (Dashboard)

Utiliza: UNION ALL, agregações

### 📁 Estrutura do Projeto

[Script de criação do banco](schema/create_database.sql)

[Script de inserção de dados de teste](data/insert_data.sql)

[Queries de análise de e-commerce](queries/queries.sql)

[Diagrama EER](docs/modelo_eer.png)

### 🚀 Como Executar o Projeto
- Pré-requisitos
- MySQL 8.0 ou superior
- Cliente MySQL (MySQL Workbench, DBeaver, ou linha de comando)

Passo 1: Criar o Banco de Dados
```Bash

mysql -u seu_usuario -p < schema/create_database.sql
```
Passo 2: Inserir Dados de Teste
```Bash

mysql -u seu_usuario -p ecommerce < data/insert_data.sql
```
Passo 3: Executar as Queries
```Bash

# Executar todas as queries
mysql -u seu_usuario -p ecommerce < queries/queries.sql
```

### 🎓 Conceitos Aplicados
Modelagem de Dados
- ✅ Mapeamento de modelo EER para modelo relacional
- ✅ Normalização (3FN)
- ✅ Identificação de entidades e relacionamentos
- ✅ Definição de chaves primárias e estrangeiras
- ✅ Constraints e Integridade
- ✅ PRIMARY KEY - Identificação única de registros
- ✅ FOREIGN KEY - Integridade referencial
- ✅ UNIQUE - Unicidade de valores (CPF, CNPJ, Código de Rastreio)
- ✅ CHECK - Validação de regras de negócio
- ✅ NOT NULL - Obrigatoriedade de campos
- ✅ DEFAULT - Valores padrão

SQL Avançado
- ✅ SELECT com múltiplas tabelas
- ✅ WHERE com condições complexas
- ✅ JOIN (INNER, LEFT, múltiplos)
- ✅ GROUP BY e HAVING
- ✅ ORDER BY com múltiplos critérios
- ✅ Funções de agregação (COUNT, SUM, AVG, MIN, MAX)
- ✅ Funções de string (CONCAT, GROUP_CONCAT)
- ✅ Funções de data (DATEDIFF, TIMESTAMPDIFF, DATE_SUB)
- ✅ CASE para atributos derivados
- ✅ Subqueries
- ✅ UNION e UNION ALL

### 📚 Referências
- Modelagem de Dados - Conceitual, Lógica e Física
- MySQL 8.0 Reference Manual
- Database Design Best Practices
- SQL Performance Tuning

Desenvolvido como parte do Desafio de Projeto - Modelagem de Banco de Dados para E-commerce da Digital Innovation One (DIO).

⭐ Se este projeto foi útil para você, considere dar uma estrela no repositório!

### 🔗 Links Úteis:

- [Documentação MySQL](https://dev.mysql.com/doc/)
- [SQL Tutorial](https://www.w3schools.com/sql/)
- [Database Design Guide](https://www.lucidchart.com/pages/database-diagram/database-design)
