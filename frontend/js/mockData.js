// Mock Data for Indian Stock Market Portfolio Tracker
// This file contains sample data that matches our Indian market SQL schema

const mockData = {
    // Sample portfolio summary data (in INR)
    portfolioSummary: {
        totalValue: 2875450.50,
        totalInvested: 2456800.00,
        unrealizedPL: 418650.50,
        unrealizedPLPct: 17.0,
        activePortfolios: 6
    },

    // Indian user portfolios data
    userPortfolios: {
        'raj_investor': {
            portfolios: [
                { id: 1, name: 'Tech Focus Portfolio', value: 854203.00, invested: 698500.00 },
                { id: 2, name: 'Dividend Income Portfolio', value: 0, invested: 0 }
            ]
        },
        'priya_trader': {
            portfolios: [
                { id: 3, name: 'Growth Portfolio', value: 987502.00, invested: 850000.00 }
            ]
        },
        'amit_growth': {
            portfolios: [
                { id: 4, name: 'Blue Chip Portfolio', value: 672308.00, invested: 598000.00 }
            ]
        },
        'sneha_value': {
            portfolios: [
                { id: 5, name: 'Banking & Finance', value: 894506.00, invested: 862500.00 }
            ]
        },
        'vikram_sip': {
            portfolios: [
                { id: 6, name: 'Monthly SIP Portfolio', value: 1254475.00, invested: 1249250.00 }
            ]
        }
    },

    // Current holdings data (Indian stocks)
    holdings: [
        {
            symbol: 'TCS',
            company: 'Tata Consultancy Services Limited',
            portfolio: 'Tech Focus Portfolio',
            username: 'raj_investor',
            sector: 'Information Technology',
            exchange: 'NSE',
            shares: 50,
            avgCost: 4100.00,
            currentPrice: 4165.30,
            marketValue: 208265.00,
            totalInvested: 205000.00,
            unrealizedPL: 3265.00,
            returnPct: 1.59,
            weight: 33.0
        },
        {
            symbol: 'INFY',
            company: 'Infosys Limited',
            portfolio: 'Tech Focus Portfolio',
            username: 'raj_investor',
            sector: 'Information Technology',
            exchange: 'NSE',
            shares: 100,
            avgCost: 1800.00,
            currentPrice: 1835.60,
            marketValue: 183560.00,
            totalInvested: 180000.00,
            unrealizedPL: 3560.00,
            returnPct: 1.98,
            weight: 20.2
        },
        {
            symbol: 'RELIANCE',
            company: 'Reliance Industries Limited',
            portfolio: 'Growth Portfolio',
            username: 'priya_trader',
            sector: 'Oil Gas & Consumable Fuels',
            exchange: 'NSE',
            shares: 200,
            avgCost: 2950.00,
            currentPrice: 2998.40,
            marketValue: 599680.00,
            totalInvested: 590000.00,
            unrealizedPL: 9680.00,
            returnPct: 1.64,
            weight: 32.7
        },
        {
            symbol: 'HDFCBANK',
            company: 'HDFC Bank Limited',
            portfolio: 'Growth Portfolio',
            username: 'priya_trader',
            sector: 'Financial Services',
            exchange: 'NSE',
            shares: 150,
            avgCost: 1670.00,
            currentPrice: 1695.80,
            marketValue: 254370.00,
            totalInvested: 250500.00,
            unrealizedPL: 3870.00,
            returnPct: 1.55,
            weight: 16.5
        },
        {
            symbol: 'MARUTI',
            company: 'Maruti Suzuki India Limited',
            portfolio: 'Blue Chip Portfolio',
            username: 'amit_growth',
            sector: 'Automobile and Auto Components',
            exchange: 'NSE',
            shares: 15,
            avgCost: 11850.00,
            currentPrice: 12150.00,
            marketValue: 182250.00,
            totalInvested: 177750.00,
            unrealizedPL: 4500.00,
            returnPct: 2.53,
            weight: 42.9
        },
        {
            symbol: 'ICICIBANK',
            company: 'ICICI Bank Limited',
            portfolio: 'Banking & Finance',
            username: 'sneha_value',
            sector: 'Financial Services',
            exchange: 'NSE',
            shares: 200,
            avgCost: 1285.00,
            currentPrice: 1320.50,
            marketValue: 264100.00,
            totalInvested: 257000.00,
            unrealizedPL: 7100.00,
            returnPct: 2.76,
            weight: 49.2
        },
        {
            symbol: 'ICICIBANK',
            company: 'ICICI Bank Limited',
            portfolio: 'Monthly SIP Portfolio',
            username: 'vikram_sip',
            sector: 'Financial Services',
            exchange: 'NSE',
            shares: 950,
            avgCost: 1315.00,
            currentPrice: 1320.50,
            marketValue: 1254475.00,
            totalInvested: 1249250.00,
            unrealizedPL: 5225.00,
            returnPct: 0.42,
            weight: 100.0
        }
    ],

    // Sector allocation data (Indian market)
    sectorAllocation: [
        { sector: 'Information Technology', value: 1658905.00, percentage: 57.7 },
        { sector: 'Financial Services', value: 564900.00, percentage: 19.6 },
        { sector: 'Oil Gas & Consumable Fuels', value: 387500.00, percentage: 13.5 },
        { sector: 'Automobile and Auto Components', value: 263200.00, percentage: 9.2 }
    ],

    // Performance data (monthly) - in INR
    performanceData: {
        labels: ['Apr 2025', 'May 2025', 'Jun 2025', 'Jul 2025'],
        datasets: [
            {
                label: 'Portfolio Value (₹)',
                data: [2456800, 2584200, 2713500, 2875450],
                borderColor: '#2563eb',
                backgroundColor: 'rgba(37, 99, 235, 0.1)',
                tension: 0.4,
                fill: true
            },
            {
                label: 'Invested Amount (₹)',
                data: [2456800, 2456800, 2456800, 2456800],
                borderColor: '#64748b',
                backgroundColor: 'rgba(100, 116, 139, 0.1)',
                tension: 0.4,
                fill: false
            }
        ]
    },

    // Top performers (Indian stocks)
    topPerformers: [
        { symbol: 'MARUTI', company: 'Maruti Suzuki India Limited', returnPct: 2.53 },
        { symbol: 'ICICIBANK', company: 'ICICI Bank Limited', returnPct: 2.76 },
        { symbol: 'INFY', company: 'Infosys Limited', returnPct: 1.98 },
        { symbol: 'RELIANCE', company: 'Reliance Industries Limited', returnPct: 1.64 },
        { symbol: 'TCS', company: 'Tata Consultancy Services Limited', returnPct: 1.59 }
    ],

    // Worst performers
    worstPerformers: [
        { symbol: 'TATAMOTORS', company: 'Tata Motors Limited', returnPct: -2.15 },
        { symbol: 'HINDALCO', company: 'Hindalco Industries Limited', returnPct: -1.80 },
        { symbol: 'TATASTEEL', company: 'Tata Steel Limited', returnPct: -0.95 }
    ],

    // Risk metrics
    riskMetrics: {
        portfolioBeta: 1.15, // Higher beta for Indian market
        volatility: 18.5, // Higher volatility
        sharpeRatio: 1.25,
        var95: -245000 // In INR
    },

    // Alerts (Indian market specific)
    alerts: [
        {
            type: 'warning',
            message: 'RELIANCE position exceeds 25% of Growth Portfolio - consider rebalancing'
        },
        {
            type: 'danger',
            message: 'TATAMOTORS position has unrealized loss > 20%'
        },
        {
            type: 'warning',
            message: 'IT sector allocation is 57.7% - high concentration risk in technology'
        }
    ]
};

// Function to get user-specific data
function getUserData(username) {
    if (!username || username === '') {
        return {
            summary: mockData.portfolioSummary,
            holdings: mockData.holdings,
            portfolios: Object.values(mockData.userPortfolios).flatMap(user => user.portfolios)
        };
    }

    const userPortfolios = mockData.userPortfolios[username];
    if (!userPortfolios) {
        return {
            summary: { totalValue: 0, totalInvested: 0, unrealizedPL: 0, unrealizedPLPct: 0, activePortfolios: 0 },
            holdings: [],
            portfolios: []
        };
    }

    const userHoldings = mockData.holdings.filter(holding => holding.username === username);
    const userSummary = {
        totalValue: userHoldings.reduce((sum, holding) => sum + holding.marketValue, 0),
        totalInvested: userHoldings.reduce((sum, holding) => sum + holding.totalInvested, 0),
        unrealizedPL: userHoldings.reduce((sum, holding) => sum + holding.unrealizedPL, 0),
        activePortfolios: userPortfolios.portfolios.length
    };
    userSummary.unrealizedPLPct = userSummary.totalInvested > 0 ? 
        (userSummary.unrealizedPL / userSummary.totalInvested * 100) : 0;

    return {
        summary: userSummary,
        holdings: userHoldings,
        portfolios: userPortfolios.portfolios
    };
}

// Function to get portfolio-specific data
function getPortfolioData(portfolioId) {
    if (!portfolioId) {
        return mockData.holdings;
    }
    
    // Find portfolio name by ID (simplified mapping)
    const portfolioNames = {
        1: 'Tech Growth Portfolio',
        3: 'Aggressive Growth',
        4: 'Balanced Portfolio',
        5: 'ESG Portfolio',
        6: 'Value Investing'
    };
    
    const portfolioName = portfolioNames[portfolioId];
    return mockData.holdings.filter(holding => holding.portfolio === portfolioName);
}

// Export for use in other files
if (typeof module !== 'undefined' && module.exports) {
    module.exports = { mockData, getUserData, getPortfolioData };
}
