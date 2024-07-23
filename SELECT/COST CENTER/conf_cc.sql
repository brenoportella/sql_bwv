SELECT *
FROM (
    SELECT m.Conta, pc.descricao, m.diario, m.numdiario, SUM (
            CASE
                WHEN m.Natureza = 'D' THEN m.Valor
                WHEN m.Natureza = 'C' THEN m.Valor * -1
                ELSE 0 
            END
    ) as Valor
    FROM PRI98482ETERN.dbo.Movimentos m
    JOIN PRI98482ETERN.dbo.PlanoContas pc ON m.conta = pc.conta
    WHERE (m.Conta LIKE '6%' OR m.Conta LIKE '7%')
    	AND (m.Diario NOT LIKE '72')
        AND (m.Conta NOT LIKE '60%' AND m.Conta NOT LIKE '70%')
        AND m.Ano = '2024'
       	AND m.Mes >= '1'
        AND m.Mes <= '7'
    GROUP BY m.Conta, pc.descricao, m.diario, m.numdiario
) AS ContasContabeis
FULL OUTER JOIN (
    SELECT m.ContaOrigem, pc2.Descricao, SUM (
            CASE
                WHEN m.Natureza = 'D' THEN m.Valor
                WHEN m.Natureza = 'C' THEN m.Valor * -1
                ELSE 0 
            END
    ) as Valor
    FROM PRI98482ETERN.dbo.PlanoCentros pc
    JOIN PRI98482ETERN.dbo.Movimentos m ON pc.Centro = m.Conta 
    JOIN PRI98482ETERN.dbo.PlanoContas pc2 ON m.ContaOrigem = pc2.Conta 
    WHERE pc.TipoConta = 'M'
        AND pc.Ano = '2024'
        AND m.Ano = '2024'
        AND m.Mes >= '1'
        AND m.Mes <= '7'
        AND pc2.Ano = '2024'
    GROUP BY m.ContaOrigem, pc2.Descricao
) AS ContasCentroCustos ON ContasContabeis.Conta = ContasCentroCustos.ContaOrigem
WHERE ContasContabeis.Valor IS NULL OR ContasCentroCustos.Valor IS NULL;