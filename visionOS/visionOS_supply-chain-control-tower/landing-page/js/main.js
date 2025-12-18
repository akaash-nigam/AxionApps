/**
 * Supply Chain Control Tower - Landing Page JavaScript
 * Interactive features and animations
 */

// ===================================
// Utility Functions
// ===================================

const $ = (selector) => document.querySelector(selector);
const $$ = (selector) => document.querySelectorAll(selector);

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

// ===================================
// Navigation & Mobile Menu
// ===================================

class Navigation {
    constructor() {
        this.navbar = $('.navbar');
        this.mobileToggle = $('.mobile-menu-toggle');
        this.navMenu = $('.nav-menu');
        this.init();
    }

    init() {
        // Scroll effect on navbar
        window.addEventListener('scroll', debounce(() => {
            if (window.scrollY > 50) {
                this.navbar.style.background = 'rgba(0, 0, 0, 0.95)';
            } else {
                this.navbar.style.background = 'rgba(0, 0, 0, 0.8)';
            }
        }, 10));

        // Mobile menu toggle
        if (this.mobileToggle) {
            this.mobileToggle.addEventListener('click', () => this.toggleMobileMenu());
        }

        // Smooth scroll for navigation links
        $$('a[href^="#"]').forEach(anchor => {
            anchor.addEventListener('click', (e) => {
                e.preventDefault();
                const target = $(anchor.getAttribute('href'));
                if (target) {
                    target.scrollIntoView({
                        behavior: 'smooth',
                        block: 'start'
                    });
                    // Close mobile menu if open
                    if (window.innerWidth <= 768) {
                        this.toggleMobileMenu();
                    }
                }
            });
        });
    }

    toggleMobileMenu() {
        this.navMenu.classList.toggle('active');
        this.mobileToggle.classList.toggle('active');
    }
}

// ===================================
// Intersection Observer for Animations
// ===================================

class AnimationObserver {
    constructor() {
        this.init();
    }

    init() {
        const options = {
            threshold: 0.1,
            rootMargin: '0px 0px -100px 0px'
        };

        const observer = new IntersectionObserver((entries) => {
            entries.forEach(entry => {
                if (entry.isIntersecting) {
                    entry.target.classList.add('fade-in');
                    observer.unobserve(entry.target);
                }
            });
        }, options);

        // Observe all feature cards, benefit cards, etc.
        $$('.feature-card, .benefit-card, .testimonial-card, .pricing-card').forEach(card => {
            observer.observe(card);
        });
    }
}

// ===================================
// Stats Counter Animation
// ===================================

class StatsCounter {
    constructor() {
        this.stats = $$('.stat-value');
        this.animated = false;
        this.init();
    }

    init() {
        const observer = new IntersectionObserver((entries) => {
            entries.forEach(entry => {
                if (entry.isIntersecting && !this.animated) {
                    this.animateStats();
                    this.animated = true;
                }
            });
        }, { threshold: 0.5 });

        const statsSection = $('.hero-stats');
        if (statsSection) {
            observer.observe(statsSection);
        }
    }

    animateStats() {
        this.stats.forEach(stat => {
            const text = stat.textContent;
            const hasPercent = text.includes('%');
            const number = parseInt(text);

            if (!isNaN(number)) {
                let current = 0;
                const increment = number / 50; // 50 steps
                const duration = 1500; // 1.5 seconds
                const stepTime = duration / 50;

                const counter = setInterval(() => {
                    current += increment;
                    if (current >= number) {
                        stat.textContent = number + (hasPercent ? '%' : '');
                        clearInterval(counter);
                    } else {
                        stat.textContent = Math.floor(current) + (hasPercent ? '%' : '');
                    }
                }, stepTime);
            }
        });
    }
}

// ===================================
// Form Handling
// ===================================

class ContactForm {
    constructor() {
        this.form = $('#contactForm');
        this.init();
    }

    init() {
        if (!this.form) return;

        this.form.addEventListener('submit', (e) => {
            e.preventDefault();
            this.handleSubmit();
        });
    }

    async handleSubmit() {
        const formData = {
            name: $('#name').value,
            email: $('#email').value,
            company: $('#company').value,
            role: $('#role').value
        };

        // Validate
        if (!this.validate(formData)) {
            this.showMessage('Please fill in all fields', 'error');
            return;
        }

        // In production, send to backend
        console.log('Form submitted:', formData);

        // Simulate API call
        this.showLoading();

        setTimeout(() => {
            this.hideLoading();
            this.showMessage('Thanks! We\'ll contact you within 24 hours.', 'success');
            this.form.reset();

            // Track event (in production, use analytics)
            this.trackEvent('form_submit', formData);
        }, 1500);
    }

    validate(data) {
        return data.name && data.email && data.company && data.role &&
               this.isValidEmail(data.email);
    }

    isValidEmail(email) {
        return /^[^\s@]+@[^\s@]+\.[^\s@]+$/.test(email);
    }

    showMessage(message, type) {
        const messageDiv = document.createElement('div');
        messageDiv.className = `form-message ${type}`;
        messageDiv.textContent = message;
        messageDiv.style.cssText = `
            padding: 16px;
            margin-top: 16px;
            border-radius: 8px;
            text-align: center;
            background: ${type === 'success' ? '#30d158' : '#ff3b30'};
            color: white;
            animation: fadeIn 0.3s ease;
        `;

        const existingMessage = $('.form-message');
        if (existingMessage) {
            existingMessage.remove();
        }

        this.form.appendChild(messageDiv);

        setTimeout(() => {
            messageDiv.remove();
        }, 5000);
    }

    showLoading() {
        const submitBtn = this.form.querySelector('button[type="submit"]');
        submitBtn.disabled = true;
        submitBtn.innerHTML = `
            <span style="display: inline-flex; align-items: center; gap: 8px;">
                <span style="display: inline-block; width: 16px; height: 16px; border: 2px solid white; border-top-color: transparent; border-radius: 50%; animation: spin 0.6s linear infinite;"></span>
                Submitting...
            </span>
        `;
    }

    hideLoading() {
        const submitBtn = this.form.querySelector('button[type="submit"]');
        submitBtn.disabled = false;
        submitBtn.innerHTML = 'Schedule Demo';
    }

    trackEvent(eventName, data) {
        // In production, integrate with analytics (Google Analytics, Mixpanel, etc.)
        console.log('Event tracked:', eventName, data);
    }
}

// ===================================
// Video Player
// ===================================

class VideoPlayer {
    constructor() {
        this.playButton = $('.play-button');
        this.videoPlaceholder = $('.video-placeholder');
        this.init();
    }

    init() {
        if (!this.playButton) return;

        this.playButton.addEventListener('click', () => {
            // In production, replace with actual video embed
            this.playVideo();
        });
    }

    playVideo() {
        // Simulate video player (in production, use YouTube/Vimeo embed)
        const videoEmbed = document.createElement('div');
        videoEmbed.innerHTML = `
            <div style="
                position: relative;
                padding-bottom: 56.25%;
                height: 0;
                overflow: hidden;
            ">
                <iframe
                    style="
                        position: absolute;
                        top: 0;
                        left: 0;
                        width: 100%;
                        height: 100%;
                        border: 0;
                    "
                    src="https://www.youtube.com/embed/dQw4w9WgXcQ?autoplay=1"
                    allowfullscreen
                    allow="autoplay; encrypted-media"
                ></iframe>
            </div>
        `;

        this.videoPlaceholder.innerHTML = '';
        this.videoPlaceholder.appendChild(videoEmbed);
    }
}

// ===================================
// Particle Animation
// ===================================

class ParticleSystem {
    constructor() {
        this.canvas = document.createElement('canvas');
        this.ctx = this.canvas.getContext('2d');
        this.particles = [];
        this.init();
    }

    init() {
        const heroSection = $('.hero-background');
        if (!heroSection) return;

        this.canvas.style.position = 'absolute';
        this.canvas.style.top = '0';
        this.canvas.style.left = '0';
        this.canvas.style.width = '100%';
        this.canvas.style.height = '100%';
        this.canvas.style.pointerEvents = 'none';
        this.canvas.style.opacity = '0.3';

        heroSection.appendChild(this.canvas);

        this.resize();
        window.addEventListener('resize', () => this.resize());

        this.createParticles();
        this.animate();
    }

    resize() {
        this.canvas.width = window.innerWidth;
        this.canvas.height = window.innerHeight;
    }

    createParticles() {
        const count = Math.floor((this.canvas.width * this.canvas.height) / 15000);
        for (let i = 0; i < count; i++) {
            this.particles.push({
                x: Math.random() * this.canvas.width,
                y: Math.random() * this.canvas.height,
                vx: (Math.random() - 0.5) * 0.5,
                vy: (Math.random() - 0.5) * 0.5,
                radius: Math.random() * 2 + 1
            });
        }
    }

    animate() {
        this.ctx.clearRect(0, 0, this.canvas.width, this.canvas.height);

        this.particles.forEach(particle => {
            // Update position
            particle.x += particle.vx;
            particle.y += particle.vy;

            // Wrap around edges
            if (particle.x < 0) particle.x = this.canvas.width;
            if (particle.x > this.canvas.width) particle.x = 0;
            if (particle.y < 0) particle.y = this.canvas.height;
            if (particle.y > this.canvas.height) particle.y = 0;

            // Draw particle
            this.ctx.beginPath();
            this.ctx.arc(particle.x, particle.y, particle.radius, 0, Math.PI * 2);
            this.ctx.fillStyle = 'rgba(255, 255, 255, 0.5)';
            this.ctx.fill();
        });

        // Draw connections
        this.particles.forEach((p1, i) => {
            this.particles.slice(i + 1).forEach(p2 => {
                const dx = p1.x - p2.x;
                const dy = p1.y - p2.y;
                const distance = Math.sqrt(dx * dx + dy * dy);

                if (distance < 150) {
                    this.ctx.beginPath();
                    this.ctx.moveTo(p1.x, p1.y);
                    this.ctx.lineTo(p2.x, p2.y);
                    this.ctx.strokeStyle = `rgba(255, 255, 255, ${0.1 * (1 - distance / 150)})`;
                    this.ctx.lineWidth = 0.5;
                    this.ctx.stroke();
                }
            });
        });

        requestAnimationFrame(() => this.animate());
    }
}

// ===================================
// Performance Monitor
// ===================================

class PerformanceMonitor {
    constructor() {
        this.init();
    }

    init() {
        // Log page load performance
        window.addEventListener('load', () => {
            if ('performance' in window) {
                const perfData = performance.timing;
                const pageLoadTime = perfData.loadEventEnd - perfData.navigationStart;
                console.log('Page load time:', pageLoadTime + 'ms');

                // Track in analytics (in production)
                this.trackPerformance('page_load', pageLoadTime);
            }
        });
    }

    trackPerformance(metric, value) {
        // In production, send to analytics
        console.log('Performance metric:', metric, value);
    }
}

// ===================================
// Initialize App
// ===================================

document.addEventListener('DOMContentLoaded', () => {
    // Initialize all components
    new Navigation();
    new AnimationObserver();
    new StatsCounter();
    new ContactForm();
    new VideoPlayer();
    new ParticleSystem();
    new PerformanceMonitor();

    // Add CSS for spin animation (for loading spinner)
    const style = document.createElement('style');
    style.textContent = `
        @keyframes spin {
            from { transform: rotate(0deg); }
            to { transform: rotate(360deg); }
        }
    `;
    document.head.appendChild(style);

    console.log('✅ Supply Chain Control Tower - Landing Page Initialized');
});

// ===================================
// Expose API for external use
// ===================================

window.SupplyChainApp = {
    trackEvent: (eventName, data) => {
        console.log('Custom event:', eventName, data);
        // In production, integrate with analytics
    },
    showDemo: () => {
        const demoSection = $('#demo');
        if (demoSection) {
            demoSection.scrollIntoView({ behavior: 'smooth' });
        }
    },
    openContact: () => {
        const contactSection = $('#contact');
        if (contactSection) {
            contactSection.scrollIntoView({ behavior: 'smooth' });
        }
    }
};
