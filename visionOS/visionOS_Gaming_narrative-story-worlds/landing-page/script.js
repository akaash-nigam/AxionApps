// Smooth scroll for anchor links
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

// Navbar scroll effect
let lastScroll = 0;
const nav = document.querySelector('.nav');

window.addEventListener('scroll', () => {
    const currentScroll = window.pageYOffset;

    if (currentScroll <= 0) {
        nav.style.boxShadow = 'none';
    } else {
        nav.style.boxShadow = '0 2px 10px rgba(0, 0, 0, 0.1)';
    }

    lastScroll = currentScroll;
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

// Observe all feature cards, testimonials, etc.
document.querySelectorAll('.feature-card, .testimonial-card, .character-card, .faq-item').forEach(el => {
    el.style.opacity = '0';
    el.style.transform = 'translateY(30px)';
    el.style.transition = 'opacity 0.6s ease, transform 0.6s ease';
    observer.observe(el);
});

// Animated counter for stats
function animateValue(element, start, end, duration) {
    let startTimestamp = null;
    const step = (timestamp) => {
        if (!startTimestamp) startTimestamp = timestamp;
        const progress = Math.min((timestamp - startTimestamp) / duration, 1);

        const value = Math.floor(progress * (end - start) + start);

        if (element.dataset.suffix === '%') {
            element.textContent = value + '%';
        } else if (element.dataset.suffix === 'K+') {
            element.textContent = value + 'K+';
        } else {
            element.textContent = value + (value < 10 ? '.0' : '');
        }

        if (progress < 1) {
            window.requestAnimationFrame(step);
        }
    };
    window.requestAnimationFrame(step);
}

// Animate stats when they come into view
const statsObserver = new IntersectionObserver((entries) => {
    entries.forEach(entry => {
        if (entry.isIntersecting && !entry.target.dataset.animated) {
            entry.target.dataset.animated = 'true';

            const statNumbers = entry.target.querySelectorAll('.stat-number');
            statNumbers.forEach(stat => {
                const endValue = parseFloat(stat.textContent);
                if (stat.textContent.includes('%')) {
                    stat.dataset.suffix = '%';
                    animateValue(stat, 0, endValue, 2000);
                } else if (stat.textContent.includes('K+')) {
                    stat.dataset.suffix = 'K+';
                    animateValue(stat, 0, endValue, 2000);
                } else {
                    animateValue(stat, 0, endValue * 10, 2000);
                }
            });
        }
    });
}, { threshold: 0.5 });

const heroStats = document.querySelector('.hero-stats');
if (heroStats) {
    statsObserver.observe(heroStats);
}

// Parallax effect for hero section
window.addEventListener('scroll', () => {
    const scrolled = window.pageYOffset;
    const parallaxElements = document.querySelectorAll('.floating-card');

    parallaxElements.forEach((el, index) => {
        const speed = 0.5 + (index * 0.1);
        const yPos = -(scrolled * speed);
        el.style.transform = `translateY(${yPos}px)`;
    });
});

// Dynamic pricing highlighting
const pricingCards = document.querySelectorAll('.pricing-card');
pricingCards.forEach(card => {
    card.addEventListener('mouseenter', () => {
        pricingCards.forEach(c => {
            if (c !== card && !c.classList.contains('featured')) {
                c.style.opacity = '0.7';
            }
        });
    });

    card.addEventListener('mouseleave', () => {
        pricingCards.forEach(c => {
            c.style.opacity = '1';
        });
    });
});

// FAQ accordion (optional enhancement)
const faqItems = document.querySelectorAll('.faq-item');
faqItems.forEach(item => {
    item.style.cursor = 'pointer';
    item.addEventListener('click', () => {
        item.style.transform = item.style.transform === 'scale(1.02)' ? 'scale(1)' : 'scale(1.02)';
    });
});

// Add hover effect to feature cards
const featureCards = document.querySelectorAll('.feature-card');
featureCards.forEach(card => {
    card.addEventListener('mouseenter', () => {
        const icon = card.querySelector('.feature-icon');
        icon.style.transform = 'scale(1.2) rotate(5deg)';
        icon.style.transition = 'transform 0.3s ease';
    });

    card.addEventListener('mouseleave', () => {
        const icon = card.querySelector('.feature-icon');
        icon.style.transform = 'scale(1) rotate(0deg)';
    });
});

// Character card interactions
const characterCards = document.querySelectorAll('.character-card:not(.coming-soon)');
characterCards.forEach(card => {
    card.addEventListener('mouseenter', () => {
        const traits = card.querySelectorAll('.trait');
        traits.forEach((trait, index) => {
            setTimeout(() => {
                trait.style.transform = 'scale(1.1)';
                trait.style.transition = 'transform 0.2s ease';
            }, index * 50);
        });
    });

    card.addEventListener('mouseleave', () => {
        const traits = card.querySelectorAll('.trait');
        traits.forEach(trait => {
            trait.style.transform = 'scale(1)';
        });
    });
});

// Testimonial card rotation effect
const testimonialCards = document.querySelectorAll('.testimonial-card');
testimonialCards.forEach(card => {
    card.addEventListener('mousemove', (e) => {
        const rect = card.getBoundingClientRect();
        const x = e.clientX - rect.left;
        const y = e.clientY - rect.top;

        const centerX = rect.width / 2;
        const centerY = rect.height / 2;

        const rotateX = (y - centerY) / 20;
        const rotateY = (centerX - x) / 20;

        card.style.transform = `perspective(1000px) rotateX(${rotateX}deg) rotateY(${rotateY}deg) translateY(-5px)`;
    });

    card.addEventListener('mouseleave', () => {
        card.style.transform = 'perspective(1000px) rotateX(0) rotateY(0) translateY(0)';
    });
});

// Add "typed" effect to hero title (optional)
function typeWriter(element, text, speed = 50) {
    let i = 0;
    element.textContent = '';

    function type() {
        if (i < text.length) {
            element.textContent += text.charAt(i);
            i++;
            setTimeout(type, speed);
        }
    }

    type();
}

// CTA button pulse effect
const ctaButtons = document.querySelectorAll('.btn-primary');
ctaButtons.forEach(button => {
    setInterval(() => {
        button.style.transform = 'scale(1.05)';
        setTimeout(() => {
            button.style.transform = 'scale(1)';
        }, 200);
    }, 3000);
});

// Scroll progress indicator
const scrollProgress = document.createElement('div');
scrollProgress.style.cssText = `
    position: fixed;
    top: 0;
    left: 0;
    width: 0%;
    height: 3px;
    background: linear-gradient(135deg, #667eea 0%, #764ba2 100%);
    z-index: 10000;
    transition: width 0.1s ease;
`;
document.body.appendChild(scrollProgress);

window.addEventListener('scroll', () => {
    const winScroll = document.body.scrollTop || document.documentElement.scrollTop;
    const height = document.documentElement.scrollHeight - document.documentElement.clientHeight;
    const scrolled = (winScroll / height) * 100;
    scrollProgress.style.width = scrolled + '%';
});

// Add particles to hero background (enhanced version)
function createParticle() {
    const particle = document.createElement('div');
    particle.style.cssText = `
        position: absolute;
        width: ${Math.random() * 4 + 1}px;
        height: ${Math.random() * 4 + 1}px;
        background: radial-gradient(circle, rgba(99, 102, 241, 0.6) 0%, transparent 70%);
        border-radius: 50%;
        pointer-events: none;
        left: ${Math.random() * 100}%;
        top: ${Math.random() * 100}%;
        animation: float ${Math.random() * 10 + 10}s linear infinite;
    `;

    const heroBackground = document.querySelector('.hero-background');
    if (heroBackground) {
        heroBackground.appendChild(particle);

        // Remove particle after animation
        setTimeout(() => {
            particle.remove();
        }, 20000);
    }
}

// Create particles periodically
setInterval(createParticle, 500);

// Add loading animation
window.addEventListener('load', () => {
    document.body.style.opacity = '0';
    document.body.style.transition = 'opacity 0.5s ease';

    setTimeout(() => {
        document.body.style.opacity = '1';
    }, 100);
});

// Track CTA clicks (for analytics)
document.querySelectorAll('a[href="#download"]').forEach(link => {
    link.addEventListener('click', (e) => {
        console.log('CTA clicked:', link.textContent.trim());
        // In production, send to analytics
        // gtag('event', 'cta_click', { button_text: link.textContent.trim() });
    });
});

// Add Easter egg - triple click on logo
const logo = document.querySelector('.nav-logo');
let clickCount = 0;
let clickTimer;

logo.addEventListener('click', () => {
    clickCount++;
    clearTimeout(clickTimer);

    clickTimer = setTimeout(() => {
        clickCount = 0;
    }, 500);

    if (clickCount === 3) {
        document.body.style.filter = 'hue-rotate(180deg)';
        setTimeout(() => {
            document.body.style.filter = 'none';
        }, 3000);
        clickCount = 0;
    }
});

console.log('🎭 Narrative Story Worlds - Landing Page Loaded');
console.log('Ready to transform your space into story worlds!');
