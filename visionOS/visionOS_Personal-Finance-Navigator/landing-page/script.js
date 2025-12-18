// Personal Finance Navigator - Landing Page JavaScript
// Interactive functionality and animations

// ==================== //
// Mobile Menu Toggle
// ==================== //

const mobileMenuToggle = document.querySelector('.mobile-menu-toggle');
const navLinks = document.querySelector('.nav-links');

if (mobileMenuToggle && navLinks) {
    mobileMenuToggle.addEventListener('click', () => {
        navLinks.classList.toggle('active');

        // Update icon
        const icon = mobileMenuToggle.textContent;
        mobileMenuToggle.textContent = icon === '☰' ? '✕' : '☰';
    });

    // Close menu when clicking on a link
    const navLinksItems = navLinks.querySelectorAll('a');
    navLinksItems.forEach(link => {
        link.addEventListener('click', () => {
            navLinks.classList.remove('active');
            mobileMenuToggle.textContent = '☰';
        });
    });

    // Close menu when clicking outside
    document.addEventListener('click', (e) => {
        if (!e.target.closest('.navbar')) {
            navLinks.classList.remove('active');
            mobileMenuToggle.textContent = '☰';
        }
    });
}

// ==================== //
// Navbar Scroll Behavior
// ==================== //

const navbar = document.querySelector('.navbar');
let lastScroll = 0;

window.addEventListener('scroll', () => {
    const currentScroll = window.pageYOffset;

    // Add/remove scrolled class for styling
    if (currentScroll > 50) {
        navbar.classList.add('scrolled');
    } else {
        navbar.classList.remove('scrolled');
    }

    lastScroll = currentScroll;
});

// ==================== //
// Smooth Scrolling
// ==================== //

// Smooth scroll for anchor links
document.querySelectorAll('a[href^="#"]').forEach(anchor => {
    anchor.addEventListener('click', function (e) {
        const href = this.getAttribute('href');

        // Skip empty anchors
        if (href === '#') return;

        e.preventDefault();

        const target = document.querySelector(href);
        if (target) {
            const navbarHeight = navbar.offsetHeight;
            const targetPosition = target.offsetTop - navbarHeight;

            window.scrollTo({
                top: targetPosition,
                behavior: 'smooth'
            });
        }
    });
});

// ==================== //
// FAQ Accordion
// ==================== //

const faqQuestions = document.querySelectorAll('.faq-question');

faqQuestions.forEach(question => {
    question.addEventListener('click', () => {
        const faqItem = question.parentElement;
        const isActive = faqItem.classList.contains('active');

        // Close all other FAQ items
        document.querySelectorAll('.faq-item').forEach(item => {
            if (item !== faqItem) {
                item.classList.remove('active');
            }
        });

        // Toggle current FAQ item
        faqItem.classList.toggle('active');
    });
});

// ==================== //
// Intersection Observer for Animations
// ==================== //

// Create observer for fade-in animations
const observerOptions = {
    threshold: 0.15,
    rootMargin: '0px 0px -50px 0px'
};

const observer = new IntersectionObserver((entries) => {
    entries.forEach(entry => {
        if (entry.isIntersecting) {
            entry.target.classList.add('fade-in');
            // Optionally unobserve after animation
            observer.unobserve(entry.target);
        }
    });
}, observerOptions);

// Observe elements for animation
const animateOnScroll = document.querySelectorAll(
    '.feature-card, .step, .pricing-card, .faq-item, .section-header'
);

animateOnScroll.forEach(element => {
    element.style.opacity = '0';
    observer.observe(element);
});

// ==================== //
// Staggered Animation for Feature Cards
// ==================== //

const featureCards = document.querySelectorAll('.feature-card');
const featureObserver = new IntersectionObserver((entries) => {
    entries.forEach((entry, index) => {
        if (entry.isIntersecting) {
            setTimeout(() => {
                entry.target.style.opacity = '1';
                entry.target.classList.add('slide-up');
            }, index * 100); // Stagger by 100ms
            featureObserver.unobserve(entry.target);
        }
    });
}, observerOptions);

featureCards.forEach(card => {
    card.style.opacity = '0';
    featureObserver.observe(card);
});

// ==================== //
// Counter Animation for Hero Stats
// ==================== //

function animateCounter(element, target, duration = 2000) {
    const start = 0;
    const increment = target / (duration / 16); // 60fps
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
        return (num / 1000).toFixed(1) + 'K+';
    }
    return num.toString();
}

// Observe hero stats for counter animation
const heroStats = document.querySelectorAll('.stat-number');
const statsObserver = new IntersectionObserver((entries) => {
    entries.forEach(entry => {
        if (entry.isIntersecting) {
            const target = parseInt(entry.target.dataset.count);
            if (target && !isNaN(target)) {
                animateCounter(entry.target, target);
            }
            statsObserver.unobserve(entry.target);
        }
    });
}, { threshold: 0.5 });

heroStats.forEach(stat => {
    // Extract number from text content
    const text = stat.textContent;
    const match = text.match(/[\d.]+/);
    if (match) {
        const value = parseFloat(match[0]);
        const multiplier = text.includes('K') ? 1000 : 1;
        stat.dataset.count = value * multiplier;
        stat.textContent = '0';
        statsObserver.observe(stat);
    }
});

// ==================== //
// Form Handling (if needed)
// ==================== //

// Handle CTA button clicks
const ctaButtons = document.querySelectorAll('.btn-primary, .btn-secondary, .nav-cta');

ctaButtons.forEach(button => {
    button.addEventListener('click', (e) => {
        const href = button.getAttribute('href');

        // If it's a download link, track the click
        if (href && href.includes('download')) {
            // Here you would typically send analytics
            console.log('Download button clicked');
        }
    });
});

// ==================== //
// Pricing Card Interaction
// ==================== //

const pricingCards = document.querySelectorAll('.pricing-card');

pricingCards.forEach(card => {
    card.addEventListener('mouseenter', () => {
        // Add subtle scale effect
        card.style.transform = 'translateY(-8px) scale(1.02)';
    });

    card.addEventListener('mouseleave', () => {
        // Reset scale
        const isFeatured = card.classList.contains('featured');
        card.style.transform = isFeatured ? 'scale(1.05)' : 'translateY(0) scale(1)';
    });
});

// ==================== //
// Easter Egg: Konami Code
// ==================== //

let konamiCode = [];
const konamiSequence = [
    'ArrowUp', 'ArrowUp', 'ArrowDown', 'ArrowDown',
    'ArrowLeft', 'ArrowRight', 'ArrowLeft', 'ArrowRight',
    'b', 'a'
];

document.addEventListener('keydown', (e) => {
    konamiCode.push(e.key);
    konamiCode = konamiCode.slice(-konamiSequence.length);

    if (konamiCode.join(',') === konamiSequence.join(',')) {
        // Easter egg activated!
        document.body.style.animation = 'rainbow 2s linear infinite';

        // Add rainbow animation
        const style = document.createElement('style');
        style.textContent = `
            @keyframes rainbow {
                0% { filter: hue-rotate(0deg); }
                100% { filter: hue-rotate(360deg); }
            }
        `;
        document.head.appendChild(style);

        // Show message
        const message = document.createElement('div');
        message.textContent = '🎉 You found the secret! Enjoy your rainbow mode!';
        message.style.cssText = `
            position: fixed;
            top: 50%;
            left: 50%;
            transform: translate(-50%, -50%);
            background: rgba(0, 0, 0, 0.9);
            color: white;
            padding: 2rem;
            border-radius: 16px;
            font-size: 1.5rem;
            z-index: 10000;
            text-align: center;
        `;
        document.body.appendChild(message);

        setTimeout(() => {
            message.remove();
        }, 3000);

        // Reset after 10 seconds
        setTimeout(() => {
            document.body.style.animation = '';
            style.remove();
        }, 10000);
    }
});

// ==================== //
// Parallax Effect for Hero Background
// ==================== //

const hero = document.querySelector('.hero');

window.addEventListener('scroll', () => {
    const scrolled = window.pageYOffset;
    const heroHeight = hero.offsetHeight;

    // Apply parallax only in hero section
    if (scrolled < heroHeight) {
        const parallaxSpeed = 0.5;
        hero.style.backgroundPositionY = `${scrolled * parallaxSpeed}px`;
    }
});

// ==================== //
// Lazy Loading for Images (if added later)
// ==================== //

if ('IntersectionObserver' in window) {
    const imageObserver = new IntersectionObserver((entries, observer) => {
        entries.forEach(entry => {
            if (entry.isIntersecting) {
                const img = entry.target;
                const src = img.getAttribute('data-src');

                if (src) {
                    img.src = src;
                    img.removeAttribute('data-src');
                    img.classList.add('loaded');
                }

                imageObserver.unobserve(img);
            }
        });
    });

    // Observe all images with data-src attribute
    const lazyImages = document.querySelectorAll('img[data-src]');
    lazyImages.forEach(img => imageObserver.observe(img));
}

// ==================== //
// Performance Monitoring
// ==================== //

// Log page load time
window.addEventListener('load', () => {
    const loadTime = performance.timing.domContentLoadedEventEnd - performance.timing.navigationStart;
    console.log(`Page loaded in ${loadTime}ms`);

    // Optional: Send to analytics
    // analytics.track('page_load_time', { duration: loadTime });
});

// ==================== //
// Dark Mode Toggle (Optional)
// ==================== //

// Check for saved theme preference or default to light mode
const currentTheme = localStorage.getItem('theme') || 'light';
document.documentElement.setAttribute('data-theme', currentTheme);

// Theme toggle function (can be triggered by a button if added)
function toggleTheme() {
    const theme = document.documentElement.getAttribute('data-theme');
    const newTheme = theme === 'light' ? 'dark' : 'light';

    document.documentElement.setAttribute('data-theme', newTheme);
    localStorage.setItem('theme', newTheme);
}

// Add keyboard shortcut for theme toggle (Ctrl/Cmd + Shift + T)
document.addEventListener('keydown', (e) => {
    if ((e.ctrlKey || e.metaKey) && e.shiftKey && e.key === 'T') {
        toggleTheme();
    }
});

// ==================== //
// Service Worker Registration (for PWA)
// ==================== //

if ('serviceWorker' in navigator) {
    window.addEventListener('load', () => {
        // Uncomment when service worker is ready
        // navigator.serviceWorker.register('/sw.js')
        //     .then(registration => console.log('SW registered:', registration))
        //     .catch(error => console.log('SW registration failed:', error));
    });
}

// ==================== //
// Initialize
// ==================== //

console.log('Personal Finance Navigator Landing Page - Loaded Successfully! 🚀');
console.log('Tip: Try the Konami Code for a surprise! ⬆️⬆️⬇️⬇️⬅️➡️⬅️➡️ B A');
