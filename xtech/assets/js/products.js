// UniFi Products Data
const unifiProducts = [
  {
    id: 1,
    name: 'UniFi 6 Access Point',
    category: 'Wireless',
    price: '$199',
    specs: ['WiFi 6 (802.11ax)', '1.2 Gbps', 'PoE+', '2x2 MIMO'],
    image: 'https://via.placeholder.com/300x200?text=UniFi+6+AP',
    description: 'High-performance WiFi 6 access point for demanding environments'
  },
  {
    id: 2,
    name: 'UniFi Security Gateway Pro',
    category: 'Security',
    price: '$449',
    specs: ['4 Gbps throughput', 'IDS/IPS', '100+ VPN users', 'DPI'],
    image: 'https://via.placeholder.com/300x200?text=USG+Pro',
    description: 'Enterprise-grade threat protection and VPN gateway'
  },
  {
    id: 3,
    name: 'UniFi Switch 48',
    category: 'Switching',
    price: '$599',
    specs: ['48 Gigabit ports', 'Layer 2/3', 'PoE support', '176 Gbps throughput'],
    image: 'https://via.placeholder.com/300x200?text=UniFi+Switch',
    description: 'Managed switch with advanced routing capabilities'
  },
  {
    id: 4,
    name: 'UniFi Dream Machine',
    category: 'Network Control',
    price: '$349',
    specs: ['All-in-one', 'Unifi OS', '2TB storage', '16GB RAM'],
    image: 'https://via.placeholder.com/300x200?text=Dream+Machine',
    description: 'Unified network management and protection'
  },
  {
    id: 5,
    name: 'UniFi Video Camera G4 Turret',
    category: 'Surveillance',
    price: '$299',
    specs: ['4K video', 'Smart detection', 'PoE powered', 'IR night vision'],
    image: 'https://via.placeholder.com/300x200?text=G4+Turret',
    description: 'Professional surveillance with AI analytics'
  },
  {
    id: 6,
    name: 'UniFi 6E Mesh Node',
    category: 'Wireless',
    price: '$249',
    specs: ['WiFi 6E', 'Tri-band', 'Mesh networking', 'PoE support'],
    image: 'https://via.placeholder.com/300x200?text=WiFi+6E',
    description: 'Next-generation mesh access point with WiFi 6E support'
  }
];

// Function to render products dynamically
function renderProducts(containerId, products = unifiProducts) {
  const container = document.getElementById(containerId);
  if (!container) return;
  
  container.innerHTML = products.map(product => `
    <div class="product-card" data-id="${product.id}">
      <img src="${product.image}" alt="${product.name}" class="product-image">
      <div class="product-info">
        <h3>${product.name}</h3>
        <p class="category">${product.category}</p>
        <p class="description">${product.description}</p>
        <div class="specs">
          ${product.specs.map(spec => `<span class="spec">${spec}</span>`).join('')}
        </div>
        <div class="product-footer">
          <span class="price">${product.price}</span>
          <button class="btn-add-cart" onclick="addToCart(${product.id})">Add to Cart</button>
        </div>
      </div>
    </div>
  `).join('');
}

// Filter products by category
function filterByCategory(category) {
  const filtered = category === 'all' 
    ? unifiProducts 
    : unifiProducts.filter(p => p.category === category);
  return filtered;
}

// Search products
function searchProducts(query) {
  return unifiProducts.filter(p => 
    p.name.toLowerCase().includes(query.toLowerCase()) ||
    p.description.toLowerCase().includes(query.toLowerCase())
  );
}

// Shopping cart functionality
let cart = JSON.parse(localStorage.getItem('xtechCart')) || [];

function addToCart(productId) {
  const product = unifiProducts.find(p => p.id === productId);
  if (!product) return;
  
  const cartItem = cart.find(item => item.id === productId);
  if (cartItem) {
    cartItem.quantity += 1;
  } else {
    cart.push({ ...product, quantity: 1 });
  }
  
  saveCart();
  showCartNotification(product.name);
}

function removeFromCart(productId) {
  cart = cart.filter(item => item.id !== productId);
  saveCart();
}

function updateCartQuantity(productId, quantity) {
  const item = cart.find(p => p.id === productId);
  if (item) {
    item.quantity = Math.max(0, quantity);
    if (item.quantity === 0) removeFromCart(productId);
  }
  saveCart();
}

function saveCart() {
  localStorage.setItem('xtechCart', JSON.stringify(cart));
  updateCartDisplay();
}

function updateCartDisplay() {
  const cartCount = document.querySelector('.cart-count');
  if (cartCount) {
    const total = cart.reduce((sum, item) => sum + item.quantity, 0);
    cartCount.textContent = total;
  }
}

function showCartNotification(productName) {
  const notification = document.createElement('div');
  notification.className = 'cart-notification';
  notification.textContent = `${productName} added to cart!`;
  notification.style.cssText = `
    position: fixed;
    top: 20px;
    right: 20px;
    background: #28a745;
    color: white;
    padding: 15px 20px;
    border-radius: 4px;
    z-index: 1000;
    animation: slideIn 0.3s ease-in-out;
  `;
  document.body.appendChild(notification);
  
  setTimeout(() => {
    notification.style.animation = 'slideOut 0.3s ease-in-out';
    setTimeout(() => notification.remove(), 300);
  }, 2000);
}

// Initialize cart on page load
document.addEventListener('DOMContentLoaded', () => {
  updateCartDisplay();
});

console.log('Products module loaded:', unifiProducts.length, 'products available');
