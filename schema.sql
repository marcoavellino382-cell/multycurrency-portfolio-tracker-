-- Disabilita temporaneamente i vincoli per ripulire senza errori
PRAGMA foreign_keys = OFF;

DROP TABLE IF EXISTS transactions;
DROP TABLE IF EXISTS historical_prices;
DROP TABLE IF EXISTS exchange_rates;
DROP TABLE IF EXISTS assets;
DROP TABLE IF EXISTS users;

-- Riabilita i vincoli
PRAGMA foreign_keys = ON;

-- 1. TABELLA UTENTI
CREATE TABLE users (
    user_id INTEGER PRIMARY KEY AUTOINCREMENT,
    username TEXT NOT NULL,
    base_currency TEXT NOT NULL DEFAULT 'EUR',
    created_at DATETIME DEFAULT (CURRENT_TIMESTAMP)
);

-- 2. TABELLA ASSET / TITOLI
CREATE TABLE assets (
    asset_id INTEGER PRIMARY KEY AUTOINCREMENT,
    ticker TEXT NOT NULL UNIQUE,
    name TEXT NOT NULL,
    asset_class TEXT NOT NULL,
    currency TEXT NOT NULL
);

-- 3. TABELLA TRANSAZIONI
CREATE TABLE transactions (
    transaction_id INTEGER PRIMARY KEY AUTOINCREMENT,
    user_id INTEGER NOT NULL,
    asset_id INTEGER NOT NULL,
    transaction_type TEXT NOT NULL,
    quantity REAL NOT NULL,
    price_per_share REAL NOT NULL,
    fees REAL DEFAULT 0.0,
    transaction_date DATETIME NOT NULL,
    FOREIGN KEY (user_id) REFERENCES users(user_id) ON DELETE CASCADE,
    FOREIGN KEY (asset_id) REFERENCES assets(asset_id) ON DELETE RESTRICT,
    CHECK (transaction_type IN ('BUY', 'SELL', 'DIVIDEND')),
    CHECK (quantity > 0),
    CHECK (price_per_share >= 0)
);

-- 4. TABELLA PREZZI STORICI
CREATE TABLE historical_prices (
    asset_id INTEGER NOT NULL,
    price_date DATE NOT NULL,
    close_price REAL NOT NULL,
    PRIMARY KEY (asset_id, price_date),
    FOREIGN KEY (asset_id) REFERENCES assets(asset_id) ON DELETE CASCADE,
    CHECK (close_price >= 0)
);

-- 5. TABELLA TASSI DI CAMBIO
CREATE TABLE exchange_rates (
    from_currency TEXT NOT NULL,
    to_currency TEXT NOT NULL,
    rate_date DATE NOT NULL,
    rate REAL NOT NULL,
    PRIMARY KEY (from_currency, to_currency, rate_date)
);

-- Elimina la vista se esisteva già una versione precedente
DROP VIEW IF EXISTS view_portfolio_summary;

-- Crea la nuova Vista
CREATE VIEW view_portfolio_summary AS
WITH current_portfolio AS (
    SELECT 
        user_id,
        asset_id,
        SUM(CASE WHEN transaction_type = 'BUY' THEN quantity 
                 WHEN transaction_type = 'SELL' THEN -quantity 
                 ELSE 0 END) AS totale_quote,
        SUM(CASE WHEN transaction_type = 'BUY' THEN (quantity * price_per_share) + fees 
                 WHEN transaction_type = 'SELL' THEN -((quantity * price_per_share) - fees) 
                 ELSE 0 END) AS totale_capitale_investito
    FROM transactions
    GROUP BY user_id, asset_id
)
SELECT 
    u.username AS Utente,
    a.ticker AS Titolo,
    a.name AS Nome_Asset,
    cp.totale_quote AS Quote_Possedute,
    a.currency AS Valuta_Originale,
    hp.close_price AS Ultimo_Prezzo,
    
    ROUND(CASE 
        WHEN a.currency = 'EUR' THEN (cp.totale_quote * hp.close_price)
        ELSE (cp.totale_quote * hp.close_price) * er.rate 
    END, 2) AS Valore_Attuale_EUR,
    
    ROUND(CASE 
        WHEN a.currency = 'EUR' THEN (cp.totale_quote * hp.close_price) - cp.totale_capitale_investito
        ELSE ((cp.totale_quote * hp.close_price) * er.rate) - (cp.totale_capitale_investito * er.rate)
    END, 2) AS Profit_Loss_EUR

FROM current_portfolio cp
JOIN users u ON cp.user_id = u.user_id
JOIN assets a ON cp.asset_id = a.asset_id
JOIN historical_prices hp ON a.asset_id = hp.asset_id AND hp.price_date = '2026-03-01'
LEFT JOIN exchange_rates er ON er.from_currency = a.currency AND er.to_currency = 'EUR' AND er.rate_date = '2026-03-01'
WHERE cp.totale_quote > 0;