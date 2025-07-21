# 🇮🇳 Indian Financial Portfolio Tracker

A comprehensive SQL-based financial portfolio management system specifically designed for the Indian stock market with NSE/BSE exchanges, featuring real-time portfolio tracking, performance analytics, and a modern web dashboard.

## 🌟 Indian Market Features

- **NSE/BSE Stock Support**: Track stocks from National Stock Exchange and Bombay Stock Exchange
- **Indian Tax Calculations**: Built-in STT (Securities Transaction Tax) and GST calculations
- **PAN Number Integration**: User profiles with PAN number support for Indian tax compliance
- **INR Currency**: All calculations and displays in Indian Rupees (₹)
- **Major Indian Stocks**: Pre-loaded with top Indian companies (TCS, Infosys, Reliance, HDFC Bank, etc.)
- **Indian Sector Classification**: Technology, Banking, Pharmaceuticals, Auto, Oil & Gas, etc.

## 🚀 Quick Start (Indian Market Setup)

### Prerequisites
- Node.js (v14 or higher)
- MySQL Server running
- Git

### 1. Clone and Install
```bash
git clone <repository-url>
cd financial-portfolio-tracker
npm install
```

### 2. Database Setup
```bash
# Update .env file with your MySQL credentials
nano .env

# Run the Indian market database setup
npm run setup-indian-db
```

### 3. Start the Application
```bash
# Start the web server
npm start

# Or run in development mode with auto-reload
npm run dev
```

### 4. Access the Dashboard
Open your browser and navigate to: `http://localhost:3000`

## 📊 Indian Market Sample Data

The system comes pre-loaded with:

### Sample Users (with PAN numbers)
- **Raj Kumar Sharma** (raj_investor) - PAN: ABCDE1234F
- **Priya Patel** (priya_trader) - PAN: FGHIJ5678K
- **Amit Singh** (amit_growth) - PAN: LMNOP9012Q
- **Sneha Gupta** (sneha_value) - PAN: RSTUV3456W
- **Vikram Reddy** (vikram_sip) - PAN: XYZAB7890C

### Indian Stocks Included
- **IT Sector**: TCS, Infosys, Wipro, HCL Tech, Tech Mahindra
- **Banking**: HDFC Bank, ICICI Bank, SBI, Kotak Mahindra, Axis Bank
- **Oil & Gas**: Reliance Industries, ONGC, IOC
- **Auto**: Maruti Suzuki, Tata Motors, Mahindra & Mahindra
- **Pharma**: Sun Pharma, Dr. Reddy's
- **Metals**: Hindalco, Tata Steel

## 🔧 Configuration

### Environment Variables (.env)
```env
# Database Configuration
DB_HOST=localhost
DB_USER=root
DB_PASSWORD=your_mysql_password
DB_NAME=indian_portfolio_tracker
DB_PORT=3306

# Indian Market Settings
DEFAULT_CURRENCY=INR
DEFAULT_EXCHANGE=NSE
TAX_RATE_STT=0.001
TAX_RATE_GST=0.18
```

## 🏗️ Architecture

### Database Schema (Indian Market)
- **users**: User profiles with PAN numbers and Indian addresses
- **stocks**: Indian stocks with NSE/BSE symbols and ISIN codes
- **stock_prices**: Real-time price data in INR
- **portfolios**: User portfolio management
- **transactions**: Buy/sell transactions with Indian tax calculations

### API Endpoints
- `GET /api/users` - Get all users with Indian profiles
- `GET /api/users/:username/portfolios` - User portfolios
- `GET /api/users/:username/holdings` - Current holdings with INR values
- `GET /api/stocks` - Indian stock data
- `GET /api/analytics/performance` - Portfolio performance in INR

### Frontend Features
- **Real-time Dashboard**: Live portfolio values in INR
- **Indian Stock Charts**: Price movements and sector allocations
- **Tax Analytics**: STT and GST calculations
- **Performance Metrics**: Returns calculated in Indian market context
- **Responsive Design**: Mobile-friendly interface

## 📈 Sample Queries (Indian Market)

### Portfolio Performance
```sql
-- Get portfolio performance with Indian tax considerations
SELECT 
    p.portfolio_name,
    u.full_name,
    u.pan_number,
    SUM(h.current_value) as portfolio_value_inr,
    SUM(h.investment_amount) as total_invested_inr,
    SUM(h.current_value - h.investment_amount) as unrealized_pl_inr,
    ROUND(((SUM(h.current_value) - SUM(h.investment_amount)) / SUM(h.investment_amount)) * 100, 2) as return_percentage
FROM portfolios p
JOIN users u ON p.user_id = u.user_id
JOIN holdings h ON p.portfolio_id = h.portfolio_id
GROUP BY p.portfolio_id, u.user_id;
```

### Indian Sector Analysis
```sql
-- Analyze sector allocation in Indian market
SELECT 
    s.sector,
    COUNT(*) as num_stocks,
    SUM(h.current_value) as sector_value_inr,
    ROUND((SUM(h.current_value) / (SELECT SUM(current_value) FROM holdings)) * 100, 2) as sector_weight_pct
FROM holdings h
JOIN stocks s ON h.stock_id = s.stock_id
WHERE s.exchange IN ('NSE', 'BSE')
GROUP BY s.sector
ORDER BY sector_value_inr DESC;
```

## 🔍 Analytics Features

### Risk Metrics (Indian Market Context)
- Portfolio Beta relative to NIFTY 50
- Volatility analysis for Indian stocks
- Value at Risk (VaR) calculations in INR
- Sector concentration risk

### Performance Tracking
- Returns calculation in INR
- Benchmark comparison with NIFTY indices
- Dividend yield tracking
- Tax-adjusted returns

## 🛠️ Development

### Project Structure
```
├── schema/
│   └── indian_market_schema.sql     # Indian market database schema
├── sample_data/
│   └── indian_market_data.sql       # Sample Indian stocks and users
├── queries/
│   ├── portfolio_analysis.sql       # Portfolio analytics queries
│   ├── risk_analysis.sql           # Risk management queries
│   └── reporting_dashboard.sql     # Dashboard data queries
├── api/
│   └── server.js                   # Express.js API server
├── frontend/
│   ├── index.html                  # Dashboard interface
│   ├── css/styles.css              # Responsive styling
│   └── js/
│       ├── dashboard.js            # Dashboard functionality
│       ├── charts.js               # Chart components
│       └── mockData.js             # Indian market mock data
└── scripts/
    └── setup-indian-database.js   # Database setup script
```

### Adding New Indian Stocks
1. Insert into `stocks` table with NSE/BSE symbol
2. Add current price in `stock_prices` table
3. Update sector classification
4. Include ISIN code for compliance

## 📱 Mobile Support

The dashboard is fully responsive and optimized for:
- Indian banking apps integration
- Mobile portfolio tracking
- Touch-friendly charts and tables
- Offline capability for basic features

## 🔐 Security & Compliance

- PAN number validation and encryption
- Indian financial regulations compliance
- Secure API endpoints
- Data privacy protection
- Audit trail for all transactions

## 🚀 Production Deployment

### For Indian Cloud Providers
- **AWS Mumbai (ap-south-1)**: Optimized for Indian users
- **Azure India**: Low latency for NSE/BSE data
- **Google Cloud Mumbai**: Real-time market data integration

### Environment Configuration
```bash
# Production environment variables
NODE_ENV=production
DB_HOST=your-production-db-host
REDIS_URL=your-redis-url # For caching Indian stock prices
```

## 📞 Support

For questions about Indian market features or technical support:
- Create an issue in the repository
- Include details about Indian market specific requirements
- Mention NSE/BSE symbols and PAN number handling if relevant

## 📄 License

MIT License - Feel free to use for personal or commercial projects in the Indian financial sector.

---

**Made with ❤️ for Indian investors and developers**
