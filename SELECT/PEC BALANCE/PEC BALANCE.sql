DECLARE @DatabaseName NVARCHAR(255);
DECLARE @SQLQuery NVARCHAR(MAX);
DECLARE @Counter INT;
DECLARE @DatabaseCount INT;
SET @Counter = 1;

-- Criar uma tabela temporária para armazenar os resultados
CREATE TABLE #TempResult (
    COMPANY NVARCHAR(50),
    SALDO_2023 DECIMAL(18,2),
    SALDO_2024 DECIMAL(18,2)
);

-- Contar bases de dados relevantes
SELECT @DatabaseCount = COUNT(name)
FROM sys.databases
WHERE name LIKE 'PRI98482%' AND state_desc = 'ONLINE';

WHILE @Counter <= @DatabaseCount
BEGIN
    -- Obter o nome da base de dados atual
    SELECT @DatabaseName = name
    FROM (
        SELECT ROW_NUMBER() OVER (ORDER BY name) AS RowNum, name
        FROM sys.databases
        WHERE name LIKE 'PRI98482%' AND state_desc = 'ONLINE'
    ) AS DatabaseList
    WHERE RowNum = @Counter;

    BEGIN TRY
        -- Construir e executar a consulta dinâmica para capturar os saldos
        SET @SQLQuery = '
            INSERT INTO #TempResult (COMPANY, SALDO_2023, SALDO_2024)
            SELECT 
                ' + QUOTENAME(@DatabaseName, '''') + ' AS COMPANY,
                SUM(CASE WHEN m.Ano = ''2023'' THEN m.Valor * (CASE WHEN m.Natureza = ''d'' THEN 1 ELSE -1 END) ELSE 0 END) AS SALDO_2023,
                SUM(CASE WHEN m.Ano = ''2024'' THEN m.Valor * (CASE WHEN m.Natureza = ''d'' THEN 1 ELSE -1 END) ELSE 0 END) AS SALDO_2024
            FROM ' + QUOTENAME(@DatabaseName) + '.dbo.Movimentos m
            WHERE m.Conta = ''24112''
            GROUP BY m.Conta;';
        
        EXEC sp_executesql @SQLQuery;
    END TRY
    BEGIN CATCH
        PRINT 'Erro ao executar consulta no banco de dados ' + @DatabaseName;
    END CATCH;

    SET @Counter = @Counter + 1;
END;

-- Selecionar os resultados apenas para empresas com saldo devedor > 0 em 2023 ou 2024
SELECT COMPANY, SALDO_2023, SALDO_2024
FROM #TempResult
WHERE SALDO_2023 > 0 OR SALDO_2024 > 0;

-- Limpar a tabela temporária
DROP TABLE #TempResult;
