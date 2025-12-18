// Smooth scroll behavior for navigation links
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

// Navbar scroll effect
let lastScroll = 0;
const navbar = document.querySelector('.navbar');

window.addEventListener('scroll', () => {
    const currentScroll = window.pageYOffset;

    if (currentScroll <= 0) {
        navbar.style.boxShadow = 'none';
    } else {
        navbar.style.boxShadow = '0 2px 20px rgba(0, 0, 0, 0.5)';
    }

    lastScroll = currentScroll;
});

// Intersection Observer for scroll animations
const observerOptions = {
    threshold: 0.1,
    rootMargin: '0px 0px -100px 0px'
};

const observer = new IntersectionObserver((entries) => {
    entries.forEach(entry => {
        if (entry.isIntersecting) {
            entry.target.style.opacity = '1';
            entry.target.style.transform = 'translateY(0)';
        }
    });
}, observerOptions);

// Observe all sections for fade-in animation
document.querySelectorAll('section').forEach(section => {
    section.style.opacity = '0';
    section.style.transform = 'translateY(30px)';
    section.style.transition = 'opacity 0.6s ease, transform 0.6s ease';
    observer.observe(section);
});

// CTA Button interactions
const ctaButtons = document.querySelectorAll('[class*="cta-button"]');

ctaButtons.forEach(button => {
    button.addEventListener('click', (e) => {
        // Check if it's a pre-order button
        if (button.textContent.includes('Pre-Order') || button.textContent.includes('Start Free Trial')) {
            e.preventDefault();

            // Create a modal or redirect (placeholder)
            alert('Pre-order functionality coming soon! Join our waitlist to be notified.');

            // In production, this would:
            // - Open a checkout modal
            // - Redirect to App Store
            // - Open a sign-up form
        }
    });
});

// Video player for trailer button
const trailerButton = document.querySelector('.cta-button-secondary');
if (trailerButton) {
    trailerButton.addEventListener('click', (e) => {
        e.preventDefault();
        alert('Trailer coming soon! Follow us on social media for updates.');

        // In production, this would:
        // - Open a video modal with the trailer
        // - Play YouTube/Vimeo embed
    });
}

// Dynamic counter animation for stats
const animateCounter = (element, target, duration = 2000) => {
    const start = 0;
    const increment = target / (duration / 16);
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
};

// Observe hero stats for counter animation
const statsObserver = new IntersectionObserver((entries) => {
    entries.forEach(entry => {
        if (entry.isIntersecting) {
            const statNumbers = entry.target.querySelectorAll('.stat-number');
            statNumbers.forEach(stat => {
                const text = stat.textContent;
                const number = parseInt(text);
                if (!isNaN(number)) {
                    animateCounter(stat, number);
                }
            });
            statsObserver.unobserve(entry.target);
        }
    });
}, { threshold: 0.5 });

const heroStats = document.querySelector('.hero-stats');
if (heroStats) {
    statsObserver.observe(heroStats);
}

// Parallax effect for hero background
window.addEventListener('scroll', () => {
    const scrolled = window.pageYOffset;
    const heroBackground = document.querySelector('.hero-background');

    if (heroBackground && scrolled < window.innerHeight) {
        heroBackground.style.transform = `translateY(${scrolled * 0.5}px)`;
    }
});

// Training cards stacking effect on hover
const trainingCards = document.querySelectorAll('.training-card');
trainingCards.forEach((card, index) => {
    card.addEventListener('mouseenter', () => {
        trainingCards.forEach((otherCard, otherIndex) => {
            if (otherIndex !== index) {
                otherCard.style.opacity = '0.5';
                otherCard.style.filter = 'blur(2px)';
            }
        });
    });

    card.addEventListener('mouseleave', () => {
        trainingCards.forEach(otherCard => {
            otherCard.style.opacity = '1';
            otherCard.style.filter = 'none';
        });
    });
});

// Pricing card hover effect
const pricingCards = document.querySelectorAll('.pricing-card');
pricingCards.forEach(card => {
    card.addEventListener('mouseenter', () => {
        card.style.borderColor = 'var(--primary-orange)';
    });

    card.addEventListener('mouseleave', () => {
        if (!card.classList.contains('featured')) {
            card.style.borderColor = 'var(--border-color)';
        }
    });
});

// Form validation (for future newsletter/waitlist forms)
const validateEmail = (email) => {
    const re = /^[^\s@]+@[^\s@]+\.[^\s@]+$/;
    return re.test(email);
};

// Add to waitlist functionality (placeholder)
window.addToWaitlist = (email) => {
    if (validateEmail(email)) {
        console.log('Adding to waitlist:', email);
        // In production, send to backend API
        return true;
    }
    return false;
};

// Easter egg: Konami code
let konamiCode = [];
const konamiSequence = ['ArrowUp', 'ArrowUp', 'ArrowDown', 'ArrowDown', 'ArrowLeft', 'ArrowRight', 'ArrowLeft', 'ArrowRight', 'b', 'a'];

document.addEventListener('keydown', (e) => {
    konamiCode.push(e.key);
    konamiCode = konamiCode.slice(-10);

    if (konamiCode.join('') === konamiSequence.join('')) {
        document.body.style.animation = 'rainbow 2s infinite';
        setTimeout(() => {
            document.body.style.animation = '';
        }, 5000);
    }
});

// Add rainbow animation for easter egg
const style = document.createElement('style');
style.textContent = `
    @keyframes rainbow {
        0% { filter: hue-rotate(0deg); }
        100% { filter: hue-rotate(360deg); }
    }
`;
document.head.appendChild(style);

// Performance monitoring
if ('PerformanceObserver' in window) {
    const observer = new PerformanceObserver((list) => {
        for (const entry of list.getEntries()) {
            console.log('Performance:', entry.name, entry.duration);
        }
    });

    observer.observe({ entryTypes: ['measure', 'navigation'] });
}

// Log page view (for analytics)
console.log('Tactical Team Shooters - Landing Page Loaded');
console.log('Build for Vision Pro - Revolutionary Spatial Combat');

// Preload critical resources
const preloadImages = [
    // Add image URLs here when you have actual assets
];

preloadImages.forEach(src => {
    const link = document.createElement('link');
    link.rel = 'preload';
    link.as = 'image';
    link.href = src;
    document.head.appendChild(link);
});
