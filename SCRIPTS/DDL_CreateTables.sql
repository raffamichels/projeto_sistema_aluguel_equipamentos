--Comando DDL Sistema de Aluguel de Equipamentos

-- Tabela 1: CLIENTES
CREATE TABLE CLIENTES(
	cliente_id INT IDENTITY(1,1) NOT NULL, 
	Nome VARCHAR(100) NOT NULL, 
	CPF_CNPJ VARCHAR(18) NOT NULL, 
	email VARCHAR(100) NOT NULL, 
	telefone VARCHAR(15) NOT NULL, 
	endereco_id INT NOT NULL,
	CONSTRAINT PK_CLIENTES PRIMARY KEY (cliente_id));

-- Tabela 2: FUNCIONARIOS
CREATE TABLE FUNCIONARIOS(
	funcionario_id INT IDENTITY(1,1) NOT NULL, 
	nome VARCHAR(100) NOT NULL, 
	cargo VARCHAR(50) NOT NULL, 
	dt_contratacao DATE NOT NULL, 
	CONSTRAINT PK_FUNCIONARIOS PRIMARY KEY (funcionario_id),
	-- CONSTRAINT CHECK para data de contratação (Regra de Negócio)
	CONSTRAINT CK_FUNC_CONTRATACAO CHECK (dt_contratacao <= GETDATE()));

-- Tabela 3: ENDERECO
CREATE TABLE ENDERECO(
	endereco_id INT IDENTITY(1,1) NOT NULL, 
	logradouro VARCHAR(100) NOT NULL, 
	bairro VARCHAR(50) NOT NULL, 
	numero VARCHAR(10) NOT NULL, 
	complemento VARCHAR(15) NULL, 
	cidade VARCHAR(50) NOT NULL,
	estado CHAR(2) NOT NULL,
	cep VARCHAR(8) NOT NULL,
	CONSTRAINT PK_ENDERECO PRIMARY KEY (endereco_id));

-- Tabela 4: CATEGORIA
CREATE TABLE CATEGORIA(
	categoria_id INT IDENTITY(1,1) NOT NULL, 
	nome_categoria VARCHAR(50) NOT NULL, 
	descricao VARCHAR(255) NOT NULL, 
	CONSTRAINT PK_CATEGORIA PRIMARY KEY (categoria_id));

-- Tabela 5: EQUIPAMENTO
CREATE TABLE EQUIPAMENTO(
	equipamento_id INT IDENTITY(1,1) NOT NULL, 
	nome VARCHAR(100) NOT NULL, 
	modelo VARCHAR(100) NOT NULL,
	numero_serie VARCHAR(50) NOT NULL,
	preco_diaria DECIMAL(10,2) NOT NULL,
	status VARCHAR(20) NOT NULL, 
	CONSTRAINT PK_EQUIPAMENTO PRIMARY KEY (equipamento_id));
	
-- Adicionando categoria_id na tabela de EQUIPAMENTO
	ALTER TABLE EQUIPAMENTO
	ADD categoria_id INT NOT NULL;

-- Tabela 6: ESTOQUE
CREATE TABLE ESTOQUE(
	estoque_id INT IDENTITY(1,1) NOT NULL, 
	equipamento_id INT NOT NULL, 
	quant_disponivel SMALLINT NOT NULL,
	quant_total SMALLINT NOT NULL,
	data_revisao DATETIME NOT NULL
	CONSTRAINT PK_ESTOQUE PRIMARY KEY (estoque_id),
	-- CONSTRAINT CHECK para integridade de estoque
	CONSTRAINT CK_ESTOQUE_DISP CHECK (quant_disponivel <= quant_total));

-- Tabela 7: ALUGUEL
CREATE TABLE ALUGUEL(
	aluguel_id INT IDENTITY(1,1) NOT NULL, 
	cliente_id INT NOT NULL, 
	funcionario_id INT NOT NULL,
	data_inicio DATETIME NOT NULL,
	data_devolucao DATETIME NULL, -- Null, pois a devolução pode estar pendente
	valor_total DECIMAL(10,2) NOT NULL, 
	CONSTRAINT PK_ALUGUEL PRIMARY KEY (aluguel_id));

-- Tabela 8: ALUGUEL_ITEM (Relacionamento N:N)
CREATE TABLE ALUGUEL_ITEM(
	aluguel_id INT  NOT NULL, 
	equipamento_id INT NOT NULL, 
	quantidade SMALLINT NOT NULL,
	valor_diaria DECIMAL(10,2) NOT NULL, 
	CONSTRAINT PK_ALUGUEL_ITEM PRIMARY KEY (aluguel_id, equipamento_id)); --Chave Primária Composta

-- Tabela 9: PAGAMENTOS
CREATE TABLE PAGAMENTOS(
	pagamento_id INT IDENTITY(1,1)  NOT NULL, 
	aluguel_id INT NOT NULL, 
	valor_pago DECIMAL(10,2) NOT NULL,
	metodo_pagamento VARCHAR(50) NOT NULL, 
	dt_pagamento DATETIME NOT NULL, 
	CONSTRAINT PK_PAGAMENTOS PRIMARY KEY (pagamento_id));

-- Tabela 10: MANUTENCAO
CREATE TABLE MANUTENCAO(
	manutencao_id INT IDENTITY(1,1)  NOT NULL, 
	equipamento_id INT NOT NULL, 
	fornecedor_id INT NOT NULL,  
	dt_inicio DATETIME NOT NULL, 
	dt_final DATETIME NULL, -- Null, pois a manutenção pode estar em andamento
	custo DECIMAL(10,2) NOT NULL, 
	descricao VARCHAR(255) NOT NULL, 
	CONSTRAINT PK_MANUTENCAO PRIMARY KEY (manutencao_id));

-- Tabela 11: MULTAS
CREATE TABLE MULTAS(
	multa_id INT IDENTITY(1,1)  NOT NULL, 
	aluguel_id INT NOT NULL, 
	valor_multa DECIMAL(10,2) NOT NULL,  
	descricao VARCHAR(255) NOT NULL, 
	dt_multa DATETIME NOT NULL,
	status_pagamento VARCHAR(20) NOT NULL, 
	CONSTRAINT PK_MULTAS PRIMARY KEY (multa_id));

-- Tabela 12: FORNECEDORES
CREATE TABLE FORNECEDORES (
	fornecedor_id INT IDENTITY(1,1)  NOT NULL, 
	nome VARCHAR(100) NOT NULL,  
	cnpj CHAR(18) NOT NULL, 
	telefone VARCHAR(15) NOT NULL, 
	CONSTRAINT PK_FORNECEDORES PRIMARY KEY (fornecedor_id));

-- REGRAS DE UNIDADE (UNIQUE)

ALTER TABLE CLIENTES
ADD CONSTRAINT UK_CLIENTE_CPF UNIQUE (CPF_CNPJ);
ALTER TABLE CLIENTES 
ADD CONSTRAINT UK_CLIENTE_EMAIL	UNIQUE (email);

ALTER TABLE CATEGORIA
ADD CONSTRAINT UK_CATEGORIA_NOME UNIQUE (nome_categoria);

ALTER TABLE EQUIPAMENTO
ADD CONSTRAINT UK_EQUIPAMENTO_NUMSERIE UNIQUE (numero_serie);

ALTER TABLE FORNECEDORES
ADD CONSTRAINT UK_FORNECEDORES_CNPJ	UNIQUE (cnpj);

-- CHAVES ESTRANGEIRAS (FOREIGN KEYS)

-- CLIENTES
ALTER TABLE CLIENTES
ADD CONSTRAINT FK_CLIENTE_ENDERECO FOREIGN KEY (endereco_id)
REFERENCES ENDERECO (endereco_id);

-- EQUIPAMENTO
ALTER TABLE EQUIPAMENTO
ADD CONSTRAINT FK_EQUIPAMENTO_CATEGORIA	FOREIGN KEY (categoria_id)
REFERENCES CATEGORIA (categoria_id);

-- ESTOQUE
ALTER TABLE ESTOQUE
ADD CONSTRAINT FK_ESTOQUE_EQUIPAMENTO FOREIGN KEY (equipamento_id)
REFERENCES EQUIPAMENTO (equipamento_id);

-- ALUGUEL
ALTER TABLE ALUGUEL
ADD CONSTRAINT FK_ALUGUEL_CLIENTE FOREIGN KEY (cliente_id)
REFERENCES CLIENTES (cliente_id);
ALTER TABLE ALUGUEL
ADD CONSTRAINT FK_ALUGUEL_FUNCIONARIO FOREIGN KEY (funcionario_id)
REFERENCES FUNCIONARIOS (funcionario_id);

-- ALUGUEL_ITEM
ALTER TABLE ALUGUEL_ITEM
ADD CONSTRAINT FK_ALUGUELITEM_ALUGUEL FOREIGN KEY (aluguel_id)
REFERENCES ALUGUEL (aluguel_id);
ALTER TABLE ALUGUEL_ITEM
ADD CONSTRAINT FK_ALUGUELITEM_EQUIPAMENTO FOREIGN KEY (equipamento_id)
REFERENCES EQUIPAMENTO (equipamento_id);

-- PAGAMENTOS
ALTER TABLE PAGAMENTOS 
ADD CONSTRAINT FK_PAGAMENTOS_ALUGUEL FOREIGN KEY (aluguel_id)
REFERENCES ALUGUEL (aluguel_id);

-- MANUTENCAO
ALTER TABLE MANUTENCAO
ADD CONSTRAINT FK_MANUTENCAO_EQUIP FOREIGN KEY (equipamento_id)
REFERENCES EQUIPAMENTO (equipamento_id);
ALTER TABLE MANUTENCAO
ADD CONSTRAINT FK_MANUTENCAO_FORN	FOREIGN KEY (fornecedor_id)
REFERENCES FORNECEDORES (fornecedor_id);

-- MULTAS
ALTER TABLE MULTAS
ADD CONSTRAINT FK_MULTAS_ALUGUEL FOREIGN KEY (aluguel_id)
REFERENCES ALUGUEL (aluguel_id);

-- Comando DML Sistema de Aluguel de Equipamentos

-- Tabela 3: Endereco

INSERT INTO ENDERECO (logradouro, bairro, numero, complemento, cidade, estado, cep) VALUES
( 'Rua das Flores', 'Jardim América', '150', 'Apto 101', 'São Paulo', 'SP', '04001001'),
( 'Av. Atlântica', 'Copacabana', '3000', 'Bloco B', 'Rio de Janeiro', 'RJ', '22070002'),
( 'Rua do Comércio', 'Centro', '125', NULL, 'Curitiba', 'PR', '80010010'),
( 'Estrada Real', 'Alphaville', '80', 'Casa 2', 'Belo Horizonte', 'MG', '30110005'),
( 'Av. Paulista', 'Bela Vista', '1009', 'Sala 5', 'São Paulo', 'SP', '01310100'),
( 'Rua XV de Novembro', 'Centro', '45', NULL, 'Curitiba', 'PR', '80020020'),
( 'Rua da Paz', 'Funcionários', '550', 'Sala 1', 'Belo Horizonte', 'MG', '30130025'),
( 'Av. Sete de Setembro', 'Ondina', '100', 'Apto 303', 'Salvador', 'BA', '40170010'),
( 'Rua das Indústrias', 'Distrito Industrial', '100', NULL, 'São Bernardo do Campo', 'SP', '09842000'),
( 'Av. dos Estados', 'Vila Nova', '500', 'Galpão 3', 'Porto Alegre', 'RS', '90110150'),
( 'Rua do Progresso', 'Centro Empresarial', '20', 'Torre Sul', 'Recife', 'PE', '50030010'),
( 'Av. Engenharia', 'Jardim Botânico', '15', NULL, 'Curitiba', 'PR', '80210050'),
( 'Rua dos Construtores', 'Industrial', '90', NULL, 'São Paulo', 'SP', '04710000'),
( 'Rua do Evento', 'Centro', '155', 'Loja B', 'Rio de Janeiro', 'RJ', '20040040'),
( 'Rua da Tecnologia', 'Santo Amaro', '1000', 'Andar 10', 'Recife', 'PE', '50030020'),
( 'Rua do Sol Nascente', 'Praia Grande', '10', 'Quiosque', 'Fortaleza', 'CE', '60165005'),
( 'Av. Principal', 'Setor Central', '200', NULL, 'Brasília', 'DF', '70040000');

-- Tabela 1: Clientes 

INSERT INTO CLIENTES (Nome, CPF_CNPJ, email, telefone, endereco_id) VALUES

('Joao da Silva', '487.654.321-09', 'joao.silva@exemplo.com', '11988887777', 1),
('Maria Souza', '359.876.543-21', 'maria.souza@empresa.com.br', '21977776666', 2),
('Pedro Henrique', '789.012.345-67', 'pedro.henrique@home.net', '41955554444', 3),
('Ana Beatriz', '123.456.789-01', 'ana.beatriz@gmail.com', '61933332222', 1),
('Fábio Junior', '901.234.567-89', 'fabio.junior@terra.com', '71922221111', 4),
('Luciana Martins', '234.567.890-12', 'luciana.m@email.com', '91900009999', 2),
('Ricardo Almeida', '567.890.123-45', 'ricardo.a@site.br', '19999998888', 5),
('Gustavo Lima', '890.123.456-78', 'gustavo.lima@mail.com', '21977774444', 6),
('Patricia Reis', '012.345.678-90', 'patricia.reis@live.com', '41955552222', 3),
('Carlos Eduardo', '678.901.234-56', 'carloseduardo@mail.com', '61933330000', 7),
('Renata Flores', '901.204.567-09', 'renata.f@web.com', '71922229999', 4),
('Alexandre Costa', '143.456.789-01', 'alex.costa@email.com', '91900007777', 8),
('Daniela Gomes', '456.789.012-34', 'daniela.gomes@ex.com', '19999996666', 5),
('Construtora Alfa Ltda', '12.345.678/0001-00', 'contato@alfa.com.br', '31966665555', 9),
('Obras Rapidas S/A', '87.654.321/0001-99', 'obras@rapidas.com', '51944443333', 10),
('Engenharia Delta', '11.223.344/0001-55', 'delta@eng.com.br', '81911110000', 11),
('Tecnologia Beta', '98.765.432/0001-11', 'beta@tec.net', '11988885555', 12),
('Construtora Gama', '54.321.098/0001-22', 'gama@constroi.com', '31966663333', 13),
('Eventos Sol', '34.567.890/0001-33', 'contato@sol.com', '51944441111', 14),
('Manutenção Essencial', '23.456.789/0001-44', 'essencial@manut.com', '81911118888', 15);

-- Tabela 2: Funcionarios

INSERT INTO FUNCIONARIOS (nome, cargo, dt_contratacao) VALUES
('Felipe Mendes', 'Gerente de Filial', '2022-01-15'),
('Sofia Oliveira', 'Vendedor Sênior', '2023-03-01'),
('Bruno Costa', 'Técnico de Manutenção', '2023-05-20'),
('Camila Ramos', 'Assistente Administrativo', '2023-08-10'),
('Daniel Santos', 'Vendedor Júnior', '2024-01-05'),
('Eliana Pereira', 'Analista Financeiro', '2022-11-01'),
('Gabriel Ferreira', 'Técnico de Logística', '2023-02-14'),
('Heloísa Lima', 'Vendedor Pleno', '2024-04-01'),
('Igor Almeida', 'Especialista em Frota', '2022-09-10'),
('Juliana Gomes', 'Vendedor Sênior', '2023-07-25'),
('Kleber Souza', 'Auxiliar de Limpeza', '2024-05-01'),
('Larissa Vieira', 'Gerente Regional', '2022-04-01'),
('Marcelo Rocha', 'Vendedor Júnior', '2024-06-15'),
('Natália Cruz', 'Técnico de Manutenção', '2023-10-10'),
('Otávio Martins', 'Assistente de Vendas', '2024-01-20');


-- (INSERIR DML ANTERIOR A TABELA ALUGUEL)!!!!!!

-- Tabela 7: Aluguel

INSERT INTO ALUGUEL (cliente_id, funcionario_id, data_inicio, data_devolucao, valor_total) VALUES
(3, 1, '2024-05-01T10:00:00', '2024-06-15T10:00:00', 15000.00),
(5, 4, '2024-05-10T11:00:00', '2024-06-05T11:00:00', 4500.00),
(13, 12, '2024-06-01T14:00:00', '2024-06-25T14:00:00', 800.00),
(15, 7, '2024-07-01T09:00:00', '2024-07-03T09:00:00', 350.00),
(1, 2, '2024-08-01T15:00:00', '2024-08-03T15:00:00', 100.00),
(4, 9, '2024-08-05T16:00:00', '2024-08-07T16:00:00', 70.00),
(7, 15, '2024-08-10T17:00:00', '2024-08-11T17:00:00', 40.00),
(10, 2, '2024-08-15T10:00:00', '2024-08-17T10:00:00', 90.00),
(6, 4, '2024-08-20T12:00:00', '2024-08-21T12:00:00', 50.00),
(9, 9, '2024-08-25T14:00:00', '2024-08-26T14:00:00', 30.00),
(2, 1, '2024-09-01T11:00:00', NULL, 600.00),
(6, 4, '2024-09-05T13:00:00', NULL, 120.00),
(8, 15, '2024-09-10T15:00:00', NULL, 80.00),
(9, 2, '2024-09-15T16:00:00', NULL, 50.00),
(11, 9, '2024-09-20T17:00:00', NULL, 750.00),
(12, 1, '2024-10-01T10:00:00', NULL, 150.00),
(14, 4, '2024-10-05T11:00:00', NULL, 25.00),
(7, 15, '2024-10-10T14:00:00', NULL, 40.00),
(8, 2, '2024-10-15T15:00:00', NULL, 20.00),
(0, 9, '2024-10-20T16:00:00', NULL, 8.00),
(3, 4, '2024-10-25T08:30:00', '2024-10-27T08:30:00', 360.00),
(5, 12, '2024-11-01T10:00:00', '2024-11-05T10:00:00', 1000.00),
(13, 7, '2024-11-10T11:00:00', '2024-11-15T11:00:00', 175.00),
(15, 1, '2024-11-20T12:00:00', '2024-11-20T17:00:00', 150.00),
(8, 2, '2024-11-25T14:00:00', '2024-11-27T14:00:00', 160.00),
(1, 9, '2024-12-01T15:00:00', '2024-12-04T15:00:00', 120.00),
(4, 15, '2024-12-05T16:00:00', '2024-12-08T16:00:00', 90.00),
(7, 2, '2024-12-10T17:00:00', '2024-12-11T17:00:00', 40.00),
(10, 4, '2024-12-15T10:00:00', '2024-12-17T10:00:00', 50.00),
(6, 9, '2024-12-20T12:00:00', '2024-12-23T12:00:00', 150.00),
(7, 12, '2025-01-01T14:00:00', NULL, 25.00),
(8, 7, '2025-01-05T15:00:00', NULL, 20.00),
(9, 1, '2025-01-10T16:00:00', NULL, 35.00),
(2, 4, '2025-01-15T17:00:00', NULL, 150.00),
(2, 9, '2025-01-20T10:00:00', NULL, 50.00),
(6, 15, '2025-02-01T11:00:00', NULL, 120.00),
(11, 2, '2025-02-05T13:00:00', NULL, 750.00),
(12, 4, '2025-02-10T14:00:00', NULL, 180.00),
(14, 9, '2025-02-15T15:00:00', NULL, 15.00),
(15, 1, '2025-02-20T16:00:00', NULL, 45.00);
