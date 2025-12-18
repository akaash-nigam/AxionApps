/**
 * Spatial CRM Landing Page JavaScript
 * Handles interactivity, animations, and form submissions
 */

// ===================================
// Smooth Scrolling
// ===================================
document.querySelectorAll('a[href^="#"]').forEach(anchor => {
    anchor.addEventListener('click', function (e) {
        e.preventDefault();
        const target = document.querySelector(this.getAttribute('href'));
        if (target) {
            target.scrollIntoView({
                behavior: 'smooth',
                block: 'start'
            });
        }
    });
});

// ===================================
// Navbar Scroll Effect
// ===================================
const navbar = document.querySelector('.navbar');
let lastScroll = 0;

window.addEventListener('scroll', () => {
    const currentScroll = window.pageYOffset;

    if (currentScroll > 50) {
        navbar.classList.add('scrolled');
    } else {
        navbar.classList.remove('scrolled');
    }

    lastScroll = currentScroll;
});

// ===================================
// Mobile Menu Toggle
// ===================================
const mobileMenuToggle = document.querySelector('.mobile-menu-toggle');
const navMenu = document.querySelector('.nav-menu');
const navCta = document.querySelector('.nav-cta');

if (mobileMenuToggle) {
    mobileMenuToggle.addEventListener('click', () => {
        mobileMenuToggle.classList.toggle('active');
        navMenu.classList.toggle('active');
        navCta.classList.toggle('active');

        // Animate hamburger icon
        const spans = mobileMenuToggle.querySelectorAll('span');
        if (mobileMenuToggle.classList.contains('active')) {
            spans[0].style.transform = 'rotate(45deg) translateY(8px)';
            spans[1].style.opacity = '0';
            spans[2].style.transform = 'rotate(-45deg) translateY(-8px)';
        } else {
            spans[0].style.transform = '';
            spans[1].style.opacity = '';
            spans[2].style.transform = '';
        }
    });
}

// ===================================
// Scroll Reveal Animation
// ===================================
const observerOptions = {
    threshold: 0.1,
    rootMargin: '0px 0px -100px 0px'
};

const observer = new IntersectionObserver((entries) => {
    entries.forEach(entry => {
        if (entry.isIntersecting) {
            entry.target.classList.add('revealed');
        }
    });
}, observerOptions);

// Observe all sections for reveal animation
document.querySelectorAll('section').forEach(section => {
    section.classList.add('scroll-reveal');
    observer.observe(section);
});

// Observe individual cards
document.querySelectorAll('.problem-card, .feature-card, .roi-card, .testimonial-card, .pricing-card').forEach(card => {
    card.classList.add('scroll-reveal');
    observer.observe(card);
});

// ===================================
// Contact Form Handling
// ===================================
const contactForm = document.getElementById('contactForm');

if (contactForm) {
    contactForm.addEventListener('submit', async (e) => {
        e.preventDefault();

        const formData = new FormData(contactForm);
        const data = Object.fromEntries(formData);

        // Get form values
        const name = contactForm.querySelector('input[type="text"]').value;
        const email = contactForm.querySelector('input[type="email"]').value;

        // Show loading state
        const submitButton = contactForm.querySelector('button[type="submit"]');
        const originalText = submitButton.textContent;
        submitButton.textContent = 'Submitting...';
        submitButton.disabled = true;

        try {
            // Simulate API call (replace with actual endpoint)
            await new Promise(resolve => setTimeout(resolve, 1500));

            // Log to console (in production, send to actual backend)
            console.log('Form submission:', { name, email, ...data });

            // Show success message
            showNotification('Success! We\'ll be in touch soon.', 'success');

            // Reset form
            contactForm.reset();

        } catch (error) {
            console.error('Form submission error:', error);
            showNotification('Oops! Something went wrong. Please try again.', 'error');

        } finally {
            // Restore button state
            submitButton.textContent = originalText;
            submitButton.disabled = false;
        }
    });
}

// ===================================
// Notification System
// ===================================
function showNotification(message, type = 'info') {
    // Create notification element
    const notification = document.createElement('div');
    notification.className = `notification notification-${type}`;
    notification.innerHTML = `
        <div class="notification-content">
            <span class="notification-icon">${type === 'success' ? '✓' : '!'}</span>
            <span class="notification-message">${message}</span>
        </div>
    `;

    // Add styles dynamically
    notification.style.cssText = `
        position: fixed;
        top: 100px;
        right: 20px;
        background: ${type === 'success' ? '#10B981' : '#EF4444'};
        color: white;
        padding: 16px 24px;
        border-radius: 12px;
        box-shadow: 0 10px 25px rgba(0, 0, 0, 0.2);
        z-index: 10000;
        animation: slideInRight 0.3s ease-out;
    `;

    document.body.appendChild(notification);

    // Auto remove after 5 seconds
    setTimeout(() => {
        notification.style.animation = 'slideOutRight 0.3s ease-in';
        setTimeout(() => {
            document.body.removeChild(notification);
        }, 300);
    }, 5000);

    // Allow manual close
    notification.addEventListener('click', () => {
        document.body.removeChild(notification);
    });
}

// Add notification animations to CSS dynamically
const styleSheet = document.createElement('style');
styleSheet.textContent = `
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

    .notification {
        cursor: pointer;
    }

    .notification-content {
        display: flex;
        align-items: center;
        gap: 12px;
    }

    .notification-icon {
        font-size: 1.5rem;
        font-weight: 800;
    }
`;
document.head.appendChild(styleSheet);

// ===================================
// Video Placeholder Click Handler
// ===================================
const videoPlaceholder = document.querySelector('.video-placeholder');
if (videoPlaceholder) {
    videoPlaceholder.addEventListener('click', () => {
        // In production, this would load the actual video
        showNotification('Demo video coming soon! Request beta access to see it live.', 'info');
    });
}

// ===================================
// Interactive Stats Counter
// ===================================
function animateValue(element, start, end, duration, suffix = '') {
    let startTimestamp = null;
    const step = (timestamp) => {
        if (!startTimestamp) startTimestamp = timestamp;
        const progress = Math.min((timestamp - startTimestamp) / duration, 1);
        const value = Math.floor(progress * (end - start) + start);
        element.textContent = value + suffix;
        if (progress < 1) {
            window.requestAnimationFrame(step);
        }
    };
    window.requestAnimationFrame(step);
}

// Animate stats when they come into view
const statsObserver = new IntersectionObserver((entries) => {
    entries.forEach(entry => {
        if (entry.isIntersecting && !entry.target.dataset.animated) {
            entry.target.dataset.animated = 'true';
            const text = entry.target.textContent.trim();

            if (text.includes('%')) {
                const value = parseInt(text);
                animateValue(entry.target, 0, value, 1500, '%');
            } else if (text.includes('x')) {
                const value = parseInt(text);
                animateValue(entry.target, 0, value, 1500, 'x');
            } else if (text.includes('$')) {
                const value = parseInt(text.replace(/[^0-9]/g, ''));
                entry.target.textContent = '$' + value.toLocaleString() + 'M';
            }
        }
    });
}, { threshold: 0.5 });

document.querySelectorAll('.stat-number, .roi-number').forEach(stat => {
    statsObserver.observe(stat);
});

// ===================================
// Parallax Effect for Hero Background
// ===================================
window.addEventListener('scroll', () => {
    const scrolled = window.pageYOffset;
    const heroBackground = document.querySelector('.hero-background');
    if (heroBackground && scrolled < window.innerHeight) {
        heroBackground.style.transform = `translateY(${scrolled * 0.5}px)`;
    }
});

// ===================================
// Add Floating Animation to Particles
// ===================================
const floatingParticles = document.querySelector('.floating-particles');
if (floatingParticles) {
    // Create additional particles
    for (let i = 0; i < 20; i++) {
        const particle = document.createElement('div');
        particle.style.cssText = `
            position: absolute;
            width: ${Math.random() * 10 + 5}px;
            height: ${Math.random() * 10 + 5}px;
            background: radial-gradient(circle, rgba(102, 126, 234, 0.3), transparent);
            border-radius: 50%;
            left: ${Math.random() * 100}%;
            top: ${Math.random() * 100}%;
            animation: float ${Math.random() * 10 + 10}s ease-in-out infinite;
            animation-delay: ${Math.random() * 5}s;
        `;
        floatingParticles.appendChild(particle);
    }
}

// ===================================
// Pricing Toggle (if needed for monthly/annual)
// ===================================
const pricingToggle = document.querySelector('.pricing-toggle');
if (pricingToggle) {
    pricingToggle.addEventListener('change', (e) => {
        const isAnnual = e.target.checked;
        document.querySelectorAll('.price-amount').forEach(price => {
            const monthlyPrice = parseInt(price.dataset.monthly);
            const annualPrice = monthlyPrice * 10; // 2 months free
            price.textContent = isAnnual ? annualPrice : monthlyPrice;
        });
    });
}

// ===================================
// Lazy Loading Images
// ===================================
if ('IntersectionObserver' in window) {
    const imageObserver = new IntersectionObserver((entries) => {
        entries.forEach(entry => {
            if (entry.isIntersecting) {
                const img = entry.target;
                img.src = img.dataset.src;
                img.classList.add('loaded');
                imageObserver.unobserve(img);
            }
        });
    });

    document.querySelectorAll('img[data-src]').forEach(img => {
        imageObserver.observe(img);
    });
}

// ===================================
// Track Engagement Events (for analytics)
// ===================================
function trackEvent(category, action, label) {
    // In production, send to analytics (GA, Mixpanel, etc.)
    console.log('Event:', { category, action, label });

    // Example: Google Analytics
    if (typeof gtag !== 'undefined') {
        gtag('event', action, {
            'event_category': category,
            'event_label': label
        });
    }
}

// Track CTA clicks
document.querySelectorAll('.btn-primary, .btn-large').forEach(button => {
    button.addEventListener('click', (e) => {
        const text = e.target.textContent.trim();
        trackEvent('CTA', 'click', text);
    });
});

// Track demo video clicks
if (videoPlaceholder) {
    videoPlaceholder.addEventListener('click', () => {
        trackEvent('Engagement', 'play_demo', 'Demo Video');
    });
}

// Track scroll depth
let maxScroll = 0;
window.addEventListener('scroll', () => {
    const scrollPercent = (window.scrollY / (document.body.scrollHeight - window.innerHeight)) * 100;
    if (scrollPercent > maxScroll) {
        maxScroll = scrollPercent;
        if (maxScroll > 25 && maxScroll < 30) {
            trackEvent('Engagement', 'scroll_depth', '25%');
        } else if (maxScroll > 50 && maxScroll < 55) {
            trackEvent('Engagement', 'scroll_depth', '50%');
        } else if (maxScroll > 75 && maxScroll < 80) {
            trackEvent('Engagement', 'scroll_depth', '75%');
        } else if (maxScroll > 90) {
            trackEvent('Engagement', 'scroll_depth', '100%');
        }
    }
});

// ===================================
// Initialize Everything on Load
// ===================================
document.addEventListener('DOMContentLoaded', () => {
    console.log('🌌 Spatial CRM Landing Page Loaded');

    // Add fade-in animation to hero
    const heroContent = document.querySelector('.hero-content');
    if (heroContent) {
        heroContent.style.opacity = '0';
        setTimeout(() => {
            heroContent.style.transition = 'opacity 1s ease-out';
            heroContent.style.opacity = '1';
        }, 100);
    }

    // Pre-load important resources
    // This could include fonts, critical images, etc.
});

// ===================================
// Easter Egg - Konami Code
// ===================================
let konamiCode = [];
const konamiSequence = [38, 38, 40, 40, 37, 39, 37, 39, 66, 65]; // ↑↑↓↓←→←→BA

document.addEventListener('keydown', (e) => {
    konamiCode.push(e.keyCode);
    konamiCode = konamiCode.slice(-10);

    if (konamiCode.join('') === konamiSequence.join('')) {
        showNotification('🎉 You found the secret! Extra 10% off for being awesome!', 'success');
        trackEvent('Easter Egg', 'konami_code', 'activated');
    }
});

// ===================================
// Export for testing
// ===================================
if (typeof module !== 'undefined' && module.exports) {
    module.exports = {
        showNotification,
        trackEvent,
        animateValue
    };
}
