// Smooth scroll for anchor links
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

// Navbar background on scroll
const navbar = document.querySelector('.navbar');
let lastScroll = 0;

window.addEventListener('scroll', () => {
    const currentScroll = window.pageYOffset;

    if (currentScroll > 100) {
        navbar.style.background = 'rgba(255, 255, 255, 0.95)';
        navbar.style.boxShadow = '0 2px 8px rgba(0, 0, 0, 0.1)';
    } else {
        navbar.style.background = 'rgba(255, 255, 255, 0.8)';
        navbar.style.boxShadow = 'none';
    }

    lastScroll = currentScroll;
});

// Intersection Observer for fade-in animations
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

// Observe all feature cards, testimonials, and pricing cards
document.querySelectorAll('.feature-card, .testimonial-card, .pricing-card, .step').forEach(el => {
    el.style.opacity = '0';
    el.style.transform = 'translateY(20px)';
    el.style.transition = 'opacity 0.6s ease, transform 0.6s ease';
    observer.observe(el);
});

// Counter animation for stats
function animateCounter(element, target, duration) {
    let start = 0;
    const increment = target / (duration / 16);
    const timer = setInterval(() => {
        start += increment;
        if (start >= target) {
            element.textContent = formatStatNumber(target);
            clearInterval(timer);
        } else {
            element.textContent = formatStatNumber(Math.floor(start));
        }
    }, 16);
}

function formatStatNumber(num) {
    if (num >= 1000) {
        return (num / 1000).toFixed(1) + 'K';
    }
    return num.toString();
}

// Trigger counter animation when stats section is visible
const statsObserver = new IntersectionObserver((entries) => {
    entries.forEach(entry => {
        if (entry.isIntersecting) {
            const statNumbers = entry.target.querySelectorAll('.stat-number');
            // Store original values if they contain text
            statsObserver.unobserve(entry.target);
        }
    });
}, { threshold: 0.5 });

const heroStats = document.querySelector('.hero-stats');
if (heroStats) {
    statsObserver.observe(heroStats);
}

// Mobile menu toggle
const mobileMenuBtn = document.createElement('button');
mobileMenuBtn.className = 'mobile-menu-btn';
mobileMenuBtn.innerHTML = '☰';
mobileMenuBtn.style.cssText = `
    display: none;
    background: none;
    border: none;
    font-size: 24px;
    cursor: pointer;
    color: var(--text-primary);
`;

const navCta = document.querySelector('.nav-cta');
if (navCta && window.innerWidth <= 768) {
    mobileMenuBtn.style.display = 'block';
    navCta.parentElement.insertBefore(mobileMenuBtn, navCta);
}

mobileMenuBtn.addEventListener('click', () => {
    const navMenu = document.querySelector('.nav-menu');
    navMenu.style.display = navMenu.style.display === 'flex' ? 'none' : 'flex';
});

// Handle window resize
window.addEventListener('resize', () => {
    const navMenu = document.querySelector('.nav-menu');
    if (window.innerWidth > 768) {
        navMenu.style.display = 'flex';
        mobileMenuBtn.style.display = 'none';
    } else {
        navMenu.style.display = 'none';
        mobileMenuBtn.style.display = 'block';
    }
});

// Add parallax effect to hero background
window.addEventListener('scroll', () => {
    const scrolled = window.pageYOffset;
    const heroBackground = document.querySelector('.hero-background');
    if (heroBackground) {
        heroBackground.style.transform = `translateY(${scrolled * 0.5}px)`;
    }
});

// Pricing card interaction
document.querySelectorAll('.pricing-card').forEach(card => {
    card.addEventListener('mouseenter', function() {
        if (!this.classList.contains('pricing-featured')) {
            this.style.transform = 'translateY(-12px)';
        }
    });

    card.addEventListener('mouseleave', function() {
        if (!this.classList.contains('pricing-featured')) {
            this.style.transform = 'translateY(0)';
        }
    });
});

// Add click tracking for CTAs (placeholder - replace with actual analytics)
document.querySelectorAll('.btn-primary').forEach(btn => {
    btn.addEventListener('click', function(e) {
        // Log CTA click
        console.log('CTA clicked:', this.textContent.trim());

        // You can add analytics tracking here
        // Example: gtag('event', 'click', { 'event_category': 'CTA', 'event_label': this.textContent });
    });
});

// Newsletter signup (if you add a form)
const emailForm = document.querySelector('#email-form');
if (emailForm) {
    emailForm.addEventListener('submit', function(e) {
        e.preventDefault();
        const email = this.querySelector('input[type="email"]').value;
        console.log('Email signup:', email);
        // Add your email signup logic here
        alert('Thank you for signing up! We\'ll keep you updated.');
        this.reset();
    });
}

// Lazy load images (if you add images later)
if ('IntersectionObserver' in window) {
    const imageObserver = new IntersectionObserver((entries, observer) => {
        entries.forEach(entry => {
            if (entry.isIntersecting) {
                const img = entry.target;
                img.src = img.dataset.src;
                img.classList.add('loaded');
                observer.unobserve(img);
            }
        });
    });

    document.querySelectorAll('img[data-src]').forEach(img => {
        imageObserver.observe(img);
    });
}

// Add smooth reveal animation to sections
const sections = document.querySelectorAll('section');
const sectionObserver = new IntersectionObserver((entries) => {
    entries.forEach(entry => {
        if (entry.isIntersecting) {
            entry.target.classList.add('section-visible');
        }
    });
}, {
    threshold: 0.1
});

sections.forEach(section => {
    sectionObserver.observe(section);
});

// Performance: Debounce scroll events
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

// Apply debounce to scroll events if needed
const debouncedScroll = debounce(() => {
    // Any expensive scroll operations here
}, 100);

window.addEventListener('scroll', debouncedScroll);

console.log('Spatial Music Studio - Landing Page Loaded ✨');
