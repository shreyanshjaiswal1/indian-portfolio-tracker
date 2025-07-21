// Data helper functions
function getUserData(username) {
    if (!username) {
        // Return aggregated data for all users
        return {
            summary: mockData.portfolioSummary,
            holdings: mockData.holdings,
            portfolios: Object.values(mockData.userPortfolios).flat().map(p => p.portfolios).flat()
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
    
    // Filter holdings for this user
    const userHoldings = mockData.holdings.filter(holding => holding.username === username);
    
    // Calculate user summary
    const totalValue = userHoldings.reduce((sum, h) => sum + h.marketValue, 0);
    const totalInvested = userHoldings.reduce((sum, h) => sum + (h.totalInvested || h.investmentAmount || h.avgCost * h.shares), 0);
    const unrealizedPL = totalValue - totalInvested;
    const unrealizedPLPct = totalInvested > 0 ? (unrealizedPL / totalInvested) * 100 : 0;
    
    return {
        summary: {
            totalValue,
            totalInvested,
            unrealizedPL,
            unrealizedPLPct,
            activePortfolios: userPortfolios.portfolios.length
        },
        holdings: userHoldings,
        portfolios: userPortfolios.portfolios
    };
}

function getPortfolioData(portfolioId) {
    // Filter holdings by portfolio ID (match by portfolio name for now)
    const portfolioNames = {
        1: 'Tech Focus Portfolio',
        2: 'Dividend Income Portfolio', 
        3: 'Growth Portfolio',
        4: 'Blue Chip Portfolio',
        5: 'Banking & Finance',
        6: 'Monthly SIP Portfolio'
    };
    
    const portfolioName = portfolioNames[portfolioId];
    if (!portfolioName) return [];
    
    return mockData.holdings.filter(holding => holding.portfolio === portfolioName);
}

// Main Dashboard JavaScript
class PortfolioDashboard {
    constructor() {
        this.currentUser = '';
        this.currentPortfolio = '';
        this.charts = null;
        this.initialize();
    }

    initialize() {
        this.setupEventListeners();
        this.charts = new PortfolioCharts();
        // Initialize with all data first
        this.loadDashboard();
        this.populatePortfolioSelect();
        
        // Initialize charts with default data
        if (this.charts) {
            this.charts.updateAllocationChart(mockData.holdings);
            this.charts.updateSectorChart(mockData.holdings);
        }
    }

    setupEventListeners() {
        // User selection
        const userSelect = document.getElementById('userSelect');
        if (userSelect) {
            userSelect.addEventListener('change', (e) => {
                this.currentUser = e.target.value;
                this.loadDashboard();
                this.populatePortfolioSelect();
            });
        }

        // Portfolio selection for allocation chart
        const portfolioSelect = document.getElementById('portfolioSelect');
        if (portfolioSelect) {
            portfolioSelect.addEventListener('change', (e) => {
                this.currentPortfolio = e.target.value;
                this.updateAllocationChart();
            });
        }

        // Refresh button
        const refreshBtn = document.getElementById('refreshBtn');
        if (refreshBtn) {
            refreshBtn.addEventListener('click', () => {
                this.showLoading();
                setTimeout(() => {
                    this.loadDashboard();
                    this.hideLoading();
                }, 1000);
            });
        }

        // Performance period buttons
        const periodButtons = document.querySelectorAll('[data-period]');
        periodButtons.forEach(btn => {
            btn.addEventListener('click', (e) => {
                // Remove active class from all buttons
                periodButtons.forEach(b => b.classList.remove('active'));
                // Add active class to clicked button
                e.target.classList.add('active');
                // Update chart
                const period = e.target.getAttribute('data-period');
                this.charts.updatePerformanceChart(period);
            });
        });

        // Search and sort functionality
        const searchInput = document.getElementById('searchInput');
        if (searchInput) {
            searchInput.addEventListener('input', () => this.filterHoldingsTable());
        }

        const sortSelect = document.getElementById('sortSelect');
        if (sortSelect) {
            sortSelect.addEventListener('change', () => this.sortHoldingsTable());
        }

        // Window resize handler
        window.addEventListener('resize', () => {
            if (this.charts) {
                this.charts.resizeCharts();
            }
        });
    }

    loadDashboard() {
        const userData = getUserData(this.currentUser);
        
        this.updateSummaryCards(userData.summary);
        this.updateHoldingsTable(userData.holdings);
        this.updateChartsData(userData.holdings);
        this.updateRiskMetrics();
        this.updateAlerts();
        this.updatePerformers();
    }

    updateSummaryCards(summary) {
        // Total Portfolio Value
        const totalValueEl = document.getElementById('totalValue');
        if (totalValueEl) {
            totalValueEl.textContent = this.formatCurrency(summary.totalValue);
        }

        // Total Invested
        const totalInvestedEl = document.getElementById('totalInvested');
        if (totalInvestedEl) {
            totalInvestedEl.textContent = this.formatCurrency(summary.totalInvested);
        }

        // Unrealized P&L
        const unrealizedPLEl = document.getElementById('unrealizedPL');
        const unrealizedPLPctEl = document.getElementById('unrealizedPLPct');
        if (unrealizedPLEl && unrealizedPLPctEl) {
            unrealizedPLEl.textContent = this.formatCurrency(summary.unrealizedPL);
            unrealizedPLPctEl.textContent = `${summary.unrealizedPLPct > 0 ? '+' : ''}${summary.unrealizedPLPct.toFixed(2)}%`;
            
            // Update color based on positive/negative
            unrealizedPLPctEl.className = 'card-change ' + (summary.unrealizedPLPct >= 0 ? 'positive' : 'negative');
        }

        // Total Change
        const totalChangeEl = document.getElementById('totalChange');
        if (totalChangeEl) {
            totalChangeEl.textContent = `${summary.unrealizedPLPct > 0 ? '+' : ''}${summary.unrealizedPLPct.toFixed(2)}%`;
            totalChangeEl.className = 'card-change ' + (summary.unrealizedPLPct >= 0 ? 'positive' : 'negative');
        }

        // Active Portfolios
        const activePortfoliosEl = document.getElementById('activePortfolios');
        if (activePortfoliosEl) {
            activePortfoliosEl.textContent = summary.activePortfolios.toString();
        }
    }

    updateHoldingsTable(holdings) {
        const tableBody = document.getElementById('holdingsTableBody');
        if (!tableBody) return;

        if (holdings.length === 0) {
            tableBody.innerHTML = '<tr><td colspan="10" style="text-align: center; padding: 2rem; color: #64748b;">No holdings found for selected user</td></tr>';
            return;
        }

        tableBody.innerHTML = holdings.map(holding => `
            <tr>
                <td><strong>${holding.symbol}</strong></td>
                <td>${holding.company}</td>
                <td>${holding.portfolio}</td>
                <td>${holding.shares.toLocaleString()}</td>
                <td>${this.formatCurrency(holding.avgCost)}</td>
                <td>${this.formatCurrency(holding.currentPrice)}</td>
                <td>${this.formatCurrency(holding.marketValue)}</td>
                <td class="${holding.unrealizedPL >= 0 ? 'text-success' : 'text-danger'}">
                    ${this.formatCurrency(holding.unrealizedPL)}
                </td>
                <td class="${holding.returnPct >= 0 ? 'text-success' : 'text-danger'}">
                    ${holding.returnPct > 0 ? '+' : ''}${holding.returnPct.toFixed(2)}%
                </td>
                <td>${holding.weight.toFixed(1)}%</td>
            </tr>
        `).join('');
    }

    updateChartsData(holdings) {
        if (this.charts && holdings.length > 0) {
            this.charts.updateAllocationChart(holdings);
            this.charts.updateSectorChart(holdings);
        }
    }

    updateAllocationChart() {
        const holdings = this.currentPortfolio ? 
            getPortfolioData(parseInt(this.currentPortfolio)) : 
            getUserData(this.currentUser).holdings;
        
        if (this.charts) {
            this.charts.updateAllocationChart(holdings);
        }
    }

    populatePortfolioSelect() {
        const portfolioSelect = document.getElementById('portfolioSelect');
        if (!portfolioSelect) return;

        const userData = getUserData(this.currentUser);
        
        // Clear existing options except "All Portfolios"
        portfolioSelect.innerHTML = '<option value="">All Portfolios</option>';
        
        // Add user's portfolios
        userData.portfolios.forEach(portfolio => {
            const option = document.createElement('option');
            option.value = portfolio.id;
            option.textContent = portfolio.name;
            portfolioSelect.appendChild(option);
        });
    }

    updateRiskMetrics() {
        const metrics = mockData.riskMetrics;
        
        const betaEl = document.getElementById('portfolioBeta');
        if (betaEl) betaEl.textContent = metrics.portfolioBeta.toFixed(2);
        
        const volatilityEl = document.getElementById('volatility');
        if (volatilityEl) volatilityEl.textContent = `${metrics.volatility.toFixed(1)}%`;
        
        const sharpeEl = document.getElementById('sharpeRatio');
        if (sharpeEl) sharpeEl.textContent = metrics.sharpeRatio.toFixed(2);
        
        const varEl = document.getElementById('var95');
        if (varEl) varEl.textContent = this.formatCurrency(metrics.var95);
    }

    updateAlerts() {
        const alertsContainer = document.getElementById('alertsContainer');
        if (!alertsContainer) return;

        if (mockData.alerts.length === 0) {
            alertsContainer.innerHTML = '<div style="text-align: center; color: #64748b; padding: 1rem;">No alerts at this time</div>';
            return;
        }

        alertsContainer.innerHTML = mockData.alerts.map(alert => `
            <div class="alert-item ${alert.type}">
                <i class="fas fa-${alert.type === 'warning' ? 'exclamation-triangle' : 'exclamation-circle'}"></i>
                ${alert.message}
            </div>
        `).join('');
    }

    updatePerformers() {
        // Top Performers
        const topPerformersEl = document.getElementById('topPerformers');
        if (topPerformersEl) {
            topPerformersEl.innerHTML = mockData.topPerformers.map(performer => `
                <div class="performer-item">
                    <div class="performer-info">
                        <div class="performer-symbol">${performer.symbol}</div>
                        <div class="performer-company">${performer.company}</div>
                    </div>
                    <div class="performer-return positive">+${performer.returnPct.toFixed(2)}%</div>
                </div>
            `).join('');
        }

        // Worst Performers
        const worstPerformersEl = document.getElementById('worstPerformers');
        if (worstPerformersEl) {
            worstPerformersEl.innerHTML = mockData.worstPerformers.map(performer => `
                <div class="performer-item">
                    <div class="performer-info">
                        <div class="performer-symbol">${performer.symbol}</div>
                        <div class="performer-company">${performer.company}</div>
                    </div>
                    <div class="performer-return negative">${performer.returnPct.toFixed(2)}%</div>
                </div>
            `).join('');
        }
    }

    filterHoldingsTable() {
        const searchInput = document.getElementById('searchInput');
        const tableBody = document.getElementById('holdingsTableBody');
        
        if (!searchInput || !tableBody) return;

        const searchTerm = searchInput.value.toLowerCase();
        const rows = tableBody.querySelectorAll('tr');

        rows.forEach(row => {
            const text = row.textContent.toLowerCase();
            if (text.includes(searchTerm)) {
                row.style.display = '';
            } else {
                row.style.display = 'none';
            }
        });
    }

    sortHoldingsTable() {
        const sortSelect = document.getElementById('sortSelect');
        const tableBody = document.getElementById('holdingsTableBody');
        
        if (!sortSelect || !tableBody) return;

        const sortBy = sortSelect.value;
        const userData = getUserData(this.currentUser);
        let holdings = [...userData.holdings];

        switch (sortBy) {
            case 'value':
                holdings.sort((a, b) => b.marketValue - a.marketValue);
                break;
            case 'return':
                holdings.sort((a, b) => b.returnPct - a.returnPct);
                break;
            case 'symbol':
                holdings.sort((a, b) => a.symbol.localeCompare(b.symbol));
                break;
        }

        this.updateHoldingsTable(holdings);
    }

    showLoading() {
        const loadingOverlay = document.getElementById('loadingOverlay');
        if (loadingOverlay) {
            loadingOverlay.classList.add('show');
        }
    }

    hideLoading() {
        const loadingOverlay = document.getElementById('loadingOverlay');
        if (loadingOverlay) {
            loadingOverlay.classList.remove('show');
        }
    }

    formatCurrency(amount) {
        return new Intl.NumberFormat('en-IN', {
            style: 'currency',
            currency: 'INR'
        }).format(amount);
    }

    formatPercent(value) {
        return `${value > 0 ? '+' : ''}${value.toFixed(2)}%`;
    }
}

// Initialize dashboard when DOM is loaded
document.addEventListener('DOMContentLoaded', () => {
    // Show loading initially
    const loadingOverlay = document.getElementById('loadingOverlay');
    if (loadingOverlay) {
        loadingOverlay.classList.add('show');
    }

    // Initialize dashboard after a short delay to show loading
    setTimeout(() => {
        const dashboard = new PortfolioDashboard();
        
        // Hide loading after initialization
        if (loadingOverlay) {
            loadingOverlay.classList.remove('show');
        }
    }, 1500);
});

// Export for use in other files
if (typeof module !== 'undefined' && module.exports) {
    module.exports = PortfolioDashboard;
}
