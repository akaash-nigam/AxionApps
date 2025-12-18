// ==========================================
// Navigation Scroll Effect
// ==========================================
const navbar = document.querySelector('.navbar');
let lastScrollY = window.scrollY;

window.addEventListener('scroll', () => {
    if (window.scrollY > 50) {
        navbar.style.boxShadow = '0 4px 12px rgba(0, 0, 0, 0.08)';
    } else {
        navbar.style.boxShadow = 'none';
    }

    lastScrollY = window.scrollY;
});

// ==========================================
// Smooth Scroll for Anchor Links
// ==========================================
document.querySelectorAll('a[href^="#"]').forEach(anchor => {
    anchor.addEventListener('click', function (e) {
        const href = this.getAttribute('href');

        // Skip if it's just "#" or for contact/demo modals
        if (href === '#' || href === '#contact' || href === '#demo') {
            e.preventDefault();

            if (href === '#contact') {
                openContactModal();
            } else if (href === '#demo') {
                openDemoModal();
            }
            return;
        }

        const target = document.querySelector(href);
        if (target) {
            e.preventDefault();
            const offsetTop = target.offsetTop - 72; // Account for fixed navbar
            window.scrollTo({
                top: offsetTop,
                behavior: 'smooth'
            });
        }
    });
});

// ==========================================
// Intersection Observer for Animations
// ==========================================
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

// Observe all feature cards, testimonials, pricing cards
const animatedElements = document.querySelectorAll(
    '.feature-card, .testimonial-card, .pricing-card, .benefit-item'
);

animatedElements.forEach((el, index) => {
    el.style.opacity = '0';
    el.style.transform = 'translateY(30px)';
    el.style.transition = `all 0.6s ease-out ${index * 0.1}s`;
    observer.observe(el);
});

// ==========================================
// Dynamic Stats Counter
// ==========================================
function animateCounter(element, target, duration = 2000) {
    const start = 0;
    const increment = target / (duration / 16); // 60fps
    let current = start;

    const timer = setInterval(() => {
        current += increment;
        if (current >= target) {
            element.textContent = formatStatValue(target);
            clearInterval(timer);
        } else {
            element.textContent = formatStatValue(Math.floor(current));
        }
    }, 16);
}

function formatStatValue(value) {
    if (value >= 1000) {
        return (value / 1000).toFixed(1) + 'k';
    }
    return value;
}

// Animate stats when they come into view
const statValues = document.querySelectorAll('.stat-value');
const statsObserver = new IntersectionObserver((entries) => {
    entries.forEach(entry => {
        if (entry.isIntersecting && !entry.target.dataset.animated) {
            entry.target.dataset.animated = 'true';
            const text = entry.target.textContent;
            const value = parseInt(text.replace(/[^0-9]/g, ''));
            if (!isNaN(value)) {
                entry.target.textContent = '0';
                setTimeout(() => {
                    // Keep original text for percentages
                    entry.target.textContent = text;
                }, 100);
            }
        }
    });
}, { threshold: 0.5 });

statValues.forEach(stat => statsObserver.observe(stat));

// ==========================================
// Pricing Toggle (if needed for monthly/annual)
// ==========================================
const pricingToggle = document.getElementById('pricing-toggle');
if (pricingToggle) {
    pricingToggle.addEventListener('change', (e) => {
        const isAnnual = e.target.checked;
        document.querySelectorAll('.price-amount').forEach(price => {
            const monthly = parseInt(price.dataset.monthly);
            const annual = parseInt(price.dataset.annual);
            price.textContent = isAnnual ? annual : monthly;
        });
    });
}

// ==========================================
// Contact Modal
// ==========================================
function openContactModal() {
    // Create modal
    const modal = document.createElement('div');
    modal.className = 'modal';
    modal.innerHTML = `
        <div class="modal-overlay" onclick="closeModal()"></div>
        <div class="modal-content">
            <button class="modal-close" onclick="closeModal()">×</button>
            <h2>Start Your Free Trial</h2>
            <p>Get started with Innovation Laboratory today. No credit card required.</p>
            <form class="contact-form" onsubmit="handleContactSubmit(event)">
                <div class="form-group">
                    <label for="name">Full Name *</label>
                    <input type="text" id="name" name="name" required>
                </div>
                <div class="form-group">
                    <label for="email">Work Email *</label>
                    <input type="email" id="email" name="email" required>
                </div>
                <div class="form-group">
                    <label for="company">Company *</label>
                    <input type="text" id="company" name="company" required>
                </div>
                <div class="form-group">
                    <label for="role">Role</label>
                    <select id="role" name="role">
                        <option value="">Select your role</option>
                        <option value="cto">CTO / Technical Leader</option>
                        <option value="cio">Chief Innovation Officer</option>
                        <option value="rd">R&D Manager</option>
                        <option value="pm">Product Manager</option>
                        <option value="other">Other</option>
                    </select>
                </div>
                <div class="form-group">
                    <label for="team-size">Team Size</label>
                    <select id="team-size" name="team-size">
                        <option value="">Select team size</option>
                        <option value="1-10">1-10</option>
                        <option value="11-50">11-50</option>
                        <option value="51-200">51-200</option>
                        <option value="201-500">201-500</option>
                        <option value="500+">500+</option>
                    </select>
                </div>
                <button type="submit" class="btn-primary btn-full btn-large">Start Free Trial</button>
                <p style="text-align: center; margin-top: 1rem; font-size: 0.875rem; color: #6b7280;">
                    By submitting, you agree to our Terms of Service and Privacy Policy
                </p>
            </form>
        </div>
    `;

    document.body.appendChild(modal);
    document.body.style.overflow = 'hidden';

    // Add modal styles if not already present
    if (!document.getElementById('modal-styles')) {
        const style = document.createElement('style');
        style.id = 'modal-styles';
        style.textContent = `
            .modal {
                position: fixed;
                inset: 0;
                z-index: 9999;
                display: flex;
                align-items: center;
                justify-content: center;
                padding: 1rem;
            }
            .modal-overlay {
                position: absolute;
                inset: 0;
                background: rgba(0, 0, 0, 0.5);
                backdrop-filter: blur(4px);
            }
            .modal-content {
                position: relative;
                background: white;
                border-radius: 1.5rem;
                padding: 2rem;
                max-width: 500px;
                width: 100%;
                max-height: 90vh;
                overflow-y: auto;
                box-shadow: 0 25px 50px -12px rgba(0, 0, 0, 0.25);
            }
            .modal-close {
                position: absolute;
                top: 1rem;
                right: 1rem;
                background: none;
                border: none;
                font-size: 2rem;
                cursor: pointer;
                color: #9ca3af;
                line-height: 1;
                padding: 0;
                width: 2rem;
                height: 2rem;
            }
            .modal-close:hover {
                color: #374151;
            }
            .modal-content h2 {
                margin-bottom: 0.5rem;
                font-size: 1.875rem;
            }
            .modal-content > p {
                color: #6b7280;
                margin-bottom: 2rem;
            }
            .contact-form {
                display: flex;
                flex-direction: column;
                gap: 1.25rem;
            }
            .form-group {
                display: flex;
                flex-direction: column;
                gap: 0.5rem;
            }
            .form-group label {
                font-weight: 600;
                font-size: 0.875rem;
                color: #374151;
            }
            .form-group input,
            .form-group select {
                padding: 0.75rem;
                border: 1px solid #d1d5db;
                border-radius: 0.5rem;
                font-size: 1rem;
                font-family: inherit;
            }
            .form-group input:focus,
            .form-group select:focus {
                outline: none;
                border-color: #667eea;
                box-shadow: 0 0 0 3px rgba(102, 126, 234, 0.1);
            }
        `;
        document.head.appendChild(style);
    }
}

function closeModal() {
    const modal = document.querySelector('.modal');
    if (modal) {
        modal.remove();
        document.body.style.overflow = '';
    }
}

function handleContactSubmit(event) {
    event.preventDefault();

    // Get form data
    const formData = new FormData(event.target);
    const data = Object.fromEntries(formData);

    // Here you would send data to your backend
    console.log('Form submitted:', data);

    // Show success message
    const modalContent = document.querySelector('.modal-content');
    modalContent.innerHTML = `
        <div style="text-align: center; padding: 2rem;">
            <div style="font-size: 4rem; margin-bottom: 1rem;">✓</div>
            <h2 style="margin-bottom: 1rem;">Thank You!</h2>
            <p style="color: #6b7280; margin-bottom: 2rem;">
                We'll be in touch soon to set up your Innovation Laboratory trial.
                Check your email for next steps.
            </p>
            <button onclick="closeModal()" class="btn-primary btn-large">Close</button>
        </div>
    `;
}

// ==========================================
// Demo Modal
// ==========================================
function openDemoModal() {
    const modal = document.createElement('div');
    modal.className = 'modal';
    modal.innerHTML = `
        <div class="modal-overlay" onclick="closeModal()"></div>
        <div class="modal-content" style="max-width: 900px;">
            <button class="modal-close" onclick="closeModal()">×</button>
            <h2>Watch Innovation Laboratory in Action</h2>
            <p>See how teams are transforming innovation with spatial computing</p>
            <div style="margin-top: 2rem; aspect-ratio: 16/9; background: #1a1a2e; border-radius: 0.75rem; display: flex; align-items: center; justify-content: center; color: white;">
                <div style="text-align: center;">
                    <div style="font-size: 4rem; margin-bottom: 1rem;">▶</div>
                    <p>Demo Video Placeholder</p>
                    <p style="font-size: 0.875rem; opacity: 0.7; margin-top: 0.5rem;">
                        Experience immersive ideation, virtual prototyping, and team collaboration
                    </p>
                </div>
            </div>
            <div style="display: grid; grid-template-columns: repeat(3, 1fr); gap: 1rem; margin-top: 2rem;">
                <div style="text-align: center; padding: 1rem;">
                    <div style="font-size: 2rem; margin-bottom: 0.5rem;">💡</div>
                    <h4 style="font-size: 0.875rem; margin-bottom: 0.25rem;">Ideation</h4>
                    <p style="font-size: 0.75rem; color: #6b7280;">3D brainstorming</p>
                </div>
                <div style="text-align: center; padding: 1rem;">
                    <div style="font-size: 2rem; margin-bottom: 0.5rem;">🔬</div>
                    <h4 style="font-size: 0.875rem; margin-bottom: 0.25rem;">Prototyping</h4>
                    <p style="font-size: 0.75rem; color: #6b7280;">Virtual testing</p>
                </div>
                <div style="text-align: center; padding: 1rem;">
                    <div style="font-size: 2rem; margin-bottom: 0.5rem;">🤝</div>
                    <h4 style="font-size: 0.875rem; margin-bottom: 0.25rem;">Collaboration</h4>
                    <p style="font-size: 0.75rem; color: #6b7280;">Team sessions</p>
                </div>
            </div>
            <button onclick="openContactModal()" class="btn-primary btn-full btn-large" style="margin-top: 2rem;">
                Request Personal Demo
            </button>
        </div>
    `;

    document.body.appendChild(modal);
    document.body.style.overflow = 'hidden';
}

// ==========================================
// Floating Cards Animation
// ==========================================
const floatingCards = document.querySelectorAll('.floating-card');
floatingCards.forEach((card, index) => {
    card.style.animationDelay = `${-index * 2}s`;
});

// ==========================================
// Initialize on Load
// ==========================================
document.addEventListener('DOMContentLoaded', () => {
    console.log('Innovation Laboratory Landing Page Loaded');

    // Add subtle parallax effect to hero
    window.addEventListener('scroll', () => {
        const scrolled = window.scrollY;
        const hero = document.querySelector('.hero-visual');
        if (hero && scrolled < 800) {
            hero.style.transform = `translateY(${scrolled * 0.3}px)`;
        }
    });
});

// ==========================================
// Keyboard Navigation
// ==========================================
document.addEventListener('keydown', (e) => {
    if (e.key === 'Escape') {
        closeModal();
    }
});
