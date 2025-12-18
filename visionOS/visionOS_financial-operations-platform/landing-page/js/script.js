// ===== Smooth Scrolling =====
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

// ===== Navbar Scroll Effect =====
let lastScroll = 0;
const nav = document.querySelector('.nav');

window.addEventListener('scroll', () => {
    const currentScroll = window.pageYOffset;

    if (currentScroll <= 0) {
        nav.style.transform = 'translateY(0)';
        return;
    }

    if (currentScroll > lastScroll && currentScroll > 100) {
        // Scroll down - hide nav
        nav.style.transform = 'translateY(-100%)';
    } else {
        // Scroll up - show nav
        nav.style.transform = 'translateY(0)';
    }

    lastScroll = currentScroll;
});

// ===== Intersection Observer for Animations =====
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

// Observe all cards and sections
document.querySelectorAll('.problem-card, .feature-card, .benefit-card, .testimonial-card, .pricing-card').forEach(el => {
    el.style.opacity = '0';
    el.style.transform = 'translateY(30px)';
    el.style.transition = 'opacity 0.6s ease, transform 0.6s ease';
    observer.observe(el);
});

// ===== CTA Form Handling =====
const ctaForm = document.querySelector('.cta-form');
if (ctaForm) {
    ctaForm.addEventListener('submit', (e) => {
        e.preventDefault();
        const email = ctaForm.querySelector('input[type="email"]').value;

        // Show success message (in production, this would call an API)
        const successMsg = document.createElement('div');
        successMsg.style.cssText = `
            position: fixed;
            top: 100px;
            right: 20px;
            background: linear-gradient(135deg, #43e97b, #38f9d7);
            color: white;
            padding: 1.5rem 2rem;
            border-radius: 12px;
            box-shadow: 0 8px 32px rgba(67, 233, 123, 0.4);
            z-index: 10000;
            animation: slideIn 0.3s ease;
        `;
        successMsg.innerHTML = `
            <div style="display: flex; align-items: center; gap: 1rem;">
                <span style="font-size: 1.5rem;">✓</span>
                <div>
                    <strong>Success!</strong>
                    <p style="margin: 0; opacity: 0.9;">We'll be in touch soon.</p>
                </div>
            </div>
        `;

        document.body.appendChild(successMsg);

        // Remove after 3 seconds
        setTimeout(() => {
            successMsg.style.animation = 'slideOut 0.3s ease';
            setTimeout(() => successMsg.remove(), 300);
        }, 3000);

        // Reset form
        ctaForm.reset();
    });
}

// ===== Button Click Handlers =====
document.querySelectorAll('.btn-primary, .btn-secondary, .btn-outline').forEach(btn => {
    btn.addEventListener('click', (e) => {
        if (!btn.closest('form') && !btn.getAttribute('href')) {
            // Create ripple effect
            const ripple = document.createElement('span');
            ripple.style.cssText = `
                position: absolute;
                border-radius: 50%;
                background: rgba(255, 255, 255, 0.5);
                width: 100px;
                height: 100px;
                margin-left: -50px;
                margin-top: -50px;
                animation: ripple 0.6s;
                pointer-events: none;
            `;

            const rect = btn.getBoundingClientRect();
            ripple.style.left = e.clientX - rect.left + 'px';
            ripple.style.top = e.clientY - rect.top + 'px';

            btn.style.position = 'relative';
            btn.style.overflow = 'hidden';
            btn.appendChild(ripple);

            setTimeout(() => ripple.remove(), 600);
        }
    });
});

// ===== Dynamic Counter Animation =====
const animateCounter = (element, target, duration = 2000) => {
    const start = 0;
    const increment = target / (duration / 16);
    let current = start;

    const timer = setInterval(() => {
        current += increment;
        if (current >= target) {
            element.textContent = target;
            clearInterval(timer);
        } else {
            element.textContent = Math.floor(current);
        }
    }, 16);
};

// Animate stats when they come into view
const statsObserver = new IntersectionObserver((entries) => {
    entries.forEach(entry => {
        if (entry.isIntersecting && !entry.target.dataset.animated) {
            const value = entry.target.textContent;
            const numericValue = parseInt(value.replace(/[^0-9]/g, ''));

            if (numericValue) {
                entry.target.dataset.animated = 'true';
                animateCounter(entry.target, numericValue);
            }
        }
    });
}, { threshold: 0.5 });

document.querySelectorAll('.stat-value, .benefit-metric').forEach(el => {
    statsObserver.observe(el);
});

// ===== Video Placeholder Click =====
const videoPlaceholder = document.querySelector('.video-placeholder');
if (videoPlaceholder) {
    videoPlaceholder.addEventListener('click', () => {
        // In production, this would open a video modal or redirect to video
        alert('Video demo coming soon! Request a live demo to see FinOps Spatial in action.');
    });
}

// ===== Floating Card Animation Enhancement =====
document.querySelectorAll('.floating-card').forEach((card, index) => {
    card.addEventListener('mouseenter', () => {
        card.style.transform = `translateY(-20px) scale(1.05) rotate(${index % 2 === 0 ? '2deg' : '-2deg'})`;
        card.style.zIndex = '10';
    });

    card.addEventListener('mouseleave', () => {
        card.style.transform = '';
        card.style.zIndex = '';
    });
});

// ===== Add CSS animations =====
const style = document.createElement('style');
style.textContent = `
    @keyframes slideIn {
        from {
            transform: translateX(100%);
            opacity: 0;
        }
        to {
            transform: translateX(0);
            opacity: 1;
        }
    }

    @keyframes slideOut {
        from {
            transform: translateX(0);
            opacity: 1;
        }
        to {
            transform: translateX(100%);
            opacity: 0;
        }
    }

    @keyframes ripple {
        from {
            opacity: 1;
            transform: scale(0);
        }
        to {
            opacity: 0;
            transform: scale(4);
        }
    }
`;
document.head.appendChild(style);

// ===== Parallax Effect for Hero =====
window.addEventListener('scroll', () => {
    const scrolled = window.pageYOffset;
    const parallaxElements = document.querySelectorAll('.gradient-orb');

    parallaxElements.forEach((el, index) => {
        const speed = 0.5 + (index * 0.2);
        el.style.transform = `translateY(${scrolled * speed}px)`;
    });
});

// ===== Add keyboard navigation =====
document.addEventListener('keydown', (e) => {
    if (e.key === 'Escape') {
        // Close any modals (if implemented)
        document.querySelectorAll('.modal').forEach(modal => {
            modal.style.display = 'none';
        });
    }
});

// ===== Pricing Card Hover Effect =====
document.querySelectorAll('.pricing-card').forEach(card => {
    card.addEventListener('mouseenter', function() {
        this.style.transform = 'translateY(-10px) scale(1.02)';
    });

    card.addEventListener('mouseleave', function() {
        this.style.transform = '';
    });
});

// ===== Feature Card Interactive =====
document.querySelectorAll('.feature-card').forEach(card => {
    card.addEventListener('click', function() {
        // Could open a modal with more details
        const title = this.querySelector('h3').textContent;
        console.log(`Feature clicked: ${title}`);
    });
});

// ===== Initialize on load =====
document.addEventListener('DOMContentLoaded', () => {
    console.log('FinOps Spatial Landing Page Loaded');

    // Add loading animation end
    document.body.style.opacity = '0';
    setTimeout(() => {
        document.body.style.transition = 'opacity 0.5s ease';
        document.body.style.opacity = '1';
    }, 100);
});

// ===== Request Demo Button Handlers =====
document.querySelectorAll('[href*="demo"], button:contains("Demo")').forEach(btn => {
    btn.addEventListener('click', (e) => {
        if (!btn.closest('form')) {
            e.preventDefault();
            // In production, this would open a demo request modal
            alert('Thank you for your interest! Our team will contact you within 24 hours to schedule your personalized demo.');
        }
    });
});

// ===== Track scroll depth for analytics =====
let maxScrollDepth = 0;
window.addEventListener('scroll', () => {
    const scrollDepth = (window.scrollY + window.innerHeight) / document.documentElement.scrollHeight * 100;
    if (scrollDepth > maxScrollDepth) {
        maxScrollDepth = scrollDepth;
        // In production, send to analytics
        if (maxScrollDepth > 25 && maxScrollDepth < 30) {
            console.log('User scrolled 25%');
        } else if (maxScrollDepth > 50 && maxScrollDepth < 55) {
            console.log('User scrolled 50%');
        } else if (maxScrollDepth > 75 && maxScrollDepth < 80) {
            console.log('User scrolled 75%');
        }
    }
});
