/**
 * Rhythm Flow Landing Page - JavaScript
 * Interactive elements and animations
 */

// =============================
// SMOOTH SCROLLING
// =============================
document.querySelectorAll('a[href^="#"]').forEach(anchor => {
    anchor.addEventListener('click', function (e) {
        e.preventDefault();
        const target = document.querySelector(this.getAttribute('href'));
        if (target) {
            const navHeight = document.querySelector('.navbar').offsetHeight;
            const targetPosition = target.offsetTop - navHeight;
            window.scrollTo({
                top: targetPosition,
                behavior: 'smooth'
            });
        }
    });
});

// =============================
// NAVBAR SCROLL EFFECT
// =============================
let lastScroll = 0;
const navbar = document.querySelector('.navbar');

window.addEventListener('scroll', () => {
    const currentScroll = window.pageYOffset;

    // Add shadow on scroll
    if (currentScroll > 50) {
        navbar.style.boxShadow = '0 4px 20px rgba(0, 0, 0, 0.3)';
    } else {
        navbar.style.boxShadow = 'none';
    }

    lastScroll = currentScroll;
});

// =============================
// MOBILE MENU TOGGLE
// =============================
const mobileMenuBtn = document.getElementById('mobileMenuBtn');
const navLinks = document.querySelector('.nav-links');

if (mobileMenuBtn) {
    mobileMenuBtn.addEventListener('click', () => {
        navLinks.classList.toggle('active');
        mobileMenuBtn.classList.toggle('active');
    });

    // Close menu when clicking a link
    navLinks.querySelectorAll('a').forEach(link => {
        link.addEventListener('click', () => {
            navLinks.classList.remove('active');
            mobileMenuBtn.classList.remove('active');
        });
    });
}

// =============================
// FAQ ACCORDION
// =============================
const faqItems = document.querySelectorAll('.faq-item');

faqItems.forEach(item => {
    const question = item.querySelector('.faq-question');

    question.addEventListener('click', () => {
        // Close other open items
        faqItems.forEach(otherItem => {
            if (otherItem !== item && otherItem.classList.contains('active')) {
                otherItem.classList.remove('active');
            }
        });

        // Toggle current item
        item.classList.toggle('active');
    });
});

// =============================
// VIDEO PLAY BUTTON
// =============================
const playButton = document.getElementById('playButton');
const videoPlaceholder = document.querySelector('.video-placeholder');

if (playButton) {
    playButton.addEventListener('click', () => {
        // In a real implementation, this would launch a video modal or embed
        alert('Video player would open here! \n\nFor the prototype, imagine an epic gameplay trailer showcasing:\n\n• Spatial 360° note gameplay\n• Hand tracking precision\n• Beautiful visual effects\n• Players dancing and moving\n• Multiplayer battles\n• Fitness tracking\n\nComing soon with actual gameplay footage!');
    });
}

// =============================
// INTERSECTION OBSERVER
// For fade-in animations
// =============================
const observerOptions = {
    threshold: 0.1,
    rootMargin: '0px 0px -100px 0px'
};

const fadeInObserver = new IntersectionObserver((entries) => {
    entries.forEach(entry => {
        if (entry.isIntersecting) {
            entry.target.style.opacity = '1';
            entry.target.style.transform = 'translateY(0)';
        }
    });
}, observerOptions);

// Observe feature cards and other elements
document.querySelectorAll('.feature-card, .testimonial-card, .pricing-card, .step').forEach(el => {
    el.style.opacity = '0';
    el.style.transform = 'translateY(30px)';
    el.style.transition = 'opacity 0.6s ease, transform 0.6s ease';
    fadeInObserver.observe(el);
});

// =============================
// PARALLAX EFFECT
// For floating orbs in hero
// =============================
window.addEventListener('mousemove', (e) => {
    const orbs = document.querySelectorAll('.gradient-orb');
    const mouseX = e.clientX / window.innerWidth;
    const mouseY = e.clientY / window.innerHeight;

    orbs.forEach((orb, index) => {
        const speed = (index + 1) * 20;
        const x = (mouseX - 0.5) * speed;
        const y = (mouseY - 0.5) * speed;

        orb.style.transform = `translate(${x}px, ${y}px)`;
    });
});

// =============================
// STATS COUNTER ANIMATION
// Animate numbers when visible
// =============================
const animateCounter = (element, target, duration = 2000) => {
    const start = 0;
    const increment = target / (duration / 16); // 60 FPS
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

const statsObserver = new IntersectionObserver((entries) => {
    entries.forEach(entry => {
        if (entry.isIntersecting && !entry.target.dataset.animated) {
            const statNumbers = entry.target.querySelectorAll('.stat-number');
            statNumbers.forEach(stat => {
                const text = stat.textContent;
                const number = parseInt(text.replace(/\D/g, ''));
                if (number) {
                    stat.dataset.animated = 'true';
                    animateCounter(stat, number);
                }
            });
        }
    });
}, { threshold: 0.5 });

const heroStats = document.querySelector('.hero-stats');
if (heroStats) {
    statsObserver.observe(heroStats);
}

// =============================
// PRICING CARD HOVER EFFECT
// =============================
const pricingCards = document.querySelectorAll('.pricing-card');

pricingCards.forEach(card => {
    card.addEventListener('mouseenter', function() {
        this.style.transition = 'all 0.3s ease';
    });
});

// =============================
// DOWNLOAD BUTTON ANALYTICS
// Track download button clicks
// =============================
document.querySelectorAll('[href*="download"], .btn-download').forEach(btn => {
    btn.addEventListener('click', (e) => {
        // In production, send to analytics
        console.log('Download button clicked');
        // e.g., gtag('event', 'click', { button_name: 'download' });
    });
});

// =============================
// FEATURE CARD INTERACTIONS
// =============================
const featureCards = document.querySelectorAll('.feature-card');

featureCards.forEach(card => {
    // Add random subtle animation delays
    const delay = Math.random() * 0.3;
    card.style.transitionDelay = `${delay}s`;

    // Add hover glow effect
    card.addEventListener('mouseenter', function() {
        const rect = this.getBoundingClientRect();
        const glowX = event.clientX - rect.left;
        const glowY = event.clientY - rect.top;

        this.style.setProperty('--glow-x', `${glowX}px`);
        this.style.setProperty('--glow-y', `${glowY}px`);
    });
});

// =============================
// FLOATING NOTES ANIMATION
// Enhanced floating animation for hero notes
// =============================
const floatingNotes = document.querySelectorAll('.floating-note');

floatingNotes.forEach((note, index) => {
    // Add random rotation
    const rotation = Math.random() * 360;
    note.style.transform = `rotate(${rotation}deg)`;

    // Add click interaction
    note.addEventListener('click', function() {
        this.style.animation = 'none';
        setTimeout(() => {
            this.style.animation = '';
        }, 10);
    });
});

// =============================
// LAZY LOADING IMAGES
// If images are added later
// =============================
if ('IntersectionObserver' in window) {
    const imageObserver = new IntersectionObserver((entries, observer) => {
        entries.forEach(entry => {
            if (entry.isIntersecting) {
                const img = entry.target;
                if (img.dataset.src) {
                    img.src = img.dataset.src;
                    img.removeAttribute('data-src');
                    imageObserver.unobserve(img);
                }
            }
        });
    });

    document.querySelectorAll('img[data-src]').forEach(img => {
        imageObserver.observe(img);
    });
}

// =============================
// TESTIMONIAL SLIDER (OPTIONAL)
// If you want to add a carousel
// =============================
let currentTestimonial = 0;
const testimonials = document.querySelectorAll('.testimonial-card');

function showTestimonial(index) {
    testimonials.forEach((card, i) => {
        if (i === index) {
            card.style.display = 'block';
        } else {
            card.style.display = 'none';
        }
    });
}

// Uncomment to enable auto-rotation
// setInterval(() => {
//     currentTestimonial = (currentTestimonial + 1) % testimonials.length;
//     showTestimonial(currentTestimonial);
// }, 5000);

// =============================
// PERFORMANCE MONITORING
// =============================
if ('PerformanceObserver' in window) {
    // Monitor page load performance
    window.addEventListener('load', () => {
        const perfData = performance.timing;
        const pageLoadTime = perfData.loadEventEnd - perfData.navigationStart;
        console.log(`Page loaded in ${pageLoadTime}ms`);
    });
}

// =============================
// EASTER EGG
// Konami code for fun
// =============================
let konamiCode = [];
const konamiSequence = ['ArrowUp', 'ArrowUp', 'ArrowDown', 'ArrowDown', 'ArrowLeft', 'ArrowRight', 'ArrowLeft', 'ArrowRight', 'b', 'a'];

document.addEventListener('keydown', (e) => {
    konamiCode.push(e.key);
    konamiCode = konamiCode.slice(-10);

    if (konamiCode.join('') === konamiSequence.join('')) {
        // Trigger easter egg
        document.body.style.animation = 'rainbow 2s linear infinite';
        setTimeout(() => {
            document.body.style.animation = '';
            alert('🎵 Rhythm Flow Master Mode Unlocked! 🎵\n\nYou found the secret!\nBeta access code: FLOW2025');
        }, 100);
    }
});

// Add rainbow animation
const style = document.createElement('style');
style.textContent = `
    @keyframes rainbow {
        0% { filter: hue-rotate(0deg); }
        100% { filter: hue-rotate(360deg); }
    }
`;
document.head.appendChild(style);

// =============================
// CONSOLE MESSAGE
// =============================
console.log(`
%c🎵 Rhythm Flow 🎵
%cWelcome to the future of rhythm gaming!
%cInterested in the tech? Check out our GitHub:
https://github.com/akaash-nigam/visionOS_Gaming_rhythm-flow

Built with ❤️ for Apple Vision Pro
`,
'font-size: 24px; font-weight: bold; color: #00D9FF;',
'font-size: 14px; color: #A0A0B0;',
'font-size: 12px; color: #6B6B7B;'
);

// =============================
// INITIALIZATION
// =============================
document.addEventListener('DOMContentLoaded', () => {
    console.log('Rhythm Flow landing page initialized');

    // Add smooth fade-in on page load
    document.body.style.opacity = '0';
    setTimeout(() => {
        document.body.style.transition = 'opacity 0.5s ease';
        document.body.style.opacity = '1';
    }, 100);
});

// =============================
// ERROR HANDLING
// =============================
window.addEventListener('error', (e) => {
    console.error('Page error:', e.error);
});

// =============================
// EXPORT FOR TESTING
// =============================
if (typeof module !== 'undefined' && module.exports) {
    module.exports = {
        animateCounter,
        showTestimonial
    };
}
