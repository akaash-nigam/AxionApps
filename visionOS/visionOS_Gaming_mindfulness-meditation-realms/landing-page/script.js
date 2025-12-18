// Mindfulness Meditation Realms - Landing Page JavaScript

// Smooth scrolling for navigation links
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

// Scroll reveal animation
const observerOptions = {
    threshold: 0.1,
    rootMargin: '0px 0px -50px 0px'
};

const observer = new IntersectionObserver((entries) => {
    entries.forEach(entry => {
        if (entry.isIntersecting) {
            entry.target.classList.add('revealed');
        }
    });
}, observerOptions);

// Observe all sections and cards
document.addEventListener('DOMContentLoaded', () => {
    const elementsToReveal = document.querySelectorAll(
        '.feature-card, .environment-item, .testimonial-card, .benefit-item, .pricing-card, .faq-item'
    );

    elementsToReveal.forEach(el => {
        el.classList.add('scroll-reveal');
        observer.observe(el);
    });
});

// Navbar background on scroll
let lastScroll = 0;
const nav = document.querySelector('.nav');

window.addEventListener('scroll', () => {
    const currentScroll = window.pageYOffset;

    if (currentScroll > 100) {
        nav.style.boxShadow = '0 2px 16px rgba(0, 0, 0, 0.1)';
    } else {
        nav.style.boxShadow = 'none';
    }

    lastScroll = currentScroll;
});

// Animate statistics on scroll into view
const animateStats = () => {
    const stats = document.querySelectorAll('.stat-number');
    const statsObserver = new IntersectionObserver((entries) => {
        entries.forEach(entry => {
            if (entry.isIntersecting && !entry.target.classList.contains('animated')) {
                const target = entry.target;
                const text = target.textContent;
                const hasPercent = text.includes('%');
                const hasStar = text.includes('★');
                const number = parseFloat(text);

                if (!isNaN(number)) {
                    animateNumber(target, 0, number, 1500, hasPercent, hasStar);
                    target.classList.add('animated');
                }
            }
        });
    }, { threshold: 0.5 });

    stats.forEach(stat => statsObserver.observe(stat));
};

function animateNumber(element, start, end, duration, hasPercent, hasStar) {
    const range = end - start;
    const increment = range / (duration / 16); // 60fps
    let current = start;

    const timer = setInterval(() => {
        current += increment;
        if (current >= end) {
            current = end;
            clearInterval(timer);
        }

        let displayValue = Math.round(current * 10) / 10;
        if (hasStar) {
            element.textContent = displayValue + '★';
        } else if (hasPercent) {
            element.textContent = Math.round(current) + '%';
        } else {
            element.textContent = displayValue;
        }
    }, 16);
}

// Initialize stats animation
document.addEventListener('DOMContentLoaded', animateStats);

// Animate progress bars when they come into view
const animateProgressBars = () => {
    const bars = document.querySelectorAll('.bar-fill');
    const barObserver = new IntersectionObserver((entries) => {
        entries.forEach(entry => {
            if (entry.isIntersecting) {
                const bar = entry.target;
                const width = bar.style.width;
                bar.style.width = '0%';
                setTimeout(() => {
                    bar.style.width = width;
                }, 100);
            }
        });
    }, { threshold: 0.5 });

    bars.forEach(bar => barObserver.observe(bar));
};

document.addEventListener('DOMContentLoaded', animateProgressBars);

// Environment carousel auto-scroll (optional)
const initEnvironmentCarousel = () => {
    const carousel = document.querySelector('.environment-carousel');
    if (!carousel) return;

    let isScrolling = false;

    carousel.addEventListener('mouseenter', () => {
        isScrolling = false;
    });

    carousel.addEventListener('mouseleave', () => {
        isScrolling = true;
    });

    // Add keyboard navigation
    document.addEventListener('keydown', (e) => {
        const focusedElement = document.activeElement;
        if (!focusedElement.closest('.environment-item')) return;

        if (e.key === 'ArrowLeft' || e.key === 'ArrowRight') {
            e.preventDefault();
            const items = Array.from(document.querySelectorAll('.environment-item'));
            const currentIndex = items.indexOf(focusedElement.closest('.environment-item'));

            if (e.key === 'ArrowLeft' && currentIndex > 0) {
                items[currentIndex - 1].focus();
            } else if (e.key === 'ArrowRight' && currentIndex < items.length - 1) {
                items[currentIndex + 1].focus();
            }
        }
    });
};

document.addEventListener('DOMContentLoaded', initEnvironmentCarousel);

// Add click animation to CTA buttons
document.querySelectorAll('.btn').forEach(button => {
    button.addEventListener('click', function(e) {
        // Create ripple effect
        const ripple = document.createElement('span');
        const rect = this.getBoundingClientRect();
        const size = Math.max(rect.width, rect.height);
        const x = e.clientX - rect.left - size / 2;
        const y = e.clientY - rect.top - size / 2;

        ripple.style.width = ripple.style.height = size + 'px';
        ripple.style.left = x + 'px';
        ripple.style.top = y + 'px';
        ripple.classList.add('ripple');

        this.appendChild(ripple);

        setTimeout(() => {
            ripple.remove();
        }, 600);
    });
});

// Add ripple CSS if not already in stylesheet
const addRippleStyles = () => {
    const style = document.createElement('style');
    style.textContent = `
        .btn {
            position: relative;
            overflow: hidden;
        }
        .ripple {
            position: absolute;
            border-radius: 50%;
            background: rgba(255, 255, 255, 0.5);
            transform: scale(0);
            animation: ripple-animation 0.6s ease-out;
            pointer-events: none;
        }
        @keyframes ripple-animation {
            to {
                transform: scale(4);
                opacity: 0;
            }
        }
    `;
    document.head.appendChild(style);
};

document.addEventListener('DOMContentLoaded', addRippleStyles);

// FAQ accordion functionality (optional enhancement)
const initFAQ = () => {
    const faqItems = document.querySelectorAll('.faq-item');

    faqItems.forEach(item => {
        const question = item.querySelector('h4');
        const answer = item.querySelector('p');

        if (question && answer) {
            question.style.cursor = 'pointer';
            question.style.userSelect = 'none';

            // Initially show all answers (no accordion)
            // To make it accordion-style, uncomment below:
            /*
            answer.style.maxHeight = '0';
            answer.style.overflow = 'hidden';
            answer.style.transition = 'max-height 0.3s ease';

            question.addEventListener('click', () => {
                const isOpen = answer.style.maxHeight !== '0px';

                if (isOpen) {
                    answer.style.maxHeight = '0';
                } else {
                    answer.style.maxHeight = answer.scrollHeight + 'px';
                }
            });
            */
        }
    });
};

document.addEventListener('DOMContentLoaded', initFAQ);

// Parallax effect for hero orbs (subtle)
const initParallax = () => {
    const orbs = document.querySelectorAll('.floating-orb');

    window.addEventListener('scroll', () => {
        const scrolled = window.pageYOffset;

        orbs.forEach((orb, index) => {
            const speed = 0.1 + (index * 0.05);
            const yPos = -(scrolled * speed);
            orb.style.transform = `translateY(${yPos}px)`;
        });
    });
};

document.addEventListener('DOMContentLoaded', initParallax);

// Track CTA clicks (replace with actual analytics)
const trackCTAClicks = () => {
    const ctaButtons = document.querySelectorAll('.btn-primary');

    ctaButtons.forEach(button => {
        button.addEventListener('click', (e) => {
            const ctaText = button.textContent.trim();
            console.log('CTA Clicked:', ctaText);

            // Example: Google Analytics event
            // gtag('event', 'cta_click', {
            //     'event_category': 'engagement',
            //     'event_label': ctaText
            // });

            // Example: Custom analytics
            // analytics.track('CTA Click', {
            //     text: ctaText,
            //     location: window.location.pathname
            // });
        });
    });
};

document.addEventListener('DOMContentLoaded', trackCTAClicks);

// Mobile menu toggle (if needed)
const initMobileMenu = () => {
    // Add a hamburger menu for mobile if nav-links are hidden
    // This is a basic implementation - enhance as needed

    const nav = document.querySelector('.nav');
    const navContent = document.querySelector('.nav-content');

    // Check if we're on mobile
    if (window.innerWidth <= 768) {
        // Create hamburger button if it doesn't exist
        if (!document.querySelector('.mobile-menu-toggle')) {
            const mobileToggle = document.createElement('button');
            mobileToggle.classList.add('mobile-menu-toggle');
            mobileToggle.innerHTML = '☰';
            mobileToggle.style.cssText = `
                background: none;
                border: none;
                font-size: 1.5rem;
                cursor: pointer;
                color: var(--primary);
                padding: 0.5rem;
            `;

            const navLinks = document.querySelector('.nav-links');
            navContent.insertBefore(mobileToggle, navLinks);

            mobileToggle.addEventListener('click', () => {
                navLinks.style.display = navLinks.style.display === 'flex' ? 'none' : 'flex';
                navLinks.style.flexDirection = 'column';
                navLinks.style.position = 'absolute';
                navLinks.style.top = '100%';
                navLinks.style.left = '0';
                navLinks.style.right = '0';
                navLinks.style.background = 'white';
                navLinks.style.padding = '1rem';
                navLinks.style.boxShadow = '0 4px 16px rgba(0,0,0,0.1)';
            });
        }
    }
};

window.addEventListener('resize', initMobileMenu);
document.addEventListener('DOMContentLoaded', initMobileMenu);

// Lazy load images (if images are added later)
const lazyLoadImages = () => {
    const images = document.querySelectorAll('img[data-src]');

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

    images.forEach(img => imageObserver.observe(img));
};

document.addEventListener('DOMContentLoaded', lazyLoadImages);

// Add floating animation to badges
const animateBadges = () => {
    const badges = document.querySelectorAll('.badge, .feature-badge, .pricing-badge');

    badges.forEach((badge, index) => {
        badge.style.animation = `float 3s ease-in-out infinite`;
        badge.style.animationDelay = `${index * 0.2}s`;
    });
};

document.addEventListener('DOMContentLoaded', animateBadges);

console.log('🕊️ Mindfulness Meditation Realms - Landing Page Loaded');
