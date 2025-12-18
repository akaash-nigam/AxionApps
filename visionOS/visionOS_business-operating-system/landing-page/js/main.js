// Business Operating System Landing Page - Main JavaScript
// Handles interactivity, animations, and form submissions

document.addEventListener('DOMContentLoaded', () => {
    initializeNavigation();
    initializeUseCaseTabs();
    initializeFormHandling();
    initializeScrollAnimations();
    initializeSpatialCanvas();
});

// ============================================================================
// Navigation
// ============================================================================

function initializeNavigation() {
    const nav = document.querySelector('nav');
    const mobileMenuToggle = document.querySelector('.mobile-menu-toggle');
    const navLinks = document.querySelector('.nav-links');

    // Navbar scroll effect
    let lastScroll = 0;
    window.addEventListener('scroll', () => {
        const currentScroll = window.pageYOffset;

        if (currentScroll > 50) {
            nav.style.background = 'rgba(0, 0, 0, 0.95)';
            nav.style.backdropFilter = 'blur(20px)';
        } else {
            nav.style.background = 'rgba(0, 0, 0, 0.8)';
            nav.style.backdropFilter = 'blur(10px)';
        }

        lastScroll = currentScroll;
    });

    // Mobile menu toggle (if implemented)
    if (mobileMenuToggle) {
        mobileMenuToggle.addEventListener('click', () => {
            navLinks.classList.toggle('active');
        });
    }

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

                // Close mobile menu if open
                if (navLinks.classList.contains('active')) {
                    navLinks.classList.remove('active');
                }
            }
        });
    });
}

// ============================================================================
// Use Case Tabs
// ============================================================================

function initializeUseCaseTabs() {
    const tabButtons = document.querySelectorAll('.tab-button');
    const tabContents = document.querySelectorAll('.tab-content');

    tabButtons.forEach(button => {
        button.addEventListener('click', () => {
            const targetTab = button.dataset.tab;

            // Remove active class from all buttons and contents
            tabButtons.forEach(btn => btn.classList.remove('active'));
            tabContents.forEach(content => {
                content.classList.remove('active');
                // Fade out effect
                content.style.opacity = '0';
            });

            // Add active class to clicked button
            button.classList.add('active');

            // Show target content with fade in
            const targetContent = document.getElementById(targetTab);
            if (targetContent) {
                setTimeout(() => {
                    targetContent.classList.add('active');
                    setTimeout(() => {
                        targetContent.style.opacity = '1';
                    }, 10);
                }, 150);
            }
        });
    });
}

// ============================================================================
// Form Handling
// ============================================================================

function initializeFormHandling() {
    const demoForm = document.getElementById('demo-form');
    const ctaButtons = document.querySelectorAll('.cta-button');

    // Handle CTA button clicks
    ctaButtons.forEach(button => {
        button.addEventListener('click', (e) => {
            // If it's a "Get Started" or "Request Demo" button, scroll to form
            if (button.textContent.includes('Get Started') ||
                button.textContent.includes('Request Demo') ||
                button.textContent.includes('Schedule Demo')) {
                e.preventDefault();
                const ctaSection = document.querySelector('.cta-section');
                if (ctaSection) {
                    ctaSection.scrollIntoView({ behavior: 'smooth' });
                    // Focus on first input
                    setTimeout(() => {
                        const firstInput = demoForm.querySelector('input');
                        if (firstInput) firstInput.focus();
                    }, 500);
                }
            }
        });
    });

    // Handle form submission
    if (demoForm) {
        demoForm.addEventListener('submit', async (e) => {
            e.preventDefault();

            const formData = new FormData(demoForm);
            const data = {
                name: formData.get('name'),
                email: formData.get('email'),
                company: formData.get('company'),
                role: formData.get('role')
            };

            // Validate form
            if (!validateForm(data)) {
                return;
            }

            // Show loading state
            const submitButton = demoForm.querySelector('button[type="submit"]');
            const originalText = submitButton.textContent;
            submitButton.disabled = true;
            submitButton.textContent = 'Submitting...';
            submitButton.style.opacity = '0.6';

            // Simulate API call (replace with actual endpoint)
            try {
                await simulateFormSubmission(data);

                // Show success message
                showFormMessage('success', 'Thank you! We\'ll contact you within 24 hours to schedule your personalized demo.');

                // Reset form
                demoForm.reset();

                // Track analytics (if implemented)
                trackEvent('demo_request', data);

            } catch (error) {
                showFormMessage('error', 'Something went wrong. Please try again or contact us at demo@bos-enterprise.com');
            } finally {
                // Restore button state
                submitButton.disabled = false;
                submitButton.textContent = originalText;
                submitButton.style.opacity = '1';
            }
        });
    }
}

function validateForm(data) {
    // Name validation
    if (!data.name || data.name.trim().length < 2) {
        showFormMessage('error', 'Please enter your full name.');
        return false;
    }

    // Email validation
    const emailRegex = /^[^\s@]+@[^\s@]+\.[^\s@]+$/;
    if (!data.email || !emailRegex.test(data.email)) {
        showFormMessage('error', 'Please enter a valid email address.');
        return false;
    }

    // Company validation
    if (!data.company || data.company.trim().length < 2) {
        showFormMessage('error', 'Please enter your company name.');
        return false;
    }

    // Role validation
    if (!data.role || data.role === '') {
        showFormMessage('error', 'Please select your role.');
        return false;
    }

    return true;
}

function showFormMessage(type, message) {
    // Remove existing messages
    const existingMessage = document.querySelector('.form-message');
    if (existingMessage) {
        existingMessage.remove();
    }

    // Create new message
    const messageDiv = document.createElement('div');
    messageDiv.className = `form-message form-message-${type}`;
    messageDiv.textContent = message;

    // Style the message
    messageDiv.style.padding = '16px';
    messageDiv.style.marginTop = '16px';
    messageDiv.style.borderRadius = '12px';
    messageDiv.style.fontSize = '14px';
    messageDiv.style.fontWeight = '500';
    messageDiv.style.animation = 'fadeInUp 0.3s ease';

    if (type === 'success') {
        messageDiv.style.background = 'rgba(52, 199, 89, 0.1)';
        messageDiv.style.border = '1px solid rgba(52, 199, 89, 0.3)';
        messageDiv.style.color = '#34C759';
    } else {
        messageDiv.style.background = 'rgba(255, 59, 48, 0.1)';
        messageDiv.style.border = '1px solid rgba(255, 59, 48, 0.3)';
        messageDiv.style.color = '#FF3B30';
    }

    // Insert after form
    const demoForm = document.getElementById('demo-form');
    demoForm.parentNode.insertBefore(messageDiv, demoForm.nextSibling);

    // Auto-remove success messages after 5 seconds
    if (type === 'success') {
        setTimeout(() => {
            messageDiv.style.opacity = '0';
            setTimeout(() => messageDiv.remove(), 300);
        }, 5000);
    }
}

async function simulateFormSubmission(data) {
    // TODO: Replace with actual API endpoint
    // Example: await fetch('/api/demo-request', { method: 'POST', body: JSON.stringify(data) })

    // Simulate network delay
    return new Promise((resolve) => {
        setTimeout(() => {
            console.log('Demo request submitted:', data);
            resolve();
        }, 1500);
    });
}

// ============================================================================
// Scroll Animations
// ============================================================================

function initializeScrollAnimations() {
    const observerOptions = {
        threshold: 0.1,
        rootMargin: '0px 0px -50px 0px'
    };

    const observer = new IntersectionObserver((entries) => {
        entries.forEach(entry => {
            if (entry.isIntersecting) {
                entry.target.style.opacity = '1';
                entry.target.style.transform = 'translateY(0)';
            }
        });
    }, observerOptions);

    // Observe elements that should animate on scroll
    const animatedElements = document.querySelectorAll('.benefit-card, .feature-item, .use-case-card, .pricing-card, .testimonial-card');

    animatedElements.forEach((el, index) => {
        // Set initial state
        el.style.opacity = '0';
        el.style.transform = 'translateY(30px)';
        el.style.transition = `opacity 0.6s ease ${index * 0.1}s, transform 0.6s ease ${index * 0.1}s`;

        // Observe
        observer.observe(el);
    });

    // Parallax effect for gradient orbs
    window.addEventListener('scroll', () => {
        const scrolled = window.pageYOffset;
        const orbs = document.querySelectorAll('.gradient-orb');

        orbs.forEach((orb, index) => {
            const speed = 0.2 + (index * 0.1);
            const yPos = -(scrolled * speed);
            orb.style.transform = `translateY(${yPos}px)`;
        });
    });
}

// ============================================================================
// Spatial Canvas (Optional Enhancement)
// ============================================================================

function initializeSpatialCanvas() {
    const heroSection = document.querySelector('.hero');
    if (!heroSection) return;

    // Create canvas for particle effects
    const canvas = document.createElement('canvas');
    canvas.className = 'spatial-canvas';
    canvas.style.position = 'absolute';
    canvas.style.top = '0';
    canvas.style.left = '0';
    canvas.style.width = '100%';
    canvas.style.height = '100%';
    canvas.style.pointerEvents = 'none';
    canvas.style.zIndex = '1';

    heroSection.style.position = 'relative';
    heroSection.insertBefore(canvas, heroSection.firstChild);

    const ctx = canvas.getContext('2d');
    let particles = [];
    let animationFrame;

    // Resize canvas
    function resizeCanvas() {
        canvas.width = heroSection.offsetWidth;
        canvas.height = heroSection.offsetHeight;
    }

    // Particle class
    class Particle {
        constructor() {
            this.x = Math.random() * canvas.width;
            this.y = Math.random() * canvas.height;
            this.size = Math.random() * 2 + 1;
            this.speedX = (Math.random() - 0.5) * 0.5;
            this.speedY = (Math.random() - 0.5) * 0.5;
            this.opacity = Math.random() * 0.5 + 0.2;
        }

        update() {
            this.x += this.speedX;
            this.y += this.speedY;

            // Wrap around edges
            if (this.x > canvas.width) this.x = 0;
            if (this.x < 0) this.x = canvas.width;
            if (this.y > canvas.height) this.y = 0;
            if (this.y < 0) this.y = canvas.height;
        }

        draw() {
            ctx.fillStyle = `rgba(255, 255, 255, ${this.opacity})`;
            ctx.beginPath();
            ctx.arc(this.x, this.y, this.size, 0, Math.PI * 2);
            ctx.fill();
        }
    }

    // Initialize particles
    function initParticles() {
        particles = [];
        const particleCount = Math.min(50, Math.floor(canvas.width / 20));
        for (let i = 0; i < particleCount; i++) {
            particles.push(new Particle());
        }
    }

    // Animation loop
    function animate() {
        ctx.clearRect(0, 0, canvas.width, canvas.height);

        particles.forEach(particle => {
            particle.update();
            particle.draw();
        });

        // Draw connections between nearby particles
        particles.forEach((p1, i) => {
            particles.slice(i + 1).forEach(p2 => {
                const dx = p1.x - p2.x;
                const dy = p1.y - p2.y;
                const distance = Math.sqrt(dx * dx + dy * dy);

                if (distance < 100) {
                    ctx.strokeStyle = `rgba(255, 255, 255, ${0.1 * (1 - distance / 100)})`;
                    ctx.lineWidth = 1;
                    ctx.beginPath();
                    ctx.moveTo(p1.x, p1.y);
                    ctx.lineTo(p2.x, p2.y);
                    ctx.stroke();
                }
            });
        });

        animationFrame = requestAnimationFrame(animate);
    }

    // Initialize
    resizeCanvas();
    initParticles();
    animate();

    // Handle resize
    window.addEventListener('resize', () => {
        resizeCanvas();
        initParticles();
    });

    // Pause animation when not visible (performance optimization)
    document.addEventListener('visibilitychange', () => {
        if (document.hidden) {
            cancelAnimationFrame(animationFrame);
        } else {
            animate();
        }
    });
}

// ============================================================================
// Analytics (Placeholder)
// ============================================================================

function trackEvent(eventName, data = {}) {
    // TODO: Implement actual analytics tracking
    // Example: gtag('event', eventName, data);
    // Or: analytics.track(eventName, data);

    console.log('Event tracked:', eventName, data);
}

// Track page view on load
trackEvent('page_view', {
    page: 'landing',
    timestamp: new Date().toISOString()
});

// ============================================================================
// Pricing Interaction
// ============================================================================

// Highlight recommended plan
document.addEventListener('DOMContentLoaded', () => {
    const professionalCard = document.querySelectorAll('.pricing-card')[1];
    if (professionalCard) {
        // Add subtle pulse to recommended plan
        setInterval(() => {
            professionalCard.style.transform = 'scale(1.02)';
            setTimeout(() => {
                professionalCard.style.transform = 'scale(1)';
            }, 200);
        }, 5000);
    }
});

// ============================================================================
// Easter Eggs (Optional)
// ============================================================================

// Konami code for fun spatial effect
let konamiCode = [];
const konamiPattern = ['ArrowUp', 'ArrowUp', 'ArrowDown', 'ArrowDown', 'ArrowLeft', 'ArrowRight', 'ArrowLeft', 'ArrowRight', 'b', 'a'];

document.addEventListener('keydown', (e) => {
    konamiCode.push(e.key);
    konamiCode = konamiCode.slice(-10);

    if (konamiCode.join('') === konamiPattern.join('')) {
        activateEnhancedSpatialMode();
    }
});

function activateEnhancedSpatialMode() {
    document.body.style.transform = 'perspective(1000px) rotateY(5deg)';
    setTimeout(() => {
        document.body.style.transform = 'perspective(1000px) rotateY(-5deg)';
        setTimeout(() => {
            document.body.style.transform = 'none';
        }, 300);
    }, 300);

    console.log('🎉 Enhanced Spatial Mode Activated!');
}
