SELECT 
    ac.Conta,
    ac.Mes13CR as Crédito,
    ac.Mes13DB as Débito
FROM 
    PRI98482PURPL.dbo.AcumuladosContas ac
WHERE 
    (ac.Conta = '272212' OR ac.Conta = '2431')
    AND ac.Ano = '2023'

-- Seção 2 query completa   
   
DECLARE @DatabaseName NVARCHAR(255);
DECLARE @SQLQuery NVARCHAR(MAX);
DECLARE @Counter INT;
DECLARE @DatabaseCount INT;
SET @Counter = 1;
CREATE TABLE #TempResult (
    COMPANY NVARCHAR(50),
    CONTA NVARCHAR(50),
    CREDITO DECIMAL(18,2),
    DEBITO DECIMAL(18,2)
);
SELECT @DatabaseCount = COUNT(name)
FROM sys.databases
WHERE name LIKE 'PRI98482%' AND state_desc = 'ONLINE';
WHILE @Counter <= @DatabaseCount
BEGIN
    SELECT @DatabaseName = name
    FROM (
        SELECT ROW_NUMBER() OVER (ORDER BY name) AS RowNum, name
        FROM sys.databases
        WHERE name LIKE 'PRI98482%' AND state_desc = 'ONLINE'
    ) AS DatabaseList
    WHERE RowNum = @Counter;
    BEGIN TRY
        SET @SQLQuery = '
            INSERT INTO #TempResult (COMPANY, CONTA, CREDITO, DEBITO)
            SELECT ' + QUOTENAME(@DatabaseName, '''') + ' AS COMPANY,
				ac.Conta as Conta,
				ac.Mes13CR as CREDITO,
				ac.Mes13DB as DEBITO
            FROM ' + QUOTENAME(@DatabaseName) + '.dbo.AcumuladosContas ac
            WHERE (ac.Conta = ''2431'' OR ac.Conta = ''24112'')
              AND ac.Ano = ''2023'';';
        EXEC sp_executesql @SQLQuery;
    END TRY
    BEGIN CATCH
        PRINT 'Erro ao executar consulta no banco de dados ' + @DatabaseName;
    END CATCH;
    SET @Counter = @Counter + 1;
END;
SELECT COMPANY, CONTA, CREDITO, DEBITO
FROM #TempResult
DROP TABLE #TempResult;