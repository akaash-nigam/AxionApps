// Main JavaScript for Spatial Wellness Landing Page

// Wait for DOM to be fully loaded
document.addEventListener('DOMContentLoaded', function() {
    // Initialize all features
    initMobileMenu();
    initCounters();
    initScrollReveal();
    initSmoothScroll();
    initNavbarScroll();
    initROICalculator();
    initParallax();
    initVideoPlaceholder();
});

// Mobile Menu Toggle
function initMobileMenu() {
    const menuBtn = document.getElementById('mobile-menu-btn');
    const mobileMenu = document.getElementById('mobile-menu');

    if (menuBtn && mobileMenu) {
        menuBtn.addEventListener('click', function() {
            mobileMenu.classList.toggle('hidden');
        });

        // Close menu when clicking on a link
        const menuLinks = mobileMenu.querySelectorAll('a');
        menuLinks.forEach(link => {
            link.addEventListener('click', function() {
                mobileMenu.classList.add('hidden');
            });
        });
    }
}

// Animated Counter
function initCounters() {
    const counters = document.querySelectorAll('.counter');

    const animateCounter = (counter) => {
        const target = parseInt(counter.getAttribute('data-target'));
        const duration = 2000; // 2 seconds
        const increment = target / (duration / 16); // 60fps
        let current = 0;

        const updateCounter = () => {
            current += increment;
            if (current < target) {
                counter.textContent = Math.floor(current) + '%';
                requestAnimationFrame(updateCounter);
            } else {
                counter.textContent = target + '%';
            }
        };

        updateCounter();
    };

    // Use Intersection Observer to trigger when visible
    const observer = new IntersectionObserver((entries) => {
        entries.forEach(entry => {
            if (entry.isIntersecting && !entry.target.classList.contains('animated')) {
                entry.target.classList.add('animated');
                animateCounter(entry.target);
            }
        });
    }, { threshold: 0.5 });

    counters.forEach(counter => observer.observe(counter));
}

// Scroll Reveal Animation
function initScrollReveal() {
    const reveals = document.querySelectorAll('.scroll-reveal');

    const revealObserver = new IntersectionObserver((entries) => {
        entries.forEach(entry => {
            if (entry.isIntersecting) {
                entry.target.classList.add('revealed');
            }
        });
    }, { threshold: 0.1 });

    reveals.forEach(reveal => revealObserver.observe(reveal));
}

// Smooth Scroll for Anchor Links
function initSmoothScroll() {
    document.querySelectorAll('a[href^="#"]').forEach(anchor => {
        anchor.addEventListener('click', function (e) {
            e.preventDefault();
            const target = document.querySelector(this.getAttribute('href'));

            if (target) {
                const offset = 80; // Navbar height
                const targetPosition = target.offsetTop - offset;

                window.scrollTo({
                    top: targetPosition,
                    behavior: 'smooth'
                });
            }
        });
    });
}

// Navbar Background on Scroll
function initNavbarScroll() {
    const navbar = document.querySelector('nav');

    window.addEventListener('scroll', () => {
        if (window.scrollY > 50) {
            navbar.classList.add('navbar-scrolled');
        } else {
            navbar.classList.remove('navbar-scrolled');
        }
    });
}

// ROI Calculator
function initROICalculator() {
    const employeeInput = document.getElementById('employee-count');
    const costInput = document.getElementById('avg-cost');

    // Auto-calculate on page load
    if (employeeInput && costInput) {
        calculateROI();

        // Add event listeners for real-time updates
        employeeInput.addEventListener('input', debounce(calculateROI, 500));
        costInput.addEventListener('input', debounce(calculateROI, 500));
    }
}

// Calculate and display ROI
function calculateROI() {
    const employees = parseInt(document.getElementById('employee-count')?.value) || 500;
    const avgCost = parseInt(document.getElementById('avg-cost')?.value) || 15000;

    // Calculate savings based on PRD metrics
    const totalHealthcareCost = employees * avgCost;
    const healthcareSavings = totalHealthcareCost * 0.40; // 40% reduction
    const productivityGain = totalHealthcareCost * 0.30; // 30% productivity improvement
    const absenteeismSavings = (employees * 550) * 0.50; // 50% reduction in sick days

    const totalROI = healthcareSavings + productivityGain + absenteeismSavings;

    // Update display with animation
    animateValue('healthcare-savings', 0, healthcareSavings, 1000);
    animateValue('productivity-gain', 0, productivityGain, 1200);
    animateValue('absenteeism-savings', 0, absenteeismSavings, 1400);
    animateValue('total-roi', 0, totalROI, 1600);
}

// Animate number changes
function animateValue(id, start, end, duration) {
    const element = document.getElementById(id);
    if (!element) return;

    const range = end - start;
    const increment = range / (duration / 16);
    let current = start;

    const timer = setInterval(() => {
        current += increment;
        if ((increment > 0 && current >= end) || (increment < 0 && current <= end)) {
            current = end;
            clearInterval(timer);
        }
        element.textContent = formatCurrency(Math.floor(current));
    }, 16);
}

// Format number as currency
function formatCurrency(value) {
    return '$' + value.toLocaleString('en-US');
}

// Debounce function for performance
function debounce(func, wait) {
    let timeout;
    return function executedFunction(...args) {
        const later = () => {
            clearTimeout(timeout);
            func(...args);
        };
        clearTimeout(timeout);
        timeout = setTimeout(later, wait);
    };
}

// Parallax Effect
function initParallax() {
    const parallaxElements = document.querySelectorAll('.parallax');

    window.addEventListener('scroll', () => {
        const scrolled = window.pageYOffset;

        parallaxElements.forEach(element => {
            const speed = element.dataset.speed || 0.5;
            const yPos = -(scrolled * speed);
            element.style.transform = `translateY(${yPos}px)`;
        });
    });
}

// Video Placeholder Click Handler
function initVideoPlaceholder() {
    const videoPlaceholder = document.querySelector('.aspect-video');

    if (videoPlaceholder) {
        videoPlaceholder.addEventListener('click', function() {
            // In production, this would open a video modal or play embedded video
            alert('Video demo would play here. In production, integrate with YouTube/Vimeo or custom video player.');
        });
    }
}

// Add hover effect to feature cards
document.querySelectorAll('.feature-card').forEach(card => {
    card.addEventListener('mouseenter', function() {
        this.style.transform = 'translateY(-10px)';
    });

    card.addEventListener('mouseleave', function() {
        this.style.transform = 'translateY(0)';
    });
});

// Request Demo Button Handlers
document.querySelectorAll('button').forEach(button => {
    if (button.textContent.includes('Request Demo') ||
        button.textContent.includes('Schedule Demo') ||
        button.textContent.includes('Schedule Consultation') ||
        button.textContent.includes('Contact Sales')) {

        button.addEventListener('click', function(e) {
            e.preventDefault();
            showContactForm();
        });
    }
});

// Show contact form (placeholder)
function showContactForm() {
    // In production, this would open a modal with a contact form
    // For now, just show an alert
    const name = prompt('Please enter your name:');
    if (name) {
        const email = prompt('Please enter your email:');
        if (email) {
            const company = prompt('Company name:');
            if (company) {
                alert(`Thank you, ${name}! We'll contact you at ${email} soon to schedule your demo. A member of our team will reach out to ${company} within 24 hours.`);

                // In production, send this data to your backend
                console.log('Demo request:', { name, email, company, timestamp: new Date() });
            }
        }
    }
}

// Watch Demo Button Handler
document.querySelectorAll('button').forEach(button => {
    if (button.textContent.includes('Watch Demo')) {
        button.addEventListener('click', function(e) {
            e.preventDefault();
            const demoSection = document.getElementById('demo');
            if (demoSection) {
                demoSection.scrollIntoView({ behavior: 'smooth' });
            }
        });
    }
});

// Add keyboard navigation support
document.addEventListener('keydown', function(e) {
    // Escape key closes mobile menu
    if (e.key === 'Escape') {
        const mobileMenu = document.getElementById('mobile-menu');
        if (mobileMenu && !mobileMenu.classList.contains('hidden')) {
            mobileMenu.classList.add('hidden');
        }
    }
});

// Track scroll depth for analytics (placeholder)
let maxScroll = 0;
window.addEventListener('scroll', debounce(() => {
    const scrollPercent = (window.scrollY / (document.documentElement.scrollHeight - window.innerHeight)) * 100;
    if (scrollPercent > maxScroll) {
        maxScroll = Math.floor(scrollPercent);
        // In production, send to analytics
        console.log('Max scroll depth:', maxScroll + '%');
    }
}, 1000));

// Add entrance animations on load
window.addEventListener('load', function() {
    document.body.classList.add('loaded');

    // Trigger any remaining animations
    setTimeout(() => {
        document.querySelectorAll('.fade-in, .fade-in-delay').forEach(el => {
            el.style.opacity = '1';
            el.style.transform = 'translateY(0)';
        });
    }, 100);
});

// Handle form submissions (if any forms are added)
document.querySelectorAll('form').forEach(form => {
    form.addEventListener('submit', function(e) {
        e.preventDefault();

        const formData = new FormData(this);
        const data = Object.fromEntries(formData.entries());

        console.log('Form submitted:', data);

        // In production, send to your backend API
        // fetch('/api/contact', {
        //     method: 'POST',
        //     headers: { 'Content-Type': 'application/json' },
        //     body: JSON.stringify(data)
        // });

        alert('Thank you for your submission! We\'ll be in touch soon.');
        this.reset();
    });
});

// Lazy load images (if we add real images)
if ('IntersectionObserver' in window) {
    const imageObserver = new IntersectionObserver((entries, observer) => {
        entries.forEach(entry => {
            if (entry.isIntersecting) {
                const img = entry.target;
                if (img.dataset.src) {
                    img.src = img.dataset.src;
                    img.classList.remove('lazy');
                    observer.unobserve(img);
                }
            }
        });
    });

    document.querySelectorAll('img.lazy').forEach(img => imageObserver.observe(img));
}

// Add ripple effect to buttons
document.querySelectorAll('button').forEach(button => {
    button.addEventListener('click', function(e) {
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

        setTimeout(() => ripple.remove(), 600);
    });
});

// Console Easter Egg
console.log('%c🏥 Spatial Wellness Platform', 'color: #2ECC71; font-size: 24px; font-weight: bold;');
console.log('%cInterested in joining our team? Email careers@spatialwellness.health', 'color: #3498DB; font-size: 14px;');
console.log('%cBuilt with ❤️ for healthier workplaces', 'color: #9B59B6; font-size: 12px;');

// Export functions for testing (if needed)
if (typeof module !== 'undefined' && module.exports) {
    module.exports = {
        calculateROI,
        formatCurrency,
        debounce
    };
}
