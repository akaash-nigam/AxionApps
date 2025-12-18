/**
 * Mystery Investigation Landing Page
 * Interactive JavaScript
 */

// Wait for DOM to load
document.addEventListener('DOMContentLoaded', function() {
    // Initialize all components
    initNavbar();
    initAOS();
    initTabSwitcher();
    initFAQ();
    initSmoothScroll();
    initMobileMenu();
});

/**
 * Navbar scroll effect
 */
function initNavbar() {
    const navbar = document.querySelector('.navbar');
    let lastScroll = 0;

    window.addEventListener('scroll', () => {
        const currentScroll = window.pageYOffset;

        // Add shadow on scroll
        if (currentScroll > 50) {
            navbar.style.boxShadow = '0 4px 6px -1px rgb(0 0 0 / 0.3)';
        } else {
            navbar.style.boxShadow = 'none';
        }

        lastScroll = currentScroll;
    });
}

/**
 * Scroll animations (AOS - Animate On Scroll)
 */
function initAOS() {
    const observerOptions = {
        threshold: 0.1,
        rootMargin: '0px 0px -100px 0px'
    };

    const observer = new IntersectionObserver((entries) => {
        entries.forEach(entry => {
            if (entry.isIntersecting) {
                entry.target.classList.add('aos-animate');

                // Optionally unobserve after animation
                // observer.unobserve(entry.target);
            }
        });
    }, observerOptions);

    // Observe all elements with data-aos attribute
    document.querySelectorAll('[data-aos]').forEach(el => {
        observer.observe(el);
    });
}

/**
 * Tab switcher for audience sections
 */
function initTabSwitcher() {
    const tabButtons = document.querySelectorAll('.tab-btn');
    const tabPanels = document.querySelectorAll('.audience-panel');

    tabButtons.forEach(button => {
        button.addEventListener('click', () => {
            const targetId = button.getAttribute('data-target');

            // Remove active class from all buttons and panels
            tabButtons.forEach(btn => btn.classList.remove('active'));
            tabPanels.forEach(panel => panel.classList.remove('active'));

            // Add active class to clicked button and corresponding panel
            button.classList.add('active');
            document.getElementById(targetId).classList.add('active');
        });
    });
}

/**
 * FAQ Accordion
 */
function initFAQ() {
    const faqItems = document.querySelectorAll('.faq-item');

    faqItems.forEach(item => {
        const question = item.querySelector('.faq-question');

        question.addEventListener('click', () => {
            // Toggle active class
            const wasActive = item.classList.contains('active');

            // Close all FAQ items
            faqItems.forEach(faq => faq.classList.remove('active'));

            // If wasn't active, open it
            if (!wasActive) {
                item.classList.add('active');
            }
        });
    });
}

/**
 * Smooth scrolling for anchor links
 */
function initSmoothScroll() {
    document.querySelectorAll('a[href^="#"]').forEach(anchor => {
        anchor.addEventListener('click', function (e) {
            const href = this.getAttribute('href');

            // Ignore # only links
            if (href === '#') return;

            e.preventDefault();

            const target = document.querySelector(href);
            if (target) {
                const offsetTop = target.offsetTop - 80; // Navbar height offset

                window.scrollTo({
                    top: offsetTop,
                    behavior: 'smooth'
                });
            }
        });
    });
}

/**
 * Mobile menu toggle
 */
function initMobileMenu() {
    const toggle = document.querySelector('.mobile-menu-toggle');
    const navLinks = document.querySelector('.nav-links');

    if (toggle) {
        toggle.addEventListener('click', () => {
            navLinks.classList.toggle('active');
            toggle.classList.toggle('active');
        });

        // Close menu when clicking a link
        navLinks.querySelectorAll('a').forEach(link => {
            link.addEventListener('click', () => {
                navLinks.classList.remove('active');
                toggle.classList.remove('active');
            });
        });

        // Close menu when clicking outside
        document.addEventListener('click', (e) => {
            if (!toggle.contains(e.target) && !navLinks.contains(e.target)) {
                navLinks.classList.remove('active');
                toggle.classList.remove('active');
            }
        });
    }
}

/**
 * Parallax effect for hero section
 */
function initParallax() {
    const hero = document.querySelector('.hero');
    const heroContent = document.querySelector('.hero-content');

    window.addEventListener('scroll', () => {
        const scrolled = window.pageYOffset;
        const parallaxSpeed = 0.5;

        if (heroContent) {
            heroContent.style.transform = `translateY(${scrolled * parallaxSpeed}px)`;
        }
    });
}

/**
 * Scroll progress indicator
 */
function initScrollProgress() {
    const progressBar = document.createElement('div');
    progressBar.className = 'scroll-progress';
    progressBar.style.cssText = `
        position: fixed;
        top: 0;
        left: 0;
        height: 3px;
        background: linear-gradient(90deg, var(--color-primary), var(--color-primary-dark));
        z-index: 9999;
        transition: width 0.1s ease;
    `;
    document.body.appendChild(progressBar);

    window.addEventListener('scroll', () => {
        const windowHeight = document.documentElement.scrollHeight - document.documentElement.clientHeight;
        const scrolled = (window.pageYOffset / windowHeight) * 100;
        progressBar.style.width = scrolled + '%';
    });
}

/**
 * Typing effect for hero title (optional)
 */
function initTypingEffect() {
    const subtitle = document.querySelector('.hero-subtitle');
    if (!subtitle) return;

    const text = subtitle.textContent;
    subtitle.textContent = '';
    subtitle.style.opacity = '1';

    let index = 0;
    const speed = 30; // ms per character

    function type() {
        if (index < text.length) {
            subtitle.textContent += text.charAt(index);
            index++;
            setTimeout(type, speed);
        }
    }

    // Start typing after a short delay
    setTimeout(type, 500);
}

/**
 * Stats counter animation
 */
function initStatsCounter() {
    const stats = document.querySelectorAll('.stat-number');

    const observerOptions = {
        threshold: 0.5
    };

    const observer = new IntersectionObserver((entries) => {
        entries.forEach(entry => {
            if (entry.isIntersecting && !entry.target.dataset.counted) {
                animateValue(entry.target);
                entry.target.dataset.counted = 'true';
            }
        });
    }, observerOptions);

    stats.forEach(stat => observer.observe(stat));
}

function animateValue(element) {
    const text = element.textContent;
    const number = parseInt(text.replace(/\D/g, ''));

    if (isNaN(number)) return;

    const duration = 2000; // 2 seconds
    const steps = 60;
    const stepValue = number / steps;
    let current = 0;
    let step = 0;

    const timer = setInterval(() => {
        current += stepValue;
        step++;

        if (step >= steps) {
            element.textContent = text; // Set final value
            clearInterval(timer);
        } else {
            // Format based on original text
            if (text.includes('+')) {
                element.textContent = Math.floor(current) + '+';
            } else if (text.includes('.')) {
                element.textContent = current.toFixed(1) + '★';
            } else {
                element.textContent = Math.floor(current);
            }
        }
    }, duration / steps);
}

/**
 * Form validation (if you add a contact form)
 */
function initFormValidation() {
    const forms = document.querySelectorAll('form');

    forms.forEach(form => {
        form.addEventListener('submit', (e) => {
            e.preventDefault();

            // Add your form validation logic here
            const formData = new FormData(form);

            // Example: Send to backend
            console.log('Form submitted:', Object.fromEntries(formData));

            // Show success message
            alert('Thank you! We\'ll be in touch soon.');
            form.reset();
        });
    });
}

/**
 * Video modal (for demo video)
 */
function initVideoModal() {
    const videoTriggers = document.querySelectorAll('a[href="#demo"]');

    videoTriggers.forEach(trigger => {
        trigger.addEventListener('click', (e) => {
            e.preventDefault();
            openVideoModal();
        });
    });
}

function openVideoModal() {
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
                    allow="autoplay; encrypted-media"
                    allowfullscreen>
                </iframe>
            </div>
        </div>
    `;

    // Add styles
    modal.style.cssText = `
        position: fixed;
        top: 0;
        left: 0;
        right: 0;
        bottom: 0;
        z-index: 10000;
        display: flex;
        align-items: center;
        justify-content: center;
    `;

    document.body.appendChild(modal);
    document.body.style.overflow = 'hidden';

    // Close handlers
    const closeBtn = modal.querySelector('.video-modal-close');
    const backdrop = modal.querySelector('.video-modal-backdrop');

    [closeBtn, backdrop].forEach(el => {
        el.addEventListener('click', () => {
            document.body.removeChild(modal);
            document.body.style.overflow = '';
        });
    });

    // Close on Escape key
    document.addEventListener('keydown', function escHandler(e) {
        if (e.key === 'Escape') {
            if (document.body.contains(modal)) {
                document.body.removeChild(modal);
                document.body.style.overflow = '';
            }
            document.removeEventListener('keydown', escHandler);
        }
    });
}

/**
 * Easter egg: Konami code
 */
function initKonamiCode() {
    const konamiCode = ['ArrowUp', 'ArrowUp', 'ArrowDown', 'ArrowDown', 'ArrowLeft', 'ArrowRight', 'ArrowLeft', 'ArrowRight', 'b', 'a'];
    let konamiIndex = 0;

    document.addEventListener('keydown', (e) => {
        if (e.key === konamiCode[konamiIndex]) {
            konamiIndex++;
            if (konamiIndex === konamiCode.length) {
                activateDetectiveMode();
                konamiIndex = 0;
            }
        } else {
            konamiIndex = 0;
        }
    });
}

function activateDetectiveMode() {
    // Fun easter egg - add detective hat to cursor or show secret message
    document.body.style.cursor = 'url("data:image/svg+xml,%3Csvg xmlns=\'http://www.w3.org/2000/svg\' width=\'32\' height=\'32\' viewBox=\'0 0 32 32\'%3E%3Ctext y=\'24\' font-size=\'24\'%3E🕵️%3C/text%3E%3C/svg%3E"), auto';

    setTimeout(() => {
        alert('🕵️ Detective mode activated! You found the secret!');
    }, 100);

    setTimeout(() => {
        document.body.style.cursor = '';
    }, 10000);
}

// Initialize additional features
initScrollProgress();
initStatsCounter();
initVideoModal();
initKonamiCode();

// Console easter egg
console.log('%c🔍 Mystery Investigation', 'font-size: 24px; font-weight: bold; color: #FFB800;');
console.log('%cLooking for clues in the console? Nice detective work!', 'font-size: 14px; color: #A0A8C0;');
console.log('%cJoin us: https://mysteryin vestigation.com', 'font-size: 12px; color: #6B7280;');
