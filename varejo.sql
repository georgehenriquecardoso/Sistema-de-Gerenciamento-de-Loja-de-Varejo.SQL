-- Tabela de Clientes
CREATE TABLE Clientes (
    ClienteID INT PRIMARY KEY,
    Nome VARCHAR(100),
    Email VARCHAR(100),
    Telefone VARCHAR(20),
    DataCadastro DATE
);

-- Tabela de Produtos
CREATE TABLE Produtos (
    ProdutoID INT PRIMARY KEY,
    Nome VARCHAR(100),
    Descricao TEXT,
    Preco DECIMAL(10, 2),
    QuantidadeEstoque INT,
    CategoriaID INT,
    FornecedorID INT,
    FOREIGN KEY (CategoriaID) REFERENCES Categorias(CategoriaID),
    FOREIGN KEY (FornecedorID) REFERENCES Fornecedores(FornecedorID)
);

-- Tabela de Categorias de Produtos
CREATE TABLE Categorias (
    CategoriaID INT PRIMARY KEY,
    Nome VARCHAR(100)
);

-- Tabela de Fornecedores
CREATE TABLE Fornecedores (
    FornecedorID INT PRIMARY KEY,
    Nome VARCHAR(100),
    Telefone VARCHAR(20),
    Email VARCHAR(100)
);

-- Tabela de Pedidos
CREATE TABLE Pedidos (
    PedidoID INT PRIMARY KEY,
    ClienteID INT,
    DataPedido DATETIME,
    Status VARCHAR(50),
    ValorTotal DECIMAL(10, 2),
    FOREIGN KEY (ClienteID) REFERENCES Clientes(ClienteID)
);

-- Tabela de Detalhes de Pedidos
CREATE TABLE DetalhesPedido (
    DetalheID INT PRIMARY KEY,
    PedidoID INT,
    ProdutoID INT,
    Quantidade INT,
    PrecoUnitario DECIMAL(10, 2),
    FOREIGN KEY (PedidoID) REFERENCES Pedidos(PedidoID),
    FOREIGN KEY (ProdutoID) REFERENCES Produtos(ProdutoID)
);

-- Tabela de Pagamentos
CREATE TABLE Pagamentos (
    PagamentoID INT PRIMARY KEY,
    PedidoID INT,
    MetodoPagamento VARCHAR(50),
    Valor DECIMAL(10, 2),
    DataPagamento DATETIME,
    FOREIGN KEY (PedidoID) REFERENCES Pedidos(PedidoID)
);

-- Procedimento armazenado para adicionar um novo cliente
DELIMITER //
CREATE PROCEDURE AdicionarCliente (
    IN p_nome VARCHAR(100),
    IN p_email VARCHAR(100),
    IN p_telefone VARCHAR(20),
    IN p_data_cadastro DATE
)
BEGIN
    INSERT INTO Clientes (Nome, Email, Telefone, DataCadastro)
    VALUES (p_nome, p_email, p_telefone, p_data_cadastro);
END //
DELIMITER ;

-- Gatilho para atualizar o estoque após uma venda
CREATE TRIGGER AtualizarEstoqueAposVenda
AFTER INSERT ON DetalhesPedido
FOR EACH ROW
BEGIN
    UPDATE Produtos
    SET QuantidadeEstoque = QuantidadeEstoque - NEW.Quantidade
    WHERE ProdutoID = NEW.ProdutoID;
END;

-- Consulta para calcular o valor total de vendas por mês
SELECT 
    YEAR(DataPedido) AS Ano,
    MONTH(DataPedido) AS Mes,
    SUM(ValorTotal) AS TotalVendas
FROM Pedidos
GROUP BY YEAR(DataPedido), MONTH(DataPedido)
ORDER BY Ano, Mes;

-- Consulta para obter o produto mais vendido em cada categoria
SELECT 
    Categorias.Nome AS Categoria,
    Produtos.Nome AS Produto,
    MAX(vendas.TotalVendido) AS TotalVendido
FROM Produtos
JOIN Categorias ON Produtos.CategoriaID = Categorias.CategoriaID
JOIN (
    SELECT 
        Produtos.CategoriaID,
        Produtos.ProdutoID,
        SUM(DetalhesPedido.Quantidade) AS TotalVendido
    FROM Produtos
    JOIN DetalhesPedido ON Produtos.ProdutoID = DetalhesPedido.ProdutoID
    GROUP BY Produtos.CategoriaID, Produtos.ProdutoID
) AS vendas ON Produtos.ProdutoID = vendas.ProdutoID
GROUP BY Categorias.Nome;

-- Consulta para obter os clientes com o maior número de pedidos
SELECT 
    Clientes.Nome,
    COUNT(Pedidos.PedidoID) AS NumPedidos
FROM Clientes
JOIN Pedidos ON Clientes.ClienteID = Pedidos.ClienteID
GROUP BY Clientes.Nome
ORDER BY NumPedidos DESC;
