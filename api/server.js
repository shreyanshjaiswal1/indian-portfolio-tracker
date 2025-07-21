// Express.js API for Portfolio Tracker
// This file provides REST API endpoints to connect the frontend with the SQL database

const express = require('express');
const mysql = require('mysql2/promise');
const cors = require('cors');
const path = require('path');

const app = express();
const PORT = process.env.PORT || 3000;

// Middleware
app.use(cors());
app.use(express.json());
app.use(express.static(path.join(__dirname, '../frontend')));

// Database configuration for Indian Market
const dbConfig = {
    host: process.env.DB_HOST || 'localhost',
    user: process.env.DB_USER || 'root',
    password: process.env.DB_PASSWORD || 'your_password',
    database: process.env.DB_NAME || 'indian_portfolio_tracker',
    waitForConnections: true,
    connectionLimit: 10,
    queueLimit: 0
};

// Create connection pool
const pool = mysql.createPool(dbConfig);

// API Routes

// Get all users (Indian customers)
app.get('/api/users', async (req, res) => {
    try {
        const [rows] = await pool.execute(`
            SELECT user_id, username, email, first_name, last_name, 
                   pan_number, phone_number, city, state 
            FROM users
        `);
        res.json(rows);
    } catch (error) {
        console.error('Error fetching users:', error);
        res.status(500).json({ error: 'Internal server error' });
    }
});

// Get portfolio summary for a user (or all users if no user specified)
app.get('/api/portfolio-summary', async (req, res) => {
    try {
        const { username } = req.query;
        
        let query = `
            SELECT 
                u.username,
                COUNT(DISTINCT p.portfolio_id) as total_portfolios,
                COALESCE(SUM(ph.total_invested), 0) as total_amount_invested,
                COALESCE(SUM(ph.current_shares * sp.close_price), 0) as total_current_value,
                COALESCE(SUM((ph.current_shares * sp.close_price) - ph.total_invested), 0) as total_unrealized_gain_loss,
                COUNT(DISTINCT ph.symbol) as total_unique_stocks
            FROM users u
            LEFT JOIN portfolios p ON u.user_id = p.user_id
            LEFT JOIN portfolio_holdings ph ON p.portfolio_id = ph.portfolio_id
            LEFT JOIN stocks s ON ph.symbol = s.symbol
            LEFT JOIN stock_prices sp ON s.stock_id = sp.stock_id AND sp.price_date = (
                SELECT MAX(price_date) FROM stock_prices sp2 WHERE sp2.stock_id = sp.stock_id
            )
        `;

        const params = [];
        if (username) {
            query += ' WHERE u.username = ?';
            params.push(username);
        }

        query += ' GROUP BY u.user_id, u.username';

        const [rows] = await pool.execute(query, params);
        
        if (username && rows.length > 0) {
            const summary = rows[0];
            summary.unrealized_pl_pct = summary.total_amount_invested > 0 ? 
                (summary.total_unrealized_gain_loss / summary.total_amount_invested * 100) : 0;
            res.json(summary);
        } else if (!username) {
            // Return aggregated data for all users
            const totals = rows.reduce((acc, row) => {
                acc.total_portfolios += row.total_portfolios || 0;
                acc.total_amount_invested += parseFloat(row.total_amount_invested) || 0;
                acc.total_current_value += parseFloat(row.total_current_value) || 0;
                acc.total_unrealized_gain_loss += parseFloat(row.total_unrealized_gain_loss) || 0;
                acc.total_unique_stocks += row.total_unique_stocks || 0;
                return acc;
            }, {
                total_portfolios: 0,
                total_amount_invested: 0,
                total_current_value: 0,
                total_unrealized_gain_loss: 0,
                total_unique_stocks: 0,
                total_users: rows.length
            });
            
            totals.unrealized_pl_pct = totals.total_amount_invested > 0 ? 
                (totals.total_unrealized_gain_loss / totals.total_amount_invested * 100) : 0;
            
            res.json(totals);
        } else {
            res.json({
                total_portfolios: 0,
                total_amount_invested: 0,
                total_current_value: 0,
                total_unrealized_gain_loss: 0,
                unrealized_pl_pct: 0,
                total_unique_stocks: 0
            });
        }
    } catch (error) {
        console.error('Error fetching portfolio summary:', error);
        res.status(500).json({ error: 'Internal server error' });
    }
});

// Get current holdings (Indian stocks)
app.get('/api/holdings', async (req, res) => {
    try {
        const { username, portfolio_id } = req.query;
        
        let query = `
            SELECT 
                ph.portfolio_name,
                ph.username,
                ph.first_name,
                ph.last_name,
                ph.symbol,
                ph.company_name,
                ph.sector,
                ph.exchange,
                ph.market_cap_category,
                ph.current_shares,
                ph.avg_purchase_price,
                ph.total_invested,
                sp.close_price as current_price,
                (ph.current_shares * sp.close_price) as current_market_value,
                ((ph.current_shares * sp.close_price) - ph.total_invested) as unrealized_gain_loss,
                (((ph.current_shares * sp.close_price) - ph.total_invested) / ph.total_invested * 100) as unrealized_return_pct
            FROM portfolio_holdings ph
            JOIN stocks s ON ph.symbol = s.symbol
            JOIN stock_prices sp ON s.stock_id = sp.stock_id
            WHERE sp.price_date = (
                SELECT MAX(price_date) 
                FROM stock_prices sp2 
                WHERE sp2.stock_id = sp.stock_id
            )
        `;

        const params = [];
        const conditions = [];

        if (username) {
            conditions.push('ph.username = ?');
            params.push(username);
        }

        if (portfolio_id) {
            conditions.push('ph.portfolio_id = ?');
            params.push(portfolio_id);
        }

        if (conditions.length > 0) {
            query += ' AND ' + conditions.join(' AND ');
        }

        query += ' ORDER BY current_market_value DESC';

        const [rows] = await pool.execute(query, params);
        res.json(rows);
    } catch (error) {
        console.error('Error fetching holdings:', error);
        res.status(500).json({ error: 'Internal server error' });
    }
});

// Get user portfolios
app.get('/api/portfolios', async (req, res) => {
    try {
        const { username } = req.query;
        
        let query = `
            SELECT 
                p.portfolio_id,
                p.portfolio_name,
                p.description,
                u.username,
                COALESCE(SUM(ph.total_invested), 0) as total_invested,
                COALESCE(SUM(ph.current_shares * sp.close_price), 0) as current_value
            FROM portfolios p
            JOIN users u ON p.user_id = u.user_id
            LEFT JOIN portfolio_holdings ph ON p.portfolio_id = ph.portfolio_id
            LEFT JOIN stocks s ON ph.symbol = s.symbol
            LEFT JOIN stock_prices sp ON s.stock_id = sp.stock_id AND sp.price_date = (
                SELECT MAX(price_date) FROM stock_prices sp2 WHERE sp2.stock_id = sp.stock_id
            )
        `;

        const params = [];
        if (username) {
            query += ' WHERE u.username = ?';
            params.push(username);
        }

        query += ' GROUP BY p.portfolio_id, p.portfolio_name, p.description, u.username ORDER BY current_value DESC';

        const [rows] = await pool.execute(query, params);
        res.json(rows);
    } catch (error) {
        console.error('Error fetching portfolios:', error);
        res.status(500).json({ error: 'Internal server error' });
    }
});

// Get sector allocation
app.get('/api/sector-allocation', async (req, res) => {
    try {
        const { username } = req.query;
        
        let query = `
            SELECT 
                s.sector,
                SUM(ph.current_shares * sp.close_price) as sector_value,
                (SUM(ph.current_shares * sp.close_price) / 
                 (SELECT SUM(ph2.current_shares * sp2.close_price) 
                  FROM portfolio_holdings ph2 
                  JOIN stocks s2 ON ph2.symbol = s2.symbol
                  JOIN stock_prices sp2 ON s2.stock_id = sp2.stock_id
                  WHERE sp2.price_date = (SELECT MAX(price_date) FROM stock_prices)
                  ${username ? 'AND ph2.username = ?' : ''}
                 ) * 100) as percentage
            FROM portfolio_holdings ph
            JOIN stocks s ON ph.symbol = s.symbol
            JOIN stock_prices sp ON s.stock_id = sp.stock_id
            WHERE sp.price_date = (
                SELECT MAX(price_date) 
                FROM stock_prices sp2 
                WHERE sp2.stock_id = sp.stock_id
            )
        `;

        const params = [];
        if (username) {
            query += ' AND ph.username = ?';
            params.push(username);
        }

        query += ' GROUP BY s.sector ORDER BY sector_value DESC';

        const [rows] = await pool.execute(query, params);
        res.json(rows);
    } catch (error) {
        console.error('Error fetching sector allocation:', error);
        res.status(500).json({ error: 'Internal server error' });
    }
});

// Get top performers
app.get('/api/top-performers', async (req, res) => {
    try {
        const query = `
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
            HAVING avg_return_pct IS NOT NULL
            ORDER BY avg_return_pct DESC
            LIMIT 10
        `;

        const [rows] = await pool.execute(query);
        res.json(rows);
    } catch (error) {
        console.error('Error fetching top performers:', error);
        res.status(500).json({ error: 'Internal server error' });
    }
});

// Get portfolio performance over time (simplified)
app.get('/api/performance', async (req, res) => {
    try {
        const { username, period = '3M' } = req.query;
        
        // This is a simplified version - in reality, you'd need more complex time-series data
        const query = `
            SELECT 
                DATE_FORMAT(sp.price_date, '%Y-%m') as month_year,
                sp.price_date,
                SUM(ph.current_shares * sp.close_price) as portfolio_value
            FROM portfolio_holdings ph
            JOIN stocks s ON ph.symbol = s.symbol
            JOIN stock_prices sp ON s.stock_id = sp.stock_id
            WHERE sp.price_date >= DATE_SUB(CURDATE(), INTERVAL 6 MONTH)
            ${username ? 'AND ph.username = ?' : ''}
            GROUP BY sp.price_date
            ORDER BY sp.price_date
        `;

        const params = username ? [username] : [];
        const [rows] = await pool.execute(query, params);
        res.json(rows);
    } catch (error) {
        console.error('Error fetching performance data:', error);
        res.status(500).json({ error: 'Internal server error' });
    }
});

// Serve frontend
app.get('/', (req, res) => {
    res.sendFile(path.join(__dirname, '../frontend/index.html'));
});

// Health check endpoint
app.get('/api/health', (req, res) => {
    res.json({ status: 'OK', timestamp: new Date().toISOString() });
});

// Error handling middleware
app.use((err, req, res, next) => {
    console.error(err.stack);
    res.status(500).json({ error: 'Something went wrong!' });
});

// Start server
app.listen(PORT, () => {
    console.log(`Portfolio Tracker API server running on port ${PORT}`);
    console.log(`Frontend available at: http://localhost:${PORT}`);
    console.log(`API endpoints available at: http://localhost:${PORT}/api/*`);
});

module.exports = app;
