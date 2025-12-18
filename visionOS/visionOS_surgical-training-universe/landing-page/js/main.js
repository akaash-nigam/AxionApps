// ===================================
// Surgical Training Universe - JavaScript
// ===================================

// Wait for DOM to be fully loaded
document.addEventListener('DOMContentLoaded', function() {

    // ===================================
    // Navbar Scroll Effect
    // ===================================

    const navbar = document.querySelector('.navbar');
    let lastScroll = 0;

    window.addEventListener('scroll', () => {
        const currentScroll = window.pageYOffset;

        // Add scrolled class when scrolling down
        if (currentScroll > 50) {
            navbar.classList.add('scrolled');
        } else {
            navbar.classList.remove('scrolled');
        }

        lastScroll = currentScroll;
    });

    // ===================================
    // Mobile Menu Toggle
    // ===================================

    const mobileMenuToggle = document.querySelector('.mobile-menu-toggle');
    const navMenu = document.querySelector('.nav-menu');

    if (mobileMenuToggle) {
        mobileMenuToggle.addEventListener('click', () => {
            navMenu.classList.toggle('active');
            mobileMenuToggle.classList.toggle('active');

            // Animate hamburger icon
            const spans = mobileMenuToggle.querySelectorAll('span');
            if (mobileMenuToggle.classList.contains('active')) {
                spans[0].style.transform = 'rotate(45deg) translateY(8px)';
                spans[1].style.opacity = '0';
                spans[2].style.transform = 'rotate(-45deg) translateY(-8px)';
            } else {
                spans[0].style.transform = '';
                spans[1].style.opacity = '1';
                spans[2].style.transform = '';
            }
        });
    }

    // ===================================
    // Smooth Scrolling for Navigation Links
    // ===================================

    document.querySelectorAll('a[href^="#"]').forEach(anchor => {
        anchor.addEventListener('click', function (e) {
            const href = this.getAttribute('href');

            // Skip if href is just "#"
            if (href === '#') return;

            e.preventDefault();

            const targetId = href.substring(1);
            const targetElement = document.getElementById(targetId);

            if (targetElement) {
                const offsetTop = targetElement.offsetTop - 80; // Account for fixed navbar

                window.scrollTo({
                    top: offsetTop,
                    behavior: 'smooth'
                });

                // Close mobile menu if open
                if (navMenu.classList.contains('active')) {
                    navMenu.classList.remove('active');
                    mobileMenuToggle.classList.remove('active');
                }
            }
        });
    });

    // ===================================
    // Demo Form Handling
    // ===================================

    const demoForm = document.querySelector('.demo-form');

    if (demoForm) {
        demoForm.addEventListener('submit', function(e) {
            e.preventDefault();

            // Get form data
            const formData = new FormData(demoForm);
            const data = Object.fromEntries(formData);

            // Show loading state
            const submitButton = demoForm.querySelector('.btn-submit');
            const originalText = submitButton.textContent;
            submitButton.textContent = 'Submitting...';
            submitButton.disabled = true;

            // Simulate form submission (replace with actual API call)
            setTimeout(() => {
                // Show success message
                showNotification('✅ Thank you! We\'ll contact you within 24 hours.', 'success');

                // Reset form
                demoForm.reset();

                // Restore button
                submitButton.textContent = originalText;
                submitButton.disabled = false;

                // Track event (if analytics is set up)
                if (typeof gtag !== 'undefined') {
                    gtag('event', 'form_submission', {
                        'event_category': 'Demo Request',
                        'event_label': 'Landing Page Form'
                    });
                }
            }, 1500);

            // In production, replace above with actual API call:
            /*
            fetch('/api/demo-request', {
                method: 'POST',
                headers: {
                    'Content-Type': 'application/json',
                },
                body: JSON.stringify(data)
            })
            .then(response => response.json())
            .then(data => {
                showNotification('✅ Thank you! We\'ll contact you within 24 hours.', 'success');
                demoForm.reset();
                submitButton.textContent = originalText;
                submitButton.disabled = false;
            })
            .catch(error => {
                showNotification('❌ Something went wrong. Please try again.', 'error');
                submitButton.textContent = originalText;
                submitButton.disabled = false;
            });
            */
        });
    }

    // ===================================
    // Notification System
    // ===================================

    function showNotification(message, type = 'info') {
        // Create notification element
        const notification = document.createElement('div');
        notification.className = `notification notification-${type}`;
        notification.textContent = message;

        // Style notification
        Object.assign(notification.style, {
            position: 'fixed',
            top: '100px',
            right: '20px',
            background: type === 'success' ? '#34C759' : type === 'error' ? '#FF3B30' : '#0A7AFF',
            color: 'white',
            padding: '1rem 1.5rem',
            borderRadius: '0.75rem',
            boxShadow: '0 10px 15px -3px rgb(0 0 0 / 0.1)',
            zIndex: '9999',
            animation: 'slideInRight 0.3s ease-out',
            maxWidth: '400px'
        });

        // Add to page
        document.body.appendChild(notification);

        // Remove after 5 seconds
        setTimeout(() => {
            notification.style.animation = 'slideOutRight 0.3s ease-out';
            setTimeout(() => {
                document.body.removeChild(notification);
            }, 300);
        }, 5000);
    }

    // Add notification animations
    const style = document.createElement('style');
    style.textContent = `
        @keyframes slideInRight {
            from {
                transform: translateX(400px);
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
                transform: translateX(400px);
                opacity: 0;
            }
        }
    `;
    document.head.appendChild(style);

    // ===================================
    // Intersection Observer for Animations
    // ===================================

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

    // Observe elements for scroll animations
    const animateOnScroll = document.querySelectorAll('.feature-card, .problem-card, .benefit-card, .testimonial-card, .pricing-card');

    animateOnScroll.forEach((el, index) => {
        el.style.opacity = '0';
        el.style.transform = 'translateY(30px)';
        el.style.transition = `all 0.6s ease-out ${index * 0.1}s`;
        observer.observe(el);
    });

    // ===================================
    // Counter Animation
    // ===================================

    function animateCounter(element, target, duration = 2000) {
        const start = 0;
        const increment = target / (duration / 16); // 60 FPS
        let current = start;

        const timer = setInterval(() => {
            current += increment;
            if (current >= target) {
                current = target;
                clearInterval(timer);
            }

            // Format number
            const formatted = Math.floor(current).toLocaleString();
            element.textContent = formatted;
        }, 16);
    }

    // Animate stat numbers when they come into view
    const statNumbers = document.querySelectorAll('.stat-number');
    const statObserver = new IntersectionObserver((entries) => {
        entries.forEach(entry => {
            if (entry.isIntersecting) {
                const text = entry.target.textContent;
                const number = parseInt(text.replace(/\D/g, ''));

                if (!isNaN(number)) {
                    animateCounter(entry.target, number);
                    statObserver.unobserve(entry.target);
                }
            }
        });
    }, { threshold: 0.5 });

    statNumbers.forEach(stat => statObserver.observe(stat));

    // ===================================
    // Video Modal (if video section is added)
    // ===================================

    const videoButton = document.querySelector('.btn-hero-secondary');

    if (videoButton) {
        videoButton.addEventListener('click', (e) => {
            e.preventDefault();
            showVideoModal();
        });
    }

    function showVideoModal() {
        // Create modal
        const modal = document.createElement('div');
        modal.className = 'video-modal';
        modal.innerHTML = `
            <div class="video-modal-backdrop"></div>
            <div class="video-modal-content">
                <button class="video-modal-close">&times;</button>
                <div class="video-container">
                    <iframe
                        width="100%"
                        height="100%"
                        src="https://www.youtube.com/embed/dQw4w9WgXcQ?autoplay=1"
                        frameborder="0"
                        allow="accelerometer; autoplay; clipboard-write; encrypted-media; gyroscope; picture-in-picture"
                        allowfullscreen>
                    </iframe>
                </div>
            </div>
        `;

        // Style modal
        Object.assign(modal.style, {
            position: 'fixed',
            top: '0',
            left: '0',
            right: '0',
            bottom: '0',
            zIndex: '10000',
            display: 'flex',
            alignItems: 'center',
            justifyContent: 'center',
            padding: '2rem'
        });

        // Add to page
        document.body.appendChild(modal);
        document.body.style.overflow = 'hidden';

        // Close handlers
        const closeButton = modal.querySelector('.video-modal-close');
        const backdrop = modal.querySelector('.video-modal-backdrop');

        const closeModal = () => {
            modal.style.opacity = '0';
            setTimeout(() => {
                document.body.removeChild(modal);
                document.body.style.overflow = '';
            }, 300);
        };

        closeButton.addEventListener('click', closeModal);
        backdrop.addEventListener('click', closeModal);

        // Escape key to close
        const escapeHandler = (e) => {
            if (e.key === 'Escape') {
                closeModal();
                document.removeEventListener('keydown', escapeHandler);
            }
        };
        document.addEventListener('keydown', escapeHandler);

        // Fade in
        modal.style.opacity = '0';
        modal.style.transition = 'opacity 0.3s ease-out';
        requestAnimationFrame(() => {
            modal.style.opacity = '1';
        });
    }

    // Add video modal styles
    const videoModalStyle = document.createElement('style');
    videoModalStyle.textContent = `
        .video-modal-backdrop {
            position: absolute;
            top: 0;
            left: 0;
            right: 0;
            bottom: 0;
            background: rgba(0, 0, 0, 0.9);
        }

        .video-modal-content {
            position: relative;
            width: 100%;
            max-width: 1200px;
            aspect-ratio: 16 / 9;
            background: #000;
            border-radius: 1rem;
            overflow: hidden;
        }

        .video-modal-close {
            position: absolute;
            top: -40px;
            right: 0;
            background: rgba(255, 255, 255, 0.1);
            color: white;
            border: none;
            width: 40px;
            height: 40px;
            border-radius: 50%;
            font-size: 24px;
            cursor: pointer;
            transition: all 0.3s ease;
            z-index: 10;
        }

        .video-modal-close:hover {
            background: rgba(255, 255, 255, 0.2);
            transform: scale(1.1);
        }

        .video-container {
            width: 100%;
            height: 100%;
        }

        @media (max-width: 768px) {
            .video-modal-content {
                max-width: 100%;
            }

            .video-modal-close {
                top: 10px;
                right: 10px;
            }
        }
    `;
    document.head.appendChild(videoModalStyle);

    // ===================================
    // Lazy Loading Images (if images are added)
    // ===================================

    const lazyImages = document.querySelectorAll('img[data-src]');

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

    lazyImages.forEach(img => imageObserver.observe(img));

    // ===================================
    // Console Easter Egg
    // ===================================

    console.log('%cSurgical Training Universe', 'color: #0A7AFF; font-size: 24px; font-weight: bold;');
    console.log('%cInterested in joining our team? Check out https://surgicaltraining.com/careers', 'color: #6B7280; font-size: 14px;');

    // ===================================
    // Performance Monitoring
    // ===================================

    // Log page load performance
    window.addEventListener('load', () => {
        setTimeout(() => {
            const perfData = performance.getEntriesByType('navigation')[0];
            console.log('Page Load Time:', Math.round(perfData.loadEventEnd - perfData.fetchStart), 'ms');
        }, 0);
    });

    // ===================================
    // Track Scroll Depth (for analytics)
    // ===================================

    let scrollDepthMarks = { 25: false, 50: false, 75: false, 100: false };

    window.addEventListener('scroll', () => {
        const scrollHeight = document.documentElement.scrollHeight - window.innerHeight;
        const scrolled = (window.scrollY / scrollHeight) * 100;

        // Check scroll depth milestones
        [25, 50, 75, 100].forEach(mark => {
            if (scrolled >= mark && !scrollDepthMarks[mark]) {
                scrollDepthMarks[mark] = true;

                // Track with analytics
                if (typeof gtag !== 'undefined') {
                    gtag('event', 'scroll_depth', {
                        'event_category': 'Engagement',
                        'event_label': `${mark}%`
                    });
                }
            }
        });
    });
});

// ===================================
// Utility Functions
// ===================================

// Debounce function
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

// Throttle function
function throttle(func, limit) {
    let inThrottle;
    return function(...args) {
        if (!inThrottle) {
            func.apply(this, args);
            inThrottle = true;
            setTimeout(() => inThrottle = false, limit);
        }
    };
}
