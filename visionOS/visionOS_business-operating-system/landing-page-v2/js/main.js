/**
 * Business Operating System - Landing Page JavaScript
 * ===================================================
 */

// Utility Functions
const $ = (selector) => document.querySelector(selector);
const $$ = (selector) => document.querySelectorAll(selector);

// State
const state = {
    isMenuOpen: false,
    calculatorValues: {
        employees: 1000,
        currentSpend: 850000,
        avgSalary: 200000
    }
};

// ============================================================================
// Navigation
// ============================================================================

function initNavigation() {
    const navbar = $('#navbar');
    const mobileMenuToggle = $('#mobileMenuToggle');
    const navMenu = $('#navMenu');

    // Scroll effect
    let lastScrollTop = 0;

    window.addEventListener('scroll', () => {
        const scrollTop = window.pageYOffset || document.documentElement.scrollTop;

        // Add scrolled class
        if (scrollTop > 80) {
            navbar.classList.add('scrolled');
        } else {
            navbar.classList.remove('scrolled');
        }

        // Hide/show on scroll (mobile)
        if (window.innerWidth <= 768) {
            if (scrollTop > lastScrollTop && scrollTop > 100) {
                navbar.style.transform = 'translateY(-100%)';
            } else {
                navbar.style.transform = 'translateY(0)';
            }
        }

        lastScrollTop = scrollTop;
    });

    // Mobile menu toggle
    if (mobileMenuToggle) {
        mobileMenuToggle.addEventListener('click', () => {
            state.isMenuOpen = !state.isMenuOpen;
            navMenu.classList.toggle('active');
            mobileMenuToggle.classList.toggle('active');
        });
    }

    // Smooth scroll for nav links
    $$('a[href^="#"]').forEach(link => {
        link.addEventListener('click', (e) => {
            const href = link.getAttribute('href');
            if (href === '#') return;

            e.preventDefault();
            const target = $(href);

            if (target) {
                const offsetTop = target.offsetTop - 80;
                window.scrollTo({
                    top: offsetTop,
                    behavior: 'smooth'
                });

                // Close mobile menu if open
                if (state.isMenuOpen) {
                    navMenu.classList.remove('active');
                    mobileMenuToggle.classList.remove('active');
                    state.isMenuOpen = false;
                }
            }
        });
    });
}

// ============================================================================
// Hero Animations
// ============================================================================

function initHeroAnimations() {
    // Particle background
    const particlesContainer = $('#particles');
    if (particlesContainer) {
        for (let i = 0; i < 50; i++) {
            const particle = document.createElement('div');
            particle.className = 'particle';
            particle.style.cssText = `
                position: absolute;
                width: ${Math.random() * 4 + 1}px;
                height: ${Math.random() * 4 + 1}px;
                background: rgba(102, 126, 234, ${Math.random() * 0.5});
                border-radius: 50%;
                left: ${Math.random() * 100}%;
                top: ${Math.random() * 100}%;
                animation: particleFloat ${Math.random() * 10 + 10}s ease-in-out infinite;
                animation-delay: ${Math.random() * 5}s;
            `;
            particlesContainer.appendChild(particle);
        }
    }

    // Animate hero stats on scroll
    const stats = $$('.stat-value');
    const animateStats = () => {
        stats.forEach(stat => {
            const rect = stat.getBoundingClientRect();
            if (rect.top < window.innerHeight && !stat.classList.contains('animated')) {
                stat.classList.add('animated');
                animateValue(stat);
            }
        });
    };

    window.addEventListener('scroll', animateStats);
    animateStats();
}

function animateValue(element) {
    const text = element.textContent;
    const value = parseFloat(text.replace(/[^0-9.]/g, ''));
    const prefix = text.match(/^\D*/)[0];
    const suffix = text.match(/\D*$/)[0];
    const duration = 2000;
    const steps = 60;
    const stepValue = value / steps;
    const stepDuration = duration / steps;

    let current = 0;
    const interval = setInterval(() => {
        current += stepValue;
        if (current >= value) {
            element.textContent = prefix + formatNumber(value) + suffix;
            clearInterval(interval);
        } else {
            element.textContent = prefix + formatNumber(current) + suffix;
        }
    }, stepDuration);
}

function formatNumber(num) {
    if (num >= 1000000) {
        return (num / 1000000).toFixed(1) + 'M';
    } else if (num >= 1000) {
        return (num / 1000).toFixed(1) + 'K';
    }
    return Math.round(num);
}

// ============================================================================
// ROI Calculator
// ============================================================================

function initROICalculator() {
    const employeesInput = $('#employees');
    const currentSpendInput = $('#currentSpend');
    const avgSalaryInput = $('#avgSalary');

    if (!employeesInput) return;

    const inputs = [employeesInput, currentSpendInput, avgSalaryInput];

    inputs.forEach(input => {
        input.addEventListener('input', (e) => {
            state.calculatorValues[e.target.id] = parseFloat(e.target.value) || 0;
            calculateROI();
        });
    });

    // Initial calculation
    calculateROI();
}

function calculateROI() {
    const { employees, currentSpend, avgSalary } = state.calculatorValues;

    // Calculations
    const softwareSavings = currentSpend * 0.8; // 80% consolidation savings
    const executiveCount = Math.min(employees * 0.05, 100); // 5% are executives, max 100
    const hoursPerWeek = 23; // Hours saved per executive per week
    const weeksPerYear = 50;
    const hourlyRate = avgSalary / (40 * weeksPerYear);
    const timeSavings = executiveCount * hoursPerWeek * weeksPerYear * hourlyRate;
    const decisionSavings = employees * 1000; // $1000 per employee from faster decisions
    const totalSavings = softwareSavings + timeSavings + decisionSavings;

    // Cost (simplified)
    const cost = employees < 500 ? 75000 : (employees < 5000 ? 150000 : 300000);
    const paybackMonths = (cost / totalSavings * 12).toFixed(1);

    // Update UI
    $('#totalSavings').textContent = formatCurrency(totalSavings);
    $('#softwareSavings').textContent = formatCurrency(softwareSavings);
    $('#timeSavings').textContent = formatCurrency(timeSavings);
    $('#decisionSavings').textContent = formatCurrency(decisionSavings);
    $('#paybackPeriod').textContent = `${paybackMonths} months`;

    // Animate numbers
    animateNumbers();
}

function formatCurrency(amount) {
    return '$' + Math.round(amount).toLocaleString('en-US');
}

function animateNumbers() {
    const numbers = $$('.calculator-results .breakdown-value, .calculator-results .total-value');
    numbers.forEach(num => {
        num.style.transform = 'scale(1.05)';
        setTimeout(() => {
            num.style.transform = 'scale(1)';
        }, 200);
    });
}

// ============================================================================
// Form Handling
// ============================================================================

function initForms() {
    const demoForm = $('#demoForm');
    const successModal = $('#successModal');
    const modalOverlay = $('#modalOverlay');
    const closeModal = $('#closeModal');

    if (!demoForm) return;

    demoForm.addEventListener('submit', async (e) => {
        e.preventDefault();

        // Get form data
        const formData = new FormData(demoForm);
        const data = Object.fromEntries(formData.entries());

        // Validate
        if (!validateForm(data)) {
            return;
        }

        // Submit (mock - replace with actual API call)
        try {
            // Show loading state
            const submitBtn = demoForm.querySelector('button[type="submit"]');
            const originalText = submitBtn.innerHTML;
            submitBtn.disabled = true;
            submitBtn.innerHTML = `
                <svg class="animate-spin" width="20" height="20" viewBox="0 0 20 20" fill="none">
                    <circle cx="10" cy="10" r="8" stroke="currentColor" stroke-width="2" opacity="0.3"/>
                    <path d="M10 2C14.4183 2 18 5.58172 18 10" stroke="currentColor" stroke-width="2"/>
                </svg>
                Submitting...
            `;

            // Simulate API call
            await mockAPICall(data);

            // Show success modal
            successModal.classList.add('active');

            // Reset form
            demoForm.reset();

            // Restore button
            submitBtn.disabled = false;
            submitBtn.innerHTML = originalText;

        } catch (error) {
            console.error('Form submission error:', error);
            alert('Sorry, there was an error submitting the form. Please try again.');
        }
    });

    // Close modal
    [modalOverlay, closeModal].forEach(el => {
        if (el) {
            el.addEventListener('click', () => {
                successModal.classList.remove('active');
            });
        }
    });

    // Track form analytics
    $$('form input, form select, form textarea').forEach(field => {
        field.addEventListener('focus', () => {
            trackEvent('form_field_focused', { field: field.name });
        });
    });
}

function validateForm(data) {
    const errors = [];

    // Email validation
    const emailRegex = /^[^\s@]+@[^\s@]+\.[^\s@]+$/;
    if (!emailRegex.test(data.email)) {
        errors.push('Please enter a valid email address');
    }

    // Required fields
    const required = ['fullName', 'email', 'company', 'title', 'companySize'];
    required.forEach(field => {
        if (!data[field] || data[field].trim() === '') {
            errors.push(`${field} is required`);
        }
    });

    if (errors.length > 0) {
        alert(errors.join('\n'));
        return false;
    }

    return true;
}

async function mockAPICall(data) {
    // Simulate API call
    return new Promise((resolve) => {
        setTimeout(() => {
            console.log('Form submitted:', data);

            // Track conversion
            trackEvent('demo_requested', data);

            resolve();
        }, 1500);
    });
}

// ============================================================================
// Scroll Animations
// ============================================================================

function initScrollAnimations() {
    const observerOptions = {
        threshold: 0.1,
        rootMargin: '0px 0px -100px 0px'
    };

    const observer = new IntersectionObserver((entries) => {
        entries.forEach(entry => {
            if (entry.isIntersecting) {
                entry.target.classList.add('visible');
                observer.unobserve(entry.target);
            }
        });
    }, observerOptions);

    // Observe elements
    const elementsToAnimate = $$(`
        .problem-card,
        .feature-card,
        .pricing-card,
        .testimonial-card,
        .solution-feature,
        .demo-benefit
    `);

    elementsToAnimate.forEach((el, index) => {
        el.style.opacity = '0';
        el.style.transform = 'translateY(30px)';
        el.style.transition = `opacity 0.6s ease ${index * 0.1}s, transform 0.6s ease ${index * 0.1}s`;

        // Add visible class styles
        observer.observe(el);
    });

    // Add CSS for visible state
    const style = document.createElement('style');
    style.textContent = `
        .visible {
            opacity: 1 !important;
            transform: translateY(0) !important;
        }

        .animate-spin {
            animation: spin 1s linear infinite;
        }

        @keyframes spin {
            from { transform: rotate(0deg); }
            to { transform: rotate(360deg); }
        }

        @keyframes particleFloat {
            0%, 100% {
                transform: translate(0, 0);
                opacity: 0.3;
            }
            25% {
                transform: translate(10px, -10px);
                opacity: 0.6;
            }
            50% {
                transform: translate(-5px, 5px);
                opacity: 0.8;
            }
            75% {
                transform: translate(8px, 3px);
                opacity: 0.5;
            }
        }
    `;
    document.head.appendChild(style);
}

// ============================================================================
// Parallax Effects
// ============================================================================

function initParallaxEffects() {
    const heroVisual = $('.hero-visual');
    if (!heroVisual) return;

    window.addEventListener('scroll', () => {
        const scrolled = window.pageYOffset;
        const rate = scrolled * 0.3;

        // Parallax for hero visual
        if (heroVisual && scrolled < window.innerHeight) {
            heroVisual.style.transform = `translateY(${rate}px)`;
        }

        // Parallax for gradient orbs
        $$('.gradient-orb').forEach((orb, index) => {
            const speed = 0.1 + (index * 0.05);
            orb.style.transform = `translate(${scrolled * speed}px, ${scrolled * speed * 0.5}px)`;
        });
    });

    // Mouse movement parallax for preview cards
    document.addEventListener('mousemove', (e) => {
        const mouseX = e.clientX / window.innerWidth - 0.5;
        const mouseY = e.clientY / window.innerHeight - 0.5;

        $$('.preview-card').forEach((card, index) => {
            const speed = (index + 1) * 5;
            const x = mouseX * speed;
            const y = mouseY * speed;
            card.style.transform = `translate(${x}px, ${y}px)`;
        });

        $$('.floating-element').forEach((element, index) => {
            const speed = (index + 1) * 3;
            const x = mouseX * speed;
            const y = mouseY * speed;
            element.style.transform = `translate(${x}px, ${y}px)`;
        });
    });
}

// ============================================================================
// Analytics
// ============================================================================

function trackEvent(eventName, properties = {}) {
    // Google Analytics
    if (typeof gtag !== 'undefined') {
        gtag('event', eventName, properties);
    }

    // Console log for development
    console.log('Event tracked:', eventName, properties);

    // Could also send to custom analytics endpoint
    // fetch('/api/analytics', {
    //     method: 'POST',
    //     headers: { 'Content-Type': 'application/json' },
    //     body: JSON.stringify({ event: eventName, properties })
    // });
}

function initAnalytics() {
    // Track page view
    trackEvent('page_view', {
        page: window.location.pathname,
        title: document.title
    });

    // Track button clicks
    $$('.btn').forEach(btn => {
        btn.addEventListener('click', (e) => {
            trackEvent('button_clicked', {
                text: e.target.textContent.trim(),
                href: e.target.href || ''
            });
        });
    });

    // Track scroll depth
    let maxScrollDepth = 0;
    const milestones = [25, 50, 75, 100];
    let trackedMilestones = [];

    window.addEventListener('scroll', () => {
        const scrollHeight = document.documentElement.scrollHeight - window.innerHeight;
        const scrollPercent = (window.pageYOffset / scrollHeight) * 100;

        if (scrollPercent > maxScrollDepth) {
            maxScrollDepth = scrollPercent;

            milestones.forEach(milestone => {
                if (scrollPercent >= milestone && !trackedMilestones.includes(milestone)) {
                    trackedMilestones.push(milestone);
                    trackEvent('scroll_depth', { depth: milestone });
                }
            });
        }
    });

    // Track time on page
    let startTime = Date.now();
    window.addEventListener('beforeunload', () => {
        const timeOnPage = Math.round((Date.now() - startTime) / 1000);
        trackEvent('time_on_page', { seconds: timeOnPage });
    });
}

// ============================================================================
// Tooltips & Interactive Elements
// ============================================================================

function initInteractiveElements() {
    // Add hover effects to cards
    $$('.feature-card, .pricing-card, .problem-card').forEach(card => {
        card.addEventListener('mouseenter', function() {
            this.style.transition = 'all 0.3s ease';
        });
    });

    // Pricing card interaction
    $$('.pricing-card').forEach(card => {
        card.addEventListener('click', function() {
            // Highlight selected card
            $$('.pricing-card').forEach(c => c.classList.remove('selected'));
            this.classList.add('selected');

            // Scroll to demo form
            const demoForm = $('#demo');
            if (demoForm) {
                demoForm.scrollIntoView({ behavior: 'smooth' });
            }
        });
    });

    // Add ripple effect to buttons
    $$('.btn').forEach(btn => {
        btn.addEventListener('click', function(e) {
            const ripple = document.createElement('span');
            ripple.classList.add('ripple');

            const rect = this.getBoundingClientRect();
            const x = e.clientX - rect.left;
            const y = e.clientY - rect.top;

            ripple.style.cssText = `
                position: absolute;
                width: 100px;
                height: 100px;
                border-radius: 50%;
                background: rgba(255, 255, 255, 0.5);
                transform: translate(-50%, -50%) scale(0);
                animation: ripple 0.6s ease-out;
                left: ${x}px;
                top: ${y}px;
                pointer-events: none;
            `;

            this.appendChild(ripple);

            setTimeout(() => ripple.remove(), 600);
        });
    });

    // Add ripple animation
    const rippleStyle = document.createElement('style');
    rippleStyle.textContent = `
        @keyframes ripple {
            to {
                transform: translate(-50%, -50%) scale(4);
                opacity: 0;
            }
        }

        .btn {
            position: relative;
            overflow: hidden;
        }

        .pricing-card.selected {
            transform: translateY(-12px) !important;
            box-shadow: 0 20px 40px rgba(102, 126, 234, 0.3) !important;
            border-color: var(--primary) !important;
        }
    `;
    document.head.appendChild(rippleStyle);
}

// ============================================================================
// Performance Optimization
// ============================================================================

function optimizePerformance() {
    // Lazy load images
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

        $$('img[data-src]').forEach(img => imageObserver.observe(img));
    }

    // Debounce scroll events
    let scrollTimeout;
    const originalScrollHandler = window.onscroll;

    window.onscroll = function() {
        clearTimeout(scrollTimeout);
        scrollTimeout = setTimeout(() => {
            if (originalScrollHandler) originalScrollHandler();
        }, 10);
    };
}

// ============================================================================
// Copy to Clipboard
// ============================================================================

function initCopyButtons() {
    $$('[data-copy]').forEach(btn => {
        btn.addEventListener('click', async () => {
            const text = btn.dataset.copy;
            try {
                await navigator.clipboard.writeText(text);
                const originalText = btn.textContent;
                btn.textContent = 'Copied!';
                setTimeout(() => {
                    btn.textContent = originalText;
                }, 2000);
            } catch (err) {
                console.error('Failed to copy:', err);
            }
        });
    });
}

// ============================================================================
// Initialize Everything
// ============================================================================

document.addEventListener('DOMContentLoaded', () => {
    console.log('🚀 Business Operating System - Landing Page Loaded');

    // Initialize all features
    initNavigation();
    initHeroAnimations();
    initROICalculator();
    initForms();
    initScrollAnimations();
    initParallaxEffects();
    initAnalytics();
    initInteractiveElements();
    optimizePerformance();
    initCopyButtons();

    // Add loaded class to body
    setTimeout(() => {
        document.body.classList.add('loaded');
    }, 100);
});

// Handle page visibility
document.addEventListener('visibilitychange', () => {
    if (document.hidden) {
        trackEvent('page_hidden');
    } else {
        trackEvent('page_visible');
    }
});

// Export for testing
if (typeof module !== 'undefined' && module.exports) {
    module.exports = {
        calculateROI,
        validateForm,
        trackEvent
    };
}
