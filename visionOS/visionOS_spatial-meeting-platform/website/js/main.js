/**
 * Spatial Meeting Platform - Landing Page JavaScript
 * Interactive features and animations
 */

// ===============================================
// UTILITY FUNCTIONS
// ===============================================

/**
 * Throttle function to limit execution rate
 */
function throttle(func, wait) {
  let timeout;
  return function executedFunction(...args) {
    const later = () => {
      clearTimeout(timeout);
      func(...args);
    };
    clearTimeout(timeout);
    timeout = setTimeout(later, wait);
  };
}

/**
 * Debounce function to delay execution
 */
function debounce(func, wait) {
  let timeout;
  return function executedFunction(...args) {
    const later = () => {
      clearTimeout(timeout);
      func(...args);
    };
    clearTimeout(timeout);
    timeout = setTimeout(later, wait);
  };
}

// ===============================================
// NAVIGATION
// ===============================================

class Navigation {
  constructor() {
    this.nav = document.querySelector('nav');
    this.mobileMenuBtn = document.querySelector('.mobile-menu-btn');
    this.navLinks = document.querySelector('.nav-links');
    this.lastScroll = 0;

    this.init();
  }

  init() {
    // Handle scroll effects
    window.addEventListener('scroll', throttle(() => this.handleScroll(), 100));

    // Handle mobile menu toggle
    if (this.mobileMenuBtn) {
      this.mobileMenuBtn.addEventListener('click', () => this.toggleMobileMenu());
    }

    // Smooth scroll for anchor links
    document.querySelectorAll('a[href^="#"]').forEach(anchor => {
      anchor.addEventListener('click', (e) => this.smoothScroll(e));
    });
  }

  handleScroll() {
    const currentScroll = window.pageYOffset;

    // Add/remove scrolled class
    if (currentScroll > 50) {
      this.nav.classList.add('scrolled');
    } else {
      this.nav.classList.remove('scrolled');
    }

    // Auto-hide navbar on scroll down (optional)
    if (currentScroll > this.lastScroll && currentScroll > 500) {
      this.nav.style.transform = 'translateY(-100%)';
    } else {
      this.nav.style.transform = 'translateY(0)';
    }

    this.lastScroll = currentScroll;
  }

  toggleMobileMenu() {
    this.navLinks.classList.toggle('active');
    this.mobileMenuBtn.classList.toggle('active');
  }

  smoothScroll(e) {
    const href = e.currentTarget.getAttribute('href');

    if (href.startsWith('#')) {
      e.preventDefault();
      const targetId = href.substring(1);
      const target = document.getElementById(targetId);

      if (target) {
        const offsetTop = target.offsetTop - 80; // Account for fixed nav
        window.scrollTo({
          top: offsetTop,
          behavior: 'smooth'
        });

        // Close mobile menu if open
        if (this.navLinks.classList.contains('active')) {
          this.toggleMobileMenu();
        }
      }
    }
  }
}

// ===============================================
// SCROLL ANIMATIONS
// ===============================================

class ScrollAnimations {
  constructor() {
    this.observerOptions = {
      threshold: 0.1,
      rootMargin: '0px 0px -100px 0px'
    };

    this.init();
  }

  init() {
    // Create intersection observer
    this.observer = new IntersectionObserver(
      (entries) => this.handleIntersection(entries),
      this.observerOptions
    );

    // Observe all sections and cards
    const elements = document.querySelectorAll(
      '.feature-card, .benefit-item, .use-case, .pricing-card, .testimonial, .section-title, .section-subtitle'
    );

    elements.forEach((el, index) => {
      // Add staggered animation delay
      el.style.animationDelay = `${index * 0.1}s`;
      this.observer.observe(el);
    });
  }

  handleIntersection(entries) {
    entries.forEach(entry => {
      if (entry.isIntersecting) {
        entry.target.classList.add('animate-on-scroll');
        // Unobserve after animation to prevent re-triggering
        this.observer.unobserve(entry.target);
      }
    });
  }
}

// ===============================================
// STATISTICS COUNTER
// ===============================================

class CounterAnimation {
  constructor() {
    this.counters = document.querySelectorAll('.stat-value, .metric-value');
    this.hasAnimated = new Set();
    this.init();
  }

  init() {
    const observer = new IntersectionObserver(
      (entries) => this.handleIntersection(entries),
      { threshold: 0.5 }
    );

    this.counters.forEach(counter => observer.observe(counter));
  }

  handleIntersection(entries) {
    entries.forEach(entry => {
      if (entry.isIntersecting && !this.hasAnimated.has(entry.target)) {
        this.animateCounter(entry.target);
        this.hasAnimated.add(entry.target);
      }
    });
  }

  animateCounter(element) {
    const text = element.textContent;
    const hasPercent = text.includes('%');
    const hasDollar = text.includes('$');
    const hasPlus = text.includes('+');
    const hasX = text.includes('x');

    // Extract number
    const numberMatch = text.match(/[\d.]+/);
    if (!numberMatch) return;

    const targetValue = parseFloat(numberMatch[0]);
    const duration = 2000; // 2 seconds
    const steps = 60;
    const stepValue = targetValue / steps;
    const stepDuration = duration / steps;

    let currentValue = 0;
    const timer = setInterval(() => {
      currentValue += stepValue;

      if (currentValue >= targetValue) {
        currentValue = targetValue;
        clearInterval(timer);
      }

      let displayValue = currentValue.toFixed(targetValue % 1 === 0 ? 0 : 1);

      // Add formatting
      if (hasDollar) displayValue = '$' + displayValue;
      if (hasPercent) displayValue += '%';
      if (hasPlus) displayValue += '+';
      if (hasX) displayValue += 'x';
      if (text.includes('M')) displayValue += 'M';

      element.textContent = displayValue;
    }, stepDuration);
  }
}

// ===============================================
// FORM HANDLING
// ===============================================

class FormHandler {
  constructor() {
    this.forms = document.querySelectorAll('form');
    this.init();
  }

  init() {
    this.forms.forEach(form => {
      form.addEventListener('submit', (e) => this.handleSubmit(e));
    });
  }

  handleSubmit(e) {
    e.preventDefault();
    const form = e.target;
    const emailInput = form.querySelector('input[type="email"]');

    if (emailInput && this.validateEmail(emailInput.value)) {
      this.showSuccess(form);
      // In production, send to backend
      console.log('Form submitted:', emailInput.value);
      form.reset();
    } else {
      this.showError(emailInput, 'Please enter a valid email address');
    }
  }

  validateEmail(email) {
    const re = /^[^\s@]+@[^\s@]+\.[^\s@]+$/;
    return re.test(email);
  }

  showSuccess(form) {
    const button = form.querySelector('button[type="submit"]');
    const originalText = button.textContent;

    button.textContent = '✓ Success!';
    button.style.background = 'linear-gradient(135deg, #10B981 0%, #059669 100%)';

    setTimeout(() => {
      button.textContent = originalText;
      button.style.background = '';
    }, 3000);
  }

  showError(input, message) {
    input.style.borderColor = '#EF4444';

    // Remove error styling after 3 seconds
    setTimeout(() => {
      input.style.borderColor = '';
    }, 3000);
  }
}

// ===============================================
// PRICING TOGGLE (if implementing monthly/annual)
// ===============================================

class PricingToggle {
  constructor() {
    this.toggle = document.querySelector('.pricing-toggle');
    if (this.toggle) {
      this.init();
    }
  }

  init() {
    this.toggle.addEventListener('change', (e) => {
      const isAnnual = e.target.checked;
      this.updatePricing(isAnnual);
    });
  }

  updatePricing(isAnnual) {
    const prices = document.querySelectorAll('.price');
    prices.forEach(price => {
      const monthlyPrice = parseFloat(price.dataset.monthly);
      const annualPrice = parseFloat(price.dataset.annual);

      if (monthlyPrice && annualPrice) {
        const displayPrice = isAnnual ? annualPrice : monthlyPrice;
        price.textContent = `$${displayPrice}`;
      }
    });
  }
}

// ===============================================
// USE CASE CARD EFFECTS
// ===============================================

class UseCaseEffects {
  constructor() {
    this.cards = document.querySelectorAll('.use-case');
    this.init();
  }

  init() {
    this.cards.forEach(card => {
      card.addEventListener('mouseenter', (e) => this.handleHover(e));
      card.addEventListener('mousemove', (e) => this.handleMouseMove(e));
      card.addEventListener('mouseleave', (e) => this.handleLeave(e));
    });
  }

  handleHover(e) {
    const card = e.currentTarget;
    card.style.transition = 'transform 0.1s ease';
  }

  handleMouseMove(e) {
    const card = e.currentTarget;
    const rect = card.getBoundingClientRect();
    const x = e.clientX - rect.left;
    const y = e.clientY - rect.top;

    const centerX = rect.width / 2;
    const centerY = rect.height / 2;

    const rotateX = (y - centerY) / 20;
    const rotateY = (centerX - x) / 20;

    card.style.transform = `perspective(1000px) rotateX(${rotateX}deg) rotateY(${rotateY}deg) scale(1.05)`;
  }

  handleLeave(e) {
    const card = e.currentTarget;
    card.style.transition = 'transform 0.5s ease';
    card.style.transform = 'perspective(1000px) rotateX(0) rotateY(0) scale(1)';
  }
}

// ===============================================
// SCROLL PROGRESS INDICATOR
// ===============================================

class ScrollProgress {
  constructor() {
    this.createProgressBar();
    this.init();
  }

  createProgressBar() {
    const progressBar = document.createElement('div');
    progressBar.className = 'scroll-progress';
    progressBar.style.cssText = `
      position: fixed;
      top: 0;
      left: 0;
      height: 3px;
      background: linear-gradient(90deg, #0066FF 0%, #7B61FF 50%, #00D4FF 100%);
      z-index: 9999;
      transform-origin: left;
      transform: scaleX(0);
      transition: transform 0.1s ease;
    `;
    document.body.appendChild(progressBar);
    this.progressBar = progressBar;
  }

  init() {
    window.addEventListener('scroll', throttle(() => this.updateProgress(), 10));
  }

  updateProgress() {
    const scrollTop = window.pageYOffset;
    const docHeight = document.documentElement.scrollHeight - window.innerHeight;
    const scrollPercent = scrollTop / docHeight;

    this.progressBar.style.transform = `scaleX(${scrollPercent})`;
  }
}

// ===============================================
// PARALLAX EFFECTS
// ===============================================

class ParallaxEffects {
  constructor() {
    this.elements = document.querySelectorAll('.hero-visual, .mockup-screen');
    this.init();
  }

  init() {
    window.addEventListener('scroll', throttle(() => this.handleScroll(), 10));
  }

  handleScroll() {
    const scrolled = window.pageYOffset;

    this.elements.forEach(el => {
      const speed = el.dataset.speed || 0.5;
      const yPos = -(scrolled * speed);
      el.style.transform = `translateY(${yPos}px)`;
    });
  }
}

// ===============================================
// LAZY LOADING IMAGES
// ===============================================

class LazyLoader {
  constructor() {
    this.images = document.querySelectorAll('img[data-src]');
    this.init();
  }

  init() {
    const options = {
      root: null,
      threshold: 0.1,
      rootMargin: '50px'
    };

    const observer = new IntersectionObserver((entries) => {
      entries.forEach(entry => {
        if (entry.isIntersecting) {
          this.loadImage(entry.target);
          observer.unobserve(entry.target);
        }
      });
    }, options);

    this.images.forEach(img => observer.observe(img));
  }

  loadImage(img) {
    const src = img.dataset.src;
    if (!src) return;

    img.src = src;
    img.classList.add('loaded');
  }
}

// ===============================================
// COOKIE CONSENT (Optional)
// ===============================================

class CookieConsent {
  constructor() {
    this.cookieName = 'spatial-meeting-consent';
    this.init();
  }

  init() {
    if (!this.hasConsent()) {
      this.showBanner();
    }
  }

  hasConsent() {
    return localStorage.getItem(this.cookieName) === 'true';
  }

  showBanner() {
    const banner = document.createElement('div');
    banner.className = 'cookie-banner';
    banner.innerHTML = `
      <div class="cookie-content">
        <p>We use cookies to enhance your experience. By continuing to visit this site you agree to our use of cookies.</p>
        <button class="btn btn-primary btn-sm" onclick="window.cookieConsent.acceptCookies()">Accept</button>
      </div>
    `;
    banner.style.cssText = `
      position: fixed;
      bottom: 0;
      left: 0;
      right: 0;
      background: rgba(17, 24, 39, 0.95);
      color: white;
      padding: 1.5rem;
      z-index: 9998;
      backdrop-filter: blur(10px);
      border-top: 1px solid rgba(255, 255, 255, 0.1);
    `;

    document.body.appendChild(banner);
  }

  acceptCookies() {
    localStorage.setItem(this.cookieName, 'true');
    const banner = document.querySelector('.cookie-banner');
    if (banner) {
      banner.style.animation = 'slideDown 0.3s ease forwards';
      setTimeout(() => banner.remove(), 300);
    }
  }
}

// ===============================================
// VIDEO MODAL (for demo videos)
// ===============================================

class VideoModal {
  constructor() {
    this.videoButtons = document.querySelectorAll('[data-video]');
    this.init();
  }

  init() {
    this.videoButtons.forEach(btn => {
      btn.addEventListener('click', (e) => {
        e.preventDefault();
        const videoUrl = btn.dataset.video;
        this.showModal(videoUrl);
      });
    });
  }

  showModal(videoUrl) {
    const modal = document.createElement('div');
    modal.className = 'video-modal';
    modal.innerHTML = `
      <div class="modal-overlay" onclick="this.parentElement.remove()"></div>
      <div class="modal-content">
        <button class="modal-close" onclick="this.closest('.video-modal').remove()">×</button>
        <iframe
          src="${videoUrl}"
          frameborder="0"
          allow="accelerometer; autoplay; clipboard-write; encrypted-media; gyroscope; picture-in-picture"
          allowfullscreen>
        </iframe>
      </div>
    `;

    // Add styles
    modal.style.cssText = `
      position: fixed;
      top: 0;
      left: 0;
      right: 0;
      bottom: 0;
      z-index: 10000;
      display: flex;
      align-items: center;
      justify-content: center;
      padding: 2rem;
    `;

    document.body.appendChild(modal);
    document.body.style.overflow = 'hidden';
  }
}

// ===============================================
// FEATURE COMPARISON TOOLTIP
// ===============================================

class FeatureTooltips {
  constructor() {
    this.features = document.querySelectorAll('[data-tooltip]');
    this.init();
  }

  init() {
    this.features.forEach(feature => {
      feature.addEventListener('mouseenter', (e) => this.showTooltip(e));
      feature.addEventListener('mouseleave', () => this.hideTooltip());
    });
  }

  showTooltip(e) {
    const text = e.currentTarget.dataset.tooltip;
    const tooltip = document.createElement('div');
    tooltip.className = 'tooltip';
    tooltip.textContent = text;
    tooltip.style.cssText = `
      position: absolute;
      background: rgba(17, 24, 39, 0.95);
      color: white;
      padding: 0.5rem 1rem;
      border-radius: 0.5rem;
      font-size: 0.875rem;
      z-index: 1000;
      pointer-events: none;
      white-space: nowrap;
    `;

    document.body.appendChild(tooltip);

    const rect = e.currentTarget.getBoundingClientRect();
    tooltip.style.top = `${rect.top - tooltip.offsetHeight - 10}px`;
    tooltip.style.left = `${rect.left + (rect.width / 2) - (tooltip.offsetWidth / 2)}px`;

    this.currentTooltip = tooltip;
  }

  hideTooltip() {
    if (this.currentTooltip) {
      this.currentTooltip.remove();
      this.currentTooltip = null;
    }
  }
}

// ===============================================
// INITIALIZE ALL COMPONENTS
// ===============================================

document.addEventListener('DOMContentLoaded', () => {
  // Core functionality
  new Navigation();
  new ScrollAnimations();
  new CounterAnimation();
  new FormHandler();

  // Enhanced features
  new ScrollProgress();
  new UseCaseEffects();
  new LazyLoader();

  // Optional features
  // new PricingToggle();
  // new ParallaxEffects();
  // new CookieConsent();
  // new VideoModal();
  // new FeatureTooltips();

  // Make cookie consent globally accessible
  window.cookieConsent = new CookieConsent();

  console.log('🚀 Spatial Meeting Platform landing page initialized');
});

// ===============================================
// PERFORMANCE MONITORING (Optional)
// ===============================================

if ('PerformanceObserver' in window) {
  const perfObserver = new PerformanceObserver((list) => {
    for (const entry of list.getEntries()) {
      // Log performance metrics
      console.log(`⚡ ${entry.name}: ${entry.duration.toFixed(2)}ms`);
    }
  });

  perfObserver.observe({ entryTypes: ['measure', 'navigation'] });
}

// ===============================================
// EXPORT FOR MODULE USAGE (if needed)
// ===============================================

if (typeof module !== 'undefined' && module.exports) {
  module.exports = {
    Navigation,
    ScrollAnimations,
    CounterAnimation,
    FormHandler,
    PricingToggle,
    UseCaseEffects,
    ScrollProgress,
    ParallaxEffects,
    LazyLoader,
    CookieConsent,
    VideoModal,
    FeatureTooltips
  };
}
