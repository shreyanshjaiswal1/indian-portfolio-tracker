-- Indian Stock Market Portfolio Tracker Database Schema
-- This schema supports Indian stock market portfolio management

-- Users table with Indian customer information
CREATE TABLE users (
    user_id INT PRIMARY KEY AUTO_INCREMENT,
    username VARCHAR(50) UNIQUE NOT NULL,
    email VARCHAR(100) UNIQUE NOT NULL,
    first_name VARCHAR(50) NOT NULL,
    last_name VARCHAR(50) NOT NULL,
    pan_number VARCHAR(10) UNIQUE, -- Indian PAN number
    phone_number VARCHAR(15),
    city VARCHAR(50),
    state VARCHAR(50) DEFAULT 'India',
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP
);

-- Indian stocks table with NSE/BSE listings
CREATE TABLE stocks (
    stock_id INT PRIMARY KEY AUTO_INCREMENT,
    symbol VARCHAR(20) UNIQUE NOT NULL, -- NSE/BSE symbol
    company_name VARCHAR(150) NOT NULL,
    sector VARCHAR(100),
    industry VARCHAR(100),
    exchange ENUM('NSE', 'BSE') NOT NULL,
    market_cap_category ENUM('Large Cap', 'Mid Cap', 'Small Cap'),
    isin_code VARCHAR(12), -- International Securities Identification Number
    currency VARCHAR(3) DEFAULT 'INR',
    listing_date DATE,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP
);

-- Stock prices table for Indian market data (in INR)
CREATE TABLE stock_prices (
    price_id INT PRIMARY KEY AUTO_INCREMENT,
    stock_id INT NOT NULL,
    price_date DATE NOT NULL,
    open_price DECIMAL(12, 2), -- Higher precision for Indian stocks
    high_price DECIMAL(12, 2),
    low_price DECIMAL(12, 2),
    close_price DECIMAL(12, 2) NOT NULL,
    volume BIGINT,
    adjusted_close DECIMAL(12, 2),
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (stock_id) REFERENCES stocks(stock_id),
    UNIQUE KEY unique_stock_date (stock_id, price_date),
    INDEX idx_stock_date (stock_id, price_date),
    INDEX idx_price_date (price_date)
);

-- Portfolios table for Indian investors
CREATE TABLE portfolios (
    portfolio_id INT PRIMARY KEY AUTO_INCREMENT,
    user_id INT NOT NULL,
    portfolio_name VARCHAR(100) NOT NULL,
    description TEXT,
    portfolio_type ENUM('Equity', 'Mutual Fund', 'Mixed', 'SIP') DEFAULT 'Equity',
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    FOREIGN KEY (user_id) REFERENCES users(user_id),
    UNIQUE KEY unique_user_portfolio (user_id, portfolio_name)
);

-- Transactions table with Indian market specifics
CREATE TABLE transactions (
    transaction_id INT PRIMARY KEY AUTO_INCREMENT,
    portfolio_id INT NOT NULL,
    stock_id INT NOT NULL,
    transaction_type ENUM('BUY', 'SELL') NOT NULL,
    quantity INT NOT NULL,
    price_per_share DECIMAL(12, 2) NOT NULL,
    total_amount DECIMAL(15, 2) NOT NULL,
    brokerage DECIMAL(10, 2) DEFAULT 0.00, -- Brokerage charges
    stt DECIMAL(10, 2) DEFAULT 0.00, -- Securities Transaction Tax
    stamp_duty DECIMAL(8, 2) DEFAULT 0.00,
    gst DECIMAL(10, 2) DEFAULT 0.00, -- GST on brokerage
    other_charges DECIMAL(10, 2) DEFAULT 0.00,
    net_amount DECIMAL(15, 2) NOT NULL, -- Amount after all charges
    transaction_date DATE NOT NULL,
    settlement_date DATE,
    order_id VARCHAR(50),
    notes TEXT,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (portfolio_id) REFERENCES portfolios(portfolio_id),
    FOREIGN KEY (stock_id) REFERENCES stocks(stock_id),
    INDEX idx_portfolio_date (portfolio_id, transaction_date),
    INDEX idx_stock_date (stock_id, transaction_date),
    INDEX idx_order_id (order_id)
);

-- Indian market indices for benchmarking
CREATE TABLE market_indices (
    index_id INT PRIMARY KEY AUTO_INCREMENT,
    index_name VARCHAR(50) NOT NULL, -- NIFTY 50, SENSEX, etc.
    index_date DATE NOT NULL,
    open_value DECIMAL(10, 2),
    high_value DECIMAL(10, 2),
    low_value DECIMAL(10, 2),
    close_value DECIMAL(10, 2) NOT NULL,
    change_points DECIMAL(10, 2),
    change_percent DECIMAL(8, 4),
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    UNIQUE KEY unique_index_date (index_name, index_date),
    INDEX idx_index_date (index_name, index_date)
);

-- Portfolio holdings view for Indian stocks
CREATE VIEW portfolio_holdings AS
SELECT 
    p.portfolio_id,
    p.portfolio_name,
    p.portfolio_type,
    u.username,
    u.first_name,
    u.last_name,
    s.symbol,
    s.company_name,
    s.sector,
    s.exchange,
    s.market_cap_category,
    SUM(CASE 
        WHEN t.transaction_type = 'BUY' THEN t.quantity 
        ELSE -t.quantity 
    END) as current_shares,
    ROUND(
        SUM(CASE WHEN t.transaction_type = 'BUY' THEN t.net_amount ELSE 0 END) / 
        NULLIF(SUM(CASE WHEN t.transaction_type = 'BUY' THEN t.quantity ELSE 0 END), 0), 
        2
    ) as avg_purchase_price,
    SUM(CASE 
        WHEN t.transaction_type = 'BUY' THEN t.net_amount
        ELSE -t.net_amount
    END) as total_invested
FROM portfolios p
JOIN users u ON p.user_id = u.user_id
JOIN transactions t ON p.portfolio_id = t.portfolio_id
JOIN stocks s ON t.stock_id = s.stock_id
GROUP BY p.portfolio_id, s.stock_id
HAVING current_shares > 0;

-- Create indexes for performance optimization
CREATE INDEX idx_users_pan ON users(pan_number);
CREATE INDEX idx_stocks_symbol ON stocks(symbol);
CREATE INDEX idx_stocks_exchange ON stocks(exchange);
CREATE INDEX idx_stocks_sector ON stocks(sector);
CREATE INDEX idx_transactions_date ON transactions(transaction_date);
CREATE INDEX idx_stock_prices_date ON stock_prices(price_date);

-- Comments explaining Indian market specifics
/*
Indian Stock Market Schema Notes:
1. Users table includes PAN number (mandatory for Indian trading)
2. Stocks table supports NSE/BSE exchanges with ISIN codes
3. Market cap categories: Large Cap, Mid Cap, Small Cap (Indian classification)
4. Transactions include Indian-specific charges: STT, stamp duty, GST
5. Currency is INR (Indian Rupees)
6. Market indices table for NIFTY 50, SENSEX benchmarking
7. Portfolio types include SIP (Systematic Investment Plan)
8. Higher decimal precision for Indian stock prices
*/
