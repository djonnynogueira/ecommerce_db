-- =============================================
-- INSERÇÃO DE DADOS PARA TESTES
-- =============================================

-- Inserindo Clientes Pessoa Física (PF)
INSERT INTO Cliente (Nome, Endereco, TipoCliente, CPF, DataNascimento) VALUES
('João Silva', 'Rua das São Paulo - SP', 'PF', '12345678901', '1990-05-15'),
('Maria Santos', 'Av. Paulista, 1000, São Paulo - SP', 'PF', '98765432109', '1985-08-20'),
('Pedro Oliveira', 'Rua Augusta, 500, São Paulo - SP', 'PF', '45678912345', '1995-03-10'),
('Ana Costa', 'Rua XV de Novembro, 200, Curitiba - PR', 'PF', '78945612378', '1992-11-25'),
('Carlos Mendes', 'Av. Atlântica, 800, Rio de Janeiro - RJ', 'PF', '32165498732', '1988-07-08');

-- Inserindo Clientes Pessoa Jurídica (PJ)
INSERT INTO Cliente (Nome, Endereco, TipoCliente, CNPJ, RazaoSocial, InscricaoEstadual) VALUES
('Tech Solutions', 'Av. Faria Lima, 2000, São Paulo - SP', 'PJ', '12345678000190', 'Tech Solutions Ltda', '123456789'),
('Comercial ABC', 'Rua do Comércio, 300, Rio de Janeiro - RJ', 'PJ', '98765432000180', 'Comercial ABC Ltda', '987654321'),
('Indústria XYZ', 'Av. Industrial, 1500, Belo Horizonte - MG', 'PJ', '11122233000144', 'Indústria XYZ S.A.', '111222333'),
('Distribuidora Beta', 'Rua dos Distribuidores, 450, Porto Alegre - RS', 'PJ', '55566677000155', 'Distribuidora Beta Ltda', '555666777');

-- Inserindo Produtos
INSERT INTO Produto (Categoria, Descricao, Valor) VALUES
('Eletrônicos', 'Notebook Dell Inspiron 15', 3500.00),
('Eletrônicos', 'Mouse Logitech MX Master', 350.00),
('Eletrônicos', 'Teclado Mecânico Keychron', 450.00),
('Eletrônicos', 'Monitor LG 27 Polegadas', 1200.00),
('Eletrônicos', 'Webcam Logitech C920', 550.00),
('Livros', 'Clean Code - Robert Martin', 85.00),
('Livros', 'Design Patterns', 120.00),
('Livros', 'Refactoring - Martin Fowler', 95.00),
('Móveis', 'Cadeira Gamer DT3', 1200.00),
('Móveis', 'Mesa para Computador', 600.00),
('Móveis', 'Estante para Livros', 450.00),
('Roupas', 'Camiseta Básica', 45.00),
('Roupas', 'Calça Jeans', 150.00),
('Roupas', 'Jaqueta de Couro', 380.00),
('Esportes', 'Tênis Nike Running', 400.00),
('Esportes', 'Bola de Futebol Adidas', 120.00),
('Esportes', 'Raquete de Tênis Wilson', 650.00);

-- Inserindo Estoques
INSERT INTO Estoque (Local) VALUES
('Armazém São Paulo - Centro'),
('Armazém Rio de Janeiro - Zona Sul'),
('Armazém Belo Horizonte - Centro'),
('Armazém Curitiba - Industrial');

-- Inserindo Produtos em Estoque
INSERT INTO Produto_has_Estoque (Produto_idProduto, Estoque_idEstoque, Quantidade) VALUES
(1, 1, 50), (1, 2, 30), (1, 3, 25),
(2, 1, 100), (2, 3, 80), (2, 4, 60),
(3, 1, 75), (3, 2, 60), (3, 4, 45),
(4, 1, 40), (4, 2, 35), (4, 3, 30),
(5, 2, 55), (5, 3, 40),
(6, 2, 200), (6, 3, 150), (6, 4, 180),
(7, 1, 100), (7, 2, 80), (7, 3, 90),
(8, 1, 120), (8, 4, 100),
(9, 1, 40), (9, 3, 25), (9, 4, 30),
(10, 1, 60), (10, 2, 45), (10, 3, 50),
(11, 1, 35), (11, 2, 28),
(12, 2, 300), (12, 3, 250), (12, 4, 280),
(13, 1, 150), (13, 2, 120), (13, 4, 140),
(14, 1, 45), (14, 3, 38),
(15, 1, 80), (15, 3, 60), (15, 4, 70),
(16, 2, 150), (16, 3, 120),
(17, 1, 25), (17, 2, 20);

-- Inserindo Fornecedores
INSERT INTO Fornecedor (RazaoSocial, CNPJ) VALUES
('Dell Computadores do Brasil', '11111111000111'),
('Logitech Brasil Ltda', '22222222000122'),
('Keychron International', '33333333000133'),
('LG Electronics', '44444444000144'),
('Editora Alta Books', '55555555000155'),
('Editora Novatec', '66666666000166'),
('Móveis Office Premium', '77777777000177'),
('Confecções Moda Brasil', '88888888000188'),
('Nike do Brasil', '99999999000199'),
('Adidas Brasil', '10101010000110');

-- Inserindo Disponibilização de Produtos por Fornecedor
INSERT INTO Disponibilizando_Produto (Fornecedor_idFornecedor, Produto_idProduto) VALUES
(1, 1), (2, 2), (2, 5), (3, 3), (4, 4),
(5, 6), (5, 7), (6, 8),
(7, 9), (7, 10), (7, 11),
(8, 12), (8, 13), (8, 14),
(9, 15), (10, 16), (10, 17);

-- Inserindo Terceiros Vendedores
INSERT INTO Terceiro_Vendedor (RazaoSocial, Local, CNPJ) VALUES
('Vendedor Premium SP', 'São Paulo - SP', '66666666000166'),
('Marketplace Rio', 'Rio de Janeiro - RJ', '77777777000177'),
('Vendas Online BH', 'Belo Horizonte - MG', '88888888000188'),
('E-commerce Sul', 'Porto Alegre - RS', '99999999000199');

-- Inserindo Produtos por Vendedor
INSERT INTO Produtos_por_Vendedor (Terceiro_Vendedor_idTerceiro_Vendedor, Produto_idProduto, Quantidade) VALUES
(1, 1, 10), (1, 2, 25), (1, 9, 5), (1, 15, 15),
(2, 3, 15), (2, 6, 50), (2, 12, 100), (2, 13, 80),
(3, 7, 30), (3, 13, 80), (3, 15, 20), (3, 4, 12),
(4, 9, 8), (4, 10, 15), (4, 16, 40), (4, 17, 10);

-- Inserindo Pedidos
INSERT INTO Pedido (Cliente_idCliente, StatusPedido, Descricao, Frete) VALUES
(1, 'Confirmado', 'Pedido de notebook e acessórios', 50.00),
(1, 'Enviado', 'Pedido de livros técnicos', 15.00),
(2, 'Entregue', 'Pedido de móveis para escritório', 120.00),
(3, 'Processando', 'Pedido de roupas', 20.00),
(4, 'Entregue', 'Pedido de tênis esportivo', 25.00),
(5, 'Cancelado', 'Pedido cancelado pelo cliente', 0.00),
(6, 'Confirmado', 'Pedido corporativo de eletrônicos', 80.00),
(7, 'Enviado', 'Pedido de material de escritório', 35.00),
(8, 'Entregue', 'Pedido de equipamentos de informática', 95.00),
(9, 'Confirmado', 'Pedido de móveis corporativos', 150.00),
(1, 'Enviado', 'Segundo pedido de eletrônicos', 45.00),
(2, 'Processando', 'Pedido de livros e roupas', 30.00);

-- Inserindo Relação Produto-Pedido
INSERT INTO Relacao_Produto_Pedido (Produto_idProduto, Pedido_idPedido, Quantidade) VALUES
(1, 1, 1), (2, 1, 2), (3, 1, 1),
(6, 2, 3), (7, 2, 2), (8, 2, 1),
(9, 3, 1), (10, 3, 1), (11, 3, 1),
(12, 4, 5), (13, 4, 3), (14, 4, 2),
(15, 5, 1), (16, 5, 2),
(9, 6, 1),
(1, 7, 5), (2, 7, 10), (4, 7, 3),
(6, 8, 10), (7, 8, 8), (8, 8, 5),
(1, 9, 3), (4, 9, 2), (5, 9, 2),
(9, 10, 3), (10, 10, 3), (11, 10, 2),
(4, 11, 1), (5, 11, 1),
(6, 12, 2), (12, 12, 4), (13, 12, 2);

-- Inserindo Formas de Pagamento
INSERT INTO Forma_Pagamento (TipoPagamento, Descricao) VALUES
('Cartão Crédito', 'Visa/Master/Elo - até 12x'),
('Cartão Débito', 'Débito à vista'),
('PIX', 'Pagamento instantâneo'),
('Boleto', 'Boleto bancário - vencimento em 3 dias'),
('Transferência', 'Transferência bancária');

-- Inserindo Pagamentos (alguns pedidos com múltiplas formas)
INSERT INTO Pagamento_Pedido (Pedido_idPedido, FormaPagamento_idFormaPagamento, ValorPago, StatusPagamento) VALUES
(1, 1, 3000.00, 'Aprovado'),
(1, 3, 1250.00, 'Aprovado'),  -- Pedido 1 com 2 formas de pagamento
(2, 3, 415.00, 'Aprovado'),
(3, 1, 2370.00, 'Aprovado'),
(4, 2, 635.00, 'Pendente'),
(5, 3, 665.00, 'Aprovado'),
(7, 1, 4580.00, 'Aprovado'),
(8, 4, 1615.00, 'Aprovado'),
(9, 1, 5000.00, 'Aprovado'),
(9, 3, 2395.00, 'Aprovado'),  -- Pedido 9 com 2 formas de pagamento
(10, 1, 3750.00, 'Aprovado'),
(11, 3, 1795.00, 'Aprovado'),
(12, 2, 640.00, 'Pendente');

-- Inserindo Entregas
INSERT INTO Entrega (Pedido_idPedido, StatusEntrega, CodigoRastreio, DataEnvio, DataEntregaPrevista) VALUES
(1, 'Em Trânsito', 'BR123456789SP', '2025-11-05', '2025-11-12'),
(2, 'Saiu para Entrega', 'BR987654321SP', '2025-11-03', '2025-11-08'),
(3, 'Entregue', 'BR456789123RJ', '2025-10-28', '2025-11-02'),
(5, 'Entregue', 'BR654987321RJ', '2025-10-25', '2025-10-30'),
(7, 'Em Trânsito', 'BR789123456MG', '2025-11-06', '2025-11-13'),
(8, 'Entregue', 'BR321654987SP', '2025-10-20', '2025-10-27'),
(9, 'Entregue', 'BR147258369BH', '2025-10-15', '2025-10-22'),
(10, 'Preparando', 'BR963852741PA', '2025-11-07', '2025-11-14'),
(11, 'Em Trânsito', 'BR741852963SP', '2025-11-06', '2025-11-11');

UPDATE Entrega SET DataEntregaRealizada = '2025-11-01' WHERE idEntrega = 3;
UPDATE Entrega SET DataEntregaRealizada = '2025-10-29' WHERE idEntrega = 4;
UPDATE Entrega SET DataEntregaRealizada = '2025-10-26' WHERE idEntrega = 6;
UPDATE Entrega SET DataEntregaRealizada = '2025-10-21' WHERE idEntrega = 7;
