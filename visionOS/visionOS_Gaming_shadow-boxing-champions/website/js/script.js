/**
 * Shadow Boxing Champions - Landing Page Scripts
 * Interactive features and animations
 */

// Wait for DOM to be ready
document.addEventListener('DOMContentLoaded', function() {
    initNavbar();
    initMobileMenu();
    initScrollAnimations();
    initSmoothScroll();
    initStats();
});

/**
 * Navbar scroll effect
 */
function initNavbar() {
    const navbar = document.querySelector('.navbar');
    let lastScroll = 0;

    window.addEventListener('scroll', () => {
        const currentScroll = window.pageYOffset;

        // Add scrolled class for styling
        if (currentScroll > 50) {
            navbar.classList.add('scrolled');
        } else {
            navbar.classList.remove('scrolled');
        }

        lastScroll = currentScroll;
    });
}

/**
 * Mobile menu toggle
 */
function initMobileMenu() {
    const toggle = document.querySelector('.mobile-menu-toggle');
    const navMenu = document.querySelector('.nav-menu');

    if (!toggle) return;

    toggle.addEventListener('click', () => {
        toggle.classList.toggle('active');
        navMenu.classList.toggle('active');
    });

    // Close menu when clicking on a link
    const menuLinks = document.querySelectorAll('.nav-menu a');
    menuLinks.forEach(link => {
        link.addEventListener('click', () => {
            toggle.classList.remove('active');
            navMenu.classList.remove('active');
        });
    });

    // Close menu when clicking outside
    document.addEventListener('click', (e) => {
        if (!toggle.contains(e.target) && !navMenu.contains(e.target)) {
            toggle.classList.remove('active');
            navMenu.classList.remove('active');
        }
    });
}

/**
 * Smooth scrolling for anchor links
 */
function initSmoothScroll() {
    const links = document.querySelectorAll('a[href^="#"]');

    links.forEach(link => {
        link.addEventListener('click', (e) => {
            const href = link.getAttribute('href');

            // Skip if it's just "#"
            if (href === '#') {
                e.preventDefault();
                return;
            }

            const target = document.querySelector(href);

            if (target) {
                e.preventDefault();

                const navbarHeight = document.querySelector('.navbar').offsetHeight;
                const targetPosition = target.offsetTop - navbarHeight;

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
function initScrollAnimations() {
    const observerOptions = {
        threshold: 0.1,
        rootMargin: '0px 0px -50px 0px'
    };

    const observer = new IntersectionObserver((entries) => {
        entries.forEach(entry => {
            if (entry.isIntersecting) {
                entry.target.classList.add('animate-in');

                // Stagger animations for child elements
                const children = entry.target.querySelectorAll('.feature-card, .mode-card, .testimonial-card, .pricing-card, .faq-item, .step');
                children.forEach((child, index) => {
                    setTimeout(() => {
                        child.style.opacity = '0';
                        child.style.transform = 'translateY(20px)';
                        child.style.transition = 'opacity 0.6s ease, transform 0.6s ease';

                        setTimeout(() => {
                            child.style.opacity = '1';
                            child.style.transform = 'translateY(0)';
                        }, 50);
                    }, index * 100);
                });
            }
        });
    }, observerOptions);

    // Observe sections
    const sections = document.querySelectorAll('.features, .how-it-works, .training-modes, .testimonials, .pricing, .faq');
    sections.forEach(section => observer.observe(section));
}

/**
 * Animated counter for stats
 */
function initStats() {
    const stats = document.querySelectorAll('.stat-number');

    const observerOptions = {
        threshold: 0.5,
        rootMargin: '0px'
    };

    const observer = new IntersectionObserver((entries) => {
        entries.forEach(entry => {
            if (entry.isIntersecting && !entry.target.classList.contains('counted')) {
                entry.target.classList.add('counted');
                animateNumber(entry.target);
            }
        });
    }, observerOptions);

    stats.forEach(stat => observer.observe(stat));
}

/**
 * Animate number counting
 */
function animateNumber(element) {
    const text = element.textContent;
    const hasPlus = text.includes('+');
    const hasStar = text.includes('★');

    let number = parseFloat(text.replace(/[^0-9.]/g, ''));
    const duration = 2000; // 2 seconds
    const steps = 60;
    const increment = number / steps;
    let current = 0;
    let step = 0;

    const timer = setInterval(() => {
        step++;
        current += increment;

        if (step >= steps) {
            current = number;
            clearInterval(timer);
        }

        // Format the number
        let displayValue;
        if (number >= 1000) {
            displayValue = (current / 1000).toFixed(1) + 'K';
        } else if (hasStar) {
            displayValue = current.toFixed(1);
        } else {
            displayValue = Math.floor(current);
        }

        element.textContent = displayValue + (hasPlus ? '+' : '') + (hasStar ? '★' : '');
    }, duration / steps);
}

/**
 * Form submission handler (if you add forms later)
 */
function handleFormSubmission(formElement) {
    formElement.addEventListener('submit', async (e) => {
        e.preventDefault();

        const formData = new FormData(formElement);
        const data = Object.fromEntries(formData);

        try {
            // Replace with your actual endpoint
            const response = await fetch('/api/subscribe', {
                method: 'POST',
                headers: {
                    'Content-Type': 'application/json',
                },
                body: JSON.stringify(data)
            });

            if (response.ok) {
                showNotification('Success! Check your email.', 'success');
                formElement.reset();
            } else {
                throw new Error('Submission failed');
            }
        } catch (error) {
            showNotification('Something went wrong. Please try again.', 'error');
        }
    });
}

/**
 * Show notification toast
 */
function showNotification(message, type = 'info') {
    const notification = document.createElement('div');
    notification.className = `notification notification-${type}`;
    notification.textContent = message;

    notification.style.cssText = `
        position: fixed;
        top: 100px;
        right: 20px;
        padding: 1rem 1.5rem;
        background: ${type === 'success' ? '#4CAF50' : type === 'error' ? '#F44336' : '#2962FF'};
        color: white;
        border-radius: 12px;
        box-shadow: 0 4px 16px rgba(0, 0, 0, 0.2);
        z-index: 10000;
        animation: slideInRight 0.3s ease;
    `;

    document.body.appendChild(notification);

    setTimeout(() => {
        notification.style.animation = 'slideOutRight 0.3s ease';
        setTimeout(() => notification.remove(), 300);
    }, 3000);
}

/**
 * Video modal (if you add demo video)
 */
function initVideoModal() {
    const videoButtons = document.querySelectorAll('[href="#watch-demo"]');

    videoButtons.forEach(button => {
        button.addEventListener('click', (e) => {
            e.preventDefault();

            const modal = document.createElement('div');
            modal.className = 'video-modal';
            modal.innerHTML = `
                <div class="modal-backdrop"></div>
                <div class="modal-content">
                    <button class="modal-close">&times;</button>
                    <div class="video-wrapper">
                        <iframe
                            width="100%"
                            height="100%"
                            src="https://www.youtube.com/embed/YOUR_VIDEO_ID?autoplay=1"
                            frameborder="0"
                            allow="accelerometer; autoplay; clipboard-write; encrypted-media; gyroscope; picture-in-picture"
                            allowfullscreen>
                        </iframe>
                    </div>
                </div>
            `;

            document.body.appendChild(modal);
            document.body.style.overflow = 'hidden';

            // Close modal
            const closeModal = () => {
                modal.remove();
                document.body.style.overflow = '';
            };

            modal.querySelector('.modal-close').addEventListener('click', closeModal);
            modal.querySelector('.modal-backdrop').addEventListener('click', closeModal);

            // Close on ESC key
            document.addEventListener('keydown', function escapeClose(e) {
                if (e.key === 'Escape') {
                    closeModal();
                    document.removeEventListener('keydown', escapeClose);
                }
            });
        });
    });
}

/**
 * FAQ accordion (optional enhancement)
 */
function initFAQAccordion() {
    const faqItems = document.querySelectorAll('.faq-item');

    faqItems.forEach(item => {
        const question = item.querySelector('.faq-question');
        const answer = item.querySelector('.faq-answer');

        // Initially hide answers
        answer.style.maxHeight = answer.scrollHeight + 'px';

        question.addEventListener('click', () => {
            const isActive = item.classList.contains('active');

            // Close all other items
            faqItems.forEach(otherItem => {
                otherItem.classList.remove('active');
                const otherAnswer = otherItem.querySelector('.faq-answer');
                otherAnswer.style.maxHeight = otherAnswer.scrollHeight + 'px';
            });

            // Toggle current item
            if (!isActive) {
                item.classList.add('active');
            }
        });
    });
}

/**
 * Lazy load images
 */
function initLazyLoading() {
    const images = document.querySelectorAll('img[loading="lazy"]');

    if ('IntersectionObserver' in window) {
        const imageObserver = new IntersectionObserver((entries) => {
            entries.forEach(entry => {
                if (entry.isIntersecting) {
                    const img = entry.target;
                    if (img.dataset.src) {
                        img.src = img.dataset.src;
                        img.removeAttribute('data-src');
                    }
                    imageObserver.unobserve(img);
                }
            });
        });

        images.forEach(img => imageObserver.observe(img));
    }
}

/**
 * Initialize video modal if demo buttons exist
 */
if (document.querySelector('[href="#watch-demo"]')) {
    initVideoModal();
}

/**
 * Performance monitoring (optional)
 */
if ('PerformanceObserver' in window) {
    // Monitor Core Web Vitals
    const observer = new PerformanceObserver((list) => {
        for (const entry of list.getEntries()) {
            if (entry.entryType === 'largest-contentful-paint') {
                console.log('LCP:', entry.startTime);
            }
        }
    });

    observer.observe({ entryTypes: ['largest-contentful-paint'] });
}

// Export functions for external use if needed
window.shadowBoxing = {
    showNotification,
    initVideoModal,
    initFAQAccordion
};
