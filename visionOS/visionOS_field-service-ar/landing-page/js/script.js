/**
 * Field Service AR Landing Page Scripts
 */

// ==========================================================================
// Smooth Scrolling for Navigation Links
// ==========================================================================

document.querySelectorAll('a[href^="#"]').forEach(anchor => {
    anchor.addEventListener('click', function (e) {
        e.preventDefault();
        const target = document.querySelector(this.getAttribute('href'));
        if (target) {
            const offsetTop = target.offsetTop - 80; // Account for fixed navbar
            window.scrollTo({
                top: offsetTop,
                behavior: 'smooth'
            });
        }
    });
});

// ==========================================================================
// Navbar Scroll Effect
// ==========================================================================

let lastScroll = 0;
const navbar = document.querySelector('.navbar');

window.addEventListener('scroll', () => {
    const currentScroll = window.pageYOffset;

    if (currentScroll <= 0) {
        navbar.style.boxShadow = 'none';
    } else {
        navbar.style.boxShadow = '0 2px 10px rgba(0, 0, 0, 0.1)';
    }

    lastScroll = currentScroll;
});

// ==========================================================================
// Mobile Menu Toggle
// ==========================================================================

const mobileMenuToggle = document.querySelector('.mobile-menu-toggle');
const navMenu = document.querySelector('.nav-menu');

if (mobileMenuToggle) {
    mobileMenuToggle.addEventListener('click', () => {
        navMenu.classList.toggle('active');
        mobileMenuToggle.classList.toggle('active');
    });

    // Close mobile menu when clicking outside
    document.addEventListener('click', (e) => {
        if (!mobileMenuToggle.contains(e.target) && !navMenu.contains(e.target)) {
            navMenu.classList.remove('active');
            mobileMenuToggle.classList.remove('active');
        }
    });

    // Close mobile menu when clicking a link
    navMenu.querySelectorAll('a').forEach(link => {
        link.addEventListener('click', () => {
            navMenu.classList.remove('active');
            mobileMenuToggle.classList.remove('active');
        });
    });
}

// ==========================================================================
// Scroll Animations
// ==========================================================================

const observerOptions = {
    threshold: 0.15,
    rootMargin: '0px 0px -100px 0px'
};

const observer = new IntersectionObserver((entries) => {
    entries.forEach(entry => {
        if (entry.isIntersecting) {
            entry.target.classList.add('animate-in');
            observer.unobserve(entry.target);
        }
    });
}, observerOptions);

// Observe all feature cards, benefit cards, and pricing cards
const animatedElements = document.querySelectorAll(
    '.feature-card, .benefit-card, .pricing-card, .demo-content, .contact-content'
);

animatedElements.forEach(el => {
    el.style.opacity = '0';
    el.style.transform = 'translateY(30px)';
    el.style.transition = 'opacity 0.6s ease, transform 0.6s ease';
    observer.observe(el);
});

// Add class when element is in view
const style = document.createElement('style');
style.textContent = `
    .animate-in {
        opacity: 1 !important;
        transform: translateY(0) !important;
    }
`;
document.head.appendChild(style);

// ==========================================================================
// Contact Form Handling
// ==========================================================================

const contactForm = document.getElementById('contactForm');

if (contactForm) {
    contactForm.addEventListener('submit', async (e) => {
        e.preventDefault();

        const submitButton = contactForm.querySelector('button[type="submit"]');
        const originalText = submitButton.textContent;

        // Disable button and show loading state
        submitButton.disabled = true;
        submitButton.textContent = 'Sending...';

        // Get form data
        const formData = new FormData(contactForm);
        const data = Object.fromEntries(formData.entries());

        try {
            // Simulate API call (replace with actual endpoint)
            await new Promise(resolve => setTimeout(resolve, 1500));

            console.log('Form submitted:', data);

            // Show success message
            showNotification('Thank you! We\'ll be in touch soon.', 'success');

            // Reset form
            contactForm.reset();
        } catch (error) {
            console.error('Error submitting form:', error);
            showNotification('Sorry, something went wrong. Please try again.', 'error');
        } finally {
            // Re-enable button
            submitButton.disabled = false;
            submitButton.textContent = originalText;
        }
    });
}

// ==========================================================================
// Notification System
// ==========================================================================

function showNotification(message, type = 'info') {
    const notification = document.createElement('div');
    notification.className = `notification notification-${type}`;
    notification.textContent = message;

    notification.style.cssText = `
        position: fixed;
        top: 100px;
        right: 20px;
        padding: 1rem 1.5rem;
        background: ${type === 'success' ? '#34C759' : type === 'error' ? '#FF3B30' : '#007AFF'};
        color: white;
        border-radius: 0.75rem;
        box-shadow: 0 10px 25px rgba(0, 0, 0, 0.2);
        z-index: 10000;
        animation: slideIn 0.3s ease;
        font-weight: 600;
    `;

    document.body.appendChild(notification);

    setTimeout(() => {
        notification.style.animation = 'slideOut 0.3s ease';
        setTimeout(() => {
            document.body.removeChild(notification);
        }, 300);
    }, 3000);
}

// Add notification animations
const notificationStyle = document.createElement('style');
notificationStyle.textContent = `
    @keyframes slideIn {
        from {
            transform: translateX(400px);
            opacity: 0;
        }
        to {
            transform: translateX(0);
            opacity: 1;
        }
    }

    @keyframes slideOut {
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

// ==========================================================================
// Stats Counter Animation
// ==========================================================================

function animateCounter(element, target, suffix = '') {
    let current = 0;
    const increment = target / 50; // 50 steps
    const duration = 2000; // 2 seconds
    const stepTime = duration / 50;

    const counter = setInterval(() => {
        current += increment;
        if (current >= target) {
            element.textContent = target + suffix;
            clearInterval(counter);
        } else {
            element.textContent = Math.floor(current) + suffix;
        }
    }, stepTime);
}

// Animate stats when they come into view
const statsObserver = new IntersectionObserver((entries) => {
    entries.forEach(entry => {
        if (entry.isIntersecting) {
            const statValue = entry.target.querySelector('.stat-value');
            const text = statValue.textContent;
            const number = parseInt(text);
            const suffix = text.replace(/[0-9]/g, '');

            if (!isNaN(number)) {
                statValue.textContent = '0' + suffix;
                animateCounter(statValue, number, suffix);
            }

            statsObserver.unobserve(entry.target);
        }
    });
}, { threshold: 0.5 });

document.querySelectorAll('.hero-stats .stat').forEach(stat => {
    statsObserver.observe(stat);
});

// Animate benefit metrics
const benefitObserver = new IntersectionObserver((entries) => {
    entries.forEach(entry => {
        if (entry.isIntersecting) {
            const metric = entry.target.querySelector('.benefit-metric');
            const text = metric.textContent;
            const number = parseInt(text);
            const suffix = text.replace(/[0-9]/g, '');

            if (!isNaN(number)) {
                metric.textContent = '0' + suffix;
                animateCounter(metric, number, suffix);
            }

            benefitObserver.unobserve(entry.target);
        }
    });
}, { threshold: 0.5 });

document.querySelectorAll('.benefit-card').forEach(card => {
    benefitObserver.observe(card);
});

// ==========================================================================
// Demo Video Player (Placeholder)
// ==========================================================================

const videoPlaceholder = document.querySelector('.video-placeholder');

if (videoPlaceholder) {
    videoPlaceholder.addEventListener('click', () => {
        // In a real implementation, this would open a video modal
        showNotification('Video demo coming soon!', 'info');
    });
}

// ==========================================================================
// Parallax Effect for Hero Orbs
// ==========================================================================

window.addEventListener('scroll', () => {
    const scrolled = window.pageYOffset;
    const orbs = document.querySelectorAll('.gradient-orb');

    orbs.forEach((orb, index) => {
        const speed = 0.1 + (index * 0.05);
        orb.style.transform = `translateY(${scrolled * speed}px)`;
    });
});

// ==========================================================================
// Floating Cards Animation
// ==========================================================================

function animateFloatingCards() {
    const cards = document.querySelectorAll('.floating-card');

    cards.forEach((card, index) => {
        const randomDelay = Math.random() * 2;
        const randomDuration = 3 + Math.random() * 2;

        card.style.animation = `cardFloat ${randomDuration}s ease-in-out infinite`;
        card.style.animationDelay = `${randomDelay}s`;
    });
}

// Start animations when page loads
window.addEventListener('load', () => {
    animateFloatingCards();
});

// ==========================================================================
// Feature Cards Stagger Animation
// ==========================================================================

const featureCards = document.querySelectorAll('.feature-card');
featureCards.forEach((card, index) => {
    card.style.transitionDelay = `${index * 0.1}s`;
});

const benefitCards = document.querySelectorAll('.benefit-card');
benefitCards.forEach((card, index) => {
    card.style.transitionDelay = `${index * 0.1}s`;
});

// ==========================================================================
// Pricing Card Hover Effect
// ==========================================================================

const pricingCards = document.querySelectorAll('.pricing-card');

pricingCards.forEach(card => {
    card.addEventListener('mouseenter', function() {
        this.style.transform = card.classList.contains('featured')
            ? 'scale(1.05) translateY(-8px)'
            : 'translateY(-8px)';
    });

    card.addEventListener('mouseleave', function() {
        this.style.transform = card.classList.contains('featured')
            ? 'scale(1.05)'
            : 'translateY(0)';
    });
});

// ==========================================================================
// Page Load Performance Monitoring
// ==========================================================================

window.addEventListener('load', () => {
    // Measure and log page load time
    const perfData = window.performance.timing;
    const pageLoadTime = perfData.loadEventEnd - perfData.navigationStart;

    console.log(`Page loaded in ${pageLoadTime}ms`);

    // Add loaded class to body for any load-dependent animations
    document.body.classList.add('loaded');
});

// ==========================================================================
// Utility Functions
// ==========================================================================

// Debounce function for performance
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

// Throttle function for scroll events
function throttle(func, limit) {
    let inThrottle;
    return function() {
        const args = arguments;
        const context = this;
        if (!inThrottle) {
            func.apply(context, args);
            inThrottle = true;
            setTimeout(() => inThrottle = false, limit);
        }
    };
}

// ==========================================================================
// Console Easter Egg
// ==========================================================================

console.log(
    '%c🚀 Field Service AR Assistant',
    'font-size: 20px; font-weight: bold; color: #007AFF;'
);
console.log(
    '%cBuilt for Apple Vision Pro | visionOS 2.0+',
    'font-size: 12px; color: #6E6E73;'
);
console.log(
    '%cInterested in joining our team? Contact careers@fieldservicear.com',
    'font-size: 12px; color: #34C759;'
);
