/**
 * Culture Architecture System - Landing Page JavaScript
 * Handles interactivity, animations, and user interactions
 */

// ============================================
// MOBILE MENU TOGGLE
// ============================================

const mobileMenuToggle = document.querySelector('.mobile-menu-toggle');
const navLinks = document.querySelector('.nav-links');

if (mobileMenuToggle) {
    mobileMenuToggle.addEventListener('click', () => {
        mobileMenuToggle.classList.toggle('active');
        navLinks.classList.toggle('active');

        // Prevent body scroll when menu is open
        document.body.style.overflow = navLinks.classList.contains('active') ? 'hidden' : '';
    });

    // Close menu when clicking a link
    const navItems = navLinks.querySelectorAll('a');
    navItems.forEach(link => {
        link.addEventListener('click', () => {
            mobileMenuToggle.classList.remove('active');
            navLinks.classList.remove('active');
            document.body.style.overflow = '';
        });
    });

    // Close menu when clicking outside
    document.addEventListener('click', (e) => {
        if (!e.target.closest('.navbar') && navLinks.classList.contains('active')) {
            mobileMenuToggle.classList.remove('active');
            navLinks.classList.remove('active');
            document.body.style.overflow = '';
        }
    });
}

// ============================================
// NAVBAR SCROLL EFFECT
// ============================================

const navbar = document.querySelector('.navbar');
let lastScroll = 0;

window.addEventListener('scroll', () => {
    const currentScroll = window.pageYOffset;

    // Add/remove scrolled class
    if (currentScroll > 100) {
        navbar.classList.add('scrolled');
    } else {
        navbar.classList.remove('scrolled');
    }

    lastScroll = currentScroll;
});

// ============================================
// SMOOTH SCROLLING FOR ANCHOR LINKS
// ============================================

document.querySelectorAll('a[href^="#"]').forEach(anchor => {
    anchor.addEventListener('click', function (e) {
        const href = this.getAttribute('href');

        // Only prevent default if it's a valid anchor
        if (href !== '#' && document.querySelector(href)) {
            e.preventDefault();

            const target = document.querySelector(href);
            const navbarHeight = navbar.offsetHeight;
            const targetPosition = target.getBoundingClientRect().top + window.pageYOffset - navbarHeight;

            window.scrollTo({
                top: targetPosition,
                behavior: 'smooth'
            });
        }
    });
});

// ============================================
// INTERSECTION OBSERVER FOR SCROLL ANIMATIONS
// ============================================

const observerOptions = {
    threshold: 0.1,
    rootMargin: '0px 0px -50px 0px'
};

const observer = new IntersectionObserver((entries) => {
    entries.forEach(entry => {
        if (entry.isIntersecting) {
            entry.target.classList.add('fade-in-up');
            observer.unobserve(entry.target);
        }
    });
}, observerOptions);

// Observe elements for animation
const animateOnScroll = document.querySelectorAll(
    '.feature-card, .benefit-card, .testimonial-card, .pricing-card, .problem-stat, .timeline-step'
);

animateOnScroll.forEach(el => {
    observer.observe(el);
});

// ============================================
// STAT COUNTER ANIMATION
// ============================================

function animateCounter(element, target, duration = 2000) {
    const start = 0;
    const increment = target / (duration / 16); // 60fps
    let current = start;

    const timer = setInterval(() => {
        current += increment;
        if (current >= target) {
            element.textContent = target;
            clearInterval(timer);
        } else {
            element.textContent = Math.floor(current);
        }
    }, 16);
}

// Animate hero stats when they come into view
const heroStats = document.querySelectorAll('.stat-value');
const statsObserver = new IntersectionObserver((entries) => {
    entries.forEach(entry => {
        if (entry.isIntersecting) {
            const statValue = entry.target;
            const targetText = statValue.textContent;

            // Extract number from text like "3x", "85%", etc.
            const match = targetText.match(/\d+/);
            if (match) {
                const target = parseInt(match[0]);
                const suffix = targetText.replace(match[0], '');

                // Animate counter
                let current = 0;
                const increment = target / 60; // 60 frames for smooth animation
                const timer = setInterval(() => {
                    current += increment;
                    if (current >= target) {
                        statValue.textContent = target + suffix;
                        clearInterval(timer);
                    } else {
                        statValue.textContent = Math.floor(current) + suffix;
                    }
                }, 16);
            }

            statsObserver.unobserve(entry.target);
        }
    });
}, { threshold: 0.5 });

heroStats.forEach(stat => statsObserver.observe(stat));

// ============================================
// PROBLEM STAT COUNTER ANIMATION
// ============================================

const problemStats = document.querySelectorAll('.problem-stat-value');
const problemStatsObserver = new IntersectionObserver((entries) => {
    entries.forEach(entry => {
        if (entry.isIntersecting) {
            const statValue = entry.target;
            const targetText = statValue.textContent;

            // Extract number
            const match = targetText.match(/\d+/);
            if (match) {
                const target = parseInt(match[0]);
                const suffix = targetText.replace(match[0], '');

                let current = 0;
                const increment = target / 60;
                const timer = setInterval(() => {
                    current += increment;
                    if (current >= target) {
                        statValue.textContent = target + suffix;
                        clearInterval(timer);
                    } else {
                        statValue.textContent = Math.floor(current) + suffix;
                    }
                }, 16);
            }

            problemStatsObserver.unobserve(entry.target);
        }
    });
}, { threshold: 0.5 });

problemStats.forEach(stat => problemStatsObserver.observe(stat));

// ============================================
// PARALLAX EFFECT FOR GRADIENT ORBS
// ============================================

const gradientOrbs = document.querySelectorAll('.gradient-orb');

window.addEventListener('scroll', () => {
    const scrolled = window.pageYOffset;

    gradientOrbs.forEach((orb, index) => {
        const speed = 0.5 + (index * 0.1); // Different speeds for each orb
        orb.style.transform = `translateY(${scrolled * speed}px)`;
    });
});

// ============================================
// PRICING CARD HOVER EFFECT
// ============================================

const pricingCards = document.querySelectorAll('.pricing-card');

pricingCards.forEach(card => {
    card.addEventListener('mouseenter', function() {
        // Scale up slightly
        this.style.transform = 'translateY(-8px) scale(1.02)';
    });

    card.addEventListener('mouseleave', function() {
        // Return to normal, preserve featured card scale
        if (this.classList.contains('featured')) {
            this.style.transform = 'scale(1.05)';
        } else {
            this.style.transform = 'translateY(0) scale(1)';
        }
    });
});

// ============================================
// FEATURE CARD TILT EFFECT (3D)
// ============================================

const featureCards = document.querySelectorAll('.feature-card');

featureCards.forEach(card => {
    card.addEventListener('mousemove', function(e) {
        const rect = this.getBoundingClientRect();
        const x = e.clientX - rect.left;
        const y = e.clientY - rect.top;

        const centerX = rect.width / 2;
        const centerY = rect.height / 2;

        const rotateX = (y - centerY) / 10;
        const rotateY = (centerX - x) / 10;

        this.style.transform = `perspective(1000px) rotateX(${rotateX}deg) rotateY(${rotateY}deg) translateY(-8px)`;
    });

    card.addEventListener('mouseleave', function() {
        this.style.transform = 'perspective(1000px) rotateX(0) rotateY(0) translateY(0)';
    });
});

// ============================================
// CTA BUTTON RIPPLE EFFECT
// ============================================

const buttons = document.querySelectorAll('.btn-primary');

buttons.forEach(button => {
    button.addEventListener('click', function(e) {
        const ripple = document.createElement('span');
        const rect = this.getBoundingClientRect();

        const size = Math.max(rect.width, rect.height);
        const x = e.clientX - rect.left - size / 2;
        const y = e.clientY - rect.top - size / 2;

        ripple.style.width = ripple.style.height = size + 'px';
        ripple.style.left = x + 'px';
        ripple.style.top = y + 'px';
        ripple.classList.add('ripple');

        this.appendChild(ripple);

        setTimeout(() => {
            ripple.remove();
        }, 600);
    });
});

// Add ripple CSS dynamically
const rippleStyle = document.createElement('style');
rippleStyle.textContent = `
    .btn-primary {
        position: relative;
        overflow: hidden;
    }

    .ripple {
        position: absolute;
        border-radius: 50%;
        background: rgba(255, 255, 255, 0.3);
        transform: scale(0);
        animation: ripple-animation 0.6s ease-out;
        pointer-events: none;
    }

    @keyframes ripple-animation {
        to {
            transform: scale(4);
            opacity: 0;
        }
    }
`;
document.head.appendChild(rippleStyle);

// ============================================
// TESTIMONIAL CAROUSEL AUTO-ROTATE
// ============================================

const testimonialCards = document.querySelectorAll('.testimonial-card');
let currentTestimonial = 0;

function highlightTestimonial() {
    testimonialCards.forEach((card, index) => {
        if (index === currentTestimonial) {
            card.style.borderColor = 'var(--primary-purple)';
            card.style.boxShadow = '0 0 40px rgba(139, 92, 246, 0.4)';
        } else {
            card.style.borderColor = 'rgba(255, 255, 255, 0.1)';
            card.style.boxShadow = 'none';
        }
    });

    currentTestimonial = (currentTestimonial + 1) % testimonialCards.length;
}

// Start auto-rotation if testimonials exist
if (testimonialCards.length > 0) {
    setInterval(highlightTestimonial, 4000);
}

// ============================================
// FORM VALIDATION (for demo purposes)
// ============================================

const demoButtons = document.querySelectorAll('.btn-demo');

demoButtons.forEach(button => {
    button.addEventListener('click', function(e) {
        e.preventDefault();

        // In production, this would open a demo request modal or form
        // For now, show a simple alert
        showNotification('Demo request received! We\'ll contact you shortly.', 'success');
    });
});

// ============================================
// NOTIFICATION SYSTEM
// ============================================

function showNotification(message, type = 'info') {
    const notification = document.createElement('div');
    notification.className = `notification notification-${type}`;
    notification.textContent = message;

    // Add styles
    const notificationStyles = `
        position: fixed;
        top: 100px;
        right: 20px;
        padding: 1rem 1.5rem;
        background: ${type === 'success' ? 'var(--success-green)' : 'var(--primary-purple)'};
        color: white;
        border-radius: 8px;
        box-shadow: 0 4px 20px rgba(0, 0, 0, 0.3);
        z-index: 10000;
        animation: slideInRight 0.3s ease;
    `;

    notification.style.cssText = notificationStyles;
    document.body.appendChild(notification);

    // Auto-remove after 3 seconds
    setTimeout(() => {
        notification.style.animation = 'slideOutRight 0.3s ease';
        setTimeout(() => {
            notification.remove();
        }, 300);
    }, 3000);
}

// Add notification animations
const notificationStyle = document.createElement('style');
notificationStyle.textContent = `
    @keyframes slideInRight {
        from {
            transform: translateX(400px);
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
            transform: translateX(400px);
            opacity: 0;
        }
    }
`;
document.head.appendChild(notificationStyle);

// ============================================
// LAZY LOADING IMAGES (when added)
// ============================================

if ('IntersectionObserver' in window) {
    const imageObserver = new IntersectionObserver((entries, observer) => {
        entries.forEach(entry => {
            if (entry.isIntersecting) {
                const img = entry.target;
                img.src = img.dataset.src;
                img.classList.remove('lazy');
                imageObserver.unobserve(img);
            }
        });
    });

    const lazyImages = document.querySelectorAll('img.lazy');
    lazyImages.forEach(img => imageObserver.observe(img));
}

// ============================================
// EASTER EGG: KONAMI CODE
// ============================================

let konamiCode = [];
const konamiSequence = ['ArrowUp', 'ArrowUp', 'ArrowDown', 'ArrowDown', 'ArrowLeft', 'ArrowRight', 'ArrowLeft', 'ArrowRight', 'b', 'a'];

document.addEventListener('keydown', (e) => {
    konamiCode.push(e.key);
    konamiCode = konamiCode.slice(-10);

    if (konamiCode.join('') === konamiSequence.join('')) {
        // Easter egg: activate disco mode
        document.body.style.animation = 'disco 1s infinite';
        showNotification('🎉 Disco Mode Activated! Culture is fun!', 'success');

        setTimeout(() => {
            document.body.style.animation = '';
        }, 5000);
    }
});

const discoStyle = document.createElement('style');
discoStyle.textContent = `
    @keyframes disco {
        0% { filter: hue-rotate(0deg); }
        100% { filter: hue-rotate(360deg); }
    }
`;
document.head.appendChild(discoStyle);

// ============================================
// PERFORMANCE MONITORING
// ============================================

if ('PerformanceObserver' in window) {
    // Monitor for slow interactions
    const perfObserver = new PerformanceObserver((list) => {
        for (const entry of list.getEntries()) {
            // Log slow interactions (for debugging)
            if (entry.duration > 100) {
                console.warn('Slow interaction detected:', entry);
            }
        }
    });

    try {
        perfObserver.observe({ entryTypes: ['event'] });
    } catch (e) {
        // Some browsers don't support this yet
    }
}

// ============================================
// ACCESSIBILITY: KEYBOARD NAVIGATION
// ============================================

// Trap focus in mobile menu when open
const focusableElements = 'button, [href], input, select, textarea, [tabindex]:not([tabindex="-1"])';

document.addEventListener('keydown', (e) => {
    // Escape key closes mobile menu
    if (e.key === 'Escape' && navLinks.classList.contains('active')) {
        mobileMenuToggle.classList.remove('active');
        navLinks.classList.remove('active');
        document.body.style.overflow = '';
    }
});

// ============================================
// CONSOLE EASTER EGG
// ============================================

console.log('%c🚀 Culture Architecture System', 'font-size: 24px; font-weight: bold; background: linear-gradient(135deg, #8B5CF6, #3B82F6); -webkit-background-clip: text; color: transparent;');
console.log('%cInterested in how this works? We\'re hiring! Check out our careers page.', 'font-size: 14px; color: #8B5CF6;');
console.log('%cBuilt with ❤️ for transforming organizational culture', 'font-size: 12px; color: #6B6B85;');

// ============================================
// INITIALIZE
// ============================================

document.addEventListener('DOMContentLoaded', () => {
    console.log('Landing page initialized successfully');

    // Add loaded class to body for CSS animations
    document.body.classList.add('loaded');
});

// ============================================
// HANDLE PREFERS-REDUCED-MOTION
// ============================================

const prefersReducedMotion = window.matchMedia('(prefers-reduced-motion: reduce)');

if (prefersReducedMotion.matches) {
    // Disable heavy animations for users who prefer reduced motion
    document.querySelectorAll('.gradient-orb').forEach(orb => {
        orb.style.animation = 'none';
    });
}
