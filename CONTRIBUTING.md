# Contributing to Indian Portfolio Tracker

Thank you for your interest in contributing to the Indian Portfolio Tracker! 🇮🇳

## 🚀 Getting Started

1. **Fork the repository**
2. **Clone your fork**
   ```bash
   git clone https://github.com/YOUR_USERNAME/indian-portfolio-tracker.git
   cd indian-portfolio-tracker
   ```
3. **Install dependencies**
   ```bash
   npm install
   ```
4. **Set up environment**
   ```bash
   cp .env.example .env
   # Edit .env with your database credentials
   ```

## 🛠️ Development Workflow

1. **Create a feature branch**
   ```bash
   git checkout -b feature/your-feature-name
   ```
2. **Make your changes**
3. **Test your changes**
   ```bash
   npm start
   ```
4. **Commit with descriptive messages**
   ```bash
   git commit -m "feat: add portfolio rebalancing feature"
   ```
5. **Push and create a Pull Request**

## 📋 Code Style Guidelines

### SQL Guidelines
- Use snake_case for table and column names
- Include comments for complex calculations
- Use CTEs for better readability
- Follow the existing schema patterns

### JavaScript Guidelines
- Use meaningful variable names
- Add JSDoc comments for functions
- Follow existing error handling patterns
- Keep functions focused and small

### Frontend Guidelines
- Maintain responsive design principles
- Use semantic HTML
- Follow existing CSS naming conventions
- Ensure accessibility standards

## 🗃️ Database Contributions

When contributing database changes:
- Update the schema files in `schema/`
- Provide migration scripts if needed
- Update sample data in `sample_data/`
- Test with both MySQL and SQLite

## 🐛 Bug Reports

Please use the issue templates and include:
- Clear reproduction steps
- Expected vs actual behavior
- Browser/environment details
- Console errors if applicable

## 💡 Feature Requests

For new features, please:
- Check existing issues first
- Describe the use case clearly
- Consider Indian market requirements
- Discuss implementation approach

## 🧪 Testing

- Test all database queries
- Verify frontend functionality
- Check API endpoints
- Ensure mobile responsiveness

## 📄 License

By contributing, you agree that your contributions will be licensed under the MIT License.

## 🤝 Community

- Be respectful and inclusive
- Help others learn and grow
- Share knowledge about Indian markets
- Collaborate constructively

Thank you for helping make this project better! 🙏
