-- =============================================
-- QUERIES - E-COMMERCE
-- =============================================

-- =============================================
-- QUERY 1: Quantos pedidos foram feitos por cada cliente?
-- Agora MUITO mais simples sem JOINs extras!
-- =============================================
SELECT 
    c.idCliente,
    c.Nome,
    c.TipoCliente,
    CASE 
        WHEN c.TipoCliente = 'PF' THEN c.CPF
        ELSE c.CNPJ
    END AS Documento,
    COUNT(p.idPedido) AS TotalPedidos,
    SUM(p.Frete) AS TotalFrete,
    CASE 
        WHEN COUNT(p.idPedido) = 0 THEN 'Sem Pedidos'
        WHEN COUNT(p.idPedido) <= 2 THEN 'Cliente Novo'
        WHEN COUNT(p.idPedido) <= 5 THEN 'Cliente Regular'
        ELSE 'Cliente VIP'
    END AS CategoriaCliente
FROM Cliente c
LEFT JOIN Pedido p ON c.idCliente = p.Cliente_idCliente
GROUP BY c.idCliente, c.Nome, c.TipoCliente, Documento
ORDER BY TotalPedidos DESC, c.Nome;

-- =============================================
-- QUERY 2: Comparação entre Clientes PF e PJ
-- Análise de comportamento de compra
-- =============================================
SELECT 
    c.TipoCliente,
    COUNT(DISTINCT c.idCliente) AS TotalClientes,
    COUNT(p.idPedido) AS TotalPedidos,
    AVG(CASE WHEN p.idPedido IS NOT NULL THEN 1 ELSE 0 END) AS MediaPedidosPorCliente,
    SUM(p.Frete) AS TotalFrete,
    AVG(p.Frete) AS FreteMedia
FROM Cliente c
LEFT JOIN Pedido p ON c.idCliente = p.Cliente_idCliente
GROUP BY c.TipoCliente
ORDER BY TotalPedidos DESC;

-- =============================================
-- QUERY 3: Detalhes completos dos clientes com seus pedidos
-- (Informações específicas de PF e PJ na mesma query)
-- =============================================
SELECT 
    c.idCliente,
    c.Nome,
    c.TipoCliente,
    c.Endereco,
    -- Campos específicos de PF
    c.CPF,
    c.DataNascimento,
    CASE 
        WHEN c.DataNascimento IS NOT NULL 
        THEN TIMESTAMPDIFF(YEAR, c.DataNascimento, CURDATE())
        ELSE NULL
    END AS Idade,
    -- Campos específicos de PJ
    c.CNPJ,
    c.RazaoSocial,
    c.InscricaoEstadual,
    -- Estatísticas de pedidos
    COUNT(p.idPedido) AS TotalPedidos,
    SUM(CASE WHEN p.StatusPedido = 'Entregue' THEN 1 ELSE 0 END) AS PedidosEntregues,
    SUM(CASE WHEN p.StatusPedido = 'Cancelado' THEN 1 ELSE 0 END) AS PedidosCancelados
FROM Cliente c
LEFT JOIN Pedido p ON c.idCliente = p.Cliente_idCliente
GROUP BY c.idCliente, c.Nome, c.TipoCliente, c.Endereco, 
         c.CPF, c.DataNascimento, c.CNPJ, c.RazaoSocial, c.InscricaoEstadual
ORDER BY TotalPedidos DESC;

-- =============================================
-- QUERY 4: Algum vendedor também é fornecedor?
-- (Comparação de CNPJ)
-- =============================================
SELECT 
    tv.idTerceiro_Vendedor,
    tv.RazaoSocial AS RazaoSocial_Vendedor,
    tv.CNPJ AS CNPJ_Vendedor,
    f.idFornecedor,
    f.RazaoSocial AS RazaoSocial_Fornecedor,
    'SIM - É Vendedor e Fornecedor' AS Status
FROM Terceiro_Vendedor tv
INNER JOIN Fornecedor f ON tv.CNPJ = f.CNPJ

UNION ALL

SELECT 
    NULL,
    NULL,
    NULL,
    NULL,
    NULL,
    CASE 
        WHEN NOT EXISTS (
            SELECT 1 FROM Terceiro_Vendedor tv2
            INNER JOIN Fornecedor f2 ON tv2.CNPJ = f2.CNPJ
        ) THEN 'NÃO - Nenhum vendedor é fornecedor'
    END
WHERE NOT EXISTS (
    SELECT 1 FROM Terceiro_Vendedor tv2
    INNER JOIN Fornecedor f2 ON tv2.CNPJ = f2.CNPJ
);

-- =============================================
-- QUERY 5: Relação de produtos, fornecedores e estoques
-- =============================================
SELECT 
    p.idProduto,
    p.Descricao AS Produto,
    p.Categoria,
    p.Valor,
    f.RazaoSocial AS Fornecedor,
    e.Local AS LocalEstoque,
    pe.Quantidade AS QuantidadeEstoque,
    (p.Valor * pe.Quantidade) AS ValorTotalEstoque,
    CASE 
        WHEN pe.Quantidade = 0 THEN 'SEM ESTOQUE'
        WHEN pe.Quantidade < 30 THEN 'CRÍTICO'
        WHEN pe.Quantidade < 50 THEN 'BAIXO'
        WHEN pe.Quantidade < 100 THEN 'NORMAL'
        ELSE 'ALTO'
    END AS StatusEstoque
FROM Produto p
INNER JOIN Disponibilizando_Produto dp ON p.idProduto = dp.Produto_idProduto
INNER JOIN Fornecedor f ON dp.Fornecedor_idFornecedor = f.idFornecedor
INNER JOIN Produto_has_Estoque pe ON p.idProduto = pe.Produto_idProduto
INNER JOIN Estoque e ON pe.Estoque_idEstoque = e.idEstoque
ORDER BY p.Categoria, p.Descricao, e.Local;

-- =============================================
-- QUERY 6: Relação de nomes dos fornecedores e nomes dos produtos
-- =============================================
SELECT 
    f.RazaoSocial AS Fornecedor,
    f.CNPJ,
    COUNT(DISTINCT p.idProduto) AS QuantidadeProdutos,
    GROUP_CONCAT(DISTINCT p.Categoria ORDER BY p.Categoria SEPARATOR ', ') AS Categorias,
    GROUP_CONCAT(p.Descricao ORDER BY p.Descricao SEPARATOR ' | ') AS Produtos,
    MIN(p.Valor) AS MenorPreco,
    MAX(p.Valor) AS MaiorPreco,
    AVG(p.Valor) AS PrecoMedio
FROM Fornecedor f
INNER JOIN Disponibilizando_Produto dp ON f.idFornecedor = dp.Fornecedor_idFornecedor
INNER JOIN Produto p ON dp.Produto_idProduto = p.idProduto
GROUP BY f.RazaoSocial, f.CNPJ
ORDER BY QuantidadeProdutos DESC, f.RazaoSocial;

-- =============================================
-- QUERY 7: Pedidos com valor total e detalhes de entrega
-- Incluindo informações do cliente (PF ou PJ)
-- =============================================
SELECT 
    ped.idPedido,
    c.Nome AS Cliente,
    c.TipoCliente,
    CASE 
        WHEN c.TipoCliente = 'PF' THEN CONCAT('CPF: ', c.CPF)
        ELSE CONCAT('CNPJ: ', c.CNPJ)
    END AS DocumentoCliente,
    ped.StatusPedido,
    ped.DataPedido,
    COUNT(DISTINCT rpp.Produto_idProduto) AS TotalProdutosDiferentes,
    SUM(rpp.Quantidade) AS TotalItens,
    SUM(p.Valor * rpp.Quantidade) AS ValorProdutos,
    ped.Frete,
    SUM(p.Valor * rpp.Quantidade) + ped.Frete AS ValorTotal,
    e.StatusEntrega,
    e.CodigoRastreio,
    e.DataEntregaPrevista,
    e.DataEntregaRealizada
FROM Pedido ped
INNER JOIN Cliente c ON ped.Cliente_idCliente = c.idCliente
INNER JOIN Relacao_Produto_Pedido rpp ON ped.idPedido = rpp.Pedido_idPedido
INNER JOIN Produto p ON rpp.Produto_idProduto = p.idProduto
LEFT JOIN Entrega e ON ped.idPedido = e.Pedido_idPedido
WHERE ped.StatusPedido != 'Cancelado'
GROUP BY ped.idPedido, c.Nome, c.TipoCliente, DocumentoCliente, ped.StatusPedido, 
         ped.DataPedido, ped.Frete, e.StatusEntrega, e.CodigoRastreio, 
         e.DataEntregaPrevista, e.DataEntregaRealizada
ORDER BY ped.DataPedido DESC;

-- =============================================
-- QUERY 8: Produtos mais vendidos por categoria
-- =============================================
SELECT 
    p.Categoria,
    p.Descricao AS Produto,
    COUNT(DISTINCT rpp.Pedido_idPedido) AS QuantidadePedidos,
    SUM(rpp.Quantidade) AS TotalVendido,
    p.Valor,
    SUM(p.Valor * rpp.Quantidade) AS ReceitaTotal,
    AVG(rpp.Quantidade) AS MediaQuantidadePorPedido
FROM Produto p
INNER JOIN Relacao_Produto_Pedido rpp ON p.idProduto = rpp.Produto_idProduto
INNER JOIN Pedido ped ON rpp.Pedido_idPedido = ped.idPedido
WHERE ped.StatusPedido != 'Cancelado'
GROUP BY p.Categoria, p.Descricao, p.Valor
HAVING TotalVendido > 0
ORDER BY p.Categoria, TotalVendido DESC, ReceitaTotal DESC;

-- =============================================
-- QUERY 9: TOP 10 Clientes por Receita
-- Mostrando se é PF ou PJ
-- =============================================
SELECT 
    c.idCliente,
    c.Nome,
    c.TipoCliente,
    CASE 
        WHEN c.TipoCliente = 'PF' THEN c.CPF
        ELSE c.CNPJ
    END AS Documento,
    CASE 
        WHEN c.TipoCliente = 'PJ' THEN c.RazaoSocial
        ELSE NULL
    END AS RazaoSocial,
    COUNT(DISTINCT ped.idPedido) AS TotalPedidos,
    SUM(rpp.Quantidade) AS TotalItensPedidos,
    SUM(p.Valor * rpp.Quantidade) AS ValorProdutos,
    SUM(ped.Frete) AS TotalFrete,
    SUM(p.Valor * rpp.Quantidade) + SUM(ped.Frete) AS ReceitaTotal,
    AVG(p.Valor * rpp.Quantidade) AS TicketMedioProdutos
FROM Cliente c
INNER JOIN Pedido ped ON c.idCliente = ped.Cliente_idCliente
INNER JOIN Relacao_Produto_Pedido rpp ON ped.idPedido = rpp.Pedido_idPedido
INNER JOIN Produto p ON rpp.Produto_idProduto = p.idProduto
WHERE ped.StatusPedido != 'Cancelado'
GROUP BY c.idCliente, c.Nome, c.TipoCliente, Documento, RazaoSocial
ORDER BY ReceitaTotal DESC
LIMIT 10;

-- =============================================
-- QUERY 10: Formas de pagamento mais utilizadas
-- =============================================
SELECT 
    fp.TipoPagamento,
    fp.Descricao,
    COUNT(pp.idPagamentoPedido) AS QuantidadeUsos,
    SUM(pp.ValorPago) AS ValorTotal,
    AVG(pp.ValorPago) AS TicketMedio,
    MIN(pp.ValorPago) AS MenorValor,
    MAX(pp.ValorPago) AS MaiorValor,
    COUNT(CASE WHEN pp.StatusPagamento = 'Aprovado' THEN 1 END) AS PagamentosAprovados,
    COUNT(CASE WHEN pp.StatusPagamento = 'Pendente' THEN 1 END) AS PagamentosPendentes,
    COUNT(CASE WHEN pp.StatusPagamento = 'Recusado' THEN 1 END) AS PagamentosRecusados,
    ROUND(COUNT(CASE WHEN pp.StatusPagamento = 'Aprovado' THEN 1 END) * 100.0 / COUNT(*), 2) AS TaxaAprovacao
FROM Forma_Pagamento fp
INNER JOIN Pagamento_Pedido pp ON fp.idFormaPagamento = pp.FormaPagamento_idFormaPagamento
GROUP BY fp.TipoPagamento, fp.Descricao
HAVING QuantidadeUsos > 0
ORDER BY ValorTotal DESC;

-- =============================================
-- QUERY 11: Pedidos com múltiplas formas de pagamento
-- Incluindo tipo de cliente
-- =============================================
SELECT 
    ped.idPedido,
    c.Nome AS Cliente,
    c.TipoCliente,
    COUNT(pp.idPagamentoPedido) AS QuantidadeFormasPagamento,
    GROUP_CONCAT(
        CONCAT(fp.TipoPagamento, ': R$ ', FORMAT(pp.ValorPago, 2)) 
        ORDER BY pp.ValorPago DESC 
        SEPARATOR ' | '
    ) AS DetalhePagamentos,
    SUM(pp.ValorPago) AS ValorTotalPago
FROM Pedido ped
INNER JOIN Cliente c ON ped.Cliente_idCliente = c.idCliente
INNER JOIN Pagamento_Pedido pp ON ped.idPedido = pp.Pedido_idPedido
INNER JOIN Forma_Pagamento fp ON pp.FormaPagamento_idFormaPagamento = fp.idFormaPagamento
GROUP BY ped.idPedido, c.Nome, c.TipoCliente
HAVING QuantidadeFormasPagamento > 1
ORDER BY QuantidadeFormasPagamento DESC, ValorTotalPago DESC;

-- =============================================
-- QUERY 12: Status de entregas e tempo de entrega
-- =============================================
SELECT 
    e.idEntrega,
    ped.idPedido,
    c.Nome AS Cliente,
    c.TipoCliente,
    e.StatusEntrega,
    e.CodigoRastreio,
    e.DataEnvio,
    e.DataEntregaPrevista,
    e.DataEntregaRealizada,
    DATEDIFF(e.DataEntregaPrevista, e.DataEnvio) AS PrazoEntregaDias,
    CASE 
        WHEN e.DataEntregaRealizada IS NULL THEN 
            DATEDIFF(CURDATE(), e.DataEnvio)
        ELSE 
            DATEDIFF(e.DataEntregaRealizada, e.DataEnvio)
    END AS TempoDecorridoDias,
    CASE 
        WHEN e.DataEntregaRealizada IS NULL THEN 'Em andamento'
        WHEN e.DataEntregaRealizada <= e.DataEntregaPrevista THEN 'No prazo'
        ELSE CONCAT('Atrasado ', DATEDIFF(e.DataEntregaRealizada, e.DataEntregaPrevista), ' dias')
    END AS StatusPrazo
FROM Entrega e
INNER JOIN Pedido ped ON e.Pedido_idPedido = ped.idPedido
INNER JOIN Cliente c ON ped.Cliente_idCliente = c.idCliente
ORDER BY e.DataEnvio DESC;

-- =============================================
-- QUERY 13: Estoque total por categoria
-- =============================================
SELECT 
    p.Categoria,
    COUNT(DISTINCT p.idProduto) AS QuantidadeProdutosDiferentes,
    COUNT(DISTINCT e.idEstoque) AS QuantidadeEstoques,
    SUM(pe.Quantidade) AS QuantidadeTotalEstoque,
    MIN(pe.Quantidade) AS MenorEstoque,
    MAX(pe.Quantidade) AS MaiorEstoque,
    AVG(pe.Quantidade) AS MediaEstoque,
    AVG(p.Valor) AS ValorMedioProdutos,
    SUM(p.Valor * pe.Quantidade) AS ValorTotalEstoque
FROM Produto p
INNER JOIN Produto_has_Estoque pe ON p.idProduto = pe.Produto_idProduto
INNER JOIN Estoque e ON pe.Estoque_idEstoque = e.idEstoque
GROUP BY p.Categoria
ORDER BY ValorTotalEstoque DESC;

-- =============================================
-- QUERY 14: Produtos com estoque baixo (menos de 50 unidades)
-- =============================================
SELECT 
    p.idProduto,
    p.Descricao AS Produto,
    p.Categoria,
    e.Local AS Estoque,
    pe.Quantidade,
    p.Valor,
    (p.Valor * pe.Quantidade) AS ValorEstoque,
    CASE 
        WHEN pe.Quantidade = 0 THEN 'SEM ESTOQUE - URGENTE'
        WHEN pe.Quantidade < 20 THEN 'CRÍTICO - Repor Imediatamente'
        WHEN pe.Quantidade < 30 THEN 'BAIXO - Atenção'
        WHEN pe.Quantidade < 50 THEN 'MODERADO - Monitorar'
        ELSE 'OK'
    END AS StatusEstoque,
    -- Verificar se há vendas recentes
    (SELECT COUNT(*) 
     FROM Relacao_Produto_Pedido rpp 
     INNER JOIN Pedido ped ON rpp.Pedido_idPedido = ped.idPedido
     WHERE rpp.Produto_idProduto = p.idProduto 
     AND ped.DataPedido >= DATE_SUB(CURDATE(), INTERVAL 30 DAY)
    ) AS VendasUltimos30Dias
FROM Produto p
INNER JOIN Produto_has_Estoque pe ON p.idProduto = pe.Produto_idProduto
INNER JOIN Estoque e ON pe.Estoque_idEstoque = e.idEstoque
WHERE pe.Quantidade < 50
ORDER BY pe.Quantidade ASC, p.Categoria, p.Descricao;

-- =============================================
-- QUERY 15: Vendedores terceiros e seus produtos
-- =============================================
SELECT 
    tv.idTerceiro_Vendedor,
    tv.RazaoSocial AS Vendedor,
    tv.Local,
    tv.CNPJ,
    COUNT(DISTINCT pv.Produto_idProduto) AS QuantidadeProdutos,
    SUM(pv.Quantidade) AS QuantidadeTotalItens,
    GROUP_CONCAT(
        DISTINCT p.Categoria 
        ORDER BY p.Categoria 
        SEPARATOR ', '
    ) AS Categorias,
    GROUP_CONCAT(
        CONCAT(p.Descricao, ' (', pv.Quantidade, ')')
        ORDER BY pv.Quantidade DESC
        SEPARATOR ' | '
    ) AS ProdutosComQuantidade
FROM Terceiro_Vendedor tv
INNER JOIN Produtos_por_Vendedor pv ON tv.idTerceiro_Vendedor = pv.Terceiro_Vendedor_idTerceiro_Vendedor
INNER JOIN Produto p ON pv.Produto_idProduto = p.idProduto
GROUP BY tv.idTerceiro_Vendedor, tv.RazaoSocial, tv.Local, tv.CNPJ
HAVING QuantidadeProdutos >= 1
ORDER BY QuantidadeTotalItens DESC, QuantidadeProdutos DESC;

-- =============================================
-- QUERY 16: Análise de Clientes PF por Faixa Etária
-- (Query específica para Pessoa Física)
-- =============================================
SELECT 
    CASE 
        WHEN TIMESTAMPDIFF(YEAR, c.DataNascimento, CURDATE()) < 25 THEN '18-24 anos'
        WHEN TIMESTAMPDIFF(YEAR, c.DataNascimento, CURDATE()) < 35 THEN '25-34 anos'
        WHEN TIMESTAMPDIFF(YEAR, c.DataNascimento, CURDATE()) < 45 THEN '35-44 anos'
        WHEN TIMESTAMPDIFF(YEAR, c.DataNascimento, CURDATE()) < 55 THEN '45-54 anos'
        ELSE '55+ anos'
    END AS FaixaEtaria,
    COUNT(DISTINCT c.idCliente) AS TotalClientes,
    COUNT(p.idPedido) AS TotalPedidos,
    COALESCE(AVG(p.Frete), 0) AS FreteMedia,
    COUNT(p.idPedido) / COUNT(DISTINCT c.idCliente) AS MediaPedidosPorCliente
FROM Cliente c
LEFT JOIN Pedido p ON c.idCliente = p.Cliente_idCliente
WHERE c.TipoCliente = 'PF' AND c.DataNascimento IS NOT NULL
GROUP BY FaixaEtaria
ORDER BY 
    CASE FaixaEtaria
        WHEN '18-24 anos' THEN 1
        WHEN '25-34 anos' THEN 2
        WHEN '35-44 anos' THEN 3
        WHEN '45-54 anos' THEN 4
        ELSE 5
    END;

-- =============================================
-- QUERY 17: Produtos nunca vendidos
-- =============================================
SELECT 
    p.idProduto,
    p.Descricao AS Produto,
    p.Categoria,
    p.Valor,
    SUM(pe.Quantidade) AS QuantidadeEstoque,
    SUM(p.Valor * pe.Quantidade) AS ValorTotalEstoque,
    DATEDIFF(CURDATE(), p.DataCadastro) AS DiasDesdeoCadastro,
    'Nunca Vendido' AS Status
FROM Produto p
LEFT JOIN Relacao_Produto_Pedido rpp ON p.idProduto = rpp.Produto_idProduto
LEFT JOIN Produto_has_Estoque pe ON p.idProduto = pe.Produto_idProduto
WHERE rpp.Produto_idProduto IS NULL
GROUP BY p.idProduto, p.Descricao, p.Categoria, p.Valor, p.DataCadastro
ORDER BY ValorTotalEstoque DESC, p.Categoria;

-- =============================================
-- QUERY 18: Resumo Executivo - Dashboard
-- Visão geral do e-commerce
-- =============================================
SELECT 
    'Clientes' AS Metrica,
    COUNT(DISTINCT c.idCliente) AS Total,
    SUM(CASE WHEN c.TipoCliente = 'PF' THEN 1 ELSE 0 END) AS PessoaFisica,
    SUM(CASE WHEN c.TipoCliente = 'PJ' THEN 1 ELSE 0 END) AS PessoaJuridica
FROM Cliente c

UNION ALL

SELECT 
    'Pedidos' AS Metrica,
    COUNT(*) AS Total,
    SUM(CASE WHEN StatusPedido != 'Cancelado' THEN 1 ELSE 0 END) AS Ativos,
    SUM(CASE WHEN StatusPedido = 'Cancelado' THEN 1 ELSE 0 END) AS Cancelados
FROM Pedido

UNION ALL

SELECT 
    'Produtos' AS Metrica,
    COUNT(*) AS Total,
    COUNT(DISTINCT Categoria) AS Categorias,
    NULL
FROM Produto

UNION ALL

SELECT 
    'Fornecedores' AS Metrica,
    COUNT(*) AS Total,
    NULL,
    NULL
FROM Fornecedor

UNION ALL

SELECT 
    'Vendedores Terceiros' AS Metrica,
    COUNT(*) AS Total,
    NULL,
    NULL
FROM Terceiro_Vendedor;

