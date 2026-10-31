# Multi-Currency Portfolio Tracker Database

Questo progetto presenta il design e l'implementazione di un database relazionale sviluppato in **SQLite** tramite **DBeaver**, ottimizzato per la gestione e l'analisi quantitativa di un portafoglio finanziario multi-asset e multi-valuta.

## 🎯 Obiettivi del Progetto
*   **Gestione Multi-Currency:** Conversione dinamica in tempo reale degli asset quotati in valute estere (USD) nella valuta base dell'utente (EUR) tramite tabelle di tassi di cambio storici.
*   **Flessibilità di Asset Class:** Supporto a decimali ad alta precisione per includere sia mercati tradizionali (Azioni, ETF) sia mercati digitali (Frazioni di Cryptocurrency).
*   **Integrità dei Dati:** Applicazione di vincoli relazionali (`FOREIGN KEY`, `CHECK constraints`) per garantire la consistenza contabile delle transazioni.

## 📐 Data Modeling (Architettura delle Tabelle)
Il database è composto da 5 tabelle principali:
1.  `users`: Anagrafica dell'utente e valuta base del portafoglio.
2.  `assets`: Censimento degli strumenti finanziari (Ticker, Name, Asset Class, Currency).
3.  `transactions`: Registro cronologico delle operazioni (`BUY`, `SELL`, `DIVIDEND`) con calcolo di quantità, prezzi e commissioni (`fees`).
4.  `historical_prices`: Serie storiche dei prezzi di chiusura dei titoli.
5.  `exchange_rates`: Matrice storica dei tassi di cambio valutari.

## 🚀 Highlights Tecnici & Query Avanzate

### 1. SQL Views per il Calcolo del Profit & Loss (P&L)
È stata creata una Vista modulare (`view_portfolio_summary`) che automatizza il calcolo della posizione netta e valorizza il portafoglio corrente convertendo i prezzi storici in Euro:
```sql
SELECT * FROM view_portfolio_summary;
```

### 2. Asset Allocation con CTE e Cross Join
Per determinare l'esposizione percentuale del portafoglio sui singoli titoli rispetto al patrimonio complessivo, è stata implementata una query analitica basata su Common Table Expressions (CTE):
*   Utilizzo di **CTE** per isolare i valori corrents aggregati.
*   Uso di un **CROSS JOIN** per rapportare il valore del singolo asset al totale di portafoglio in un'unica scansione.

## 🛠️ Tech Stack
*   **Database Engine:** SQLite 3
*   **Database Client:** DBeaver Universal Database Tool
*   **Operating System:** macOS (Apple Silicon Architecture)

## 📂 Contenuto del Repository
*   `portfolio_tracker.db`: Il file del database pronto all'uso con Mock Data precaricati.
*   `schema.sql`: Script DDL per la generazione delle tabelle e delle viste.
*   `queries_analisi.sql`: Script contenente le metriche finanziarie e di allocazione.
