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
        }
    });
});

// Navbar background on scroll
window.addEventListener('scroll', () => {
    const navbar = document.querySelector('.navbar');
    if (window.scrollY > 100) {
        navbar.style.background = 'rgba(0, 0, 0, 0.95)';
    } else {
        navbar.style.background = 'rgba(0, 0, 0, 0.85)';
    }
});

// Intersection Observer for fade-in animations
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

// Observe all feature cards, mode cards, etc.
document.querySelectorAll('.feature-card, .mode-card, .ability-card, .rank-card').forEach(el => {
    el.style.opacity = '0';
    el.style.transform = 'translateY(30px)';
    el.style.transition = 'opacity 0.6s ease, transform 0.6s ease';
    observer.observe(el);
});

// Ability card rotation animation
const abilityCards = document.querySelectorAll('.ability-card');
let currentAbility = 0;

function rotateAbilities() {
    abilityCards.forEach(card => card.classList.remove('active'));
    abilityCards[currentAbility].classList.add('active');
    currentAbility = (currentAbility + 1) % abilityCards.length;
}

// Rotate abilities every 3 seconds
setInterval(rotateAbilities, 3000);

// Parallax effect for hero section
window.addEventListener('scroll', () => {
    const scrolled = window.pageYOffset;
    const heroContent = document.querySelector('.hero-content');
    if (heroContent) {
        heroContent.style.transform = `translateY(${scrolled * 0.5}px)`;
        heroContent.style.opacity = 1 - (scrolled / 800);
    }
});

// Stats counter animation
function animateValue(element, start, end, duration) {
    let startTimestamp = null;
    const step = (timestamp) => {
        if (!startTimestamp) startTimestamp = timestamp;
        const progress = Math.min((timestamp - startTimestamp) / duration, 1);
        const value = Math.floor(progress * (end - start) + start);
        element.textContent = value;
        if (progress < 1) {
            window.requestAnimationFrame(step);
        } else {
            element.textContent = end;
        }
    };
    window.requestAnimationFrame(step);
}

// Observe stats section for counter animation
const statsObserver = new IntersectionObserver((entries) => {
    entries.forEach(entry => {
        if (entry.isIntersecting && !entry.target.classList.contains('counted')) {
            entry.target.classList.add('counted');
            const statNumbers = entry.target.querySelectorAll('.stat-number');
            statNumbers.forEach(stat => {
                const text = stat.textContent;
                if (text.includes('+')) {
                    const value = parseInt(text.replace(/\D/g, ''));
                    stat.textContent = '0+';
                    animateValue(stat, 0, value, 2000);
                    setTimeout(() => {
                        stat.textContent = value + '+';
                    }, 2000);
                }
            });
        }
    });
}, { threshold: 0.5 });

const esportsSection = document.querySelector('.esports-features');
if (esportsSection) {
    statsObserver.observe(esportsSection);
}

// Mouse trail effect (subtle)
const coords = { x: 0, y: 0 };
const circles = document.querySelectorAll('.circle');

// Create mouse trail circles
for (let i = 0; i < 10; i++) {
    const circle = document.createElement('div');
    circle.classList.add('circle');
    circle.style.cssText = `
        position: fixed;
        width: 10px;
        height: 10px;
        border-radius: 50%;
        background: radial-gradient(circle, rgba(0, 217, 255, 0.3), transparent);
        pointer-events: none;
        z-index: 9999;
        opacity: 0;
    `;
    document.body.appendChild(circle);
}

const circleElements = document.querySelectorAll('.circle');

circleElements.forEach((circle, index) => {
    circle.x = 0;
    circle.y = 0;
});

window.addEventListener('mousemove', (e) => {
    coords.x = e.clientX;
    coords.y = e.clientY;
});

function animateCircles() {
    let x = coords.x;
    let y = coords.y;

    circleElements.forEach((circle, index) => {
        circle.style.left = x - 5 + 'px';
        circle.style.top = y - 5 + 'px';
        circle.style.transform = `scale(${(circleElements.length - index) / circleElements.length})`;
        circle.style.opacity = (circleElements.length - index) / circleElements.length * 0.3;

        circle.x = x;
        circle.y = y;

        const nextCircle = circleElements[index + 1] || circleElements[0];
        x += (nextCircle.x - x) * 0.3;
        y += (nextCircle.y - y) * 0.3;
    });

    requestAnimationFrame(animateCircles);
}

animateCircles();

// Hide/show scroll indicator
window.addEventListener('scroll', () => {
    const scrollIndicator = document.querySelector('.scroll-indicator');
    if (scrollIndicator) {
        if (window.scrollY > 100) {
            scrollIndicator.style.opacity = '0';
        } else {
            scrollIndicator.style.opacity = '1';
        }
    }
});

// Add glowing effect to buttons on hover
document.querySelectorAll('.button-primary').forEach(button => {
    button.addEventListener('mouseenter', function() {
        this.style.boxShadow = '0 0 20px rgba(0, 217, 255, 0.5), 0 0 40px rgba(0, 217, 255, 0.3)';
    });
    button.addEventListener('mouseleave', function() {
        this.style.boxShadow = '';
    });
});

// Preload fonts
document.fonts.ready.then(() => {
    document.body.classList.add('fonts-loaded');
});

console.log('🎮 Spatial Arena Championship - Landing Page Loaded');
console.log('⚔️ Built exclusively for Apple Vision Pro');
