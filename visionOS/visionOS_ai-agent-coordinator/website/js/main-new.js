/**
 * AI Agent Coordinator - Landing Page JavaScript
 * Interactive features and animations
 */

// ======================
// Navbar Scroll Effect
// ======================
const navbar = document.querySelector('.navbar');
let lastScroll = 0;

window.addEventListener('scroll', () => {
    const currentScroll = window.pageYOffset;

    if (currentScroll > 100) {
        navbar.classList.add('scrolled');
    } else {
        navbar.classList.remove('scrolled');
    }

    lastScroll = currentScroll;
});

// ======================
// Animated Counter
// ======================
const animateCounter = (element) => {
    const target = parseInt(element.getAttribute('data-target'));
    const duration = 2000; // 2 seconds
    const increment = target / (duration / 16); // 60fps
    let current = 0;

    const updateCounter = () => {
        current += increment;
        if (current < target) {
            element.textContent = Math.floor(current).toLocaleString();
            requestAnimationFrame(updateCounter);
        } else {
            element.textContent = target.toLocaleString();
        }
    };

    updateCounter();
};

// Observe stat numbers for animation
const statObserver = new IntersectionObserver((entries) => {
    entries.forEach(entry => {
        if (entry.isIntersecting) {
            const counter = entry.target;
            if (!counter.classList.contains('animated')) {
                counter.classList.add('animated');
                animateCounter(counter);
            }
        }
    });
}, { threshold: 0.5 });

document.querySelectorAll('.stat-number').forEach(stat => {
    statObserver.observe(stat);
});

// ======================
// Tab Switching
// ======================
const tabButtons = document.querySelectorAll('.tab-btn');
const tabContents = document.querySelectorAll('.tab-content');

tabButtons.forEach(button => {
    button.addEventListener('click', () => {
        const targetTab = button.getAttribute('data-tab');

        // Remove active class from all buttons and contents
        tabButtons.forEach(btn => btn.classList.remove('active'));
        tabContents.forEach(content => content.classList.remove('active'));

        // Add active class to clicked button and corresponding content
        button.classList.add('active');
        document.querySelector(`[data-content="${targetTab}"]`).classList.add('active');
    });
});

// ======================
// 3D Hero Canvas Animation
// ======================
const heroCanvas = document.getElementById('heroCanvas');
if (heroCanvas) {
    const ctx = heroCanvas.getContext('2d');

    // Set canvas size
    const resizeCanvas = () => {
        heroCanvas.width = window.innerWidth;
        heroCanvas.height = window.innerHeight;
    };
    resizeCanvas();
    window.addEventListener('resize', resizeCanvas);

    // Particle system for agent visualization
    class Particle {
        constructor() {
            this.reset();
        }

        reset() {
            this.x = Math.random() * heroCanvas.width;
            this.y = Math.random() * heroCanvas.height;
            this.z = Math.random() * 1000;
            this.size = Math.random() * 3 + 1;
            this.speedX = (Math.random() - 0.5) * 0.5;
            this.speedY = (Math.random() - 0.5) * 0.5;
            this.speedZ = Math.random() * 2 + 1;
            this.opacity = Math.random() * 0.5 + 0.3;

            // Random color (blue/purple gradient)
            const colorChoice = Math.random();
            if (colorChoice < 0.7) {
                this.color = `rgba(0, 212, 255, ${this.opacity})`; // Primary blue
            } else if (colorChoice < 0.9) {
                this.color = `rgba(123, 47, 247, ${this.opacity})`; // Purple
            } else {
                this.color = `rgba(255, 51, 102, ${this.opacity})`; // Accent red
            }
        }

        update() {
            this.x += this.speedX;
            this.y += this.speedY;
            this.z -= this.speedZ;

            // Reset if particle goes out of bounds
            if (this.z <= 0 || this.x < 0 || this.x > heroCanvas.width ||
                this.y < 0 || this.y > heroCanvas.height) {
                this.reset();
                this.z = 1000;
            }
        }

        draw() {
            // Calculate size based on depth (z)
            const scale = 1000 / (1000 + this.z);
            const x = (this.x - heroCanvas.width / 2) * scale + heroCanvas.width / 2;
            const y = (this.y - heroCanvas.height / 2) * scale + heroCanvas.height / 2;
            const size = this.size * scale;

            ctx.beginPath();
            ctx.arc(x, y, size, 0, Math.PI * 2);
            ctx.fillStyle = this.color;
            ctx.fill();

            // Add glow effect
            ctx.shadowBlur = 10 * scale;
            ctx.shadowColor = this.color;
        }
    }

    // Create particles
    const particles = Array.from({ length: 100 }, () => new Particle());

    // Connection lines between nearby particles
    const drawConnections = () => {
        particles.forEach((p1, i) => {
            particles.slice(i + 1).forEach(p2 => {
                const dx = p1.x - p2.x;
                const dy = p1.y - p2.y;
                const distance = Math.sqrt(dx * dx + dy * dy);

                if (distance < 150) {
                    const opacity = (1 - distance / 150) * 0.2;
                    ctx.beginPath();
                    ctx.moveTo(p1.x, p1.y);
                    ctx.lineTo(p2.x, p2.y);
                    ctx.strokeStyle = `rgba(0, 212, 255, ${opacity})`;
                    ctx.lineWidth = 1;
                    ctx.stroke();
                }
            });
        });
    };

    // Animation loop
    const animate = () => {
        ctx.clearRect(0, 0, heroCanvas.width, heroCanvas.height);

        // Draw connections first (behind particles)
        drawConnections();

        // Update and draw particles
        particles.forEach(particle => {
            particle.update();
            particle.draw();
        });

        requestAnimationFrame(animate);
    };

    animate();
}

// ======================
// Smooth Scroll
// ======================
document.querySelectorAll('a[href^="#"]').forEach(anchor => {
    anchor.addEventListener('click', function (e) {
        const href = this.getAttribute('href');
        if (href === '#') return;

        e.preventDefault();
        const target = document.querySelector(href);
        if (target) {
            const offsetTop = target.offsetTop - 80; // Account for navbar height
            window.scrollTo({
                top: offsetTop,
                behavior: 'smooth'
            });
        }
    });
});

// ======================
// Intersection Observer for Fade-in Animations
// ======================
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

// Observe all sections
document.querySelectorAll('section').forEach(section => {
    section.style.opacity = '0';
    section.style.transform = 'translateY(30px)';
    section.style.transition = 'opacity 0.8s ease-out, transform 0.8s ease-out';
    observer.observe(section);
});

// ======================
// Video Player (Placeholder)
// ======================
const videoPlaceholder = document.querySelector('.video-placeholder');
if (videoPlaceholder) {
    videoPlaceholder.addEventListener('click', () => {
        // In production, this would open a modal with the actual video
        alert('Video demo would play here. Add your demo video URL.');
    });
}

// ======================
// Form Handling (for Contact/Demo requests)
// ======================
const handleFormSubmit = (formId) => {
    const form = document.getElementById(formId);
    if (form) {
        form.addEventListener('submit', async (e) => {
            e.preventDefault();

            const formData = new FormData(form);
            const data = Object.fromEntries(formData);

            try {
                // In production, send to your backend
                // const response = await fetch('/api/contact', {
                //     method: 'POST',
                //     headers: { 'Content-Type': 'application/json' },
                //     body: JSON.stringify(data)
                // });

                console.log('Form submitted:', data);
                alert('Thank you! We\'ll be in touch soon.');
                form.reset();
            } catch (error) {
                console.error('Form submission error:', error);
                alert('Something went wrong. Please try again.');
            }
        });
    }
};

// ======================
// Particle Cursor Effect (Optional Enhancement)
// ======================
let cursorParticles = [];

class CursorParticle {
    constructor(x, y) {
        this.x = x;
        this.y = y;
        this.size = Math.random() * 3 + 1;
        this.speedX = (Math.random() - 0.5) * 2;
        this.speedY = (Math.random() - 0.5) * 2;
        this.life = 1;
        this.decay = Math.random() * 0.02 + 0.01;
    }

    update() {
        this.x += this.speedX;
        this.y += this.speedY;
        this.life -= this.decay;
        this.size *= 0.98;
    }

    isAlive() {
        return this.life > 0 && this.size > 0.1;
    }
}

// Add cursor trail on mouse move (optional - can be removed if too distracting)
let lastMouseMove = 0;
document.addEventListener('mousemove', (e) => {
    const now = Date.now();
    if (now - lastMouseMove > 50) { // Throttle to every 50ms
        cursorParticles.push(new CursorParticle(e.clientX, e.clientY));
        lastMouseMove = now;
    }
});

// ======================
// Copy to Clipboard (for code snippets if any)
// ======================
const copyToClipboard = (text) => {
    navigator.clipboard.writeText(text).then(() => {
        // Show a temporary success message
        console.log('Copied to clipboard');
    });
};

// ======================
// Dark Mode Toggle (Optional)
// ======================
const initDarkMode = () => {
    const darkModeToggle = document.getElementById('darkModeToggle');
    if (darkModeToggle) {
        const isDarkMode = localStorage.getItem('darkMode') === 'true';
        if (isDarkMode) {
            document.body.classList.add('dark-mode');
        }

        darkModeToggle.addEventListener('click', () => {
            document.body.classList.toggle('dark-mode');
            localStorage.setItem('darkMode',
                document.body.classList.contains('dark-mode'));
        });
    }
};

// ======================
// Lazy Loading for Images
// ======================
const lazyLoadImages = () => {
    const imageObserver = new IntersectionObserver((entries, observer) => {
        entries.forEach(entry => {
            if (entry.isIntersecting) {
                const img = entry.target;
                img.src = img.dataset.src;
                img.classList.add('loaded');
                observer.unobserve(img);
            }
        });
    });

    document.querySelectorAll('img[data-src]').forEach(img => {
        imageObserver.observe(img);
    });
};

// ======================
// Pricing Calculator (if needed)
// ======================
const initPricingCalculator = () => {
    const agentSlider = document.getElementById('agentSlider');
    const priceDisplay = document.getElementById('priceDisplay');

    if (agentSlider && priceDisplay) {
        agentSlider.addEventListener('input', (e) => {
            const agents = parseInt(e.target.value);
            let price = 0;

            if (agents <= 1000) {
                price = 4999;
            } else if (agents <= 10000) {
                price = 19999;
            } else {
                price = 'Custom';
            }

            priceDisplay.textContent = typeof price === 'number'
                ? `$${price.toLocaleString()}/month`
                : price;
        });
    }
};

// ======================
// Newsletter Signup
// ======================
const initNewsletterSignup = () => {
    const newsletterForm = document.getElementById('newsletterForm');
    if (newsletterForm) {
        newsletterForm.addEventListener('submit', async (e) => {
            e.preventDefault();
            const email = newsletterForm.querySelector('input[type="email"]').value;

            try {
                // Send to your email service provider
                console.log('Newsletter signup:', email);
                alert('Thank you for subscribing!');
                newsletterForm.reset();
            } catch (error) {
                console.error('Newsletter signup error:', error);
            }
        });
    }
};

// ======================
// Initialize Everything
// ======================
document.addEventListener('DOMContentLoaded', () => {
    initDarkMode();
    lazyLoadImages();
    initPricingCalculator();
    initNewsletterSignup();

    // Log that page is ready
    console.log('%c🤖 AI Agent Coordinator ',
        'font-size: 20px; font-weight: bold; background: linear-gradient(135deg, #00D4FF, #7B2FF7); -webkit-background-clip: text; -webkit-text-fill-color: transparent;');
    console.log('%cBuilt for Apple Vision Pro',
        'font-size: 12px; color: #00D4FF;');
});

// ======================
// Performance Monitoring
// ======================
if (window.performance) {
    window.addEventListener('load', () => {
        const perfData = window.performance.timing;
        const pageLoadTime = perfData.loadEventEnd - perfData.navigationStart;
        console.log(`Page load time: ${pageLoadTime}ms`);
    });
}

// ======================
// Export for modules (if needed)
// ======================
if (typeof module !== 'undefined' && module.exports) {
    module.exports = {
        animateCounter,
        copyToClipboard
    };
}
