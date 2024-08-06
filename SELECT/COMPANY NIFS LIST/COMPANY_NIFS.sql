DECLARE @DatabaseName NVARCHAR(255);
DECLARE @SQLQuery NVARCHAR(MAX);
DECLARE @Counter INT;
DECLARE @DatabaseCount INT;
SET @Counter = 1;
CREATE TABLE #FinalResult (
    COMPANY NVARCHAR(50),
    UtilizadorTransporte NVARCHAR(255)
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
            INSERT INTO #FinalResult (COMPANY, UtilizadorTransporte)
            SELECT ' + QUOTENAME(@DatabaseName, '''') + ' AS COMPANY,
                pa.UtilizadorTransporte
            FROM ' + QUOTENAME(@DatabaseName) + '.dbo.ParametrosAT pa;';
        EXEC sp_executesql @SQLQuery;
    END TRY
    BEGIN CATCH
        PRINT 'Erro ao executar consulta no banco de dados ' + @DatabaseName;
    END CATCH;
    SET @Counter = @Counter + 1;
END;
SELECT COMPANY, UtilizadorTransporte
FROM #FinalResult;
DROP TABLE #FinalResult;
