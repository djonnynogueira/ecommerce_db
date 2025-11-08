-- =============================================
-- E-COMMERCE DATABASE SCHEMA
-- =============================================

CREATE DATABASE IF NOT EXISTS ecommerce;
USE ecommerce;

-- =============================================
-- TABELA: Cliente (Tabela Única - PF e PJ)
-- =============================================
CREATE TABLE Cliente (
    idCliente INT AUTO_INCREMENT PRIMARY KEY,
    Nome VARCHAR(100) NOT NULL,
    Endereco VARCHAR(255),
    TipoCliente ENUM('PF', 'PJ') NOT NULL,
    
    -- Campos específicos para Pessoa Física
    CPF CHAR(11) UNIQUE,
    DataNascimento DATE,
    
    -- Campos específicos para Pessoa Jurídica
    CNPJ CHAR(14) UNIQUE,
    RazaoSocial VARCHAR(100),
    InscricaoEstadual VARCHAR(20),
    
    DataCadastro TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    
    -- Constraint para garantir que PF tenha CPF e PJ tenha CNPJ
    CONSTRAINT chk_cliente_pf_pj CHECK (
        (TipoCliente = 'PF' AND CPF IS NOT NULL AND CNPJ IS NULL) OR
        (TipoCliente = 'PJ' AND CNPJ IS NOT NULL AND CPF IS NULL)
    )
);

-- Índices para otimização de busca
CREATE INDEX idx_cliente_tipo ON Cliente(TipoCliente);
CREATE INDEX idx_cliente_cpf ON Cliente(CPF);
CREATE INDEX idx_cliente_cnpj ON Cliente(CNPJ);

-- =============================================
-- TABELA: Pedido
-- =============================================
CREATE TABLE Pedido (
    idPedido INT AUTO_INCREMENT PRIMARY KEY,
    Cliente_idCliente INT NOT NULL,
    StatusPedido ENUM('Processando', 'Confirmado', 'Enviado', 'Entregue', 'Cancelado') DEFAULT 'Processando',
    Descricao VARCHAR(255),
    Frete DECIMAL(10,2) DEFAULT 0.00,
    DataPedido TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    CONSTRAINT fk_pedido_cliente FOREIGN KEY (Cliente_idCliente) 
        REFERENCES Cliente(idCliente)
);

CREATE INDEX idx_pedido_status ON Pedido(StatusPedido);
CREATE INDEX idx_pedido_data ON Pedido(DataPedido);

-- =============================================
-- TABELA: Forma_Pagamento
-- =============================================
CREATE TABLE Forma_Pagamento (
    idFormaPagamento INT AUTO_INCREMENT PRIMARY KEY,
    TipoPagamento ENUM('Cartão Crédito', 'Cartão Débito', 'PIX', 'Boleto', 'Transferência') NOT NULL,
    Descricao VARCHAR(100)
);

-- =============================================
-- TABELA: Pagamento_Pedido
-- Um pedido pode ter múltiplas formas de pagamento
-- =============================================
CREATE TABLE Pagamento_Pedido (
    idPagamentoPedido INT AUTO_INCREMENT PRIMARY KEY,
    Pedido_idPedido INT NOT NULL,
    FormaPagamento_idFormaPagamento INT NOT NULL,
    ValorPago DECIMAL(10,2) NOT NULL,
    DataPagamento TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    StatusPagamento ENUM('Pendente', 'Aprovado', 'Recusado') DEFAULT 'Pendente',
    CONSTRAINT fk_pagamento_pedido FOREIGN KEY (Pedido_idPedido) 
        REFERENCES Pedido(idPedido),
    CONSTRAINT fk_pagamento_forma FOREIGN KEY (FormaPagamento_idFormaPagamento) 
        REFERENCES Forma_Pagamento(idFormaPagamento)
);

CREATE INDEX idx_pagamento_status ON Pagamento_Pedido(StatusPagamento);

-- =============================================
-- TABELA: Entrega
-- Possui status e código de rastreio
-- =============================================
CREATE TABLE Entrega (
    idEntrega INT AUTO_INCREMENT PRIMARY KEY,
    Pedido_idPedido INT NOT NULL UNIQUE,
    StatusEntrega ENUM('Preparando', 'Em Trânsito', 'Saiu para Entrega', 'Entregue', 'Devolvido') DEFAULT 'Preparando',
    CodigoRastreio VARCHAR(50) UNIQUE,
    DataEnvio DATE,
    DataEntregaPrevista DATE,
    DataEntregaRealizada DATE,
    CONSTRAINT fk_entrega_pedido FOREIGN KEY (Pedido_idPedido) 
        REFERENCES Pedido(idPedido)
);

CREATE INDEX idx_entrega_status ON Entrega(StatusEntrega);
CREATE INDEX idx_entrega_rastreio ON Entrega(CodigoRastreio);

-- =============================================
-- TABELA: Produto
-- =============================================
CREATE TABLE Produto (
    idProduto INT AUTO_INCREMENT PRIMARY KEY,
    Categoria VARCHAR(45),
    Descricao VARCHAR(255),
    Valor DECIMAL(10,2) NOT NULL,
    DataCadastro TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

CREATE INDEX idx_produto_categoria ON Produto(Categoria);

-- =============================================
-- TABELA: Relacao_Produto_Pedido
-- =============================================
CREATE TABLE Relacao_Produto_Pedido (
    Produto_idProduto INT NOT NULL,
    Pedido_idPedido INT NOT NULL,
    Quantidade INT NOT NULL DEFAULT 1,
    PRIMARY KEY (Produto_idProduto, Pedido_idPedido),
    CONSTRAINT fk_relacao_produto FOREIGN KEY (Produto_idProduto) 
        REFERENCES Produto(idProduto),
    CONSTRAINT fk_relacao_pedido FOREIGN KEY (Pedido_idPedido) 
        REFERENCES Pedido(idPedido)
);

-- =============================================
-- TABELA: Estoque
-- =============================================
CREATE TABLE Estoque (
    idEstoque INT AUTO_INCREMENT PRIMARY KEY,
    Local VARCHAR(100) NOT NULL
);

-- =============================================
-- TABELA: Produto_has_Estoque
-- =============================================
CREATE TABLE Produto_has_Estoque (
    Produto_idProduto INT NOT NULL,
    Estoque_idEstoque INT NOT NULL,
    Quantidade INT NOT NULL DEFAULT 0,
    PRIMARY KEY (Produto_idProduto, Estoque_idEstoque),
    CONSTRAINT fk_produto_estoque_produto FOREIGN KEY (Produto_idProduto) 
        REFERENCES Produto(idProduto),
    CONSTRAINT fk_produto_estoque_estoque FOREIGN KEY (Estoque_idEstoque) 
        REFERENCES Estoque(idEstoque)
);

-- =============================================
-- TABELA: Fornecedor
-- =============================================
CREATE TABLE Fornecedor (
    idFornecedor INT AUTO_INCREMENT PRIMARY KEY,
    RazaoSocial VARCHAR(100) NOT NULL,
    CNPJ CHAR(14) NOT NULL UNIQUE
);

-- =============================================
-- TABELA: Disponibilizando_Produto
-- Relação entre Fornecedor e Produto
-- =============================================
CREATE TABLE Disponibilizando_Produto (
    Fornecedor_idFornecedor INT NOT NULL,
    Produto_idProduto INT NOT NULL,
    PRIMARY KEY (Fornecedor_idFornecedor, Produto_idProduto),
    CONSTRAINT fk_disponibilizando_fornecedor FOREIGN KEY (Fornecedor_idFornecedor) 
        REFERENCES Fornecedor(idFornecedor),
    CONSTRAINT fk_disponibilizando_produto FOREIGN KEY (Produto_idProduto) 
        REFERENCES Produto(idProduto)
);

-- =============================================
-- TABELA: Terceiro_Vendedor
-- =============================================
CREATE TABLE Terceiro_Vendedor (
    idTerceiro_Vendedor INT AUTO_INCREMENT PRIMARY KEY,
    RazaoSocial VARCHAR(100) NOT NULL,
    Local VARCHAR(100),
    CNPJ CHAR(14) UNIQUE
);

-- =============================================
-- TABELA: Produtos_por_Vendedor
-- =============================================
CREATE TABLE Produtos_por_Vendedor (
    Terceiro_Vendedor_idTerceiro_Vendedor INT NOT NULL,
    Produto_idProduto INT NOT NULL,
    Quantidade INT NOT NULL DEFAULT 1,
    PRIMARY KEY (Terceiro_Vendedor_idTerceiro_Vendedor, Produto_idProduto),
    CONSTRAINT fk_produtos_vendedor FOREIGN KEY (Terceiro_Vendedor_idTerceiro_Vendedor) 
        REFERENCES Terceiro_Vendedor(idTerceiro_Vendedor),
    CONSTRAINT fk_produtos_vendedor_produto FOREIGN KEY (Produto_idProduto) 
        REFERENCES Produto(idProduto)
);
