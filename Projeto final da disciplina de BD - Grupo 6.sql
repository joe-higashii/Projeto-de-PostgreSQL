-- Opção 1: E-commerce tradicional

-- 3. SQL de criação das tabelas

CREATE TABLE Categoria (
    ID SERIAL PRIMARY KEY,
    nome VARCHAR(100) NOT NULL,
    descricao TEXT
);

CREATE TABLE Funcionario ( -- funcionarios
    ID SERIAL PRIMARY KEY,
    Nome VARCHAR(255) NOT NULL,
    cpf_funcionario VARCHAR(20) UNIQUE NOT NULL
);

CREATE TABLE Produto (
    ID SERIAL PRIMARY KEY,
    nome VARCHAR(255) NOT NULL,
    descricao TEXT,
    quantidade_estoque INT NOT NULL,
    data_fabricacao DATE,
    valor_unitario DECIMAL(10, 2) NOT NULL,
    categoria_id INT REFERENCES categoria(id), -- associação a tabela categoria
    funcionario_id INT REFERENCES funcionario(id),
    CONSTRAINT nome_descricao_unique UNIQUE (NOME, DESCRICAO)
);

CREATE TABLE Cliente (
    ID SERIAL PRIMARY KEY,
    nome_completo VARCHAR(255) NOT NULL,
    nome_usuario VARCHAR(50),
    email VARCHAR(100) UNIQUE NOT NULL, --regra de normalizacao 1FN
    cpf VARCHAR(20) UNIQUE NOT NULL,
    data_nascimento DATE
);

CREATE TABLE Telefone (
	ID SERIAL PRIMARY KEY,
	numero_telefone VARCHAR(100) UNIQUE NOT NULL,
	cliente_id INT REFERENCES cliente(id)
);

CREATE TABLE Endereco (
    cliente_id INT PRIMARY KEY,
    cep VARCHAR(20) NOT NULL,
    tipo_logradouro VARCHAR(100) NOT NULL,
    nome_logradouro VARCHAR(255) NOT NULL,
    numero VARCHAR(50),
    complemento VARCHAR(50),
    bairro VARCHAR (100) NOT NULL,
    cidade VARCHAR (100) NOT NULL,
	FOREIGN KEY (cliente_id) REFERENCES cliente(id)
);

CREATE TABLE Pedido (
    ID SERIAL PRIMARY KEY,
    data_do_pedido DATE NOT NULL,
    cliente_id INT REFERENCES cliente(id) -- referencia ao cliente que fez o pedido
);

CREATE TABLE PedidoItem (
    PRIMARY KEY (pedido_id, produto_id),
    pedido_id INT REFERENCES pedido(id), -- referencia a tabela do Pedido
    produto_id INT REFERENCES produto(id), -- referente a tabela do Produto
    quantidade INT NOT NULL,
    CONSTRAINT checar_quantidade CHECK (quantidade > 0) -- garante que cada pedido contenha um ou mais produtos
);

-- 4. SQL de inserção de dados nas tabelas (pelo menos 5 registros em cada uma)

INSERT INTO Categoria (nome, descricao)
VALUES
    ('Eletronicos', 'Produtos eletronicos diversos'),
    ('Vestuario', 'Roupas e acessorios'),
    ('Livros', 'Livros de varios generos'),
    ('Casa Mesa e Banho', 'Produtos para o lar'),
    ('Brinquedos e Jogos', 'Brinquedos para todas as idades');
	
INSERT INTO Funcionario (nome, cpf_funcionario)
VALUES
    ('Madurosa', '789.123.456-00'),
    ('Bisteca', '321.987.654-00'),
    ('Dinora', '654.321.987-00'),
    ('Katrina', '765.732.101-23'),
    ('Nadira', '865.432.098-12');

INSERT INTO Produto (nome, descricao, quantidade_estoque, data_fabricacao, valor_unitario, categoria_id, funcionario_id)
VALUES
    ('Notebook', 'Notebook da xuxa', 300, '2022-01-15', 9.99, 1, 1),
	('Smartphone', 'Smartphone da apple', 800, '2022-01-15', 899.99, 1, 1),
    ('Camiseta', 'Camiseta de oncinha', 500, '2022-02-10', 59.99, 2, 2),
    ('Livro de Aventura', 'Harry Potter e a Pedra Filosofal', 500, '2022-03-05', 79.99, 3, 3),
    ('Roupa de Cama', 'Edredon de algodao', 300, '2022-04-20', 139.99, 4, 1),
    ('Jogo de Tabuleiro', 'Jogo de Damas', 200, '2022-05-30', 19.99, 5, 2);

INSERT INTO Cliente (nome_completo, nome_usuario, email, cpf, data_nascimento)
VALUES
    ('Coralina Bonevelho', 'coralinabonevelho', 'coralinabonevelho@email.com', '123.456.789-00', '1990-01-15'),
    ('Agnes Rugabaixa', 'agnesrugabaixa', 'agnesrugabaixa@email.com', '987.654.321-00', '1985-03-20'),
    ('Bruno Vidadura', 'brunovidadura', 'brunovidadura@email.com', '111.222.333-00', '1995-07-10'),
    ('Laura Caixao', 'lauracaixao', 'lauracaixao@email.com', '333.222.111-00', '1982-12-05'),
    ('Titania Veranossonho', 'titaniaveranossonho', 'titaniaveranossonho@email.com', '444.555.666-00', '1998-09-25'),
	('Leticia', 'leticiabussinger', 'leticiabussinger@email.com', '123.456.789-99', '1990-01-15');

INSERT INTO Telefone (numero_telefone, cliente_id)
VALUES
    ('555-123-4567', 1),
    ('555-987-6543', 2),
    ('555-555-1234', 3),
    ('555-789-0123', 4),
	('555-321-9876', 5),
    ('555-444-5555', 6);

INSERT INTO Endereco (cliente_id, cep, tipo_logradouro, nome_logradouro, numero, complemento, bairro, cidade)
VALUES
	(1, '28623-000', 'avenida', 'conselheiro julius', '333', 'apt.402', 'centro', 'nova friburgo'),
	(2, '28623-001', 'rua', 'conselheiro julius', '334', 'apt.404', 'centro', 'nova friburgo'),
	(3, '28623-002', 'beco', 'conselheiro julius', '335', 'apt.406', 'centro', 'nova friburgo'),
	(4, '28623-003', 'servidao', 'conselheiro julius', '336', 'apt.408', 'centro', 'nova friburgo'),
	(5, '28623-004', 'alameda', 'conselheiro julius', '337', 'apt.410', 'centro', 'nova friburgo');

INSERT INTO Pedido (data_do_pedido, cliente_id)
VALUES
    ('2023-08-01', 1),
    ('2023-08-02', 2),
    ('2023-08-03', 3),
    ('2023-08-04', 4),
    ('2023-08-05', 5);

-- função criada para verificar se há quantidade suficiente em estoque para atender o pedido do cliente
-- e garantir que a quantidade de produtos em estoque seja atualizada sempre que um novo pedido for realizado:
	
CREATE FUNCTION verificar_e_atualizar_quantidade_estoque()
RETURNS TRIGGER AS $$
BEGIN
    -- verificar quantidade do estoque
    IF NEW.quantidade <= (SELECT quantidade_estoque FROM Produto WHERE ID = NEW.produto_id) THEN
        -- atualizar quantidade do estoque
        UPDATE Produto
        SET quantidade_estoque = quantidade_estoque - NEW.quantidade
        WHERE ID = NEW.produto_id;
        RETURN NEW;
    ELSE
        RAISE EXCEPTION 'Não há produto suficiente em estoque';
    END IF;
END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER trigger_verificar_e_atualizar_quantidade_estoque
BEFORE INSERT ON PedidoItem
FOR EACH ROW
EXECUTE FUNCTION verificar_e_atualizar_quantidade_estoque();

INSERT INTO PedidoItem (pedido_id, produto_id, quantidade)
VALUES
    (1, 1, 10),
    (1, 2, 15),
    (2, 2, 3),
    (2, 3, 10),
    (3, 3, 2),
	(3, 4, 2),
    (4, 4, 10),
    (4, 5, 5),
    (5, 5, 2),
    (5, 1, 3);
	
-- SELECIONAR ATÉ AQUI
-------------------------------------------------------------------------

-- Teste para inserir um pedido de quantidade superior a quantidade do estoque
INSERT INTO PedidoItem (pedido_id, produto_id, quantidade)
VALUES
    (1, 2, 1000);
	
	
-- Teste para inserir o mesmo produto mais de uma vez no mesmo pedido

INSERT INTO PedidoItem (pedido_id, produto_id, quantidade)
VALUES
    (1, 1, 10);
	

-- Teste para inserir o mesmo numero de telefone mais de uma vez

INSERT INTO Telefone (numero_telefone, cliente_id)
VALUES
    ('555-123-4567', 3)
	

-- SQL para verificar se a quantidade de itens do estoque foi atualizada

SELECT quantidade_estoque
FROM Produto
WHERE categoria_id = 1; --substituir pela categoria desejada

-------------------------------------------------------------------------
	
-- 5.Um comando SQL de atualização em algum registro em uma tabela

UPDATE Produto SET valor_unitario = 49.99 WHERE ID = 3

-- verificar atualização

SELECT id, valor_unitario
FROM Produto

-- 6. Um comando SQL de exclusão de algum registro em uma tabela

DELETE FROM PedidoItem WHERE pedido_id = 5

-- verificar exclusão
SELECT *
FROM PedidoItem;

-- 7. 5 SQLs de consulta

-- 7.a Dois SQL de consulta com algum tipo de junção

-- primeiro
SELECT -- consulta para mostrar qual funcionário cadastrou o produto
	pr.nome AS produto,
	pr.descricao AS descricao_produto,
	pr.quantidade_estoque,
	pr.valor_unitario,
	cat.nome AS categoria,
	f.nome AS funcionario
FROM
	categoria cat JOIN produto pr ON cat.id = pr.categoria_id
	JOIN funcionario f ON f.id = pr.funcionario_id

-- segundo
SELECT -- consulta para mostrar o cep e o cpf do cliente
	c.nome_completo AS nome_cliente,
	c.cpf,
	p.id AS id_pedido,
	e.cep
FROM
	cliente c LEFT JOIN pedido p ON p.cliente_id = c.id
	LEFT JOIN endereco e ON e.cliente_id = c.id
	

-- 7.b Pelo menos 1 com usando count() e group by()

-- primeiro
SELECT -- consulta a quantidade de produtos em cada categoria
	cat.nome AS categoria, COUNT(*) AS quantidade_produto
FROM
	Produto pr JOIN categoria cat ON cat.id = pr.categoria_id
GROUP BY
	cat.nome

-- segundo
SELECT -- consulta o valor total em estoque de cada categoria de produto
	cat.nome AS categoria, SUM(pr.valor_unitario * pr.quantidade_estoque) AS valor_total_estoque
FROM
	Produto pr JOIN categoria cat ON cat.id = pr.categoria_id
GROUP BY
	cat.nome
	
-- terceiro
SELECT -- consulta quantidade de produtos cadastrados por cada funcionário
	f.nome AS funcionario, COUNT(pr.id) AS quantidade_de_produtos_cadastrados
FROM
	produto pr JOIN funcionario f ON f.id = pr.funcionario_id
GROUP BY
	f.nome
ORDER BY
	quantidade_de_produtos_cadastrados DESC

-- 7.c 1 SQL pra contrução de Nota Fiscal

-- Primeira versão de exibição da Nota Fiscal
SELECT
    p.id AS pedido_id,
    c.nome_completo AS cliente,
    c.email AS email_cliente,
    c.cpf AS cpf_cliente,
    STRING_AGG(DISTINCT tel.numero_telefone, ', ') AS telefones,
    e.cep AS cep_entrega,
    e.tipo_logradouro AS tipo_logradouro_entrega,
    e.nome_logradouro AS nome_logradouro_entrega,
    e.numero AS numero_entrega,
    e.complemento AS complemento_entrega,
    e.bairro AS bairro_entrega,
    e.cidade AS cidade_entrega,
    p.data_do_pedido AS data_pedido,
    STRING_AGG(cat.nome, ', ') AS categoria,
    STRING_AGG(cat.id::TEXT, ', ') AS categoria_id,
    STRING_AGG(pr.nome, ', ') AS nome_produto,
    STRING_AGG(pr.descricao, ', ') AS descricao_produto,
    STRING_AGG(pi.quantidade::TEXT, ', ') AS quantidade_produto,
    STRING_AGG(pr.valor_unitario::TEXT, ', ') AS valor_unitario_produto,
    STRING_AGG((pi.quantidade * pr.valor_unitario)::TEXT, ', ') AS subtotal_produto,
    (
        SELECT SUM(pi2.quantidade * pr2.valor_unitario)
        FROM PedidoItem pi2
        JOIN Produto pr2 ON pi2.produto_id = pr2.id
        WHERE pi2.pedido_id = p.id
    ) AS total_pedido
FROM
    Pedido p
    JOIN Cliente c ON p.cliente_id = c.id
    JOIN Endereco e ON c.id = e.cliente_id
    JOIN Telefone tel ON c.id = tel.cliente_id
    JOIN PedidoItem pi ON p.id = pi.pedido_id
    JOIN Produto pr ON pi.produto_id = pr.id
    JOIN Categoria cat ON pr.categoria_id = cat.id
-- WHERE p.id = 1 -- substituir pelo id do pedido desejado
GROUP BY
    p.id, c.nome_completo, c.email, c.cpf, e.cep, e.tipo_logradouro, e.nome_logradouro, e.numero,
    e.complemento, e.bairro, e.cidade, p.data_do_pedido
ORDER BY
    p.id


-- Segunda versão de exibição da Nota Fiscal
SELECT
	pd.id AS "Id do pedido", 
	pd.data_do_pedido AS "Data do pedido",
	c.nome_completo AS "Nome do cliente", 
	c.email AS "Email do cliente", 
	c.cpf AS "CPF do cliente",
	STRING_AGG(DISTINCT tel.numero_telefone, ', ') AS "Telefones",
	MAX(CONCAT(e.tipo_logradouro, ' ', e.nome_logradouro,' - ', e.numero, ' - ', e.complemento, ', ', e.bairro, ', ', e.cidade, ' CEP: ', e.cep)) AS "Endereço",
	STRING_AGG(CONCAT(p.nome, ' - ', p.descricao,' (', pi.quantidade, ' unidades', ' -> ', 'R$ ', p.valor_unitario, ')'), ', ') AS "Descrição da Nota-Fiscal",
	SUM(pi.quantidade * p.valor_unitario) AS "Valor Total"
FROM
	categoria ct JOIN Produto p ON ct.id = p.categoria_id
	JOIN funcionario f ON f.id = p.funcionario_id
	JOIN PedidoItem pi ON pi.produto_id = p.id
	JOIN Pedido pd ON pi.pedido_id = pd.id
	JOIN cliente c ON c.id = pd.cliente_id
	JOIN endereco e ON e.cliente_id = c.id
	JOIN Telefone tel ON c.id = tel.cliente_id
GROUP BY	
	pd.id, c.nome_completo, c.email, c.cpf,
	e.tipo_logradouro, e.nome_logradouro, 
	e.numero, e.complemento, e.bairro, e.cidade, e.cep, pd.data_do_pedido