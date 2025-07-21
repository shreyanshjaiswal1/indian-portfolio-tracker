-- Portfolio Performance Analysis Queries
-- This file contains comprehensive SQL queries for analyzing portfolio performance

-- 1. Current Portfolio Holdings Summary
-- Shows current positions, market value, and unrealized gains/losses
SELECT 
    ph.portfolio_name,
    ph.username,
    ph.symbol,
    ph.company_name,
    ph.current_shares,
    ph.avg_purchase_price,
    ph.total_invested,
    sp.close_price as current_price,
    (ph.current_shares * sp.close_price) as current_market_value,
    ((ph.current_shares * sp.close_price) - ph.total_invested) as unrealized_gain_loss,
    (((ph.current_shares * sp.close_price) - ph.total_invested) / ph.total_invested * 100) as unrealized_return_pct
FROM portfolio_holdings ph
JOIN stock_prices sp ON ph.symbol = (
    SELECT s.symbol FROM stocks s WHERE s.stock_id = sp.stock_id
)
WHERE sp.price_date = (
    SELECT MAX(price_date) 
    FROM stock_prices sp2 
    WHERE sp2.stock_id = sp.stock_id
)
ORDER BY ph.portfolio_name, unrealized_return_pct DESC;

-- 2. Portfolio Summary by User
-- Aggregated portfolio performance metrics per user
WITH portfolio_summary AS (
    SELECT 
        ph.portfolio_id,
        ph.portfolio_name,
        ph.username,
        SUM(ph.total_invested) as total_invested,
        SUM(ph.current_shares * sp.close_price) as current_market_value,
        SUM((ph.current_shares * sp.close_price) - ph.total_invested) as total_unrealized_gain_loss
    FROM portfolio_holdings ph
    JOIN stocks s ON ph.symbol = s.symbol
    JOIN stock_prices sp ON s.stock_id = sp.stock_id
    WHERE sp.price_date = (
        SELECT MAX(price_date) 
        FROM stock_prices sp2 
        WHERE sp2.stock_id = sp.stock_id
    )
    GROUP BY ph.portfolio_id, ph.portfolio_name, ph.username
)
SELECT 
    username,
    portfolio_name,
    total_invested,
    current_market_value,
    total_unrealized_gain_loss,
    (total_unrealized_gain_loss / total_invested * 100) as portfolio_return_pct,
    COUNT(*) OVER (PARTITION BY username) as num_portfolios,
    SUM(current_market_value) OVER (PARTITION BY username) as total_user_portfolio_value
FROM portfolio_summary
ORDER BY username, portfolio_return_pct DESC;

-- 3. Asset Allocation Analysis
-- Shows portfolio diversification across sectors and individual stocks
WITH portfolio_allocation AS (
    SELECT 
        ph.portfolio_id,
        ph.portfolio_name,
        ph.username,
        s.sector,
        ph.symbol,
        ph.company_name,
        (ph.current_shares * sp.close_price) as position_value,
        SUM(ph.current_shares * sp.close_price) OVER (PARTITION BY ph.portfolio_id) as total_portfolio_value
    FROM portfolio_holdings ph
    JOIN stocks s ON ph.symbol = s.symbol
    JOIN stock_prices sp ON s.stock_id = sp.stock_id
    WHERE sp.price_date = (
        SELECT MAX(price_date) 
        FROM stock_prices sp2 
        WHERE sp2.stock_id = sp.stock_id
    )
)
SELECT 
    portfolio_name,
    username,
    sector,
    symbol,
    company_name,
    position_value,
    total_portfolio_value,
    (position_value / total_portfolio_value * 100) as position_weight_pct,
    SUM(position_value) OVER (PARTITION BY portfolio_id, sector) / total_portfolio_value * 100 as sector_weight_pct
FROM portfolio_allocation
ORDER BY portfolio_name, position_weight_pct DESC;

-- 4. Transaction History Analysis
-- Detailed transaction history with running totals and average prices
SELECT 
    p.portfolio_name,
    u.username,
    s.symbol,
    s.company_name,
    t.transaction_type,
    t.quantity,
    t.price_per_share,
    t.total_amount,
    t.commission,
    t.transaction_date,
    t.notes,
    SUM(CASE 
        WHEN t2.transaction_type = 'BUY' THEN t2.quantity 
        ELSE -t2.quantity 
    END) as running_shares,
    AVG(CASE 
        WHEN t2.transaction_type = 'BUY' THEN t2.price_per_share 
    END) OVER (
        PARTITION BY t.portfolio_id, t.stock_id 
        ORDER BY t2.transaction_date 
        ROWS UNBOUNDED PRECEDING
    ) as running_avg_cost
FROM transactions t
JOIN portfolios p ON t.portfolio_id = p.portfolio_id
JOIN users u ON p.user_id = u.user_id
JOIN stocks s ON t.stock_id = s.stock_id
JOIN transactions t2 ON t.portfolio_id = t2.portfolio_id 
    AND t.stock_id = t2.stock_id 
    AND t2.transaction_date <= t.transaction_date
GROUP BY t.transaction_id, p.portfolio_name, u.username, s.symbol, s.company_name,
         t.transaction_type, t.quantity, t.price_per_share, t.total_amount, 
         t.commission, t.transaction_date, t.notes, t.portfolio_id, t.stock_id
ORDER BY p.portfolio_name, s.symbol, t.transaction_date;

-- 5. Monthly Portfolio Performance
-- Time-series analysis of portfolio value over time
WITH monthly_portfolio_value AS (
    SELECT 
        p.portfolio_id,
        p.portfolio_name,
        u.username,
        DATE_FORMAT(sp.price_date, '%Y-%m') as month_year,
        sp.price_date,
        SUM(
            CASE 
                WHEN sp.price_date >= t.transaction_date THEN
                    (CASE WHEN t.transaction_type = 'BUY' THEN t.quantity ELSE -t.quantity END) * sp.close_price
                ELSE 0
            END
        ) as portfolio_value
    FROM portfolios p
    JOIN users u ON p.user_id = u.user_id
    JOIN transactions t ON p.portfolio_id = t.portfolio_id
    JOIN stocks s ON t.stock_id = s.stock_id
    JOIN stock_prices sp ON s.stock_id = sp.stock_id
    WHERE sp.price_date >= t.transaction_date
    GROUP BY p.portfolio_id, p.portfolio_name, u.username, sp.price_date
    HAVING portfolio_value > 0
)
SELECT 
    portfolio_name,
    username,
    month_year,
    MAX(portfolio_value) as end_of_month_value,
    LAG(MAX(portfolio_value)) OVER (
        PARTITION BY portfolio_id 
        ORDER BY month_year
    ) as previous_month_value,
    ((MAX(portfolio_value) - LAG(MAX(portfolio_value)) OVER (
        PARTITION BY portfolio_id 
        ORDER BY month_year
    )) / LAG(MAX(portfolio_value)) OVER (
        PARTITION BY portfolio_id 
        ORDER BY month_year
    ) * 100) as monthly_return_pct
FROM monthly_portfolio_value
GROUP BY portfolio_id, portfolio_name, username, month_year
ORDER BY portfolio_name, month_year;

-- 6. Top Performers and Losers
-- Identifies best and worst performing stocks across all portfolios
WITH stock_performance AS (
    SELECT 
        s.symbol,
        s.company_name,
        s.sector,
        COUNT(DISTINCT ph.portfolio_id) as held_by_portfolios,
        AVG(ph.avg_purchase_price) as avg_purchase_price_all_portfolios,
        sp.close_price as current_price,
        ((sp.close_price - AVG(ph.avg_purchase_price)) / AVG(ph.avg_purchase_price) * 100) as avg_return_pct,
        SUM(ph.current_shares * sp.close_price) as total_market_value_all_portfolios
    FROM portfolio_holdings ph
    JOIN stocks s ON ph.symbol = s.symbol
    JOIN stock_prices sp ON s.stock_id = sp.stock_id
    WHERE sp.price_date = (
        SELECT MAX(price_date) 
        FROM stock_prices sp2 
        WHERE sp2.stock_id = sp.stock_id
    )
    GROUP BY s.symbol, s.company_name, s.sector, sp.close_price
)
SELECT 
    'Top Performers' as category,
    symbol,
    company_name,
    sector,
    held_by_portfolios,
    avg_purchase_price_all_portfolios,
    current_price,
    avg_return_pct,
    total_market_value_all_portfolios
FROM stock_performance
WHERE avg_return_pct > 0
ORDER BY avg_return_pct DESC
LIMIT 5

UNION ALL

SELECT 
    'Worst Performers' as category,
    symbol,
    company_name,
    sector,
    held_by_portfolios,
    avg_purchase_price_all_portfolios,
    current_price,
    avg_return_pct,
    total_market_value_all_portfolios
FROM stock_performance
WHERE avg_return_pct <= 0
ORDER BY avg_return_pct ASC
LIMIT 5;

-- 7. Dividend Income Potential (based on typical dividend yields)
-- Estimates dividend income based on historical yields for dividend-paying stocks
WITH dividend_estimates AS (
    SELECT 
        ph.portfolio_name,
        ph.username,
        ph.symbol,
        ph.company_name,
        ph.current_shares,
        sp.close_price as current_price,
        (ph.current_shares * sp.close_price) as position_value,
        CASE 
            WHEN s.sector = 'Financial Services' THEN 0.035  -- 3.5% typical yield
            WHEN s.sector = 'Consumer Staples' THEN 0.025    -- 2.5% typical yield
            WHEN s.sector = 'Healthcare' THEN 0.020          -- 2.0% typical yield
            WHEN s.sector = 'Technology' THEN 0.010          -- 1.0% typical yield
            ELSE 0.015                                       -- 1.5% default
        END as estimated_yield,
        (ph.current_shares * sp.close_price * 
            CASE 
                WHEN s.sector = 'Financial Services' THEN 0.035
                WHEN s.sector = 'Consumer Staples' THEN 0.025
                WHEN s.sector = 'Healthcare' THEN 0.020
                WHEN s.sector = 'Technology' THEN 0.010
                ELSE 0.015
            END
        ) as estimated_annual_dividend
    FROM portfolio_holdings ph
    JOIN stocks s ON ph.symbol = s.symbol
    JOIN stock_prices sp ON s.stock_id = sp.stock_id
    WHERE sp.price_date = (
        SELECT MAX(price_date) 
        FROM stock_prices sp2 
        WHERE sp2.stock_id = sp.stock_id
    )
)
SELECT 
    portfolio_name,
    username,
    SUM(position_value) as total_portfolio_value,
    SUM(estimated_annual_dividend) as estimated_annual_dividend_income,
    (SUM(estimated_annual_dividend) / SUM(position_value) * 100) as portfolio_dividend_yield_pct,
    SUM(estimated_annual_dividend) / 12 as estimated_monthly_dividend_income
FROM dividend_estimates
GROUP BY portfolio_name, username
ORDER BY portfolio_dividend_yield_pct DESC;
