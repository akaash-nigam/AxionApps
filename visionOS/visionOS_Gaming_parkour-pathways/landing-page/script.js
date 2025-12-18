// Parkour Pathways Landing Page JavaScript

// Smooth scroll for navigation links
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

// Mobile menu toggle
const mobileMenuBtn = document.getElementById('mobileMenuBtn');
const navLinks = document.querySelector('.nav-links');

if (mobileMenuBtn) {
    mobileMenuBtn.addEventListener('click', () => {
        navLinks.classList.toggle('active');
        mobileMenuBtn.classList.toggle('active');
    });
}

// Navbar background on scroll
const nav = document.querySelector('.nav');
let lastScroll = 0;

window.addEventListener('scroll', () => {
    const currentScroll = window.pageYOffset;

    if (currentScroll <= 0) {
        nav.style.background = 'rgba(10, 14, 39, 0.8)';
    } else {
        nav.style.background = 'rgba(10, 14, 39, 0.95)';
    }

    lastScroll = currentScroll;
});

// Intersection Observer for fade-in animations
const observerOptions = {
    threshold: 0.1,
    rootMargin: '0px 0px -50px 0px'
};

const observer = new IntersectionObserver((entries) => {
    entries.forEach(entry => {
        if (entry.isIntersecting) {
            entry.target.style.animation = 'fadeIn 0.8s ease-out forwards';
            observer.unobserve(entry.target);
        }
    });
}, observerOptions);

// Observe all sections and cards
document.querySelectorAll('section > .container > *:not(.section-header), .feature-card, .pricing-card, .testimonial-card, .step').forEach(el => {
    el.style.opacity = '0';
    observer.observe(el);
});

// Counter animation for stats
const animateCounter = (element, target, duration = 2000) => {
    const start = 0;
    const increment = target / (duration / 16);
    let current = start;

    const timer = setInterval(() => {
        current += increment;
        if (current >= target) {
            element.textContent = target >= 1000 ? `${Math.floor(target / 1000)}K+` : target.toFixed(1);
            clearInterval(timer);
        } else {
            element.textContent = current >= 1000 ? `${Math.floor(current / 1000)}K+` : current.toFixed(1);
        }
    }, 16);
};

// Animate stats when they come into view
const statsObserver = new IntersectionObserver((entries) => {
    entries.forEach(entry => {
        if (entry.isIntersecting) {
            const statNumber = entry.target.querySelector('.stat-number');
            const text = statNumber.textContent;
            let target;

            if (text.includes('K+')) {
                target = parseInt(text.replace('K+', '')) * 1000;
            } else {
                target = parseFloat(text);
            }

            animateCounter(statNumber, target);
            statsObserver.unobserve(entry.target);
        }
    });
}, observerOptions);

document.querySelectorAll('.stat').forEach(stat => {
    statsObserver.observe(stat);
});

// Pricing card hover effect
document.querySelectorAll('.pricing-card').forEach(card => {
    card.addEventListener('mouseenter', function() {
        this.style.transform = 'translateY(-12px)';
    });

    card.addEventListener('mouseleave', function() {
        this.style.transform = 'translateY(-8px)';
    });
});

// Feature card parallax effect
document.querySelectorAll('.feature-card').forEach(card => {
    card.addEventListener('mousemove', function(e) {
        const rect = this.getBoundingClientRect();
        const x = e.clientX - rect.left;
        const y = e.clientY - rect.top;

        const centerX = rect.width / 2;
        const centerY = rect.height / 2;

        const rotateX = (y - centerY) / 20;
        const rotateY = (centerX - x) / 20;

        this.style.transform = `perspective(1000px) rotateX(${rotateX}deg) rotateY(${rotateY}deg) translateY(-8px)`;
    });

    card.addEventListener('mouseleave', function() {
        this.style.transform = 'perspective(1000px) rotateX(0) rotateY(0) translateY(0)';
    });
});

// Testimonial carousel (if more testimonials added)
let testimonialIndex = 0;

function rotateTestimonials() {
    const testimonials = document.querySelectorAll('.testimonial-card');
    if (testimonials.length <= 3) return; // Don't rotate if 3 or fewer

    testimonials[testimonialIndex].style.opacity = '0';
    testimonialIndex = (testimonialIndex + 1) % testimonials.length;
    testimonials[testimonialIndex].style.opacity = '1';
}

// Auto-rotate testimonials every 5 seconds (if needed)
// setInterval(rotateTestimonials, 5000);

// Download button analytics tracking
document.querySelectorAll('a[href="#download"]').forEach(btn => {
    btn.addEventListener('click', () => {
        // Track download button click
        if (typeof gtag !== 'undefined') {
            gtag('event', 'download_click', {
                'event_category': 'engagement',
                'event_label': 'Download Button'
            });
        }
        console.log('Download button clicked');
    });
});

// Demo video button
document.querySelectorAll('a[href="#demo"]').forEach(btn => {
    btn.addEventListener('click', (e) => {
        e.preventDefault();
        // Open modal or video player
        if (typeof gtag !== 'undefined') {
            gtag('event', 'demo_view', {
                'event_category': 'engagement',
                'event_label': 'Demo Video'
            });
        }
        alert('Demo video feature coming soon!');
    });
});

// Form submissions (if contact form added)
document.querySelectorAll('form').forEach(form => {
    form.addEventListener('submit', (e) => {
        e.preventDefault();
        // Handle form submission
        console.log('Form submitted');
    });
});

// Lazy loading for images (if images added)
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

    document.querySelectorAll('img.lazy').forEach(img => {
        imageObserver.observe(img);
    });
}

// Easter egg: Konami code
let konamiCode = [];
const konamiPattern = ['ArrowUp', 'ArrowUp', 'ArrowDown', 'ArrowDown', 'ArrowLeft', 'ArrowRight', 'ArrowLeft', 'ArrowRight', 'b', 'a'];

document.addEventListener('keydown', (e) => {
    konamiCode.push(e.key);
    konamiCode = konamiCode.slice(-10);

    if (konamiCode.join(',') === konamiPattern.join(',')) {
        document.body.style.transform = 'rotate(360deg)';
        document.body.style.transition = 'transform 2s';
        setTimeout(() => {
            document.body.style.transform = '';
            alert('🏃 Secret parkour mode activated! You\'re now a Master Traceur!');
        }, 2000);
        konamiCode = [];
    }
});

// Performance monitoring
window.addEventListener('load', () => {
    if (window.performance) {
        const loadTime = window.performance.timing.domContentLoadedEventEnd - window.performance.timing.navigationStart;
        console.log(`Page loaded in ${loadTime}ms`);

        if (typeof gtag !== 'undefined') {
            gtag('event', 'timing_complete', {
                'name': 'load',
                'value': loadTime,
                'event_category': 'Page Performance'
            });
        }
    }
});

// Initialize
document.addEventListener('DOMContentLoaded', () => {
    console.log('🏃 Parkour Pathways landing page loaded');

    // Add any initialization code here
    // Example: Initialize analytics, load user preferences, etc.
});
