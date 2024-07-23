# BWV Queries
Queries SQL of BWV Primavera to help office.

## List of queries

### IVA Recapitulativo Intracomunitário Trimestral

**Documentation**

path
```bash
/SQL_BWV/SELECT/DOC_iva_recap_intcom_tri.sql
```

**SQL Query**

path
``` bash
 /SQL_BWV/SELECT/iva_recap_intcom_tri.sql
 ```

**Result**

The created table should be like this:

| COMPANY       | TipoDoc | EspacoFiscal | Data       | Nome                          | NumContribuinte  | Documento     | TotalMerc | TotalDocumento | Diario | Observacoes                                                                 | Estado | NumDiario |
|---------------|---------|--------------|------------|-------------------------------|------------------|---------------|-----------|----------------|--------|----------------------------------------------------------------------------|--------|-----------|
| PRI98482ABCDE | FA      | 2            | 26/04/2024 | Company NAME | BP987654321 | FT FA.2024/5  | 6000.00  | 6000.00      |        | "Motivo: C02 - Alteração do diário/documento Utilizador: admin99"          | P      | 0         |
| PRI98482ABCDE | FA      | 2            | 25/06/2024 | Company NAME | BP987654321 | FT FA.2024/7  | 7000.00   | 7000.00       |        | "Motivo: C02 - Alteração do diário/documento Utilizador: admin99"          | P      | 0         |
| PRI98482ABCDE | FA      | 2            | 24/05/2024 | Company NAME | BP987654321 | FT FA.2024/6  | 5000.00   | 5000.00       |        | "Motivo: C02 - Alteração do diário/documento Utilizador: admin99"          | P      | 0         |


 ### Conferência Centro de Custos
 
 **Documentation**

path
```bash
/SQL_BWV/SELECT/DOC_conf_cc.sql
```

**SQL Query**

path
``` bash
 /SQL_BWV/SELECT/conf_cc.sql
 ```

**Result**

If the table created is blank, then there is no value to correct. Otherwise, the chart, journal, journal number and value will be displayed in the table.

| Conta  | Descrição                        | Diário | NumDiário | Valor    | ContaOrigem | Descricao | Valor |
|--------|----------------------------------|--------|-----------|----------|-------------|-----------|-------|
| 624231 | Gás - aceite pela totalidade     | 41     | 50001     | 12.1200  | null        | null      | null  |
| 6981   | Relativas a financiamentos obtidos| 41     | 50018     | 484.8600 | null       | null      | null  |
