/* ============================================
   Spatial Code Reviewer - Landing Page JavaScript
   Interactive features and animations
   ============================================ */

(function() {
  'use strict';

  /* ============================================
     Mobile Menu Toggle
     ============================================ */
  const mobileMenuBtn = document.querySelector('.mobile-menu-btn');
  const navLinks = document.querySelector('.nav-links');
  const body = document.body;

  if (mobileMenuBtn && navLinks) {
    mobileMenuBtn.addEventListener('click', function() {
      navLinks.classList.toggle('active');
      body.style.overflow = navLinks.classList.contains('active') ? 'hidden' : '';

      // Update button icon
      const icon = this.textContent;
      this.textContent = icon === '☰' ? '✕' : '☰';
    });

    // Close mobile menu when clicking on a link
    const mobileLinks = navLinks.querySelectorAll('a');
    mobileLinks.forEach(link => {
      link.addEventListener('click', function() {
        navLinks.classList.remove('active');
        body.style.overflow = '';
        if (mobileMenuBtn) {
          mobileMenuBtn.textContent = '☰';
        }
      });
    });

    // Close mobile menu when clicking outside
    document.addEventListener('click', function(event) {
      if (!event.target.closest('.nav-links') &&
          !event.target.closest('.mobile-menu-btn') &&
          navLinks.classList.contains('active')) {
        navLinks.classList.remove('active');
        body.style.overflow = '';
        if (mobileMenuBtn) {
          mobileMenuBtn.textContent = '☰';
        }
      }
    });
  }

  /* ============================================
     Smooth Scroll Navigation
     ============================================ */
  const smoothScrollLinks = document.querySelectorAll('a[href^="#"]');

  smoothScrollLinks.forEach(link => {
    link.addEventListener('click', function(e) {
      const href = this.getAttribute('href');

      // Skip if href is just "#"
      if (href === '#') {
        e.preventDefault();
        return;
      }

      const targetId = href.substring(1);
      const targetElement = document.getElementById(targetId);

      if (targetElement) {
        e.preventDefault();

        // Calculate offset for fixed nav
        const navHeight = document.querySelector('.nav')?.offsetHeight || 0;
        const targetPosition = targetElement.offsetTop - navHeight - 20;

        window.scrollTo({
          top: targetPosition,
          behavior: 'smooth'
        });

        // Update URL without jumping
        history.pushState(null, null, href);
      }
    });
  });

  /* ============================================
     Navbar Scroll Effect
     ============================================ */
  const nav = document.querySelector('.nav');
  let lastScrollTop = 0;

  function handleNavScroll() {
    const scrollTop = window.pageYOffset || document.documentElement.scrollTop;

    // Add/remove scrolled class
    if (scrollTop > 50) {
      nav?.classList.add('scrolled');
    } else {
      nav?.classList.remove('scrolled');
    }

    lastScrollTop = scrollTop;
  }

  window.addEventListener('scroll', handleNavScroll, { passive: true });

  /* ============================================
     FAQ Accordion
     ============================================ */
  const faqItems = document.querySelectorAll('.faq-item');

  faqItems.forEach(item => {
    const question = item.querySelector('.faq-question');

    if (question) {
      question.addEventListener('click', function() {
        const isActive = item.classList.contains('active');

        // Close all other items (optional - comment out for multi-open)
        faqItems.forEach(otherItem => {
          if (otherItem !== item) {
            otherItem.classList.remove('active');
          }
        });

        // Toggle current item
        item.classList.toggle('active');
      });
    }
  });

  /* ============================================
     Scroll-Triggered Animations
     ============================================ */
  const observerOptions = {
    threshold: 0.1,
    rootMargin: '0px 0px -50px 0px'
  };

  const observer = new IntersectionObserver(function(entries) {
    entries.forEach(entry => {
      if (entry.isIntersecting) {
        entry.target.classList.add('visible');
        // Optional: Stop observing after animation
        observer.unobserve(entry.target);
      }
    });
  }, observerOptions);

  // Observe all elements with fade-in class
  const fadeElements = document.querySelectorAll('.fade-in');
  fadeElements.forEach(el => observer.observe(el));

  // Add fade-in class to sections for progressive reveal
  const animateSections = document.querySelectorAll(
    '.feature-card, .step, .testimonial-card, .pricing-card'
  );

  animateSections.forEach((el, index) => {
    el.classList.add('fade-in');
    // Stagger animation delay
    el.style.transitionDelay = `${index * 0.1}s`;
    observer.observe(el);
  });

  /* ============================================
     3D Cube Animation Enhancement
     ============================================ */
  const cube = document.querySelector('.cube');
  let isMouseOver = false;
  let mouseX = 0;
  let mouseY = 0;

  if (cube) {
    const heroVisual = document.querySelector('.hero-visual');

    if (heroVisual) {
      heroVisual.addEventListener('mouseenter', function() {
        isMouseOver = true;
        cube.style.animationPlayState = 'paused';
      });

      heroVisual.addEventListener('mouseleave', function() {
        isMouseOver = false;
        cube.style.animationPlayState = 'running';
      });

      heroVisual.addEventListener('mousemove', function(e) {
        if (!isMouseOver) return;

        const rect = this.getBoundingClientRect();
        const centerX = rect.left + rect.width / 2;
        const centerY = rect.top + rect.height / 2;

        mouseX = (e.clientX - centerX) / (rect.width / 2);
        mouseY = (e.clientY - centerY) / (rect.height / 2);

        const rotateX = mouseY * 30;
        const rotateY = mouseX * 30;

        cube.style.transform = `rotateX(${rotateX}deg) rotateY(${rotateY}deg)`;
      });
    }
  }

  /* ============================================
     Stats Counter Animation
     ============================================ */
  function animateCounter(element, target, duration = 2000) {
    const start = 0;
    const increment = target / (duration / 16);
    let current = start;

    const timer = setInterval(function() {
      current += increment;
      if (current >= target) {
        current = target;
        clearInterval(timer);
      }

      // Format number with commas
      element.textContent = Math.floor(current).toLocaleString();
    }, 16);
  }

  // Observe stats and trigger counter when visible
  const statNumbers = document.querySelectorAll('.stat-number');
  const statsObserver = new IntersectionObserver(function(entries) {
    entries.forEach(entry => {
      if (entry.isIntersecting) {
        const target = parseInt(entry.target.dataset.count || 0);
        if (target > 0) {
          animateCounter(entry.target, target);
          statsObserver.unobserve(entry.target);
        }
      }
    });
  }, { threshold: 0.5 });

  statNumbers.forEach(stat => {
    // Store original value as data attribute
    const text = stat.textContent;
    const number = parseInt(text.replace(/[^0-9]/g, ''));
    stat.dataset.count = number;
    stat.textContent = '0';
    statsObserver.observe(stat);
  });

  /* ============================================
     Form Handling (if forms are added later)
     ============================================ */
  const forms = document.querySelectorAll('form');

  forms.forEach(form => {
    form.addEventListener('submit', function(e) {
      e.preventDefault();

      // Get form data
      const formData = new FormData(form);
      const data = Object.fromEntries(formData.entries());

      console.log('Form submitted:', data);

      // Show success message (customize as needed)
      alert('Thank you for your submission! We will be in touch soon.');

      // Reset form
      form.reset();
    });
  });

  /* ============================================
     Download Button Tracking
     ============================================ */
  const downloadButtons = document.querySelectorAll('a[href="#download"], .btn-primary');

  downloadButtons.forEach(button => {
    button.addEventListener('click', function(e) {
      // Track download click (integrate with analytics if needed)
      console.log('Download button clicked');

      // Show coming soon message for now
      if (this.getAttribute('href') === '#download') {
        e.preventDefault();
        showNotification('Coming soon! Spatial Code Reviewer will be available on the App Store.');
      }
    });
  });

  /* ============================================
     Notification System
     ============================================ */
  function showNotification(message, duration = 3000) {
    // Remove any existing notifications
    const existingNotification = document.querySelector('.notification');
    if (existingNotification) {
      existingNotification.remove();
    }

    // Create notification element
    const notification = document.createElement('div');
    notification.className = 'notification';
    notification.textContent = message;

    // Add styles dynamically
    Object.assign(notification.style, {
      position: 'fixed',
      bottom: '20px',
      right: '20px',
      background: 'linear-gradient(135deg, #7c3aed 0%, #3b82f6 100%)',
      color: '#fff',
      padding: '1rem 1.5rem',
      borderRadius: '0.5rem',
      boxShadow: '0 4px 16px rgba(0, 0, 0, 0.3)',
      zIndex: '9999',
      maxWidth: '400px',
      animation: 'slideInRight 0.3s ease',
      fontWeight: '500'
    });

    document.body.appendChild(notification);

    // Remove after duration
    setTimeout(function() {
      notification.style.animation = 'slideOutRight 0.3s ease';
      setTimeout(function() {
        notification.remove();
      }, 300);
    }, duration);
  }

  // Add notification animations
  const style = document.createElement('style');
  style.textContent = `
    @keyframes slideInRight {
      from {
        transform: translateX(100%);
        opacity: 0;
      }
      to {
        transform: translateX(0);
        opacity: 1;
      }
    }
    @keyframes slideOutRight {
      from {
        transform: translateX(0);
        opacity: 1;
      }
      to {
        transform: translateX(100%);
        opacity: 0;
      }
    }
  `;
  document.head.appendChild(style);

  /* ============================================
     Pricing Card Interaction
     ============================================ */
  const pricingButtons = document.querySelectorAll('.pricing-card .btn');

  pricingButtons.forEach(button => {
    button.addEventListener('click', function(e) {
      e.preventDefault();
      const tier = this.closest('.pricing-card').querySelector('.pricing-tier').textContent;
      console.log(`Selected pricing tier: ${tier}`);
      showNotification(`You selected the ${tier} plan. Sign up coming soon!`);
    });
  });

  /* ============================================
     Keyboard Navigation Enhancement
     ============================================ */
  document.addEventListener('keydown', function(e) {
    // Escape key closes mobile menu
    if (e.key === 'Escape' && navLinks?.classList.contains('active')) {
      navLinks.classList.remove('active');
      body.style.overflow = '';
      if (mobileMenuBtn) {
        mobileMenuBtn.textContent = '☰';
      }
    }
  });

  /* ============================================
     Lazy Loading Images (for future image additions)
     ============================================ */
  if ('IntersectionObserver' in window) {
    const imageObserver = new IntersectionObserver(function(entries) {
      entries.forEach(entry => {
        if (entry.isIntersecting) {
          const img = entry.target;
          const src = img.dataset.src;

          if (src) {
            img.src = src;
            img.removeAttribute('data-src');
            imageObserver.unobserve(img);
          }
        }
      });
    });

    const lazyImages = document.querySelectorAll('img[data-src]');
    lazyImages.forEach(img => imageObserver.observe(img));
  }

  /* ============================================
     Performance Monitoring
     ============================================ */
  window.addEventListener('load', function() {
    // Log performance metrics
    if (window.performance) {
      const perfData = window.performance.timing;
      const pageLoadTime = perfData.loadEventEnd - perfData.navigationStart;
      console.log(`Page loaded in ${pageLoadTime}ms`);
    }
  });

  /* ============================================
     Social Share Functionality (future feature)
     ============================================ */
  function shareOnSocial(platform) {
    const url = encodeURIComponent(window.location.href);
    const title = encodeURIComponent(document.title);
    const text = encodeURIComponent('Check out Spatial Code Reviewer - Code review reimagined in 3D for visionOS!');

    const shareUrls = {
      twitter: `https://twitter.com/intent/tweet?url=${url}&text=${text}`,
      facebook: `https://www.facebook.com/sharer/sharer.php?u=${url}`,
      linkedin: `https://www.linkedin.com/sharing/share-offsite/?url=${url}`,
      reddit: `https://reddit.com/submit?url=${url}&title=${title}`
    };

    if (shareUrls[platform]) {
      window.open(shareUrls[platform], '_blank', 'width=600,height=400');
    }
  }

  // Make share function globally accessible
  window.shareOnSocial = shareOnSocial;

  /* ============================================
     Dark Mode Toggle (optional future feature)
     ============================================ */
  function initDarkMode() {
    const darkModeToggle = document.querySelector('.dark-mode-toggle');

    if (darkModeToggle) {
      // Check for saved preference
      const savedMode = localStorage.getItem('darkMode');
      if (savedMode === 'enabled') {
        document.body.classList.add('dark-mode');
      }

      darkModeToggle.addEventListener('click', function() {
        document.body.classList.toggle('dark-mode');

        // Save preference
        if (document.body.classList.contains('dark-mode')) {
          localStorage.setItem('darkMode', 'enabled');
        } else {
          localStorage.setItem('darkMode', 'disabled');
        }
      });
    }
  }

  initDarkMode();

  /* ============================================
     Email Validation Helper
     ============================================ */
  function validateEmail(email) {
    const re = /^[^\s@]+@[^\s@]+\.[^\s@]+$/;
    return re.test(email);
  }

  // Add validation to email inputs
  const emailInputs = document.querySelectorAll('input[type="email"]');
  emailInputs.forEach(input => {
    input.addEventListener('blur', function() {
      if (this.value && !validateEmail(this.value)) {
        this.setCustomValidity('Please enter a valid email address');
        this.reportValidity();
      } else {
        this.setCustomValidity('');
      }
    });
  });

  /* ============================================
     Scroll Progress Indicator (optional)
     ============================================ */
  function updateScrollProgress() {
    const progressBar = document.querySelector('.scroll-progress');
    if (!progressBar) return;

    const windowHeight = window.innerHeight;
    const documentHeight = document.documentElement.scrollHeight;
    const scrollTop = window.pageYOffset || document.documentElement.scrollTop;
    const trackLength = documentHeight - windowHeight;
    const progress = (scrollTop / trackLength) * 100;

    progressBar.style.width = `${Math.min(progress, 100)}%`;
  }

  window.addEventListener('scroll', updateScrollProgress, { passive: true });

  /* ============================================
     Console Easter Egg
     ============================================ */
  console.log('%c🚀 Spatial Code Reviewer', 'font-size: 24px; font-weight: bold; color: #7c3aed;');
  console.log('%cInterested in joining our team? Visit https://github.com/spatial-code-reviewer', 'font-size: 14px; color: #60a5fa;');
  console.log('%cBuilt with ❤️ for visionOS', 'font-size: 12px; color: #9ca3af;');

  /* ============================================
     Initialize on DOM Ready
     ============================================ */
  console.log('✅ Spatial Code Reviewer landing page initialized');

})();

/* ============================================
   Service Worker Registration (for PWA - future)
   ============================================ */
if ('serviceWorker' in navigator) {
  window.addEventListener('load', function() {
    // Uncomment when service worker is ready
    // navigator.serviceWorker.register('/sw.js')
    //   .then(reg => console.log('Service Worker registered'))
    //   .catch(err => console.log('Service Worker registration failed'));
  });
}
