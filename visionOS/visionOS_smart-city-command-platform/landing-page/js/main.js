/**
 * Smart City Command Platform - Landing Page JavaScript
 */

// Smooth scroll with offset for fixed navbar
document.querySelectorAll('a[href^="#"]').forEach(anchor => {
    anchor.addEventListener('click', function (e) {
        e.preventDefault();
        const target = document.querySelector(this.getAttribute('href'));
        if (target) {
            const offset = 80; // navbar height
            const targetPosition = target.offsetTop - offset;
            window.scrollTo({
                top: targetPosition,
                behavior: 'smooth'
            });
        }
    });
});

// Navbar scroll effect
const navbar = document.querySelector('.navbar');
window.addEventListener('scroll', () => {
    if (window.scrollY > 50) {
        navbar.classList.add('scrolled');
    } else {
        navbar.classList.remove('scrolled');
    }
});

// Use Cases Tabs
const tabButtons = document.querySelectorAll('.tab-btn');
const tabContents = document.querySelectorAll('.tab-content');

tabButtons.forEach(button => {
    button.addEventListener('click', () => {
        // Remove active class from all
        tabButtons.forEach(btn => btn.classList.remove('active'));
        tabContents.forEach(content => content.classList.remove('active'));

        // Add active class to clicked
        button.classList.add('active');
        const tabId = button.dataset.tab;
        document.getElementById(tabId).classList.add('active');
    });
});

// Mobile menu toggle
const mobileMenuToggle = document.querySelector('.mobile-menu-toggle');
const navLinks = document.querySelector('.nav-links');

if (mobileMenuToggle) {
    mobileMenuToggle.addEventListener('click', () => {
        navLinks.classList.toggle('active');
        mobileMenuToggle.classList.toggle('active');
    });
}

// Demo form submission
const demoForm = document.getElementById('demoForm');
const formSuccess = document.getElementById('formSuccess');

if (demoForm) {
    demoForm.addEventListener('submit', async (e) => {
        e.preventDefault();

        // Get form data
        const formData = new FormData(demoForm);
        const data = Object.fromEntries(formData.entries());

        // Log to console (in production, this would send to a server)
        console.log('Demo Request:', data);

        // Show success message
        demoForm.style.display = 'none';
        formSuccess.style.display = 'block';

        // In production, you would send this to your server:
        /*
        try {
            const response = await fetch('/api/demo-request', {
                method: 'POST',
                headers: {
                    'Content-Type': 'application/json',
                },
                body: JSON.stringify(data)
            });

            if (response.ok) {
                demoForm.style.display = 'none';
                formSuccess.style.display = 'block';
            } else {
                alert('Error submitting form. Please try again.');
            }
        } catch (error) {
            console.error('Error:', error);
            alert('Error submitting form. Please try again.');
        }
        */

        // Send email notification (example using mailto - replace with proper email service)
        const subject = encodeURIComponent('Smart City Platform Demo Request');
        const body = encodeURIComponent(`
            New demo request from ${data.name}
            Email: ${data.email}
            City: ${data.city}
            Phone: ${data.phone}
            Role: ${data.role}
            City Size: ${data['city-size']}
        `);

        // Optional: Open email client
        // window.location.href = `mailto:sales@smartcityplatform.com?subject=${subject}&body=${body}`;
    });
}

// Intersection Observer for fade-in animations
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
const animatedElements = document.querySelectorAll(`
    .problem-card,
    .feature-card,
    .roi-card,
    .testimonial-card,
    .pricing-card
`);

animatedElements.forEach(el => {
    el.style.opacity = '0';
    el.style.transform = 'translateY(20px)';
    el.style.transition = 'opacity 0.6s ease, transform 0.6s ease';
    observer.observe(el);
});

// Video modal (if you add a video)
const videoButton = document.querySelector('.btn-secondary[href="#video"]');
if (videoButton) {
    videoButton.addEventListener('click', (e) => {
        e.preventDefault();
        // Create modal for video
        const modal = document.createElement('div');
        modal.className = 'video-modal';
        modal.innerHTML = `
            <div class="modal-backdrop" onclick="this.parentElement.remove()"></div>
            <div class="modal-content">
                <button class="modal-close" onclick="this.closest('.video-modal').remove()">×</button>
                <div class="video-container">
                    <iframe
                        width="100%"
                        height="100%"
                        src="https://www.youtube.com/embed/your-video-id"
                        frameborder="0"
                        allow="accelerometer; autoplay; clipboard-write; encrypted-media; gyroscope; picture-in-picture"
                        allowfullscreen>
                    </iframe>
                </div>
            </div>
        `;

        // Add modal styles
        const style = document.createElement('style');
        style.textContent = `
            .video-modal {
                position: fixed;
                top: 0;
                left: 0;
                right: 0;
                bottom: 0;
                z-index: 9999;
                display: flex;
                align-items: center;
                justify-content: center;
            }
            .modal-backdrop {
                position: absolute;
                top: 0;
                left: 0;
                right: 0;
                bottom: 0;
                background: rgba(0, 0, 0, 0.8);
                cursor: pointer;
            }
            .modal-content {
                position: relative;
                width: 90%;
                max-width: 900px;
                background: white;
                border-radius: 1rem;
                overflow: hidden;
            }
            .modal-close {
                position: absolute;
                top: -40px;
                right: 0;
                background: white;
                border: none;
                width: 32px;
                height: 32px;
                border-radius: 50%;
                font-size: 24px;
                cursor: pointer;
                display: flex;
                align-items: center;
                justify-content: center;
                transition: transform 0.2s;
            }
            .modal-close:hover {
                transform: scale(1.1);
            }
            .video-container {
                position: relative;
                padding-bottom: 56.25%; /* 16:9 */
                height: 0;
            }
            .video-container iframe {
                position: absolute;
                top: 0;
                left: 0;
                width: 100%;
                height: 100%;
            }
        `;

        document.head.appendChild(style);
        document.body.appendChild(modal);
    });
}

// Counter animation for stats
const animateCounter = (element, target, duration = 2000) => {
    const start = 0;
    const increment = target / (duration / 16);
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
};

const formatNumber = (num) => {
    if (num >= 1000000) {
        return (num / 1000000).toFixed(0) + 'M';
    } else if (num >= 1000) {
        return (num / 1000).toFixed(0) + 'K';
    }
    return num.toString();
};

// Animate counters when in view
const statValues = document.querySelectorAll('.stat-value, .roi-number');
const statObserver = new IntersectionObserver((entries) => {
    entries.forEach(entry => {
        if (entry.isIntersecting && !entry.target.dataset.animated) {
            entry.target.dataset.animated = 'true';
            const text = entry.target.textContent;
            const value = parseInt(text.replace(/[^0-9]/g, ''));
            if (!isNaN(value)) {
                entry.target.textContent = '0';
                animateCounter(entry.target, value);
            }
        }
    });
}, { threshold: 0.5 });

statValues.forEach(stat => statObserver.observe(stat));

// Add loading animation
window.addEventListener('load', () => {
    document.body.classList.add('loaded');
});

// Scroll progress indicator (optional)
const createScrollProgress = () => {
    const progressBar = document.createElement('div');
    progressBar.className = 'scroll-progress';
    progressBar.innerHTML = '<div class="progress-fill"></div>';

    const style = document.createElement('style');
    style.textContent = `
        .scroll-progress {
            position: fixed;
            top: 0;
            left: 0;
            right: 0;
            height: 3px;
            background: rgba(0, 0, 0, 0.1);
            z-index: 10000;
        }
        .progress-fill {
            height: 100%;
            background: linear-gradient(90deg, #0066FF 0%, #6366F1 100%);
            width: 0%;
            transition: width 0.1s ease;
        }
    `;

    document.head.appendChild(style);
    document.body.appendChild(progressBar);

    const progressFill = progressBar.querySelector('.progress-fill');

    window.addEventListener('scroll', () => {
        const windowHeight = document.documentElement.scrollHeight - document.documentElement.clientHeight;
        const scrolled = (window.scrollY / windowHeight) * 100;
        progressFill.style.width = scrolled + '%';
    });
};

// Enable scroll progress
createScrollProgress();

// Cookie consent banner (optional, for GDPR compliance)
const showCookieConsent = () => {
    if (!localStorage.getItem('cookieConsent')) {
        const banner = document.createElement('div');
        banner.className = 'cookie-banner';
        banner.innerHTML = `
            <div class="cookie-content">
                <p>🍪 We use cookies to improve your experience. By using our site, you agree to our cookie policy.</p>
                <div class="cookie-actions">
                    <button class="btn btn-primary btn-sm" onclick="acceptCookies()">Accept</button>
                    <button class="btn btn-secondary btn-sm" onclick="this.closest('.cookie-banner').remove()">Decline</button>
                </div>
            </div>
        `;

        const style = document.createElement('style');
        style.textContent = `
            .cookie-banner {
                position: fixed;
                bottom: 20px;
                left: 20px;
                right: 20px;
                background: white;
                padding: 1.5rem;
                border-radius: 0.75rem;
                box-shadow: 0 10px 40px rgba(0, 0, 0, 0.2);
                z-index: 9999;
                max-width: 500px;
            }
            .cookie-content {
                display: flex;
                flex-direction: column;
                gap: 1rem;
            }
            .cookie-content p {
                margin: 0;
                color: var(--text-secondary);
            }
            .cookie-actions {
                display: flex;
                gap: 0.75rem;
            }
            .btn-sm {
                padding: 0.5rem 1rem;
                font-size: 0.875rem;
            }
            @media (max-width: 640px) {
                .cookie-banner {
                    left: 10px;
                    right: 10px;
                }
            }
        `;

        document.head.appendChild(style);
        document.body.appendChild(banner);
    }
};

window.acceptCookies = () => {
    localStorage.setItem('cookieConsent', 'true');
    document.querySelector('.cookie-banner')?.remove();
};

// Show cookie consent after 2 seconds
setTimeout(showCookieConsent, 2000);

// Analytics (replace with your actual analytics)
const trackEvent = (category, action, label) => {
    console.log('Event tracked:', { category, action, label });
    // In production, use Google Analytics, Mixpanel, etc:
    // gtag('event', action, { event_category: category, event_label: label });
};

// Track button clicks
document.querySelectorAll('.btn').forEach(button => {
    button.addEventListener('click', () => {
        const text = button.textContent.trim();
        trackEvent('Button', 'Click', text);
    });
});

console.log('%c🏙️ Smart City Command Platform', 'font-size: 20px; font-weight: bold; color: #0066FF;');
console.log('%cBuilt for Apple Vision Pro | Enterprise-Grade Smart City Management', 'font-size: 12px; color: #6B7280;');
