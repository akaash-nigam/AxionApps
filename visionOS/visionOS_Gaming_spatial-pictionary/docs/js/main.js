/**
 * Spatial Pictionary Landing Page - Main JavaScript
 * Handles interactive elements and animations
 */

// Wait for DOM to be ready
document.addEventListener('DOMContentLoaded', function() {
    initializeNavbar();
    initializeFAQ();
    initializeSmoothScroll();
    initializeAnimations();
});

/**
 * Navbar functionality
 */
function initializeNavbar() {
    const navbar = document.querySelector('.navbar');
    const mobileMenuToggle = document.querySelector('.mobile-menu-toggle');
    const navLinks = document.querySelector('.nav-links');

    // Navbar scroll effect
    let lastScroll = 0;
    window.addEventListener('scroll', () => {
        const currentScroll = window.pageYOffset;

        if (currentScroll > 50) {
            navbar.style.boxShadow = '0 2px 16px rgba(0,0,0,0.1)';
        } else {
            navbar.style.boxShadow = 'none';
        }

        lastScroll = currentScroll;
    });

    // Mobile menu toggle
    if (mobileMenuToggle) {
        mobileMenuToggle.addEventListener('click', () => {
            navLinks.classList.toggle('active');
            mobileMenuToggle.classList.toggle('active');

            // Toggle aria-expanded for accessibility
            const isExpanded = mobileMenuToggle.getAttribute('aria-expanded') === 'true';
            mobileMenuToggle.setAttribute('aria-expanded', !isExpanded);
        });
    }

    // Close mobile menu when clicking a link
    const navLinkItems = document.querySelectorAll('.nav-links a');
    navLinkItems.forEach(link => {
        link.addEventListener('click', () => {
            navLinks.classList.remove('active');
            mobileMenuToggle.classList.remove('active');
        });
    });
}

/**
 * FAQ accordion functionality
 */
function initializeFAQ() {
    const faqItems = document.querySelectorAll('.faq-item');

    faqItems.forEach(item => {
        const question = item.querySelector('.faq-question');

        question.addEventListener('click', () => {
            const isActive = item.classList.contains('active');

            // Close all other items
            faqItems.forEach(otherItem => {
                if (otherItem !== item) {
                    otherItem.classList.remove('active');
                }
            });

            // Toggle current item
            if (isActive) {
                item.classList.remove('active');
            } else {
                item.classList.add('active');
            }
        });
    });
}

/**
 * Smooth scrolling for anchor links
 */
function initializeSmoothScroll() {
    const links = document.querySelectorAll('a[href^="#"]');

    links.forEach(link => {
        link.addEventListener('click', function(e) {
            const href = this.getAttribute('href');

            // Skip empty hash links
            if (href === '#') return;

            const target = document.querySelector(href);

            if (target) {
                e.preventDefault();

                const navbarHeight = document.querySelector('.navbar').offsetHeight;
                const targetPosition = target.offsetTop - navbarHeight - 20;

                window.scrollTo({
                    top: targetPosition,
                    behavior: 'smooth'
                });
            }
        });
    });
}

/**
 * Intersection Observer for scroll animations
 */
function initializeAnimations() {
    // Only animate if user hasn't indicated they prefer reduced motion
    if (window.matchMedia('(prefers-reduced-motion: reduce)').matches) {
        return;
    }

    const observerOptions = {
        threshold: 0.1,
        rootMargin: '0px 0px -100px 0px'
    };

    const observer = new IntersectionObserver((entries) => {
        entries.forEach(entry => {
            if (entry.isIntersecting) {
                entry.target.classList.add('animate-in');
                observer.unobserve(entry.target);
            }
        });
    }, observerOptions);

    // Observe elements that should animate on scroll
    const animateElements = document.querySelectorAll('.feature-card, .step, .pricing-card, .testimonial-card');
    animateElements.forEach(el => {
        el.style.opacity = '0';
        el.style.transform = 'translateY(30px)';
        el.style.transition = 'opacity 0.6s ease, transform 0.6s ease';
        observer.observe(el);
    });

    // Add CSS for animated state
    const style = document.createElement('style');
    style.textContent = `
        .animate-in {
            opacity: 1 !important;
            transform: translateY(0) !important;
        }
    `;
    document.head.appendChild(style);
}

/**
 * Video modal functionality (if video section is added)
 */
function openVideoModal(videoUrl) {
    const modal = document.createElement('div');
    modal.className = 'video-modal';
    modal.innerHTML = `
        <div class="modal-overlay" onclick="closeVideoModal()"></div>
        <div class="modal-content">
            <button class="modal-close" onclick="closeVideoModal()" aria-label="Close video">&times;</button>
            <div class="video-wrapper">
                <iframe
                    src="${videoUrl}"
                    frameborder="0"
                    allow="accelerometer; autoplay; clipboard-write; encrypted-media; gyroscope; picture-in-picture"
                    allowfullscreen
                ></iframe>
            </div>
        </div>
    `;
    document.body.appendChild(modal);
    document.body.style.overflow = 'hidden';

    // Close on escape key
    document.addEventListener('keydown', function escClose(e) {
        if (e.key === 'Escape') {
            closeVideoModal();
            document.removeEventListener('keydown', escClose);
        }
    });
}

function closeVideoModal() {
    const modal = document.querySelector('.video-modal');
    if (modal) {
        modal.remove();
        document.body.style.overflow = '';
    }
}

/**
 * Simple analytics tracking (replace with actual analytics)
 */
function trackEvent(category, action, label) {
    // Example: Send to Google Analytics
    if (typeof gtag !== 'undefined') {
        gtag('event', action, {
            'event_category': category,
            'event_label': label
        });
    }

    // Example: Send to custom analytics
    console.log('Event tracked:', { category, action, label });
}

// Track CTA button clicks
document.querySelectorAll('.btn').forEach(button => {
    button.addEventListener('click', function() {
        const buttonText = this.textContent.trim();
        trackEvent('Button', 'Click', buttonText);
    });
});

/**
 * Form validation (if download form is added)
 */
function validateEmailForm(email) {
    const emailRegex = /^[^\s@]+@[^\s@]+\.[^\s@]+$/;
    return emailRegex.test(email);
}

/**
 * Loading state management
 */
function setLoadingState(button, isLoading) {
    if (isLoading) {
        button.disabled = true;
        button.dataset.originalText = button.textContent;
        button.innerHTML = '<span class="spinner"></span> Loading...';
    } else {
        button.disabled = false;
        button.textContent = button.dataset.originalText;
    }
}

/**
 * Pricing plan selection
 */
document.querySelectorAll('.pricing-card .btn').forEach(button => {
    button.addEventListener('click', function(e) {
        e.preventDefault();

        const pricingCard = this.closest('.pricing-card');
        const planName = pricingCard.querySelector('.pricing-title').textContent;
        const price = pricingCard.querySelector('.pricing-price .amount').textContent;

        // Track selection
        trackEvent('Pricing', 'Plan Selected', `${planName} - $${price}`);

        // Example: Open checkout or redirect to App Store
        console.log('Selected plan:', planName);
        alert(`You selected ${planName} plan for $${price}.99\n\nThis would redirect to the App Store in production.`);
    });
});

/**
 * Newsletter signup (example)
 */
function handleNewsletterSignup(event) {
    event.preventDefault();

    const form = event.target;
    const email = form.querySelector('input[type="email"]').value;

    if (!validateEmailForm(email)) {
        alert('Please enter a valid email address');
        return;
    }

    const submitButton = form.querySelector('button[type="submit"]');
    setLoadingState(submitButton, true);

    // Example API call
    setTimeout(() => {
        setLoadingState(submitButton, false);
        alert('Thank you for subscribing!');
        form.reset();
        trackEvent('Newsletter', 'Signup', email);
    }, 1000);
}

/**
 * Countdown timer (for launches, sales, etc.)
 */
function initializeCountdown(targetDate) {
    const countdownElement = document.getElementById('countdown');
    if (!countdownElement) return;

    function updateCountdown() {
        const now = new Date().getTime();
        const distance = targetDate - now;

        if (distance < 0) {
            countdownElement.innerHTML = "LAUNCHED!";
            return;
        }

        const days = Math.floor(distance / (1000 * 60 * 60 * 24));
        const hours = Math.floor((distance % (1000 * 60 * 60 * 24)) / (1000 * 60 * 60));
        const minutes = Math.floor((distance % (1000 * 60 * 60)) / (1000 * 60));
        const seconds = Math.floor((distance % (1000 * 60)) / 1000);

        countdownElement.innerHTML = `
            <div class="countdown-item">
                <span class="countdown-number">${days}</span>
                <span class="countdown-label">Days</span>
            </div>
            <div class="countdown-item">
                <span class="countdown-number">${hours}</span>
                <span class="countdown-label">Hours</span>
            </div>
            <div class="countdown-item">
                <span class="countdown-number">${minutes}</span>
                <span class="countdown-label">Minutes</span>
            </div>
            <div class="countdown-item">
                <span class="countdown-number">${seconds}</span>
                <span class="countdown-label">Seconds</span>
            </div>
        `;
    }

    updateCountdown();
    setInterval(updateCountdown, 1000);
}

/**
 * Parallax effect for hero section
 */
window.addEventListener('scroll', () => {
    const scrolled = window.pageYOffset;
    const heroVisual = document.querySelector('.hero-visual');

    if (heroVisual && scrolled < window.innerHeight) {
        heroVisual.style.transform = `translateY(${scrolled * 0.5}px)`;
    }
});

/**
 * Device detection and optimization
 */
const isMobile = /iPhone|iPad|iPod|Android/i.test(navigator.userAgent);
const isVisionOS = /Apple Vision/i.test(navigator.userAgent); // Future-proofing

if (isMobile) {
    document.body.classList.add('is-mobile');
}

if (isVisionOS) {
    document.body.classList.add('is-visionos');
    // Add special behaviors for Vision Pro users
}

/**
 * Lazy loading images
 */
function initializeLazyLoading() {
    const images = document.querySelectorAll('img[data-src]');

    const imageObserver = new IntersectionObserver((entries, observer) => {
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
}

// Initialize lazy loading
initializeLazyLoading();

/**
 * Performance monitoring
 */
if ('PerformanceObserver' in window) {
    const perfObserver = new PerformanceObserver((list) => {
        list.getEntries().forEach((entry) => {
            // Log or send to analytics
            console.log('Performance metric:', entry.name, entry.value);
        });
    });

    perfObserver.observe({ entryTypes: ['measure', 'navigation'] });
}

/**
 * Service Worker registration (for PWA functionality)
 */
if ('serviceWorker' in navigator) {
    window.addEventListener('load', () => {
        navigator.serviceWorker.register('/sw.js')
            .then(registration => console.log('SW registered:', registration))
            .catch(err => console.log('SW registration failed:', err));
    });
}

// Export functions for use in other scripts
window.SpatialPictionary = {
    openVideoModal,
    closeVideoModal,
    trackEvent,
    validateEmailForm,
    handleNewsletterSignup
};
