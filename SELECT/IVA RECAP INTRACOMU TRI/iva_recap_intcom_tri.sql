-- ============================================
-- Script: iva_recapitulativo_intracomunitario_trimestral.sql
-- Descrição: Este script gera um relatório trimestral de IVA recapitulado para operações intracomunitárias.
-- Autor: Breno Portella
-- Data: 23/07/2024
-- ============================================


-- QUERY 1 - Uma empresa
SELECT 
    TipoDoc,
    EspacoFiscal,
    CONVERT(varchar, Data, 103) as Data,
    Nome,
    NumContribuinte,
    Documento,
    TotalMerc,
    TotalDocumento,
    Diario,
    NumDiario,
    cds.Estado
FROM 
    PRI98482ABCDE.dbo.CabecDoc cd
JOIN 
    PRI98482ABCDE.dbo.CabecDocStatus cds
    ON cd.ID = cds.IdCabecDoc
WHERE
    cd.EspacoFiscal = '2'
    AND YEAR(Data) = '2024'
    AND MONTH(Data) >= '4'
    AND MONTH(Data) <= '6'
    AND TipoDoc <> 'GT'
    AND cds.Estado = 'P';

-- =======================================================================

-- QUERY 2 - Todas empresas ativas
DECLARE @DatabaseName NVARCHAR(255)
DECLARE @SQLQuery NVARCHAR(MAX)
DECLARE @Counter INT
SET @Counter = 1
DECLARE @DatabaseCount INT
CREATE TABLE #TempResult (
    COMPANY NVARCHAR(255),
    TipoDoc NVARCHAR(50),
    EspacoFiscal INT,
    Data VARCHAR(10),
    Nome NVARCHAR(255),
    NumContribuinte NVARCHAR(50),
    Documento NVARCHAR(50),
    TotalMerc DECIMAL(18, 2),
    TotalDocumento DECIMAL(18, 2),
    Diario NVARCHAR(50),
    Observacoes NVARCHAR(255),
    Estado NVARCHAR(1),
    NumDiario NVARCHAR(50)
)
SELECT @DatabaseCount = COUNT(name)
FROM sys.databases
WHERE name LIKE 'PRI98482%' AND state_desc = 'ONLINE'
WHILE @Counter <= @DatabaseCount
BEGIN
    SELECT @DatabaseName = name
    FROM (
        SELECT ROW_NUMBER() OVER(ORDER BY name) AS RowNum, name
        FROM sys.databases
        WHERE name LIKE 'PRI98482%' AND state_desc = 'ONLINE'
    ) AS DatabaseList
    WHERE RowNum = @Counter
    BEGIN TRY
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
                AND cds.Estado = ''P'';'      
        EXEC sp_executesql @SQLQuery
    END TRY
    BEGIN CATCH
        PRINT 'Erro ao executar consulta no banco de dados ' + @DatabaseName
    END CATCH 
    SET @Counter = @Counter + 1
END
SELECT * FROM #TempResult
DROP TABLE #TempResult