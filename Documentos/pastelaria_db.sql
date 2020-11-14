CREATE DATABASE pastelaria_db;

USE pastelaria_db;

CREATE TABLE tb_cliente
(
	id_cliente INT NOT NULL PRIMARY KEY AUTO_INCREMENT,
    nome	VARCHAR(100) NOT NULL,
    cpf 	VARCHAR(11) NOT NULL UNIQUE,
    data_pagamento DATETIME,
    telefone CHAR(11) NOT NULL,
    senha VARCHAR(200) NULL DEFAULT NULL,
    compra_fiado TINYINT(4)
);


CREATE TABLE tb_funcionario
(
	id_funcionario INT  NOT NULL PRIMARY KEY AUTO_INCREMENT,
    matricula  CHAR(10) NOT NULL,
    grupo TINYINT(4),
    nome VARCHAR(100) NOT NULL,
    cpf VARCHAR(11) NOT NULL UNIQUE,
    telefone CHAR(11) NOT NULL,
    senha VARCHAR(200) NOT NULL,
	compra_fiado TINYINT(4),
    data_pagamento DATE 
);


CREATE TABLE tb_produto
(
	id_produto INT  NOT NULL PRIMARY KEY AUTO_INCREMENT, 
    nome	VARCHAR(100) NOT NULL ,
    descricao	VARCHAR(200) NOT NULL,
    valor_unitario	DECIMAL(11,2) NOT NULL,
    foto BLOB
);


CREATE TABLE tb_empresa
(
	id_empresa INT  NOT NULL PRIMARY KEY AUTO_INCREMENT, 
    multa_atraso	DECIMAL(11,2),
    taxa_juro_diaria	DECIMAL(11,2)
);

CREATE TABLE tb_comanda
(
	id_comanda INT  NOT NULL PRIMARY KEY AUTO_INCREMENT, 
    funcionario_id INT  NOT NULL, 
    cliente_id INT  NOT NULL,
    valor_cobrado DECIMAL(11,2) NULL,
    -- valor_total DECIMAL(11,2) NULL DEFAULT NULL,
    numero_comanda VARCHAR(100) NOT  NULL,
    data_hora DATETIME NOT NULL,
    data_assinatura_fiado DATE,
    status_pagamento TINYINT,
    status_comanda TINYINT,
    
    
    CONSTRAINT KF_tb_funcionario__tb_comanda
	FOREIGN KEY (funcionario_id)
    REFERENCES tb_funcionario(id_funcionario),
    
    CONSTRAINT KF_tb_cliente__tb_comanda
    FOREIGN KEY (cliente_id)
    REFERENCES tb_cliente(id_cliente)
    
);


CREATE TABLE tb_comanda_produto
(
	id_comanda_produto INT NOT NULL PRIMARY KEY AUTO_INCREMENT,
    funcionario_id INT NOT NULL,
    produto_id INT  NOT NULL,
    comanda_id INT  NOT NULL,
    quantidade TINYINT,
	valor_unitario DECIMAL(11,2),
    
	CONSTRAINT  FK_tb_comanda__tb_comanda_produto
	FOREIGN KEY (comanda_id)
	REFERENCES tb_comanda(id_comanda),
   
	CONSTRAINT FK_tb_produto__tb_comanda_produto
	FOREIGN KEY (produto_id)
	REFERENCES tb_produto(id_produto),
   
	CONSTRAINT FK_tb_funcionario__tb_comanda_Produto
	FOREIGN KEY (funcionario_id)
	REFERENCES tb_funcionario(id_funcionario)
    
);


CREATE TABLE tb_recebimento
(
	id_recebimento 	INT NOT NULL PRIMARY KEY AUTO_INCREMENT,
    id_funcionario INT(11) NOT NULL,
    tipo 			TINYINT,
    valor_acrescimo DECIMAL(11,2) NULL DEFAULT NULL,
    valor_desconto DECIMAL(11,2) NULL DEFAULT NULL,
    data_hora		DATETIME,
    valor_total DECIMAL(11,2) NULL DEFAULT NULL,
    
    CONSTRAINT FK_tb_recebimento__tb_funcionario
	FOREIGN KEY (id_funcionario)
	REFERENCES tb_funcionario (id_funcionario)
);


CREATE TABLE tb_comanda_recebimento 
(
   id_comanda_recebimento INT  NOT NULL PRIMARY KEY AUTO_INCREMENT,
   recebimento_id INT  UNIQUE NOT NULL,
   comanda_id INT  UNIQUE NOT NULL,
   
   CONSTRAINT FK_tb_comanda__tb_comanda_recebimento
   FOREIGN KEY  (comanda_id)
   REFERENCES tb_comanda(id_comanda),
   
   CONSTRAINT FK_tb_recebimento__tb_comanda_recebimento
   FOREIGN KEY (recebimento_id)
   REFERENCES tb_recebimento(id_recebimento)
);


UPDATE tb_funcionario 
SET status_fiado = 1
WHERE id_funcionario = 1  or id_funcionario = 3 OR id_funcionario = 4; 

UPDATE tb_recebimento 
SET valor_acrescimo = 252.00
WHERE id_recebimento = 15; 

INSERT INTO tb_produto
(nome, descricao, valor_unitario)
VALUES
('Pastel de Carne', 'Carne de Primeira!', 4.50);

SELECT * FROM tb_cliente;
SELECT * FROM tb_comanda;

DELETE FROM tb_comanda
WHERE funcionario_id = 1;


UPDATE tb_recebimento 
SET valor_desconto = 0.00
WHERE id_recebimento = 2;


SELECT if(datediff(now(), data_assinatura_fiado) > 30, datediff(now(), data_assinatura_fiado) - 30, 0) AS 'Dias Atrasado' FROM tb_comanda
WHERE id_comanda = 24;

UPDATE tb_comanda 
SET data_assinatura_fiado = '2020-05-15'
WHERE id_comanda = 23;


-- Add EMPRESA
INSERT INTO tb_empresa
(multa_atraso, taxa_juro_diaria)
VALUES
(15.00, 1.50);

-- Teste
SELECT tbc.id_comanda AS ID, 
tbc.numero_comanda AS Comanda, 
tbc.data_hora AS Data, 
tbc.valor_cobrado AS Valor, 
if(datediff(now(), data_assinatura_fiado) > 30, datediff(now(), data_assinatura_fiado) - 30, 0) AS 'Dias Atrasado',
if(datediff(now(), tbc.data_assinatura_fiado) > 30,tbe.multa_atraso, 0),
tbe.multa_atraso,
tbe.taxa_juro_diaria 
FROM tb_empresa tbe, tb_comanda tbc
INNER JOIN tb_funcionario tbf 
ON tbc.funcionario_id = tbf.id_funcionario 
WHERE tbc.cliente_id = 7 AND tbc.status_pagamento = 0;

-- 
SELECT 	tbc.id_comanda AS ID, 
		tbc.numero_comanda AS Comanda, 
		tbc.data_hora AS Data, 
        tbc.valor_cobrado AS Valor, 
        if(datediff(now(), tbc.data_assinatura_fiado) > 30, datediff(now(), tbc.data_assinatura_fiado) - 30, 0) AS 'Dias Atrasado', 
        if(datediff(now(), tbc.data_assinatura_fiado) > 30, tbe.multa_atraso * (datediff(now(), tbc.data_assinatura_fiado) - 30), 0) AS Multa, 
        if(datediff(now(), tbc.data_assinatura_fiado) > 30, tbe.taxa_juro_diaria * (datediff(now(), tbc.data_assinatura_fiado) - 30), 0) AS Juros,
        if(datediff(now(), tbc.data_assinatura_fiado) > 30, (tbe.multa_atraso * (datediff(now(), tbc.data_assinatura_fiado) - 30)) + (tbe.taxa_juro_diaria * (datediff(now(), tbc.data_assinatura_fiado) - 30)) + (tbc.valor_cobrado), tbc.valor_cobrado) AS 'VALOR TOTAL'
FROM tb_empresa tbe, tb_comanda tbc
INNER JOIN tb_funcionario tbf 
ON tbc.funcionario_id = tbf.id_funcionario;

-- Comandas Abertas 
SELECT	tbc.id_comanda AS 'ID COMANDA',
		tbc.numero_comanda  AS 'Nº COMANDA',
        tbc.data_hora AS DATA,
        if(tbc.status_comanda = 0,'ABERTA', 'FECHADA')  AS STATUS,
		tbcp.id_comanda_produto AS 'ID CP',
        tbp.nome AS PRODUTO,
        tbcp.quantidade AS QTD,
        tbcp.valor_unitario AS 'UNITÁRIO',
        tbf.nome AS FUNCIONARIO
        FROM tb_comanda tbc
        INNER JOIN tb_comanda_produto tbcp 
        ON tbcp.comanda_id = tbc.id_comanda
        INNER JOIN tb_produto tbp
        ON tbcp.produto_id = tbp.id_produto
        INNER JOIN tb_funcionario tbf
        ON tbcp.funcionario_id = tbf.id_funcionario
        WHERE tbc.status_comanda = 0;
        

-- Comandas Pagas a vista
SELECT 	id_comanda AS ID,
		numero_comanda  AS 'Nº COMANDA',
        data_hora AS DATA,
        if(status_pagamento = 0,'ABERTA', 'FECHADA')  AS STATUS
        FROM tb_comanda 
        GROUP BY numero_comanda;

SELECT 	tbcp.id_comanda_produto AS 'ID CP',
        tbp.nome AS PRODUTO,
        tbcp.quantidade AS QTD,
        tbcp.valor_unitario AS 'UNITÁRIO',
        tbf.nome AS FUNCIONARIO,
        tbc.id_comanda AS 'ID COMANDA'
        FROM tb_comanda_produto tbcp
        INNER JOIN tb_comanda tbc
        ON tbcp.comanda_id = tbc.id_comanda
        INNER JOIN tb_produto tbp
        ON tbcp.produto_id = tbp.id_produto
        INNER JOIN tb_funcionario tbf
        ON tbcp.funcionario_id = tbf.id_funcionario
        GROUP BY tbcp.id_comanda_produto;

SELECT	tbc.id_comanda AS 'ID COMANDA',
		tbc.numero_comanda  AS 'Nº COMANDA',
        tbc.data_hora AS DATA,
        if(tbc.status_pagamento = 0,'ABERTA', 'FECHADA')  AS STATUS,
		tbcp.id_comanda_produto AS 'ID CP',
        tbp.nome AS PRODUTO,
        tbcp.quantidade AS QTD,
        tbcp.valor_unitario AS 'UNITÁRIO',
        tbf.nome AS FUNCIONARIO
        FROM tb_comanda_produto tbcp
        INNER JOIN tb_comanda tbc
        ON tbcp.comanda_id = tbc.id_comanda
        INNER JOIN tb_produto tbp
        ON tbcp.produto_id = tbp.id_produto
        INNER JOIN tb_funcionario tbf
        ON tbcp.funcionario_id = tbf.id_funcionario
        ORDER BY tbc.id_comanda asc ;

-- Comandas  Marcadas no Fiado 
SELECT 	tbc.id_comanda AS 'ID COMANDA',
		tbc.numero_comanda  AS 'Nº COMANDA',
        tbc.data_hora AS DATA,
        if(tbc.status_comanda = 2,'Marcado Fiado', 'A vista')  AS STATUS,
        tbcl.nome AS CLIENTE,
        tbcl.id_cliente AS ID, 
        tbcl.cpf AS CPF,
        tbcl.telefone AS TELEFONE,
		tbcp.id_comanda_produto AS 'ID CP',
        tbp.nome AS PRODUTO,
        tbcp.quantidade AS QTD,
        tbcp.valor_unitario AS 'UNITÁRIO',
        tbf.nome AS FUNCIONARIO
        FROM tb_comanda tbc 
        INNER JOIN tb_comanda_produto tbcp
        ON tbcp.comanda_id = tbc.id_comanda
        INNER JOIN tb_cliente tbcl
        ON tbc.cliente_id = tbcl.id_cliente
        INNER JOIN tb_funcionario tbf
        ON tbc.funcionario_id = tbf.id_funcionario
        INNER JOIN tb_produto tbp
        ON tbcp.produto_id = tbp.id_produto
        WHERE tbc.status_comanda = 1;



-- Recebimento á vista = 1
SELECT 	tbr.id_recebimento AS ID,
		tbr.data_hora  AS DATA,
        tbf.nome AS FUNCIONARIO,
        tbr.valor_acrescimo AS ACRESCIMO,
        tbr.valor_desconto  AS DESCONTO,
        tbr.valor_total AS VALOR
        FROM tb_recebimento tbr
        INNER JOIN tb_funcionario tbf
        ON tbr.id_funcionario = tbf.id_funcionario
        WHERE tbr.tipo = 1;

-- Recebimento fiado = 0
SELECT 	tbr.id_recebimento AS ID,
		tbr.data_hora  AS DATA,
        tbf.nome AS FUNCIONARIO,
        tbr.valor_acrescimo AS ACRESCIMO,
        tbr.valor_desconto  AS DESCONTO,
        tbr.valor_total AS VALOR
        FROM tb_recebimento tbr
        INNER JOIN tb_funcionario tbf
        ON tbr.id_funcionario = tbf.id_funcionario
        WHERE tbr.tipo = 2;

/*SELECT 	tbc.id_comanda AS ID
		tbc.numero_comanda AS COMANDA,
        tbc.data_hora AS DATA,
        DATEDIFF(tbc.data_assinatura_fiado, tbcl.data_pagamento) AS 'DIAS ATRASADOS',
        IF(DATEDIFF(tbc.data_assinatura_fiado, tbcl.data_pagamento) > 0, tbe.multa_atraso * (DATEDIFF(tbc.data_assinatura_fiado, tbcl.data_pagamento) ), 0) AS Multa, 
        IF(DATEDIFF(tbc.data_assinatura_fiado, tbcl.data_pagamento) > 0, tbe.taxa_juro_diaria * (DATEDIFF(tbc.data_assinatura_fiado, tbcl.data_pagamento) ), 0) AS Juros,
        tbr.*/

SELECT 	tbcl.nome AS CLIENTE,
		tbcl.data_pagamento AS 'DIA DO PAGAMENTO' , 
		IF(DATEDIFF(tbc.data_assinatura_fiado, tbcl.data_pagamento) > 0, DATEDIFF(tbc.data_assinatura_fiado, tbcl.data_pagamento) , 0) AS 'Dias Atrasado', 
        IF(DATEDIFF(tbc.data_assinatura_fiado, tbcl.data_pagamento) > 0, tbe.multa_atraso * (DATEDIFF(tbc.data_assinatura_fiado, tbcl.data_pagamento) ), 0) AS Multa, 
        IF(DATEDIFF(tbc.data_assinatura_fiado, tbcl.data_pagamento) > 0, tbe.taxa_juro_diaria * (DATEDIFF(tbc.data_assinatura_fiado, tbcl.data_pagamento) ), 0) AS Juros,
        IF(DATEDIFF(tbc.data_assinatura_fiado, tbcl.data_pagamento) > 0, (tbe.multa_atraso * (DATEDIFF(tbc.data_assinatura_fiado, tbcl.data_pagamento) )) + (tbe.taxa_juro_diaria * (DATEDIFF(tbc.data_assinatura_fiado, tbcl.data_pagamento) )) + (tbc.valor_cobrado), tbc.valor_cobrado) AS 'VALOR TOTAL'
        FROM tb_empresa tbe, tb_comanda tbc
		INNER JOIN tb_funcionario tbf 
		ON tbc.funcionario_id = tbf.id_funcionario
		INNER JOIN tb_cliente tbcl 
		ON tbc.cliente_id = tbcl.id_cliente;
        
