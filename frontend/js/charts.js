// Chart.js configuration and management
class PortfolioCharts {
    constructor() {
        this.charts = {};
        this.initializeCharts();
    }

    initializeCharts() {
        // Initialize all charts
        this.createAllocationChart();
        this.createSectorChart();
        this.createPerformanceChart();
    }

    createAllocationChart() {
        const ctx = document.getElementById('allocationChart');
        if (!ctx) return;

        this.charts.allocation = new Chart(ctx, {
            type: 'doughnut',
            data: {
                labels: [],
                datasets: [{
                    data: [],
                    backgroundColor: [
                        '#2563eb', '#3b82f6', '#60a5fa', '#93c5fd',
                        '#dbeafe', '#10b981', '#34d399', '#6ee7b7',
                        '#a7f3d0', '#d1fae5'
                    ],
                    borderWidth: 2,
                    borderColor: '#ffffff'
                }]
            },
            options: {
                responsive: true,
                maintainAspectRatio: false,
                plugins: {
                    legend: {
                        position: 'bottom',
                        labels: {
                            padding: 20,
                            usePointStyle: true,
                            font: {
                                size: 12
                            }
                        }
                    },
                    tooltip: {
                        callbacks: {
                            label: function(context) {
                                const label = context.label || '';
                                const value = context.formattedValue;
                                const percentage = ((context.parsed / context.dataset.data.reduce((a, b) => a + b, 0)) * 100).toFixed(1);
                                return `${label}: ₹${value} (${percentage}%)`;
                            }
                        }
                    }
                },
                cutout: '60%'
            }
        });
    }

    createSectorChart() {
        const ctx = document.getElementById('sectorChart');
        if (!ctx) return;

        this.charts.sector = new Chart(ctx, {
            type: 'pie',
            data: {
                labels: mockData.sectorAllocation.map(sector => sector.sector),
                datasets: [{
                    data: mockData.sectorAllocation.map(sector => sector.value),
                    backgroundColor: [
                        '#2563eb', '#10b981', '#f59e0b', '#ef4444',
                        '#8b5cf6', '#06b6d4', '#84cc16', '#f97316'
                    ],
                    borderWidth: 2,
                    borderColor: '#ffffff'
                }]
            },
            options: {
                responsive: true,
                maintainAspectRatio: false,
                plugins: {
                    legend: {
                        position: 'bottom',
                        labels: {
                            padding: 20,
                            usePointStyle: true,
                            font: {
                                size: 12
                            }
                        }
                    },
                    tooltip: {
                        callbacks: {
                            label: function(context) {
                                const label = context.label || '';
                                const value = new Intl.NumberFormat('en-IN', {
                                    style: 'currency',
                                    currency: 'INR'
                                }).format(context.parsed);
                                const percentage = mockData.sectorAllocation[context.dataIndex].percentage;
                                return `${label}: ${value} (${percentage}%)`;
                            }
                        }
                    }
                }
            }
        });
    }

    createPerformanceChart() {
        const ctx = document.getElementById('performanceChart');
        if (!ctx) return;

        this.charts.performance = new Chart(ctx, {
            type: 'line',
            data: mockData.performanceData,
            options: {
                responsive: true,
                maintainAspectRatio: false,
                interaction: {
                    intersect: false,
                    mode: 'index'
                },
                plugins: {
                    legend: {
                        position: 'top',
                        labels: {
                            usePointStyle: true,
                            padding: 20,
                            font: {
                                size: 12
                            }
                        }
                    },
                    tooltip: {
                        callbacks: {
                            label: function(context) {
                                const label = context.dataset.label || '';
                                const value = new Intl.NumberFormat('en-IN', {
                                    style: 'currency',
                                    currency: 'INR'
                                }).format(context.parsed.y);
                                return `${label}: ${value}`;
                            }
                        }
                    }
                },
                scales: {
                    y: {
                        beginAtZero: false,
                        ticks: {
                            callback: function(value) {
                                return new Intl.NumberFormat('en-IN', {
                                    style: 'currency',
                                    currency: 'INR',
                                    notation: 'compact'
                                }).format(value);
                            }
                        },
                        grid: {
                            color: '#e2e8f0'
                        }
                    },
                    x: {
                        grid: {
                            color: '#e2e8f0'
                        }
                    }
                }
            }
        });
    }

    updateAllocationChart(holdings) {
        if (!this.charts.allocation) return;

        // Group holdings by symbol for allocation chart
        const stockAllocation = {};
        holdings.forEach(holding => {
            if (stockAllocation[holding.symbol]) {
                stockAllocation[holding.symbol] += holding.marketValue;
            } else {
                stockAllocation[holding.symbol] = holding.marketValue;
            }
        });

        const labels = Object.keys(stockAllocation);
        const data = Object.values(stockAllocation);

        this.charts.allocation.data.labels = labels;
        this.charts.allocation.data.datasets[0].data = data;
        this.charts.allocation.update();
    }

    updateSectorChart(holdings) {
        if (!this.charts.sector) return;

        // Group holdings by sector
        const sectorAllocation = {};
        holdings.forEach(holding => {
            if (sectorAllocation[holding.sector]) {
                sectorAllocation[holding.sector] += holding.marketValue;
            } else {
                sectorAllocation[holding.sector] = holding.marketValue;
            }
        });

        const labels = Object.keys(sectorAllocation);
        const data = Object.values(sectorAllocation);

        this.charts.sector.data.labels = labels;
        this.charts.sector.data.datasets[0].data = data;
        this.charts.sector.update();
    }

    updatePerformanceChart(period = '3M') {
        if (!this.charts.performance) return;

        // For now, we'll use the same data regardless of period
        // In a real application, this would fetch different data based on the period
        let data = mockData.performanceData;
        
        // Simulate different periods
        switch (period) {
            case '1M':
                data = {
                    ...mockData.performanceData,
                    labels: ['Jul 2025'],
                    datasets: mockData.performanceData.datasets.map(dataset => ({
                        ...dataset,
                        data: [dataset.data[dataset.data.length - 1]]
                    }))
                };
                break;
            case '6M':
                data = {
                    ...mockData.performanceData,
                    labels: ['Feb 2025', 'Mar 2025', 'Apr 2025', 'May 2025', 'Jun 2025', 'Jul 2025'],
                    datasets: mockData.performanceData.datasets.map(dataset => ({
                        ...dataset,
                        data: [220000, 235000, ...dataset.data]
                    }))
                };
                break;
            case '1Y':
                data = {
                    ...mockData.performanceData,
                    labels: ['Jul 2024', 'Oct 2024', 'Jan 2025', 'Apr 2025', 'Jul 2025'],
                    datasets: mockData.performanceData.datasets.map(dataset => ({
                        ...dataset,
                        data: [180000, 200000, 225000, dataset.data[0], dataset.data[dataset.data.length - 1]]
                    }))
                };
                break;
            default: // 3M
                break;
        }

        this.charts.performance.data = data;
        this.charts.performance.update();
    }

    destroyCharts() {
        Object.values(this.charts).forEach(chart => {
            if (chart) {
                chart.destroy();
            }
        });
        this.charts = {};
    }

    resizeCharts() {
        Object.values(this.charts).forEach(chart => {
            if (chart) {
                chart.resize();
            }
        });
    }
}

// Export for use in other files
if (typeof module !== 'undefined' && module.exports) {
    module.exports = PortfolioCharts;
}
