-- ============================================
-- Script: DOC_iva_recapitulativo_intracomunitario_trimestral.sql
-- Descrição: Este script documenta a criação de um relatório trimestral de IVA recapitulado para operações intracomunitárias.
-- Autor: Breno Portella
-- Data: 23/07/2024
-- ============================================

-- Seção 1: Consulta para extrair dados trimestrais de IVA recapitulado

    -- Seleciona dados de cabeçalhos de documentos e seus status para o trimestre especificado para uma unica empresa.

SELECT 
    TipoDoc,                -- Tipo de documento
    EspacoFiscal,           -- Espaço fiscal
    CONVERT(varchar, Data, 103) as Data, -- Data da gravação, convertida para formato 'dd/mm/yyyy'
    Nome,                   -- Nome do adquirente
    NumContribuinte,        -- Número do contribuinte adquirente
    Documento,              -- Número do documento
    TotalMerc,              -- Valor total das mercadorias
    TotalDocumento,         -- Valor total do documento
    Diario,                 -- Diário
    NumDiario,              -- Número do diário
    cds.Estado              -- Estado do documento
FROM 
    PRI98482ABCDE.dbo.CabecDoc cd -- Tabela de cabeçalhos de documentos ALTERAR CODIGO CONFORME EMPRESA PRI98482(codigo da empresa)
JOIN 
    PRI98482ABCDE.dbo.CabecDocStatus cds -- Tabela de status dos cabeçalhos de documentos ALTERAR CODIGO CONFORME EMPRESA PRI98482(codigo da empresa)
    ON cd.ID = cds.IdCabecDoc 
WHERE 
    cd.EspacoFiscal = '2'  -- Filtra por espaço fiscal
    AND YEAR(Data) = '2024' -- Filtra por ano ALTERAR CONFORME ANO
    AND MONTH(cd.Data) BETWEEN 4 AND 6  -- Filtra o periodo entre meses ALTERAR CONFORME PERIODO
    AND TipoDoc <> 'GT'     -- Ignora documentos do tipo 'GT'
    AND cds.Estado = 'P';   -- Inclui apenas documentos com estado 'P'



-- Seção 2: Automação para execução em múltiplos bancos de dados

    -- Variáveis para a automação

DECLARE @DatabaseName NVARCHAR(255); -- Cria Nome do banco de dados atual
DECLARE @SQLQuery NVARCHAR(MAX);     -- Cria Consulta SQL dinâmica
DECLARE @Counter INT;                -- Cria Contador para iterar pelos bancos de dados
SET @Counter = 1;                    -- Atribui valor ao contador
DECLARE @DatabaseCount INT;          -- Cria Contador de bancos de dados

    -- Cria uma tabela temporária para armazenar os resultados

CREATE TABLE #TempResult (
    COMPANY NVARCHAR(255),         -- Nome da empresa/banco de dados
    TipoDoc NVARCHAR(50),          -- Tipo de documento
    EspacoFiscal INT,              -- Espaço fiscal
    Data VARCHAR(10),              -- Data do documento
    Nome NVARCHAR(255),            -- Nome do cliente
    NumContribuinte NVARCHAR(50),  -- Número do contribuinte
    Documento NVARCHAR(50),        -- Número do documento
    TotalMerc DECIMAL(18, 2),      -- Valor total das mercadorias
    TotalDocumento DECIMAL(18, 2), -- Valor total do documento
    Diario NVARCHAR(50),           -- Diário
    Observacoes NVARCHAR(255),     -- Observações
    Estado NVARCHAR(1),            -- Estado do documento
    NumDiario NVARCHAR(50)         -- Número do diário
);

    -- Contar o número de bancos de dados que correspondem ao padrão e configurar parametros de laço de repetição da consulta

SELECT @DatabaseCount = COUNT(name)
FROM sys.databases
WHERE name LIKE 'PRI98482%' AND state_desc = 'ONLINE'; -- Considera apenas bancos de dados online
WHILE @Counter <= @DatabaseCount -- Loop para percorrer todos os bancos de dados correspondentes
BEGIN

-- Selecionar o nome do banco de dados atual
    SELECT @DatabaseName = name
    FROM (
        SELECT ROW_NUMBER() OVER(ORDER BY name) AS RowNum, name
        FROM sys.databases
        WHERE name LIKE 'PRI98482%' AND state_desc = 'ONLINE' -- Considera apenas bancos de dados online
    ) AS DatabaseList
    WHERE RowNum = @Counter;

    BEGIN TRY
        -- Construir a consulta SQL dinamicamente
        SET @SQLQuery = '
            INSERT INTO #TempResult
            SELECT ''' + @DatabaseName + ''' AS COMPANY,
                   cd.TipoDoc,
                   cd.EspacoFiscal,
                   CONVERT (VARCHAR, cd.Data, 103) AS Data,
                   cd.Nome,
                   cd.NumContribuinte,
                   cd.Documento,
                   cd.TotalMerc,
                   cd.TotalDocumento,
                   cd.Diario,
                   cd.Observacoes,
                   cds.Estado,
                   cd.NumDiario
            FROM ' + @DatabaseName + '.dbo.CabecDoc cd
            JOIN ' + @DatabaseName + '.dbo.CabecDocStatus cds
            ON cd.ID = cds.IdCabecDoc
            WHERE cd.EspacoFiscal = ''2''
                AND YEAR(cd.Data) = 2024
                AND MONTH(cd.Data) BETWEEN 4 AND 6
                AND cd.TipoDoc <> ''GT''
                AND cds.Estado = ''P'';';
        -- Executar a consulta SQL
        EXEC sp_executesql @SQLQuery;
    END TRY
    BEGIN CATCH
        -- Capturar e imprimir erros
        PRINT 'Erro ao executar consulta no banco de dados ' + @DatabaseName;
    END CATCH;
    -- Incrementar o contador
    SET @Counter = @Counter + 1;
END;
-- Selecionar os resultados finais da tabela temporária
SELECT * FROM #TempResult;
-- Deletar a tabela temporária
DROP TABLE #TempResult;