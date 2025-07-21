#!/usr/bin/env node

/**
 * Setup script for Indian Portfolio Tracker Database
 * This script creates the database and populates it with Indian market data
 */

const mysql = require('mysql2/promise');
const fs = require('fs').promises;
const path = require('path');
require('dotenv').config();

// Database configuration
const dbConfig = {
    host: process.env.DB_HOST || 'localhost',
    user: process.env.DB_USER || 'root',
    password: process.env.DB_PASSWORD || 'password',
    multipleStatements: true
};

async function setupDatabase() {
    let connection;
    
    try {
        console.log('🚀 Starting Indian Portfolio Tracker database setup...\n');
        
        // Connect to MySQL server (without selecting a database)
        console.log('📡 Connecting to MySQL server...');
        connection = await mysql.createConnection(dbConfig);
        console.log('✅ Connected to MySQL server\n');
        
        // Create database
        console.log('🏗️  Creating database: indian_portfolio_tracker');
        await connection.execute('DROP DATABASE IF EXISTS indian_portfolio_tracker');
        await connection.execute('CREATE DATABASE indian_portfolio_tracker');
        console.log('✅ Database created successfully\n');
        
        // Switch to the new database
        await connection.execute('USE indian_portfolio_tracker');
        
        // Read and execute schema file
        console.log('📋 Creating tables from schema...');
        const schemaPath = path.join(__dirname, '..', 'schema', 'indian_market_schema.sql');
        const schemaSQL = await fs.readFile(schemaPath, 'utf8');
        
        // Split by semicolon and execute each statement
        const statements = schemaSQL.split(';').filter(stmt => stmt.trim());
        for (const statement of statements) {
            if (statement.trim()) {
                await connection.execute(statement);
            }
        }
        console.log('✅ Tables created successfully\n');
        
        // Read and execute sample data file
        console.log('📊 Inserting Indian market sample data...');
        const dataPath = path.join(__dirname, '..', 'sample_data', 'indian_market_data.sql');
        const dataSQL = await fs.readFile(dataPath, 'utf8');
        
        // Split by semicolon and execute each statement
        const dataStatements = dataSQL.split(';').filter(stmt => stmt.trim());
        for (const statement of dataStatements) {
            if (statement.trim()) {
                await connection.execute(statement);
            }
        }
        console.log('✅ Sample data inserted successfully\n');
        
        // Verify data insertion
        console.log('🔍 Verifying data insertion...');
        const [users] = await connection.execute('SELECT COUNT(*) as count FROM users');
        const [stocks] = await connection.execute('SELECT COUNT(*) as count FROM stocks');
        const [portfolios] = await connection.execute('SELECT COUNT(*) as count FROM portfolios');
        const [transactions] = await connection.execute('SELECT COUNT(*) as count FROM transactions');
        
        console.log(`   Users: ${users[0].count}`);
        console.log(`   Stocks: ${stocks[0].count}`);
        console.log(`   Portfolios: ${portfolios[0].count}`);
        console.log(`   Transactions: ${transactions[0].count}\n`);
        
        // Show sample data
        console.log('📈 Sample Indian stocks in database:');
        const [stockSample] = await connection.execute(`
            SELECT symbol, company_name, sector, exchange 
            FROM stocks 
            LIMIT 5
        `);
        stockSample.forEach(stock => {
            console.log(`   ${stock.symbol} - ${stock.company_name} (${stock.exchange})`);
        });
        
        console.log('\n💼 Sample user portfolios:');
        const [portfolioSample] = await connection.execute(`
            SELECT u.username, u.full_name, p.portfolio_name 
            FROM users u 
            JOIN portfolios p ON u.user_id = p.user_id
            LIMIT 5
        `);
        portfolioSample.forEach(portfolio => {
            console.log(`   ${portfolio.full_name} (${portfolio.username}) - ${portfolio.portfolio_name}`);
        });
        
        console.log('\n🎉 Indian Portfolio Tracker database setup completed successfully!');
        console.log('🌐 You can now start the web server with: npm start');
        console.log('📊 Access the dashboard at: http://localhost:3000\n');
        
    } catch (error) {
        console.error('❌ Error setting up database:', error.message);
        console.error('\n🔧 Troubleshooting tips:');
        console.error('   1. Make sure MySQL server is running');
        console.error('   2. Check your database credentials in .env file');
        console.error('   3. Ensure the database user has CREATE privileges');
        console.error('   4. Run: npm install to install dependencies\n');
        process.exit(1);
    } finally {
        if (connection) {
            await connection.end();
            console.log('🔌 Database connection closed');
        }
    }
}

// Run the setup
if (require.main === module) {
    setupDatabase().catch(console.error);
}

module.exports = { setupDatabase };
