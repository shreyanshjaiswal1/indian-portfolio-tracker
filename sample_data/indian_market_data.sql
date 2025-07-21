-- Sample Data for Indian Stock Market Portfolio Tracker
-- This file contains realistic Indian market data for testing

-- Insert Indian users with PAN numbers
INSERT INTO users (username, email, first_name, last_name, pan_number, phone_number, city, state) VALUES
('raj_investor', 'raj.sharma@gmail.com', 'Raj', 'Sharma', 'ABCDE1234F', '+91-9876543210', 'Mumbai', 'Maharashtra'),
('priya_trader', 'priya.patel@yahoo.com', 'Priya', 'Patel', 'FGHIJ5678K', '+91-9876543211', 'Ahmedabad', 'Gujarat'),
('amit_growth', 'amit.singh@rediffmail.com', 'Amit', 'Singh', 'KLMNO9012P', '+91-9876543212', 'Delhi', 'Delhi'),
('sneha_value', 'sneha.reddy@outlook.com', 'Sneha', 'Reddy', 'QRSTU3456V', '+91-9876543213', 'Hyderabad', 'Telangana'),
('vikram_sip', 'vikram.kumar@gmail.com', 'Vikram', 'Kumar', 'WXYZB7890C', '+91-9876543214', 'Bangalore', 'Karnataka');

-- Insert popular Indian stocks from NSE/BSE
INSERT INTO stocks (symbol, company_name, sector, industry, exchange, market_cap_category, isin_code, listing_date) VALUES
-- Large Cap Technology Stocks
('TCS', 'Tata Consultancy Services Limited', 'Information Technology', 'IT Services & Consulting', 'NSE', 'Large Cap', 'INE467B01029', '2004-08-25'),
('INFY', 'Infosys Limited', 'Information Technology', 'IT Services & Consulting', 'NSE', 'Large Cap', 'INE009A01021', '1993-06-08'),
('HCLTECH', 'HCL Technologies Limited', 'Information Technology', 'IT Services & Consulting', 'NSE', 'Large Cap', 'INE860A01027', '2000-01-06'),
('WIPRO', 'Wipro Limited', 'Information Technology', 'IT Services & Consulting', 'NSE', 'Large Cap', 'INE075A01022', '1980-10-29'),

-- Banking & Financial Services
('RELIANCE', 'Reliance Industries Limited', 'Oil Gas & Consumable Fuels', 'Refineries', 'NSE', 'Large Cap', 'INE002A01018', '1977-11-29'),
('HDFCBANK', 'HDFC Bank Limited', 'Financial Services', 'Private Sector Bank', 'NSE', 'Large Cap', 'INE040A01034', '1995-11-08'),
('ICICIBANK', 'ICICI Bank Limited', 'Financial Services', 'Private Sector Bank', 'NSE', 'Large Cap', 'INE090A01021', '1997-09-17'),
('KOTAKBANK', 'Kotak Mahindra Bank Limited', 'Financial Services', 'Private Sector Bank', 'NSE', 'Large Cap', 'INE237A01028', '2012-12-20'),
('AXISBANK', 'Axis Bank Limited', 'Financial Services', 'Private Sector Bank', 'NSE', 'Large Cap', 'INE238A01034', '1998-07-02'),

-- FMCG & Consumer
('HINDUNILVR', 'Hindustan Unilever Limited', 'Fast Moving Consumer Goods', 'Personal Products', 'NSE', 'Large Cap', 'INE030A01027', '1956-07-01'),
('ITC', 'ITC Limited', 'Fast Moving Consumer Goods', 'Tobacco Products', 'NSE', 'Large Cap', 'INE154A01025', '1951-08-24'),
('NESTLEIND', 'Nestle India Limited', 'Fast Moving Consumer Goods', 'Food Products', 'NSE', 'Large Cap', 'INE239A01016', '1993-04-26'),

-- Automobile
('MARUTI', 'Maruti Suzuki India Limited', 'Automobile and Auto Components', 'Passenger Cars & Utility Vehicles', 'NSE', 'Large Cap', 'INE585B01010', '2003-07-09'),
('TATAMOTORS', 'Tata Motors Limited', 'Automobile and Auto Components', 'Passenger Cars & Utility Vehicles', 'NSE', 'Large Cap', 'INE155A01022', '1998-07-22'),

-- Pharmaceuticals
('SUNPHARMA', 'Sun Pharmaceutical Industries Limited', 'Healthcare', 'Pharmaceuticals', 'NSE', 'Large Cap', 'INE044A01036', '1994-02-08'),
('DRREDDY', 'Dr. Reddys Laboratories Limited', 'Healthcare', 'Pharmaceuticals', 'NSE', 'Large Cap', 'INE089A01023', '2001-05-30'),

-- Mid Cap Stocks
('BAJFINANCE', 'Bajaj Finance Limited', 'Financial Services', 'Non Banking Financial Company (NBFC)', 'NSE', 'Large Cap', 'INE296A01024', '2003-04-01'),
('ADANIPORTS', 'Adani Ports and Special Economic Zone Limited', 'Infrastructure', 'Port & Port services', 'NSE', 'Large Cap', 'INE742F01042', '2007-11-27'),

-- Metals & Mining
('TATASTEEL', 'Tata Steel Limited', 'Metals & Mining', 'Iron & Steel', 'NSE', 'Large Cap', 'INE081A01020', '1997-11-18'),
('HINDALCO', 'Hindalco Industries Limited', 'Metals & Mining', 'Aluminium', 'NSE', 'Large Cap', 'INE038A01020', '1995-01-04');

-- Insert sample market indices data (NIFTY 50 and SENSEX)
INSERT INTO market_indices (index_name, index_date, open_value, high_value, low_value, close_value, change_points, change_percent) VALUES
('NIFTY 50', '2025-07-21', 24850.50, 24920.75, 24780.25, 24895.60, 45.10, 0.18),
('SENSEX', '2025-07-21', 81450.75, 81620.30, 81280.50, 81575.45, 124.70, 0.15),
('NIFTY 50', '2025-07-20', 24805.40, 24870.80, 24720.60, 24850.50, 45.10, 0.18),
('SENSEX', '2025-07-20', 81326.05, 81485.25, 81150.75, 81450.75, 124.70, 0.15),
('NIFTY 50', '2025-07-19', 24720.30, 24825.90, 24650.20, 24805.40, 85.10, 0.34),
('SENSEX', '2025-07-19', 81102.50, 81350.60, 80980.40, 81326.05, 223.55, 0.28);

-- Insert sample stock prices (last few days for key stocks)
-- TCS prices
INSERT INTO stock_prices (stock_id, price_date, open_price, high_price, low_price, close_price, volume, adjusted_close) VALUES
(1, '2025-07-21', 4125.00, 4185.50, 4098.75, 4165.30, 2845000, 4165.30),
(1, '2025-07-20', 4098.25, 4142.80, 4076.50, 4125.00, 3120000, 4125.00),
(1, '2025-07-19', 4076.50, 4115.75, 4045.20, 4098.25, 2960000, 4098.25);

-- Infosys prices  
INSERT INTO stock_prices (stock_id, price_date, open_price, high_price, low_price, close_price, volume, adjusted_close) VALUES
(2, '2025-07-21', 1820.50, 1845.75, 1805.25, 1835.60, 1850000, 1835.60),
(2, '2025-07-20', 1805.25, 1828.90, 1798.50, 1820.50, 2100000, 1820.50),
(2, '2025-07-19', 1798.50, 1815.75, 1785.20, 1805.25, 1920000, 1805.25);

-- Reliance prices
INSERT INTO stock_prices (stock_id, price_date, open_price, high_price, low_price, close_price, volume, adjusted_close) VALUES
(5, '2025-07-21', 2985.75, 3015.50, 2962.25, 2998.40, 4250000, 2998.40),
(5, '2025-07-20', 2962.25, 2990.80, 2945.60, 2985.75, 4680000, 2985.75),
(5, '2025-07-19', 2945.60, 2975.30, 2920.85, 2962.25, 4420000, 2962.25);

-- HDFC Bank prices
INSERT INTO stock_prices (stock_id, price_date, open_price, high_price, low_price, close_price, volume, adjusted_close) VALUES
(6, '2025-07-21', 1685.50, 1705.75, 1672.25, 1695.80, 3850000, 1695.80),
(6, '2025-07-20', 1672.25, 1688.90, 1665.50, 1685.50, 4120000, 1685.50),
(6, '2025-07-19', 1665.50, 1678.75, 1652.20, 1672.25, 3920000, 1672.25);

-- Insert sample portfolios for Indian users
INSERT INTO portfolios (user_id, portfolio_name, description, portfolio_type) VALUES
(1, 'Tech Focus Portfolio', 'Focus on Indian IT and technology stocks', 'Equity'),
(1, 'Dividend Income Portfolio', 'Conservative dividend-paying Indian stocks', 'Equity'),
(2, 'Growth Portfolio', 'High-growth Indian stocks across sectors', 'Equity'),
(3, 'Blue Chip Portfolio', 'Large cap Indian stocks for stability', 'Equity'),
(4, 'Banking & Finance', 'Focus on Indian banking and financial services', 'Equity'),
(5, 'Monthly SIP Portfolio', 'Systematic investment in top Indian stocks', 'SIP');

-- Insert sample transactions with Indian market specifics (including STT, brokerage, etc.)
-- Raj's Tech Portfolio
INSERT INTO transactions (portfolio_id, stock_id, transaction_type, quantity, price_per_share, total_amount, brokerage, stt, stamp_duty, gst, other_charges, net_amount, transaction_date, settlement_date, order_id, notes) VALUES
(1, 1, 'BUY', 50, 4100.00, 205000.00, 410.00, 205.00, 103.00, 73.80, 50.00, 205841.80, '2025-07-15', '2025-07-17', 'ORD001', 'Initial TCS investment'),
(1, 2, 'BUY', 100, 1800.00, 180000.00, 360.00, 180.00, 90.00, 64.80, 40.00, 180734.80, '2025-07-16', '2025-07-18', 'ORD002', 'INFY investment'),
(1, 3, 'BUY', 75, 1420.00, 106500.00, 213.00, 106.50, 53.25, 38.34, 25.00, 106936.09, '2025-07-17', '2025-07-19', 'ORD003', 'HCL Tech position'),

-- Priya's Growth Portfolio  
(3, 5, 'BUY', 200, 2950.00, 590000.00, 1180.00, 590.00, 295.00, 212.40, 100.00, 592377.40, '2025-07-15', '2025-07-17', 'ORD004', 'Reliance large position'),
(3, 6, 'BUY', 150, 1670.00, 250500.00, 501.00, 250.50, 125.25, 90.18, 60.00, 251526.93, '2025-07-16', '2025-07-18', 'ORD005', 'HDFC Bank investment'),
(3, 11, 'BUY', 300, 580.00, 174000.00, 348.00, 174.00, 87.00, 62.64, 45.00, 174716.64, '2025-07-17', '2025-07-19', 'ORD006', 'HUL FMCG play'),

-- Amit's Blue Chip Portfolio
(4, 1, 'BUY', 25, 4080.00, 102000.00, 204.00, 102.00, 51.00, 36.72, 25.00, 102418.72, '2025-07-18', '2025-07-20', 'ORD007', 'TCS blue chip'),
(4, 12, 'BUY', 400, 485.00, 194000.00, 388.00, 194.00, 97.00, 69.84, 50.00, 194798.84, '2025-07-18', '2025-07-20', 'ORD008', 'ITC dividend stock'),
(4, 14, 'BUY', 15, 11850.00, 177750.00, 355.50, 177.75, 88.88, 64.00, 45.00, 178481.13, '2025-07-19', '2025-07-21', 'ORD009', 'Maruti auto exposure'),

-- Sneha's Banking Portfolio
(5, 6, 'BUY', 100, 1675.00, 167500.00, 335.00, 167.50, 83.75, 60.30, 40.00, 168186.55, '2025-07-16', '2025-07-18', 'ORD010', 'HDFC Bank core holding'),
(5, 7, 'BUY', 200, 1285.00, 257000.00, 514.00, 257.00, 128.50, 92.52, 65.00, 258057.02, '2025-07-17', '2025-07-19', 'ORD011', 'ICICI Bank position'),
(5, 9, 'BUY', 125, 1125.00, 140625.00, 281.25, 140.63, 70.31, 50.63, 35.00, 141202.82, '2025-07-18', '2025-07-20', 'ORD012', 'Axis Bank investment'),

-- Vikram's SIP Portfolio (monthly investments)
(6, 1, 'BUY', 12, 4050.00, 48600.00, 97.20, 48.60, 24.30, 17.50, 15.00, 48802.60, '2025-07-01', '2025-07-03', 'SIP001', 'July SIP - TCS'),
(6, 2, 'BUY', 25, 1790.00, 44750.00, 89.50, 44.75, 22.38, 16.11, 12.00, 44934.74, '2025-07-01', '2025-07-03', 'SIP002', 'July SIP - Infosys'),
(6, 5, 'BUY', 15, 2940.00, 44100.00, 88.20, 44.10, 22.05, 15.88, 12.00, 44282.23, '2025-07-01', '2025-07-03', 'SIP003', 'July SIP - Reliance');
