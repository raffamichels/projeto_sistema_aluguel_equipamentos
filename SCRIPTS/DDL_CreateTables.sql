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

-- Tabela 4: Categoria

INSERT INTO CATEGORIA (nome_categoria, descricao) VALUES
('Ferramentas Elétricas', 'Equipamentos portáteis para corte, perfuração e desbaste.'),
('Máquinas Pesadas', 'Equipamentos de grande porte para terraplanagem e elevação.'),
('Equipamentos de Jardinagem', 'Ferramentas para manutenção de áreas verdes e paisagismo.'),
('Segurança e EPIs', 'Equipamentos de Proteção Individual e Coletiva (EPC).'),
('Compressores e Geradores', 'Máquinas para geração de energia e ar comprimido no canteiro.'),
('Transporte e Logística', 'Equipamentos para movimentação e transporte de materiais.'),
('Construção a Seco', 'Ferramentas e perfis para sistemas de Drywall e Steel Frame.'),
('Hidráulica e Saneamento', 'Equipamentos para instalação e manutenção de sistemas hídricos.'),
('Pintura e Acabamento', 'Máquinas e acessórios para preparação e aplicação de tintas.'),
('Acesso e Elevação', 'Andaimes, escadas e plataformas elevatórias.'),
('Serralheria e Solda', 'Equipamentos para corte e união de metais.'),
('Medição e Topografia', 'Instrumentos de precisão para medição de distâncias e níveis.'),
('Limpeza Industrial', 'Máquinas de alta pressão e aspiração para limpeza de obras.'),
('Iluminação', 'Torres de iluminação e refletores para trabalho noturno.'),
('Ferramentas Manuais', 'Kits e peças avulsas de ferramentas não elétricas.');

-- Tabela 12: Fornecedores

INSERT INTO FORNECEDORES (nome, cnpj, telefone) VALUES
('Manutenção Diesel e Hidráulica MG', '01.234.567/0001-89', '3135001234'),
('Peças e Componentes Elétricos Sul', '12.345.678/0001-90', '4733005678'),
('Oficina Especializada de Betoneiras SP', '23.456.789/0001-01', '1144009876'),
('Reparos Rápidos para Mini Escavadeiras', '34.567.890/0001-12', '1938006543'),
('Lubrificantes Industriais Alfa', '45.678.901/0001-23', '2199003210'),
('Calibração e Testes de Ferramentas', '56.789.012/0001-34', '5130301010'),
('Serviços de Soldagem Estrutural LTDA', '67.890.123/0001-45', '8134502020'),
('Centro de Reparo de Compressores', '78.901.234/0001-56', '6239993030'),
('Conserto de Máquinas de Topografia', '89.012.345/0001-67', '7140404040'),
('Peças para Geradores Sigma', '90.123.456/0001-78', '9298885050'),
('Baterias e Carregadores Profissionais', '02.345.678/0001-11', '1120206060'),
('Reforma de Andaimes e Estruturas', '13.456.789/0001-22', '4137777070'),
('Manutenção Preventiva de Motores', '24.567.890/0001-33', '8436668080'),
('Automação e Sensores para Equipamentos', '35.678.901/0001-44', '6130009090'),
('Pneus e Rodas para Máquinas Pesadas', '46.789.012/0001-55', '5434440101'),
('Afiamento de Lâminas e Discos', '57.890.123/0001-66', '1938881111'),
('EPIs e Uniformes de Reposição', '68.901.234/0001-77', '2197772222'),
('Diagnóstico Eletrônico de Falhas', '79.012.345/0001-88', '4733333333'),
('Serviços de Retífica e Usinagem', '80.123.456/0001-99', '3130004444'),
('Assistência Técnica Autorizada Bosch', '91.234.567/0001-00', '1140005555');

-- Tabela 5: Equipamento

INSERT INTO EQUIPAMENTO (nome, modelo, numero_serie, preco_diaria, status, categoria_id) VALUES
('Furadeira de Impacto', 'Bosch GSB 550', 'BR550A001', 25.50, 'Em Uso', 1),
('Furadeira de Impacto', 'Bosch GSB 550', 'BR550A002', 25.50, 'Em Manutenção', 1),
('Furadeira de Impacto', 'Bosch GSB 550', 'BR550A003', 25.50, 'Em Manutenção', 1),
('Furadeira de Impacto', 'Bosch GSB 550', 'BR550A004', 25.50, 'Em Manutenção', 1),
('Furadeira de Impacto', 'Bosch GSB 550', 'BR550A005', 25.50, 'Disponível', 1),
('Furadeira de Impacto', 'Bosch GSB 550', 'BR550A006', 25.50, 'Disponível', 1),
('Furadeira de Impacto', 'Bosch GSB 550', 'BR550A007', 25.50, 'Disponível', 1),
('Furadeira de Impacto', 'Bosch GSB 550', 'BR550A008', 25.50, 'Disponível', 1),
('Furadeira de Impacto', 'Bosch GSB 550', 'BR550A009', 25.50, 'Disponível', 1),
('Furadeira de Impacto', 'Bosch GSB 550', 'BR550A010', 25.50, 'Disponível', 1),
('Furadeira de Impacto', 'Bosch GSB 550', 'BR550A011', 25.50, 'Disponível', 1),
('Furadeira de Impacto', 'Bosch GSB 550', 'BR550A012', 25.50, 'Disponível', 1),
('Lixadeira Roto Orbital', 'Makita BO5031', 'MKRO013', 35.00, 'Em Uso', 1),
('Lixadeira Roto Orbital', 'Makita BO5031', 'MKRO014', 35.00, 'Em Manutenção', 1),
('Lixadeira Roto Orbital', 'Makita BO5031', 'MKRO015', 35.00, 'Em Manutenção', 1),
('Mini Escavadeira', 'Bobcat E10', 'E10-XC016', 850.00, 'Em Uso', 2),
('Mini Escavadeira', 'Bobcat E10', 'E10-XC017', 850.00, 'Em Uso', 2),
('Mini Escavadeira', 'Bobcat E10', 'E10-XC018', 850.00, 'Em Manutenção', 2),
('Mini Escavadeira', 'Bobcat E10', 'E10-XC019', 850.00, 'Em Manutenção', 2),
('Mini Escavadeira', 'Bobcat E10', 'E10-XC020', 850.00, 'Em Manutenção', 2),
('Mini Escavadeira', 'Bobcat E10', 'E10-XC021', 850.00, 'Em Manutenção', 2),
('Mini Escavadeira', 'Bobcat E10', 'E10-XC022', 850.00, 'Disponível', 2),
('Mini Escavadeira', 'Bobcat E10', 'E10-XC023', 850.00, 'Disponível', 2),
('Mini Escavadeira', 'Bobcat E10', 'E10-XC024', 850.00, 'Disponível', 2),
('Mini Escavadeira', 'Bobcat E10', 'E10-XC025', 850.00, 'Disponível', 2),
('Mini Escavadeira', 'Bobcat E10', 'E10-XC026', 850.00, 'Disponível', 2),
('Mini Escavadeira', 'Bobcat E10', 'E10-XC027', 850.00, 'Disponível', 2),
('Placa Vibratória', 'Wacker Neuson VP1550', 'WN-PV028', 120.00, 'Em Uso', 2),
('Placa Vibratória', 'Wacker Neuson VP1550', 'WN-PV029', 120.00, 'Em Uso', 2),
('Placa Vibratória', 'Wacker Neuson VP1550', 'WN-PV030', 120.00, 'Em Uso', 2),
('Placa Vibratória', 'Wacker Neuson VP1550', 'WN-PV031', 120.00, 'Em Manutenção', 2),
('Placa Vibratória', 'Wacker Neuson VP1550', 'WN-PV032', 120.00, 'Em Manutenção', 2),
('Placa Vibratória', 'Wacker Neuson VP1550', 'WN-PV033', 120.00, 'Em Manutenção', 2),
('Placa Vibratória', 'Wacker Neuson VP1550', 'WN-PV034', 120.00, 'Em Manutenção', 2),
('Placa Vibratória', 'Wacker Neuson VP1550', 'WN-PV035', 120.00, 'Em Manutenção', 2),
('Placa Vibratória', 'Wacker Neuson VP1550', 'WN-PV036', 120.00, 'Em Manutenção', 2),
('Placa Vibratória', 'Wacker Neuson VP1550', 'WN-PV037', 120.00, 'Em Manutenção', 2),
('Placa Vibratória', 'Wacker Neuson VP1550', 'WN-PV038', 120.00, 'Em Manutenção', 2),
('Placa Vibratória', 'Wacker Neuson VP1550', 'WN-PV039', 120.00, 'Em Manutenção', 2),
('Placa Vibratória', 'Wacker Neuson VP1550', 'WN-PV040', 120.00, 'Em Manutenção', 2),
('Placa Vibratória', 'Wacker Neuson VP1550', 'WN-PV041', 120.00, 'Disponível', 2),
('Placa Vibratória', 'Wacker Neuson VP1550', 'WN-PV042', 120.00, 'Disponível', 2),
('Motosserra a Gasolina', 'Stihl MS 170', 'ST-MS043', 90.00, 'Em Uso', 3),
('Motosserra a Gasolina', 'Stihl MS 170', 'ST-MS044', 90.00, 'Em Uso', 3),
('Motosserra a Gasolina', 'Stihl MS 170', 'ST-MS045', 90.00, 'Em Uso', 3),
('Motosserra a Gasolina', 'Stihl MS 170', 'ST-MS046', 90.00, 'Disponível', 3),
('Motosserra a Gasolina', 'Stihl MS 170', 'ST-MS047', 90.00, 'Disponível', 3),
('Motosserra a Gasolina', 'Stihl MS 170', 'ST-MS048', 90.00, 'Disponível', 3),
('Motosserra a Gasolina', 'Stihl MS 170', 'ST-MS049', 90.00, 'Disponível', 3),
('Motosserra a Gasolina', 'Stihl MS 170', 'ST-MS050', 90.00, 'Disponível', 3),
('Detector de Gás 4 em 1', 'BW Technologies GasAlert', 'BWGA051', 45.00, 'Em Manutenção', 4),
('Detector de Gás 4 em 1', 'BW Technologies GasAlert', 'BWGA052', 45.00, 'Em Manutenção', 4),
('Detector de Gás 4 em 1', 'BW Technologies GasAlert', 'BWGA053', 45.00, 'Em Manutenção', 4),
('Detector de Gás 4 em 1', 'BW Technologies GasAlert', 'BWGA054', 45.00, 'Disponível', 4),
('Detector de Gás 4 em 1', 'BW Technologies GasAlert', 'BWGA055', 45.00, 'Disponível', 4),
('Detector de Gás 4 em 1', 'BW Technologies GasAlert', 'BWGA056', 45.00, 'Disponível', 4),
('Detector de Gás 4 em 1', 'BW Technologies GasAlert', 'BWGA057', 45.00, 'Disponível', 4),
('Detector de Gás 4 em 1', 'BW Technologies GasAlert', 'BWGA058', 45.00, 'Disponível', 4),
('Detector de Gás 4 em 1', 'BW Technologies GasAlert', 'BWGA059', 45.00, 'Disponível', 4),
('Detector de Gás 4 em 1', 'BW Technologies GasAlert', 'BWGA060', 45.00, 'Disponível', 4),
('Detector de Gás 4 em 1', 'BW Technologies GasAlert', 'BWGA061', 45.00, 'Disponível', 4),
('Detector de Gás 4 em 1', 'BW Technologies GasAlert', 'BWGA062', 45.00, 'Disponível', 4),
('Detector de Gás 4 em 1', 'BW Technologies GasAlert', 'BWGA063', 45.00, 'Disponível', 4),
('Detector de Gás 4 em 1', 'BW Technologies GasAlert', 'BWGA064', 45.00, 'Disponível', 4),
('Detector de Gás 4 em 1', 'BW Technologies GasAlert', 'BWGA065', 45.00, 'Disponível', 4),
('Detector de Gás 4 em 1', 'BW Technologies GasAlert', 'BWGA066', 45.00, 'Disponível', 4),
('Gerador a Diesel 5 kVA', 'Honda EU7000', 'HDG7067', 350.00, 'Em Uso', 5),
('Gerador a Diesel 5 kVA', 'Honda EU7000', 'HDG7068', 350.00, 'Em Uso', 5),
('Gerador a Diesel 5 kVA', 'Honda EU7000', 'HDG7069', 350.00, 'Disponível', 5),
('Gerador a Diesel 5 kVA', 'Honda EU7000', 'HDG7070', 350.00, 'Disponível', 5),
('Gerador a Diesel 5 kVA', 'Honda EU7000', 'HDG7071', 350.00, 'Disponível', 5),
('Gerador a Diesel 5 kVA', 'Honda EU7000', 'HDG7072', 350.00, 'Disponível', 5),
('Paleteira Manual 2.5T', 'Paletrans PT2500', 'PT25073', 60.00, 'Em Uso', 6),
('Paleteira Manual 2.5T', 'Paletrans PT2500', 'PT25074', 60.00, 'Em Uso', 6),
('Paleteira Manual 2.5T', 'Paletrans PT2500', 'PT25075', 60.00, 'Em Uso', 6),
('Paleteira Manual 2.5T', 'Paletrans PT2500', 'PT25076', 60.00, 'Em Manutenção', 6),
('Paleteira Manual 2.5T', 'Paletrans PT2500', 'PT25077', 60.00, 'Em Manutenção', 6),
('Paleteira Manual 2.5T', 'Paletrans PT2500', 'PT25078', 60.00, 'Em Manutenção', 6),
('Paleteira Manual 2.5T', 'Paletrans PT2500', 'PT25079', 60.00, 'Em Manutenção', 6),
('Paleteira Manual 2.5T', 'Paletrans PT2500', 'PT25080', 60.00, 'Em Manutenção', 6),
('Paleteira Manual 2.5T', 'Paletrans PT2500', 'PT25081', 60.00, 'Disponível', 6),
('Paleteira Manual 2.5T', 'Paletrans PT2500', 'PT25082', 60.00, 'Disponível', 6),
('Parafusadeira Drywall', 'Dewalt DW274', 'DW-DRY083', 55.00, 'Em Manutenção', 7),
('Parafusadeira Drywall', 'Dewalt DW274', 'DW-DRY084', 55.00, 'Disponível', 7),
('Parafusadeira Drywall', 'Dewalt DW274', 'DW-DRY085', 55.00, 'Disponível', 7),
('Parafusadeira Drywall', 'Dewalt DW274', 'DW-DRY086', 55.00, 'Disponível', 7),
('Parafusadeira Drywall', 'Dewalt DW274', 'DW-DRY087', 55.00, 'Disponível', 7),
('Bomba Submersível', 'Leão Dancor', 'LDSB088', 80.00, 'Em Uso', 8),
('Bomba Submersível', 'Leão Dancor', 'LDSB089', 80.00, 'Em Uso', 8),
('Bomba Submersível', 'Leão Dancor', 'LDSB090', 80.00, 'Em Uso', 8),
('Bomba Submersível', 'Leão Dancor', 'LDSB091', 80.00, 'Em Manutenção', 8),
('Bomba Submersível', 'Leão Dancor', 'LDSB092', 80.00, 'Disponível', 8),
('Bomba Submersível', 'Leão Dancor', 'LDSB093', 80.00, 'Disponível', 8),
('Bomba Submersível', 'Leão Dancor', 'LDSB094', 80.00, 'Disponível', 8),
('Bomba Submersível', 'Leão Dancor', 'LDSB095', 80.00, 'Disponível', 8),
('Bomba Submersível', 'Leão Dancor', 'LDSB096', 80.00, 'Disponível', 8),
('Bomba Submersível', 'Leão Dancor', 'LDSB097', 80.00, 'Disponível', 8),
('Bomba Submersível', 'Leão Dancor', 'LDSB098', 80.00, 'Disponível', 8),
('Bomba Submersível', 'Leão Dancor', 'LDSB099', 80.00, 'Disponível', 8),
('Bomba Submersível', 'Leão Dancor', 'LDSB100', 80.00, 'Disponível', 8),
('Bomba Submersível', 'Leão Dancor', 'LDSB101', 80.00, 'Disponível', 8),
('Bomba Submersível', 'Leão Dancor', 'LDSB102', 80.00, 'Disponível', 8),
('Bomba Submersível', 'Leão Dancor', 'LDSB103', 80.00, 'Disponível', 8),
('Bomba Submersível', 'Leão Dancor', 'LDSB104', 80.00, 'Disponível', 8),
('Bomba Submersível', 'Leão Dancor', 'LDSB105', 80.00, 'Disponível', 8),
('Pistola Airless', 'Graco Magnum X5', 'GMAGX106', 110.00, 'Em Uso', 9),
('Pistola Airless', 'Graco Magnum X5', 'GMAGX107', 110.00, 'Em Uso', 9),
('Pistola Airless', 'Graco Magnum X5', 'GMAGX108', 110.00, 'Em Uso', 9),
('Pistola Airless', 'Graco Magnum X5', 'GMAGX109', 110.00, 'Em Manutenção', 9),
('Pistola Airless', 'Graco Magnum X5', 'GMAGX110', 110.00, 'Em Manutenção', 9),
('Pistola Airless', 'Graco Magnum X5', 'GMAGX111', 110.00, 'Disponível', 9),
('Pistola Airless', 'Graco Magnum X5', 'GMAGX112', 110.00, 'Disponível', 9),
('Pistola Airless', 'Graco Magnum X5', 'GMAGX113', 110.00, 'Disponível', 9),
('Pistola Airless', 'Graco Magnum X5', 'GMAGX114', 110.00, 'Disponível', 9),
('Andaime Tubular 1.0m', 'Tubex Padrão', 'TBX-A115', 15.00, 'Em Manutenção', 10),
('Andaime Tubular 1.0m', 'Tubex Padrão', 'TBX-A116', 15.00, 'Em Manutenção', 10),
('Máquina de Solda Inversora', 'Esab Bantam 140i', 'ESB-S117', 95.00, 'Em Uso', 11),
('Máquina de Solda Inversora', 'Esab Bantam 140i', 'ESB-S118', 95.00, 'Em Uso', 11),
('Máquina de Solda Inversora', 'Esab Bantam 140i', 'ESB-S119', 95.00, 'Disponível', 11),
('Máquina de Solda Inversora', 'Esab Bantam 140i', 'ESB-S120', 95.00, 'Disponível', 11),
('Máquina de Solda Inversora', 'Esab Bantam 140i', 'ESB-S121', 95.00, 'Disponível', 11),
('Máquina de Solda Inversora', 'Esab Bantam 140i', 'ESB-S122', 95.00, 'Disponível', 11),
('Máquina de Solda Inversora', 'Esab Bantam 140i', 'ESB-S123', 95.00, 'Disponível', 11),
('Máquina de Solda Inversora', 'Esab Bantam 140i', 'ESB-S124', 95.00, 'Disponível', 11),
('Máquina de Solda Inversora', 'Esab Bantam 140i', 'ESB-S125', 95.00, 'Disponível', 11),
('Máquina de Solda Inversora', 'Esab Bantam 140i', 'ESB-S126', 95.00, 'Disponível', 11),
('Nível a Laser Rotativo', 'Spectra Precision HV302', 'SP-NL127', 180.00, 'Em Uso', 12),
('Nível a Laser Rotativo', 'Spectra Precision HV302', 'SP-NL128', 180.00, 'Em Manutenção', 12),
('Lavadora de Alta Pressão', 'Karcher HD 5/11 C', 'KCHD129', 70.00, 'Em Manutenção', 13),
('Lavadora de Alta Pressão', 'Karcher HD 5/11 C', 'KCHD130', 70.00, 'Disponível', 13),
('Lavadora de Alta Pressão', 'Karcher HD 5/11 C', 'KCHD131', 70.00, 'Disponível', 13),
('Lavadora de Alta Pressão', 'Karcher HD 5/11 C', 'KCHD132', 70.00, 'Disponível', 13),
('Lavadora de Alta Pressão', 'Karcher HD 5/11 C', 'KCHD133', 70.00, 'Disponível', 13),
('Lavadora de Alta Pressão', 'Karcher HD 5/11 C', 'KCHD134', 70.00, 'Disponível', 13),
('Lavadora de Alta Pressão', 'Karcher HD 5/11 C', 'KCHD135', 70.00, 'Disponível', 13),
('Lavadora de Alta Pressão', 'Karcher HD 5/11 C', 'KCHD136', 70.00, 'Disponível', 13),
('Lavadora de Alta Pressão', 'Karcher HD 5/11 C', 'KCHD137', 70.00, 'Disponível', 13),
('Lavadora de Alta Pressão', 'Karcher HD 5/11 C', 'KCHD138', 70.00, 'Disponível', 13),
('Torre de Iluminação Móvel', 'Atlas Copco HiLight', 'ACHL139', 220.00, 'Em Uso', 14),
('Torre de Iluminação Móvel', 'Atlas Copco HiLight', 'ACHL140', 220.00, 'Disponível', 14),
('Conjunto de Chaves', 'Gedore', 'GDR-CC141', 10.00, 'Em Uso', 15),
('Conjunto de Chaves', 'Gedore', 'GDR-CC142', 10.00, 'Em Uso', 15),
('Conjunto de Chaves', 'Gedore', 'GDR-CC143', 10.00, 'Em Uso', 15),
('Conjunto de Chaves', 'Gedore', 'GDR-CC144', 10.00, 'Disponível', 15),
('Conjunto de Chaves', 'Gedore', 'GDR-CC145', 10.00, 'Disponível', 15),
('Conjunto de Chaves', 'Gedore', 'GDR-CC146', 10.00, 'Disponível', 15),
('Conjunto de Chaves', 'Gedore', 'GDR-CC147', 10.00, 'Disponível', 15),
('Conjunto de Chaves', 'Gedore', 'GDR-CC148', 10.00, 'Disponível', 15),
('Conjunto de Chaves', 'Gedore', 'GDR-CC149', 10.00, 'Disponível', 15),
('Conjunto de Chaves', 'Gedore', 'GDR-CC150', 10.00, 'Disponível', 15),
('Conjunto de Chaves', 'Gedore', 'GDR-CC151', 10.00, 'Disponível', 15),
('Conjunto de Chaves', 'Gedore', 'GDR-CC152', 10.00, 'Disponível', 15),
('Conjunto de Chaves', 'Gedore', 'GDR-CC153', 10.00, 'Disponível', 15),
('Conjunto de Chaves', 'Gedore', 'GDR-CC154', 10.00, 'Disponível', 15),
('Conjunto de Chaves', 'Gedore', 'GDR-CC155', 10.00, 'Disponível', 15),
('Martelete Rompedor', 'Makita HM1202C', 'MKHM156', 130.00, 'Em Manutenção', 1),
('Martelete Rompedor', 'Makita HM1202C', 'MKHM157', 130.00, 'Disponível', 1),
('Martelete Rompedor', 'Makita HM1202C', 'MKHM158', 130.00, 'Disponível', 1),
('Martelete Rompedor', 'Makita HM1202C', 'MKHM159', 130.00, 'Disponível', 1),
('Martelete Rompedor', 'Makita HM1202C', 'MKHM160', 130.00, 'Disponível', 1),
('Retroescavadeira', 'Case 580N', 'CS580N-161', 950.00, 'Disponível', 2),
('Plataforma Elevatória Tesoura', 'Skyjack SJIII', 'SJ3162', 600.00, 'Em Uso', 10),
('Plataforma Elevatória Tesoura', 'Skyjack SJIII', 'SJ3163', 600.00, 'Disponível', 10),
('Plataforma Elevatória Tesoura', 'Skyjack SJIII', 'SJ3164', 600.00, 'Disponível', 10),
('Plataforma Elevatória Tesoura', 'Skyjack SJIII', 'SJ3165', 600.00, 'Disponível', 10),
('Plataforma Elevatória Tesoura', 'Skyjack SJIII', 'SJ3166', 600.00, 'Disponível', 10);

-- Tabela 6: Estoque

INSERT INTO ESTOQUE (equipamento_id, quant_disponivel, quant_total, data_revisao) VALUES
(1, 8, 12, '2025-11-01'), 
(2, 0, 3, '2025-10-25'),
(3, 6, 12, '2025-11-15'),
(4, 2, 15, '2025-10-05'),
(5, 5, 8, '2025-11-20'),
(6, 13, 16, '2025-10-18'), 
(7, 4, 6, '2025-11-25'),
(8, 2, 10, '2025-10-01'),
(9, 4, 5, '2025-11-05'),
(10, 14, 18, '2025-10-22'),
(11, 4, 9, '2025-11-12'),
(12, 0, 2, '2025-10-08'),
(13, 8, 10, '2025-11-28'),
(14, 1, 2, '2025-10-14'),
(15, 9, 10, '2025-11-07'),
(16, 1, 2, '2025-10-29'),
(17, 12, 15, '2025-11-18'),
(18, 4, 5, '2025-10-03'),
(19, 1, 1, '2025-11-09'),
(20, 4, 5, '2025-11-10');

-- Tabela 10: Manutenção

INSERT INTO MANUTENCAO (equipamento_id, fornecedor_id, dt_inicio, dt_final, custo, descricao) VALUES
(2, 20, '2025-10-15 08:00:00', '2025-10-20 17:30:00', 85.50, 'Troca de escovas e lubrificação preventiva.'),
(3, 20, '2025-11-01 10:30:00', '2025-11-05 14:00:00', 95.00, 'Conserto do motor e substituição do cabo de energia.'),
(4, 20, '2025-11-20 15:00:00', NULL, 120.00, 'Revisão completa e calibração de torque. Em andamento.'),
(14, 1, '2025-10-25 09:00:00', '2025-10-28 16:00:00', 180.50, 'Troca da base de lixamento e verificação do motor.'),
(15, 1, '2025-11-18 08:30:00', NULL, 210.00, 'Reparo na excentricidade. Aguardando peça de reposição.'),
(18, 4, '2025-10-05 14:00:00', '2025-10-15 11:00:00', 3500.00, 'Manutenção do sistema hidráulico e troca de filtros.'),
(19, 4, '2025-11-08 07:00:00', '2025-11-20 12:00:00', 4100.00, 'Reparo estrutural na lança e pintura protetora.'),
(20, 4, '2025-11-25 10:00:00', NULL, 850.00, 'Diagnóstico eletrônico de falhas. Em análise.'),
(21, 4, '2025-11-27 15:00:00', NULL, 6500.00, 'Revisão completa do motor (1000h).'),
(31, 19, '2025-10-10 11:00:00', '2025-10-14 17:00:00', 750.00, 'Substituição de correias e amortecedores de vibração.'),
(32, 19, '2025-10-22 13:00:00', '2025-10-28 09:00:00', 920.00, 'Conserto do motor a diesel e troca de óleo.'),
(33, 19, '2025-11-01 08:00:00', '2025-11-05 16:30:00', 1050.00, 'Revisão do sistema de ignição e limpeza de carburador.'),
(34, 19, '2025-11-10 14:30:00', '2025-11-14 12:00:00', 600.00, 'Alinhamento e balanceamento do disco vibratório.'),
(35, 13, '2025-11-16 11:00:00', '2025-11-21 17:00:00', 1150.00, 'Manutenção preventiva de motores.'),
(36, 13, '2025-11-23 09:30:00', NULL, 1500.00, 'Troca de pistão e anéis do motor. Em andamento.'),
(37, 13, '2025-10-01 10:00:00', '2025-10-04 18:00:00', 480.00, 'Revisão do sistema de aceleração e cabos.'),
(38, 13, '2025-10-18 13:00:00', '2025-10-25 10:00:00', 800.00, 'Reparo no tanque de combustível e mangueiras.'),
(39, 13, '2025-11-03 14:00:00', '2025-11-08 15:30:00', 550.00, 'Troca de vela, filtro de ar e combustível.'),
(40, 13, '2025-11-11 08:30:00', NULL, 1250.00, 'Diagnóstico de superaquecimento. Aguardando laudo.'),
(51, 6, '2025-10-20 09:00:00', '2025-10-22 17:00:00', 450.00, 'Calibração dos sensores de CO e metano.'),
(52, 6, '2025-11-05 14:00:00', '2025-11-07 16:00:00', 420.00, 'Substituição da célula de oxigênio.'),
(53, 6, '2025-11-25 10:00:00', NULL, 390.00, 'Revisão periódica de segurança. Em andamento.'),
(76, 5, '2025-10-08 07:30:00', '2025-10-10 12:00:00', 150.00, 'Troca de rodas e lubrificação dos eixos.'),
(83, 2, '2025-11-15 14:00:00', '2025-11-18 11:00:00', 110.90, 'Reparo no mandril e substituição do cabo de força.'),
(129, 3, '2025-11-26 10:00:00', NULL, 350.00, 'Vazamento na bomba de alta pressão. Peça de reposição solicitada.');

-- Tabela 7: Aluguel

INSERT INTO ALUGUEL (cliente_id, funcionario_id, data_inicio, data_devolucao, valor_total) VALUES
(1, 2, '2025-11-20 10:00:00', '2025-11-25 14:30:00', 350.50),
(14, 5, '2025-11-15 08:30:00', '2025-11-22 17:00:00', 2100.00),
(3, 8, '2025-11-27 11:00:00', NULL, 120.00),
(16, 10, '2025-11-01 09:15:00', '2025-11-10 16:00:00', 850.90),
(5, 1, '2025-10-28 14:00:00', '2025-11-04 11:45:00', 45.00),
(11, 2, '2025-11-26 15:30:00', NULL, 650.00),
(7, 5, '2025-11-18 10:45:00', '2025-11-28 09:00:00', 95.00),
(20, 13, '2025-11-12 13:00:00', '2025-11-19 14:00:00', 1500.00),
(9, 8, '2025-11-05 09:30:00', '2025-11-15 17:30:00', 280.00),
(2, 2, '2025-10-01 16:00:00', '2025-10-30 10:00:00', 1050.00),
(13, 15, '2025-11-21 11:30:00', NULL, 30.00),
(4, 1, '2025-11-23 08:00:00', '2025-11-24 08:00:00', 60.00),
(18, 5, '2025-11-10 14:15:00', '2025-11-20 13:00:00', 4200.00),
(6, 10, '2025-11-25 10:00:00', NULL, 75.00),
(15, 13, '2025-11-08 07:00:00', '2025-11-13 18:00:00', 1100.00),
(8, 8, '2025-11-03 12:00:00', '2025-11-06 12:00:00', 90.00),
(17, 2, '2025-11-27 16:45:00', NULL, 50.00),
(10, 15, '2025-11-16 09:00:00', '2025-11-21 15:00:00', 180.00),
(12, 1, '2025-11-02 11:00:00', '2025-11-05 11:00:00', 135.00),
(19, 13, '2025-10-15 13:30:00', '2025-11-15 12:00:00', 310.00);

-- Tabela 9: Pagamentos

INSERT INTO PAGAMENTOS (aluguel_id, valor_pago, metodo_pagamento, dt_pagamento) VALUES
(1, 350.50, 'Cartão de Crédito', '2025-11-20 10:05:00'),
(2, 2100.00, 'Boleto', '2025-11-15 08:45:00'),
(3, 120.00, 'PIX', '2025-11-27 11:05:00'),
(4, 850.90, 'Transferência Bancária', '2025-11-01 09:20:00'),
(5, 45.00, 'Cartão de Débito', '2025-10-28 14:05:00'),
(6, 650.00, 'PIX', '2025-11-26 15:35:00'),
(7, 95.00, 'Dinheiro', '2025-11-18 10:50:00'),
(8, 1500.00, 'Transferência Bancária', '2025-11-12 13:05:00'),
(9, 140.00, 'Cartão de Crédito', '2025-11-05 09:35:00'),
(9, 140.00, 'Cartão de Crédito', '2025-11-15 17:35:00'),
(10, 1050.00, 'Boleto', '2025-10-01 16:10:00'),
(11, 30.00, 'PIX', '2025-11-21 11:40:00'),
(12, 60.00, 'Dinheiro', '2025-11-23 08:05:00'),
(13, 2000.00, 'Transferência Bancária', '2025-11-10 14:20:00'),
(13, 1500.00, 'Transferência Bancária', '2025-11-15 10:00:00'),
(13, 700.00, 'Transferência Bancária', '2025-11-20 13:05:00'),
(14, 75.00, 'PIX', '2025-11-25 10:05:00'),
(15, 1100.00, 'Boleto', '2025-11-08 07:15:00'),
(16, 90.00, 'Cartão de Débito', '2025-11-03 12:05:00'),
(17, 50.00, 'PIX', '2025-11-27 16:50:00'),
(18, 180.00, 'Dinheiro', '2025-11-16 09:10:00'),
(19, 135.00, 'Cartão de Crédito', '2025-11-02 11:05:00'),
(20, 310.00, 'Transferência Bancária', '2025-10-15 13:35:00'),
(1, 0.00, 'PIX', '2025-11-25 14:35:00'),
(2, 0.00, 'Dinheiro', '2025-11-22 17:05:00');

-- Tabela 11: Multas

INSERT INTO MULTAS (aluguel_id, valor_multa, descricao, dt_multa, status_pagamento) VALUES
(1, 75.00, 'Atraso de 1 dia na devolução do equipamento.', '2025-11-26 10:00:00', 'Pago'),
(2, 210.00, 'Dano leve no equipamento (Placa Vibratória).', '2025-11-22 17:30:00', 'Pendente'),
(4, 85.09, 'Atraso na devolução de 12 horas.', '2025-11-11 08:00:00', 'Pago'),
(5, 15.00, 'Equipamento devolvido sujo.', '2025-11-04 12:00:00', 'Pago'),
(7, 20.00, 'Atraso de 3 horas na devolução.', '2025-11-28 12:00:00', 'Pago'),
(8, 300.00, 'Perda de acessório da Mini Escavadeira.', '2025-11-19 14:15:00', 'Pendente'),
(9, 56.00, 'Atraso de 2 dias na devolução.', '2025-11-17 09:00:00', 'Pago'),
(10, 150.00, 'Dano moderado na Bomba Submersível.', '2025-10-30 11:30:00', 'Pago'),
(12, 12.00, 'Atraso de 4 horas na devolução.', '2025-11-24 12:00:00', 'Pago'),
(13, 840.00, 'Dano grave no equipamento (Retroescavadeira).', '2025-11-20 14:00:00', 'Pendente'),
(15, 110.00, 'Atraso de 1 dia na devolução.', '2025-11-14 10:00:00', 'Pago'),
(16, 18.00, 'Equipamento devolvido sujo (Mini Escavadeira).', '2025-11-06 12:30:00', 'Pago'),
(18, 500.00, 'Dano leve na Torre de Iluminação Móvel.', '2025-11-20 13:45:00', 'Pendente'),
(19, 31.00, 'Atraso de 1 dia na devolução.', '2025-11-16 11:00:00', 'Pago'),
(3, 15.00, 'Multa diária por atraso (Aluguel em aberto).', '2025-11-29 09:00:00', 'Pendente'),
(6, 20.00, 'Multa diária por atraso (Aluguel em aberto).', '2025-11-29 09:00:00', 'Pendente'),
(11, 20.00, 'Multa diária por atraso (Aluguel em aberto).', '2025-11-29 09:00:00', 'Pendente'),
(17, 10.00, 'Multa diária por atraso (Aluguel em aberto).', '2025-11-29 09:00:00', 'Pendente'),
(14, 5.00, 'Taxa administrativa por processamento de multa anterior.', '2025-10-20 15:00:00', 'Pago'),
(1, 10.00, 'Taxa de reembalagem por devolução inadequada.', '2025-11-25 15:00:00', 'Pago');

-- Tabela 8: Aluguem_Item

INSERT INTO ALUGUEL_ITEM (aluguel_id, equipamento_id, quantidade, valor_diaria) VALUES
(1, 1, 1, 25.50),
(1, 13, 1, 35.00),
(2, 28, 1, 120.00),
(2, 29, 1, 120.00),
(3, 75, 1, 60.00),
(4, 16, 1, 850.00),
(5, 107, 1, 110.00),
(5, 108, 1, 110.00),
(6, 127, 1, 180.00),
(7, 43, 1, 90.00),
(7, 44, 1, 90.00),
(8, 141, 1, 10.00),
(8, 142, 1, 10.00),
(8, 143, 1, 10.00),
(9, 1, 1, 25.50),
(9, 13, 1, 35.00),
(10, 88, 1, 80.00),
(10, 89, 1, 80.00),
(11, 30, 1, 120.00),
(12, 67, 1, 350.00),
(13, 162, 1, 600.00),
(14, 17, 1, 850.00),
(15, 139, 1, 220.00),
(15, 68, 1, 350.00),
(16, 117, 1, 95.00),
(17, 73, 1, 60.00),
(18, 118, 1, 95.00),
(19, 45, 1, 90.00),
(20, 90, 1, 80.00);