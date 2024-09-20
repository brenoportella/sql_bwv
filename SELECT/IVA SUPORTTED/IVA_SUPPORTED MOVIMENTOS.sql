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
                   m.Conta AS CONTA,
                   SUM(CASE WHEN m.Natureza = ''c'' THEN m.Valor ELSE 0 END) AS CREDITO,
                   SUM(CASE WHEN m.Natureza = ''d'' THEN m.Valor ELSE 0 END) AS DEBITO
            FROM ' + QUOTENAME(@DatabaseName) + '.dbo.Movimentos m
            WHERE m.Ano = ''2023''
              AND (m.Conta LIKE ''2431%'' OR m.Conta = ''24112'')
			  AND m.Mes >= 1
			  AND m.Mes <= 13
            GROUP BY m.Conta;';
        EXEC sp_executesql @SQLQuery;
    END TRY
    BEGIN CATCH
        PRINT 'Erro ao executar consulta no banco de dados ' + @DatabaseName;
    END CATCH;
    SET @Counter = @Counter + 1;
END;
SELECT COMPANY, CONTA, CREDITO, DEBITO
FROM #TempResult;
DROP TABLE #TempResult;