// ============================================
// Sustainability Command Center Landing Page
// Interactive JavaScript
// ============================================

// ===== Smooth Scroll Navigation =====
document.addEventListener('DOMContentLoaded', function() {
    // Smooth scroll for all anchor links
    const anchorLinks = document.querySelectorAll('a[href^="#"]');

    anchorLinks.forEach(link => {
        link.addEventListener('click', function(e) {
            const href = this.getAttribute('href');

            // Skip if it's just "#"
            if (href === '#') {
                e.preventDefault();
                return;
            }

            const target = document.querySelector(href);

            if (target) {
                e.preventDefault();
                const navHeight = document.querySelector('.nav').offsetHeight;
                const targetPosition = target.offsetTop - navHeight;

                window.scrollTo({
                    top: targetPosition,
                    behavior: 'smooth'
                });
            }
        });
    });
});

// ===== Navbar Scroll Effect =====
let lastScroll = 0;
const nav = document.querySelector('.nav');

window.addEventListener('scroll', function() {
    const currentScroll = window.pageYOffset;

    // Add shadow on scroll
    if (currentScroll > 50) {
        nav.style.boxShadow = '0 4px 20px rgba(0, 0, 0, 0.3)';
    } else {
        nav.style.boxShadow = 'none';
    }

    lastScroll = currentScroll;
});

// ===== Intersection Observer for Animations =====
const observerOptions = {
    threshold: 0.1,
    rootMargin: '0px 0px -50px 0px'
};

const fadeInObserver = new IntersectionObserver(function(entries) {
    entries.forEach(entry => {
        if (entry.isIntersecting) {
            entry.target.style.opacity = '1';
            entry.target.style.transform = 'translateY(0)';
        }
    });
}, observerOptions);

// Observe all sections and cards
document.addEventListener('DOMContentLoaded', function() {
    const animatedElements = document.querySelectorAll(`
        .problem-card,
        .feature-card,
        .step,
        .impact-card,
        .testimonial-card,
        .pricing-card
    `);

    animatedElements.forEach(element => {
        element.style.opacity = '0';
        element.style.transform = 'translateY(30px)';
        element.style.transition = 'opacity 0.6s ease, transform 0.6s ease';
        fadeInObserver.observe(element);
    });
});

// ===== Number Counter Animation =====
function animateCounter(element, target, duration = 2000) {
    const start = 0;
    const increment = target / (duration / 16); // 60fps
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

// Trigger counter animations when hero stats are visible
const heroStatsObserver = new IntersectionObserver(function(entries) {
    entries.forEach(entry => {
        if (entry.isIntersecting) {
            const statNumbers = entry.target.querySelectorAll('.stat-number');
            statNumbers.forEach((stat, index) => {
                const text = stat.textContent.trim();
                let target = 0;

                if (text.includes('M')) {
                    target = parseFloat(text) * 1000000;
                } else if (text.includes('K')) {
                    target = parseFloat(text) * 1000;
                } else if (text.includes('+')) {
                    target = parseInt(text.replace('+', ''));
                } else if (text.includes('%')) {
                    target = parseInt(text);
                    setTimeout(() => {
                        animatePercentage(stat, target);
                    }, index * 200);
                    return;
                } else {
                    target = parseInt(text);
                }

                setTimeout(() => {
                    animateCounter(stat, target);
                }, index * 200);
            });

            heroStatsObserver.unobserve(entry.target);
        }
    });
}, { threshold: 0.5 });

function animatePercentage(element, target) {
    let current = 0;
    const increment = target / 50;

    const timer = setInterval(() => {
        current += increment;
        if (current >= target) {
            element.textContent = target + '%';
            clearInterval(timer);
        } else {
            element.textContent = Math.floor(current) + '%';
        }
    }, 30);
}

document.addEventListener('DOMContentLoaded', function() {
    const heroStats = document.querySelector('.hero-stats');
    if (heroStats) {
        heroStatsObserver.observe(heroStats);
    }
});

// ===== Impact Metrics Counter =====
const impactObserver = new IntersectionObserver(function(entries) {
    entries.forEach(entry => {
        if (entry.isIntersecting) {
            const impactValues = entry.target.querySelectorAll('.impact-value');

            impactValues.forEach((value, index) => {
                const text = value.textContent.trim();

                setTimeout(() => {
                    if (text.includes('%')) {
                        const target = parseInt(text);
                        animatePercentage(value, target);
                    } else if (text.includes('M')) {
                        const target = parseFloat(text.replace('$', '')) * 1000000;
                        animateImpactValue(value, target, true);
                    } else if (text.includes(':')) {
                        const target = parseFloat(text.split(':')[0]);
                        animateRatio(value, target);
                    }
                }, index * 150);
            });

            impactObserver.unobserve(entry.target);
        }
    });
}, { threshold: 0.3 });

function animateImpactValue(element, target, isCurrency = false) {
    let current = 0;
    const increment = target / 50;

    const timer = setInterval(() => {
        current += increment;
        if (current >= target) {
            element.textContent = isCurrency ? '$' + (target / 1000000) + 'M' : target;
            clearInterval(timer);
        } else {
            const displayValue = Math.floor(current / 1000000);
            element.textContent = isCurrency ? '$' + displayValue + 'M' : displayValue;
        }
    }, 30);
}

function animateRatio(element, target) {
    let current = 0;
    const increment = target / 40;

    const timer = setInterval(() => {
        current += increment;
        if (current >= target) {
            element.textContent = target + ':1';
            clearInterval(timer);
        } else {
            element.textContent = current.toFixed(1) + ':1';
        }
    }, 40);
}

document.addEventListener('DOMContentLoaded', function() {
    const impactSection = document.querySelector('.impact-grid');
    if (impactSection) {
        impactObserver.observe(impactSection);
    }
});

// ===== Parallax Effect for Hero =====
window.addEventListener('scroll', function() {
    const scrolled = window.pageYOffset;
    const heroParticles = document.querySelector('.hero-particles');
    const earthSphere = document.querySelector('.earth-sphere');

    if (heroParticles) {
        heroParticles.style.transform = `translateY(${scrolled * 0.3}px)`;
    }

    if (earthSphere && scrolled < window.innerHeight) {
        earthSphere.style.transform = `rotate(${scrolled * 0.1}deg)`;
    }
});

// ===== Mobile Menu Toggle =====
document.addEventListener('DOMContentLoaded', function() {
    // Create mobile menu button if on mobile
    if (window.innerWidth <= 768) {
        const navContainer = document.querySelector('.nav-container');
        const navMenu = document.querySelector('.nav-menu');

        // Create hamburger button
        const hamburger = document.createElement('button');
        hamburger.className = 'mobile-menu-toggle';
        hamburger.innerHTML = '☰';
        hamburger.style.cssText = `
            display: block;
            font-size: 1.5rem;
            background: none;
            border: none;
            color: var(--text-primary);
            cursor: pointer;
            padding: 0.5rem;
        `;

        navContainer.insertBefore(hamburger, navMenu);

        // Toggle menu
        hamburger.addEventListener('click', function() {
            if (navMenu.style.display === 'flex') {
                navMenu.style.display = 'none';
            } else {
                navMenu.style.display = 'flex';
                navMenu.style.flexDirection = 'column';
                navMenu.style.position = 'absolute';
                navMenu.style.top = '100%';
                navMenu.style.left = '0';
                navMenu.style.right = '0';
                navMenu.style.background = 'var(--bg-dark)';
                navMenu.style.padding = 'var(--spacing-lg)';
                navMenu.style.borderTop = '1px solid var(--glass-border)';
            }
        });

        // Close menu when clicking a link
        const menuLinks = navMenu.querySelectorAll('a');
        menuLinks.forEach(link => {
            link.addEventListener('click', () => {
                navMenu.style.display = 'none';
            });
        });
    }
});

// ===== Form Submission (Demo/Contact) =====
// This is a placeholder - you'll need to implement actual form handling
document.addEventListener('DOMContentLoaded', function() {
    const ctaButtons = document.querySelectorAll('a[href="#contact"]');

    ctaButtons.forEach(button => {
        button.addEventListener('click', function(e) {
            // Prevent default for now
            e.preventDefault();

            // Show a simple alert (replace with actual form/modal)
            alert('Contact Form Coming Soon!\n\nFor now, please email: sales@sustainabilitycommand.com');
        });
    });

    const demoButtons = document.querySelectorAll('a[href="#demo"]');

    demoButtons.forEach(button => {
        button.addEventListener('click', function(e) {
            e.preventDefault();
            alert('Demo Video Coming Soon!\n\nSchedule a live demo: demo@sustainabilitycommand.com');
        });
    });
});

// ===== Typing Effect for Hero Title (Optional) =====
function typeWriter(element, text, speed = 50) {
    let i = 0;
    element.innerHTML = '';

    function type() {
        if (i < text.length) {
            element.innerHTML += text.charAt(i);
            i++;
            setTimeout(type, speed);
        }
    }

    type();
}

// ===== Pricing Card Comparison =====
document.addEventListener('DOMContentLoaded', function() {
    const pricingCards = document.querySelectorAll('.pricing-card');

    pricingCards.forEach(card => {
        card.addEventListener('mouseenter', function() {
            // Slightly dim other cards
            pricingCards.forEach(otherCard => {
                if (otherCard !== card) {
                    otherCard.style.opacity = '0.7';
                }
            });
        });

        card.addEventListener('mouseleave', function() {
            // Restore opacity
            pricingCards.forEach(otherCard => {
                otherCard.style.opacity = '1';
            });
        });
    });
});

// ===== Easter Egg: Earth Rotation Speed on Click =====
document.addEventListener('DOMContentLoaded', function() {
    const earthSphere = document.querySelector('.earth-sphere');
    let rotationSpeed = 30;

    if (earthSphere) {
        earthSphere.addEventListener('click', function() {
            rotationSpeed = rotationSpeed === 30 ? 5 : 30;
            this.style.animationDuration = rotationSpeed + 's';

            // Add a little feedback
            this.style.boxShadow = `
                inset 0 0 100px rgba(0, 0, 0, 0.5),
                0 20px 60px rgba(16, 185, 129, ${rotationSpeed === 5 ? 0.6 : 0.3})
            `;
        });
    }
});

// ===== Track Button Clicks (Analytics Placeholder) =====
function trackEvent(category, action, label) {
    // Placeholder for analytics
    console.log('Event:', category, action, label);

    // Example: Google Analytics
    // gtag('event', action, {
    //     event_category: category,
    //     event_label: label
    // });
}

document.addEventListener('DOMContentLoaded', function() {
    // Track CTA clicks
    document.querySelectorAll('.btn-primary').forEach(btn => {
        btn.addEventListener('click', function() {
            trackEvent('CTA', 'click', this.textContent.trim());
        });
    });

    // Track feature card views
    const featureObserver = new IntersectionObserver(function(entries) {
        entries.forEach(entry => {
            if (entry.isIntersecting) {
                const featureTitle = entry.target.querySelector('h3')?.textContent;
                if (featureTitle) {
                    trackEvent('Feature', 'view', featureTitle);
                }
                featureObserver.unobserve(entry.target);
            }
        });
    }, { threshold: 0.5 });

    document.querySelectorAll('.feature-card').forEach(card => {
        featureObserver.observe(card);
    });
});

// ===== Page Load Performance =====
window.addEventListener('load', function() {
    // Log page load time
    const loadTime = performance.timing.domContentLoadedEventEnd - performance.timing.navigationStart;
    console.log('Page loaded in:', loadTime, 'ms');

    // Track performance
    trackEvent('Performance', 'page_load', `${loadTime}ms`);
});

// ===== Scroll Progress Indicator =====
function updateScrollProgress() {
    const windowHeight = window.innerHeight;
    const documentHeight = document.documentElement.scrollHeight - windowHeight;
    const scrollTop = window.pageYOffset;
    const scrollPercent = (scrollTop / documentHeight) * 100;

    // You can use this to show a progress bar
    // For now, just log it
    if (scrollPercent > 75) {
        // User has scrolled 75% - maybe show a bottom CTA
        console.log('User engaged - 75% scroll');
    }
}

let scrollTimeout;
window.addEventListener('scroll', function() {
    clearTimeout(scrollTimeout);
    scrollTimeout = setTimeout(updateScrollProgress, 100);
});

// ===== Copy Email to Clipboard =====
function copyToClipboard(text) {
    navigator.clipboard.writeText(text).then(function() {
        // Show success message
        const toast = document.createElement('div');
        toast.textContent = 'Email copied to clipboard!';
        toast.style.cssText = `
            position: fixed;
            bottom: 20px;
            right: 20px;
            background: var(--primary-green);
            color: white;
            padding: 1rem 1.5rem;
            border-radius: var(--radius-lg);
            box-shadow: var(--shadow-xl);
            z-index: 10000;
            animation: slideIn 0.3s ease;
        `;
        document.body.appendChild(toast);

        setTimeout(() => {
            toast.remove();
        }, 3000);
    });
}

// ===== Initialize Everything =====
console.log('🌍 Sustainability Command Center - Landing Page Loaded');
console.log('Built with ❤️ for a sustainable future 🌱');
