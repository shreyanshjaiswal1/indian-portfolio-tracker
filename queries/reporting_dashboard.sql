-- Reporting and Dashboard Queries
-- Ready-to-use queries for executive summaries and reporting dashboards

-- 1. Executive Portfolio Summary Dashboard
-- High-level overview of all portfolios and key metrics
WITH portfolio_summary AS (
    SELECT 
        u.username,
        COUNT(DISTINCT p.portfolio_id) as total_portfolios,
        SUM(ph.total_invested) as total_amount_invested,
        SUM(ph.current_shares * sp.close_price) as total_current_value,
        SUM((ph.current_shares * sp.close_price) - ph.total_invested) as total_unrealized_gain_loss,
        COUNT(DISTINCT ph.symbol) as total_unique_stocks
    FROM users u
    JOIN portfolios p ON u.user_id = p.user_id
    JOIN portfolio_holdings ph ON p.portfolio_id = ph.portfolio_id
    JOIN stocks s ON ph.symbol = s.symbol
    JOIN stock_prices sp ON s.stock_id = sp.stock_id
    WHERE sp.price_date = (SELECT MAX(price_date) FROM stock_prices sp2 WHERE sp2.stock_id = sp.stock_id)
    GROUP BY u.user_id, u.username
)
SELECT 
    'PLATFORM TOTALS' as metric_type,
    'All Users' as username,
    SUM(total_portfolios) as total_portfolios,
    SUM(total_amount_invested) as total_amount_invested,
    SUM(total_current_value) as total_current_value,
    SUM(total_unrealized_gain_loss) as total_unrealized_gain_loss,
    (SUM(total_unrealized_gain_loss) / SUM(total_amount_invested) * 100) as overall_return_pct,
    SUM(total_unique_stocks) as total_unique_stocks,
    COUNT(*) as total_users
FROM portfolio_summary

UNION ALL

SELECT 
    'USER DETAILS' as metric_type,
    username,
    total_portfolios,
    total_amount_invested,
    total_current_value,
    total_unrealized_gain_loss,
    (total_unrealized_gain_loss / total_amount_invested * 100) as overall_return_pct,
    total_unique_stocks,
    1 as total_users
FROM portfolio_summary
ORDER BY metric_type, total_current_value DESC;

-- 2. Top Holdings Across All Portfolios
-- Most popular stocks and their aggregate performance
SELECT 
    s.symbol,
    s.company_name,
    s.sector,
    COUNT(DISTINCT ph.portfolio_id) as held_by_portfolios,
    SUM(ph.current_shares) as total_shares_held,
    AVG(ph.avg_purchase_price) as avg_purchase_price_all_users,
    sp.close_price as current_price,
    SUM(ph.current_shares * sp.close_price) as total_market_value,
    SUM(ph.total_invested) as total_amount_invested_all_users,
    SUM((ph.current_shares * sp.close_price) - ph.total_invested) as total_unrealized_gain_loss,
    (SUM((ph.current_shares * sp.close_price) - ph.total_invested) / SUM(ph.total_invested) * 100) as overall_return_pct
FROM stocks s
JOIN portfolio_holdings ph ON s.symbol = ph.symbol
JOIN stock_prices sp ON s.stock_id = sp.stock_id
WHERE sp.price_date = (SELECT MAX(price_date) FROM stock_prices sp2 WHERE sp2.stock_id = sp.stock_id)
GROUP BY s.symbol, s.company_name, s.sector, sp.close_price
ORDER BY total_market_value DESC;

-- 3. Sector Performance Analysis
-- Performance breakdown by industry sectors
SELECT 
    s.sector,
    COUNT(DISTINCT s.stock_id) as stocks_in_sector,
    COUNT(DISTINCT ph.portfolio_id) as portfolios_with_exposure,
    SUM(ph.total_invested) as total_invested_in_sector,
    SUM(ph.current_shares * sp.close_price) as current_sector_value,
    SUM((ph.current_shares * sp.close_price) - ph.total_invested) as sector_unrealized_gain_loss,
    (SUM((ph.current_shares * sp.close_price) - ph.total_invested) / SUM(ph.total_invested) * 100) as sector_return_pct,
    (SUM(ph.current_shares * sp.close_price) / 
     (SELECT SUM(ph2.current_shares * sp2.close_price) 
      FROM portfolio_holdings ph2 
      JOIN stocks s2 ON ph2.symbol = s2.symbol
      JOIN stock_prices sp2 ON s2.stock_id = sp2.stock_id
      WHERE sp2.price_date = (SELECT MAX(price_date) FROM stock_prices)) * 100) as sector_weight_pct
FROM stocks s
JOIN portfolio_holdings ph ON s.symbol = ph.symbol
JOIN stock_prices sp ON s.stock_id = sp.stock_id
WHERE sp.price_date = (SELECT MAX(price_date) FROM stock_prices sp2 WHERE sp2.stock_id = sp.stock_id)
GROUP BY s.sector
ORDER BY sector_return_pct DESC;

-- 4. Monthly Trading Activity Summary
-- Transaction volume and activity trends
SELECT 
    DATE_FORMAT(t.transaction_date, '%Y-%m') as month_year,
    COUNT(*) as total_transactions,
    SUM(CASE WHEN t.transaction_type = 'BUY' THEN 1 ELSE 0 END) as buy_transactions,
    SUM(CASE WHEN t.transaction_type = 'SELL' THEN 1 ELSE 0 END) as sell_transactions,
    SUM(t.total_amount) as total_transaction_volume,
    SUM(CASE WHEN t.transaction_type = 'BUY' THEN t.total_amount ELSE 0 END) as total_buy_volume,
    SUM(CASE WHEN t.transaction_type = 'SELL' THEN t.total_amount ELSE 0 END) as total_sell_volume,
    SUM(t.commission) as total_commissions_paid,
    COUNT(DISTINCT t.portfolio_id) as active_portfolios,
    COUNT(DISTINCT t.stock_id) as unique_stocks_traded,
    AVG(t.total_amount) as avg_transaction_size
FROM transactions t
GROUP BY DATE_FORMAT(t.transaction_date, '%Y-%m')
ORDER BY month_year DESC;

-- 5. Risk-Return Matrix for Portfolio Comparison
-- Compares all portfolios on risk vs return metrics
WITH portfolio_metrics AS (
    SELECT 
        p.portfolio_id,
        p.portfolio_name,
        u.username,
        SUM(ph.total_invested) as total_invested,
        SUM(ph.current_shares * sp.close_price) as current_value,
        ((SUM(ph.current_shares * sp.close_price) - SUM(ph.total_invested)) / SUM(ph.total_invested) * 100) as return_pct,
        COUNT(DISTINCT ph.symbol) as number_of_holdings,
        -- Calculate portfolio concentration (Herfindahl Index)
        SUM(POWER((ph.current_shares * sp.close_price) / SUM(ph.current_shares * sp.close_price) OVER (PARTITION BY p.portfolio_id), 2)) as concentration_index
    FROM portfolios p
    JOIN users u ON p.user_id = u.user_id
    JOIN portfolio_holdings ph ON p.portfolio_id = ph.portfolio_id
    JOIN stocks s ON ph.symbol = s.symbol
    JOIN stock_prices sp ON s.stock_id = sp.stock_id
    WHERE sp.price_date = (SELECT MAX(price_date) FROM stock_prices sp2 WHERE sp2.stock_id = sp.stock_id)
    GROUP BY p.portfolio_id, p.portfolio_name, u.username
)
SELECT 
    portfolio_name,
    username,
    total_invested,
    current_value,
    return_pct,
    number_of_holdings,
    concentration_index,
    CASE 
        WHEN concentration_index > 0.5 THEN 'High Concentration'
        WHEN concentration_index > 0.25 THEN 'Medium Concentration' 
        ELSE 'Well Diversified'
    END as diversification_level,
    CASE 
        WHEN return_pct > 15 AND concentration_index < 0.3 THEN 'High Return, Low Risk'
        WHEN return_pct > 15 AND concentration_index >= 0.3 THEN 'High Return, High Risk'
        WHEN return_pct <= 15 AND concentration_index < 0.3 THEN 'Low Return, Low Risk'
        ELSE 'Low Return, High Risk'
    END as risk_return_category
FROM portfolio_metrics
ORDER BY return_pct DESC;

-- 6. Portfolio Performance Benchmarking
-- Compares portfolio performance against sector averages
WITH sector_benchmarks AS (
    SELECT 
        s.sector,
        AVG(((sp.close_price - sp_prev.close_price) / sp_prev.close_price) * 100) as sector_avg_return
    FROM stocks s
    JOIN stock_prices sp ON s.stock_id = sp.stock_id
    JOIN stock_prices sp_prev ON s.stock_id = sp_prev.stock_id
    WHERE sp.price_date = (SELECT MAX(price_date) FROM stock_prices)
      AND sp_prev.price_date = (
          SELECT MAX(price_date) 
          FROM stock_prices sp2 
          WHERE sp2.stock_id = s.stock_id 
            AND sp2.price_date < (SELECT MAX(price_date) FROM stock_prices)
      )
    GROUP BY s.sector
),
portfolio_sector_exposure AS (
    SELECT 
        ph.portfolio_id,
        ph.portfolio_name,
        ph.username,
        s.sector,
        SUM(ph.current_shares * sp.close_price) as sector_value,
        SUM(SUM(ph.current_shares * sp.close_price)) OVER (PARTITION BY ph.portfolio_id) as total_portfolio_value,
        (SUM(ph.current_shares * sp.close_price) / SUM(SUM(ph.current_shares * sp.close_price)) OVER (PARTITION BY ph.portfolio_id)) as sector_weight
    FROM portfolio_holdings ph
    JOIN stocks s ON ph.symbol = s.symbol
    JOIN stock_prices sp ON s.stock_id = sp.stock_id
    WHERE sp.price_date = (SELECT MAX(price_date) FROM stock_prices sp2 WHERE sp2.stock_id = sp.stock_id)
    GROUP BY ph.portfolio_id, ph.portfolio_name, ph.username, s.sector
)
SELECT 
    pse.portfolio_name,
    pse.username,
    pse.total_portfolio_value,
    SUM(pse.sector_weight * sb.sector_avg_return) as benchmark_weighted_return,
    -- This would need actual portfolio return calculation for comparison
    'Portfolio vs Benchmark analysis requires time-series data' as note
FROM portfolio_sector_exposure pse
JOIN sector_benchmarks sb ON pse.sector = sb.sector
GROUP BY pse.portfolio_id, pse.portfolio_name, pse.username, pse.total_portfolio_value
ORDER BY pse.total_portfolio_value DESC;

-- 7. Alert and Notification Queries
-- Identifies portfolios that may need attention
SELECT 
    'CONCENTRATION RISK' as alert_type,
    ph.portfolio_name,
    ph.username,
    ph.symbol,
    ph.company_name,
    (ph.current_shares * sp.close_price) as position_value,
    total_portfolio.total_value,
    ((ph.current_shares * sp.close_price) / total_portfolio.total_value * 100) as position_weight_pct,
    'Position exceeds 25% of portfolio' as alert_message
FROM portfolio_holdings ph
JOIN stocks s ON ph.symbol = s.symbol
JOIN stock_prices sp ON s.stock_id = sp.stock_id
JOIN (
    SELECT 
        ph2.portfolio_id,
        SUM(ph2.current_shares * sp2.close_price) as total_value
    FROM portfolio_holdings ph2
    JOIN stocks s2 ON ph2.symbol = s2.symbol
    JOIN stock_prices sp2 ON s2.stock_id = sp2.stock_id
    WHERE sp2.price_date = (SELECT MAX(price_date) FROM stock_prices)
    GROUP BY ph2.portfolio_id
) total_portfolio ON ph.portfolio_id = total_portfolio.portfolio_id
WHERE sp.price_date = (SELECT MAX(price_date) FROM stock_prices sp2 WHERE sp2.stock_id = sp.stock_id)
  AND ((ph.current_shares * sp.close_price) / total_portfolio.total_value) > 0.25

UNION ALL

SELECT 
    'LARGE UNREALIZED LOSS' as alert_type,
    ph.portfolio_name,
    ph.username,
    ph.symbol,
    ph.company_name,
    (ph.current_shares * sp.close_price) as position_value,
    ph.total_invested,
    (((ph.current_shares * sp.close_price) - ph.total_invested) / ph.total_invested * 100) as return_pct,
    'Position has unrealized loss > 20%' as alert_message
FROM portfolio_holdings ph
JOIN stocks s ON ph.symbol = s.symbol
JOIN stock_prices sp ON s.stock_id = sp.stock_id
WHERE sp.price_date = (SELECT MAX(price_date) FROM stock_prices sp2 WHERE sp2.stock_id = sp.stock_id)
  AND (((ph.current_shares * sp.close_price) - ph.total_invested) / ph.total_invested) < -0.20

ORDER BY alert_type, position_weight_pct DESC;
