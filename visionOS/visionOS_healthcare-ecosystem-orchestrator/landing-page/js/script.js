// Healthcare Orchestrator Landing Page JavaScript

// ===========================
// Navigation Scroll Effect
// ===========================
const navbar = document.querySelector('.navbar');
let lastScroll = 0;

window.addEventListener('scroll', () => {
    const currentScroll = window.pageYOffset;

    // Add shadow on scroll
    if (currentScroll > 50) {
        navbar.style.boxShadow = '0 2px 10px rgba(0, 0, 0, 0.1)';
    } else {
        navbar.style.boxShadow = 'none';
    }

    lastScroll = currentScroll;
});

// ===========================
// Mobile Menu Toggle
// ===========================
const mobileMenuBtn = document.querySelector('.mobile-menu-btn');
const navLinks = document.querySelector('.nav-links');

if (mobileMenuBtn) {
    mobileMenuBtn.addEventListener('click', () => {
        navLinks.classList.toggle('active');
        mobileMenuBtn.classList.toggle('active');
    });

    // Close menu when clicking nav link
    document.querySelectorAll('.nav-links a').forEach(link => {
        link.addEventListener('click', () => {
            navLinks.classList.remove('active');
            mobileMenuBtn.classList.remove('active');
        });
    });
}

// ===========================
// Smooth Scroll for Anchor Links
// ===========================
document.querySelectorAll('a[href^="#"]').forEach(anchor => {
    anchor.addEventListener('click', function (e) {
        e.preventDefault();
        const target = document.querySelector(this.getAttribute('href'));

        if (target) {
            const navHeight = navbar.offsetHeight;
            const targetPosition = target.offsetTop - navHeight;

            window.scrollTo({
                top: targetPosition,
                behavior: 'smooth'
            });
        }
    });
});

// ===========================
// Scroll Fade-In Animation
// ===========================
const observerOptions = {
    threshold: 0.1,
    rootMargin: '0px 0px -100px 0px'
};

const observer = new IntersectionObserver((entries) => {
    entries.forEach(entry => {
        if (entry.isIntersecting) {
            entry.target.classList.add('visible');
        }
    });
}, observerOptions);

// Observe all elements that should fade in
document.querySelectorAll('.problem-card, .feature-card, .roi-metric, .testimonial-card, .pricing-card').forEach(el => {
    el.classList.add('scroll-fade-in');
    observer.observe(el);
});

// ===========================
// Demo Form Handling
// ===========================
const demoForm = document.getElementById('demoForm');

if (demoForm) {
    demoForm.addEventListener('submit', async (e) => {
        e.preventDefault();

        const formData = new FormData(demoForm);
        const data = Object.fromEntries(formData);

        // Show loading state
        const submitBtn = demoForm.querySelector('button[type="submit"]');
        const originalText = submitBtn.textContent;
        submitBtn.textContent = 'Scheduling...';
        submitBtn.disabled = true;

        // Simulate API call (replace with actual endpoint)
        try {
            // await fetch('/api/demo-request', {
            //     method: 'POST',
            //     headers: { 'Content-Type': 'application/json' },
            //     body: JSON.stringify(data)
            // });

            // Simulate delay
            await new Promise(resolve => setTimeout(resolve, 1500));

            // Show success message
            showNotification('Thank you! We\'ll contact you within 24 hours to schedule your personalized demo.', 'success');
            demoForm.reset();

        } catch (error) {
            showNotification('Oops! Something went wrong. Please try again or email us at sales@healthcareorchestrator.com', 'error');
        } finally {
            submitBtn.textContent = originalText;
            submitBtn.disabled = false;
        }
    });
}

// ===========================
// Notification System
// ===========================
function showNotification(message, type = 'info') {
    const notification = document.createElement('div');
    notification.className = `notification notification-${type}`;
    notification.innerHTML = `
        <div class="notification-content">
            <span class="notification-icon">${type === 'success' ? '✓' : '⚠'}</span>
            <p>${message}</p>
        </div>
        <button class="notification-close" onclick="this.parentElement.remove()">×</button>
    `;

    // Add styles
    Object.assign(notification.style, {
        position: 'fixed',
        top: '20px',
        right: '20px',
        background: type === 'success' ? '#10B981' : '#EF4444',
        color: 'white',
        padding: '1rem 1.5rem',
        borderRadius: '0.75rem',
        boxShadow: '0 10px 15px -3px rgba(0, 0, 0, 0.1)',
        zIndex: '10000',
        display: 'flex',
        alignItems: 'center',
        gap: '1rem',
        maxWidth: '500px',
        animation: 'slideInRight 0.3s ease-out'
    });

    document.body.appendChild(notification);

    // Auto remove after 5 seconds
    setTimeout(() => {
        notification.style.animation = 'slideOutRight 0.3s ease-out';
        setTimeout(() => notification.remove(), 300);
    }, 5000);
}

// Add animation keyframes
const style = document.createElement('style');
style.textContent = `
    @keyframes slideInRight {
        from {
            transform: translateX(100%);
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
            transform: translateX(100%);
            opacity: 0;
        }
    }

    .notification-content {
        display: flex;
        align-items: center;
        gap: 0.75rem;
        flex: 1;
    }

    .notification-icon {
        font-size: 1.5rem;
        font-weight: bold;
    }

    .notification-close {
        background: none;
        border: none;
        color: white;
        font-size: 1.5rem;
        cursor: pointer;
        padding: 0;
        width: 24px;
        height: 24px;
        display: flex;
        align-items: center;
        justify-content: center;
        opacity: 0.8;
        transition: opacity 0.2s;
    }

    .notification-close:hover {
        opacity: 1;
    }
`;
document.head.appendChild(style);

// ===========================
// Number Counter Animation
// ===========================
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
            const value = entry.target.textContent;
            const num = parseInt(value);
            const suffix = value.replace(num, '');

            animateValue(entry.target, 0, num, 1500, suffix);
            entry.target.dataset.animated = 'true';
        }
    });
}, { threshold: 0.5 });

document.querySelectorAll('.stat-value, .metric-value').forEach(el => {
    if (el.textContent.match(/\d+/)) {
        statsObserver.observe(el);
    }
});

// ===========================
// Video Modal (if needed)
// ===========================
const videoLinks = document.querySelectorAll('a[href="#video"]');

videoLinks.forEach(link => {
    link.addEventListener('click', (e) => {
        e.preventDefault();
        showVideoModal('https://www.youtube.com/embed/dQw4w9WgXcQ'); // Replace with actual video URL
    });
});

function showVideoModal(videoUrl) {
    const modal = document.createElement('div');
    modal.className = 'video-modal';
    modal.innerHTML = `
        <div class="video-modal-backdrop" onclick="this.parentElement.remove()"></div>
        <div class="video-modal-content">
            <button class="video-modal-close" onclick="this.closest('.video-modal').remove()">×</button>
            <iframe
                src="${videoUrl}"
                frameborder="0"
                allow="accelerometer; autoplay; clipboard-write; encrypted-media; gyroscope; picture-in-picture"
                allowfullscreen
            ></iframe>
        </div>
    `;

    // Add modal styles
    const modalStyle = document.createElement('style');
    modalStyle.textContent = `
        .video-modal {
            position: fixed;
            top: 0;
            left: 0;
            right: 0;
            bottom: 0;
            z-index: 9999;
            display: flex;
            align-items: center;
            justify-content: center;
        }

        .video-modal-backdrop {
            position: absolute;
            top: 0;
            left: 0;
            right: 0;
            bottom: 0;
            background: rgba(0, 0, 0, 0.9);
            cursor: pointer;
        }

        .video-modal-content {
            position: relative;
            width: 90%;
            max-width: 1200px;
            aspect-ratio: 16/9;
            background: #000;
            border-radius: 1rem;
            overflow: hidden;
            animation: modalZoomIn 0.3s ease-out;
        }

        @keyframes modalZoomIn {
            from {
                transform: scale(0.8);
                opacity: 0;
            }
            to {
                transform: scale(1);
                opacity: 1;
            }
        }

        .video-modal-content iframe {
            width: 100%;
            height: 100%;
        }

        .video-modal-close {
            position: absolute;
            top: -40px;
            right: 0;
            background: none;
            border: none;
            color: white;
            font-size: 2rem;
            cursor: pointer;
            z-index: 1;
            width: 40px;
            height: 40px;
            display: flex;
            align-items: center;
            justify-content: center;
        }

        .video-modal-close:hover {
            opacity: 0.7;
        }
    `;
    document.head.appendChild(modalStyle);
    document.body.appendChild(modal);

    // Prevent body scroll
    document.body.style.overflow = 'hidden';

    // Restore scroll when modal is removed
    modal.addEventListener('remove', () => {
        document.body.style.overflow = '';
    });
}

// ===========================
// Pricing Toggle (if needed for monthly/annual)
// ===========================
function initPricingToggle() {
    const toggle = document.querySelector('.pricing-toggle');
    if (!toggle) return;

    const monthlyPrices = {
        basic: 199,
        pro: 399,
        enterprise: 699
    };

    const annualPrices = {
        basic: 2000000 / 500 / 12, // Annual package divided by users and months
        pro: 5000000 / 2000 / 12,
        enterprise: 12000000 / 5000 / 12
    };

    toggle.addEventListener('change', (e) => {
        const isAnnual = e.target.checked;
        const prices = isAnnual ? annualPrices : monthlyPrices;

        // Update prices on page (implement based on your HTML structure)
        console.log('Pricing toggle:', isAnnual ? 'Annual' : 'Monthly', prices);
    });
}

initPricingToggle();

// ===========================
// ROI Calculator (Interactive)
// ===========================
function initROICalculator() {
    const calcButton = document.querySelector('a[href="#contact"]');
    if (!calcButton) return;

    // Could add an interactive ROI calculator modal here
}

initROICalculator();

// ===========================
// Performance Optimizations
// ===========================
// Lazy load images
document.addEventListener('DOMContentLoaded', () => {
    const images = document.querySelectorAll('img[data-src]');
    const imageObserver = new IntersectionObserver((entries) => {
        entries.forEach(entry => {
            if (entry.isIntersecting) {
                const img = entry.target;
                img.src = img.dataset.src;
                img.removeAttribute('data-src');
                imageObserver.unobserve(img);
            }
        });
    });

    images.forEach(img => imageObserver.observe(img));
});

// ===========================
// Console Easter Egg
// ===========================
console.log('%c👋 Hello Healthcare Innovator!', 'font-size: 20px; font-weight: bold; color: #0066FF;');
console.log('%cInterested in joining our team? Email us at careers@healthcareorchestrator.com', 'font-size: 14px; color: #00D4AA;');
console.log('%c\nBuilt with ❤️ for the future of healthcare', 'font-size: 12px; font-style: italic;');

// ===========================
// Analytics Event Tracking (placeholder)
// ===========================
function trackEvent(category, action, label) {
    // Implement your analytics tracking here
    // Example: gtag('event', action, { event_category: category, event_label: label });
    console.log('Track:', category, action, label);
}

// Track button clicks
document.querySelectorAll('.btn').forEach(btn => {
    btn.addEventListener('click', (e) => {
        const action = btn.textContent.trim();
        trackEvent('Button', 'Click', action);
    });
});

// Track form submissions
if (demoForm) {
    demoForm.addEventListener('submit', () => {
        trackEvent('Form', 'Submit', 'Demo Request');
    });
}

// Track scroll depth
let maxScrollDepth = 0;
window.addEventListener('scroll', () => {
    const scrollPercentage = (window.scrollY / (document.documentElement.scrollHeight - window.innerHeight)) * 100;

    if (scrollPercentage > maxScrollDepth) {
        maxScrollDepth = Math.floor(scrollPercentage / 25) * 25; // Track in 25% increments
        if (maxScrollDepth % 25 === 0 && maxScrollDepth > 0) {
            trackEvent('Scroll Depth', `${maxScrollDepth}%`, window.location.pathname);
        }
    }
});

console.log('🚀 Healthcare Orchestrator Landing Page Loaded Successfully!');
