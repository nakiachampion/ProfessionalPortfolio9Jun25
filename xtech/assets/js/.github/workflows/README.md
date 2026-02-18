# Xceptional Technologies - Dynamic Website

[![Build Status](https://github.com/nakiachampion/ProfessionalPortfolio9Jun25/actions/workflows/deploy.yml/badge.svg?branch=xtech-website)](https://github.com/nakiachampion/ProfessionalPortfolio9Jun25/actions)
[![License: MIT](https://img.shields.io/badge/License-MIT-yellow.svg)](https://opensource.org/licenses/MIT)

A modern, responsive website for Xceptional Technologies featuring Ubiquiti UniFi products and services.

## Overview

This project demonstrates a complete, professional website implementation with:

- **Dynamic Product Catalog** - Interactive UniFi product showcase with filtering and search capabilities
- **Responsive Design** - Mobile-first approach using modern CSS Grid and Flexbox
- **JavaScript Interactivity** - Smooth animations, form handling, and shopping cart functionality
- **Automated Deployment** - GitHub Actions workflow for continuous integration and deployment
- **Professional Services Pages** - Comprehensive service offerings with pricing information

## Project Structure

```
xtech-website/
├── xtech/
│   ├── index.html              # Homepage with hero section and featured products
│   ├── about.html              # About page with team and certifications
│   ├── services.html           # Services and pricing information
│   ├── contact.html            # Contact form and FAQ
│   ├── plan.html               # Business plan and strategy
│   └── assets/
│       ├── css/
│       │   └── style.css       # Global styles and responsive layouts
│       └── js/
│           ├── main.js         # Core functionality and utilities
│           └── products.js     # Product data and shopping cart
├── .github/
│   └── workflows/
│       └── deploy.yml          # CI/CD pipeline configuration
└── README.md                   # This file
```

## Key Features

### 1. **Responsive Web Design**
- Mobile-first approach
- Breakpoints for tablets, desktops, and ultra-wide screens
- Optimized performance across all devices

### 2. **Dynamic Product Management**
- 6+ featured UniFi products with specifications
- Product filtering by category (Wireless, Security, Switching, etc.)
- Search functionality across product names and descriptions
- Shopping cart with localStorage persistence

### 3. **Interactive Features**
- Smooth scroll animations on page elements
- Active navigation link highlighting
- Mobile menu toggle for navigation
- Scroll-to-top button for easy navigation
- Form validation and success notifications

### 4. **Professional Content**
- Executive summary and mission statement
- Detailed service descriptions and pricing
- Team expertise and certifications
- Financial projections and growth strategy

## Technologies Used

- **HTML5** - Semantic markup and form elements
- **CSS3** - Modern layouts with Grid, Flexbox, and animations
- **JavaScript (ES6+)** - Dynamic functionality and interactivity
- **GitHub** - Version control and collaborative development
- **GitHub Actions** - Automated testing and deployment

## Getting Started

### Prerequisites
- A modern web browser (Chrome, Firefox, Safari, Edge)
- Git for cloning the repository
- A text editor for modifications (VS Code recommended)

### Installation

```bash
# Clone the repository
git clone https://github.com/nakiachampion/ProfessionalPortfolio9Jun25.git

# Navigate to the xtech-website branch
cd ProfessionalPortfolio9Jun25
git checkout xtech-website

# Open in your browser
open xtech/index.html
# or
start xtech\index.html  # Windows
```

### Local Development

1. Open any HTML file in your browser to view the site
2. JavaScript features work immediately with no build process required
3. Modify CSS in `xtech/assets/css/style.css` for styling changes
4. Update product data in `xtech/assets/js/products.js`

## Pages

### **Homepage (index.html)**
- Hero section with compelling headline
- Featured UniFi products with dynamic rendering
- Service overview
- Call-to-action buttons

### **About Page (about.html)**
- Company background and mission
- Team member profiles with expertise
- Certifications and credentials
- Company values and culture

### **Services Page (services.html)**
- Complete service offerings
- Detailed pricing tables
- Service features and benefits
- Comparison tables

### **Contact Page (contact.html)**
- Contact form with validation
- Business location and hours
- FAQ section
- Multiple contact methods

### **Business Plan (plan.html)**
- Executive summary
- Market analysis
- Financial projections
- Growth strategy

## JavaScript Modules

### **main.js**
Core functionality including:
- Mobile menu toggle
- Smooth scrolling
- Active link highlighting
- Scroll animations (Intersection Observer API)
- Scroll-to-top button
- Form validation and handling

### **products.js**
Product management including:
- Product catalog (6 UniFi products)
- Filtering by category
- Search functionality
- Shopping cart (add, update, remove)
- Cart persistence with localStorage
- Notifications and user feedback

## Styling

The CSS follows modern best practices:
- CSS Variables for consistent theming
- Mobile-first responsive design
- Flexbox and CSS Grid layouts
- Smooth transitions and animations
- Accessibility-friendly color contrasts

## GitHub Actions Workflow

The `.github/workflows/deploy.yml` file includes:
- **Build Step**: Validates HTML, CSS, and JavaScript
- **Test Step**: Counts files and generates reports
- **Deploy Step**: Prepares for GitHub Pages deployment

Run manually or automatically on:
- Pushes to `xtech-website` or `main` branches
- Pull requests to `xtech-website`

## Browser Support

- Chrome/Edge 90+
- Firefox 88+
- Safari 14+
- Mobile browsers (iOS Safari, Chrome Android)

## Performance

- Lightweight HTML/CSS/JS with no external dependencies
- Images use placeholder service (can be replaced with actual images)
- Optimized for fast loading and smooth interactions
- Lazy loading for images in product catalog

## SEO Optimization

- Semantic HTML5 structure
- Meta tags and descriptions
- Mobile-responsive design
- Fast page load times
- Accessible navigation

## Future Enhancements

- [ ] Add real product images and videos
- [ ] Implement backend API for product data
- [ ] Add user authentication and accounts
- [ ] Integrate payment processing
- [ ] Add blog section with content management
- [ ] Implement analytics tracking
- [ ] Add multi-language support
- [ ] Create admin dashboard

## Contributing

1. Fork the repository
2. Create a feature branch (`git checkout -b feature/AmazingFeature`)
3. Commit changes (`git commit -m 'Add AmazingFeature'`)
4. Push to branch (`git push origin feature/AmazingFeature`)
5. Open a Pull Request

## License

This project is licensed under the MIT License - see the LICENSE file for details.

## Author

**Nakia Champion**
- GitHub: [@nakiachampion](https://github.com/nakiachampion)
- Portfolio: [Professional Portfolio](https://github.com/nakiachampion/ProfessionalPortfolio9Jun25)

## Support

For support, contact Xceptional Technologies or open an issue on GitHub.

## Acknowledgments

- Ubiquiti Networks for UniFi product ecosystem
- GitHub for version control and CI/CD capabilities
- The web development community for best practices and inspiration
