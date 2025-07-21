# Financial Portfolio Tracker SQL Project

A comprehensive SQL-based financial portfolio management system for tracking stock investments, analyzing performance, and managing risk across multiple portfolios.

## 📊 Project Overview

This project provides a complete database schema and analytical framework for financial portfolio management, including:

- **Portfolio Management**: Track multiple portfolios per user with detailed transaction history
- **Performance Analytics**: Calculate returns, risk metrics, and portfolio performance over time
- **Risk Analysis**: Volatility calculations, Value at Risk (VaR), correlation analysis, and Sharpe ratios
- **Reporting Dashboards**: Executive summaries, sector analysis, and automated alerts
- **Asset Allocation**: Portfolio diversification analysis and rebalancing recommendations

## 🗂️ Project Structure

```
financial-portfolio-tracker/
├── frontend/                      # Web dashboard frontend
│   ├── index.html                # Main dashboard page
│   ├── css/styles.css            # Styling and responsive design
│   └── js/                       # JavaScript modules
│       ├── dashboard.js          # Main dashboard functionality
│       ├── charts.js             # Chart.js configurations
│       └── mockData.js           # Sample data for frontend
├── api/
│   └── server.js                 # Express.js REST API server
├── scripts/
│   └── setup-database.js         # Automated database setup
├── schema/
│   └── create_tables.sql          # Database schema definition
├── sample_data/
│   └── insert_data.sql           # Sample data for testing
├── queries/
│   ├── portfolio_analysis.sql    # Basic portfolio performance queries
│   ├── risk_analysis.sql         # Advanced risk and volatility analysis
│   └── reporting_dashboard.sql   # Executive reporting and alerts
├── .github/
│   └── copilot-instructions.md   # AI coding assistant instructions
├── package.json                  # Node.js dependencies
└── README.md                     # This file
```

## 🏗️ Database Schema

### Core Tables

- **`users`**: User account information
- **`stocks`**: Stock master data with company details
- **`stock_prices`**: Historical price data for technical analysis
- **`portfolios`**: User portfolio definitions
- **`transactions`**: Buy/sell transaction records

### Key Features

- Proper foreign key relationships and constraints
- Optimized indexes for time-series queries
- Portfolio holdings view for current positions
- Support for multiple currencies and exchanges

## 🚀 Getting Started

### Prerequisites

- **Node.js** (v14 or higher) for the web server
- **MySQL, PostgreSQL, or SQLite** for the database
- **Web browser** for the dashboard interface

### Option 1: Complete Setup (Database + Web Interface)

1. **Install Node.js dependencies**
   ```bash
   npm install
   ```

2. **Set up the database automatically**
   ```bash
   npm run setup-db
   ```

3. **Start the web server**
   ```bash
   npm start
   ```

4. **Open the dashboard**
   ```
   http://localhost:3000
   ```

### Option 2: SQL-Only Setup

#### Quick Setup (Option 1: One Command)

Run the complete setup script:
```sql
SOURCE setup.sql;
```

#### Manual Setup (Option 2: Step by Step)

1. **Create the Database Schema**
   ```sql
   SOURCE schema/create_tables.sql;
   ```

2. **Load Sample Data**
   ```sql
   SOURCE sample_data/insert_data.sql;
   ```

3. **Run Analysis Queries**
   ```sql
   SOURCE queries/portfolio_analysis.sql;
   ```

### How to Run on Different Database Systems

#### MySQL
```bash
# Connect to MySQL
mysql -u your_username -p

# Create database and use it
CREATE DATABASE portfolio_tracker;
USE portfolio_tracker;

# Run the setup
SOURCE setup.sql;
```

#### PostgreSQL
```bash
# Connect to PostgreSQL
psql -U your_username -d postgres

# Create database and connect
CREATE DATABASE portfolio_tracker;
\c portfolio_tracker;

# Run the setup (use \i instead of SOURCE)
\i setup.sql;
```

#### SQLite
```bash
# Create/open SQLite database
sqlite3 portfolio_tracker.db

# Run the setup
.read setup.sql
```

## 📈 Key Features and Queries

### 🌐 Web Dashboard Features

- **📊 Interactive Charts**: Portfolio allocation, sector distribution, and performance over time
- **👤 Multi-User Support**: Switch between different users and their portfolios
- **📱 Responsive Design**: Works on desktop, tablet, and mobile devices
- **🔄 Real-Time Updates**: Refresh data and see live portfolio changes
- **🔍 Advanced Filtering**: Search and sort holdings by various criteria
- **⚠️ Risk Alerts**: Automated notifications for concentration risk and large losses
- **📈 Performance Tracking**: Visual representation of portfolio growth over time

### 🏦 Portfolio Performance Analysis

- **Current Holdings Summary**: Real-time portfolio positions and unrealized P&L
- **Portfolio Returns**: Time-weighted returns and performance metrics
- **Asset Allocation**: Sector and individual stock weightings
- **Transaction History**: Detailed audit trail with running averages

### Risk Management

- **Volatility Analysis**: Portfolio and individual stock volatility calculations
- **Value at Risk (VaR)**: Potential loss estimation at various confidence levels
- **Correlation Analysis**: Stock correlation matrices for diversification insights
- **Sharpe Ratio**: Risk-adjusted return measurements

### Advanced Analytics

- **Sector Performance**: Industry-wise performance breakdown
- **Rebalancing Recommendations**: Automated suggestions based on target allocations
- **Dividend Income Projections**: Estimated dividend yields and income
- **Performance Benchmarking**: Comparison against sector averages

### Reporting Dashboards

- **Executive Summary**: High-level platform and user metrics
- **Top Holdings**: Most popular stocks across all portfolios
- **Risk-Return Matrix**: Portfolio comparison on risk vs return
- **Automated Alerts**: Concentration risk and large loss notifications

## 💡 Sample Use Cases

### For Portfolio Managers
- Track client portfolios and generate performance reports
- Identify rebalancing opportunities and risk concentrations
- Monitor compliance with investment guidelines

### For Individual Investors
- Analyze personal investment performance
- Understand portfolio risk characteristics
- Make informed buy/sell decisions

### For Financial Advisors
- Compare client portfolios against benchmarks
- Generate client reports and performance summaries
- Identify tax-loss harvesting opportunities

## 🔧 Advanced Usage

### Custom Analysis
The modular query structure allows for easy customization:
- Modify risk-free rates in Sharpe ratio calculations
- Adjust target allocations for rebalancing recommendations
- Add new performance metrics and KPIs

### Integration Possibilities
- Connect to real-time market data feeds
- Export results to BI tools (Tableau, Power BI)
- Integrate with portfolio management systems

### Performance Optimization
- All queries include proper indexing recommendations
- Window functions used for efficient time-series analysis
- CTEs (Common Table Expressions) for improved readability

## 📊 Sample Queries

### Quick Portfolio Overview
```sql
-- See all current holdings
SELECT * FROM portfolio_holdings 
WHERE portfolio_name = 'Tech Growth Portfolio';
```

### Run Specific Analysis

#### Portfolio Performance Analysis
```sql
-- Run all portfolio analysis queries
SOURCE queries/portfolio_analysis.sql;

-- Or run individual sections (copy/paste from the file):
-- 1. Current Portfolio Holdings Summary
-- 2. Portfolio Summary by User  
-- 3. Asset Allocation Analysis
-- 4. Transaction History Analysis
-- 5. Monthly Portfolio Performance
-- 6. Top Performers and Losers
-- 7. Dividend Income Potential
```

#### Risk Analysis
```sql
-- Run all risk analysis queries
SOURCE queries/risk_analysis.sql;

-- Individual risk metrics:
-- 1. Portfolio Risk Analysis (Volatility)
-- 2. Sharpe Ratio Calculation
-- 3. Value at Risk (VaR) Estimation
-- 4. Portfolio Correlation Analysis
-- 5. Rebalancing Recommendations
```

#### Executive Dashboard
```sql
-- Run all reporting queries
SOURCE queries/reporting_dashboard.sql;

-- Individual reports:
-- 1. Executive Portfolio Summary
-- 2. Top Holdings Across All Portfolios
-- 3. Sector Performance Analysis
-- 4. Monthly Trading Activity
-- 5. Risk-Return Matrix
-- 6. Portfolio Performance Benchmarking
-- 7. Alert and Notification Queries
```

### Test Your Setup
```sql
-- Quick verification query
SELECT 'Database Setup Complete!' as status,
       (SELECT COUNT(*) FROM users) as users,
       (SELECT COUNT(*) FROM portfolios) as portfolios,
       (SELECT COUNT(*) FROM stocks) as stocks,
       (SELECT COUNT(*) FROM transactions) as transactions;
```

## 🎯 Learning Objectives

This project helps practice:
- **Complex JOINs**: Multi-table relationships and data integration
- **Window Functions**: Ranking, running totals, and time-series analysis
- **CTEs**: Breaking down complex queries into readable components
- **Aggregations**: GROUP BY, HAVING, and statistical functions
- **Date Functions**: Time-based filtering and period calculations
- **Subqueries**: Correlated and non-correlated subquery patterns

## 🔍 Key SQL Concepts Demonstrated

- **Time-Series Analysis**: Rolling calculations and period-over-period comparisons
- **Financial Calculations**: Returns, volatility, correlations, and risk metrics
- **Data Modeling**: Normalized schema design for financial data
- **Performance Optimization**: Strategic indexing and query optimization
- **Reporting**: Hierarchical summaries and drill-down capabilities

## 📚 Extensions and Enhancements

### Potential Additions
- Options and derivatives tracking
- Currency conversion for international stocks
- ESG (Environmental, Social, Governance) scoring
- Machine learning integration for predictive analytics
- Real-time alerting system
- Mobile-responsive dashboard integration

### Advanced Features
- Monte Carlo simulations for portfolio projections
- Black-Scholes option pricing models
- Factor analysis (Fama-French three-factor model)
- Portfolio optimization algorithms
- Stress testing scenarios

## 🤝 Contributing

Feel free to extend this project with:
- Additional financial metrics and calculations
- Enhanced data visualization queries
- Performance optimizations
- New reporting templates
- Integration with external data sources

## 📝 License

This project is provided as an educational resource for learning SQL and financial analysis concepts.

---

**Happy Investing and Happy Querying! 📈💻**
