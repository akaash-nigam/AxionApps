/**
 * Smart Agriculture Landing Page JavaScript
 */

// Smooth scroll to sections
function scrollToDemo() {
    const demoSection = document.getElementById('demo');
    demoSection.scrollIntoView({ behavior: 'smooth' });
}

// Play video modal (placeholder)
function playVideo() {
    alert('Video demo would open here. For full experience, schedule a live demo!');
}

// Form submission
document.getElementById('demoForm')?.addEventListener('submit', function(e) {
    e.preventDefault();

    // Get form data
    const formData = new FormData(this);

    // Simulate form submission
    const submitButton = this.querySelector('button[type="submit"]');
    const originalText = submitButton.innerHTML;

    submitButton.innerHTML = '<span>Processing...</span>';
    submitButton.disabled = true;

    // Simulate API call
    setTimeout(() => {
        // Show success message
        submitButton.innerHTML = '<span>✓ Request Sent!</span>';
        submitButton.style.background = '#33CC4D';

        // Reset form
        setTimeout(() => {
            this.reset();
            submitButton.innerHTML = originalText;
            submitButton.disabled = false;
            submitButton.style.background = '';

            alert('Thank you! Our team will contact you within 24 hours to schedule your personalized demo.');
        }, 2000);
    }, 1500);
});

// Navbar scroll effect
window.addEventListener('scroll', function() {
    const navbar = document.querySelector('.navbar');
    if (window.scrollY > 50) {
        navbar.style.boxShadow = '0 4px 6px rgba(0, 0, 0, 0.1)';
    } else {
        navbar.style.boxShadow = 'none';
    }
});

// Intersection Observer for fade-in animations
const observerOptions = {
    threshold: 0.1,
    rootMargin: '0px 0px -50px 0px'
};

const observer = new IntersectionObserver(function(entries) {
    entries.forEach(entry => {
        if (entry.isIntersecting) {
            entry.target.style.opacity = '1';
            entry.target.style.transform = 'translateY(0)';
        }
    });
}, observerOptions);

// Observe all feature cards, benefit cards, etc.
document.addEventListener('DOMContentLoaded', function() {
    const animatedElements = document.querySelectorAll('.feature-card, .benefit-card, .testimonial-card, .pricing-card');

    animatedElements.forEach(el => {
        el.style.opacity = '0';
        el.style.transform = 'translateY(30px)';
        el.style.transition = 'opacity 0.6s ease, transform 0.6s ease';
        observer.observe(el);
    });

    // Counter animation for stats
    const stats = document.querySelectorAll('.stat-number, .benefit-stat');
    const hasAnimated = new Set();

    const statsObserver = new IntersectionObserver(entries => {
        entries.forEach(entry => {
            if (entry.isIntersecting && !hasAnimated.has(entry.target)) {
                animateCounter(entry.target);
                hasAnimated.add(entry.target);
            }
        });
    }, { threshold: 0.5 });

    stats.forEach(stat => statsObserver.observe(stat));
});

function animateCounter(element) {
    const text = element.textContent;
    const isPercentage = text.includes('%');
    const isTime = text.includes('hrs');
    const isSeason = text.includes('Season');
    const isCustom = text.includes('<');

    // Skip custom formatted text
    if (isCustom || isSeason) return;

    // Extract number
    let targetValue = parseInt(text.replace(/[^0-9-]/g, ''));
    if (isNaN(targetValue)) return;

    const isNegative = text.includes('-');
    const isPositive = text.includes('+');
    let currentValue = 0;
    const duration = 2000; // 2 seconds
    const steps = 60;
    const increment = targetValue / steps;
    const stepDuration = duration / steps;

    const counter = setInterval(() => {
        currentValue += increment;

        if ((increment > 0 && currentValue >= targetValue) ||
            (increment < 0 && currentValue <= targetValue)) {
            currentValue = targetValue;
            clearInterval(counter);
        }

        let displayValue = Math.floor(currentValue);

        if (isNegative) {
            element.textContent = `-${Math.abs(displayValue)}${isPercentage ? '%' : ''}${isTime ? ' hrs/week' : ''}`;
        } else if (isPositive) {
            element.textContent = `+${displayValue}${isPercentage ? '%' : ''}`;
        } else {
            element.textContent = `${displayValue}${isPercentage ? '%' : ''}${isTime ? ' hrs/week' : ''}`;
        }
    }, stepDuration);
}

// Mobile menu toggle (if needed)
const createMobileMenu = () => {
    const nav = document.querySelector('.nav-menu');
    const menuButton = document.createElement('button');
    menuButton.className = 'mobile-menu-button';
    menuButton.innerHTML = '☰';
    menuButton.style.display = 'none';
    menuButton.style.fontSize = '24px';
    menuButton.style.background = 'none';
    menuButton.style.border = 'none';
    menuButton.style.cursor = 'pointer';

    menuButton.addEventListener('click', () => {
        nav.classList.toggle('active');
    });

    document.querySelector('.nav-container').insertBefore(
        menuButton,
        document.querySelector('.cta-button')
    );

    // Show button on mobile
    const mediaQuery = window.matchMedia('(max-width: 768px)');
    const handleMediaChange = (e) => {
        menuButton.style.display = e.matches ? 'block' : 'none';
    };
    mediaQuery.addListener(handleMediaChange);
    handleMediaChange(mediaQuery);
};

// Initialize mobile menu
createMobileMenu();

// Add active state to navigation links
const navLinks = document.querySelectorAll('.nav-menu a');
navLinks.forEach(link => {
    link.addEventListener('click', (e) => {
        e.preventDefault();
        const targetId = link.getAttribute('href');
        const targetSection = document.querySelector(targetId);
        if (targetSection) {
            targetSection.scrollIntoView({ behavior: 'smooth' });
        }
    });
});

// Add scroll spy for active navigation
window.addEventListener('scroll', () => {
    let current = '';
    const sections = document.querySelectorAll('section[id]');

    sections.forEach(section => {
        const sectionTop = section.offsetTop;
        const sectionHeight = section.clientHeight;
        if (pageYOffset >= sectionTop - 200) {
            current = section.getAttribute('id');
        }
    });

    navLinks.forEach(link => {
        link.classList.remove('active');
        if (link.getAttribute('href') === `#${current}`) {
            link.classList.add('active');
        }
    });
});

// Console welcome message
console.log('%cSmart Agriculture', 'font-size: 24px; font-weight: bold; color: #33CC4D');
console.log('%cBuilt for Apple Vision Pro 🍎', 'font-size: 14px; color: #666');
console.log('Interested in the technical details? Check out our documentation at /docs');
