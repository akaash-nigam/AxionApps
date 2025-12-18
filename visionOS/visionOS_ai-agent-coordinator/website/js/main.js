// AI Agent Coordinator - Landing Page JavaScript

// Smooth scroll with offset for fixed nav
document.querySelectorAll('a[href^="#"]').forEach(anchor => {
    anchor.addEventListener('click', function (e) {
        e.preventDefault();
        const target = document.querySelector(this.getAttribute('href'));
        if (target) {
            const offsetTop = target.offsetTop - 80;
            window.scrollTo({
                top: offsetTop,
                behavior: 'smooth'
            });
        }
    });
});

// Navbar background on scroll
window.addEventListener('scroll', () => {
    const nav = document.querySelector('.nav');
    if (window.scrollY > 50) {
        nav.style.background = 'rgba(0, 0, 0, 0.95)';
    } else {
        nav.style.background = 'rgba(28, 28, 30, 0.7)';
    }
});

// Animate elements on scroll
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

// Observe all cards and sections
document.querySelectorAll('.feature-card, .problem-card, .use-case-card, .pricing-card, .spec-card').forEach(el => {
    el.style.opacity = '0';
    el.style.transform = 'translateY(30px)';
    el.style.transition = 'opacity 0.6s ease, transform 0.6s ease';
    observer.observe(el);
});

// Dynamic agent sphere animation
function createAgentSphere(container, delay) {
    const sphere = document.createElement('div');
    sphere.className = 'agent-sphere';
    sphere.style.setProperty('--delay', `${delay}s`);
    sphere.style.setProperty('--x', `${Math.random() * 80 + 10}%`);
    sphere.style.setProperty('--y', `${Math.random() * 80 + 10}%`);

    // Randomly make some spheres errors or learning
    const rand = Math.random();
    if (rand > 0.8) {
        sphere.classList.add('error');
    } else if (rand > 0.6) {
        sphere.classList.add('learning');
    }

    container.appendChild(sphere);

    // Random lifetime
    setTimeout(() => {
        sphere.style.opacity = '0';
        setTimeout(() => sphere.remove(), 1000);
    }, 10000 + Math.random() * 5000);
}

// Continuously create new agent spheres
const spaceContainer = document.querySelector('.space-container');
if (spaceContainer) {
    setInterval(() => {
        if (document.querySelectorAll('.agent-sphere').length < 15) {
            createAgentSphere(spaceContainer, Math.random() * 2);
        }
    }, 3000);
}

// Stats counter animation
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

        // Format based on target value
        if (target >= 1000) {
            element.textContent = Math.floor(current).toLocaleString() + '+';
        } else if (element.textContent.includes('%')) {
            element.textContent = Math.floor(current) + '%';
        } else if (element.textContent.includes('fps')) {
            element.textContent = Math.floor(current) + 'fps';
        } else {
            element.textContent = current.toFixed(1) + '%';
        }
    }, 16);
}

// Trigger counter animation when stats are visible
const statsObserver = new IntersectionObserver((entries) => {
    entries.forEach(entry => {
        if (entry.isIntersecting && !entry.target.dataset.animated) {
            const number = entry.target.querySelector('.stat-number');
            const text = number.textContent;

            // Extract number from text
            let target;
            if (text.includes('50,000')) target = 50000;
            else if (text.includes('90%')) target = 90;
            else if (text.includes('60fps')) target = 60;
            else if (text.includes('99.9%')) target = 99.9;

            animateCounter(number, target);
            entry.target.dataset.animated = 'true';
        }
    });
}, { threshold: 0.5 });

document.querySelectorAll('.stat').forEach(stat => {
    statsObserver.observe(stat);
});

// Demo video placeholder click handler
const demoPlaceholder = document.querySelector('.demo-placeholder');
if (demoPlaceholder) {
    demoPlaceholder.addEventListener('click', () => {
        alert('Demo video coming soon! Request a live demo to see the app in action.');
    });
}

// Dynamic particle effects on hero
function createParticle(x, y) {
    const particle = document.createElement('div');
    particle.className = 'particle';
    particle.style.cssText = `
        position: fixed;
        width: 4px;
        height: 4px;
        background: var(--primary-color);
        border-radius: 50%;
        pointer-events: none;
        z-index: 9999;
        left: ${x}px;
        top: ${y}px;
        box-shadow: 0 0 10px var(--primary-color);
    `;

    document.body.appendChild(particle);

    // Animate particle
    const angle = Math.random() * Math.PI * 2;
    const velocity = 2 + Math.random() * 2;
    const vx = Math.cos(angle) * velocity;
    const vy = Math.sin(angle) * velocity;

    let px = x, py = y;
    let opacity = 1;

    const animate = () => {
        px += vx;
        py += vy;
        opacity -= 0.02;

        particle.style.left = px + 'px';
        particle.style.top = py + 'px';
        particle.style.opacity = opacity;

        if (opacity > 0) {
            requestAnimationFrame(animate);
        } else {
            particle.remove();
        }
    };

    animate();
}

// Add particles on mouse move in hero section
let lastParticleTime = 0;
document.querySelector('.hero')?.addEventListener('mousemove', (e) => {
    const now = Date.now();
    if (now - lastParticleTime > 100) { // Throttle particle creation
        createParticle(e.clientX, e.clientY);
        lastParticleTime = now;
    }
});

// CTA button hover effect
document.querySelectorAll('.btn-primary, .btn-large').forEach(btn => {
    btn.addEventListener('mouseenter', function(e) {
        const rect = this.getBoundingClientRect();
        const ripple = document.createElement('span');
        ripple.style.cssText = `
            position: absolute;
            border-radius: 50%;
            background: rgba(255, 255, 255, 0.3);
            width: 20px;
            height: 20px;
            transform: scale(0);
            animation: ripple 0.6s ease-out;
            pointer-events: none;
            left: ${e.clientX - rect.left - 10}px;
            top: ${e.clientY - rect.top - 10}px;
        `;

        this.style.position = 'relative';
        this.style.overflow = 'hidden';
        this.appendChild(ripple);

        setTimeout(() => ripple.remove(), 600);
    });
});

// Add ripple animation
const style = document.createElement('style');
style.textContent = `
    @keyframes ripple {
        to {
            transform: scale(20);
            opacity: 0;
        }
    }
`;
document.head.appendChild(style);

// Pricing card highlight on scroll
const pricingCards = document.querySelectorAll('.pricing-card');
const highlightObserver = new IntersectionObserver((entries) => {
    entries.forEach(entry => {
        if (entry.isIntersecting) {
            entry.target.style.transform = 'translateY(0)';
        }
    });
}, { threshold: 0.3 });

pricingCards.forEach(card => {
    highlightObserver.observe(card);
});

// Log analytics (placeholder)
function trackEvent(category, action, label) {
    console.log(`Analytics: ${category} - ${action} - ${label}`);
    // In production, integrate with analytics service
}

// Track CTA clicks
document.querySelectorAll('a[href="#contact"]').forEach(link => {
    link.addEventListener('click', () => {
        trackEvent('CTA', 'Click', 'Request Demo');
    });
});

// Track feature interest
document.querySelectorAll('.feature-card').forEach((card, index) => {
    card.addEventListener('click', () => {
        const featureName = card.querySelector('h3').textContent;
        trackEvent('Feature', 'Click', featureName);
    });
});

console.log('AI Agent Coordinator landing page loaded successfully! 🚀');
