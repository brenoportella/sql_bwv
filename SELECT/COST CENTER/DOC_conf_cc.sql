-- ============================================
-- Script: conf_cc.sql
-- Descrição: Este script compara valores entre contas contábeis e centros de custos para o período especificado.
-- Autor: Breno Portella
-- Data: 23/07/2024
-- ============================================

-- Consulta principal para comparar valores contábeis

-- Seleciona todos os resultados da junção total entre contas contábeis e centros de custos
SELECT *
FROM (
    -- Subconsulta 1: Calcula os valores contábeis para contas contábeis
    SELECT 
        m.Conta,                  -- Conta contábil
        pc.descricao,             -- Descrição da conta contábil
        m.diario,                 -- Diário contábil
        m.numdiario,              -- Número do diário
        SUM (
            CASE
                WHEN m.Natureza = 'D' THEN m.Valor  -- Se natureza for 'D' (débito), valor positivo
                WHEN m.Natureza = 'C' THEN m.Valor * -1  -- Se natureza for 'C' (crédito), valor negativo
                ELSE 0  -- Caso contrário, valor zero
            END
        ) as Valor  -- Soma dos valores ajustados por natureza
    FROM PRI98482ABCDE.dbo.Movimentos m  -- Tabela de movimentos contábeis
    JOIN PRI98482ABCDE.dbo.PlanoContas pc ON m.conta = pc.conta  -- Junta com tabela de plano de contas para obter descrições
    WHERE (m.Conta LIKE '6%' OR m.Conta LIKE '7%')  -- Filtra contas que começam com '6' ou '7'
        AND (m.Diario NOT LIKE '72')  -- Exclui diários que começam com '72'
        AND (m.Conta NOT LIKE '60%' AND m.Conta NOT LIKE '70%')  -- Exclui contas que começam com '60' ou '70'
        AND m.Ano = '2024'  -- Filtra o ano
        AND m.Mes >= '1'  -- Filtra meses a partir do MÊS
        AND m.Mes <= '7'  -- Filtra até o MÊS
    GROUP BY m.Conta, pc.descricao, m.diario, m.numdiario  -- Agrupa pelos campos relevantes
) AS ContasContabeis  -- Subconsulta 1 nomeada como ContasContabeis
FULL OUTER JOIN (
    -- Subconsulta 2: Calcula os valores contábeis para centros de custos
    SELECT 
        m.ContaOrigem,            -- Conta de origem
        pc2.Descricao,            -- Descrição da conta de origem
        SUM (
            CASE
                WHEN m.Natureza = 'D' THEN m.Valor  -- Se natureza for 'D' (débito), valor positivo
                WHEN m.Natureza = 'C' THEN m.Valor * -1  -- Se natureza for 'C' (crédito), valor negativo
                ELSE 0  -- Caso contrário, valor zero
            END
        ) as Valor  -- Soma dos valores ajustados por natureza
    FROM PRI98482ABCDE.dbo.PlanoCentros pc  -- Tabela de plano de centros de custo
    JOIN PRI98482ABCDE.dbo.Movimentos m ON pc.Centro = m.Conta  -- Junta com tabela de movimentos para obter contas
    JOIN PRI98482ABCDE.dbo.PlanoContas pc2 ON m.ContaOrigem = pc2.Conta  -- Junta com tabela de plano de contas para obter descrições
    WHERE pc.TipoConta = 'M'  -- Filtra centros de custo do tipo 'M'
        AND pc.Ano = '2024'  -- Filtra o ano nos centros de custo
        AND m.Ano = '2024'  -- Filtra o ano nos movimentos
        AND m.Mes >= '1'  -- Filtra meses a partir de MÊS
        AND m.Mes <= '7'  -- Filtra até o MÊS
        AND pc2.Ano = '2024'  -- Filtra o ano no plano de contas
    GROUP BY m.ContaOrigem, pc2.Descricao  -- Agrupa pelos campos relevantes
) AS ContasCentroCustos  -- Subconsulta 2 nomeada como ContasCentroCustos

ON ContasContabeis.Conta = ContasCentroCustos.ContaOrigem  -- Junta as duas subconsultas pelas contas correspondentes

-- Filtra para mostrar apenas registros onde os valores são nulos em uma das subconsultas
WHERE ContasContabeis.Valor IS NULL OR ContasCentroCustos.Valor IS NULL;
