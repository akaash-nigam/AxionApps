/**
 * Parkour Pathways - Landing Page JavaScript
 * Interactive elements and animations
 */

(function() {
    'use strict';

    // =========================================================================
    // Initialize AOS (Animate On Scroll)
    // =========================================================================

    AOS.init({
        duration: 800,
        easing: 'ease-out-cubic',
        once: true,
        offset: 100,
        disable: 'mobile'
    });

    // =========================================================================
    // Navigation
    // =========================================================================

    const nav = document.getElementById('nav');
    const navToggle = document.getElementById('nav-toggle');
    const navMenu = document.getElementById('nav-menu');

    // Scroll effect
    let lastScroll = 0;

    window.addEventListener('scroll', () => {
        const currentScroll = window.pageYOffset;

        // Add scrolled class when page is scrolled
        if (currentScroll > 50) {
            nav.classList.add('scrolled');
        } else {
            nav.classList.remove('scrolled');
        }

        // Hide nav on scroll down, show on scroll up
        if (currentScroll > lastScroll && currentScroll > 500) {
            nav.style.transform = 'translateY(-100%)';
        } else {
            nav.style.transform = 'translateY(0)';
        }

        lastScroll = currentScroll;
    });

    // Mobile menu toggle
    if (navToggle) {
        navToggle.addEventListener('click', () => {
            navMenu.classList.toggle('active');
            navToggle.classList.toggle('active');
        });
    }

    // Smooth scroll for anchor links
    document.querySelectorAll('a[href^="#"]').forEach(anchor => {
        anchor.addEventListener('click', function(e) {
            e.preventDefault();
            const target = document.querySelector(this.getAttribute('href'));

            if (target) {
                const offsetTop = target.offsetTop - 80; // Account for fixed nav

                window.scrollTo({
                    top: offsetTop,
                    behavior: 'smooth'
                });

                // Close mobile menu if open
                if (navMenu.classList.contains('active')) {
                    navMenu.classList.remove('active');
                    navToggle.classList.remove('active');
                }
            }
        });
    });

    // =========================================================================
    // Pricing Toggle (Monthly/Annual)
    // =========================================================================

    const pricingToggle = document.getElementById('pricing-toggle');

    if (pricingToggle) {
        pricingToggle.addEventListener('change', function() {
            const monthlyPrices = document.querySelectorAll('.monthly-price');
            const annualPrices = document.querySelectorAll('.annual-price');

            if (this.checked) {
                // Show annual pricing
                monthlyPrices.forEach(price => price.style.display = 'none');
                annualPrices.forEach(price => price.style.display = 'inline');
            } else {
                // Show monthly pricing
                monthlyPrices.forEach(price => price.style.display = 'inline');
                annualPrices.forEach(price => price.style.display = 'none');
            }
        });
    }

    // =========================================================================
    // FAQ Accordion
    // =========================================================================

    const faqQuestions = document.querySelectorAll('.faq-question');

    faqQuestions.forEach(question => {
        question.addEventListener('click', () => {
            const faqItem = question.parentElement;
            const isActive = faqItem.classList.contains('active');

            // Close all FAQ items
            document.querySelectorAll('.faq-item').forEach(item => {
                item.classList.remove('active');
            });

            // Toggle current item (unless it was already active)
            if (!isActive) {
                faqItem.classList.add('active');
            }
        });
    });

    // =========================================================================
    // Video Demo Play Button
    // =========================================================================

    const playButton = document.querySelector('.play-button');
    const videoPlaceholder = document.querySelector('.video-placeholder');

    if (playButton && videoPlaceholder) {
        playButton.addEventListener('click', () => {
            // In a real implementation, this would open a video modal
            // or load a video player
            console.log('Play video demo');

            // Example: Open video in modal
            showVideoModal('https://www.youtube.com/embed/your-video-id');
        });
    }

    // =========================================================================
    // Stats Counter Animation
    // =========================================================================

    function animateCounter(element, target, duration = 2000) {
        const start = 0;
        const increment = target / (duration / 16); // 60 FPS
        let current = start;

        const timer = setInterval(() => {
            current += increment;

            if (current >= target) {
                element.textContent = formatNumber(target);
                clearInterval(timer);
            } else {
                element.textContent = formatNumber(Math.floor(current));
            }
        }, 16);
    }

    function formatNumber(num) {
        if (num >= 1000000) {
            return (num / 1000000).toFixed(1) + 'M';
        } else if (num >= 1000) {
            return (num / 1000).toFixed(1) + 'K';
        }
        return num.toString();
    }

    // Trigger counter animation when stats come into view
    const statsObserver = new IntersectionObserver((entries) => {
        entries.forEach(entry => {
            if (entry.isIntersecting) {
                const statValue = entry.target;
                const targetValue = parseInt(statValue.dataset.value);

                if (targetValue && !statValue.classList.contains('animated')) {
                    animateCounter(statValue, targetValue);
                    statValue.classList.add('animated');
                }
            }
        });
    }, { threshold: 0.5 });

    document.querySelectorAll('.stat-value').forEach(stat => {
        // Store the target value as a data attribute
        const text = stat.textContent;
        let value = 0;

        if (text.includes('K+')) {
            value = parseInt(text.replace('K+', '')) * 1000;
        } else if (text.includes('M+')) {
            value = parseInt(text.replace('M+', '')) * 1000000;
        } else {
            value = parseFloat(text);
        }

        stat.dataset.value = value;
        stat.textContent = '0';
        statsObserver.observe(stat);
    });

    // =========================================================================
    // Feature Cards Hover Effect
    // =========================================================================

    const featureCards = document.querySelectorAll('.feature-card');

    featureCards.forEach(card => {
        card.addEventListener('mousemove', (e) => {
            const rect = card.getBoundingClientRect();
            const x = e.clientX - rect.left;
            const y = e.clientY - rect.top;

            // Create subtle gradient effect following mouse
            card.style.setProperty('--mouse-x', `${x}px`);
            card.style.setProperty('--mouse-y', `${y}px`);
        });
    });

    // =========================================================================
    // Testimonial Cards Rotation
    // =========================================================================

    let currentTestimonial = 0;
    const testimonialCards = document.querySelectorAll('.testimonial-card');
    const autoRotateDelay = 5000; // 5 seconds

    function rotateTestimonials() {
        if (testimonialCards.length === 0) return;

        // Remove highlight from current
        testimonialCards.forEach(card => card.classList.remove('highlighted'));

        // Add highlight to next
        currentTestimonial = (currentTestimonial + 1) % testimonialCards.length;
        testimonialCards[currentTestimonial].classList.add('highlighted');
    }

    // Auto-rotate testimonials
    setInterval(rotateTestimonials, autoRotateDelay);

    // =========================================================================
    // Parallax Effect for Hero Background
    // =========================================================================

    const heroGradient = document.querySelector('.hero-gradient');

    if (heroGradient) {
        window.addEventListener('scroll', () => {
            const scrolled = window.pageYOffset;
            const parallaxSpeed = 0.5;

            heroGradient.style.transform = `translateX(-50%) translateY(${scrolled * parallaxSpeed}px)`;
        });
    }

    // =========================================================================
    // CTA Button Click Tracking
    // =========================================================================

    document.querySelectorAll('.btn-primary').forEach(button => {
        button.addEventListener('click', (e) => {
            // Track button click (integrate with analytics)
            const buttonText = button.textContent.trim();
            console.log('CTA clicked:', buttonText);

            // Send to analytics
            if (window.gtag) {
                window.gtag('event', 'cta_click', {
                    'button_text': buttonText,
                    'button_location': button.closest('section')?.className || 'unknown'
                });
            }
        });
    });

    // =========================================================================
    // Email Newsletter Signup (Placeholder)
    // =========================================================================

    function setupNewsletterForm() {
        const forms = document.querySelectorAll('.newsletter-form');

        forms.forEach(form => {
            form.addEventListener('submit', async (e) => {
                e.preventDefault();

                const email = form.querySelector('input[type="email"]').value;
                const submitButton = form.querySelector('button[type="submit"]');
                const originalText = submitButton.textContent;

                // Show loading state
                submitButton.textContent = 'Subscribing...';
                submitButton.disabled = true;

                try {
                    // In production, send to your email service
                    await fetch('/api/newsletter/subscribe', {
                        method: 'POST',
                        headers: {
                            'Content-Type': 'application/json'
                        },
                        body: JSON.stringify({ email })
                    });

                    // Show success message
                    submitButton.textContent = '✓ Subscribed!';
                    submitButton.classList.add('success');
                    form.reset();

                    // Track subscription
                    if (window.gtag) {
                        window.gtag('event', 'newsletter_signup', {
                            'method': 'landing_page'
                        });
                    }
                } catch (error) {
                    console.error('Newsletter signup error:', error);
                    submitButton.textContent = 'Try Again';
                } finally {
                    setTimeout(() => {
                        submitButton.textContent = originalText;
                        submitButton.disabled = false;
                        submitButton.classList.remove('success');
                    }, 3000);
                }
            });
        });
    }

    setupNewsletterForm();

    // =========================================================================
    // Video Modal (for demo playback)
    // =========================================================================

    function showVideoModal(videoUrl) {
        // Create modal overlay
        const modal = document.createElement('div');
        modal.className = 'video-modal';
        modal.innerHTML = `
            <div class="video-modal-overlay"></div>
            <div class="video-modal-content">
                <button class="video-modal-close">&times;</button>
                <iframe
                    src="${videoUrl}?autoplay=1"
                    frameborder="0"
                    allow="accelerometer; autoplay; clipboard-write; encrypted-media; gyroscope; picture-in-picture"
                    allowfullscreen
                ></iframe>
            </div>
        `;

        document.body.appendChild(modal);
        document.body.style.overflow = 'hidden';

        // Animate in
        setTimeout(() => modal.classList.add('active'), 10);

        // Close modal
        const closeModal = () => {
            modal.classList.remove('active');
            setTimeout(() => {
                document.body.removeChild(modal);
                document.body.style.overflow = '';
            }, 300);
        };

        modal.querySelector('.video-modal-close').addEventListener('click', closeModal);
        modal.querySelector('.video-modal-overlay').addEventListener('click', closeModal);

        // Close on Escape key
        const escapeHandler = (e) => {
            if (e.key === 'Escape') {
                closeModal();
                document.removeEventListener('keydown', escapeHandler);
            }
        };
        document.addEventListener('keydown', escapeHandler);
    }

    // Add video modal styles dynamically
    const videoModalStyles = `
        <style>
            .video-modal {
                position: fixed;
                inset: 0;
                z-index: 10000;
                display: flex;
                align-items: center;
                justify-content: center;
                opacity: 0;
                transition: opacity 0.3s ease;
            }

            .video-modal.active {
                opacity: 1;
            }

            .video-modal-overlay {
                position: absolute;
                inset: 0;
                background: rgba(0, 0, 0, 0.9);
                backdrop-filter: blur(10px);
            }

            .video-modal-content {
                position: relative;
                width: 90%;
                max-width: 1200px;
                aspect-ratio: 16 / 9;
                background: #000;
                border-radius: 1rem;
                overflow: hidden;
                transform: scale(0.9);
                transition: transform 0.3s ease;
            }

            .video-modal.active .video-modal-content {
                transform: scale(1);
            }

            .video-modal-content iframe {
                width: 100%;
                height: 100%;
            }

            .video-modal-close {
                position: absolute;
                top: -50px;
                right: 0;
                width: 40px;
                height: 40px;
                background: rgba(255, 255, 255, 0.1);
                backdrop-filter: blur(10px);
                border: 1px solid rgba(255, 255, 255, 0.2);
                border-radius: 50%;
                color: white;
                font-size: 24px;
                cursor: pointer;
                transition: all 0.2s ease;
                display: flex;
                align-items: center;
                justify-content: center;
            }

            .video-modal-close:hover {
                background: rgba(255, 255, 255, 0.2);
                transform: scale(1.1);
            }
        </style>
    `;

    document.head.insertAdjacentHTML('beforeend', videoModalStyles);

    // =========================================================================
    // Performance Monitoring
    // =========================================================================

    // Log page load time
    window.addEventListener('load', () => {
        const loadTime = performance.now();
        console.log(`Page loaded in ${loadTime.toFixed(2)}ms`);

        // Send to analytics
        if (window.gtag) {
            window.gtag('event', 'timing_complete', {
                'name': 'page_load',
                'value': Math.round(loadTime),
                'event_category': 'performance'
            });
        }
    });

    // =========================================================================
    // Scroll Progress Indicator
    // =========================================================================

    function createScrollProgress() {
        const indicator = document.createElement('div');
        indicator.className = 'scroll-progress';
        indicator.innerHTML = '<div class="scroll-progress-bar"></div>';
        document.body.appendChild(indicator);

        const progressBar = indicator.querySelector('.scroll-progress-bar');

        window.addEventListener('scroll', () => {
            const windowHeight = document.documentElement.scrollHeight - window.innerHeight;
            const scrolled = (window.pageYOffset / windowHeight) * 100;
            progressBar.style.width = `${scrolled}%`;
        });
    }

    createScrollProgress();

    // Add scroll progress styles
    const scrollProgressStyles = `
        <style>
            .scroll-progress {
                position: fixed;
                top: 0;
                left: 0;
                right: 0;
                height: 3px;
                z-index: 10001;
                background: rgba(255, 255, 255, 0.1);
            }

            .scroll-progress-bar {
                height: 100%;
                background: linear-gradient(90deg, #00D9FF 0%, #7B61FF 100%);
                width: 0%;
                transition: width 0.2s ease;
            }
        </style>
    `;

    document.head.insertAdjacentHTML('beforeend', scrollProgressStyles);

    // =========================================================================
    // Copy to Clipboard (for code examples if needed)
    // =========================================================================

    function setupCopyButtons() {
        document.querySelectorAll('.copy-button').forEach(button => {
            button.addEventListener('click', async () => {
                const code = button.getAttribute('data-copy');

                try {
                    await navigator.clipboard.writeText(code);

                    const originalText = button.textContent;
                    button.textContent = '✓ Copied!';

                    setTimeout(() => {
                        button.textContent = originalText;
                    }, 2000);
                } catch (err) {
                    console.error('Failed to copy:', err);
                }
            });
        });
    }

    setupCopyButtons();

    // =========================================================================
    // Lazy Loading Images (if images are added later)
    // =========================================================================

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

    document.querySelectorAll('img[data-src]').forEach(img => {
        imageObserver.observe(img);
    });

    // =========================================================================
    // Debug Mode (dev only)
    // =========================================================================

    if (window.location.hostname === 'localhost' || window.location.hostname === '127.0.0.1') {
        console.log('%c🎮 Parkour Pathways Landing Page', 'font-size: 20px; font-weight: bold; color: #00D9FF');
        console.log('%cDebug mode enabled', 'color: #7B61FF');

        // Add debug info to window object
        window.parkourDebug = {
            version: '2.0.0',
            features: {
                aos: typeof AOS !== 'undefined',
                smoothScroll: true,
                videoModal: true,
                analytics: typeof gtag !== 'undefined'
            }
        };
    }

    // =========================================================================
    // Initialize Everything
    // =========================================================================

    console.log('✓ Parkour Pathways landing page initialized');

})();
