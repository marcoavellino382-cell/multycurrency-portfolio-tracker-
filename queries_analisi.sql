WITH portfolio_values AS (
    -- Recupera il valore attuale in Euro di ogni asset direttamente dalla Vista che hai appena creato
    SELECT 
        Titolo,
        Nome_Asset,
        Valore_Attuale_EUR
    FROM view_portfolio_summary
),
total_wallet AS (
    -- Calcola il valore totale complessivo di tutto il portafoglio
    SELECT SUM(Valore_Attuale_EUR) AS valore_totale_portafoglio 
    FROM portfolio_values
)
SELECT 
    pv.Titolo,
    pv.Nome_Asset,
    pv.Valore_Attuale_EUR AS Valore_EUR,
    -- Calcola la percentuale sul totale e la arrotonda a due decimali
    ROUND((pv.Valore_Attuale_EUR / tw.valore_totale_portafoglio) * 100, 2) AS Percentuale_Allocazione
FROM portfolio_values pv
CROSS JOIN total_wallet tw;

SELECT * FROM view_portfolio_summary; 