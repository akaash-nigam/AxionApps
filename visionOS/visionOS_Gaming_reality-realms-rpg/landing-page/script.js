// ===================================
// Smooth Scroll
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
            // Close mobile menu if open
            navMenu.classList.remove('active');
        }
    });
});

// ===================================
// Navbar Scroll Effect
// ===================================
const navbar = document.getElementById('navbar');
let lastScroll = 0;

window.addEventListener('scroll', () => {
    const currentScroll = window.pageYOffset;

    if (currentScroll > 100) {
        navbar.classList.add('scrolled');
    } else {
        navbar.classList.remove('scrolled');
    }

    lastScroll = currentScroll;
});

// ===================================
// Mobile Menu Toggle
// ===================================
const hamburger = document.getElementById('hamburger');
const navMenu = document.getElementById('nav-menu');

hamburger.addEventListener('click', () => {
    navMenu.classList.toggle('active');
    hamburger.classList.toggle('active');
});

// ===================================
// FAQ Accordion
// ===================================
const faqItems = document.querySelectorAll('.faq-item');

faqItems.forEach(item => {
    const question = item.querySelector('.faq-question');

    question.addEventListener('click', () => {
        const isActive = item.classList.contains('active');

        // Close all items
        faqItems.forEach(faq => faq.classList.remove('active'));

        // Toggle current item
        if (!isActive) {
            item.classList.add('active');
        }
    });
});

// ===================================
// Scroll Animations (AOS - Animate On Scroll)
// ===================================
const observerOptions = {
    threshold: 0.1,
    rootMargin: '0px 0px -100px 0px'
};

const observer = new IntersectionObserver((entries) => {
    entries.forEach(entry => {
        if (entry.isIntersecting) {
            entry.target.classList.add('aos-animate');
            // Optional: stop observing after animation
            // observer.unobserve(entry.target);
        }
    });
}, observerOptions);

// Observe all elements with data-aos attribute
document.querySelectorAll('[data-aos]').forEach(el => {
    observer.observe(el);
});

// ===================================
// Pricing Card Hover Effects
// ===================================
const pricingCards = document.querySelectorAll('.pricing-card');

pricingCards.forEach(card => {
    card.addEventListener('mouseenter', function() {
        this.style.transform = 'translateY(-10px) scale(1.02)';
    });

    card.addEventListener('mouseleave', function() {
        if (this.classList.contains('featured')) {
            this.style.transform = 'scale(1.05)';
        } else {
            this.style.transform = 'translateY(0) scale(1)';
        }
    });
});

// ===================================
// Class Card Interactions
// ===================================
const classCards = document.querySelectorAll('.class-card');

classCards.forEach(card => {
    card.addEventListener('click', function() {
        // Remove active class from all cards
        classCards.forEach(c => c.classList.remove('active-class'));

        // Add active class to clicked card
        this.classList.add('active-class');

        // Animate stat bars
        const statBars = this.querySelectorAll('.fill');
        statBars.forEach(bar => {
            const width = bar.style.width;
            bar.style.width = '0%';
            setTimeout(() => {
                bar.style.width = width;
            }, 100);
        });
    });
});

// ===================================
// Hero Stats Counter Animation
// ===================================
function animateCounter(element, target, duration = 2000) {
    const start = 0;
    const increment = target / (duration / 16); // 60 FPS
    let current = start;

    const timer = setInterval(() => {
        current += increment;
        if (current >= target) {
            element.textContent = formatNumber(target);
            clearInterval(timer);
        } else {
            element.textContent = formatNumber(Math.floor(current));
        }
    }, 16);
}

function formatNumber(num) {
    if (num >= 1000) {
        return (num / 1000).toFixed(0) + 'K+';
    }
    return num.toString();
}

// Trigger counter animation when hero section is in view
const heroStats = document.querySelector('.hero-stats');
if (heroStats) {
    const statsObserver = new IntersectionObserver((entries) => {
        entries.forEach(entry => {
            if (entry.isIntersecting) {
                const statValues = entry.target.querySelectorAll('.stat-value');
                statValues.forEach((stat, index) => {
                    if (index === 0) { // 100K+
                        animateCounter(stat, 100);
                    }
                    // Skip rating and infinity symbol
                });
                statsObserver.unobserve(entry.target);
            }
        });
    }, { threshold: 0.5 });

    statsObserver.observe(heroStats);
}

// ===================================
// Parallax Effect for Hero Background
// ===================================
window.addEventListener('scroll', () => {
    const scrolled = window.pageYOffset;
    const parallaxElements = document.querySelectorAll('.gradient-orb');

    parallaxElements.forEach((el, index) => {
        const speed = 0.5 + (index * 0.1);
        el.style.transform = `translateY(${scrolled * speed}px)`;
    });
});

// ===================================
// Feature Cards Stagger Animation
// ===================================
const featureCards = document.querySelectorAll('.feature-card');

const featureObserver = new IntersectionObserver((entries) => {
    entries.forEach((entry, index) => {
        if (entry.isIntersecting) {
            setTimeout(() => {
                entry.target.style.opacity = '1';
                entry.target.style.transform = 'translateY(0)';
            }, index * 100);
        }
    });
}, { threshold: 0.1 });

featureCards.forEach(card => {
    card.style.opacity = '0';
    card.style.transform = 'translateY(30px)';
    card.style.transition = 'opacity 0.6s ease, transform 0.6s ease';
    featureObserver.observe(card);
});

// ===================================
// Testimonial Cards Animation
// ===================================
const testimonialCards = document.querySelectorAll('.testimonial-card');

const testimonialObserver = new IntersectionObserver((entries) => {
    entries.forEach((entry, index) => {
        if (entry.isIntersecting) {
            setTimeout(() => {
                entry.target.style.opacity = '1';
                entry.target.style.transform = 'translateY(0) scale(1)';
            }, index * 150);
        }
    });
}, { threshold: 0.1 });

testimonialCards.forEach(card => {
    card.style.opacity = '0';
    card.style.transform = 'translateY(30px) scale(0.95)';
    card.style.transition = 'opacity 0.6s ease, transform 0.6s ease';
    testimonialObserver.observe(card);
});

// ===================================
// Loading Animation
// ===================================
window.addEventListener('load', () => {
    document.body.classList.add('loaded');

    // Animate hero content
    const heroContent = document.querySelector('.hero-content');
    if (heroContent) {
        heroContent.style.opacity = '0';
        heroContent.style.transform = 'translateY(30px)';

        setTimeout(() => {
            heroContent.style.transition = 'opacity 1s ease, transform 1s ease';
            heroContent.style.opacity = '1';
            heroContent.style.transform = 'translateY(0)';
        }, 100);
    }
});

// ===================================
// Button Ripple Effect
// ===================================
document.querySelectorAll('.btn').forEach(button => {
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

// Add ripple styles
const style = document.createElement('style');
style.textContent = `
    .btn {
        position: relative;
        overflow: hidden;
    }
    .ripple {
        position: absolute;
        border-radius: 50%;
        background: rgba(255, 255, 255, 0.6);
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
document.head.appendChild(style);

// ===================================
// Easter Egg: Konami Code
// ===================================
let konamiCode = ['ArrowUp', 'ArrowUp', 'ArrowDown', 'ArrowDown', 'ArrowLeft', 'ArrowRight', 'ArrowLeft', 'ArrowRight', 'b', 'a'];
let konamiIndex = 0;

document.addEventListener('keydown', (e) => {
    if (e.key === konamiCode[konamiIndex]) {
        konamiIndex++;
        if (konamiIndex === konamiCode.length) {
            activateEasterEgg();
            konamiIndex = 0;
        }
    } else {
        konamiIndex = 0;
    }
});

function activateEasterEgg() {
    // Add magical effects to the page
    document.body.style.animation = 'rainbow 5s linear infinite';

    const easterEggStyle = document.createElement('style');
    easterEggStyle.textContent = `
        @keyframes rainbow {
            0% { filter: hue-rotate(0deg); }
            100% { filter: hue-rotate(360deg); }
        }
    `;
    document.head.appendChild(easterEggStyle);

    // Show achievement notification
    const notification = document.createElement('div');
    notification.textContent = '🎮 Achievement Unlocked: Secret Guardian! 🎮';
    notification.style.cssText = `
        position: fixed;
        top: 100px;
        left: 50%;
        transform: translateX(-50%);
        background: linear-gradient(135deg, #8B5CF6, #06B6D4);
        color: white;
        padding: 1.5rem 3rem;
        border-radius: 1rem;
        font-weight: 700;
        font-size: 1.25rem;
        z-index: 10000;
        box-shadow: 0 20px 40px rgba(0,0,0,0.3);
        animation: slideDown 0.5s ease;
    `;
    document.body.appendChild(notification);

    setTimeout(() => {
        notification.style.animation = 'slideUp 0.5s ease';
        setTimeout(() => notification.remove(), 500);
        document.body.style.animation = '';
    }, 3000);
}

// Add slide animations for easter egg
const eggStyle = document.createElement('style');
eggStyle.textContent = `
    @keyframes slideDown {
        from {
            transform: translateX(-50%) translateY(-100px);
            opacity: 0;
        }
        to {
            transform: translateX(-50%) translateY(0);
            opacity: 1;
        }
    }
    @keyframes slideUp {
        from {
            transform: translateX(-50%) translateY(0);
            opacity: 1;
        }
        to {
            transform: translateX(-50%) translateY(-100px);
            opacity: 0;
        }
    }
`;
document.head.appendChild(eggStyle);

// ===================================
// Console Easter Egg
// ===================================
console.log('%c⚔️ Reality Realms RPG ⚔️', 'font-size: 24px; font-weight: bold; background: linear-gradient(135deg, #8B5CF6, #06B6D4); -webkit-background-clip: text; color: transparent;');
console.log('%cLooking for secrets, Guardian? 🔍', 'font-size: 16px; color: #8B5CF6;');
console.log('%cTry the Konami Code... ↑ ↑ ↓ ↓ ← → ← → B A', 'font-size: 14px; color: #06B6D4;');
console.log('%cInterested in joining our dev team? Email us at jobs@realityrealms.com', 'font-size: 12px; color: #CBD5E1;');

// ===================================
// Performance Monitoring
// ===================================
if ('PerformanceObserver' in window) {
    const perfObserver = new PerformanceObserver((list) => {
        for (const entry of list.getEntries()) {
            if (entry.loadTime > 3000) {
                console.warn('Slow resource detected:', entry.name);
            }
        }
    });
    perfObserver.observe({ entryTypes: ['resource', 'navigation'] });
}

// ===================================
// Accessibility: Focus Management
// ===================================
document.addEventListener('keydown', (e) => {
    if (e.key === 'Tab') {
        document.body.classList.add('keyboard-nav');
    }
});

document.addEventListener('mousedown', () => {
    document.body.classList.remove('keyboard-nav');
});

// Add focus styles
const focusStyle = document.createElement('style');
focusStyle.textContent = `
    body.keyboard-nav *:focus {
        outline: 3px solid #8B5CF6;
        outline-offset: 2px;
    }
`;
document.head.appendChild(focusStyle);

// ===================================
// Analytics Tracking (Placeholder)
// ===================================
function trackEvent(category, action, label) {
    // Replace with your analytics implementation
    console.log('Event tracked:', { category, action, label });
}

// Track button clicks
document.querySelectorAll('.btn').forEach(btn => {
    btn.addEventListener('click', function() {
        const text = this.textContent.trim();
        trackEvent('Button', 'Click', text);
    });
});

// Track section views
const sections = document.querySelectorAll('section[id]');
const sectionObserver = new IntersectionObserver((entries) => {
    entries.forEach(entry => {
        if (entry.isIntersecting) {
            trackEvent('Section', 'View', entry.target.id);
        }
    });
}, { threshold: 0.5 });

sections.forEach(section => sectionObserver.observe(section));

console.log('🎮 Reality Realms landing page loaded successfully!');
