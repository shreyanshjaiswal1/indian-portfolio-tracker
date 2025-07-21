-- Advanced Financial Analytics Queries
-- Risk analysis, volatility calculations, and advanced performance metrics

-- 1. Portfolio Risk Analysis (Volatility and Beta approximation)
-- Calculates portfolio volatility based on historical price movements
WITH daily_returns AS (
    SELECT 
        s.stock_id,
        s.symbol,
        sp.price_date,
        sp.close_price,
        LAG(sp.close_price) OVER (PARTITION BY s.stock_id ORDER BY sp.price_date) as prev_close,
        ((sp.close_price - LAG(sp.close_price) OVER (PARTITION BY s.stock_id ORDER BY sp.price_date)) 
         / LAG(sp.close_price) OVER (PARTITION BY s.stock_id ORDER BY sp.price_date)) as daily_return
    FROM stocks s
    JOIN stock_prices sp ON s.stock_id = sp.stock_id
),
stock_volatility AS (
    SELECT 
        stock_id,
        symbol,
        COUNT(*) as days_count,
        AVG(daily_return) as avg_daily_return,
        STDDEV(daily_return) as daily_volatility,
        STDDEV(daily_return) * SQRT(252) as annualized_volatility  -- 252 trading days
    FROM daily_returns 
    WHERE daily_return IS NOT NULL
    GROUP BY stock_id, symbol
    HAVING COUNT(*) > 1
),
portfolio_risk AS (
    SELECT 
        ph.portfolio_id,
        ph.portfolio_name,
        ph.username,
        ph.symbol,
        (ph.current_shares * sp.close_price) as position_value,
        SUM(ph.current_shares * sp.close_price) OVER (PARTITION BY ph.portfolio_id) as total_portfolio_value,
        sv.annualized_volatility,
        sv.avg_daily_return * 252 as annualized_return
    FROM portfolio_holdings ph
    JOIN stock_prices sp ON ph.symbol = (SELECT symbol FROM stocks WHERE stock_id = sp.stock_id)
    JOIN stock_volatility sv ON ph.symbol = sv.symbol
    WHERE sp.price_date = (SELECT MAX(price_date) FROM stock_prices sp2 WHERE sp2.stock_id = sp.stock_id)
)
SELECT 
    portfolio_name,
    username,
    total_portfolio_value,
    SUM((position_value / total_portfolio_value) * annualized_volatility) as weighted_portfolio_volatility,
    SUM((position_value / total_portfolio_value) * annualized_return) as weighted_portfolio_return,
    COUNT(*) as number_of_holdings,
    MAX(annualized_volatility) as highest_stock_volatility,
    MIN(annualized_volatility) as lowest_stock_volatility
FROM portfolio_risk
GROUP BY portfolio_id, portfolio_name, username, total_portfolio_value
ORDER BY weighted_portfolio_volatility;

-- 2. Sharpe Ratio Calculation (simplified - assumes 2% risk-free rate)
-- Measures risk-adjusted returns
WITH portfolio_returns AS (
    SELECT 
        ph.portfolio_id,
        ph.portfolio_name,
        ph.username,
        SUM(ph.total_invested) as total_invested,
        SUM(ph.current_shares * sp.close_price) as current_value,
        ((SUM(ph.current_shares * sp.close_price) - SUM(ph.total_invested)) / SUM(ph.total_invested)) as total_return,
        -- Approximate time-weighted return (simplified)
        POWER(
            (SUM(ph.current_shares * sp.close_price) / SUM(ph.total_invested)),
            (365.25 / DATEDIFF(CURDATE(), MIN(t.transaction_date)))
        ) - 1 as annualized_return
    FROM portfolio_holdings ph
    JOIN transactions t ON ph.portfolio_id = t.portfolio_id
    JOIN stock_prices sp ON ph.symbol = (SELECT symbol FROM stocks WHERE stock_id = sp.stock_id)
    WHERE sp.price_date = (SELECT MAX(price_date) FROM stock_prices sp2 WHERE sp2.stock_id = sp.stock_id)
    GROUP BY ph.portfolio_id, ph.portfolio_name, ph.username
),
portfolio_with_volatility AS (
    SELECT 
        pr.*,
        pr2.weighted_portfolio_volatility
    FROM portfolio_returns pr
    JOIN (
        -- Reusing volatility calculation from previous query
        SELECT 
            ph.portfolio_id,
            SUM((position_value / total_portfolio_value) * annualized_volatility) as weighted_portfolio_volatility
        FROM (
            SELECT 
                ph.portfolio_id,
                ph.symbol,
                (ph.current_shares * sp.close_price) as position_value,
                SUM(ph.current_shares * sp.close_price) OVER (PARTITION BY ph.portfolio_id) as total_portfolio_value,
                sv.annualized_volatility
            FROM portfolio_holdings ph
            JOIN stock_prices sp ON ph.symbol = (SELECT symbol FROM stocks WHERE stock_id = sp.stock_id)
            JOIN (
                SELECT 
                    s.symbol,
                    STDDEV(((sp.close_price - LAG(sp.close_price) OVER (PARTITION BY s.stock_id ORDER BY sp.price_date)) 
                             / LAG(sp.close_price) OVER (PARTITION BY s.stock_id ORDER BY sp.price_date))) * SQRT(252) as annualized_volatility
                FROM stocks s
                JOIN stock_prices sp ON s.stock_id = sp.stock_id
                GROUP BY s.symbol
            ) sv ON ph.symbol = sv.symbol
            WHERE sp.price_date = (SELECT MAX(price_date) FROM stock_prices sp2 WHERE sp2.stock_id = sp.stock_id)
        ) ph
        GROUP BY ph.portfolio_id
    ) pr2 ON pr.portfolio_id = pr2.portfolio_id
)
SELECT 
    portfolio_name,
    username,
    total_invested,
    current_value,
    total_return * 100 as total_return_pct,
    annualized_return * 100 as annualized_return_pct,
    weighted_portfolio_volatility * 100 as portfolio_volatility_pct,
    ((annualized_return - 0.02) / weighted_portfolio_volatility) as sharpe_ratio,  -- Assuming 2% risk-free rate
    CASE 
        WHEN ((annualized_return - 0.02) / weighted_portfolio_volatility) > 1.0 THEN 'Excellent'
        WHEN ((annualized_return - 0.02) / weighted_portfolio_volatility) > 0.5 THEN 'Good'
        WHEN ((annualized_return - 0.02) / weighted_portfolio_volatility) > 0 THEN 'Fair'
        ELSE 'Poor'
    END as risk_adjusted_performance
FROM portfolio_with_volatility
ORDER BY sharpe_ratio DESC;

-- 3. Value at Risk (VaR) Estimation
-- Estimates potential portfolio losses at 95% confidence level
WITH portfolio_values AS (
    SELECT 
        ph.portfolio_id,
        ph.portfolio_name,
        ph.username,
        SUM(ph.current_shares * sp.close_price) as current_portfolio_value,
        SUM((ph.current_shares * sp.close_price) * sv.daily_volatility) as portfolio_daily_risk
    FROM portfolio_holdings ph
    JOIN stock_prices sp ON ph.symbol = (SELECT symbol FROM stocks WHERE stock_id = sp.stock_id)
    JOIN (
        SELECT 
            s.symbol,
            STDDEV(((sp.close_price - LAG(sp.close_price) OVER (PARTITION BY s.stock_id ORDER BY sp.price_date)) 
                     / LAG(sp.close_price) OVER (PARTITION BY s.stock_id ORDER BY sp.price_date))) as daily_volatility
        FROM stocks s
        JOIN stock_prices sp ON s.stock_id = sp.stock_id
        GROUP BY s.symbol
    ) sv ON ph.symbol = sv.symbol
    WHERE sp.price_date = (SELECT MAX(price_date) FROM stock_prices sp2 WHERE sp2.stock_id = sp.stock_id)
    GROUP BY ph.portfolio_id, ph.portfolio_name, ph.username
)
SELECT 
    portfolio_name,
    username,
    current_portfolio_value,
    portfolio_daily_risk,
    (portfolio_daily_risk * 1.645) as daily_var_95_pct,  -- 95% confidence level
    (portfolio_daily_risk * 1.645 * SQRT(5)) as weekly_var_95_pct,
    (portfolio_daily_risk * 1.645 * SQRT(22)) as monthly_var_95_pct,
    ((portfolio_daily_risk * 1.645) / current_portfolio_value * 100) as daily_var_as_pct_of_portfolio
FROM portfolio_values
ORDER BY daily_var_as_pct_of_portfolio DESC;

-- 4. Portfolio Correlation Analysis
-- Analyzes correlation between different stocks in portfolios
WITH stock_returns AS (
    SELECT 
        s.symbol,
        sp.price_date,
        ((sp.close_price - LAG(sp.close_price) OVER (PARTITION BY s.stock_id ORDER BY sp.price_date)) 
         / LAG(sp.close_price) OVER (PARTITION BY s.stock_id ORDER BY sp.price_date)) as daily_return
    FROM stocks s
    JOIN stock_prices sp ON s.stock_id = sp.stock_id
),
portfolio_correlations AS (
    SELECT 
        sr1.symbol as stock1,
        sr2.symbol as stock2,
        COUNT(*) as common_days,
        (
            (COUNT(*) * SUM(sr1.daily_return * sr2.daily_return) - SUM(sr1.daily_return) * SUM(sr2.daily_return))
            / 
            (SQRT(COUNT(*) * SUM(sr1.daily_return * sr1.daily_return) - POWER(SUM(sr1.daily_return), 2)) 
             * SQRT(COUNT(*) * SUM(sr2.daily_return * sr2.daily_return) - POWER(SUM(sr2.daily_return), 2)))
        ) as correlation_coefficient
    FROM stock_returns sr1
    JOIN stock_returns sr2 ON sr1.price_date = sr2.price_date AND sr1.symbol < sr2.symbol
    WHERE sr1.daily_return IS NOT NULL AND sr2.daily_return IS NOT NULL
    GROUP BY sr1.symbol, sr2.symbol
    HAVING COUNT(*) > 10  -- Require at least 10 common data points
)
SELECT 
    ph1.portfolio_name,
    ph1.username,
    pc.stock1,
    pc.stock2,
    pc.correlation_coefficient,
    CASE 
        WHEN ABS(pc.correlation_coefficient) > 0.8 THEN 'Very High'
        WHEN ABS(pc.correlation_coefficient) > 0.6 THEN 'High'
        WHEN ABS(pc.correlation_coefficient) > 0.4 THEN 'Moderate'
        WHEN ABS(pc.correlation_coefficient) > 0.2 THEN 'Low'
        ELSE 'Very Low'
    END as correlation_strength,
    (ph1.current_shares * sp1.close_price) as stock1_position_value,
    (ph2.current_shares * sp2.close_price) as stock2_position_value
FROM portfolio_correlations pc
JOIN portfolio_holdings ph1 ON pc.stock1 = ph1.symbol
JOIN portfolio_holdings ph2 ON pc.stock2 = ph2.symbol AND ph1.portfolio_id = ph2.portfolio_id
JOIN stock_prices sp1 ON ph1.symbol = (SELECT symbol FROM stocks WHERE stock_id = sp1.stock_id)
JOIN stock_prices sp2 ON ph2.symbol = (SELECT symbol FROM stocks WHERE stock_id = sp2.stock_id)
WHERE sp1.price_date = (SELECT MAX(price_date) FROM stock_prices)
  AND sp2.price_date = (SELECT MAX(price_date) FROM stock_prices)
ORDER BY ph1.portfolio_name, ABS(pc.correlation_coefficient) DESC;

-- 5. Rebalancing Recommendations
-- Suggests portfolio rebalancing based on target allocations
WITH current_allocations AS (
    SELECT 
        ph.portfolio_id,
        ph.portfolio_name,
        ph.username,
        s.sector,
        SUM(ph.current_shares * sp.close_price) as sector_value,
        SUM(SUM(ph.current_shares * sp.close_price)) OVER (PARTITION BY ph.portfolio_id) as total_portfolio_value,
        (SUM(ph.current_shares * sp.close_price) / 
         SUM(SUM(ph.current_shares * sp.close_price)) OVER (PARTITION BY ph.portfolio_id) * 100) as current_allocation_pct
    FROM portfolio_holdings ph
    JOIN stocks s ON ph.symbol = s.symbol
    JOIN stock_prices sp ON s.stock_id = sp.stock_id
    WHERE sp.price_date = (SELECT MAX(price_date) FROM stock_prices sp2 WHERE sp2.stock_id = sp.stock_id)
    GROUP BY ph.portfolio_id, ph.portfolio_name, ph.username, s.sector
),
target_allocations AS (
    SELECT 
        'Technology' as sector, 40.0 as target_pct UNION ALL
    SELECT 'Financial Services', 25.0 UNION ALL
    SELECT 'Healthcare', 15.0 UNION ALL
    SELECT 'Consumer Discretionary', 10.0 UNION ALL
    SELECT 'Consumer Staples', 5.0 UNION ALL
    SELECT 'Communication Services', 5.0
)
SELECT 
    ca.portfolio_name,
    ca.username,
    ca.sector,
    ca.current_allocation_pct,
    COALESCE(ta.target_pct, 0) as target_allocation_pct,
    (ca.current_allocation_pct - COALESCE(ta.target_pct, 0)) as allocation_difference,
    ca.sector_value,
    ca.total_portfolio_value,
    ((COALESCE(ta.target_pct, 0) / 100 * ca.total_portfolio_value) - ca.sector_value) as rebalance_amount,
    CASE 
        WHEN (ca.current_allocation_pct - COALESCE(ta.target_pct, 0)) > 5 THEN 'SELL - Overweight'
        WHEN (ca.current_allocation_pct - COALESCE(ta.target_pct, 0)) < -5 THEN 'BUY - Underweight'
        ELSE 'HOLD - Balanced'
    END as rebalance_action
FROM current_allocations ca
LEFT JOIN target_allocations ta ON ca.sector = ta.sector
ORDER BY ca.portfolio_name, ABS(ca.current_allocation_pct - COALESCE(ta.target_pct, 0)) DESC;
