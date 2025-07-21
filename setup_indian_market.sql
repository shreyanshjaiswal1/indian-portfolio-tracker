-- Complete Indian Stock Market Database Setup Script
-- Run this script to set up the Indian Portfolio Tracker database

-- Step 1: Create the database (uncomment and modify for your SQL system)
-- CREATE DATABASE indian_portfolio_tracker;
-- USE indian_portfolio_tracker;

-- Step 2: Create all tables with Indian market schema
SOURCE schema/indian_market_schema.sql;

-- Step 3: Insert Indian market sample data
SOURCE sample_data/indian_market_data.sql;

-- Step 4: Verify setup with a quick test query
SELECT 
    'Indian Market Setup Complete!' as status,
    COUNT(*) as total_users
FROM users

UNION ALL

SELECT 
    'Portfolios Created',
    COUNT(*)
FROM portfolios

UNION ALL

SELECT 
    'Indian Stocks Available',
    COUNT(*)
FROM stocks

UNION ALL

SELECT 
    'Transactions Recorded',
    COUNT(*)
FROM transactions;

-- Display current portfolio summary for Indian market
SELECT 
    'Portfolio Holdings Summary' as info,
    '' as details

UNION ALL

SELECT 
    CONCAT('Portfolio: ', portfolio_name) as info,
    CONCAT('User: ', first_name, ' ', last_name, ' (', username, ')') as details
FROM portfolio_holdings
ORDER BY info
LIMIT 10;

-- Show sample Indian stocks
SELECT 
    'Top Indian Stocks in Database' as info,
    '' as details

UNION ALL

SELECT 
    CONCAT(symbol, ' - ', company_name) as info,
    CONCAT(exchange, ' | ', sector) as details
FROM stocks
ORDER BY market_cap_category = 'Large Cap' DESC, symbol
LIMIT 10;
