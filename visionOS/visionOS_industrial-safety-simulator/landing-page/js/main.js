// ==========================================
// SMOOTH SCROLLING
// ==========================================

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

// ==========================================
// NAVBAR SCROLL EFFECT
// ==========================================

const navbar = document.querySelector('.navbar');
let lastScroll = 0;

window.addEventListener('scroll', () => {
    const currentScroll = window.pageYOffset;

    if (currentScroll > 100) {
        navbar.style.background = 'rgba(255, 255, 255, 0.95)';
        navbar.style.boxShadow = '0 2px 20px rgba(0, 0, 0, 0.1)';
    } else {
        navbar.style.background = 'rgba(255, 255, 255, 0.8)';
        navbar.style.boxShadow = 'none';
    }

    lastScroll = currentScroll;
});

// ==========================================
// MOBILE MENU TOGGLE
// ==========================================

const mobileMenuToggle = document.querySelector('.mobile-menu-toggle');
const navLinks = document.querySelector('.nav-links');

if (mobileMenuToggle) {
    mobileMenuToggle.addEventListener('click', () => {
        navLinks.classList.toggle('active');
        mobileMenuToggle.classList.toggle('active');
    });
}

// ==========================================
// INTERSECTION OBSERVER FOR ANIMATIONS
// ==========================================

const observerOptions = {
    threshold: 0.1,
    rootMargin: '0px 0px -50px 0px'
};

const observer = new IntersectionObserver((entries) => {
    entries.forEach(entry => {
        if (entry.isIntersecting) {
            entry.target.classList.add('fade-in');
            observer.unobserve(entry.target);
        }
    });
}, observerOptions);

// Observe all sections and cards
document.querySelectorAll('.feature-card, .roi-card, .industry-card, .testimonial-card, .pricing-card, .comparison-card').forEach(el => {
    observer.observe(el);
});

// ==========================================
// ANIMATED COUNTERS
// ==========================================

function animateCounter(element, target, duration = 2000) {
    const start = 0;
    const increment = target / (duration / 16);
    let current = start;

    const timer = setInterval(() => {
        current += increment;
        if (current >= target) {
            current = target;
            clearInterval(timer);
        }

        // Format number
        if (element.dataset.format === 'currency') {
            element.textContent = '$' + Math.floor(current).toLocaleString() + 'M';
        } else if (element.dataset.format === 'percentage') {
            element.textContent = Math.floor(current) + '%';
        } else {
            element.textContent = Math.floor(current).toLocaleString();
        }
    }, 16);
}

// Animate stat numbers when they come into view
const statObserver = new IntersectionObserver((entries) => {
    entries.forEach(entry => {
        if (entry.isIntersecting) {
            const element = entry.target;
            const targetValue = parseFloat(element.dataset.target);
            animateCounter(element, targetValue);
            statObserver.unobserve(element);
        }
    });
}, { threshold: 0.5 });

document.querySelectorAll('.stat-number').forEach(stat => {
    // Extract numeric value
    const text = stat.textContent;
    let value = parseFloat(text.replace(/[^0-9.]/g, ''));

    if (text.includes('M')) {
        stat.dataset.format = 'currency';
        stat.dataset.target = value;
    } else if (text.includes('%')) {
        stat.dataset.format = 'percentage';
        stat.dataset.target = value;
    } else {
        stat.dataset.target = value;
    }

    stat.textContent = '0';
    statObserver.observe(stat);
});

// ==========================================
// FORM HANDLING
// ==========================================

const demoForm = document.getElementById('demoForm');

if (demoForm) {
    demoForm.addEventListener('submit', async (e) => {
        e.preventDefault();

        const formData = new FormData(demoForm);
        const data = Object.fromEntries(formData);

        console.log('Form submitted:', data);

        // Show success message
        const button = demoForm.querySelector('button[type="submit"]');
        const originalText = button.innerHTML;

        button.innerHTML = `
            <svg width="20" height="20" viewBox="0 0 20 20" fill="none">
                <path d="M4 10L8 14L16 6" stroke="currentColor" stroke-width="2"/>
            </svg>
            <span>Demo Requested!</span>
        `;
        button.disabled = true;

        // Reset form after 3 seconds
        setTimeout(() => {
            demoForm.reset();
            button.innerHTML = originalText;
            button.disabled = false;
        }, 3000);

        // In production, send to backend
        // await fetch('/api/demo-request', {
        //     method: 'POST',
        //     headers: { 'Content-Type': 'application/json' },
        //     body: JSON.stringify(data)
        // });
    });
}

// ==========================================
// PARALLAX EFFECT FOR HERO
// ==========================================

window.addEventListener('scroll', () => {
    const scrolled = window.pageYOffset;
    const parallaxElements = document.querySelectorAll('.gradient-orb');

    parallaxElements.forEach((element, index) => {
        const speed = 0.5 + (index * 0.2);
        element.style.transform = `translateY(${scrolled * speed}px)`;
    });
});

// ==========================================
// PRICING CARD INTERACTION
// ==========================================

document.querySelectorAll('.pricing-card').forEach(card => {
    card.addEventListener('mouseenter', () => {
        card.style.transform = 'translateY(-10px)';
    });

    card.addEventListener('mouseleave', () => {
        card.style.transform = 'translateY(0)';
    });
});

// ==========================================
// FEATURE CARD HOVER EFFECTS
// ==========================================

document.querySelectorAll('.feature-card').forEach(card => {
    const icon = card.querySelector('.feature-icon');

    card.addEventListener('mouseenter', () => {
        if (icon) {
            icon.style.transform = 'scale(1.1) rotate(5deg)';
        }
    });

    card.addEventListener('mouseleave', () => {
        if (icon) {
            icon.style.transform = 'scale(1) rotate(0deg)';
        }
    });
});

// ==========================================
// DEVICE MOCKUP ANIMATION
// ==========================================

function animateDeviceMockup() {
    const scene = document.querySelector('.training-scene');
    if (!scene) return;

    const hazard = scene.querySelector('.hazard');
    const worker = scene.querySelector('.worker');
    const equipment = scene.querySelector('.equipment');

    // Animate elements
    if (hazard) {
        setInterval(() => {
            hazard.style.opacity = Math.random() * 0.5 + 0.5;
        }, 1000);
    }

    if (worker) {
        let position = 25;
        let direction = 1;
        setInterval(() => {
            position += direction * 2;
            if (position >= 75 || position <= 25) direction *= -1;
            worker.style.right = position + '%';
        }, 100);
    }

    if (equipment) {
        let scale = 1;
        let growing = true;
        setInterval(() => {
            scale += growing ? 0.02 : -0.02;
            if (scale >= 1.2 || scale <= 1) growing = !growing;
            equipment.style.transform = `translate(-50%, -50%) scale(${scale})`;
        }, 50);
    }
}

// Start animations when page loads
window.addEventListener('load', () => {
    animateDeviceMockup();
});

// ==========================================
// VIDEO MODAL (for demo video)
// ==========================================

const videoButtons = document.querySelectorAll('a[href="#video"]');

videoButtons.forEach(button => {
    button.addEventListener('click', (e) => {
        e.preventDefault();

        // Create modal
        const modal = document.createElement('div');
        modal.style.cssText = `
            position: fixed;
            top: 0;
            left: 0;
            right: 0;
            bottom: 0;
            background: rgba(0, 0, 0, 0.9);
            display: flex;
            align-items: center;
            justify-content: center;
            z-index: 10000;
            padding: 20px;
        `;

        modal.innerHTML = `
            <div style="max-width: 1200px; width: 100%; position: relative;">
                <button style="
                    position: absolute;
                    top: -40px;
                    right: 0;
                    background: none;
                    border: none;
                    color: white;
                    font-size: 2rem;
                    cursor: pointer;
                    padding: 10px;
                " onclick="this.closest('div').parentElement.remove()">×</button>
                <div style="
                    position: relative;
                    padding-bottom: 56.25%;
                    background: #000;
                    border-radius: 12px;
                    overflow: hidden;
                ">
                    <iframe
                        style="position: absolute; top: 0; left: 0; width: 100%; height: 100%;"
                        src="https://www.youtube.com/embed/dQw4w9WgXcQ"
                        frameborder="0"
                        allow="accelerometer; autoplay; clipboard-write; encrypted-media; gyroscope; picture-in-picture"
                        allowfullscreen
                    ></iframe>
                </div>
            </div>
        `;

        document.body.appendChild(modal);

        // Close on background click
        modal.addEventListener('click', (e) => {
            if (e.target === modal) {
                modal.remove();
            }
        });

        // Close on escape key
        document.addEventListener('keydown', function escHandler(e) {
            if (e.key === 'Escape') {
                modal.remove();
                document.removeEventListener('keydown', escHandler);
            }
        });
    });
});

// ==========================================
// SCROLL PROGRESS INDICATOR
// ==========================================

function updateScrollProgress() {
    const windowHeight = window.innerHeight;
    const documentHeight = document.documentElement.scrollHeight;
    const scrollTop = window.pageYOffset;
    const scrollPercentage = (scrollTop / (documentHeight - windowHeight)) * 100;

    // Create progress bar if it doesn't exist
    let progressBar = document.querySelector('.scroll-progress');
    if (!progressBar) {
        progressBar = document.createElement('div');
        progressBar.className = 'scroll-progress';
        progressBar.style.cssText = `
            position: fixed;
            top: 0;
            left: 0;
            height: 3px;
            background: linear-gradient(90deg, #FF6B35 0%, #F7931E 100%);
            z-index: 10000;
            transition: width 0.1s ease;
        `;
        document.body.appendChild(progressBar);
    }

    progressBar.style.width = scrollPercentage + '%';
}

window.addEventListener('scroll', updateScrollProgress);
window.addEventListener('load', updateScrollProgress);

// ==========================================
// CONSOLE MESSAGE
// ==========================================

console.log('%c🚀 Industrial Safety Simulator', 'font-size: 24px; font-weight: bold; background: linear-gradient(90deg, #FF6B35 0%, #F7931E 100%); -webkit-background-clip: text; -webkit-text-fill-color: transparent;');
console.log('%cBuilt for Apple Vision Pro | Transform your safety training', 'font-size: 14px; color: #666;');
